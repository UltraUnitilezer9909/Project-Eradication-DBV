
#===Alias original Switches/Variables===

class Game_Switches

  alias tdw_persist_get_switch []
  def [](switch_id)
    return checkPersistentSwitch(switch_id) if $data_system.switches[switch_id].include?("[p]")
	return tdw_persist_get_switch(switch_id)
  end
  alias tdw_persist_set_switch []=
  def []=(switch_id, value)
    setPersistentSwitch(switch_id, value) if $data_system.switches[switch_id].include?("[p]")
	tdw_persist_set_switch(switch_id, value)
  end

end

class Game_Variables

  alias tdw_persist_get_variable []
  def [](variable_id)
    return checkPersistentVariable(variable_id) if $data_system.variables[variable_id].include?("[p]")
    return tdw_persist_get_variable(variable_id)
  end

  alias tdw_persist_set_variable []=
  def []=(variable_id, value)
    setPersistentVariable(variable_id, value) if $data_system.variables[variable_id].include?("[p]")
	tdw_persist_set_variable(variable_id, value)
  end

end

#===Persistent Switches===

def getPersistentSwitches
	if safeExists?("Data/PersistentSwitches.rxdata")
		pSwitches = load_data("Data/PersistentSwitches.rxdata")
		return pSwitches
	else
		initSwitches = []
		File.open("Data/PersistentSwitches.rxdata", "wb") { |f| Marshal.dump(initSwitches, f) }
		pSwitches = load_data("Data/PersistentSwitches.rxdata")
		return pSwitches
	end
end

def setPersistentSwitch(id,value)
	switches = getPersistentSwitches
	switches[id]=value
	save_data(switches,"Data/PersistentSwitches.rxdata")
end

def checkPersistentSwitch(id)
	switches = getPersistentSwitches
	setPersistentSwitch(id,false) if switches[id] == nil
	return switches[id]
end

#===Persistent Variables===

def getPersistentVariables
	if safeExists?("Data/PersistentVariables.rxdata")
		pVariables = load_data("Data/PersistentVariables.rxdata")
		return pVariables
	else
		initVariables = []
		File.open("Data/PersistentVariables.rxdata", "wb") { |f| Marshal.dump(initVariables, f) }
		pVariables = load_data("Data/PersistentVariables.rxdata")
		return pVariables
	end
end

def setPersistentVariable(id,value)
	variables = getPersistentVariables
	variables[id]=value
	save_data(variables,"Data/PersistentVariables.rxdata")
end

def checkPersistentVariable(id)
	variables = getPersistentVariables
	setPersistentVariable(id,0) if !variables[id]
	return variables[id]
end