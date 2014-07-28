/*
 Pre-Deployment Script Template							
--------------------------------------------------------------------------------------
 This file contains SQL statements that will be executed before the build script.	
 Use SQLCMD syntax to include a file in the pre-deployment script.			
 Example:      :r .\myfile.sql								
 Use SQLCMD syntax to reference a variable in the pre-deployment script.		
 Example:      :setvar TableName MyTable							
               SELECT * FROM [$(TableName)]					
--------------------------------------------------------------------------------------
*/

-- Validate Origin records
-- --coctlmst

GO
	PRINT N'BEGIN CHECK coctlmst'
GO
	SET NOCOUNT ON
GO
	declare @strDBName nvarchar(max), @intCount int
	select @strDBName = db_name()
	select @intCount = count(*) from coctlmst

	select @intCount, @strDBName

	IF (@intCount > 1)
	BEGIN
		declare @strMessage nvarchar(max)
		set @strMessage = @strDBName + ' has multiple records on coctlmst. Cannot continue upgrade.'
		RAISERROR(@strMessage, 16, 1)
	END

GO
	SET NOCOUNT OFF

GO
	PRINT N'END CHECK coctlmst'
GO

-- Delete Objects
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
	,'vwticmst'
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

-- TM
--tblTMClock
IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblTMClock]') AND type in (N'U')) 
BEGIN
    IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'dblAccumulatedWinterClose' AND OBJECT_ID = OBJECT_ID(N'tblTMClock')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'dblAccDDWinterClose' AND OBJECT_ID = OBJECT_ID(N'tblTMClock'))
    BEGIN
        EXEC sp_rename 'tblTMClock.dblAccDDWinterClose', 'dblAccumulatedWinterClose' , 'COLUMN'
    END
     
    IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'dblJanuaryDailyAverage' AND OBJECT_ID = OBJECT_ID(N'tblTMClock')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'dblDailyAverageDD01' AND OBJECT_ID = OBJECT_ID(N'tblTMClock'))
    BEGIN
        EXEC sp_rename 'tblTMClock.dblDailyAverageDD01', 'dblJanuaryDailyAverage' , 'COLUMN'
    END
         
    IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'dblFebruaryDailyAverage' AND OBJECT_ID = OBJECT_ID(N'tblTMClock')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'dblDailyAverageDD02' AND OBJECT_ID = OBJECT_ID(N'tblTMClock'))
    BEGIN
        EXEC sp_rename 'tblTMClock.dblDailyAverageDD02', 'dblFebruaryDailyAverage' , 'COLUMN'
    END
     
    IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'dblMarchDailyAverage' AND OBJECT_ID = OBJECT_ID(N'tblTMClock')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'dblDailyAverageDD03' AND OBJECT_ID = OBJECT_ID(N'tblTMClock'))
    BEGIN
        EXEC sp_rename 'tblTMClock.dblDailyAverageDD03', 'dblMarchDailyAverage' , 'COLUMN'
    END
     
    IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'dblAprilDailyAverage' AND OBJECT_ID = OBJECT_ID(N'tblTMClock')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'dblDailyAverageDD04' AND OBJECT_ID = OBJECT_ID(N'tblTMClock'))
    BEGIN
        EXEC sp_rename 'tblTMClock.dblDailyAverageDD04', 'dblAprilDailyAverage' , 'COLUMN'
    END
     
    IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'dblMayDailyAverage' AND OBJECT_ID = OBJECT_ID(N'tblTMClock')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'dblDailyAverageDD05' AND OBJECT_ID = OBJECT_ID(N'tblTMClock'))
    BEGIN
        EXEC sp_rename 'tblTMClock.dblDailyAverageDD05', 'dblMayDailyAverage' , 'COLUMN'
    END
     
    IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'dblJuneDailyAverage' AND OBJECT_ID = OBJECT_ID(N'tblTMClock')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'dblDailyAverageDD06' AND OBJECT_ID = OBJECT_ID(N'tblTMClock'))
    BEGIN
        EXEC sp_rename 'tblTMClock.dblDailyAverageDD06', 'dblJuneDailyAverage' , 'COLUMN'
    END
     
    IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'dblJulyDailyAverage' AND OBJECT_ID = OBJECT_ID(N'tblTMClock')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'dblDailyAverageDD07' AND OBJECT_ID = OBJECT_ID(N'tblTMClock'))
    BEGIN
        EXEC sp_rename 'tblTMClock.dblDailyAverageDD07', 'dblJulyDailyAverage' , 'COLUMN'
    END
     
    IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'dblAugustDailyAverage' AND OBJECT_ID = OBJECT_ID(N'tblTMClock')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'dblDailyAverageDD08' AND OBJECT_ID = OBJECT_ID(N'tblTMClock'))
    BEGIN
        EXEC sp_rename 'tblTMClock.dblDailyAverageDD08', 'dblAugustDailyAverage' , 'COLUMN'
    END
     
    IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'dblSeptemberDailyAverage' AND OBJECT_ID = OBJECT_ID(N'tblTMClock')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'dblDailyAverageDD09' AND OBJECT_ID = OBJECT_ID(N'tblTMClock'))
    BEGIN
        EXEC sp_rename 'tblTMClock.dblDailyAverageDD09', 'dblSeptemberDailyAverage' , 'COLUMN'
    END
     
    IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'dblOctoberDailyAverage' AND OBJECT_ID = OBJECT_ID(N'tblTMClock')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'dblDailyAverageDD10' AND OBJECT_ID = OBJECT_ID(N'tblTMClock'))
    BEGIN
        EXEC sp_rename 'tblTMClock.dblDailyAverageDD10', 'dblOctoberDailyAverage' , 'COLUMN'
    END
     
    IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'dblNovemberDailyAverage' AND OBJECT_ID = OBJECT_ID(N'tblTMClock')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'dblDailyAverageDD11' AND OBJECT_ID = OBJECT_ID(N'tblTMClock'))
    BEGIN
        EXEC sp_rename 'tblTMClock.dblDailyAverageDD11', 'dblNovemberDailyAverage' , 'COLUMN'
    END
     
    IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'dblDecemberDailyAverage' AND OBJECT_ID = OBJECT_ID(N'tblTMClock')) AND EXISTS (SELECT * FROM sys.columns WHERE NAME  = N'dblDailyAverageDD12' AND OBJECT_ID = OBJECT_ID(N'tblTMClock'))
    BEGIN
        EXEC sp_rename 'tblTMClock.dblDailyAverageDD12', 'dblDecemberDailyAverage' , 'COLUMN'
    END
     
END
GO
 
-- tblTMDegreeDay
IF NOT EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblTMDegreeDayReading]') AND type in (N'U')) AND EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblTMDDReading]') AND type in (N'U'))
BEGIN
    EXEC sp_rename 'tblTMDDReading', 'tblTMDegreeDayReading'
END
GO
IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblTMDegreeDayReading]') AND type in (N'U')) 
BEGIN
    IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intDegreeDayReadingID' AND OBJECT_ID = OBJECT_ID(N'tblTMDegreeDayReading')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intDDReadingID' AND OBJECT_ID = OBJECT_ID(N'tblTMDegreeDayReading'))
    BEGIN
        EXEC sp_rename 'tblTMDegreeDayReading.intDDReadingID', 'intDegreeDayReadingID' , 'COLUMN'
    END
     
    IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intClockLocationID' AND OBJECT_ID = OBJECT_ID(N'tblTMDegreeDayReading')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intDDClockLocationID' AND OBJECT_ID = OBJECT_ID(N'tblTMDegreeDayReading'))
    BEGIN
        EXEC sp_rename 'tblTMDegreeDayReading.intDDClockLocationID', 'intClockLocationID' , 'COLUMN'
    END
     
    IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'dblAccumulatedDegreeDay' AND OBJECT_ID = OBJECT_ID(N'tblTMDegreeDayReading')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'dblAccumulatedDD' AND OBJECT_ID = OBJECT_ID(N'tblTMDegreeDayReading'))
    BEGIN
        EXEC sp_rename 'tblTMDegreeDayReading.dblAccumulatedDD', 'dblAccumulatedDegreeDay' , 'COLUMN'
    END
END
GO
-- tblTMDeliveryHistoryDetail
--ALTER TABLE tblTMDeliveryHistoryDetail  
--ALTER COLUMN dblPercentAfterDelivery NUMERIC(18,6) NOT NULL
-- tblTMDispatch
IF EXISTS (SELECT TOP 1 1 FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_tblTMDispatch_tblTMSite]') AND parent_object_id = OBJECT_ID(N'[dbo].[tblTMDispatch]')) 
BEGIN
    ALTER TABLE [dbo].[tblTMDispatch] 
    DROP CONSTRAINT [FK_tblTMDispatch_tblTMSite]
END
GO
IF NOT EXISTS (SELECT TOP 1 1 FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_tblTMDispatch_tblTMSite1]') AND parent_object_id = OBJECT_ID(N'[dbo].[tblTMDispatch]'))
AND EXISTS(select 1  from INFORMATION_SCHEMA.TABLES where TABLE_NAME = N'tblTMDispatch' and TABLE_TYPE = N'BASE TABLE')
BEGIN
    ALTER TABLE [dbo].[tblTMDispatch] WITH CHECK ADD  CONSTRAINT [FK_tblTMDispatch_tblTMSite1] FOREIGN KEY([intSiteID])
    REFERENCES [dbo].[tblTMSite] ([intSiteID])
END
GO
IF EXISTS (SELECT TOP 1 1 FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_tblTMDispatch_tblTMSite1]') AND parent_object_id = OBJECT_ID(N'[dbo].[tblTMDispatch]'))
BEGIN
    ALTER TABLE [dbo].[tblTMDispatch] CHECK CONSTRAINT [FK_tblTMDispatch_tblTMSite1]
END
GO
-- tblTMEvent
IF EXISTS (SELECT TOP 1 1 FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_tblTMEvent_tblTMDevice]') AND parent_object_id = OBJECT_ID(N'[dbo].[tblTMEvent]')) 
BEGIN
    ALTER TABLE [dbo].[tblTMEvent]
    DROP CONSTRAINT [FK_tblTMEvent_tblTMDevice]
END
GO
 
-- tblTMEventType
IF EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'ysnDefault' AND OBJECT_ID = OBJECT_ID(N'tblTMEventType')) 
BEGIN
    ALTER TABLE [dbo].[tblTMEventType]
    ALTER COLUMN ysnDefault bit NOT NULL
END
GO
 
-- tblTMSite
IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intClockID' AND OBJECT_ID = OBJECT_ID(N'tblTMSite')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intClockLocno' AND OBJECT_ID = OBJECT_ID(N'tblTMSite'))
BEGIN
    EXEC sp_rename 'tblTMSite.intClockLocno', 'intClockID' , 'COLUMN'
END
GO
     
IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'dblDegreeDayBetweenDelivery' AND OBJECT_ID = OBJECT_ID(N'tblTMSite')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'dblDDBetweenDlvry' AND OBJECT_ID = OBJECT_ID(N'tblTMSite'))
BEGIN
    EXEC sp_rename 'tblTMSite.dblDDBetweenDlvry', 'dblDegreeDayBetweenDelivery' , 'COLUMN'
END
GO
     
IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'ysnPrintDeliveryTicket' AND OBJECT_ID = OBJECT_ID(N'tblTMSite')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'ysnPrintDlvryTicket' AND OBJECT_ID = OBJECT_ID(N'tblTMSite'))
BEGIN
    EXEC sp_rename 'tblTMSite.ysnPrintDlvryTicket', 'ysnPrintDeliveryTicket' , 'COLUMN'
END
GO
-- tblTMSyncOutOfRange
IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intSyncOutOfRangeID' AND OBJECT_ID = OBJECT_ID(N'tblTMSyncOutOfRange')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intSyncOutOfRange' AND OBJECT_ID = OBJECT_ID(N'tblTMSyncOutOfRange'))
BEGIN
    EXEC sp_rename 'tblTMSyncOutOfRange.intSyncOutOfRange', 'intSyncOutOfRangeID', 'COLUMN'
END
GO
-- tblTMWork
IF NOT EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblTMWorkOrder]') AND type in (N'U')) AND EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblTMWork]') AND type in (N'U'))
BEGIN
    EXEC sp_rename 'tblTMWork', 'tblTMWorkOrder'
END
GO
IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intWorkStatusTypeID' AND OBJECT_ID = OBJECT_ID(N'tblTMWorkOrder')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intWorkStatusID' AND OBJECT_ID = OBJECT_ID(N'tblTMWorkOrder'))
BEGIN
    EXEC sp_rename 'tblTMWorkOrder.intWorkStatusID', 'intWorkStatusTypeID', 'COLUMN'
