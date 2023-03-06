GO
PRINT '*** Start Updating strTransactionType on tblSMAuditLog ***'
GO

UPDATE tblSMAuditLog 
SET	tblSMAuditLog.strTransactionType = CASE WHEN (CHARINDEX('i21', tblSMAuditLog.strTransactionType) > 0)
                            THEN REPLACE(tblSMAuditLog.strTransactionType, 'i21', 'SystemManager')
                            ELSE REPLACE(tblSMAuditLog.strTransactionType, 'GlobalComponentEngine', 'SystemManager') END
FROM tblSMAuditLog AS tblSMAuditLog
WHERE tblSMAuditLog.strTransactionType LIKE '%i21%'
	OR tblSMAuditLog.strTransactionType LIKE '%GlobalComponentEngine%'

PRINT '*** End Updating strTransactionType on tblSMAuditLog ***'
GO

PRINT '*** Start Updating strScreen on tblSMComment ***'
GO

UPDATE tblSMComment 
SET	tblSMComment.strScreen = CASE WHEN (CHARINDEX('i21', tblSMComment.strScreen) > 0)
                            THEN REPLACE(tblSMComment.strScreen, 'i21', 'SystemManager')
                            ELSE REPLACE(tblSMComment.strScreen, 'GlobalComponentEngine', 'SystemManager') END
FROM tblSMComment AS tblSMComment
WHERE tblSMComment.strScreen LIKE '%i21%'
	OR tblSMComment.strScreen LIKE '%GlobalComponentEngine%'

PRINT '*** End Updating strScreen on tblSMComment ***'
GO

PRINT '*** Start Updating strScreen on tblSMAttachment ***'
GO

UPDATE tblSMAttachment 
SET	tblSMAttachment.strScreen = CASE WHEN (CHARINDEX('i21', tblSMAttachment.strScreen) > 0)
                            THEN REPLACE(tblSMAttachment.strScreen, 'i21', 'SystemManager')
                            ELSE REPLACE(tblSMAttachment.strScreen, 'GlobalComponentEngine', 'SystemManager') END
FROM tblSMAttachment AS tblSMAttachment
WHERE tblSMAttachment.strScreen LIKE '%i21%'
	OR tblSMAttachment.strScreen LIKE '%GlobalComponentEngine%'

PRINT '*** End Updating strScreen on tblSMAttachment ***'
GO

PRINT '*** Start Updating strScreen on tblSMGridLayout ***'
GO

UPDATE tblSMGridLayout 
SET	tblSMGridLayout.strScreen = CASE WHEN (CHARINDEX('i21', tblSMGridLayout.strScreen) > 0)
                            THEN REPLACE(tblSMGridLayout.strScreen, 'i21', 'SystemManager')
                            ELSE REPLACE(tblSMGridLayout.strScreen, 'GlobalComponentEngine', 'SystemManager') END
FROM tblSMGridLayout AS tblSMGridLayout
WHERE tblSMGridLayout.strScreen LIKE '%i21%'
	OR tblSMGridLayout.strScreen LIKE '%GlobalComponentEngine%'

PRINT '*** End Updating strScreen on tblSMGridLayout ***'
GO

PRINT '*** Start Updating strScreen on tblSMGridLayout ***'
GO

UPDATE tblSMCompanyGridLayout 
SET	tblSMCompanyGridLayout.strScreen = CASE WHEN (CHARINDEX('i21', tblSMCompanyGridLayout.strScreen) > 0)
                            THEN REPLACE(tblSMCompanyGridLayout.strScreen, 'i21', 'SystemManager')
                            ELSE REPLACE(tblSMCompanyGridLayout.strScreen, 'GlobalComponentEngine', 'SystemManager') END
FROM tblSMCompanyGridLayout AS tblSMCompanyGridLayout
WHERE tblSMCompanyGridLayout.strScreen LIKE '%i21%'
	OR tblSMCompanyGridLayout.strScreen LIKE '%GlobalComponentEngine%'

PRINT '*** End Updating strScreen on tblSMGridLayout ***'
GO

PRINT '*** Start Updating strScreen on tblSMEmail ***'
GO

