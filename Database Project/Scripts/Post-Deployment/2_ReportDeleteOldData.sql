GO
/*******************  BEGIN DELETE old records  *******************/
	
	print('/*******************  BEGIN DELETE old records  *******************/')
	delete from tblRMCompanyInformations
	delete from tblRMArchives
	delete from tblRMUsers
	delete from tblRMConnections
	delete from tblRMReports
	delete from tblRMCriteriaFieldSelections
	delete from tblRMDatasources
	delete from tblRMSubreportSettings
	delete from tblRMSorts
	delete from tblRMCriteriaFields
	delete from tblRMConfigurations
	delete from tblRMOptions
	delete from tblRMFilters
	delete from tblRMFieldSelectionFilters
	print('/*******************  END DELETE old records  *******************/')

/*******************  END DELETE old records  *******************/
GO