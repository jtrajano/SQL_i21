﻿/*
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
DECLARE @GLReportId INT
SELECT @GLReportId = intReportId FROM tblRMReport WHERE strName = 'Trial Balance Detail' and strGroup = 'General Ledger' 

DELETE FROM [tblRMOption] WHERE strName = 'Include Audit Adjustment' and intReportId = @GLReportId
DELETE FROM [tblRMDefaultOption] where intReportId = @GLReportId and strName = 'Include Audit Adjustment'
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


IF NOT EXISTS(SELECT TOP 1 1 FROM tblRMCriteriaField WHERE intReportId = @GLReportId and strFieldName = 'ysnIncludeAuditAdjustment')
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
           (@GLReportId
           ,(SELECT TOP 1 intCriteriaFieldSelectionId FROM [tblRMCriteriaFieldSelection] WHERE strName = 'Include Audit Adjustment')
           ,'ysnIncludeAuditAdjustment','String','Include Audit Adjustment','Equal To',1,1,0,1,1)

DECLARE @GLReportDrillDown VARCHAR(MAX) =  '[{"Control":"labelEx1","DrillThroughType":0,"Name":"General Ledger by Account ID Detail","DrillThroughFilterType":0,"Filters":null,"id":null},{"Control":"labelEx2","DrillThroughType":0,"Name":"General Ledger by Account ID Detail","DrillThroughFilterType":0,"Filters":null,"id":null}]' 
DECLARE @GLReportDataSource VARCHAR(MAX) = 'EXEC [dbo].[uspGLGetTrialBalanceDetailReport]'

--UPDATE THE DRILL DOWN
UPDATE o SET strSettings = @GLReportDrillDown, ysnEnable = 0, ysnShow = 0
from tblRMOption o INNER join tblRMReport r on o.intReportId = r.intReportId
where r.intReportId = @GLReportId and o.strName ='General Ledger by Account ID Detail'

UPDATE o SET strSettings = @GLReportDrillDown, ysnEnable = 0, ysnShow = 0
from tblRMDefaultOption o INNER join tblRMReport r on o.intReportId = r.intReportId
where r.intReportId = @GLReportId and o.strName ='General Ledger by Account ID Detail'
--UPDATE THE DATASOURCE
UPDATE d SET strQuery = @GLReportDataSource,intDataSourceType = 1
from tblRMDatasource d join tblRMReport r on d.intReportId = r.intReportId
where r.intReportId = @GLReportId


PRINT 'Finish updating Trial Balance Detail Report'
END
GO

