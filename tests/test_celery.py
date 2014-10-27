"""
http://stackoverflow.com/questions/6234586/we-need-to-pickle-any-sort-of-callable
http://stackoverflow.com/questions/14129568/django-celery-dynamically-create-and-register-a-task
"""
import sys, random
from celery import Celery, Task

class Config: pass

app = Celery('tasks')
app.config_from_object(Config)

class CortexTask(Task):
    abstract = True

    def after_return(self, *args, **kwargs):
        print 'Task returned: {0!r}'.format(self.request)

    def __call__(self, *args, **kargs):
        msg = 'Executing task id {0.id}, args: {0.args!r} kwargs: {0.kwargs!r}'
        print msg.format(self.request)
        return super(CortexTask, self).__call__(*args, **kargs)

    @classmethod
    def create_from(kls, fxn):
        return app.task(bind=True, base=CortexTask)(fxn)

class Add(CortexTask):
    def run(self, x, y):
        return x+y

#@CortexTask.create_from
#def add(self, x, y):
#    return x + y

@CortexTask.create_from
def sub(self, x, y):
    return x - y

if __name__ == '__main__':
    if '-a' in sys.argv:
        fxn = Add()
    if '-s' in sys.argv:
        fxn = sub
    if '-a' in sys.argv or \
       '-s' in sys.argv:
        print 'running'
        for x in range(100):
            x,y = random.choice(range(100)),\
                  random.choice(range(100)),
            fxn.delay(x,y)
    else:
        app.worker_main()