UPDATE tblSMEmail 
SET	tblSMEmail.strScreen = CASE WHEN (CHARINDEX('i21', tblSMEmail.strScreen) > 0)
                            THEN REPLACE(tblSMEmail.strScreen, 'i21', 'SystemManager')
                            ELSE REPLACE(tblSMEmail.strScreen, 'GlobalComponentEngine', 'SystemManager') END
FROM tblSMEmail AS tblSMEmail
WHERE tblSMEmail.strScreen LIKE '%i21%'
	OR tblSMEmail.strScreen LIKE '%GlobalComponentEngine%'

PRINT '*** End Updating strScreen on tblSMEmail ***'
GO

PRINT '*** Start Updating strScreen on tblSMReminderList ***'
GO

UPDATE tblSMReminderList 
SET	tblSMReminderList.strNamespace = CASE WHEN (CHARINDEX('i21', tblSMReminderList.strNamespace) > 0)
                            THEN REPLACE(tblSMReminderList.strNamespace, 'i21', 'SystemManager')
                            ELSE REPLACE(tblSMReminderList.strNamespace, 'GlobalComponentEngine', 'SystemManager') END
FROM tblSMReminderList AS tblSMReminderList
WHERE tblSMReminderList.strNamespace LIKE '%i21%'
	OR tblSMReminderList.strNamespace LIKE '%GlobalComponentEngine%'

PRINT '*** End Updating strScreen on tblSMReminderList ***'
GO

PRINT N'START UPDATE SCREEN NAMES FOR SENCHA UNIVERSAL'
GO
---------------------------------------------------------------------------------------------------------------------------------------
----------- Delete record for SystemManager.view.SecurityListingGenerator as it has a duplicate record on SM Module -----------
---------------------------------------------------------------------------------------------------------------------------------------
PRINT '*** Start Deleting obsolete GCE namespace on tblSMScreen ***'
GO

DELETE A 
FROM tblSMScreen AS A
WHERE A.strNamespace = 'GlobalComponentEngine.view.SecurityListingGenerator'
     OR A.strNamespace = 'GlobalComponentEngine.view.CompanyPreferenceOption'

PRINT '*** End Deleting obsolete GCE namespace on tblSMScreen ***'
GO
-----------------------------------------------------------------
------ Delete records that has both existing on GCE and SM ------
-----------------------------------------------------------------
PRINT '*** Start deleting obsolete GCE screens on tblSMTransaction ***'
GO

DELETE TRN
FROM tblSMScreen AS MAIN
INNER JOIN tblSMTransaction AS TRN
     ON MAIN.intScreenId = TRN.intScreenId
WHERE 
     RIGHT(MAIN.strNamespace, CHARINDEX('.', REVERSE(MAIN.strNamespace) + '.') - 1) IN ('LightningTable', 'DatabaseConnection')
     OR MAIN.strNamespace = 'GlobalComponentEngine.view.CompanyPreferenceOption'

DELETE MAIN 
FROM tblSMScreen AS MAIN
WHERE 
     RIGHT(MAIN.strNamespace, CHARINDEX('.', REVERSE(MAIN.strNamespace) + '.') - 1) IN ('LightningTable', 'DatabaseConnection') -- This are the duplicate records
PRINT '*** End deleting obsolete GCE screens on tblSMTransaction ***'
GO
----------------------------------------------------------------
------ Update all Sencha Universal iRely Package screens  ------
----------------------------------------------------------------
PRINT '*** Start Updating strNamespace on tblSMScreen related to Framework ***'
GO

UPDATE
     TSS
SET
     TSS.strNamespace = CASE WHEN (CHARINDEX('i21', TSS.strNamespace) > 0)
                            THEN REPLACE(TSS.strNamespace, 'i21', 'iRely.Controls')
                            ELSE REPLACE(TSS.strNamespace, 'GlobalComponentEngine', 'iRely.Controls') END
FROM  dbo.tblSMScreen AS TSS
CROSS APPLY (
        -- https://stackoverflow.com/a/39002164/13726696
        SELECT RIGHT(TSS.strNamespace, CHARINDEX('.', REVERSE(TSS.strNamespace) + '.') - 1) as ScreenName
     ) AS SEL
