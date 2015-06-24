# Owncloud: Open source personal cloud platform written in PHP

This is a Radial Wheel repository for an [Owncloud][owncloud] app.

It doesn't actually run by itself. The Spoke container that this repository
creates merely gathers the source code for the owncloud app itself, the php
language data needed to run it, and results in creating the CGI (Common Gateway
Interface) as a final step, which is a php-fpm socket by default.

It is up to the user to put together the rest of the stack needed to actually
serve this app and combine all the configuration and other Spokes into one
hybrid Wheel repository. One may configure any server, any database, and any
other supplementary tools as long as it can reach this app via the standard unix
socket.

[owncloud]: http://owncloud.org/

## Tunables

Tunable environment variables; modify at runtime. Italics are defaults.

  - **$OWNCLOUD_VERSION**: [_"7.0.2"_] Which owncloud source code version to
    download. (ex.  "7.0.2")
  - **$WWW_DIR**: [_"/data/www"_] Location to store source. Radial
    "best-practice" is in the '/data' directory.

## Radial

[Radial][radial] is a [Docker][docker] container topology strategy that
seeks to put the cannon of Docker best-practices into simple, re-usable, and
scalable images, dockerfiles, and repositories. Radial categorizes containers
into 3 types: Axles, Hubs, and Spokes. A Wheel is a repository used to recreate
an application stack consisting of any combination of all three types of
containers. Check out the [Radial documentation][radialdocs] for more.

One of the main design goals of Radial containers is simple and painless
modularity. All Spoke (application/binary) containers are designed to be run by
themselves as a service (a Wheel consisting of a Hub container for configuration
and a Spoke container for the running binary) or as part of a larger stack as a
Wheel of many Spokes all joined by the Hub container (database, application
code, web server, backend services etc.). Check out the [Wheel
tutorial][wheel-template] for some more details on how this works.

Note also that for now, Radial makes use of [Docker Compose][compose] for
all orchestration, demonstration, and testing. Radial is just a collection of
images and strategies, so technically, any orchestration tool can work. But
Docker Compose was the leanest and most logical to use for now. 

[wheel-template]: https://github.com/radial/template-wheel
[compose]: https://docs.docker.com/compose/install
[docker]: http://docker.io/
[radial]: https://github.com/radial
[radialdocs]: http://radial.viewdocs.io/docs

## How to Use
### Static Build

In case you need to modify the entrypoint script, the Dockerfile itself, create
your "config" branch for dynamic building, or just prefer to build your own from
scratch, then you can do the following:

1. Clone this repository
2. Make whatever changes needed to configuration and add whatever files
3. `docker-compose up`

### Dynamic Build

A standard feature of all Radial images is their ability to be used dynamically.
This means that since great care is made to separate the application code from
it's configuration, as long as you make your application configuration available
as a git repository, and in it's own "config" branch as per the guidelines in
the [Wheel template][wheel-template], no building of any images will be
necessary at deploy time. This has many benefits as it allows rapid deployment
and configuration without any wait time in the building process. However:

**Dynamic builds will not commit your configuration files into any
resulting images like static builds.**

Static builds do a "COPY" of files into the image before exposing the
directories as volumes. Dynamic builds do a `git fetch` at run time and the
resulting data is downloaded to an already existing volume location, which is
now free from Docker versioning. Both methods have their advantages and
disadvantages. Deploying the same exact configuration might benefit from a
single image built statically whereas deploying many different disposable 
configurations rapidly are best done dynamically with no building.

To run dynamically:

1. Modify the `docker-compose-dynamic.yml` file to point at your own Wheel repository
   location by setting the `$WHEEL_REPO` variable. When run, the Hub container
   will pull the "config" branch of that repository and use it to run the Spoke
   container with your own configuration.
3. `docker-compose -f docker-compose-dynamic.yml up`
