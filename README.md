# Ansible Playbook Docker Image

Executes ansible-playbook command against an externally mounted set of Ansible playbooks

```
docker run --rm -it -v PATH_TO_LOCAL_PLAYBOOKS_DIR:/ansible/playbooks talentincnyc/ansible_playbook PLAYBOOK_FILE
```

## SSH Keys

If Ansible is interacting with external machines, you'll need to mount an SSH key pair for the duration of the play:

```
docker run --rm -it \
    -v ~/.ssh/id_rsa:/root/.ssh/id_rsa \
    -v ~/.ssh/id_rsa.pub:/root/.ssh/id_rsa.pub \
    -v $(pwd):/ansible/playbooks \
    philm/ansible_playbook site.yml
```

## Testing Playbooks - Ansible Target Container

The [Ansible Target Docker image](https://github.com/philm/ansible_target) is an SSH container optimized for testing Ansible playbooks.

First, define your inventory file.

```
[test]
ansible_target
```

Be sure your testing playbooks include the correct host and remote user:

```
- hosts: test
  remote_user: ubuntu

  tasks:
  ... tasks go here ...
```

When testing the playbook, you'll need to link the two containers:

```
docker run --rm -it \
    --link ansible_target \
    -v ~/.ssh/id_rsa:/root/.ssh/id_rsa \
    -v ~/.ssh/id_rsa.pub:/root/.ssh/id_rsa.pub \
    -v $(pwd):/ansible/playbooks \
    philm/ansible_playbook tests.yml -i inventory
```

Note: the SSH key used above should match the one used to run Ansible Target.

### Docker Compose

An sample *docker-compose.yml* file is in this repo's test directory.

Example:
```
docker-compose run --rm test remote.yml -i inventory
```

And if you'd like the ansible_target container to be recreated each time, do:
```
docker rm -v -f ansible_target
```

(Eventually Compose will be able to automatically remove services after each run, see https://github.com/docker/compose/issues/2774)

#### Privileged Operations

Notice the ```privileged: true``` option in the compose file. This enables us to better mimic a VM environment and perform operations such as installing the Docker Engine during a playbook run see [Docker Reference](https://docs.docker.com/engine/reference/commandline/run/#full-container-capabilities-privileged).