END
GO

IF EXISTS(select 1  from INFORMATION_SCHEMA.TABLES where TABLE_NAME = N'tblTMDispatch' and TABLE_TYPE = N'BASE TABLE')
BEGIN
	---Update data in tblTMDispatch
		UPDATE tblTMDispatch
		SET intSiteID = intDispatchID
		WHERE isnull(intSiteID, '') = ''
END
GO

 IF EXISTS(select 1  from INFORMATION_SCHEMA.TABLES where TABLE_NAME = N'tblTMApplianceType' and TABLE_TYPE = N'BASE TABLE')
BEGIN
	---Update data in tblTMApplianceType
	UPDATE tblTMApplianceType
	SET ysnDefault = 0
	WHERE ysnDefault IS NULL 
END
GO

-- BEGIN DROP TRASH VIEWS
    /****** Object:  View [dbo].[vwCSSearch]     ******/
    IF OBJECT_ID(N'dbo.vwCSSearch', N'V') IS NOT NULL
    BEGIN
        DROP VIEW dbo.vwCSSearch
    END
    /****** Object:  View [dbo].[vyu_DeliveryFillReport]     ******/
    -- will be recreated on Reports create views 
    IF OBJECT_ID(N'dbo.vyu_DeliveryFillReport', N'V') IS NOT NULL
    BEGIN
        DROP VIEW dbo.vyu_DeliveryFillReport
    END
--END DROP TRASH VIEWS
GO


GO
	select * into #tmpU from INFORMATION_SCHEMA.TABLE_CONSTRAINTS where CONSTRAINT_TYPE='UNIQUE' and TABLE_NAME like 'tblTM%'
	while exists (select top 1 1 from #tmpU)
	begin
		declare @consName nvarchar(max)
		declare @tableName nvarchar(max)
		declare @command  nvarchar(max)
     
		select top 1 
			@consName = CONSTRAINT_NAME, @tableName = TABLE_NAME
			, @command = 'ALTER TABLE ' + TABLE_NAME + ' DROP CONSTRAINT ' + CONSTRAINT_NAME  
		from
			#tmpU
     
		exec (@command) -- executes the alter
		delete from #tmpU where CONSTRAINT_NAME = @consName and TABLE_NAME = @tableName
	end
	drop table #tmpU
GO

PRINT N'BEGIN Renaming of columns in tblSMSite'
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblTMSite]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intFillMethodId' AND OBJECT_ID = OBJECT_ID(N'tblTMSite')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intFillMethodID' AND OBJECT_ID = OBJECT_ID(N'tblTMSite'))
    BEGIN
        EXEC sp_rename 'tblTMSite.intFillMethodID', 'intFillMethodId' , 'COLUMN'
    END

	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intRouteId' AND OBJECT_ID = OBJECT_ID(N'tblTMSite')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intRouteID' AND OBJECT_ID = OBJECT_ID(N'tblTMSite'))
    BEGIN
        EXEC sp_rename 'tblTMSite.intRouteID', 'intRouteId' , 'COLUMN'
    END

	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'strRouteId' AND OBJECT_ID = OBJECT_ID(N'tblTMSite')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'strRouteID' AND OBJECT_ID = OBJECT_ID(N'tblTMSite'))
    BEGIN
        EXEC sp_rename 'tblTMSite.strRouteID', 'strRouteId' , 'COLUMN'
    END

	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intTankTownshipId' AND OBJECT_ID = OBJECT_ID(N'tblTMSite')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intTankTownshipID' AND OBJECT_ID = OBJECT_ID(N'tblTMSite'))
    BEGIN
        EXEC sp_rename 'tblTMSite.intTankTownshipID', 'intTankTownshipId' , 'COLUMN'
    END

	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intFillGroupId' AND OBJECT_ID = OBJECT_ID(N'tblTMSite')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intFillGroupID' AND OBJECT_ID = OBJECT_ID(N'tblTMSite'))
    BEGIN
        EXEC sp_rename 'tblTMSite.intFillGroupID', 'intFillGroupId' , 'COLUMN'
    END

	/*update null data*/
	IF EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'ysnPrintARBalance' AND OBJECT_ID = OBJECT_ID(N'tblTMSite')) 
    BEGIN
        UPDATE tblTMSite SET ysnPrintARBalance = 0 
		WHERE ysnPrintARBalance IS NULL
    END

	IF EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'ysnPrintDeliveryTicket' AND OBJECT_ID = OBJECT_ID(N'tblTMSite')) 
    BEGIN
        UPDATE tblTMSite SET ysnPrintDeliveryTicket = 0 
		WHERE ysnPrintDeliveryTicket IS NULL
    END

	IF EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'ysnDeliveryTicketPrinted' AND OBJECT_ID = OBJECT_ID(N'tblTMSite')) 
    BEGIN
        UPDATE tblTMSite SET ysnDeliveryTicketPrinted = 0 
		WHERE ysnDeliveryTicketPrinted IS NULL
    END

END
GO
PRINT N'END Renaming of columns in tblSMSite'
GO

PRINT N'BEGIN Renaming of columns in tblTMDevice'
GO
IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblTMDevice]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intRegulatorTypeId' AND OBJECT_ID = OBJECT_ID(N'tblTMDevice')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intRegulatorTypeID' AND OBJECT_ID = OBJECT_ID(N'tblTMDevice'))
    BEGIN
        EXEC sp_rename 'tblTMDevice.intRegulatorTypeID', 'intRegulatorTypeId' , 'COLUMN'
    END

	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intLeaseId' AND OBJECT_ID = OBJECT_ID(N'tblTMDevice')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intLeaseID' AND OBJECT_ID = OBJECT_ID(N'tblTMDevice'))
    BEGIN
        EXEC sp_rename 'tblTMDevice.intLeaseID', 'intLeaseId' , 'COLUMN'
    END

	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'dblTankSize' AND OBJECT_ID = OBJECT_ID(N'tblTMDevice')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intTankSize' AND OBJECT_ID = OBJECT_ID(N'tblTMDevice'))
    BEGIN
        EXEC sp_rename 'tblTMDevice.intTankSize', 'dblTankSize' , 'COLUMN'
    END

	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'dblTankCapacity' AND OBJECT_ID = OBJECT_ID(N'tblTMDevice')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intTankCapacity' AND OBJECT_ID = OBJECT_ID(N'tblTMDevice'))
    BEGIN
        EXEC sp_rename 'tblTMDevice.intTankCapacity', 'dblTankCapacity' , 'COLUMN'
    END

	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intTankTypeId' AND OBJECT_ID = OBJECT_ID(N'tblTMDevice')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intTankTypeID' AND OBJECT_ID = OBJECT_ID(N'tblTMDevice'))
    BEGIN
        EXEC sp_rename 'tblTMDevice.intTankTypeID', 'intTankTypeId' , 'COLUMN'
    END

	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intDeviceTypeId' AND OBJECT_ID = OBJECT_ID(N'tblTMDevice')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intDeviceTypeID' AND OBJECT_ID = OBJECT_ID(N'tblTMDevice'))
    BEGIN
        EXEC sp_rename 'tblTMDevice.intDeviceTypeID', 'intDeviceTypeId' , 'COLUMN'
    END

	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intInventoryStatusTypeId' AND OBJECT_ID = OBJECT_ID(N'tblTMDevice')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intInventoryStatusTypeID' AND OBJECT_ID = OBJECT_ID(N'tblTMDevice'))
    BEGIN
        EXEC sp_rename 'tblTMDevice.intInventoryStatusTypeID', 'intInventoryStatusTypeId' , 'COLUMN'
    END

	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intMeterTypeId' AND OBJECT_ID = OBJECT_ID(N'tblTMDevice')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intMeterTypeID' AND OBJECT_ID = OBJECT_ID(N'tblTMDevice'))
    BEGIN
        EXEC sp_rename 'tblTMDevice.intMeterTypeID', 'intMeterTypeId' , 'COLUMN'
    END
END
GO

PRINT N'END Renaming of columns in tblTMDevice'
GO



PRINT N'BEGIN Renaming of columns in tblTMLease'
GO
IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblTMLease]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intLeaseId' AND OBJECT_ID = OBJECT_ID(N'tblTMLease')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intLeaseID' AND OBJECT_ID = OBJECT_ID(N'tblTMLease'))
    BEGIN
        EXEC sp_rename 'tblTMLease.intLeaseID', 'intLeaseId' , 'COLUMN'
    END

	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intLeaseCodeId' AND OBJECT_ID = OBJECT_ID(N'tblTMLease')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intLeaseCodeID' AND OBJECT_ID = OBJECT_ID(N'tblTMLease'))
    BEGIN
        EXEC sp_rename 'tblTMLease.intLeaseCodeID', 'intLeaseCodeId' , 'COLUMN'
    END

	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intBillToCustomerId' AND OBJECT_ID = OBJECT_ID(N'tblTMLease')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intBillToCustomerID' AND OBJECT_ID = OBJECT_ID(N'tblTMLease'))
    BEGIN
        EXEC sp_rename 'tblTMLease.intBillToCustomerID', 'intBillToCustomerId' , 'COLUMN'
    END
END
GO
PRINT N'END Renaming of columns in tblTMLease'
GO



PRINT N'BEGIN Renaming of columns in tblTMEvent'
GO
IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblTMEvent]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intDeviceId' AND OBJECT_ID = OBJECT_ID(N'tblTMEvent')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intDeviceID' AND OBJECT_ID = OBJECT_ID(N'tblTMEvent'))
    BEGIN
        EXEC sp_rename 'tblTMEvent.intDeviceID', 'intDeviceId' , 'COLUMN'
    END
END
GO
PRINT N'END Renaming of columns in tblTMEvent'
GO


PRINT N'BEGIN Renaming of columns in tblTMSiteDevice'
GO
IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblTMSiteDevice]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intDeviceId' AND OBJECT_ID = OBJECT_ID(N'tblTMSiteDevice')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intDeviceID' AND OBJECT_ID = OBJECT_ID(N'tblTMSiteDevice'))
    BEGIN
        EXEC sp_rename 'tblTMSiteDevice.intDeviceID', 'intDeviceId' , 'COLUMN'
    END
END
GO
PRINT N'BEGIN Renaming of columns in tblTMSiteDevice'
GO



PRINT N'BEGIN Renaming of columns in tblTMRoute'
GO
IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblTMRoute]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intRouteId' AND OBJECT_ID = OBJECT_ID(N'tblTMRoute')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intRouteID' AND OBJECT_ID = OBJECT_ID(N'tblTMRoute'))
    BEGIN
        EXEC sp_rename 'tblTMRoute.intRouteID', 'intRouteId' , 'COLUMN'
    END

	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'strRouteId' AND OBJECT_ID = OBJECT_ID(N'tblTMRoute')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'strRouteID' AND OBJECT_ID = OBJECT_ID(N'tblTMRoute'))
    BEGIN
        EXEC sp_rename 'tblTMRoute.strRouteID', 'strRouteId' , 'COLUMN'
    END
END
GO
PRINT N'END Renaming of columns in tblTMRoute'
GO

PRINT N'BEGIN Renaming of columns in tblTMFillMethod'
GO
IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblTMFillMethod]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intFillMethodId' AND OBJECT_ID = OBJECT_ID(N'tblTMFillMethod')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intFillMethodID' AND OBJECT_ID = OBJECT_ID(N'tblTMFillMethod'))
    BEGIN
        EXEC sp_rename 'tblTMFillMethod.intFillMethodID', 'intFillMethodId' , 'COLUMN'
    END
END
GO
PRINT N'BEGIN Renaming of columns in tblTMFillMethod'
GO

PRINT N'BEGIN Renaming of columns in tblTMDeviceType'
GO
IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblTMDeviceType]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intDeviceTypeId' AND OBJECT_ID = OBJECT_ID(N'tblTMDeviceType')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intDeviceTypeID' AND OBJECT_ID = OBJECT_ID(N'tblTMDeviceType'))
    BEGIN
        EXEC sp_rename 'tblTMDeviceType.intDeviceTypeID', 'intDeviceTypeId' , 'COLUMN'
    END
END
GO
PRINT N'END Renaming of columns in tblTMDeviceType'
GO

PRINT N'BEGIN Renaming of columns in tblTMMeterType'
GO
IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblTMMeterType]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intMeterTypeId' AND OBJECT_ID = OBJECT_ID(N'tblTMMeterType')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intMeterTypeID' AND OBJECT_ID = OBJECT_ID(N'tblTMMeterType'))
    BEGIN
        EXEC sp_rename 'tblTMMeterType.intMeterTypeID', 'intMeterTypeId' , 'COLUMN'
    END
END
GO
PRINT N'END Renaming of columns in tblTMMeterType'
GO

