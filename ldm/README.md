# LDM Dockerfiles #

## Building the LDM ##

You need a TTY and sudo privileges for a proper LDM build which is why it is
handled in a separate container that you run interactively. After the LDM has
been built, you'll upload to RAMADDA (or wherever the `ldmrun` Dockerfile can
find it).

You may have to update the version of the ldm in the `install_ldm.sh` script. If
you do, commit this to the repository.

Now build and run the container:

    docker build -f Dockerfile.ldmbase -t unidata/ldmbase .

    docker build -f Dockerfile.ldmbuild -t unidata/ldmbuild .

    docker-compose -f docker-compose-ldmbuild.yml run ldmbuild bash

At the bash prompt, run `sh install_ldm.sh`. `exit` the container, when done.

The result of this command will put a tar ball of the LDM in the `./output`
directory (on your base machine, not the container). Upload that file to

<http://motherlode.ucar.edu/repository/entry/show/RAMADDA/Unidata/Docker?entryid=2348da77-0f71-4ee2-b6a3-325f5d939202>

## Pushing the LDM Image to DockerHub ##

If the latest version of the LDM has changed, please update the
`Dockerfile.ldmrun` file as well, and commit that to the repository.

At this point:

    docker build -f Dockerfile.ldmrun -t unidata/ldm:<ldm version> .

    docker build -f Dockerfile.ldmrun -t unidata/ldm:latest .

    docker push unidata/ldm:<ldm version>

    docker push unidata/ldm:latest

You are done deploying the LDM.
