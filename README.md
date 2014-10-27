##Toybox

This is a template for building a bad ass development machine for virtualbox using vagrant and puppet.  Apart from actually using the toybox as my primary development box, this is currently my main pattern boilerplate for more custom automation.

##Build target/reference versions:

Vagrant 1.6.5 and Virtualbox 4.3.18 on the host with an Ubuntu guest.  Note that currently only some random subset of the toys will work with redhat/centos.  At least across recent Ubuntu versions, the puppet code is probably (possibly maybe hopefully) fairly generic.  A known working base-box is Ubuntu 14.04 "trusty" (for download command, see "Usage" section).  If you wish to use the optional xwindows setup, I strongly suggest installing the vbguest plugin [vbguest plugin](https://github.com/dotless-de/vagrant-vbguest).  Download vagrant [here](http://www.vagrantup.com/downloads.html), download virtualbox [here](https://www.virtualbox.org/wiki/Downloads).

## Usage

```shell
  $ git clone https://github.com/mattvonrocketstein/toybox.git
  $ cd toybox
  $ vagrant box add trusty64 https://cloud-images.ubuntu.com/vagrant/trusty/current/trusty-server-cloudimg-i386-vagrant-disk1.box
  $ vagrant plugin install vagrant-vbguest
  $ wget http://dist.neo4j.org/neo4j-community-1.7.2-unix.tar.gz
  $ vagrant up # provisioning will take a while..
  $ vagrant reload # just in case puppet misses some restart
```

##The batteries included:
* misc: git, ack-grep, nmap, screen, and tree
* basic dev:
    * ruby: ruby 1.9.3, ruby-dev, gem
    * python: python 2.7.6, python-pip, python-dev, python-virtualenv

##The various toys:
* mongodb (a popular nosql database)
    * version @ 2.4.9
    * default port @ ??
    * started by default on system boot
* neo4j: (a graph database, requires java)
    * version @ Graph Database Kernel 1.7.2
    * WUI/data port @ 7474
    * see Vagrantfile to check if port-forwarding is enabled
* rabbitmq: (a message queue, requires erlang)
    * version @ 3.4.0, Erlang R16B03
    * data port @ 5672
    * users: admin/admin, guest/guest
    * use WUI at http://admin:admin@localhost:15672
    * see Vagrantfile to check if port-forwarding is enabled
* celery: (a task queue framework on top of rabbit)
   * version @ 3.1.6
   * tests: see tests/test_celery.py
* flower: (data viz tool for celery)
    * version @ 0.7.3
    * WUI port @ 5555
    * see Vagrantfile to check if port-forwarding is enabled
* genghisapp: (data viz tool for mongo)
    * version @ 2.3.11
    * WUI port @ 5555
    * see Vagrantfile to check if port-forwarding is enabled
* supervisor: (lightweight daemonizing daemon with simple configuration)
    * version @ 3.0
    * responsible for daemonizing flower
    * responsible for daemonizing genghisapp
    * default port WUI port @ 9001
    * see Vagrantfile to check if port-forwarding is enabled


##Optional stuff:
* mysql5, nodejs
* xwindows
    * basic naked installation (and emacs23)
    * must use `startx`; will not startup on boot
    * includes xmonad
        * sole window manager, will be used by default with "startx".
        * implicitly requires haskell

##The Puppet Layout:
* Entry-point is `puppet/default.pp` (as named in the Vagrantfile)
    * This is probably your starting place for fork-and-mod hacks
* The `puppet` directory has two subdirs, namely `core` and `site`
    * `core` is meant for modules that will not change.
    * `site` is meant for modules that are more idiosyncratic
* Two stages are defined in `default.pp`: 'first' and 'last'.
    * Stages are used to guarantee aspects of the run-order
        * see [puppet language guide](http://docs.puppetlabs.com/guides/language_guide.html) and the section "Run Stages"

##Credits:
    * https://github.com/aubricus/vagrant-puppet-boilerplate
    * https://github.com/opencredo/neo4j-puppet
    * https://forge.puppetlabs.com/proletaryo/supervisor
    * https://github.com/puppetlabs/puppetlabs-rabbitmq
