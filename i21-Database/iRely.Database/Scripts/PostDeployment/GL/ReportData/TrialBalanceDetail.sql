/*
--------------------------------------------------------------------------------------
Author				: Trajano, Jeffrey
Date Last Modified	: 9/22/2015
Reason Modified     : to show accounts with no activity
Description			: Updates Report Data source to sp. Remove options.
--------------------------------------------------------------------------------------
*/
GO
BEGIN -- Trial Balance Detail Report
PRINT 'Begin updating Trial Balance Detail Report'
DECLARE @TBReportId INT
DECLARE @GLReportId INT

SELECT TOP 1 @TBReportId = intReportId FROM tblRMReport WHERE strName = 'Trial Balance Detail' and strGroup = 'General Ledger' 
SELECT TOP 1 @GLReportId =intReportId FROM tblRMReport WHERE strName like 'General Ledger by Account ID Detail'  and strGroup = 'General Ledger' 

DELETE FROM [tblRMOption] WHERE strName = 'Include Audit Adjustment' and intReportId = @TBReportId
DELETE FROM [tblRMDefaultOption] where intReportId = @TBReportId and strName = 'Include Audit Adjustment'
DELETE FROM tblRMSort WHERE intReportId = @TBReportId 
DELETE FROM tblRMDefaultSort WHERE intReportId = @TBReportId

IF NOT EXISTS(SELECT TOP 1 1 FROM [tblRMCriteriaFieldSelection] WHERE [strName] = 'Include Audit Adjustment')

INSERT INTO [dbo].[tblRMCriteriaFieldSelection]
           ([strName]
           ,[intConnectionId]
           ,[ysnDistinct]
           ,[strSource]
           ,[intFieldSourceType]
           ,[intConcurrencyId])
     VALUES
           ('Include Audit Adjustment',1,0,'Yes,No',3,1)


IF NOT EXISTS(SELECT TOP 1 1 FROM tblRMCriteriaField WHERE intReportId = @TBReportId and strFieldName = 'ysnIncludeAuditAdjustment')
INSERT INTO [dbo].[tblRMCriteriaField]
           ([intReportId]
           ,[intCriteriaFieldSelectionId]
           ,[strFieldName]
           ,[strDataType]
           ,[strDescription]
           ,[strConditions]
           ,[ysnIsRequired]
           ,[ysnShow]
           ,[ysnAllowSort]
           ,[ysnEditCondition]
           ,[intConcurrencyId])
     VALUES
           (@TBReportId
           ,(SELECT TOP 1 intCriteriaFieldSelectionId FROM [tblRMCriteriaFieldSelection] WHERE strName = 'Include Audit Adjustment')
           ,'ysnIncludeAuditAdjustment','String','Include Audit Adjustment','Equal To',1,1,0,1,1)

DECLARE @GLReportDrillDown VARCHAR(MAX) =  '[{"Control":"labelEx1","DrillThroughType":0,"Name":"General Ledger by Account ID Detail","DrillThroughFilterType":0,"Filters":null,"id":null},{"Control":"labelEx2","DrillThroughType":0,"Name":"General Ledger by Account ID Detail","DrillThroughFilterType":0,"Filters":null,"id":null}]' 
DECLARE @GLReportDataSource VARCHAR(MAX) = 'EXEC [dbo].[uspGLGetTrialBalanceDetailReport]'

--UPDATE THE DRILL DOWN
UPDATE o SET strSettings = @GLReportDrillDown, ysnEnable = 0, ysnShow = 0
FROM tblRMOption o INNER join tblRMReport r on o.intReportId = r.intReportId
WHERE r.intReportId = @TBReportId and o.strName ='General Ledger by Account ID Detail'

UPDATE o SET strSettings = @GLReportDrillDown, ysnEnable = 0, ysnShow = 0
FROM tblRMDefaultOption o INNER join tblRMReport r on o.intReportId = r.intReportId
WHERE r.intReportId = @TBReportId and o.strName ='General Ledger by Account ID Detail'
--UPDATE THE DATASOURCE
UPDATE d SET strQuery = @GLReportDataSource,intDataSourceType = 1
FROM tblRMDatasource d join tblRMReport r on d.intReportId = r.intReportId
WHERE r.intReportId = @TBReportId

-- COPY GL DETAIL REPORT SORTING
INSERT INTO tblRMSort (strSortField,intReportId,intSortDirection,intUserId, ysnDefault,ysnCanned,ysnRequired,intSortConcurrencyId)
	SELECT strSortField,@TBReportId,intSortDirection,intUserId,ysnDefault,ysnCanned,ysnRequired,intSortConcurrencyId FROM tblRMSort WHERE intReportId = @GLReportId
INSERT INTO tblRMDefaultSort (strSortField,intReportId,intSortDirection,intUserId, ysnCanned,ysnRequired,intSortConcurrencyId)
	SELECT strSortField,@TBReportId,intSortDirection,intUserId,ysnCanned,ysnRequired,intSortConcurrencyId FROM tblRMDefaultSort WHERE intReportId = @GLReportId

PRINT 'Finish updating Trial Balance Detail Report'
END
GO