PRINT N'BEGIN Renaming of columns in tblTMTankType'
GO
IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblTMTankType]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intTankTypeId' AND OBJECT_ID = OBJECT_ID(N'tblTMTankType')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intTankTypeID' AND OBJECT_ID = OBJECT_ID(N'tblTMTankType'))
    BEGIN
        EXEC sp_rename 'tblTMTankType.intTankTypeID', 'intTankTypeId' , 'COLUMN'
    END
END
GO
PRINT N'END Renaming of columns in tblTMTankType'
GO

PRINT N'BEGIN Renaming of columns in tblTMInventoryStatusType'
GO
IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblTMInventoryStatustype]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intInventoryStatusTypeId' AND OBJECT_ID = OBJECT_ID(N'tblTMInventoryStatusType')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intInventoryStatusTypeID' AND OBJECT_ID = OBJECT_ID(N'tblTMInventoryStatusType'))
    BEGIN
        EXEC sp_rename 'tblTMInventoryStatusType.intInventoryStatusTypeID', 'intInventoryStatusTypeId' , 'COLUMN'
    END
END
GO
PRINT N'END Renaming of columns in tblTMInventoryStatusType'
GO

PRINT N'BEGIN Renaming of columns in tblTMRegulatorType'
GO
IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblTMRegulatorType]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intRegulatorTypeId' AND OBJECT_ID = OBJECT_ID(N'tblTMRegulatorType')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intRegulatorTypeID' AND OBJECT_ID = OBJECT_ID(N'tblTMRegulatorType'))
    BEGIN
        EXEC sp_rename 'tblTMRegulatorType.intRegulatorTypeID', 'intRegulatorTypeId' , 'COLUMN'
    END
END
GO
PRINT N'END Renaming of columns in tblTMRegulatorType'
GO

PRINT N'BEGIN Renaming of columns in tblTMLeaseCode'
GO
IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblTMLeaseCode]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intLeaseCodeId' AND OBJECT_ID = OBJECT_ID(N'tblTMLeaseCode')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intLeaseCodeID' AND OBJECT_ID = OBJECT_ID(N'tblTMLeaseCode'))
    BEGIN
        EXEC sp_rename 'tblTMLeaseCode.intLeaseCodeID', 'intLeaseCodeId' , 'COLUMN'
    END
END
GO
PRINT N'END Renaming of columns in tblTMLeaseCode'
GO


PRINT N'BEGIN Renaming of columns in tblTMDevice'
GO
IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblTMDevice]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intDeviceId' AND OBJECT_ID = OBJECT_ID(N'tblTMDevice')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intDeviceID' AND OBJECT_ID = OBJECT_ID(N'tblTMDevice'))
    BEGIN
        EXEC sp_rename 'tblTMDevice.intDeviceID', 'intDeviceId' , 'COLUMN'
    END
END
GO
PRINT N'END Renaming of columns in tblTMDevice'
GO

PRINT N'BEGIN Renaming of columns in tblTMFillGroup'
GO
IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblTMFillGroup]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intFillGroupId' AND OBJECT_ID = OBJECT_ID(N'tblTMFillGroup')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intFillGroupID' AND OBJECT_ID = OBJECT_ID(N'tblTMFillGroup'))
    BEGIN
        EXEC sp_rename 'tblTMFillGroup.intFillGroupID', 'intFillGroupId' , 'COLUMN'
    END
END
GO
PRINT N'END Renaming of columns in tblTMFillGroup'
GO



-- CM
IF EXISTS(select 1  from INFORMATION_SCHEMA.TABLES where TABLE_NAME = N'apcbkmst' and TABLE_TYPE = N'BASE TABLE')
BEGIN
	EXEC sp_rename 'apcbkmst', 'apcbkmst_origin'
END

GO

IF EXISTS(select 1  from INFORMATION_SCHEMA.TABLES where TABLE_NAME = N'apchkmst' and TABLE_TYPE = N'BASE TABLE')
BEGIN
	EXEC sp_rename 'apchkmst', 'apchkmst_origin'
END
GO



-- 1 of 3: Drop old stored procedures referencing RecapTableType. 
PRINT N'BEGIN CASH MANAGEMENT DELETE PATH: 14.1 to 14.2'

PRINT N'Dropping [dbo].[PostRecap]...';
GO
	IF EXISTS (SELECT 1 FROM sys.objects WHERE name = 'PostRecap' and type = 'P') DROP PROCEDURE [dbo].[PostRecap];
GO
PRINT N'Dropping [dbo].[BookGLEntries]...';
GO
	IF EXISTS (SELECT 1 FROM sys.objects WHERE name = 'BookGLEntries' and type = 'P') DROP PROCEDURE [dbo].[BookGLEntries];
GO
PRINT N'Dropping [dbo].[PostCMBankTransfer]...';
GO
	IF EXISTS (SELECT 1 FROM sys.objects WHERE name = 'PostCMBankTransfer' and type = 'P') DROP PROCEDURE [dbo].[PostCMBankTransfer];
GO
PRINT N'Dropping [dbo].[PostCMBankDeposit]...';
GO
	IF EXISTS (SELECT 1 FROM sys.objects WHERE name = 'PostCMBankDeposit' and type = 'P') DROP PROCEDURE [dbo].[PostCMBankDeposit];
GO
PRINT N'Dropping [dbo].[PostCMBankTransaction]...';
GO
	IF EXISTS (SELECT 1 FROM sys.objects WHERE name = 'PostCMBankTransaction' and type = 'P') DROP PROCEDURE [dbo].[PostCMBankTransaction];
GO
PRINT N'Dropping [dbo].[PostCMMiscChecks]...';
GO
	IF EXISTS (SELECT 1 FROM sys.objects WHERE name = 'PostCMMiscChecks' and type = 'P') DROP PROCEDURE [dbo].[PostCMMiscChecks];
GO

-- 2 of 3: Drop new stored procedures referencing RecapTableType. 
PRINT N'Dropping [dbo].[uspCMPostRecap]...';
GO
	IF EXISTS (SELECT 1 FROM sys.objects WHERE name = 'uspCMPostRecap' and type = 'P') DROP PROCEDURE [dbo].[uspCMPostRecap];
GO

PRINT N'Dropping [dbo].[uspCMBookGLEntries]...';
GO
	IF EXISTS (SELECT 1 FROM sys.objects WHERE name = 'uspCMBookGLEntries' and type = 'P') DROP PROCEDURE [dbo].[uspCMBookGLEntries];
GO

PRINT N'Dropping [dbo].[uspCMPostBankDeposit]...';
GO
	IF EXISTS (SELECT 1 FROM sys.objects WHERE name = 'uspCMPostBankDeposit' and type = 'P') DROP PROCEDURE [dbo].[uspCMPostBankDeposit];
GO

PRINT N'Dropping [dbo].[uspCMPostBankTransaction]...';
GO
	IF EXISTS (SELECT 1 FROM sys.objects WHERE name = 'uspCMPostBankTransaction' and type = 'P') DROP PROCEDURE [dbo].[uspCMPostBankTransaction];
GO

PRINT N'Dropping [dbo].[uspCMPostBankTransfer]...';
GO
	IF EXISTS (SELECT 1 FROM sys.objects WHERE name = 'uspCMPostBankTransfer' and type = 'P') DROP PROCEDURE [dbo].[uspCMPostBankTransfer];
GO

PRINT N'Dropping [dbo].[uspCMPostMiscChecks]...';
GO
	IF EXISTS (SELECT 1 FROM sys.objects WHERE name = 'uspCMPostMiscChecks' and type = 'P') DROP PROCEDURE [dbo].[uspCMPostMiscChecks];
GO

-- 3 of 3: Drop RecapTableType
PRINT N'Dropping [dbo].[RecapTableType]...';
GO
	IF EXISTS (SELECT 1 FROM sys.table_types WHERE name = 'RecapTableType') DROP TYPE [dbo].[RecapTableType]
GO

PRINT N'END CASH MANAGEMENT DELETE PATH: 14.1 to 14.2'

-- DB
--tblDBPanel
IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblDBPanel]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS(SELECT top 1 1 FROM sys.columns WHERE NAME  = N'intPanelId' AND OBJECT_ID = OBJECT_ID(N'tblDBPanel')) AND EXISTS (SELECT top 1 1 FROM sys.columns WHERE NAME  = N'intPanelID' AND OBJECT_ID = OBJECT_ID(N'tblDBPanel'))
	BEGIN
	 EXEC sp_rename 'tblDBPanel.intPanelID', 'intPanelId', 'COLUMN'
	END
	  
	IF NOT EXISTS(SELECT top 1 1 FROM sys.columns WHERE NAME  = N'intUserId' AND OBJECT_ID = OBJECT_ID(N'tblDBPanel')) AND EXISTS (SELECT top 1 1 FROM sys.columns WHERE NAME  = N'intUserID' AND OBJECT_ID = OBJECT_ID(N'tblDBPanel'))
	BEGIN
	 EXEC sp_rename 'tblDBPanel.intUserID', 'intUserId', 'COLUMN'
	END
	
	IF NOT EXISTS(SELECT top 1 1 FROM sys.columns WHERE NAME  = N'intSourcePanelId' AND OBJECT_ID = OBJECT_ID(N'tblDBPanel')) AND EXISTS (SELECT top 1 1 FROM sys.columns WHERE NAME  = N'intSourcePanelID' AND OBJECT_ID = OBJECT_ID(N'tblDBPanel'))
	BEGIN
	 EXEC sp_rename 'tblDBPanel.intSourcePanelID', 'intSourcePanelId', 'COLUMN'
	END

	IF NOT EXISTS(SELECT top 1 1 FROM sys.columns WHERE NAME  = N'intConnectionId' AND OBJECT_ID = OBJECT_ID(N'tblDBPanel')) AND EXISTS (SELECT top 1 1 FROM sys.columns WHERE NAME  = N'intConnectionID' AND OBJECT_ID = OBJECT_ID(N'tblDBPanel'))
	BEGIN
	 EXEC sp_rename 'tblDBPanel.intConnectionID', 'intConnectionId', 'COLUMN'
	END
	     
END
GO



 --tblDBPanelAccess
IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblDBPanelAccess]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS(SELECT top 1 1 FROM sys.columns WHERE NAME  = N'intPanelUserId' AND OBJECT_ID = OBJECT_ID(N'tblDBPanelAccess')) AND EXISTS (SELECT top 1 1 FROM sys.columns WHERE NAME  = N'intPanelUserID' AND OBJECT_ID = OBJECT_ID(N'tblDBPanelAccess'))
	BEGIN
	 EXEC sp_rename 'tblDBPanelAccess.intPanelUserID', 'intPanelUserId', 'COLUMN'
	END

	IF NOT EXISTS(SELECT top 1 1 FROM sys.columns WHERE NAME  = N'intUserId' AND OBJECT_ID = OBJECT_ID(N'tblDBPanelAccess')) AND EXISTS (SELECT top 1 1 FROM sys.columns WHERE NAME  = N'intUserID' AND OBJECT_ID = OBJECT_ID(N'tblDBPanelAccess'))
	BEGIN
	 EXEC sp_rename 'tblDBPanelAccess.intUserID', 'intUserId', 'COLUMN'
	END

	IF NOT EXISTS(SELECT top 1 1 FROM sys.columns WHERE NAME  = N'intPanelId' AND OBJECT_ID = OBJECT_ID(N'tblDBPanelAccess')) AND EXISTS (SELECT top 1 1 FROM sys.columns WHERE NAME  = N'intPanelID' AND OBJECT_ID = OBJECT_ID(N'tblDBPanelAccess'))
	BEGIN
	 EXEC sp_rename 'tblDBPanelAccess.intPanelID', 'intPanelId', 'COLUMN'
	END
	     
END
GO



 --tblDBPanelColumn
IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblDBPanelColumn]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS(SELECT top 1 1 FROM sys.columns WHERE NAME  = N'intPanelColumnId' AND OBJECT_ID = OBJECT_ID(N'tblDBPanelColumn')) AND EXISTS (SELECT top 1 1 FROM sys.columns WHERE NAME  = N'intPanelColumnID' AND OBJECT_ID = OBJECT_ID(N'tblDBPanelColumn'))
	BEGIN
	 EXEC sp_rename 'tblDBPanelColumn.intPanelColumnID', 'intPanelColumnId', 'COLUMN'
	END

	IF NOT EXISTS(SELECT top 1 1 FROM sys.columns WHERE NAME  = N'intUserId' AND OBJECT_ID = OBJECT_ID(N'tblDBPanelColumn')) AND EXISTS (SELECT top 1 1 FROM sys.columns WHERE NAME  = N'intUserID' AND OBJECT_ID = OBJECT_ID(N'tblDBPanelColumn'))
	BEGIN
	 EXEC sp_rename 'tblDBPanelColumn.intUserID', 'intUserId', 'COLUMN'
	END

	IF NOT EXISTS(SELECT top 1 1 FROM sys.columns WHERE NAME  = N'intPanelId' AND OBJECT_ID = OBJECT_ID(N'tblDBPanelColumn')) AND EXISTS (SELECT top 1 1 FROM sys.columns WHERE NAME  = N'intPanelID' AND OBJECT_ID = OBJECT_ID(N'tblDBPanelColumn'))
	BEGIN
	 EXEC sp_rename 'tblDBPanelColumn.intPanelID', 'intPanelId', 'COLUMN'
	END
	     
