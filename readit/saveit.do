*python set exec ....
program drop _all

sysuse auto, clear
describe
datasignature
loc ds = r(datasignature)

//to_hdf is fairly limited at this time, essentially a single numpy array (so homogeneous type and not our typical Pandas extension type with includes nulls for ints). Can't even get to work with a df of just 2 floats
foreach ext in dta xls xlsx csv pkl json html feather parquet1 parquet2 /*h5*/ {
	preserve
	di "`ext'"

	* Save file
	loc save_opts = ""
	if "`ext'"=="parquet1" {
		loc ext "parquet"
		loc save_options pd_options("engine='fastparquet'")
	}
	if "`ext'"=="parquet2" {
		loc ext "parquet"
		loc save_options pd_options("engine='pyarrow'")
	}
	if "`ext'"=="dta" drop make headroom gear_ratio //to_stata() doesn't support strings or float32 yet
	if "`ext'"=="xls" loc save_opts pd_options("engine='openpyxl'")
	saveit auto.`ext', replace 	`save_opts'

	* Load file
	loc read_opts = ""
	if "`ext'"=="json" loc read_opts rawjson
	readit "'auto.`ext''", clear `read_opts'
	
	* Compare
	qui datasignature
	loc ds2 = r(datasignature)
	if "`ds'"!="`ds2'" {
		di "failed"
		describe
		datasignature
	}
	else {
		di "succeeded"
	}
	
	* Cleanup
	rm "auto.`ext'"
	restore
}
