// Drops program from memory if already loaded
cap prog drop readit

// Defines the Stata program for readit
prog def readit

	// Defines the syntax structure of the command
	syntax anything(name=root) [, Types(string asis) REName(string asis)	 ///
								  noDETect noRECursive RAWJson SAVe(string)	 ///   
								  REPlace Clear * ]
								  
	// Check to see if the user passed the clear option
	if `"`clear'"' != "" clear
	
	// Checks the auto type detection parameter
	if `"`detect'"' != "" loc detect ", auto_detect = False"
	else loc detect ", auto_detect = True"
	
	// Checks the parameter for recursive search of files
	if `"`recursive'"' != "" loc recursive ", recursive = False"
	else loc recursive ", recursive = True"
	
	// Checks the parameter for reading raw json 
	if `"`rawjson'"' != "" loc rawjson ", raw_json = True"
	else loc rawjson ", raw_json = False"
	
	// If values are passed to the rename parameter format them as a dict object
	if `"`rename'"' != "" loc rename `", rename = { `rename' }"'
	
	// If values are passed to the types parameter format them as a list object
	if `"`types'"' != "" loc types `", types = [ `types' ]"'
    
    // Removes sticky quotation marks from the file/directory paths
    loc root = subinstr(`root', char(34), "", .)
	
	// Structure the root argument as a list in case users want to search 
	// multiple directories
	loc root "root = [ `root' ]"
	
	// Test to see if there are any additional options
	if `"`options'"' != "" loc optin ", "
	
	// Remove first character from options macro.
	// This is likely a bug that should be reported to Stata since the options 
	// macro shouldn't be returning a leading quotation mark.
	loc options = subinstr(`"`options'"', char(34), "", 1)

	// Check to see if data is already in memory
	qui: count
	
	// If there are data already loaded in memory
	if `r(N)' > 0 {
	
		// Print a message to the console and ask the user if they would like to
		// clear the data from memory
		di as err "Data already loaded in memory." _n as res "Clear it? (y/n)" _request(_clearit)
		
		// Check the response and print error message if needed
		if `"`clearit'"' == "n" exit = 4
			
		// If they want the data cleared, clear it
		else clear
	
	} // End IF Block when data are already loaded
	
	// Initialize Python object and load data into Stata
	python: x = ReadIt(`root' `types' `rename' `detect' `recursive' `rawjson' `optin' `options')
	
	// Check to see if save parameter was passed 
	if `"`save'"' != "" qui: save `"`save'"', `replace'
	
// End program definition
end
	
// Define required Stata version for Python code below
version 16.1	
	
// Start Python interpreter
python:
import sfi
import glob
import pandas as pd
import numpy as np
from os import path
import json
import itertools
import platform
import inspect
from pandas import read_stata, \
    read_csv, \
    read_excel, \
    read_spss, \
    read_sas, \
    read_html, read_pickle, \
    read_table, \
    read_json, \
    read_fwf, \
    read_feather, \
    read_parquet, \
    read_hdf
try:
    from pandas.io.json import json_normalize  # old location
except:
    from pandas import json_normalize


class ReadIt(object):
    """
    Class used to handle reading multiple files across arbitrary formats
    and return a single Stata Data Set.
    """

    def __init__(self, root: [str], types: [str] = None, auto_detect: bool = True, recursive: bool = True,
                 raw_json: bool = False, parallel: bool = False, config: str = None,
                 rename: {} = {}, executable: str = None, **kwargs):
        """
        Initializing function for the Readit class object.
        :param root: The root directory/file to begin looking for files that will be read.
        :param types: An optional list of file types that a user can specify (particularly useful if the file extensions
        are unconventional in any way to ensure the correct parser is used).
        :param auto_detect: Optional argument indicating whether or not the class should attempt to infer the file type
        automatically.
        :param recursive: Indicates whether or not glob should search for the file name string recursively
        :param raw_json: A boolean used to determine which JSON parsing method to use when reading the data.  If True,
        the class will use pandas.read_json() otherwise, a file object is passed to pandas' json_normalize()
        :param kwargs: The optional keyword arguments that can be passed to the constructor are used to trigger behaviors
        of the pandas data parsers.  Passing keyword arguments here can be useful if you only want to retain a subset of
        the data from the files and the columns you wish to keep/exclude exist in all of the files.
        """
        # Sets the raw_json value used to determine whether to use
        # pd.read_json or json_normalize
        self.raw_json = raw_json

        # Tests whether or not the OS is Windows
        self.is_windows = platform.system() == 'Windows'

        # Needed if Windows OS and wanting to use multithreaded reading
        self.executable = executable

        self.MISSINGS = {
            'string' : '',
            'byte': 127,
            'int': 32767,
            'long': np.nan,
            'float': 17122118120704448E22,
            'double': 9045521364627034E292,
            'labeled': 2147483647,
            'object': ''
        }

        # Defines the list of all of the pandas IO functions used
        self.PANDAS_IO = [ read_stata, read_csv, read_excel, read_spss,
        read_sas, read_html, read_pickle, read_table, read_json, read_fwf,
        read_feather, read_parquet, read_hdf, json_normalize ]

        # Define type mappings for file extensions
        self.FILE_TYPE = {'.dta': 'stata',
                          '.xls': 'excel',
                          '.xlsx': 'excel',
                          '.csv': 'csv',
                          '.pkl': 'pickle',
                          '.pickle': 'pickle',
                          '.sas7bdat': 'sas',
                          '.xport': 'sas',
                          '.tab': 'tab',
                          '.tsv': 'tab',
                          '.txt': 'fwf',
                          '.dat': 'fwf',
                          '.json': 'json',
                          '.html': 'html',
                          '.feather': 'feather',
                          '.parquet': 'parquet',
                          '.h5': 'hdf',
                          '.sav': 'spss'
                          }

        # Defines a dict that can be used to make it easier to map the pandas
        # types to strings that are a bit more meaningful
        self.DTYPE_MAP = {'object': 'string',
                          'string_': 'string',
                          'unicode_': 'string',
                          'int8': 'byte',
                          'int16': 'int',
                          'int32': 'long',
                          'int64': 'double',
                          'float32': 'float',
                          'float64': 'double',
                          'Int8': 'byte',
                          'Int16': 'int',
                          'Int32': 'long',
                          'Int64': 'double',
                          'Float32': 'float',
                          'Float64': 'double',
                          'Category': 'labeled',
                          'String': 'string',
                          'Unicode': 'string',
                          'string': 'string',
                          'unicode': 'string',
                          'categorical': 'labeled',
                          'Categorical': 'labeled'
                          }

        # Creates numeric mappings for types to allow for testing the highest cast value
        self.DTYPE_VALUES = {'object': -1,
                          'string_': -1,
                          'unicode_': -1,
                          'int8': 1,
                          'int16': 2,
                          'int32': 3,
                          'int64': 5,
                          'float32': 4,
                          'float64': 5,
                          'Int8': 1.1,
                          'Int16': 2.1,
                          'Int32': 3.1,
                          'Int64': 5,
                          'Float32': 4,
                          'Float64': 5,
                          'Category': 0,
                          'String': -1,
                          'Unicode': -1,
                          'string': -1,
                          'unicode': -1,
                          'categorical': 0,
                          'Categorical': 0
                          }

        # Creates text mappings for numeric type maps
        self.VALUE_DTYPES = {
            -1 : 'string',
            0 : 'categorical',
            1 : 'int8',
            1.1: 'Int8',
            2 : 'int16',
            2.1 : 'Int16',
            3 : 'int32',
            3.1 : 'int32',
            4 : 'float32',
            5 : 'float64'
        }

        # Initialize empty dictionary to store the file/type KV pairs
        self.file_types = {}

        # Create the dictionary with the signatures for the IO methods
        self.iosigs = self._get_signatures()

        # If config file is present
        if config is not None:
            # Call function to load configuration file
            self.config = self._load_config(config)

        # Get the file names that should be passed to the initializer
        self.files = self._get_paths(root=root, recursive=recursive)

        # If auto_detect
        if auto_detect:

            # This will attempt to infer the file types based on the file
            # extensions that are located.
            for file, ext in self._get_extensions(self.files):
                self.file_types[file + ext] = self._get_file_type(ext)

        # If auto_detect is disabled the user should submit a list of file
        # type strings (or a single file type string) and will create the
        # file type map appropriately
        else:

            # If the number of files and file types are the same
            if len(self.files) == len([types]):

                # Create the dictionary of filename : type using the input
                for file, file_type in zip(self.files, [types]):
                    self.file_types[file] = file_type

                    # If a single type is passed to the constructor
            elif len([types]) == 1:

                # Broadcast the scalar type value to have the same dimension
                # as the number of files
                thetypes = list(itertools.repeat(types, len(self.files)))

                # Populate the dictionary of filename : type values using
                # the broadcasted list of the single file type and file names
                for file, file_type in zip(self.files, thetypes):
                    self.file_types[file] = file_type

                    
        # Reads the data into the member variable data
        self.data = [self._read_file(filenm=file, filetype=ext, **kwargs)
                     for file, ext in self.file_types.items()]

        # Stores the modal types from the first pass
        self.modal_types = self._get_modal_types(self.data)

        # Reduces the list of pd.DataFrame objects into a single pd.DataFrame
        self.smash_data(self.data, rename)

        # Loads the data into Stata's memory
        self.load_data()

    def _load_config(self, conf: str) -> [{}]:
        """
        Defines a function that will be used to read a JSON file with configuration settings that can be used as an
        alternative method for the interface
        :param conf: This is a string to the configuration file which should be a list of JSON objects corresponding to
        the files and pandas arguments to pass to the parsers.
        :return: A list of Python dictionaries that will be used to dispatch the methods to consume the data sets
        """
        config = json.load(conf)
        configout = []
        for fileconf in config:
            fileconf['filetype'] = self._process_config(fileconf)
            configout.append(fileconf)

        return configout

    def _get_signatures(self) -> {}:
        """
        Helper method used to identify the valid arguments that can be passed
        to any of the pandas IO functions used by the program
        :return: Returns a dictionary containing the available arguments for each pandas IO method
        """
        # Creates an empty dictionary to collect the function names and signatures
        sigreturn = {}
        # Loops over the functions that are used for IO operations
        for io in self.PANDAS_IO:
            # Gets the name of the function in question
            funcname = io.__name__
            # Gets the list of arguments that the function can take
            args = list(inspect.signature(io).parameters.keys())
            # Adds the arguments to the dictionary with the function name as the key
            sigreturn[funcname] = args
        # Returns the dictionary object
        return sigreturn

    def _process_config(self, confobject: {}) -> str:
        """
        Internal method used to process individual configuration objects to add a file type
        :param confobject: A Python dictionary representing the configuration settings for a given file
        :return: The same dictionary object with the file extension/file type added as an attribute
        """
        file, ext = self._get_extensions([confobject.get('filenm')])
        return self._get_file_type(ext)

    @staticmethod
    def _get_paths(root: str, recursive: bool = True) -> [str]:
        """
        Defines a function used to retrieve all of the file paths matching a
        directory string expression.
        :param root: The root directory/file to begin looking for files that will be read.
        :param recursive: Indicates whether or not glob should search for the file name string recursively
        :return: Returns a list of strings containing fully specified file paths that will be consumed and combined.
        """
        # Test the type of the root parameter
        if isinstance(root, list):
            # Create an empty container in which to accumulate the results
            files = []
            # Iterate over the elements of the list passed
            for filenm in root:
                # Iterate over the file paths identified from the glob method
                for i in glob.glob(filenm, recursive = recursive):
                    # Append the individual file path to the global container
                    files.append(i)
            # Return the container created at the start of this condition        
            return files
        elif isinstance(root, str):
            return glob.glob(root, recursive=recursive)
        else:
            return []

    @staticmethod
    def _get_extensions(paths: [str]) -> [(str, str)]:
        """
        Gets the file extensions for all of the files in the file list and
        returns this in a list of tuples like (fileName, Extension).
        :param paths: A list of strings containing file paths that will be read
        :return: A list of tuples where the first value is the file name and the second value is the extension.
        """
        if isinstance(paths, list):
            return [path.splitext(file) for file in paths]
        else:
            return [path.splitext(paths)]

    def _get_file_type(self, ext: str) -> str:
        """
        This function maps a file extension to a file type indicator that will
        be used to identify the appropriate API to use to read the data.
        :param ext: A string containing the file name
        :return: Returns a user-friendly file type name based on the FILE_TYPE dictionary
        """
        return self.FILE_TYPE.get(ext, 'Unknown')

    def _get_modal_types(self, dfs) -> {}:
        """
        Method to return the modal dtype across columns of the data frames
        :return: A dictionary containing the modal type for each column
        """
        # Iterate over the datasets read in to memory, combines them, and gets the modal dtype
        # for each variable, and shifts the index into a column
        type_container = pd.concat([ i.dtypes.apply(lambda x : x.name) for i in dfs if i is not None ], axis = 1, ignore_index= False, sort = True)

        # Gets the modal types from the DataFrame of Types
        mode_types_container = type_container.mode(axis = 1).dropna(axis = 1, how = 'any')

        # Name the column from the container that will get updated
        mode_types_container.columns = [ 'type' ]

        # Gets the max value of the numeric mappings of the types across all files
        max_types_container = pd.DataFrame({ 'type' : type_container.replace(self.DTYPE_VALUES, inplace = False).max(axis = 1) })

        # Updates the modal types with the the max type if they are different
        mode_types_container.update(max_types_container.replace(self.VALUE_DTYPES, inplace = False))

        # Return the dictionary containing the modal data types
        return mode_types_container.to_dict()['type']

    def _read_file(self, filenm: str, filetype: str, **kwargs: {}) -> pd.DataFrame:
        """
        An internal function that dispatches the appropriate pandas io method to read the file into memory and return a pandas DataFrame object.
        :param file: The file to read into memory
        :param filetype: The type of file that will be read.  Note: This parameter is used to determine which Pandas method to dispatch in order to parse the file correctly.
        :param kwargs: Optional arguments that can be passed to the individual file parsers.  Enabled now to allow future development of a configuration file where parameters can be specified distinctly for each file.
        :return: Returns a Pandas DataFrame object.
        """
        if filetype == 'stata':
            args = self._valid_args(kwargs, 'read_stata')
            return pd.read_stata(filenm, **args).convert_dtypes()
        elif filetype == 'csv':
            args = self._valid_args(kwargs, 'read_csv')
            return pd.read_csv(filenm, **args).convert_dtypes()
        elif filetype == 'excel':
            args = self._valid_args(kwargs, 'read_excel')
            return pd.read_excel(filenm, **args).convert_dtypes()
        elif filetype == 'spss':
            args = self._valid_args(kwargs, 'read_spss')
            return pd.read_spss(filenm, **args).convert_dtypes()
        elif filetype == 'sas':
            args = self._valid_args(kwargs, 'read_sas')
            return pd.read_sas(filenm, **args).convert_dtypes()
        elif filetype == 'html':
            args = self._valid_args(kwargs, 'read_html')
            return pd.read_html(filenm, **args)[0].convert_dtypes()
        elif filetype == 'pickle':
            args = self._valid_args(kwargs, 'read_pickle')
            return pd.read_pickle(filenm, **args).convert_dtypes()
        elif filetype == 'tab':
            args = self._valid_args(kwargs, 'read_table')
            return pd.read_table(filenm, **args).convert_dtypes()
        elif filetype == 'json':
            if self.raw_json:
                args = self._valid_args(kwargs, 'read_json')
                return pd.read_json(filenm, **args).convert_dtypes()
            else:
                args = self._valid_args(kwargs, 'json_normalize')
                with open(filenm, 'r') as f:
                    return json_normalize(json.load(f.read()), **args).convert_dtypes()
        elif filetype == 'fwf':
            args = self._valid_args(kwargs, 'read_fwf')
            return pd.read_fwf(filenm, **args).convert_dtypes()
        elif filetype == 'feather':
            args = self._valid_args(kwargs, 'read_feather')
            return pd.read_feather(filenm, **args).convert_dtypes()
        elif filetype == 'parquet':
            args = self._valid_args(kwargs, 'read_parquet')
            return pd.read_parquet(filenm, **args).convert_dtypes()
        elif filetype == 'hdf':
            args = self._valid_args(kwargs, 'read_hdf')
            return pd.read_hdf(filenm, **args).convert_dtypes()

    def _valid_args(self, kwargs: {}, iomethod: str) -> dict:
        """
        A method to extract valid keyword arguments being passed to IO operations
        :param kwargs: Keyword arguments that are being passed to IO methods
        :param iomethod: The pandas I/O method to test the signature
        :return: Returns a dictionary of valid arguments for the dictionary
        """
        # Get the list of invalid keyword arguments
        invalid = list(set(kwargs) - set(self.iosigs[iomethod]))

        # Create a copy of the keyword argument dictionary
        args = kwargs.copy()

        # Loop over the list of invalid arguments
        for remove in invalid:
            # Remove this key/value pair from the copy
            del args[remove]

        # Return the copy of the dictionary with the invalid arguments removed
        return args

    def smash_data(self, dfs: [pd.DataFrame], rename: {}):
        """
        This function takes the list of pandas DataFrame objects and appends
        them to each other.  It also sets several internal variables that are
        used to load the data into the active Stata session.
        :param dfs: A list of pandas.DataFrame objects that will be appended to form a single data set.
        """
        # Appends all of the data into a single pd.DataFrame object
        sort = len(dfs) > 1
        self.data = pd.concat(dfs, axis=0, join = 'inner', ignore_index=True, sort=sort)
        # Trying to replace missing values with a similar missing type
        #self.data.fillna(value=np.nan, axis=1, inplace=True)

        # Gets the number of observations and variables from the combined
        # pd.DataFrame object
        self.nrows, self.nvars = self.data.shape

        # Recast the variables to their original types
        self._restore_modal_dtype(self.data.columns)

        # Test whether the rename parameter is empty
        if bool(rename):
            # If values were passed for renaming, apply them prior to clean names.
            self._rename_global(rename)

        # Check to make sure that all variable names are valid Stata varnames
        self._clean_names()

        # Sets a member variable with the variable names
        self.varnames = self.data.columns

        # Sets a member variable with type mappings
        self.var_types, self.miss_map, self.types = self._get_vartypes(self.varnames)

        self._convert_long_longs()

        # Updates the var_type map with information for string variables
        # self._get_string_types(self.var_types)

        # Gets the list of categorical typed variables
        self.cat_vars = [varname for varname, vartype in self.var_types.items() if
                         vartype in ['categorical', 'labeled']]

        # Generates the value label mappings
        self.value_labels = self._get_encodings(self.cat_vars)

        # Replaces categorical values with ints that align with value label
        # mapping
        self._recode_categorical(self.value_labels)

    def _restore_modal_dtype(self, varnames: [str]):
        """
        :param varnames: Takes a list of variable names
        :return:
        """
        # Loop over the variable names
        for i in varnames:
            # Recast the columns to their modal types
            self.data[i] = self.data[i].astype(self.modal_types[i])

    def _convert_long_longs(self):
        """
        A method to update the casting of variables in the dataframe after concatenation.
        Specifically, this method seeks values of type Int64 to recast them as Float64 to
        maintain consistency with Stata's internal types
        :param dtypemap: A Python dict containing a variable name (key) and dtype (value)
        """
        for key, value in self.types.items():
            if value in ['Int64', 'int64']:
                self.data[key] = self.data[key].astype(dtype = 'Float64')

    def _get_vartypes(self, varnames: [str]) -> {str: str}:
        """
        Internal function used to identify var type strings to use to create the
        Stata variables.
        :param varnames: Takes a list of variable names.
        :return: Returns a dictionary where the variable name is the key and the type of the variable
        is the value
        """
        vtypes = {}
        vmiss = {}
        vorig = {}
        for varname in varnames:
            vtype = self.DTYPE_MAP.get(self.data[varname].dtype.name, 'Unknown')
            if vtype in ['str', 'object']:
                vmiss[varname] = self.MISSINGS[vtype]
            vorig[varname] = self.data[varname].dtype.name
            if vtype in ['string', 'object']:
                string_length = self.data[varname].apply(str).map(len).max()
                if string_length < 2045:
                    vtypes[varname] = int(string_length)
                else:
                    vtypes[varname] = 'strL'
            else:
                vtypes[varname] = vtype

        return vtypes, vmiss, vorig

    def _get_string_types(self, vartypes: {str: str}):
        """
        Function to identify the length of the string variable required to store
        these data.  Returns 'strL' if the strL type should be created
        :param vartypes: Takes a dictionary of variable name : type key/value pairs.  If the variable is a string
        value or something that could be a string, it will detect the maximum length of the string.  If the value is
        >= 2,045, it will update the variable type to be a 'strL' type or will update the variable type to contain an
        integer value for the width needed to hold the string.
        """
        for vnm, vtype in vartypes.items():
            if vtype in ['object', 'string', 'unicode', 'string_', 'unicode_']:
                string_length = self.data[vnm].map(len).max()
                if string_length < 2045:
                    self.var_types[vnm] = string_length
                else:
                    self.var_types[vnm] = 'strL'
            else:
                continue

    def _get_encodings(self, varnames: [str]) -> {str: {int: str}}:
        """
        Function to assign arbitrary numeric values to categorical data and
        also create the mapping needed to generate the appropriate value
        labels.
        :param varnames: A list of variable names that should be transformed to have value labels and numeric values
        :return: Returns a dictionary object where the variable names are the keys and the value is a dictionary
        consisting of label : value key/value pairs (the string : int structure is used so the dictionary can be passed
        to subsequent pandas methods to recode the values of that variable)
        """
        # Initialize the list object that will be returned
        value_labels = {}

        # Loop over the variable names that represent categorical variabels
        for varname in varnames:
            # Get the unique values for this variable and numeric mapping
            value_map = {idx: value for idx, value in enumerate(self.data[varname].unique())}

            # Append the value_map to the parent dictionary using the name of
            # the variable for the key
            value_labels[varname] = value_map

        return value_labels

    def make_vars(self, name_and_type: {str: str}):
        """
        Function used to create the Stata variables in memory.
        This assumes that the values in name_and_type object are valid
        Stata variable names.
        :param name_and_type: A dictionary structured to contain the variable names as the keys and the storage type of
        the variable as the value.
        """
        # Loop over the variable name / variable type mappings and add
        # variables with the appropriate typing based on the vartype
        for varname, vartype in name_and_type.items():
            if isinstance(vartype, int):
                sfi.Data.addVarStr(varname, vartype)
            elif vartype == 'strL':
                sfi.Data.addVarStrL(varname)
            elif vartype == 'byte':
                sfi.Data.addVarByte(varname)
            elif vartype == 'int':
                sfi.Data.addVarInt(varname)
            elif vartype in [ 'long', 'labeled' ]:
                sfi.Data.addVarLong(varname)
            elif vartype == 'float':
                sfi.Data.addVarFloat(varname)
            elif vartype == 'double':
                sfi.Data.addVarDouble(varname)

    def _set_obs(self, n_observations: int):
        """
        Small function to handle setting the number of observations in
        Stata to load the data.
        :param n_observations: The number of observations needed to store the data that will be loaded
        """
        sfi.Data.setObsTotal(n_observations)

    def _clean_names(self):
        """
        Function to ensure all of the names of the variables in the DataFrame
        are valid Stata variable names.
        """

        # Creates a mapping from existing column names to names allowed by Stata
        varname_map = {varname: sfi.SFIToolkit.strToName(varname, prefix=False)
                       for varname in self.data.columns}

        # Applies the variable name map to the pd.DataFrame object
        self.data.rename(columns=varname_map)

    def _recode_categorical(self, mapping_list: {}):
        """
        Function to replace the values of the data in the data frame with numeric values
        :param mapping_list: Contains a Dictionary where the keys are the names of the variables that correspond to the
        value labels and the values are Dictionaries that map the string labels (keys) to numeric values (values) that
        are used to recode the string values to integer values.  The same dictionary object is used to generate the
        value labels to associate with the variable to ensure the meaning of the values remains bound to the data.
        """
        for mapping in mapping_list:
            self.data.replace({mapping: mapping_list[mapping]}, inplace=True)

    @staticmethod
    def define_value_labels(mapping_list: {}):
        """
        Function used to define new value labels for use in Stata
        :param mapping_list: Contains a Dictionary where the keys are the names of the variables that correspond to the
        value labels and the values are Dictionaries that map the string labels (keys) to numeric values (values) that
        are used to define the value labels associated with the variable.
        """
        for name in mapping_list.keys():
            sfi.ValueLabel.createLabel(name)
            for label, value in mapping_list[name].items():
                sfi.ValueLabel.setLabelValue(name, value, label)

    def apply_value_labels(self, labelNames: [str]):
        """
        Assumes that the variable names and value label names are the
        same and assigns the variable labels to variables with the same
        names.
        :param labelNames:
        """
        for label_name in labelNames:
            sfi.ValueLabel.setVarValueLabel(label_name, label_name)

    def nice_missing(self) -> []:
        # Fix the string missings
        self.data.fillna(value = self.miss_map, inplace = True)
        
        # For numerical variables, sfi.Data.store() needs the full double maximum value to make an observation missing 
        # even if variable smaller types. So we need to replace after covnerting to list so that we don't change the other values.
        datavals = self.data.values.tolist()
        datavals = [[dataval if not pd.isna(dataval) else sfi.Missing.getValue() for dataval in datarow] for datarow in datavals]
        return datavals

    def _rename_global(self, rename_map: {}):
        """
        A function that handles renaming all of the columns after concatenation.
        :param rename_map: A dictionary of old to new variable names to apply to
        the concatenated data frame object.
        """
        self.data.rename(columns = rename_map, errors = 'ignore', inplace = True)
        

    @staticmethod
    def _set_stata_metadata(stata_metadata : dict):
        #define_value_labels takes it the reverse way as getValueLabels() generates it. Also conver to int.
        vls_reversed =  {name:{value: int(key) for key, value in vldict.items()} for name, vldict in stata_metadata['vls'].items()}
        ReadIt.define_value_labels(mapping_list=vls_reversed)

        if 'var_meta' in stata_metadata:
            for var, (label, format, value_label) in stata_metadata['var_meta'].items():
                sfi.Data.setVarLabel(var, label)
                sfi.Data.setVarFormat(var, format)
                if value_label!="":
                    sfi.ValueLabel.setVarValueLabel(var, value_label)

        if 'data_label' in stata_metadata:
            sfi.SFIToolkit.stata('label data "' + stata_metadata['data_label'] + '"')  #Ugh, no way to use direct Python API
        
        if 'dta_chars' in stata_metadata:
            for name, value  in stata_metadata['dta_chars'].items():
                sfi.Characteristic.setDtaChar(name, value)
                
        if 'var_chars' in stata_metadata:
            for var, chardict in stata_metadata['var_chars'].items():
                for name, value in chardict.items():
                    sfi.Characteristic.setVariableChar(var, name, value)

    def load_data(self):
        """
        Loads the data into memory in Stata and handle the rest of the
        housekeeping to get everything set up.
        """
        self._set_obs(n_observations=self.nrows)
        if 'stata_metadata' in self.data.attrs:
            self.make_vars(name_and_type=self.data.attrs['stata_metadata']['var_types'])
        else:
            self.make_vars(name_and_type=self.var_types)
        ReadIt.define_value_labels(mapping_list=self.value_labels)
        datavals= self.nice_missing()
        sfi.Data.store(var=None, obs=None, val=datavals)
        self.apply_value_labels(labelNames=self.value_labels.keys())
        if 'stata_metadata' in self.data.attrs:
            ReadIt._set_stata_metadata(self.data.attrs['stata_metadata'])

end
	
