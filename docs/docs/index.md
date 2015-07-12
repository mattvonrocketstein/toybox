##What is it?

Toybox is a template that builds an awesome development environment for virtualbox using vagrant and puppet.  More specifically it comes with a bunch of fun infrastructure components pre-installed so developers can concentrate on developing, not installing services.  Apart from using the toybox as a development playground, this should be usable as pattern boilerplate for other kinds of custom automation.  Toybox includes demos and integration tests for the infrastructure that is bootstrapped- these tests can be run from the guest or the host OS.

##Reference versions

**Vagrant 1.6.5** and **Virtualbox 4.3.18** on the host with an **Ubuntu 14.04** guest.  Note that currently it's only tested on Ubuntu, but the puppet patterns for infrastructure installation should be more or less the same on Redhat/CentOS.

A known working base-box is Ubuntu 14.04 "trusty" (for download command, see "Quick Start" section).  You can download vagrant [here](http://www.vagrantup.com/downloads.html), download virtualbox [here](https://www.virtualbox.org/wiki/Downloads).

<a name="batteries"></a>
##Batteries are included

Various system packages for development are installed out of the box.

* misc: git, ack-grep, nmap, screen, and tree
* basic dev:
    * ruby: ruby 1.9.3, ruby-dev, gem
    * python: python 2.7.6, python-pip, python-dev, python-virtualenv

<a name="toybox"></a>
##Toys in the toybox

* [mongodb](http://www.mongodb.org): a popular nosql database
    * default port @ 27017
    * mongo version is 2.4.9
    * started by default on system boot
    * [genghisapp](http://genghisapp.com): a data viz tool for mongo
        * version @ 2.3.11
        * WUI port at 5556
        * see Vagrantfile to check if port-forwarding is enabled
* [rabbitmq](https://www.rabbitmq.com): a message queue
    * Erlang R16B03 will be installed
    * data port @ 5672
    * rabbit version is 3.4.0
    * users: admin/admin, guest/guest
    * WUI port at 15672
    * see Vagrantfile to check if port-forwarding is enabled
    * [celery](http://celery.readthedocs.org): task queue framework (uses rabbit)
        * celery version is 3.1.6
        * no workers are defined or started by default
        * [flower](http://flower.readthedocs.org/en/latest/): a data viz tool for celery
            * flower version is 0.7.3
            * WUI port @ 5555
            * see Vagrantfile to check if port-forwarding is enabled
* [supervisor](http://supervisord.org): a configurable, lightweight daemon tool
    * version @ 3.0
    * responsible for daemonizing flower
    * responsible for daemonizing genghisapp
    * WUI port @ 9001
    * see Vagrantfile to check if port-forwarding is enabled
* [nginx](http://nginx.org/en/docs/): a webserver with fairly sane configs
    * version @ 1.4.6
    * WUI/data port @ 80
    * default config is simple: just a rendered version of this markdown
    * see Vagrantfile to check if port-forwarding to host 8080 is enabled

##Optional Toys

See the [optional provisioning](toybox_usage/#optional-provisioning) section of the usage documents.


* [neo4j](http://www.neo4j.com): a graph database
    * WUI/data port @ 7474
    * gDB kernel version is 1.7.2
    * this will also install Java.  sorry
    * see Vagrantfile to check if port-forwarding is enabled

* XWindows and [XMonad](http://xmonad.org/) 0.11
    * basic naked installation (well ok, and emacs23)
    * you must use `startx`; will not startup on boot
    * the sole window manager (XMonad) will be used by default with "startx".
    * xmonad implicitly requires haskell
