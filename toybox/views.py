""" toybox.views
"""
import demjson
from collections import OrderedDict

from corkscrew.views import View
from corkscrew.views import JSONEdit
from corkscrew.comet import SijaxDemo
from corkscrew.views.meta import SettingsView
from corkscrew.views.nav import Nav, MakeMenu
from corkscrew.proxy import RedirectsFromSettings#, ProxyFromSettings

class MyMenu(MakeMenu):
    pass

class Home(View):
    url = '/'
    template = 'toybox_home.html'
    #@View.use_local_template
    def main(self):
        """
        """
        return self.render(
            demos = OrderedDict(
                [ ['/comet?start=1','comet demo (via sijax)'],
                  ['/json_editor','a simple json editor'],
                  ['/redirect', ('example redirect (define as '
                                 'many as you want in the .ini)')],
                  ['/__views__' , 'shows views in this runtime'],
                  ["/_make_menu?menu=[['menu-header',[['menu-item','/']]]]" ,
                   'a parametric menu-maker, suitable for loading with ajax'],
                  ['/__settings__' , 'settings in this runtime'],
                  ]),
            app_metadata=dict(
                static_folder=self.app.static_folder,
                jinja_env_globals=self.app.jinja_env.globals.keys(),
                rootpath=self.app.root_path))


class DemoPage(View):
    url = '/demo_page'
    @View.use_local_template
    def main(self):
        """
        simple demo page.<br/><br/><hr/>
        this template is embedded in the view code<br/>
        for simplicity, but of course you can have
        external templates as well.
        """
        return dict()


class DemoJSONEdit(JSONEdit):
    def get_json(self):
        return demjson.encode(
            dict(string= "foo",
                 number= 5,
                 array= [1, 2, 3],
                 object= dict(
                     property="value",
                     subobj = dict(
                         arr=["foo", "ha"],
                         numero= 1))))
from corkscrew.admin import AdminView

class ToyboxAdminView(AdminView):
    url = '/'
    requires_auth = False
    def main(self):
        return self.render_template(
            env='?', page_title='toybox')


__views__ = [
    #Home, Nav,
    #DemoPage,
    #DemoJSONEdit,
    #SijaxDemo,
    #RedirectsFromSettings,
    #MakeMenu,
    ToyboxAdminView
    #type('DemoSettingsView', (SettingsView,), dict(requires_auth=False)),
    ]