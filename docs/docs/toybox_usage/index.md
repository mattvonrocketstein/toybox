<a name="usage"></a>
## Quick Start

  **Clone the repository and cd into it**

```shell
  $ git clone https://github.com/mattvonrocketstein/toybox.git
  $ cd toybox
```

  **Bootstrap vagrant with the plugins and basebox toybox uses**

```shell
  $ vagrant box add trusty64 https://cloud-images.ubuntu.com/vagrant/trusty/current/trusty-server-cloudimg-i386-vagrant-disk1.box
  $ vagrant plugin install vagrant-vbguest
  $ vagrant plugin install vagrant-scp
```

  **Bring up the new toybox and provision it**.  This will take a long time while the basebox is bootstrapped and the provisioning downloads package updates.  Also Note that if vbguest detects a mismatched guest-additions iso, it may tke even longer while it corrects this.  *Subsequent calls like the one below will not by default rerun provisioning.*

```shell
  $ vagrant up
```

If the command above happens to terminate with a red message _"The SSH command responded with a non-zero exit status.  Vagrant assumes that this means the command failed"_, it might be caused by some download via apt, gem, or pip which has timed out.  If that's the case, you may want to retry provisioning by executing  `vagrant provision`.

If you don't see the _"non-zero exit status"_ message, then it probably succeeded.  But just to be sure that puppet hasn't missed starting or restarting a service that it's updated, you should run

```shell
  $ vagrant reload
```

**If you got this far, your new box should alreaady be setup and working**.  You can connect to it now with the `vagrant ssh` command or try [running the tests](#running-tests).

**You might want to send over some ssh keys to your fresh new development box.**
  To copy everything except for the local autothorized_keys into your toybox,

```shell
  $ find ~/.ssh -type f|grep -v authorized_keys|xargs -I{} vagrant scp {} /home/vagrant/.ssh/
```

<a name="optional-provisioning-xwin"></a>
##Advanced Usage: Optional Provisioning
The optional items are optional mostly because they are big.  You probably don't want this stuff to slow down your install on a slow connections or headless box.

####Provisioning XWindows

If you wish to use the optional xwindows setup, I strongly suggest installing the vbguest plugin [vbguest plugin](https://github.com/dotless-de/vagrant-vbguest).  (*Note: Unfortunately even then getting full-screen resolution to work may still take some extra fiddling, the situation seems to change slightly with every minor-version release of guest-extensions/virtualbox.)* If you want to change the window manager or other details of this aspect of provisioning, fork this repo and edit `toybox/puppet/modules/site/manifests/xwindows.pp`.  **To enable provisioning for xwindows, run**:

```shell
  $ PROVISION_XWIN=true vagrant provision
```

<a name="optional-provisioning-neo"></a>
####Provisioning Neo

Provisioning neo is similar to provisioning XWindows, but you will need to download their distribution tarball first.  Note: before you start the download, make sure that you're still in the same directory as this README and the Vagrantfile.

```shell
  $ wget http://dist.neo4j.org/neo4j-community-1.7.2-unix.tar.gz
  $ PROVISION_NEO=true vagrant provision
```