END
GO



--tblDBPanelFormat
IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblDBPanelFormat]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS(SELECT top 1 1 FROM sys.columns WHERE NAME  = N'intPanelFormatId' AND OBJECT_ID = OBJECT_ID(N'tblDBPanelFormat')) AND EXISTS (SELECT top 1 1 FROM sys.columns WHERE NAME  = N'intPanelFormatID' AND OBJECT_ID = OBJECT_ID(N'tblDBPanelFormat'))
	BEGIN
	 EXEC sp_rename 'tblDBPanelFormat.intPanelFormatID', 'intPanelFormatId', 'COLUMN'
	END

	IF NOT EXISTS(SELECT top 1 1 FROM sys.columns WHERE NAME  = N'intUserId' AND OBJECT_ID = OBJECT_ID(N'tblDBPanelFormat')) AND EXISTS (SELECT top 1 1 FROM sys.columns WHERE NAME  = N'intUserID' AND OBJECT_ID = OBJECT_ID(N'tblDBPanelFormat'))
	BEGIN
	 EXEC sp_rename 'tblDBPanelFormat.intUserID', 'intUserId', 'COLUMN'
	END

	IF NOT EXISTS(SELECT top 1 1 FROM sys.columns WHERE NAME  = N'intPanelId' AND OBJECT_ID = OBJECT_ID(N'tblDBPanelFormat')) AND EXISTS (SELECT top 1 1 FROM sys.columns WHERE NAME  = N'intPanelID' AND OBJECT_ID = OBJECT_ID(N'tblDBPanelFormat'))
	BEGIN
	 EXEC sp_rename 'tblDBPanelFormat.intPanelID', 'intPanelId', 'COLUMN'
	END	
	  	     
END
GO



--tblDBPanelTab
IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblDBPanelTab]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS(SELECT top 1 1 FROM sys.columns WHERE NAME  = N'intPanelTabId' AND OBJECT_ID = OBJECT_ID(N'tblDBPanelTab')) AND EXISTS (SELECT top 1 1 FROM sys.columns WHERE NAME  = N'intPanelTabID' AND OBJECT_ID = OBJECT_ID(N'tblDBPanelTab'))
	BEGIN
	 EXEC sp_rename 'tblDBPanelTab.intPanelTabID', 'intPanelTabId', 'COLUMN'
	END

	IF NOT EXISTS(SELECT top 1 1 FROM sys.columns WHERE NAME  = N'intUserId' AND OBJECT_ID = OBJECT_ID(N'tblDBPanelTab')) AND EXISTS (SELECT top 1 1 FROM sys.columns WHERE NAME  = N'intUserID' AND OBJECT_ID = OBJECT_ID(N'tblDBPanelTab'))
	BEGIN
	 EXEC sp_rename 'tblDBPanelTab.intUserID', 'intUserId', 'COLUMN'
	END
	  		     
END
GO



--tblDBPanelUser
IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblDBPanelUser]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS(SELECT top 1 1 FROM sys.columns WHERE NAME  = N'intPanelUserId' AND OBJECT_ID = OBJECT_ID(N'tblDBPanelUser')) AND EXISTS (SELECT top 1 1 FROM sys.columns WHERE NAME  = N'intPanelUserID' AND OBJECT_ID = OBJECT_ID(N'tblDBPanelUser'))
	BEGIN
	 EXEC sp_rename 'tblDBPanelUser.intPanelUserID', 'intPanelUserId', 'COLUMN'
	END

	IF NOT EXISTS(SELECT top 1 1 FROM sys.columns WHERE NAME  = N'intPanelId' AND OBJECT_ID = OBJECT_ID(N'tblDBPanelUser')) AND EXISTS (SELECT top 1 1 FROM sys.columns WHERE NAME  = N'intPanelID' AND OBJECT_ID = OBJECT_ID(N'tblDBPanelUser'))
	BEGIN
	 EXEC sp_rename 'tblDBPanelUser.intPanelID', 'intPanelId', 'COLUMN'
	END
	
	IF NOT EXISTS(SELECT top 1 1 FROM sys.columns WHERE NAME  = N'intPanelTabId' AND OBJECT_ID = OBJECT_ID(N'tblDBPanelUser')) AND EXISTS (SELECT top 1 1 FROM sys.columns WHERE NAME  = N'intPanelTabID' AND OBJECT_ID = OBJECT_ID(N'tblDBPanelUser'))
	BEGIN
	 EXEC sp_rename 'tblDBPanelUser.intPanelTabID', 'intPanelTabId', 'COLUMN'
	END
	
	IF NOT EXISTS(SELECT top 1 1 FROM sys.columns WHERE NAME  = N'intUserId' AND OBJECT_ID = OBJECT_ID(N'tblDBPanelUser')) AND EXISTS (SELECT top 1 1 FROM sys.columns WHERE NAME  = N'intUserID' AND OBJECT_ID = OBJECT_ID(N'tblDBPanelUser'))
	BEGIN
	 EXEC sp_rename 'tblDBPanelUser.intUserID', 'intUserId', 'COLUMN'
	END  
	     
END
GO

-- SM
GO
	PRINT N'BEGIN CLEAN UP PREFERENCES - update null intUserID to 0'
GO
	IF EXISTS(select top 1 1 from INFORMATION_SCHEMA.COLUMNS WHERE UPPER(COLUMN_NAME) = 'INTUSERID' and UPPER(TABLE_NAME) = 'TBLSMPREFERENCES') 
		EXEC('UPDATE tblSMPreferences SET intUserID = 0  WHERE intUserID is null')
GO
	PRINT N'END CLEAN UP PREFERENCES - update null intUserID to 0'
GO

-- CM

GO
	PRINT N'BEGIN DROP Cash Management Triggers'
GO
	IF OBJECT_ID('trg_delete_apchkmst', 'TR') IS NOT NULL
		DROP TRIGGER trg_delete_apchkmst;
GO
	PRINT N'END DROP Cash Management Triggers'
GO

-- GL

--=====================================================================================================================================
-- 	UPDATE FIELD CASING (ID to Id)
---------------------------------------------------------------------------------------------------------------------------------------

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblGLAccount]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intAccountId' AND OBJECT_ID = OBJECT_ID(N'tblGLAccount')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intAccountID' AND OBJECT_ID = OBJECT_ID(N'tblGLAccount'))
    BEGIN
        EXEC sp_rename 'tblGLAccount.intAccountID', 'intAccountId' , 'COLUMN'
    END
END
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblGLAccount]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'strAccountId' AND OBJECT_ID = OBJECT_ID(N'tblGLAccount')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'strAccountID' AND OBJECT_ID = OBJECT_ID(N'tblGLAccount'))
    BEGIN
        EXEC sp_rename 'tblGLAccount.strAccountID', 'strAccountId' , 'COLUMN'
    END
END
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblGLAccount]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intAccountGroupId' AND OBJECT_ID = OBJECT_ID(N'tblGLAccount')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intAccountGroupID' AND OBJECT_ID = OBJECT_ID(N'tblGLAccount'))
    BEGIN
        EXEC sp_rename 'tblGLAccount.intAccountGroupID', 'intAccountGroupId' , 'COLUMN'
    END
END
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblGLAccount]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intAccountUnitId' AND OBJECT_ID = OBJECT_ID(N'tblGLAccount')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intAccountUnitID' AND OBJECT_ID = OBJECT_ID(N'tblGLAccount'))
    BEGIN
        EXEC sp_rename 'tblGLAccount.intAccountUnitID', 'intAccountUnitId' , 'COLUMN'
    END
END
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblGLAccountAllocationDetail]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intAccountAllocationDetailId' AND OBJECT_ID = OBJECT_ID(N'tblGLAccountAllocationDetail')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intAccountAllocationDetailID' AND OBJECT_ID = OBJECT_ID(N'tblGLAccountAllocationDetail'))
    BEGIN
        EXEC sp_rename 'tblGLAccountAllocationDetail.intAccountAllocationDetailID', 'intAccountAllocationDetailId' , 'COLUMN'
    END
END
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblGLAccountAllocationDetail]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intAllocatedAccountId' AND OBJECT_ID = OBJECT_ID(N'tblGLAccountAllocationDetail')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intAllocatedAccountID' AND OBJECT_ID = OBJECT_ID(N'tblGLAccountAllocationDetail'))
    BEGIN
        EXEC sp_rename 'tblGLAccountAllocationDetail.intAllocatedAccountID', 'intAllocatedAccountId' , 'COLUMN'
    END
END
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblGLAccountAllocationDetail]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intAccountId' AND OBJECT_ID = OBJECT_ID(N'tblGLAccountAllocationDetail')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intAccountID' AND OBJECT_ID = OBJECT_ID(N'tblGLAccountAllocationDetail'))
    BEGIN
        EXEC sp_rename 'tblGLAccountAllocationDetail.intAccountID', 'intAccountId' , 'COLUMN'
    END
END
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblGLAccountAllocationDetail]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'strJobId' AND OBJECT_ID = OBJECT_ID(N'tblGLAccountAllocationDetail')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'strJobID' AND OBJECT_ID = OBJECT_ID(N'tblGLAccountAllocationDetail'))
    BEGIN
        EXEC sp_rename 'tblGLAccountAllocationDetail.strJobID', 'strJobId' , 'COLUMN'
    END
END
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblGLAccountDefault]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intAccountDefaultId' AND OBJECT_ID = OBJECT_ID(N'tblGLAccountDefault')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intAccountDefaultID' AND OBJECT_ID = OBJECT_ID(N'tblGLAccountDefault'))
    BEGIN
        EXEC sp_rename 'tblGLAccountDefault.intAccountDefaultID', 'intAccountDefaultId' , 'COLUMN'
    END
END
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblGLAccountDefault]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intSecurityUserId' AND OBJECT_ID = OBJECT_ID(N'tblGLAccountDefault')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intSecurityUserID' AND OBJECT_ID = OBJECT_ID(N'tblGLAccountDefault'))
    BEGIN
        EXEC sp_rename 'tblGLAccountDefault.intSecurityUserID', 'intSecurityUserId' , 'COLUMN'
    END
END
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblGLAccountDefault]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intGLAccountTemplateId' AND OBJECT_ID = OBJECT_ID(N'tblGLAccountDefault')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intGLAccountTemplateID' AND OBJECT_ID = OBJECT_ID(N'tblGLAccountDefault'))
    BEGIN
        EXEC sp_rename 'tblGLAccountDefault.intGLAccountTemplateID', 'intGLAccountTemplateId' , 'COLUMN'
    END
END
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblGLAccountDefaultDetail]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intAccountDefaultDetailId' AND OBJECT_ID = OBJECT_ID(N'tblGLAccountDefaultDetail')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intAccountDefaultDetailID' AND OBJECT_ID = OBJECT_ID(N'tblGLAccountDefaultDetail'))
    BEGIN
        EXEC sp_rename 'tblGLAccountDefaultDetail.intAccountDefaultDetailID', 'intAccountDefaultDetailId' , 'COLUMN'
    END
END
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblGLAccountDefaultDetail]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intAccountDefaultId' AND OBJECT_ID = OBJECT_ID(N'tblGLAccountDefaultDetail')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intAccountDefaultID' AND OBJECT_ID = OBJECT_ID(N'tblGLAccountDefaultDetail'))
    BEGIN
        EXEC sp_rename 'tblGLAccountDefaultDetail.intAccountDefaultID', 'intAccountDefaultId' , 'COLUMN'
    END
END
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblGLAccountDefaultDetail]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intAccountId' AND OBJECT_ID = OBJECT_ID(N'tblGLAccountDefaultDetail')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intAccountID' AND OBJECT_ID = OBJECT_ID(N'tblGLAccountDefaultDetail'))
    BEGIN
        EXEC sp_rename 'tblGLAccountDefaultDetail.intAccountID', 'intAccountId' , 'COLUMN'
    END
