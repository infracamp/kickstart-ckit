# kickstart-ckit

The container kit for building kickstart flavors. It contains the setup, entrypoint scripts
and preinstalled `kicker` command. Just  `COPY --from=ckit /kickstart /kickstart` will extend
your base container image with full kickstart-flavor functionality. 

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

- [`/kickstart/build/ubuntu.d/`](kickstart/build/ubuntu.d): Installer directory for
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
  