

/*******************  BEGIN DELETE old records  *******************/
	
	print('/*******************  BEGIN DELETE old records  *******************/')
	delete from tblRMArchive
	delete from tblRMUser
	delete from tblRMReport
	delete from tblRMCriteriaFieldSelection
	delete from tblRMDatasource
	delete from tblRMSubreportSetting
	delete from tblRMSort
	delete from tblRMCriteriaField
	delete from tblRMConfiguration
	delete from tblRMOption
	delete from tblRMFilter
	delete from tblRMFieldSelectionFilter
	delete from tblRMPrintingOption
	delete from tblRMPrintingFilter
	print('/*******************  END DELETE old records  *******************/')

/*******************  END DELETE old records  *******************/
GO