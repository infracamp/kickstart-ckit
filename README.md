# kickstart-ckit

[infracamp.org](https://infracamp.org) | [github page](https://github.com/infracamp/kickstart-ckit)

The container kit for building kickstart flavors. It contains the setup, entrypoint scripts
and preinstalled `kicker` command. Just  `COPY --from=ckit /kickstart /kickstart` will extend
your base container image with full kickstart-flavor functionality. 

CKit offers a standarized entrypoint and the [kick](https://gighub.com/infracamp/kicker) command
executor to easy configure and start services inside the container.

## TL;DR: Building containers

```dockerfile
FROM nfra/kickstart-ckit:1.0 AS ckit

FROM ubunut:18.04
COPY --from=ckit /kickstart /kickstart

# ... Do some modifications ...

RUN chmod -R 755 /kickstart && /kickstart/build/build-ubuntu.sh
ENTRYPOINT ["/kickstart/run/entrypoint.sh"]
```


## Directories

### Build stage

> The build stage is executed only during `docker build` run. Everything done during 
> build stage will be stored inside the container image.
>
> If you want to install software with `apt-get` or `npm` or `composer`. This stage
> is the correct place to do it

- [`/kickstart/build/ubuntu.d/`](kickstart/flavor/build.d): Installer directory for
  Ubuntu based containers. All scripts inside this directory will be executed when
  `RUN /kickstart/build/build-ubuntu.sh` is executed during build.


### Run stage

> **Do not** use a run stage to install / update / download software (like `apt-get`). 
> See the build stage above on how to install software during build time.

> All changes done during this stage will be lost after container shutdown. The run stage
> is only meant to prepare and run services build before.

- [`/kickstart/run/entrypoint.sh`](kickstart/run/entrypoint.sh): The main script run directly
  inside the container. It will run the whole lifetime of the container in background and
  manage the system start / shutdown.
  
- [`/kickstart/run/prepare.d/`](kickstart/run/prepare.d): Scripts ending with `.sh` in this
  directory will be executed **on each container startup** before any service starts. Use them
  to prepare configuration files.
  
- [`/kickstart/run/start.d/`](kickstart/run/start.d): Scripts here are executed after all
  initialisation (after `kick init`) and should start the actual services as daemon. All
  services defined here must return after startup (daemon mode) to not block further execution.
  
- [`/kickstart/run/stop.d/`](kickstart/run/stop.d): Scripts in this directory will be executed
  whenever the container receives a `SIGTERM` - the order to terminate. They can be used to
  wait for pending requests to complete or do some cleanup stuff. 
  
- [`/kickstart/run/dev.d/`](kickstart/run/dev.d): Scripts in this directory will be executed
  only if the container was run in interactive development mode. It is meant to activate
  debuggers or additional services, that should not be present in production.
  
  
  
## Tags & Versions

We don't like hard version breaks where you have to upgrade all you infrastructure at once.
This is not microservice. Instead we use a versioned tagging approach that will keep also
old versions alive and available.

There is no `latest` nor `testing` tag on this image. The version has to be specified
and will be updated only in case of backward compatibility.

We will build a tested and stable version on the tag `1.0` at least once per week.

If you prefer a stable version, use one of the versioned `static-x.x.x`. These images
will not be updated.

> We suggest to use the stable, regulary updated version `1.0`. It will stay 
> backwards compatible during its lifetime. 

| Image Version                      | Regular updates    | Stable  | Purpose | Branch |
|------------------------------------|--------------------|---------|---------|--------|
| `nfra/kickstart-ckit:1.0`          | YES (1x per week)  | YES     | Use this for Production                   | stable-1.0    |
| `nfra/kickstart-ckit:1.0-rc`       | YES daily          | NO      | Development Release candidate (master)    | master        |
| `nfra/kickstart-ckit:1.0.x`        | NO (static image)  | YES     | Use if you prefer static images or want to compare with older versions | (tag) |

### Alternative Hardware Architectures

Images for arm32v7 (e.g. RaspberryPi) platform:

| Image Version                      | Regular updates    | Stable  | Purpose | Branch |
|------------------------------------|--------------------|---------|---------|--------|
| `nfra/kickstart-ckit:arm32v7-1.0`          | YES (1x per week)  | YES     | Use this for Production                   | stable-1.0    |
| `nfra/kickstart-ckit:arm32v7-1.0.x` | NO (static image)  | YES     | Use if you prefer static images or want to compare with older versions | (tag) |


## Flavor Build modes

### Requirements

Kickstart included from docker image requires no additional libraries to run. Although is
recommend to install at least `git` and `sudo`.

### Project builds

This is the default for kickstart-flavors: The flavor is used in a product. This
product is build and deployed. - No Problemo

### Flavor build

Flavor builds just install some software, define start and stop scripts etc.

But they are no own project. - No Problemo as well



### SDK build

A Sdk build includes both: New software to be installed plus a project plus this
project is to be used by another project as well.

So you want to use the full kickstart functionality for your sdk project as well
as for your project. This is a little bit tricky. Because: which is the project,
kick should run on? Which .kick.yml to interpret?

- You want your sdk to be located in a different directory than /opt (normaly /sdk)

- You can set the `KICK_PATH=/sdk:/opt`: This will include all the commands from the
  both kick.yml files (except build section).
  
  
## Environment variables

| Variable Name | Default | Description |
|---------------|---------|-------------|
| WORKDIR       | /opt    | The workdir where the project is located |
| TIMEZONE      | Europe/Berlin | The locale timezone                |
| DEV_UID       | 1000    | The numeric uid of the developer (user will be adjusted to this id)  |
| DEV_CONTAINER_NAME |    | The name to be presented on development time                         |



