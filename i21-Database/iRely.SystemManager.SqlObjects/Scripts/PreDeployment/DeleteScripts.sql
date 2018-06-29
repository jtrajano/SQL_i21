-- CONSOLIDATED DELETE SCRIPTS


PRINT N' BEGIN CONSOLIDATED DELETE PATH: 13.4 to 14.1'
	
	GO
	/*******************  BEGIN DROP 13.4 REPORTS TABLE CONSTRAINTS  *******************/

	PRINT('*******************  BEGIN DROP 13.4 REPORTS TABLE CONSTRAINTS  *******************')
	SELECT * INTO #TEMPConstraints 
	FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS 
	WHERE CONSTRAINT_TYPE = 'FOREIGN KEY'
	AND TABLE_NAME 
	IN ('tblRMArchives'
	,'tblRMCompanyInformations'
	,'tblRMConfigurations'
	,'tblRMConnections'
	,'tblRMCriteriaFields'
	,'tblRMCriteriaFieldSelections'
	,'tblRMDatasources'
	,'tblRMFieldSelectionFilters'
	,'tblRMFilters'
	,'tblRMOptions'
	,'tblRMReports'
	,'tblRMSorts'
	,'tblRMSubreportSettings'
	,'tblRMUsers')
	
	
	DECLARE @tableName NVARCHAR(100)
	DECLARE @constraintName NVARCHAR(100)

	WHILE exists(SELECT TOP 1 1 FROM #TEMPConstraints)
	BEGIN
		SELECT TOP 1 @tableName= TABLE_NAME, @constraintName = CONSTRAINT_NAME FROM #TEMPConstraints
		PRINT('ALTER TABLE ' +  @tableName + ' DROP CONSTRAINT [' + @constraintName + ']')
		EXEC ('ALTER TABLE ' +  @tableName + ' DROP CONSTRAINT [' + @constraintName + ']')
		DELETE FROM #TEMPConstraints WHERE CONSTRAINT_NAME = @constraintName
	END

	DROP TABLE #TEMPConstraints
	
	PRINT('*******************  END DROP 13.4 REPORTS TABLE CONSTRAINTS  *******************')
	
	
	/*******************  END DROP 13.4 REPORTS TABLE CONSTRAINTS  *******************/

	/*******************  BEGIN DROP 13.4 REPORTS TABLE  *******************/

	PRINT('*******************  BEGIN DROP 13.4 REPORTS TABLE  *******************')
	SELECT * INTO #TEMPReportTables 
	FROM INFORMATION_SCHEMA.TABLES 
	WHERE TABLE_NAME 
	IN ('tblRMArchives'
	,'tblRMCompanyInformations'
	,'tblRMConfigurations'
	,'tblRMConnections'
	,'tblRMCriteriaFields'
	,'tblRMCriteriaFieldSelections'
	,'tblRMDatasources'
	,'tblRMFieldSelectionFilters'
	,'tblRMFilters'
	,'tblRMOptions'
	,'tblRMReports'
	,'tblRMSorts'
	,'tblRMSubreportSettings'
	,'tblRMUsers')

	WHILE exists(SELECT TOP 1 1 FROM #TEMPReportTables)
		BEGIN
			SELECT TOP 1 @tableName= TABLE_NAME FROM #TEMPReportTables
			PRINT('DROP TABLE [' + @tableName + ']')
			EXEC ('DROP TABLE [' + @tableName + ']')
			DELETE FROM #TEMPReportTables WHERE TABLE_NAME = @tableName
		END
	
	DROP TABLE #TEMPReportTables
	
	PRINT('*******************  END DROP 13.4 REPORTS TABLE  *******************')
	/*******************  END DROP 13.4 REPORTS TABLE  *******************/

	/*******************  BEGIN DROP 13.4 VIEWS  *******************/
	PRINT('*******************  BEGIN DROP 13.4 VIEWS  *******************')
	SELECT * INTO #TEMPViews 
	FROM INFORMATION_SCHEMA.VIEWS 
	WHERE TABLE_NAME 
	IN('vwapivcmst'
	,'vwcoctlmst'
	,'vyu_GLAccountView'
	,'vyu_GLDetailView')
	
	DECLARE @viewName NVARCHAR(100)
	
	WHILE exists(SELECT TOP 1 1 FROM #TEMPViews)
	BEGIN
		SELECT TOP 1 @viewName= TABLE_NAME FROM #TEMPViews
		PRINT('DROP VIEW [' + @viewName + ']')
		EXEC ('DROP VIEW [' + @viewName + ']')
		DELETE FROM #TEMPViews WHERE TABLE_NAME = @viewName
	END

	DROP TABLE #TEMPViews

	PRINT('*******************  END DROP 13.4 VIEWS  *******************')
	/*******************  END DROP 13.4 VIEWS  *******************/

	/*******************  BEGIN DROP 13.4 PROCEDURES  *******************/
	PRINT('*******************  BEGIN DROP 13.4 PROCEDURES  *******************')
	
	SELECT * INTO #TEMPProcedures 
	FROM INFORMATION_SCHEMA.ROUTINES 
	WHERE ROUTINE_TYPE = 'PROCEDURE' 
	AND ROUTINE_NAME 
	IN ('usp_BuildGLAccount'
	,'usp_BuildGLAccountTemporary'
	,'usp_RMInsertDynamicParameterFields'
	,'usp_SyncAccounts'
	,'usp_BuildGLTempCOASegment')
	
	DECLARE @procedureName NVARCHAR(100)
	
	WHILE exists(SELECT TOP 1 1 FROM #TEMPProcedures)
	BEGIN
		SELECT TOP 1 @procedureName= ROUTINE_NAME FROM #TEMPProcedures
		PRINT('DROP PROCEDURE [' + @procedureName + ']')
		EXEC ('DROP PROCEDURE [' + @procedureName + ']')
		DELETE FROM #TEMPProcedures WHERE ROUTINE_NAME = @procedureName
	END

	DROP TABLE #TEMPProcedures

	PRINT('*******************  END DROP 13.4 PROCEDURES  *******************')
	/*******************  END DROP 13.4 PROCEDURES  *******************/
	GO

PRINT N' END CONSOLIDATED DELETE PATH: 13.4 to 14.1'