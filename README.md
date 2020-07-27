# READIT
--------

`readit` is a Python enabled Stata package to read and append multiple files quickly and easily.  


## Usage

Read and combine an arbitrary number of SPSS files in a directory and clear any existing data from memory:

```
readit "'test/*.sav'", c
```

Read all files of any format that start with auto clear existing data from memory and rename some of the variables once the underlying files are combined:

```
readit "'test/auto*'", ren('gear_ratio': 'gratio') c
```

Read all MS Excel, Feather, and SPSS files in the test directory, clear existing data from memory, rename some variables, and pass arguments to the underlying pandas methods:

```
readit "'test/*.xlsx', 'test/*.feather', 'test/*.sav'", clear ///   
ren('src2' : 'backupsrc', 'gear_ratio' : 'gearRatio', 'datatype': 'filetype') ///   
"sep = ',', na_values = '', convert_categoricals = False"
```


