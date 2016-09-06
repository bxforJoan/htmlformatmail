import ConfigParser,sys

class ConfigUtil:
    def __init__(self,std_cfg_file):
        self.std_cfg_file=std_cfg_file
        self.cf=ConfigParser.ConfigParser()
        self.cf.optionxform=str
        self.cf.read(std_cfg_file)

    def get_prop_file_name(self):
        print self.cf.sections()
        return self.cf.sections()

    def get_keys_by_prop_file(self,prop_file):
        try:
           print self.cf.options(prop_file)
           return self.cf.options(prop_file)
        except NoOptionError:
           return ""
   
    def get_value_by_key_and_section(self,section,option):
        try:
           res=self.cf.get(section,option)
           print res
           return res
        except:
           return ""
   
    def get_wrong_item_by_proj_and_env(self,proj,env):
        try:
           res=""
           result=self.cf.items(proj+"."+env)
           dres=dict(result)
           for k in sorted(dres.keys()):
               res+=str(dres.get(k)[1:])+"<br>"
           print res
           return res
        except:
           return ""
