2022-11-02c
# MyPlayground
- MyPlayground is a container for trying anything. 
- Make sure to use branch before doing anything.
- Only the most basic environment setup is done in branch `master`


!!! warning

- Modify only the container building files (Dockerfile, docker-compose.yml, devcontainer.json) at branch **master**; otherwise, it is difficult to maintain.
- That you should build your container at branch master only.

!!! note

- Hello, the previous julia_pkg branch breaks, for the possible reasons below:
    - improper merge 
        1. merge julia_pkg into master
        2. do something in master
        3. merge master in julia_pkg
        4. many files are lost without showing on git history
    - the container is broken
        - git-graph and other vscode addons are not installed properly after building
        - there is uncommitted changes in the git-graph interface, but I see nothing after clicking in.
    

- This branch initiated as master, and files from julia_pkg_unbroken are manually copied here, because when I merge this branch into `new_julia_pkg`, nothing different shows (however, there are indeed files not in `new_julia_pkg`)
