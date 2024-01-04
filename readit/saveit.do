*python set exec ....
program drop _all

sysuse auto, clear
describe
datasignature
saveit auto.parquet, replace

readit "'auto.parquet'", clear
describe
datasignature

