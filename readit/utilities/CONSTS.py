# Maps file extensions to format types
FILE_TYPE = {'.dta': 'stata',
             '.xls': 'excel',
             '.xlsx': 'excel',
             '.csv': 'csv',
             '.pickle': 'pickle',
             '.pkl': 'pickle',
             '.sas7bdat': 'sas',
             '.xport': 'sas',
             '.tsv': 'tab',
             '.dat': 'fwf',
             '.json': 'json',
             '.html': 'html',
             '.feather': 'feather',
             '.parquet': 'parquet',
             '.h5': 'hdf',
             '.sav': 'spss',
             '.txt': 'fwf'
             }

# Mappings from Pandas data types to simplified data types
DTYPE_MAP = {'object': 'string',
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
DTYPE_VALUES = {'object': -1,
                'string_': -1,
                'unicode_': -1,
                'int8': 1,
                'int16': 2,
                'int32': 3,
                'int64': 5,
                'float32': 4,
                'float64': 5,
                'Int8': 1,
                'Int16': 2,
                'Int32': 3,
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

# Mappings to translate from numeric values back to string types
VALUE_DTYPES = {
    -1: 'string',
    0: 'categorical',
    1: 'int8',
    2: 'int16',
    3: 'int32',
    4: 'float32',
    5: 'float64'
}