WHERE SEL.ScreenName IN -- List of iRely.Controls screens
     (
          'ActivityGrid'
          ,'AdvanceSearchGrid'
          ,'ApprovalGrid'
          ,'AttachmentGrid'
          ,'AuditLogTree'
          ,'DocumentGrid'
          ,'Filter'
          ,'FloatingSearch'
          ,'GridTemplate'
          ,'HoursWorked'
          ,'PaymentGrid'
          ,'ReportTranslation'
          ,'Search'
          ,'SearchGrid'
          ,'Statusbar'
          ,'StatusbarPaging'
     )
     AND TSS.strModule = 'Global Component Engine'

PRINT '*** End Updating strNamespace on tblSMScreen related to Framework ***'
GO

------------------------------------------
------ Start updating tblSMMasterMenu ------
------------------------------------------
PRINT '*** Start Updating strCommand on tblSMMasterMenu for GCE and SM ***'
GO

UPDATE
     TSMM
SET
    TSMM.strCommand = CASE WHEN (CHARINDEX('i21', TSMM.strCommand) > 0)
                            THEN REPLACE(TSMM.strCommand, 'i21', 'SystemManager')
                            ELSE REPLACE(TSMM.strCommand, 'GlobalComponentEngine', 'SystemManager') END
FROM  dbo.tblSMMasterMenu AS TSMM
WHERE TSMM.strType = 'Screen'
      AND (TSMM.strCommand LIKE '%i21%'
               OR TSMM.strCommand LIKE '%GlobalComponentEngine%'
          )

PRINT '*** End Updating strCommand on tblSMMasterMenu for GCE and SM ***'
GO


PRINT '*** Start Updating strCommand on tblSMScreen for GCE and SM ***'
GO

UPDATE
     TSS
SET
     TSS.strNamespace = CASE WHEN (CHARINDEX('i21', TSS.strNamespace) > 0)
                              THEN REPLACE(TSS.strNamespace, 'i21', 'SystemManager')
                              ELSE REPLACE(TSS.strNamespace, 'GlobalComponentEngine', 'SystemManager') END
FROM  dbo.tblSMScreen AS TSS
WHERE TSS.strNamespace LIKE '%i21%'
     OR TSS.strNamespace LIKE '%GlobalComponentEngine%'

PRINT '*** End Updating strCommand on tblSMScreen for GCE and SM ***'
GO

PRINT '*** Start Updating strCommand on tblSMMasterMenu for Reports ***'
GO

UPDATE
     TSMM
SET
     TSMM.strCommand = REPLACE(TSMM.strCommand, 'Reporting.view', 'Reports.view')
FROM  dbo.tblSMMasterMenu AS TSMM
WHERE TSMM.strType = 'Screen'
     AND TSMM.strCommand LIKE '%Reporting.view%'

PRINT '*** End Updating strCommand on tblSMMasterMenu for Reports ***'
GO

PRINT '*** Start Updating strCommand on tblSMScreen for Reports ***'
GO

UPDATE
     TSS
SET
     TSS.strNamespace = REPLACE(TSS.strNamespace, 'Reporting.view', 'Reports.view')
FROM  dbo.tblSMScreen AS TSS
WHERE TSS.strNamespace LIKE '%Reporting.view%'

PRINT '*** End Updating strCommand on tblSMScreen for Reports ***'
GO

PRINT '*** Start Updating strCommand on tblSMScreen for GCE and SM ***'
GO

UPDATE
     TSS
SET
     TSS.strNamespace = CASE WHEN (CHARINDEX('i21', TSS.strNamespace) > 0)
                              THEN REPLACE(TSS.strNamespace, 'i21', 'SystemManager')
                              ELSE REPLACE(TSS.strNamespace, 'GlobalComponentEngine', 'SystemManager') END
FROM  dbo.tblSMScreen AS TSS
WHERE TSS.strNamespace LIKE '%i21%'
     OR TSS.strNamespace LIKE '%GlobalComponentEngine%'

PRINT '*** End Updating strCommand on tblSMScreen for GCE and SM ***'
GO

PRINT '*** Start Updating strNamespace on tblSMApproverConfigurationApprovalFor ***'
GO

UPDATE 
     A 
SET 
     A.strNamespace = REPLACE(A.strNamespace, 'i21', 'SystemManager.controls')
FROM tblSMApproverConfigurationApprovalFor AS A
WHERE A.strNamespace LIKE '%i21.component%'

PRINT '*** End Updating strNamespace on tblSMApproverConfigurationApprovalFor ***'
GO