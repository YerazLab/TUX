import psutil

from misc.module import Module
from misc.i18n import _, _n
from misc.ui import Display
from misc.configuration import Configuration
from misc.theme import theme

class Memory(Module):

    settings = {}

    def __init__(self, settings):
        self.settings = settings

    def run(self):
        """ Affiche l"état de la mémoire """

        Display.header(_("Memory"))

        mem = psutil.virtual_memory()

        Display.barlabel(
            self.get("icon.info",""), 
            "", 
            mem.used, 
            mem.total,
            Configuration.get("graph.width", 50)
        )
        
        Display.bargraph(
            self.get("icon.graph",""), 
            mem.used, 
            mem.total,
            self.get("treshold.warn", 70),
            self.get("treshold.critical", 90),
            Configuration.get("graph.width", 50)
        )
