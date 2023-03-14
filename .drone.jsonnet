local Clone() = {
  name: "Clone",
  image: "drone/git",
  commands: [
    "mkdir $HOME/.ssh",
    "chmod 0700 $HOME/.ssh",
    "echo $$DRONE_CLONE_KEY | base64 -d > $HOME/.ssh/id_ed25519",
    "chmod 0600 $HOME/.ssh/id_ed25519",
    'echo -e "
      Host *
        StrictHostKeyChecking accept-new
      " > $HOME/.ssh/config',
    "ssh git@$${DRONE_CLONE_HOST}",
    "git clone ssh://git@$${DRONE_CLONE_HOST}/${DRONE_REPO} .",
    "git checkout ${DRONE_COMMIT_BRANCH}"
  ],
  environment:
    { DRONE_CLONE_KEY: { from_secret: 'drone_clone_key' },
      DRONE_CLONE_HOST: { from_secret: 'drone_clone_host' } },
};

[
  {
    name: "Lint",
    kind: "pipeline",
    clone:
      { disable: true },
    steps: [
      Clone(),
      {
        name: "Lint code",
        image: "registry.element-networks.nl/tools/molecule",
        commands: [
          "ansible-galaxy collection install theforeman.foreman",
          "ansible-galaxy collection install ansible.posix",
          "molecule --version",
          "molecule lint",
          "molecule syntax"
        ],
        privileged: true,
        volumes: [
          { name: "docker", path: "/var/run/docker.sock" },
        ],
      }
    ],
    volumes: [
      { name: "docker",
        host: { path: "/var/run/docker.sock" }
      },
    ],
  },
  {
    name: "Publish",
    kind: "pipeline",
    clone:
      { disable: true },
    steps: [
      {
        name: "Ansible Galaxy",
        image: "registry.element-networks.nl/tools/molecule",
        commands: [
          "ansible-galaxy import --token $$GALAXY_TOKEN Thulium-Drake ansible-role-${DRONE_REPO_NAME##*-} --role-name=${DRONE_REPO_NAME##*-}",
        ],
        environment:
          { GALAXY_TOKEN: { from_secret: "galaxy_token" } },
      },
    ],
    depends_on: [
      "Lint",
    ],
  },
]
