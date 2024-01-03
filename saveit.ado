// For now, just saves files in parquet format. Later make more general
// Usage: saveit auto.parquet, replace

//TODO: Test using both parquet engines
program saveit
    syntax anything [, replace]

    if "`replace'"=="" {
        cap confirm file `anything'
        _assert(_rc!=0), msg("File already exists. You can specify -replace-")
    }
    //There's no way to use the Python API to query char keys, so in Stata store them as locals
    //TODO: Throw warning if variables named _dta or anything
    unab vlist : *
    loc evlist _dta `vlist'
    foreach ev in `evlist' {
        loc `ev' : char `ev'[]
    }

    python: save_parquet("`anything'", ": data label")
end

python:
from sfi import Characteristic, Data, ValueLabel, Macro, SFIToolkit
import pandas as pd
import numpy as np

types_stata_to_pandas = {'byte':pd.Int8Dtype(), 'int':pd.Int16Dtype(), 'long':pd.Int32Dtype(), 'float':pd.Float32Dtype(), 'double':pd.Float64Dtype()}

def get_stata_metadata(vars : [str], data_label: str = ""):
    var_types = {}
    var_meta = {}
    var_chars = {}
    for var in vars:
        var_type = Data.getVarType(var)
        # If str, just store length
        if Data.isVarTypeStr(var):
            var_type = int(var_type[3:])
        var_types[var] = var_type
        
        var_meta[var] = (Data.getVarLabel(var), Data.getVarFormat(var), ValueLabel.getVarValueLabel(var))
        
        var_chars[var] = {name: Characteristic.getVariableChar(var, name) for name in Macro.getLocal(var).split(" ")}

    dta_chars = {name: Characteristic.getDtaChar(name) for name in Macro.getLocal("_dta").split(" ")}
        
    vls = {}
    for name in ValueLabel.getNames():
        vls[name] = ValueLabel.getValueLabels(name) # (getLabels(var_label_name), getValues(var_label_name))

    return {'vls': vls, 'var_types':var_types, 'var_meta':var_meta, 'data_label': data_label, 'dta_chars': dta_chars, 'var_chars': var_chars}

def save_parquet(path: str, data_label:str = "", **kwargs):
    
    dataraw = Data.getAsDict(missingval=np.nan)
    # TODO: ensure same order when using dict
    vars = dataraw.keys()
    stata_metadata = get_stata_metadata(vars, data_label)
    
    # ensure Stata integer types are mapped to pd nullable types, rather than float, and ensure float/double correct conversion
    for var in vars:
        v_type = stata_metadata['var_types'][var]
        if Data.isVarTypeStr(var):
            dataraw[var] = pd.array(dataraw[var], dtype=pd.StringDtype()) 
        else:
            dataraw[var] = pd.array(dataraw[var], dtype=types_stata_to_pandas[v_type])

    
    
    dataframe = pd.DataFrame(dataraw)
    dataframe.attrs = {'stata_metadata': stata_metadata} # since 2.1 https://github.com/pandas-dev/pandas/issues/54321

    dataframe.to_parquet(path, **kwargs)

end
