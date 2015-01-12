""" toybox.settings
"""
import toybox
from goulash.settings import Settings as BaseSettings
from goulash.settings import SettingsError

class Settings(BaseSettings):

    environ_key  = 'TOYBOX_SETTINGS'
    default_file = 'toybox.ini'

    @classmethod
    def get_parser(kls):
        """ build the default parser """
        parser = super(Settings, kls).get_parser()
        parser.add_option("--neo",  dest="neo",
                          default=False, help="")
        #parser.add_option("--runner",  dest="runner",
        #                  default='', help="dotpath for app server")
        #parser.add_option("--encode", dest='encode',
        #                  default="",
        #                  help="encode password hash using werkzeug")
        return parser

    def shell_namespace(self):
        """ publish the namespace that's available to shell.
            subclasses should not forget to call super()!
        """
        out = super(Settings, self).shell_namespace()
        #out.update(
        #    views = self.get_views())
        return out

    def show_version(self):
        super(Settings, self).show_version()
        from toybox import __version__
        print 'toybox=={0}'.format(__version__)


    def __init__(self, filename=None):
        """ first load the default config so that overrides don't need
            to mention everything.  update default with the config
            specified by the command line optionparser, then
            update that with any other overrides delivered to the parser.
        """
        # this super call
        #   1) parses cli
        #   2) loads setting fil  based on env-vars/class-vars
        #   3) setup the implied `user` section
        super(Settings, self).__init__(filename=filename)

        # a few command line options are allowed to override the .ini
        #if self.options.port:
        #    self.update({'flask.port' : self.options.port})

        # update the implied user section
        #self['user']['encode_password'] = self.options.encode
        #self['user']['runner'] = self.options.runner
        toybox.SETTTINGS = self