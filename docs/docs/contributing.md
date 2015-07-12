<a name="implementation"></a>
##Implementation Remarks
This section documents a few things that might be useful to people forking this recipe.  If you need toybox to execute additional git-clones, create or provision python virtualenvironments, etc, the examples in **[1]** will be useful.  To modify the nginx setup, start in **[2]**.  To execute additional configuration in the very last step of provisioning, see **[3]**.  To change the window-manager or other applications installed in provisioning xwindows, see **[4]**.  For examples of daemonizing random processes, check out the supervisorctl section in **[5]**.  As a place to add default additional system packages, **[6]** is the suggested spot.

1. `puppet/modules/site/manifests/my_code.pp`
2. `puppet/modules/site/files/nginx_conf/sites-enabled/default`
3. `puppet/modules/site/manifests/configuration.pp`
4. `puppet/modules/site/manifests/xwindows.pp`
5. `puppet/modules/core/manifests/toybox.pp`
6. `puppet/modules/core/manifests/basic_dev.pp`

<a name="puppet-idempotency"></a>
####Pattern Idempotency
Much effort has gone into making toybox as friendly as possible for low-bandwidth situations.  During repeated calls to `vagrant provision`, every effort has been made to avoid unnecessary duplication of effort for expensive network operations like `apt-get update`, `git clone`, and `pip install`.  However, relevant changes to configuration that involve new packages or changes to template files, etc, should always be honored.  Please file an issue on github if you find problems.

<a name="puppet-layout"></a>
####Puppet File Layout
* Entry-point is `puppet/default.pp` (as named in the Vagrantfile)
    * This is probably your starting place for fork-and-mod hacks
* The `puppet` directory has two subdirs, namely `core` and `site`
    * `core` is meant for modules that will not change.
    * `site` is meant for modules that are more idiosyncratic
* Two stages are defined in `default.pp`: 'first' and 'last'.
    * Stages are used to guarantee aspects of the run-order
        * see [puppet language guide](http://docs.puppetlabs.com/guides/language_guide.html) and the section "Run Stages"

<a name="contributing"></a>
##Contributing:

Issues can be raised on [the bugtracker](https://github.com/mattvonrocketstein/toybox/issues) and pull requests are always welcome.

<a name="todo"></a>
##TODO:
* Experimentation with the [AWS provider](https://github.com/mitchellh/vagrant-aws)?
* optional install for gephi (a graphdb browser)? use [these instructions](https://gist.github.com/dcht00/432caaf3e6c50a2202b8)
* elasticsearch?
* zookeeper?

<a name="credits"></a>
##Credits:
Puppet can sometimes make it pretty difficult it is to reuse other code without forking.  Apart from puppet forge standard libraries included in this repo and amongst other things, I have benefited from the work mentioned below:

* https://github.com/opencredo/neo4j-puppet
* https://github.com/aubricus/vagrant-puppet-boilerplate
* https://forge.puppetlabs.com/proletaryo/supervisor
* https://github.com/netmanagers/puppet-nginx
* https://github.com/nesi/puppet-git