END
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblGLAccountGroup]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intAccountGroupId' AND OBJECT_ID = OBJECT_ID(N'tblGLAccountGroup')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intAccountGroupID' AND OBJECT_ID = OBJECT_ID(N'tblGLAccountGroup'))
    BEGIN
        EXEC sp_rename 'tblGLAccountGroup.intAccountGroupID', 'intAccountGroupId' , 'COLUMN'
    END
END
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblGLAccountGroup]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intParentGroupId' AND OBJECT_ID = OBJECT_ID(N'tblGLAccountGroup')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intParentGroupID' AND OBJECT_ID = OBJECT_ID(N'tblGLAccountGroup'))
    BEGIN
        EXEC sp_rename 'tblGLAccountGroup.intParentGroupID', 'intParentGroupId' , 'COLUMN'
    END
END
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblGLAccountReallocation]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intAccountReallocationId' AND OBJECT_ID = OBJECT_ID(N'tblGLAccountReallocation')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intAccountReallocationID' AND OBJECT_ID = OBJECT_ID(N'tblGLAccountReallocation'))
    BEGIN
        EXEC sp_rename 'tblGLAccountReallocation.intAccountReallocationID', 'intAccountReallocationId' , 'COLUMN'
    END
END
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblGLAccountReallocationDetail]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intAccountReallocationDetailId' AND OBJECT_ID = OBJECT_ID(N'tblGLAccountReallocationDetail')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intAccountReallocationDetailID' AND OBJECT_ID = OBJECT_ID(N'tblGLAccountReallocationDetail'))
    BEGIN
        EXEC sp_rename 'tblGLAccountReallocationDetail.intAccountReallocationDetailID', 'intAccountReallocationDetailId' , 'COLUMN'
    END
END
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblGLAccountReallocationDetail]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intAccountReallocationId' AND OBJECT_ID = OBJECT_ID(N'tblGLAccountReallocationDetail')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intAccountReallocationID' AND OBJECT_ID = OBJECT_ID(N'tblGLAccountReallocationDetail'))
    BEGIN
        EXEC sp_rename 'tblGLAccountReallocationDetail.intAccountReallocationID', 'intAccountReallocationId' , 'COLUMN'
    END
END
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblGLAccountReallocationDetail]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intAccountId' AND OBJECT_ID = OBJECT_ID(N'tblGLAccountReallocationDetail')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intAccountID' AND OBJECT_ID = OBJECT_ID(N'tblGLAccountReallocationDetail'))
    BEGIN
        EXEC sp_rename 'tblGLAccountReallocationDetail.intAccountID', 'intAccountId' , 'COLUMN'
    END
END
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblGLAccountReallocationDetail]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'strJobId' AND OBJECT_ID = OBJECT_ID(N'tblGLAccountReallocationDetail')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'strJobID' AND OBJECT_ID = OBJECT_ID(N'tblGLAccountReallocationDetail'))
    BEGIN
        EXEC sp_rename 'tblGLAccountReallocationDetail.strJobID', 'strJobId' , 'COLUMN'
    END
END
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblGLAccountSegment]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intAccountSegmentId' AND OBJECT_ID = OBJECT_ID(N'tblGLAccountSegment')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intAccountSegmentID' AND OBJECT_ID = OBJECT_ID(N'tblGLAccountSegment'))
    BEGIN
        EXEC sp_rename 'tblGLAccountSegment.intAccountSegmentID', 'intAccountSegmentId' , 'COLUMN'
    END
END
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblGLAccountSegment]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intAccountStructureId' AND OBJECT_ID = OBJECT_ID(N'tblGLAccountSegment')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intAccountStructureID' AND OBJECT_ID = OBJECT_ID(N'tblGLAccountSegment'))
    BEGIN
        EXEC sp_rename 'tblGLAccountSegment.intAccountStructureID', 'intAccountStructureId' , 'COLUMN'
    END
END
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblGLAccountSegment]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intAccountGroupId' AND OBJECT_ID = OBJECT_ID(N'tblGLAccountSegment')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intAccountGroupID' AND OBJECT_ID = OBJECT_ID(N'tblGLAccountSegment'))
    BEGIN
        EXEC sp_rename 'tblGLAccountSegment.intAccountGroupID', 'intAccountGroupId' , 'COLUMN'
    END
END
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblGLAccountSegmentMapping]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intAccountSegmentMappingId' AND OBJECT_ID = OBJECT_ID(N'tblGLAccountSegmentMapping')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intAccountSegmentMappingID' AND OBJECT_ID = OBJECT_ID(N'tblGLAccountSegmentMapping'))
    BEGIN
        EXEC sp_rename 'tblGLAccountSegmentMapping.intAccountSegmentMappingID', 'intAccountSegmentMappingId' , 'COLUMN'
    END
END
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblGLAccountSegmentMapping]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intAccountId' AND OBJECT_ID = OBJECT_ID(N'tblGLAccountSegmentMapping')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intAccountID' AND OBJECT_ID = OBJECT_ID(N'tblGLAccountSegmentMapping'))
    BEGIN
        EXEC sp_rename 'tblGLAccountSegmentMapping.intAccountID', 'intAccountId' , 'COLUMN'
    END
END
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblGLAccountSegmentMapping]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intAccountSegmentId' AND OBJECT_ID = OBJECT_ID(N'tblGLAccountSegmentMapping')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intAccountSegmentID' AND OBJECT_ID = OBJECT_ID(N'tblGLAccountSegmentMapping'))
    BEGIN
        EXEC sp_rename 'tblGLAccountSegmentMapping.intAccountSegmentID', 'intAccountSegmentId' , 'COLUMN'
    END
END
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblGLAccountStructure]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intAccountStructureId' AND OBJECT_ID = OBJECT_ID(N'tblGLAccountStructure')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intAccountStructureID' AND OBJECT_ID = OBJECT_ID(N'tblGLAccountStructure'))
    BEGIN
        EXEC sp_rename 'tblGLAccountStructure.intAccountStructureID', 'intAccountStructureId' , 'COLUMN'
    END
END
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblGLAccountStructure]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intOriginLength' AND OBJECT_ID = OBJECT_ID(N'tblGLAccountStructure')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intLegacyLength' AND OBJECT_ID = OBJECT_ID(N'tblGLAccountStructure'))
    BEGIN
        EXEC sp_rename 'tblGLAccountStructure.intLegacyLength', 'intOriginLength' , 'COLUMN'
    END
END
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblGLAccountTemplate]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intGLAccountTemplateId' AND OBJECT_ID = OBJECT_ID(N'tblGLAccountTemplate')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intGLAccountTemplateID' AND OBJECT_ID = OBJECT_ID(N'tblGLAccountTemplate'))
    BEGIN
        EXEC sp_rename 'tblGLAccountTemplate.intGLAccountTemplateID', 'intGLAccountTemplateId' , 'COLUMN'
    END
END
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblGLAccountTemplateDetail]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intGLAccountTempalteDetailId' AND OBJECT_ID = OBJECT_ID(N'tblGLAccountTemplateDetail')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intGLAccountTempalteDetailID' AND OBJECT_ID = OBJECT_ID(N'tblGLAccountTemplateDetail'))
    BEGIN
        EXEC sp_rename 'tblGLAccountTemplateDetail.intGLAccountTempalteDetailID', 'intGLAccountTempalteDetailId' , 'COLUMN'
    END
END
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblGLAccountTemplateDetail]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intGLAccountTemplateId' AND OBJECT_ID = OBJECT_ID(N'tblGLAccountTemplateDetail')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intGLAccountTemplateID' AND OBJECT_ID = OBJECT_ID(N'tblGLAccountTemplateDetail'))
    BEGIN
        EXEC sp_rename 'tblGLAccountTemplateDetail.intGLAccountTemplateID', 'intGLAccountTemplateId' , 'COLUMN'
    END
END
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblGLAccountTemplateDetail]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intAccountId' AND OBJECT_ID = OBJECT_ID(N'tblGLAccountTemplateDetail')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intAccountID' AND OBJECT_ID = OBJECT_ID(N'tblGLAccountTemplateDetail'))
    BEGIN
        EXEC sp_rename 'tblGLAccountTemplateDetail.intAccountID', 'intAccountId' , 'COLUMN'
    END
END
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblGLAccountUnit]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intAccountUnitId' AND OBJECT_ID = OBJECT_ID(N'tblGLAccountUnit')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intAccountUnitID' AND OBJECT_ID = OBJECT_ID(N'tblGLAccountUnit'))
    BEGIN
        EXEC sp_rename 'tblGLAccountUnit.intAccountUnitID', 'intAccountUnitId' , 'COLUMN'
    END
END
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblGLBudget]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intBudgetId' AND OBJECT_ID = OBJECT_ID(N'tblGLBudget')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intBudgetID' AND OBJECT_ID = OBJECT_ID(N'tblGLBudget'))
    BEGIN
        EXEC sp_rename 'tblGLBudget.intBudgetID', 'intBudgetId' , 'COLUMN'
    END
END
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblGLBudget]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intFiscalYearId' AND OBJECT_ID = OBJECT_ID(N'tblGLBudget')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intFiscalYearID' AND OBJECT_ID = OBJECT_ID(N'tblGLBudget'))
    BEGIN
        EXEC sp_rename 'tblGLBudget.intFiscalYearID', 'intFiscalYearId' , 'COLUMN'
    END
END
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblGLBudget]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intAccountId' AND OBJECT_ID = OBJECT_ID(N'tblGLBudget')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intAccountID' AND OBJECT_ID = OBJECT_ID(N'tblGLBudget'))
    BEGIN
        EXEC sp_rename 'tblGLBudget.intAccountID', 'intAccountId' , 'COLUMN'
    END
END
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblGLBudget]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intAccountGroupId' AND OBJECT_ID = OBJECT_ID(N'tblGLBudget')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intAccountGroupID' AND OBJECT_ID = OBJECT_ID(N'tblGLBudget'))
    BEGIN
        EXEC sp_rename 'tblGLBudget.intAccountGroupID', 'intAccountGroupId' , 'COLUMN'
    END
END
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblGLBudget]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intAccountGroupId' AND OBJECT_ID = OBJECT_ID(N'tblGLBudget')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intAccountGroupID' AND OBJECT_ID = OBJECT_ID(N'tblGLBudget'))
    BEGIN
        EXEC sp_rename 'tblGLBudget.intAccountGroupID', 'intAccountGroupId' , 'COLUMN'
    END
END
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblGLBudgetDetail]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'cntId' AND OBJECT_ID = OBJECT_ID(N'tblGLBudgetDetail')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'cntID' AND OBJECT_ID = OBJECT_ID(N'tblGLBudgetDetail'))
    BEGIN
        EXEC sp_rename 'tblGLBudgetDetail.cntID', 'cntId' , 'COLUMN'
    END
END
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblGLBudgetDetail]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'strAccountId' AND OBJECT_ID = OBJECT_ID(N'tblGLBudgetDetail')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'strAccountID' AND OBJECT_ID = OBJECT_ID(N'tblGLBudgetDetail'))
    BEGIN
        EXEC sp_rename 'tblGLBudgetDetail.strAccountID', 'strAccountId' , 'COLUMN'
    END
END
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblGLCOAAdjustment]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intCOAAdjustmentId' AND OBJECT_ID = OBJECT_ID(N'tblGLCOAAdjustment')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intCOAAdjustmentID' AND OBJECT_ID = OBJECT_ID(N'tblGLCOAAdjustment'))
    BEGIN
        EXEC sp_rename 'tblGLCOAAdjustment.intCOAAdjustmentID', 'intCOAAdjustmentId' , 'COLUMN'
    END
END
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblGLCOAAdjustment]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'strCOAAdjustmentId' AND OBJECT_ID = OBJECT_ID(N'tblGLCOAAdjustment')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'strCOAAdjustmentID' AND OBJECT_ID = OBJECT_ID(N'tblGLCOAAdjustment'))
    BEGIN
        EXEC sp_rename 'tblGLCOAAdjustment.strCOAAdjustmentID', 'strCOAAdjustmentId' , 'COLUMN'
    END
END
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblGLCOAAdjustment]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intUserId' AND OBJECT_ID = OBJECT_ID(N'tblGLCOAAdjustment')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intUserID' AND OBJECT_ID = OBJECT_ID(N'tblGLCOAAdjustment'))
    BEGIN
        EXEC sp_rename 'tblGLCOAAdjustment.intUserID', 'intUserId' , 'COLUMN'
    END
END
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblGLCOAAdjustmentDetail]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intCOAAdjustmentDetailId' AND OBJECT_ID = OBJECT_ID(N'tblGLCOAAdjustmentDetail')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intCOAAdjustmentDetailID' AND OBJECT_ID = OBJECT_ID(N'tblGLCOAAdjustmentDetail'))
    BEGIN
        EXEC sp_rename 'tblGLCOAAdjustmentDetail.intCOAAdjustmentDetailID', 'intCOAAdjustmentDetailId' , 'COLUMN'
    END
