##Toybox

Toybox is a template that builds an awesome development environment for virtualbox using vagrant and puppet.  Apart from actually using the toybox as a development playground, this should be usable as pattern boilerplate for other custom automation.

##Build target/reference versions:

Vagrant 1.6.5 and Virtualbox 4.3.18 on the host with an Ubuntu guest.  Note that currently only some random subset of the toys will work with redhat/centos.  At least across recent Ubuntu versions, the puppet code is probably _(possibly maybe hopefully)_ fairly generic.  A known working base-box is Ubuntu 14.04 "trusty" (for download command, see "Usage" section).  If you wish to use the optional xwindows setup, I strongly suggest installing the vbguest plugin [vbguest plugin](https://github.com/dotless-de/vagrant-vbguest).  Download vagrant [here](http://www.vagrantup.com/downloads.html), download virtualbox [here](https://www.virtualbox.org/wiki/Downloads).


##Basic batteries are included:
* misc: git, ack-grep, nmap, screen, and tree
* basic dev:
    * ruby: ruby 1.9.3, ruby-dev, gem
    * python: python 2.7.6, python-pip, python-dev, python-virtualenv

##Other toys in the toybox
* [mongodb](http://www.mongodb.org): a popular nosql database
    * default port @ ??
    * mongo version is 2.4.9
    * started by default on system boot
    * [genghisapp](http://genghisapp.com): a data viz tool for mongo
        * version @ 2.3.11
        * WUI port @ 5555
        * see Vagrantfile to check if port-forwarding is enabled
* [rabbitmq](https://www.rabbitmq.com): a message queue
    * Erlang R16B03 will be installed
    * data port @ 5672
    * rabbit version is 3.4.0
    * users: admin/admin, guest/guest
    * use WUI at http://admin:admin@localhost:15672
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
    * default port WUI port @ 9001
    * see Vagrantfile to check if port-forwarding is enabled
* [nginx](http://nginx.org/en/docs/): a webserver with fairly sane configs
    * version @ 1.4.6
    * WUI/data port @ 80
    * no real default configuration
    * see Vagrantfile to check if port-forwarding to host 8080 is enabled

##Optional toys:
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

## Basic Usage

First we'll need to download a couple of things.  Feel free to skip steps below if you have already cloned this repository, if you already know that you have the right base-box downloaded, or if the vagrant plugin is already installed.

```shell
  $ git clone https://github.com/mattvonrocketstein/toybox.git
  $ cd toybox
  $ vagrant box add trusty64 https://cloud-images.ubuntu.com/vagrant/trusty/current/trusty-server-cloudimg-i386-vagrant-disk1.box
  $ vagrant plugin install vagrant-vbguest
```

Now we'll bring the box up and start the provisioning.  This will take a long time while it imports the basebox, bootstraps it, and then runs the provisioning.   Notes:  Subsequent calls like the one below will not by default rerun provisioning.  If vbguest detects a mismatched guest-additions iso, it may take even longer while it corrects this but it is better to fix it ASAP.

```shell
  $ vagrant up
```

If the command above happens to terminate with a red message _"The SSH command responded with a non-zero exit status.  Vagrant assumes that this means the command failed"_, it might be caused by some download via apt, gem, or pip which has timed out.  If that's the case, you may want to retry provisioning by executing  `vagrant provision`.

If you don't see the _"non-zero exit status"_ message, then it probably succeeded.  But just to be sure that puppet hasn't missed starting or restarting a service that it's updated, you should run

```shell
  $ vagrant reload
```

After this, your box should be working.  You can connect to it now, or try running the tests mentioned under the "Advanced Usage" section.

```shell
   $ vagrant ssh
```

##Advanced Usage: Provisioning with the optional stuff
The optional items are optional mostly because they are big.  You probably don't want this stuff to slow down your install on a slow connections or headless box.  To install the xwindows stuff, run:

```shell
  $ PROVISION_XWIN=true vagrant provision
```

Setting up the neo4j graph database provisioning is similar, but you will need to download their distribution tarball first.  Note: before you start the download, make sure that you're still in the same directory as this README and the Vagrantfile.

```shell
  $ wget http://dist.neo4j.org/neo4j-community-1.7.2-unix.tar.gz
  $ PROVISION_NEO=true vagrant provision
```

##Advanced Usage: Testing from the host
By default, the Vagrantfile forwards lots of ports for the services puppet
is expected to bring up.  During development it can be useful to verify that
those services are indeed alive.  To bootstrap the testing-setup on the host:

```shell
  $ virtualenv host_venv
  $ source host_venv/bin/activate
  $ pip install -r tests/requirements.txt
  $ python tests/test_guest_from_host.py
```

##Advanced Usage: Testing from the guest
Currently, the only thing testable from the guest is celery/rabbit.  To run
those tests,

```shell
  $ virtualenv guest_venv
  $ source guest_venv/bin/activate
  $ pip install -r tests/requirements.txt
  $ python tests/test_guest_from_guest.py
```

##Implementation Remarks: The Puppet Layout
* Entry-point is `puppet/default.pp` (as named in the Vagrantfile)
    * This is probably your starting place for fork-and-mod hacks
* The `puppet` directory has two subdirs, namely `core` and `site`
    * `core` is meant for modules that will not change.
    * `site` is meant for modules that are more idiosyncratic
* Two stages are defined in `default.pp`: 'first' and 'last'.
    * Stages are used to guarantee aspects of the run-order
        * see [puppet language guide](http://docs.puppetlabs.com/guides/language_guide.html) and the section "Run Stages"

##TODO:
* Experimentation with the [AWS provider](https://github.com/mitchellh/vagrant-aws)

##Credits:
Puppet is a crappy language for many reasons, but the worst thing about it is how difficult it is to reuse other code without forking.  Apart from puppet forge standard libraries included in this repo, I have benefited from the work mentioned below:

* https://github.com/opencredo/neo4j-puppet
* https://github.com/aubricus/vagrant-puppet-boilerplate
* https://forge.puppetlabs.com/proletaryo/supervisor
