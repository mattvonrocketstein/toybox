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