END
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblGLCOAAdjustmentDetail]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intCOAAdjustmentId' AND OBJECT_ID = OBJECT_ID(N'tblGLCOAAdjustmentDetail')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intCOAAdjustmentID' AND OBJECT_ID = OBJECT_ID(N'tblGLCOAAdjustmentDetail'))
    BEGIN
        EXEC sp_rename 'tblGLCOAAdjustmentDetail.intCOAAdjustmentID', 'intCOAAdjustmentId' , 'COLUMN'
    END
END
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblGLCOAAdjustmentDetail]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intAccountId' AND OBJECT_ID = OBJECT_ID(N'tblGLCOAAdjustmentDetail')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intAccountID' AND OBJECT_ID = OBJECT_ID(N'tblGLCOAAdjustmentDetail'))
    BEGIN
        EXEC sp_rename 'tblGLCOAAdjustmentDetail.intAccountID', 'intAccountId' , 'COLUMN'
    END
END
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblGLCOAAdjustmentDetail]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intAccountGroupId' AND OBJECT_ID = OBJECT_ID(N'tblGLCOAAdjustmentDetail')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intAccountGroupID' AND OBJECT_ID = OBJECT_ID(N'tblGLCOAAdjustmentDetail'))
    BEGIN
        EXEC sp_rename 'tblGLCOAAdjustmentDetail.intAccountGroupID', 'intAccountGroupId' , 'COLUMN'
    END
END
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblGLCOACrossReference]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intCrossReferenceId' AND OBJECT_ID = OBJECT_ID(N'tblGLCOACrossReference')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intCrossReferenceID' AND OBJECT_ID = OBJECT_ID(N'tblGLCOACrossReference'))
    BEGIN
        EXEC sp_rename 'tblGLCOACrossReference.intCrossReferenceID', 'intCrossReferenceId' , 'COLUMN'
    END
END
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblGLCOACrossReference]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'inti21Id' AND OBJECT_ID = OBJECT_ID(N'tblGLCOACrossReference')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'inti21ID' AND OBJECT_ID = OBJECT_ID(N'tblGLCOACrossReference'))
    BEGIN
        EXEC sp_rename 'tblGLCOACrossReference.inti21ID', 'inti21Id' , 'COLUMN'
    END
END
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblGLCOACrossReference]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'stri21Id' AND OBJECT_ID = OBJECT_ID(N'tblGLCOACrossReference')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'stri21ID' AND OBJECT_ID = OBJECT_ID(N'tblGLCOACrossReference'))
    BEGIN
        EXEC sp_rename 'tblGLCOACrossReference.stri21ID', 'stri21Id' , 'COLUMN'
    END
END
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblGLCOACrossReference]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'strExternalId' AND OBJECT_ID = OBJECT_ID(N'tblGLCOACrossReference')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'strExternalID' AND OBJECT_ID = OBJECT_ID(N'tblGLCOACrossReference'))
    BEGIN
        EXEC sp_rename 'tblGLCOACrossReference.strExternalID', 'strExternalId' , 'COLUMN'
    END
END
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblGLCOACrossReference]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'strCurrentExternalId' AND OBJECT_ID = OBJECT_ID(N'tblGLCOACrossReference')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'strCurrentExternalID' AND OBJECT_ID = OBJECT_ID(N'tblGLCOACrossReference'))
    BEGIN
        EXEC sp_rename 'tblGLCOACrossReference.strCurrentExternalID', 'strCurrentExternalId' , 'COLUMN'
    END
END
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblGLCOACrossReference]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'strCompanyId' AND OBJECT_ID = OBJECT_ID(N'tblGLCOACrossReference')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'strCompanyID' AND OBJECT_ID = OBJECT_ID(N'tblGLCOACrossReference'))
    BEGIN
        EXEC sp_rename 'tblGLCOACrossReference.strCompanyID', 'strCompanyId' , 'COLUMN'
    END
END
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblGLCOACrossReference]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intLegacyReferenceId' AND OBJECT_ID = OBJECT_ID(N'tblGLCOACrossReference')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intLegacyReferenceID' AND OBJECT_ID = OBJECT_ID(N'tblGLCOACrossReference'))
    BEGIN
        EXEC sp_rename 'tblGLCOACrossReference.intLegacyReferenceID', 'intLegacyReferenceId' , 'COLUMN'
    END
END
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblGLCOAImportLog]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intImportLogId' AND OBJECT_ID = OBJECT_ID(N'tblGLCOAImportLog')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intImportLogID' AND OBJECT_ID = OBJECT_ID(N'tblGLCOAImportLog'))
    BEGIN
        EXEC sp_rename 'tblGLCOAImportLog.intImportLogID', 'intImportLogId' , 'COLUMN'
    END
END
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblGLCOAImportLog]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intUserId' AND OBJECT_ID = OBJECT_ID(N'tblGLCOAImportLog')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intUserID' AND OBJECT_ID = OBJECT_ID(N'tblGLCOAImportLog'))
    BEGIN
        EXEC sp_rename 'tblGLCOAImportLog.intUserID', 'intUserId' , 'COLUMN'
    END
END
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblGLCOAImportLogDetail]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intImportLogDetailId' AND OBJECT_ID = OBJECT_ID(N'tblGLCOAImportLogDetail')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intImportLogDetailID' AND OBJECT_ID = OBJECT_ID(N'tblGLCOAImportLogDetail'))
    BEGIN
        EXEC sp_rename 'tblGLCOAImportLogDetail.intImportLogDetailID', 'intImportLogDetailId' , 'COLUMN'
    END
END
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblGLCOAImportLogDetail]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intImportLogId' AND OBJECT_ID = OBJECT_ID(N'tblGLCOAImportLogDetail')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intImportLogID' AND OBJECT_ID = OBJECT_ID(N'tblGLCOAImportLogDetail'))
    BEGIN
        EXEC sp_rename 'tblGLCOAImportLogDetail.intImportLogID', 'intImportLogId' , 'COLUMN'
    END
END
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblGLCOAImportLogDetail]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'strJournalId' AND OBJECT_ID = OBJECT_ID(N'tblGLCOAImportLogDetail')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'strJournalID' AND OBJECT_ID = OBJECT_ID(N'tblGLCOAImportLogDetail'))
    BEGIN
        EXEC sp_rename 'tblGLCOAImportLogDetail.strJournalID', 'strJournalId' , 'COLUMN'
    END
END
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblGLCOATemplate]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intAccountTemplateId' AND OBJECT_ID = OBJECT_ID(N'tblGLCOATemplate')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intAccountTemplateID' AND OBJECT_ID = OBJECT_ID(N'tblGLCOATemplate'))
    BEGIN
        EXEC sp_rename 'tblGLCOATemplate.intAccountTemplateID', 'intAccountTemplateId' , 'COLUMN'
    END
END
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblGLCOATemplateDetail]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intAccountTemplateDetailId' AND OBJECT_ID = OBJECT_ID(N'tblGLCOATemplateDetail')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intAccountTemplateDetailID' AND OBJECT_ID = OBJECT_ID(N'tblGLCOATemplateDetail'))
    BEGIN
        EXEC sp_rename 'tblGLCOATemplateDetail.intAccountTemplateDetailID', 'intAccountTemplateDetailId' , 'COLUMN'
    END
END
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblGLCOATemplateDetail]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intAccountTemplateId' AND OBJECT_ID = OBJECT_ID(N'tblGLCOATemplateDetail')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intAccountTemplateID' AND OBJECT_ID = OBJECT_ID(N'tblGLCOATemplateDetail'))
    BEGIN
        EXEC sp_rename 'tblGLCOATemplateDetail.intAccountTemplateID', 'intAccountTemplateId' , 'COLUMN'
    END
END
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblGLCOATemplateDetail]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intAccountGroupId' AND OBJECT_ID = OBJECT_ID(N'tblGLCOATemplateDetail')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intAccountGroupID' AND OBJECT_ID = OBJECT_ID(N'tblGLCOATemplateDetail'))
    BEGIN
        EXEC sp_rename 'tblGLCOATemplateDetail.intAccountGroupID', 'intAccountGroupId' , 'COLUMN'
    END
END
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblGLCOATemplateDetail]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intAccountStructureId' AND OBJECT_ID = OBJECT_ID(N'tblGLCOATemplateDetail')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intAccountStructureID' AND OBJECT_ID = OBJECT_ID(N'tblGLCOATemplateDetail'))
    BEGIN
        EXEC sp_rename 'tblGLCOATemplateDetail.intAccountStructureID', 'intAccountStructureId' , 'COLUMN'
    END
END
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblGLCurrentFiscalYear]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'cntId' AND OBJECT_ID = OBJECT_ID(N'tblGLCurrentFiscalYear')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'cntID' AND OBJECT_ID = OBJECT_ID(N'tblGLCurrentFiscalYear'))
    BEGIN
        EXEC sp_rename 'tblGLCurrentFiscalYear.cntID', 'cntId' , 'COLUMN'
    END
END
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblGLCurrentFiscalYear]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intFiscalYearId' AND OBJECT_ID = OBJECT_ID(N'tblGLCurrentFiscalYear')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intFiscalYearID' AND OBJECT_ID = OBJECT_ID(N'tblGLCurrentFiscalYear'))
    BEGIN
        EXEC sp_rename 'tblGLCurrentFiscalYear.intFiscalYearID', 'intFiscalYearId' , 'COLUMN'
    END
END
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblGLDetail]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intGLDetailId' AND OBJECT_ID = OBJECT_ID(N'tblGLDetail')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intGLDetailID' AND OBJECT_ID = OBJECT_ID(N'tblGLDetail'))
    BEGIN
        EXEC sp_rename 'tblGLDetail.intGLDetailID', 'intGLDetailId' , 'COLUMN'
    END
END
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblGLDetail]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'strBatchId' AND OBJECT_ID = OBJECT_ID(N'tblGLDetail')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'strBatchID' AND OBJECT_ID = OBJECT_ID(N'tblGLDetail'))
    BEGIN
        EXEC sp_rename 'tblGLDetail.strBatchID', 'strBatchId' , 'COLUMN'
    END
END
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblGLDetail]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intAccountId' AND OBJECT_ID = OBJECT_ID(N'tblGLDetail')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intAccountID' AND OBJECT_ID = OBJECT_ID(N'tblGLDetail'))
    BEGIN
        EXEC sp_rename 'tblGLDetail.intAccountID', 'intAccountId' , 'COLUMN'
    END
END
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblGLDetail]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'strTransactionId' AND OBJECT_ID = OBJECT_ID(N'tblGLDetail')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'strTransactionID' AND OBJECT_ID = OBJECT_ID(N'tblGLDetail'))
    BEGIN
        EXEC sp_rename 'tblGLDetail.strTransactionID', 'strTransactionId' , 'COLUMN'
    END
END
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblGLDetail]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'strJobId' AND OBJECT_ID = OBJECT_ID(N'tblGLDetail')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'strJobID' AND OBJECT_ID = OBJECT_ID(N'tblGLDetail'))
    BEGIN
        EXEC sp_rename 'tblGLDetail.strJobID', 'strJobId' , 'COLUMN'
    END
END
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblGLDetail]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intCurrencyId' AND OBJECT_ID = OBJECT_ID(N'tblGLDetail')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intCurrencyID' AND OBJECT_ID = OBJECT_ID(N'tblGLDetail'))
    BEGIN
        EXEC sp_rename 'tblGLDetail.intCurrencyID', 'intCurrencyId' , 'COLUMN'
    END
END
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblGLDetail]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'strProductId' AND OBJECT_ID = OBJECT_ID(N'tblGLDetail')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'strProductID' AND OBJECT_ID = OBJECT_ID(N'tblGLDetail'))
    BEGIN
        EXEC sp_rename 'tblGLDetail.strProductID', 'strProductId' , 'COLUMN'
    END
END
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblGLDetail]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'strWarehouseId' AND OBJECT_ID = OBJECT_ID(N'tblGLDetail')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'strWarehouseID' AND OBJECT_ID = OBJECT_ID(N'tblGLDetail'))
    BEGIN
        EXEC sp_rename 'tblGLDetail.strWarehouseID', 'strWarehouseId' , 'COLUMN'
    END
END
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblGLDetail]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intUserId' AND OBJECT_ID = OBJECT_ID(N'tblGLDetail')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intUserID' AND OBJECT_ID = OBJECT_ID(N'tblGLDetail'))
    BEGIN
        EXEC sp_rename 'tblGLDetail.intUserID', 'intUserId' , 'COLUMN'
    END
