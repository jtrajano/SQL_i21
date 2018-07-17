

/*******************  BEGIN DELETE old records  *******************/
	
	print('/*******************  BEGIN DELETE old records  *******************/')
	delete from tblRMArchive
	delete from tblRMReport
	delete from tblRMCriteriaFieldSelection
	delete from tblRMDatasource
	delete from tblRMSubreportSetting
	delete from tblRMCriteriaField
	delete from tblRMConfiguration
	delete from tblRMDefaultSort
	delete from tblRMDefaultOption
	delete from tblRMDefaultFilter
	delete from tblRMFieldSelectionFilter
	delete from tblRMPrintingOption
	delete from tblRMPrintingFilter
	delete from tblRMSubreportFilter
	delete from tblRMSubreportCondition
	delete tblRMFilter where intUserId = 0
	delete tblRMOption where intUserId = 0
	delete tblRMSort where intUserId = 0
	print('/*******************  END DELETE old records  *******************/')

/*******************  END DELETE old records  *******************/
GO