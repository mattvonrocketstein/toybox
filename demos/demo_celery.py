#!/usr/bin/env python
""" toybox demo for celery
    Example usage follows:

      # send 100 messages to subtract task
      $ demo_celery.py -n 100 --subtract

      # send 200 messages to add task
      demo_celery.py -n 100 --subtract

      # start the worker which answers add/subtract tasks
      demo_celery.py --worker
"""
import argparse
import sys, random
from celery import Celery, Task
from kombu import Exchange, Queue

class Config:
    default_exchange = Exchange('default', type='direct')
    CELERY_QUEUES = (
        Queue('default', default_exchange, routing_key='default'),
        Queue('demo', default_exchange, routing_key='demo.#'),
        )
    CELERY_DEFAULT_QUEUE = 'default'
    CELERY_DEFAULT_EXCHANGE = 'default'
    CELERY_DEFAULT_ROUTING_KEY = 'default'

app = Celery('demo')
app.config_from_object(Config)



class TracingTask(Task):
    abstract = True
    queue = 'demo'
    def after_return(self, *args, **kwargs):
        print 'Task returned: {0!r}'.format(self.request)

    def __call__(self, *args, **kargs):
        msg = 'Executing task id {0.id}, args: {0.args!r} kwargs: {0.kwargs!r}'
        print msg.format(self.request)
        return super(TracingTask, self).__call__(*args, **kargs)

    @classmethod
    def create_from(kls, fxn):
        return app.task(bind=True, base=TracingTask)(fxn)

class Add(TracingTask):
    """ Add is an example of a class-based task """
    def run(self, x, y):
        return x+y

@TracingTask.create_from
def sub(self, x, y):
    """subtract is an example of a function-based task"""
    return x - y

def build_parser():
    parser = argparse.ArgumentParser(conflict_handler='resolve')
    parser.add_argument('-w', '--worker', action='store_true')
    parser.add_argument('-a', '--add', action='store_true')
    parser.add_argument('-s', '--subtract', action='store_true')
    parser.add_argument('-n', '--messages', type=int, default=100)
    return parser

if __name__ == '__main__':
    parser = build_parser()
    args = parser.parse_args()
    if args.worker:
        sys.argv = [__file__]
        raise SystemExit(app.worker_main())
    else:
        num_messages = int(args.messages)
        if not args.add ^ args.subtract:
            raise SystemExit("expected one of --add and --subtract")
        if args.add:
            fxn = Add()
        if args.subtract:
            fxn = sub
        if args.add or args.subtract:
            print 'running'
            for x in range(num_messages):
                x,y = random.choice(range(100)),\
                      random.choice(range(100)),
                fxn.delay(x,y)
            print 'dispatched {0} messages for task {1}'.format(
                num_messages, fxn)