END
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblGLDetailRecap]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intGLDetailId' AND OBJECT_ID = OBJECT_ID(N'tblGLDetailRecap')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intGLDetailID' AND OBJECT_ID = OBJECT_ID(N'tblGLDetailRecap'))
    BEGIN
        EXEC sp_rename 'tblGLDetailRecap.intGLDetailID', 'intGLDetailId' , 'COLUMN'
    END
END
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblGLDetailRecap]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'strTransactionId' AND OBJECT_ID = OBJECT_ID(N'tblGLDetailRecap')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'strTransactionID' AND OBJECT_ID = OBJECT_ID(N'tblGLDetailRecap'))
    BEGIN
        EXEC sp_rename 'tblGLDetailRecap.strTransactionID', 'strTransactionId' , 'COLUMN'
    END
END
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblGLDetailRecap]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intTransactionId' AND OBJECT_ID = OBJECT_ID(N'tblGLDetailRecap')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intTransactionID' AND OBJECT_ID = OBJECT_ID(N'tblGLDetailRecap'))
    BEGIN
        EXEC sp_rename 'tblGLDetailRecap.intTransactionID', 'intTransactionId' , 'COLUMN'
    END
END
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblGLDetailRecap]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'strBatchId' AND OBJECT_ID = OBJECT_ID(N'tblGLDetailRecap')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'strBatchID' AND OBJECT_ID = OBJECT_ID(N'tblGLDetailRecap'))
    BEGIN
        EXEC sp_rename 'tblGLDetailRecap.strBatchID', 'strBatchId' , 'COLUMN'
    END
END
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblGLDetailRecap]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intAccountId' AND OBJECT_ID = OBJECT_ID(N'tblGLDetailRecap')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intAccountID' AND OBJECT_ID = OBJECT_ID(N'tblGLDetailRecap'))
    BEGIN
        EXEC sp_rename 'tblGLDetailRecap.intAccountID', 'intAccountId' , 'COLUMN'
    END
END
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblGLDetailRecap]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'strJobId' AND OBJECT_ID = OBJECT_ID(N'tblGLDetailRecap')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'strJobID' AND OBJECT_ID = OBJECT_ID(N'tblGLDetailRecap'))
    BEGIN
        EXEC sp_rename 'tblGLDetailRecap.strJobID', 'strJobId' , 'COLUMN'
    END
END
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblGLDetailRecap]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intCurrencyId' AND OBJECT_ID = OBJECT_ID(N'tblGLDetailRecap')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intCurrencyID' AND OBJECT_ID = OBJECT_ID(N'tblGLDetailRecap'))
    BEGIN
        EXEC sp_rename 'tblGLDetailRecap.intCurrencyID', 'intCurrencyId' , 'COLUMN'
    END
END
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblGLDetailRecap]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intUserId' AND OBJECT_ID = OBJECT_ID(N'tblGLDetailRecap')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intUserID' AND OBJECT_ID = OBJECT_ID(N'tblGLDetailRecap'))
    BEGIN
        EXEC sp_rename 'tblGLDetailRecap.intUserID', 'intUserId' , 'COLUMN'
    END
END
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblGLFiscalYear]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intFiscalYearId' AND OBJECT_ID = OBJECT_ID(N'tblGLFiscalYear')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intFiscalYearID' AND OBJECT_ID = OBJECT_ID(N'tblGLFiscalYear'))
    BEGIN
        EXEC sp_rename 'tblGLFiscalYear.intFiscalYearID', 'intFiscalYearId' , 'COLUMN'
    END
END
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblGLFiscalYearPeriod]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intGLFiscalYearPeriodId' AND OBJECT_ID = OBJECT_ID(N'tblGLFiscalYearPeriod')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intGLFiscalYearPeriodID' AND OBJECT_ID = OBJECT_ID(N'tblGLFiscalYearPeriod'))
    BEGIN
        EXEC sp_rename 'tblGLFiscalYearPeriod.intGLFiscalYearPeriodID', 'intGLFiscalYearPeriodId' , 'COLUMN'
    END
END
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblGLFiscalYearPeriod]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intFiscalYearId' AND OBJECT_ID = OBJECT_ID(N'tblGLFiscalYearPeriod')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intFiscalYearID' AND OBJECT_ID = OBJECT_ID(N'tblGLFiscalYearPeriod'))
    BEGIN
        EXEC sp_rename 'tblGLFiscalYearPeriod.intFiscalYearID', 'intFiscalYearId' , 'COLUMN'
    END
END
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblGLJournal]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intJournalId' AND OBJECT_ID = OBJECT_ID(N'tblGLJournal')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intJournalID' AND OBJECT_ID = OBJECT_ID(N'tblGLJournal'))
    BEGIN
        EXEC sp_rename 'tblGLJournal.intJournalID', 'intJournalId' , 'COLUMN'
    END
END
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblGLJournal]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'strJournalId' AND OBJECT_ID = OBJECT_ID(N'tblGLJournal')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'strJournalID' AND OBJECT_ID = OBJECT_ID(N'tblGLJournal'))
    BEGIN
        EXEC sp_rename 'tblGLJournal.strJournalID', 'strJournalId' , 'COLUMN'
    END
END
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblGLJournal]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intCurrencyId' AND OBJECT_ID = OBJECT_ID(N'tblGLJournal')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intCurrencyID' AND OBJECT_ID = OBJECT_ID(N'tblGLJournal'))
    BEGIN
        EXEC sp_rename 'tblGLJournal.intCurrencyID', 'intCurrencyId' , 'COLUMN'
    END
END
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblGLJournal]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intUserId' AND OBJECT_ID = OBJECT_ID(N'tblGLJournal')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intUserID' AND OBJECT_ID = OBJECT_ID(N'tblGLJournal'))
    BEGIN
        EXEC sp_rename 'tblGLJournal.intUserID', 'intUserId' , 'COLUMN'
    END
END
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblGLJournal]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'strSourceId' AND OBJECT_ID = OBJECT_ID(N'tblGLJournal')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'strSourceID' AND OBJECT_ID = OBJECT_ID(N'tblGLJournal'))
    BEGIN
        EXEC sp_rename 'tblGLJournal.strSourceID', 'strSourceId' , 'COLUMN'
    END
END
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblGLJournalDetail]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intJournalDetailId' AND OBJECT_ID = OBJECT_ID(N'tblGLJournalDetail')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intJournalDetailID' AND OBJECT_ID = OBJECT_ID(N'tblGLJournalDetail'))
    BEGIN
        EXEC sp_rename 'tblGLJournalDetail.intJournalDetailID', 'intJournalDetailId' , 'COLUMN'
    END
END
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblGLJournalDetail]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intJournalId' AND OBJECT_ID = OBJECT_ID(N'tblGLJournalDetail')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intJournalID' AND OBJECT_ID = OBJECT_ID(N'tblGLJournalDetail'))
    BEGIN
        EXEC sp_rename 'tblGLJournalDetail.intJournalID', 'intJournalId' , 'COLUMN'
    END
END
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblGLJournalDetail]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intAccountId' AND OBJECT_ID = OBJECT_ID(N'tblGLJournalDetail')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intAccountID' AND OBJECT_ID = OBJECT_ID(N'tblGLJournalDetail'))
    BEGIN
        EXEC sp_rename 'tblGLJournalDetail.intAccountID', 'intAccountId' , 'COLUMN'
    END
END
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblGLJournalRecurring]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intJournalRecurringId' AND OBJECT_ID = OBJECT_ID(N'tblGLJournalRecurring')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intJournalRecurringID' AND OBJECT_ID = OBJECT_ID(N'tblGLJournalRecurring'))
    BEGIN
        EXEC sp_rename 'tblGLJournalRecurring.intJournalRecurringID', 'intJournalRecurringId' , 'COLUMN'
    END
END
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblGLJournalRecurring]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'strJournalRecurringId' AND OBJECT_ID = OBJECT_ID(N'tblGLJournalRecurring')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'strJournalRecurringID' AND OBJECT_ID = OBJECT_ID(N'tblGLJournalRecurring'))
    BEGIN
        EXEC sp_rename 'tblGLJournalRecurring.strJournalRecurringID', 'strJournalRecurringId' , 'COLUMN'
    END
END
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblGLJournalRecurring]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'strStoreId' AND OBJECT_ID = OBJECT_ID(N'tblGLJournalRecurring')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'strStoreID' AND OBJECT_ID = OBJECT_ID(N'tblGLJournalRecurring'))
    BEGIN
        EXEC sp_rename 'tblGLJournalRecurring.strStoreID', 'strStoreId' , 'COLUMN'
    END
END
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblGLJournalRecurring]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intCurrencyId' AND OBJECT_ID = OBJECT_ID(N'tblGLJournalRecurring')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intCurrencyID' AND OBJECT_ID = OBJECT_ID(N'tblGLJournalRecurring'))
    BEGIN
        EXEC sp_rename 'tblGLJournalRecurring.intCurrencyID', 'intCurrencyId' , 'COLUMN'
    END
END
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblGLJournalRecurringDetail]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intJournalRecurringDetailId' AND OBJECT_ID = OBJECT_ID(N'tblGLJournalRecurringDetail')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intJournalRecurringDetailID' AND OBJECT_ID = OBJECT_ID(N'tblGLJournalRecurringDetail'))
    BEGIN
        EXEC sp_rename 'tblGLJournalRecurringDetail.intJournalRecurringDetailID', 'intJournalRecurringDetailId' , 'COLUMN'
    END
END
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblGLJournalRecurringDetail]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intJournalRecurringId' AND OBJECT_ID = OBJECT_ID(N'tblGLJournalRecurringDetail')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intJournalRecurringID' AND OBJECT_ID = OBJECT_ID(N'tblGLJournalRecurringDetail'))
    BEGIN
        EXEC sp_rename 'tblGLJournalRecurringDetail.intJournalRecurringID', 'intJournalRecurringId' , 'COLUMN'
    END
END
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblGLJournalRecurringDetail]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intAccountId' AND OBJECT_ID = OBJECT_ID(N'tblGLJournalRecurringDetail')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intAccountID' AND OBJECT_ID = OBJECT_ID(N'tblGLJournalRecurringDetail'))
    BEGIN
        EXEC sp_rename 'tblGLJournalRecurringDetail.intAccountID', 'intAccountId' , 'COLUMN'
    END
END
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblGLJournalRecurringDetail]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intCurrencyId' AND OBJECT_ID = OBJECT_ID(N'tblGLJournalRecurringDetail')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intCurrencyID' AND OBJECT_ID = OBJECT_ID(N'tblGLJournalRecurringDetail'))
    BEGIN
        EXEC sp_rename 'tblGLJournalRecurringDetail.intCurrencyID', 'intCurrencyId' , 'COLUMN'
    END
END
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblGLJournalRecurringDetail]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'strNameId' AND OBJECT_ID = OBJECT_ID(N'tblGLJournalRecurringDetail')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'strNameID' AND OBJECT_ID = OBJECT_ID(N'tblGLJournalRecurringDetail'))
    BEGIN
        EXEC sp_rename 'tblGLJournalRecurringDetail.strNameID', 'strNameId' , 'COLUMN'
    END
END
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblGLJournalRecurringDetail]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intJobId' AND OBJECT_ID = OBJECT_ID(N'tblGLJournalRecurringDetail')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intJobID' AND OBJECT_ID = OBJECT_ID(N'tblGLJournalRecurringDetail'))
    BEGIN
        EXEC sp_rename 'tblGLJournalRecurringDetail.intJobID', 'intJobId' , 'COLUMN'
    END
END
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblGLModuleList]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'cntId' AND OBJECT_ID = OBJECT_ID(N'tblGLModuleList')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'cntID' AND OBJECT_ID = OBJECT_ID(N'tblGLModuleList'))
    BEGIN
        EXEC sp_rename 'tblGLModuleList.cntID', 'cntId' , 'COLUMN'
    END
END
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblGLPostHistory]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intPostHistoryId' AND OBJECT_ID = OBJECT_ID(N'tblGLPostHistory')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intPostHistoryID' AND OBJECT_ID = OBJECT_ID(N'tblGLPostHistory'))
    BEGIN
        EXEC sp_rename 'tblGLPostHistory.intPostHistoryID', 'intPostHistoryId' , 'COLUMN'
    END
END
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblGLPostHistory]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'strBatchId' AND OBJECT_ID = OBJECT_ID(N'tblGLPostHistory')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'strBatchID' AND OBJECT_ID = OBJECT_ID(N'tblGLPostHistory'))
    BEGIN
        EXEC sp_rename 'tblGLPostHistory.strBatchID', 'strBatchId' , 'COLUMN'
    END
