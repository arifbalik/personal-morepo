# Monorepo

I've been using monorepos for commercial projects for a while now and I've come to appreciate the benefits they bring, so I've been thinking about doing the same for my personal projects.  In this post, I'll share how I set up my self monorepo, so that hopefully you can do it too.

## What is a monorepo?

A monorepo is simply a collection of would-be repositories in a single repository. Usually all source files, issues and other materials and processes of an organization or a subset of it are stored in a single repository. This method is already used by big companies like Google and Microsoft and Github is continuing to extend it's support for monorepos -since they are also using it in Microsoft.

## Features

- Devcontainers for reproducible development environments
- Commitlint for consistent commit messages both locally and on CI
- MegaLinter for consistent code quality and linting both locally and on CI
- Self-hosted runners for free CI/CD runs
- Code owners for code responsibility
- `.gitconfig` for the latest git features
- Required workflow runs including `pr-watcher` workflow
- Advanced security features enabled like verified commits, branch protection rules etc.
- npm scripts for easy access to features and maintaining monorepo

## Getting Started

### Requirements

- [GH CLI](https://cli.github.com/)
- [npm](https://www.npmjs.com/)
- [Docker](https://www.docker.com/)
- [VSCode](https://code.visualstudio.com/)

This is a template repository, so you can use it as a starting point for your own monorepo. To use it as your own monorepo, you can click the `Use this template` button at the top of the page or with `gh-cli` you can run the following command:

```bash
gh api \
  --method POST \
  -H "Accept: application/vnd.github+json" \
  -H "X-GitHub-Api-Version: 2022-11-28" \
  /repos/arifbalik/monorepo/generate \
   -f "owner=your-username" -f "name=my-monorepo" -f "description=A test with monorepos"
```

### Setup

After you've created your own monorepo, you can clone it to your local machine and run the following commands:

```bash
npm install
```

this will install all the dependencies for the monorepo.

From this point on I recommend working in a devcontainer, make sure docker deamon is running and then run the following commands:

```bash
npm run create-volume
npm run dev
```

This will create a volume for the devcontainer and start the devcontainer. Press `Ctrl+Shift+P` and select `Remote-Containers: Attach to Running Container...` to run the devcontainer.

### Devcontainer

Inside the devcontainer volume clone your repo and initialize;

```bash
git clone <your-repo-url>
cd <your-repo-name>
npm install
```

### npm scripts

There are a few npm scripts that you can use to maintain your monorepo:

- `npm run reset-repo` resets the repository to the default settings
- `npm run update-from-template` updates the repository from the template (`arifbalik/monorepo`)
- `npm run signingkey path/to/signingkey.pub` configures git to use ssh signing key to sign commits
- `npm run commitlint` runs commitlint on the repository
- `npm run lint` runs megalinter on the repository
- `npm run create-volume` creates a volume for the devcontainer (if doesn't exist)
- `npm run dev` starts the devcontainer (builds the image if doesn't exist)
  - optional: `npm run dev -- --remove-existing-container` rebuilds the image and starts the devcontainer
- `npm run dev-shell <command>` starts a shell in the devcontainer and runs the command

> [!NOTE]
> Self hosted runners are not enabled by default. Please see [open pull request #8](https://github.com/arifbalik/monorepo/pull/8) to see how to enable them.
