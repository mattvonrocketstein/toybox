"""
"""
import argparse
import sys, random
from celery import Celery, Task

class Config: pass

app = Celery('tasks')
app.config_from_object(Config)


class TracingTask(Task):
    abstract = True

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
