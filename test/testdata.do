// Load the system auto data set
sysuse auto.dta, clear

// Add a variable to use as a file placeholder to the dataset
g src = ""

// Add a variable label
la var src "Source Filename"

// Add alternate source file name
g src2 = ""

// Add a variable label
la var src2 "Source Filename"

// Add a variable to use for the dataset type
g datatype = ""

// Add a variable label
la var datatype "Type of Data File"

// Specify csv options for csv exports
loc csvexport nolab quote replace

// Create a variable with the observation number in it
qui: g byte id = _n

// Label the variable
la var id "Observation index"

// Create the name for the example file
loc fstub "/Users/billy/Desktop/Programs/StataPrograms/r/readit/test/auto"

// Replace the file name variable
qui: replace src = `"`fstub'_"' + strofreal(id) + ".csv"

// Replace the dataset type 
qui: replace datatype = `"`j'"'

// Loop over the observations
forv i = 1(2)74 {
	
	// Gets the name for this observation's file
	loc thisfile = src[`i']
		
	// Export the specified file as CSV format (will convert using StatTransfer)
	export delimited using `"`thisfile'"' in `i'/`= `i' + 1', `csvexport' delim(",")
	
} // End Loop over observations

// Replace the source name
qui: replace src = `"`fstub'_"' + strofreal(id) + ".tsv"

// Replace the dataset type
qui: replace datatype = "tsv"

// Loop over the observations
forv i = 1(2)74 {
	
	// Gets the name for this observation's file
	loc thisfile = src[`i']
		
	// Export the specified file as tab delimited format
	export delimited using `"`thisfile'"' in `i'/`= `i' + 1', `csvexport' delim(tab)
	
} // End Loop over observations


// Loop over formats for files
foreach j in sas7bdat sav feather {
	
	if `"`j'"' == "sas7bdat" loc dtype "SAS"
	else if `"`j'"' == "sav" loc dtype "SPSS"
	else loc dtype "ApacheArrow"
	
	// Replace the file name variable
	qui: replace src = `"`fstub'_"' + strofreal(id) + ".`j'"
	
	// Make a stata specific file name without including the extension for 
	// the new format
	qui: replace src2 = `"`fstub'_"' + strofreal(id) + "_`dtype'.dta"
	
	// Replace the dataset type 
	qui: replace datatype = `"`j'"'
	
	// Loop over the observations
	forv i = 1(2)74 {

		// Preserves data in original state
		preserve
	
		// Gets the name for this observation's file
		loc thisfile = src2[`i']
		
		// Only retain this observation
		keep in `i'/`= `i' + 1'
			
		// Export the specified file as CSV format (will convert using StatTransfer)
		qui: save `"`thisfile'"', replace
		
		// Restores data set to original state
		restore
		
	} // End Loop over observations
	
} // End Loop over the file types

// Replace the source name for Stata files
qui: replace src = `"`fstub'_"' + strofreal(id) + ".dta"

// Replace the dataset type
qui: replace datatype = "stata"

// Preserve the data set
preserve

// Loop over the observations
forv i = 1(2)74 {
	
	// Gets the name for this observation's file
	loc thisfile = src[`i']
	
	// Keep just this record
	keep in `i'/`= `i' + 1'
			
	// Export the specified file as tab delimited format
	qui: save `"`thisfile'"', replace
	
	// Restore and preserve the data again
	restore, preserve
	
} // End Loop over observations


// Replace the source name
qui: replace src = `"`fstub'_"' + strofreal(id) + ".xlsx"

// Replace the dataset type
qui: replace datatype = "excel"

// Loop over the observations
forv i = 1(2)74 {
	
	// Gets the name for this observation's file
	loc thisfile = src[`i']
		
	// Export the specified file as tab delimited format
	export excel using `"`thisfile'"' in `i'/`= `i' + 1', first(var) nolabel replace
	
} // End Loop over observations

