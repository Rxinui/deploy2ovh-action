# SSH Deploy GitHub Repo Action

_Originally created by [@pitscher](https://github.com/pitscher/) and forked by [@Rxinui](https://github.com/Rxinui/)_

Simple and fast GitHub Action that deploys your current project to your server using SSH protocol (*ie. OVH vps server*).

It deploys a single branch when cloning GitHub repo which make the deployment faster (see `target-branch`).

## Requirements

- Server **where SSH is supported**
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

## Example usage

For instance, within `.github/workflows/main.yml`

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
