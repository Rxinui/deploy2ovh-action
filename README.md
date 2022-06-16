# SSH Deploy GitHub Repo Action

_Originally created by [@pitscher](https://github.com/pitscher/) and forked by [@Rxinui](https://github.com/Rxinui/)_

Simple and fast GitHub Action that deploys your current project to your server using SSH protocol (_ie. OVH vps server_).

It deploys a single branch when cloning GitHub repo which make the deployment faster (see `target-branch`).

## Requirements

- Server **where SSH is supported**
- Server with **`bash`, `git` installed**.
- User with **SSH access granted**
- Access granted to project's git repository. It will be deployed by using `git clone`

## Actions parameters

| **Parameters**     | **Required** | **Description**                                                                                                                                                | **Values**     |
| ------------------ | ------------ | -------------------------------------------------------------------------------------------------------------------------------------------------------------- | -------------- |
| `ssh-user`         | x            | SSH login username                                                                                                                                             | Any            |
| `ssh-password`     | x            | SSH login password. Favouring the use of GitHub secrets                                                                                                        | Any            |
| `ssh-domain`       | x            | SSH login domain. Favouring the use of GitHub secrets                                                                                                          | Any            |
| `git-clone-by`     |              | Git repository clone method. Value must be lowercase. Defaults to `https`                                                                                      | `ssh`, `https` |
| `target-branch`    |              | Git branch to clone/checkout. Defaults to `main`                                                                                                               | Any            |
| `target-directory` |              | Path where git repository will be cloned. Defaults to `~/`                                                                                                     | Any            |
| `pre-command`      |              | Command lines to execute **before the deployment**. If `pre-command` failed, then deployment and post-command won't be executed.                               | Any            |
| `post-command`     |              | Command lines to execute **after the deployment within the `target-directory`**. If `pre-command` or deployment failed, then `post-command` won't be executed. | Any            |
| `protect-files`    |              | Protected files will not be remove during new deployment. Useful when files are not added to git (ie. `.env`).                                                 | List[Path]     |

## Example usage

For instance, within `.github/workflows/main.yml`

### Basic usage

**Requires version >= `v1`**

```yaml
name: Deployment of current GitHub repo on a server through SSH
on:
  push:
    branches: [main, develop]
jobs:
  deploy:
    runs-on: ubuntu-20.04
    steps:
      - uses: Rxinui/ssh-deploy-repo-action@v1
        with:
          # Required
          ssh-user: myuser
          ssh-password: ${{ secrets.OVH_HOSTING_PASSWORD }}
          ssh-domain: ${{ secrets.OVH_HOSTING_DOMAIN }}
          # Optional
          git-clone-by: ssh
          target-branch: develop
          target-directory: /opt/my-awesome-project/
```

### Advanced usage : define post and pre deployment command

**Requires version >= `v1.1`**

```yaml
name: Deployment of current GitHub repo and use of docker-compose on a server through SSH
on:
  push:
    branches: [main, develop]
jobs:
  deploy:
    runs-on: ubuntu-20.04
    steps:
      - uses: Rxinui/ssh-deploy-repo-action@v1.1
        with:
          # Required
          ssh-user: myuser
          ssh-password: ${{ secrets.OVH_HOSTING_PASSWORD }}
          ssh-domain: ${{ secrets.OVH_HOSTING_DOMAIN }}
          # Optional
          git-clone-by: ssh
          target-branch: develop
          target-directory: /opt/my-awesome-project/
          pre-command: | # multi-line script possible
            cd $TARGET_DIRECTORY && 
            docker-compose down -v --remove-orphans
          post-command: docker-compose up -d -V --force-recreate
```

### Advanced usage : protect files before deployment

**Requires version >= `v1.2`**

Deployment is done by deleting project directories and clone it again from GitHub server.

It means that files that are not registered with git will not be deploy again (ie. `.env`)

To avoid that, a new parameter has been added: `protect-files`

```yaml
name: Deployment of current GitHub repo and use of docker-compose on a server through SSH
on:
  push:
    branches: [main, develop]
jobs:
  deploy:
    runs-on: ubuntu-20.04
    steps:
      - uses: Rxinui/ssh-deploy-repo-action@v1.2
        with:
          # Required
          ssh-user: myuser
          ssh-password: ${{ secrets.OVH_HOSTING_PASSWORD }}
          ssh-domain: ${{ secrets.OVH_HOSTING_DOMAIN }}
          # Optional
          git-clone-by: ssh
          target-branch: develop
          target-directory: /opt/my-awesome-project/
          protect-files:
            - ./.env # will protect file .env
            - ./pyvenv/ # will protect folder pyvenv/
```
