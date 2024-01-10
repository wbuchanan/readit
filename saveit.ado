*! version 1.0.0.
*! Saves files in multiple formats using Python's Pandas functionality.
*! Usage: saveit auto.parquet, replace
program saveit
    syntax anything [, REPlace Type(string) pd_options(string)]

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

    // Test to see if there are any additional options
	if `"`pd_options'"' != "" loc optin ", "
	
    python: pysaveit("`anything'", "`: data label'", "`type'" `optin' `pd_options')
end

python:
import os
from sfi import Characteristic, Data, ValueLabel, Macro, SFIToolkit
import pandas as pd
import numpy as np

types_stata_to_pandas = {'byte':pd.Int8Dtype(), 'int':pd.Int16Dtype(), 'long':pd.Int32Dtype(), 'float':pd.Float32Dtype(), 'double':pd.Float64Dtype()}

def get_stata_metadata(vars : [str], data_label: str = "") -> dict:
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

def pysaveit(path: str, data_label:str = "", filetype: str = "", **kwargs):
    # Load the data into Pandas df    
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

    # Save out to file
    FILE_TYPE = {'.dta': 'stata',
                        '.xls': 'excel',
                        '.xlsx': 'excel',
                        '.csv': 'csv',
                        '.pkl': 'pickle',
                        '.pickle': 'pickle',
                        #'.sas7bdat': 'sas', #not implimented
                        #'.xport': 'sas', #not implimented
                        #'.tab': 'tab', #no specific function (closest is to_csv)
                        #'.tsv': 'tab', #no specific function (closest is to_csv)
                        #'.txt': 'fwf', #no specific function
                        #'.dat': 'fwf', #no specific function
                        '.json': 'json',
                        '.html': 'html',
                        '.feather': 'feather',
                        '.parquet': 'parquet',
                        '.h5': 'hdf',
                        #'.sav': 'spss' # not implimented
                        }
    if filetype!="":
        if filetype not in FILE_TYPE.values():
            raise Exception("Invalid save file type specified: " + filetype)
    else: # autodetect
        file_extension = os.path.splitext(path)[1]
        if file_extension not in FILE_TYPE.keys():
            raise Exception("Unknown save file type inferred from extension (use type to specificy): " + file_extension)
        filetype = FILE_TYPE[file_extension]

    if 'index' not in kwargs.keys() and filetype not in ['stata', 'pickle', 'feather']:
        kwargs['index'] = False    

    if filetype == 'stata':
        dataframe.to_stata(path, **kwargs)
    elif filetype == 'csv':
        dataframe.to_csv(path, **kwargs)
    elif filetype == 'excel':

        dataframe.to_excel(path, **kwargs)
    elif filetype == 'spss':
        dataframe.to_spss(path, **kwargs)
    elif filetype == 'html':
        dataframe.to_html(path, **kwargs)
    elif filetype == 'pickle':
        dataframe.to_pickle(path, **kwargs)
    elif filetype == 'json':
        dataframe.to_json(path, **kwargs)
    elif filetype == 'fwf':
        dataframe.to_fwf(path, **kwargs)
    elif filetype == 'feather':
        dataframe.to_feather(path, **kwargs)
    elif filetype == 'parquet':
        dataframe.to_parquet(path, **kwargs)
    elif filetype == 'hdf':
        if 'key' not in kwargs.keys():
            kwargs['key'] = 'df'
        dataframe.to_hdf(path, **kwargs)

end
