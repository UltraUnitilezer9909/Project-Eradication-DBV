#-------------------------------------------------------------------------------
# Item data.
#-------------------------------------------------------------------------------
module GameData
  class Item
    SCHEMA["PortionName"]       = [:portion_name,        "s"]
    SCHEMA["PortionNamePlural"] = [:portion_name_plural, "s"]
    
    alias portion_initialize initialize
    def initialize(hash)
      portion_initialize(hash)
      @real_portion_name        = hash[:portion_name]
      @real_portion_name_plural = hash[:portion_name_plural]
    end
    
    def portion_name
      return pbGetMessageFromHash(MessageTypes::ItemPortionNames, @real_portion_name) if @real_portion_name
      return name
    end

    def portion_name_plural
      return pbGetMessageFromHash(MessageTypes::ItemPortionNamePlurals, @real_portion_name_plural) if @real_portion_name_plural
      return name_plural
    end
  end
end


#-------------------------------------------------------------------------------
# Compiler.
#-------------------------------------------------------------------------------
module Compiler
  PLUGIN_FILES += ["Improved Item Text"]
end