END
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblGLPostRecap]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intGLDetailId' AND OBJECT_ID = OBJECT_ID(N'tblGLPostRecap')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intGLDetailID' AND OBJECT_ID = OBJECT_ID(N'tblGLPostRecap'))
    BEGIN
        EXEC sp_rename 'tblGLPostRecap.intGLDetailID', 'intGLDetailId' , 'COLUMN'
    END
END
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblGLPostRecap]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'strTransactionId' AND OBJECT_ID = OBJECT_ID(N'tblGLPostRecap')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'strTransactionID' AND OBJECT_ID = OBJECT_ID(N'tblGLPostRecap'))
    BEGIN
        EXEC sp_rename 'tblGLPostRecap.strTransactionID', 'strTransactionId' , 'COLUMN'
    END
END
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblGLPostRecap]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intTransactionId' AND OBJECT_ID = OBJECT_ID(N'tblGLPostRecap')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intTransactionID' AND OBJECT_ID = OBJECT_ID(N'tblGLPostRecap'))
    BEGIN
        EXEC sp_rename 'tblGLPostRecap.intTransactionID', 'intTransactionId' , 'COLUMN'
    END
END
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblGLPostRecap]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'strBatchId' AND OBJECT_ID = OBJECT_ID(N'tblGLPostRecap')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'strBatchID' AND OBJECT_ID = OBJECT_ID(N'tblGLPostRecap'))
    BEGIN
        EXEC sp_rename 'tblGLPostRecap.strBatchID', 'strBatchId' , 'COLUMN'
    END
END
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblGLPostRecap]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intAccountId' AND OBJECT_ID = OBJECT_ID(N'tblGLPostRecap')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intAccountID' AND OBJECT_ID = OBJECT_ID(N'tblGLPostRecap'))
    BEGIN
        EXEC sp_rename 'tblGLPostRecap.intAccountID', 'intAccountId' , 'COLUMN'
    END
END
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblGLPostRecap]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'strAccountId' AND OBJECT_ID = OBJECT_ID(N'tblGLPostRecap')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'strAccountID' AND OBJECT_ID = OBJECT_ID(N'tblGLPostRecap'))
    BEGIN
        EXEC sp_rename 'tblGLPostRecap.strAccountID', 'strAccountId' , 'COLUMN'
    END
END
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblGLPostRecap]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'strJobId' AND OBJECT_ID = OBJECT_ID(N'tblGLPostRecap')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'strJobID' AND OBJECT_ID = OBJECT_ID(N'tblGLPostRecap'))
    BEGIN
        EXEC sp_rename 'tblGLPostRecap.strJobID', 'strJobId' , 'COLUMN'
    END
END
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblGLPostRecap]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intCurrencyId' AND OBJECT_ID = OBJECT_ID(N'tblGLPostRecap')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intCurrencyID' AND OBJECT_ID = OBJECT_ID(N'tblGLPostRecap'))
    BEGIN
        EXEC sp_rename 'tblGLPostRecap.intCurrencyID', 'intCurrencyId' , 'COLUMN'
    END
END
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblGLPostRecap]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intUserId' AND OBJECT_ID = OBJECT_ID(N'tblGLPostRecap')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intUserID' AND OBJECT_ID = OBJECT_ID(N'tblGLPostRecap'))
    BEGIN
        EXEC sp_rename 'tblGLPostRecap.intUserID', 'intUserId' , 'COLUMN'
    END
END
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblGLPostResult]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'strBatchId' AND OBJECT_ID = OBJECT_ID(N'tblGLPostResult')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'strBatchID' AND OBJECT_ID = OBJECT_ID(N'tblGLPostResult'))
    BEGIN
        EXEC sp_rename 'tblGLPostResult.strBatchID', 'strBatchId' , 'COLUMN'
    END
END
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblGLPostResult]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intTransactionId' AND OBJECT_ID = OBJECT_ID(N'tblGLPostResult')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intTransactionID' AND OBJECT_ID = OBJECT_ID(N'tblGLPostResult'))
    BEGIN
        EXEC sp_rename 'tblGLPostResult.intTransactionID', 'intTransactionId' , 'COLUMN'
    END
END
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblGLPostResult]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'strTransactionId' AND OBJECT_ID = OBJECT_ID(N'tblGLPostResult')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'strTransactionID' AND OBJECT_ID = OBJECT_ID(N'tblGLPostResult'))
    BEGIN
        EXEC sp_rename 'tblGLPostResult.strTransactionID', 'strTransactionId' , 'COLUMN'
    END
END
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblGLPostResult]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intUserId' AND OBJECT_ID = OBJECT_ID(N'tblGLPostResult')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intUserID' AND OBJECT_ID = OBJECT_ID(N'tblGLPostResult'))
    BEGIN
        EXEC sp_rename 'tblGLPostResult.intUserID', 'intUserId' , 'COLUMN'
    END
END
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblGLRecurringHistory]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intRecurringHistoryId' AND OBJECT_ID = OBJECT_ID(N'tblGLRecurringHistory')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intRecurringHistoryID' AND OBJECT_ID = OBJECT_ID(N'tblGLRecurringHistory'))
    BEGIN
        EXEC sp_rename 'tblGLRecurringHistory.intRecurringHistoryID', 'intRecurringHistoryId' , 'COLUMN'
    END
END
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblGLRecurringHistory]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'strJournalRecurringId' AND OBJECT_ID = OBJECT_ID(N'tblGLRecurringHistory')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'strJournalRecurringID' AND OBJECT_ID = OBJECT_ID(N'tblGLRecurringHistory'))
    BEGIN
        EXEC sp_rename 'tblGLRecurringHistory.strJournalRecurringID', 'strJournalRecurringId' , 'COLUMN'
    END
END
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblGLRecurringHistory]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'strJournalId' AND OBJECT_ID = OBJECT_ID(N'tblGLRecurringHistory')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'strJournalID' AND OBJECT_ID = OBJECT_ID(N'tblGLRecurringHistory'))
    BEGIN
        EXEC sp_rename 'tblGLRecurringHistory.strJournalID', 'strJournalId' , 'COLUMN'
    END
END
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblGLSummary]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intSummaryId' AND OBJECT_ID = OBJECT_ID(N'tblGLSummary')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intSummaryID' AND OBJECT_ID = OBJECT_ID(N'tblGLSummary'))
    BEGIN
        EXEC sp_rename 'tblGLSummary.intSummaryID', 'intSummaryId' , 'COLUMN'
    END
END
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblGLSummary]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intAccountId' AND OBJECT_ID = OBJECT_ID(N'tblGLSummary')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intAccountID' AND OBJECT_ID = OBJECT_ID(N'tblGLSummary'))
    BEGIN
        EXEC sp_rename 'tblGLSummary.intAccountID', 'intAccountId' , 'COLUMN'
    END
END
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblGLTempAccount]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'cntId' AND OBJECT_ID = OBJECT_ID(N'tblGLTempAccount')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'cntID' AND OBJECT_ID = OBJECT_ID(N'tblGLTempAccount'))
    BEGIN
        EXEC sp_rename 'tblGLTempAccount.cntID', 'cntId' , 'COLUMN'
    END
END
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblGLTempAccount]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'strAccountId' AND OBJECT_ID = OBJECT_ID(N'tblGLTempAccount')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'strAccountID' AND OBJECT_ID = OBJECT_ID(N'tblGLTempAccount'))
    BEGIN
        EXEC sp_rename 'tblGLTempAccount.strAccountID', 'strAccountId' , 'COLUMN'
    END
END
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblGLTempAccount]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intAccountGroupId' AND OBJECT_ID = OBJECT_ID(N'tblGLTempAccount')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intAccountGroupID' AND OBJECT_ID = OBJECT_ID(N'tblGLTempAccount'))
    BEGIN
        EXEC sp_rename 'tblGLTempAccount.intAccountGroupID', 'intAccountGroupId' , 'COLUMN'
    END
END
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblGLTempAccount]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'strAccountSegmentId' AND OBJECT_ID = OBJECT_ID(N'tblGLTempAccount')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'strAccountSegmentID' AND OBJECT_ID = OBJECT_ID(N'tblGLTempAccount'))
    BEGIN
        EXEC sp_rename 'tblGLTempAccount.strAccountSegmentID', 'strAccountSegmentId' , 'COLUMN'
    END
END
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblGLTempAccount]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intAccountUnitId' AND OBJECT_ID = OBJECT_ID(N'tblGLTempAccount')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intAccountUnitID' AND OBJECT_ID = OBJECT_ID(N'tblGLTempAccount'))
    BEGIN
        EXEC sp_rename 'tblGLTempAccount.intAccountUnitID', 'intAccountUnitId' , 'COLUMN'
    END
END
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblGLTempAccount]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intUserId' AND OBJECT_ID = OBJECT_ID(N'tblGLTempAccount')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intUserID' AND OBJECT_ID = OBJECT_ID(N'tblGLTempAccount'))
    BEGIN
        EXEC sp_rename 'tblGLTempAccount.intUserID', 'intUserId' , 'COLUMN'
    END
END
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblGLTempAccountToBuild]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'cntId' AND OBJECT_ID = OBJECT_ID(N'tblGLTempAccountToBuild')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'cntID' AND OBJECT_ID = OBJECT_ID(N'tblGLTempAccountToBuild'))
    BEGIN
        EXEC sp_rename 'tblGLTempAccountToBuild.cntID', 'cntId' , 'COLUMN'
    END
END
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblGLTempAccountToBuild]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intAccountSegmentId' AND OBJECT_ID = OBJECT_ID(N'tblGLTempAccountToBuild')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intAccountSegmentID' AND OBJECT_ID = OBJECT_ID(N'tblGLTempAccountToBuild'))
    BEGIN
        EXEC sp_rename 'tblGLTempAccountToBuild.intAccountSegmentID', 'intAccountSegmentId' , 'COLUMN'
    END
END
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblGLTempAccountToBuild]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intUserId' AND OBJECT_ID = OBJECT_ID(N'tblGLTempAccountToBuild')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intUserID' AND OBJECT_ID = OBJECT_ID(N'tblGLTempAccountToBuild'))
    BEGIN
        EXEC sp_rename 'tblGLTempAccountToBuild.intUserID', 'intUserId' , 'COLUMN'
    END
END
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblGLTempAccountToBuild]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intUserId' AND OBJECT_ID = OBJECT_ID(N'tblGLTempAccountToBuild')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intUserID' AND OBJECT_ID = OBJECT_ID(N'tblGLTempAccountToBuild'))
    BEGIN
        EXEC sp_rename 'tblGLTempAccountToBuild.intUserID', 'intUserId' , 'COLUMN'
    END
END
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblGLCOAAdjustment]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'ysnPosted' AND OBJECT_ID = OBJECT_ID(N'tblGLCOAAdjustment')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'ysnposted' AND OBJECT_ID = OBJECT_ID(N'tblGLCOAAdjustment'))
    BEGIN
        EXEC sp_rename 'tblGLCOAAdjustment.ysnposted', 'ysnPosted' , 'COLUMN'
    END
END
GO



-- AR

PRINT N'BEGIN Rename for tblEntities'
GO
IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblEntities]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE  OBJECT_ID = OBJECT_ID(N'tblEntity'))
    BEGIN
        EXEC sp_rename 'tblEntities', 'tblEntity'
    END
END
GO
PRINT N'END	 Rename for tblEntities'
GO

PRINT N'Begin Rename for tblEntityLocations'
GO
IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblEntityLocations]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE  OBJECT_ID = OBJECT_ID(N'tblEntityLocation'))
    BEGIN
        EXEC sp_rename 'tblEntityLocations', 'tblEntityLocation'
    END
END
GO
PRINT N'END	 Rename for tblEntityLocations'
GO

PRINT N'BEGIN Rename for tblEntityTypes'
GO
IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblEntityTypes]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE  OBJECT_ID = OBJECT_ID(N'tblEntityType'))
    BEGIN
        EXEC sp_rename 'tblEntityTypes', 'tblEntityType'
    END
END
GO
PRINT N'END	 Rename for tblEntityLocations'
GO


-- AP
IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblAPVendor]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intDefaultLocationId' AND OBJECT_ID = OBJECT_ID(N'tblAPVendor')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intEntityLocationId' AND OBJECT_ID = OBJECT_ID(N'tblAPVendor'))
    BEGIN
        EXEC sp_rename 'tblAPVendor.intEntityLocationId', 'intDefaultLocationId' , 'COLUMN'
    END

	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intDefaultContactId' AND OBJECT_ID = OBJECT_ID(N'tblAPVendor')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intEntityContactId' AND OBJECT_ID = OBJECT_ID(N'tblAPVendor'))
    BEGIN
        EXEC sp_rename 'tblAPVendor.intEntityContactId', 'intDefaultContactId' , 'COLUMN'
    END
END

GO
