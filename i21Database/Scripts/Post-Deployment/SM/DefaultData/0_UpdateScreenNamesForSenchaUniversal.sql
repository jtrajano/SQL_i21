GO
PRINT N'START UPDATE SCREEN NAMES FOR SENCHA UNIVERSAL'
GO
---------------------------------------------------------------------------------------------------------------------------------------
----------- Delete record for GlobalComponentEngine.view.SecurityListingGenerator as it has a duplicate record on SM Module -----------
---------------------------------------------------------------------------------------------------------------------------------------
PRINT '*** Start Deleting SecurityListingGenerator namespace on tblSMScreen ***'
GO

DELETE A 
FROM tblSMScreen AS A
WHERE A.strNamespace = 'GlobalComponentEngine.view.SecurityListingGenerator'

PRINT '*** End Deleting SecurityListingGenerator namespace on tblSMScreen ***'
GO
-----------------------------------------------------------------
------ Delete records that has both existing on GCE and SM ------
-----------------------------------------------------------------
PRINT '*** Start Updating LightningTable and DatabaseConnection namespaces on tblSMScreen ***'
GO

DELETE MAIN 
FROM tblSMScreen AS MAIN
WHERE 
      RIGHT(MAIN.strNamespace, CHARINDEX('.', REVERSE(MAIN.strNamespace) + '.') - 1) IN ('LightningTable', 'DatabaseConnection') -- This are the duplicate records

PRINT '*** End deleting LightningTable and DatabaseConnection namespaces on tblSMScreen ***'
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
