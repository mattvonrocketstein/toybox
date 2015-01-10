[requirements](#requirements) | [batteries included](#batteries) | [toys in the toybox](#toybox)

[optional stuff](#optional-provisioning-xwin) | [tests](#running-tests) | [demos](#running-demos) | [implementation remarks](#implementation) | [contributing](#contributing) | [quick-links](#qlinks) | [todo](#todo) | [credits](#credits)

##Toybox

<a name="intro"/>
Toybox is a template that builds an awesome development environment for virtualbox using vagrant and puppet.  Apart from actually using the toybox as a development playground, this should be usable as pattern boilerplate for other kinds of custom automation.  Toybox includes demos and integration tests for the infrastructure that is bootstrapped, and the tests can be run from either the guest or host OS.

<a name="requirements"/>
##Build target/reference versions:

Vagrant 1.6.5 and Virtualbox 4.3.18 on the host with an Ubuntu guest.  Note that currently only some random subset of the toys will work with redhat/centos.  At least across recent Ubuntu versions, the puppet code is probably _(possibly? maybe? hopefully??)_ fairly generic.

A known working base-box is Ubuntu 14.04 "trusty" (for download command, see "Usage" section).  Download vagrant [here](http://www.vagrantup.com/downloads.html), download virtualbox [here](https://www.virtualbox.org/wiki/Downloads).

<a name="batteries"/>
##Basic batteries are included:
* misc: git, ack-grep, nmap, screen, and tree
* basic dev:
    * ruby: ruby 1.9.3, ruby-dev, gem
    * python: python 2.7.6, python-pip, python-dev, python-virtualenv

<a name="toybox"/>
##Other toys in the toybox
* ELK stack

    * [kibana](http://www.elasticsearch.org/overview/kibana/): the k in your ELK stack
        * default port @ 9200
        * version is 1.2.1
    * [logstash](http://logstash.net/):
        * default port @ 9200
        * version is 1.2.1
    * [elasticsearch](http://www.elasticsearch.org): you know, for search
        * default port @ 9200
        * version is 1.2.1
        * kopf WUI is installed
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

<a name="usage"/>
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

After this, your box should be working.  You can connect to it now, or try [running the tests](#running-tests).

```shell
   $ vagrant ssh
```

<a name="optional-provisioning-xwin"/>
##Advanced Usage: Optional Provisioning
The optional items are optional mostly because they are big.  You probably don't want this stuff to slow down your install on a slow connections or headless box.

####Provisioning XWindows

If you wish to use the optional xwindows setup, I strongly suggest installing the vbguest plugin [vbguest plugin](https://github.com/dotless-de/vagrant-vbguest).  (*Note: Unfortunately even then getting full-screen resolution to work may still take some extra fiddling, the situation seems to change slightly with every minor-version release of guest-extensions/virtualbox.)* If you want to change the window manager or other details of this aspect of provisioning, fork this repo and edit `toybox/puppet/modules/site/manifests/xwindows.pp`.  **To enable provisioning for xwindows, run**:

```shell
  $ PROVISION_XWIN=true vagrant provision
```

<a name="optional-provisioning-neo"/>
####Provisioning Neo

Provisioning neo is similar to provisioning XWindows, but you will need to download their distribution tarball first.  Note: before you start the download, make sure that you're still in the same directory as this README and the Vagrantfile.

```shell
  $ wget http://dist.neo4j.org/neo4j-community-1.7.2-unix.tar.gz
  $ PROVISION_NEO=true vagrant provision
```

<a name="running-tests"/>
##Running Tests
Tests can be run from either the guest or the host, but the meaning of each is slightly different.  Tests will autodetect whether they are running from the guest or the host based on the presence of the `/vagrant` directory.

By default, the Vagrantfile forwards lots of ports for the services puppet is expected to bring up.  During development it can be useful to verify that those services are indeed alive.  To bootstrap the testing-setup on the host:

```shell
  $ virtualenv host_venv
  $ source host_venv/bin/activate
  $ pip install -r tests/requirements.txt
  $ python tests/test_guest.py
```

During normal provisioning, `guest_venv` is setup automatically.  To run tests on the guest from the guest, run this command from the host:

```shell
  $ vagrant ssh -c "/vagrant/guest_venv/bin/python /vagrant/tests/test_guest.py"
```

<a name="running-demos"/>
##Running Demos
During default provisioning, databases, message queues, and visualization aids are setup but there is no data to populate them.  Demos included with toybox are just code examples to create some traffic.  All demos require you to connect to the guest and source the main guest virtual-environment:


```shell
  $ vagrant ssh # connect to guest
  $ source /vagrant/guest_venv/bin/activate # run this from guest
```

To run the **celery/rabbit demo** follows the instructions below.  You can confirm the operations by watching graphs change in real time on your local [flower](http://admin:admin@localhost:5555) and [rabbitmq](http://admin:admin@localhost:15672) servers.

```shell
  # send 1000 and 500 tasks to add and subtract worker, respectively
  $ python /vagrant/demos/demo_celery.py --add -n 1000
  $ python /vagrant/demos/demo_celery.py --add -n 500
  # start a worker to deal with tasks
  $ python /vagrant/demos/demo_celery.py --worker
```

To run the **MongoDB demo** follow the instructions below.  You can confirm the operations by checking [your local genghisapp](http://admin:admin@localhost:5556), specifically the [user collection](http://localhost:5556/servers/localhost/databases/testdb/collections/user).

```shell
  # create 50 fake users
  $ python /vagrant/demos/demo_mongo.py --records 50
```

To run the **Neo4j demo** you must already have done some of the [optional provisioning](#optional-provisioning), and then you can follow the instructions below. If it's not present on the guest in the /vagrant directory, the example movies database will be downloaded and afterwards it will be loaded into your neo server.  After loading a dataset, visit [your local neo server](http://localhost:7474/webadmin/#/data/search/0/).  If you want to start over, you can flush the database by using the `--wipedb` argument to the `demo_neo.py` script.  See the script code for other usage instructions.

```shell
  # load default datset "cieasts_12k_movies_50k"
  $ python /vagrant/demos/demo_neo.py
```
<a name="implementation"/>
##Implementation Remarks
This section documents a few things that might be useful to people forking this recipe.  If you need toybox to execute additional git-clones, create or provision python virtualenvironments, etc, the examples in **[1]** will be useful.  To modify the nginx setup, start in **[2]**.  To execute additional configuration in the very last step of provisioning, see **[3]**.  To change the window-manager or other applications installed in provisioning xwindows, see **[4]**.  For examples of daemonizing random processes, check out the supervisorctl section in **[5]**.  As a place to add default additional system packages, **[6]** is the suggested spot.

1. `puppet/modules/site/manifests/my_code.pp`
2. `puppet/modules/site/files/nginx_conf/sites-enabled/default`
3. `puppet/modules/site/manifests/configuration.pp`
4. `puppet/modules/site/manifests/xwindows.pp`
5. `puppet/modules/core/manifests/toybox.pp`
6. `puppet/modules/core/manifests/basic_dev.pp`

<a name="puppet-idempotency"/>
####Pattern Idempotency
Much effort has gone into making toybox as friendly as possible for low-bandwidth situations.  During repeated calls to `vagrant provision`, every effort has been made to avoid unnecessary duplication of effort for expensive network operations like `apt-get update`, `git clone`, and `pip install`.  However, relevant changes to configuration that involve new packages or changes to template files, etc, should always be honored.  Please file an issue on github if you find problems.

<a name="puppet-layout"/>
####Puppet File Layout
* Entry-point is `puppet/default.pp` (as named in the Vagrantfile)
    * This is probably your starting place for fork-and-mod hacks
* The `puppet` directory has two subdirs, namely `core` and `site`
    * `core` is meant for modules that will not change.
    * `site` is meant for modules that are more idiosyncratic
* Two stages are defined in `default.pp`: 'first' and 'last'.
    * Stages are used to guarantee aspects of the run-order
        * see [puppet language guide](http://docs.puppetlabs.com/guides/language_guide.html) and the section "Run Stages"

<a name="contributing"/>
##Contributing:

Issues can be raised on [the bugtracker](https://github.com/mattvonrocketstein/toybox/issues) and pull requests are always welcome.

<a name="qlinks"/>
##Quick links:
This markdown file is rendered to html and used as the default landing page for the toybox nginx installation.  If you're looking at that page, you might find the following links useful:

* [kopf](http://localhost:9200/_plugin/kopf/#!/cluster)
* [kibana](http://admin:admin@localhost:5557)
* [genghis](http://admin:admin@localhost:5556)
* [flower](http://admin:admin@localhost:5555)
* [rabbitmq](http://admin:admin@localhost:15672)
* [supervisor](http://admin:admin@localhost:9001)
* [nginx](http://admin:admin@localhost:8080)
* [neo](http://admin:admin@localhost:7474)

<a name="todo"/>
##TODO:
* Experimentation with the [AWS provider](https://github.com/mitchellh/vagrant-aws)?
* Optional install for gephi (a graphdb browser)? use [these instructions](https://gist.github.com/dcht00/432caaf3e6c50a2202b8)
* Zookeeper?

<a name="credits"/>
##Credits:
Puppet can sometimes make it pretty difficult it is to reuse other code without forking.  Apart from puppet forge standard libraries included in this repo and amongst other things, I have benefited from the work mentioned below:

* https://github.com/opencredo/neo4j-puppet
* https://github.com/aubricus/vagrant-puppet-boilerplate
* https://forge.puppetlabs.com/proletaryo/supervisor
* https://github.com/netmanagers/puppet-nginx
* https://github.com/nesi/puppet-git
