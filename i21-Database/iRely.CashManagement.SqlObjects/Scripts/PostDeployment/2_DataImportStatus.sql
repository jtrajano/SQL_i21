-- --------------------------------------------------
-- Purpose: Allows the system to know when the data import was executed against a system. 
-- Once executed, user is not allowed to run it again. For now, the import is against the origin system. 
-- --------------------------------------------------
-- Date Created: 02/18/2014 9:30 AM
-- Created by: Feb Montefrio
-- --------------------------------------------------

print('/*******************  BEGIN Populate Cash Management Import Status *******************/')

SET IDENTITY_INSERT [dbo].[tblCMDataImportStatus] ON

INSERT INTO dbo.[tblCMDataImportStatus] (
	[intDataImportStatusId]
    ,[strDescription]
)
SELECT 
	[intDataImportStatusId]		= 1
    ,[strDescription]			= 'Import Bank and Bank Accounts from Origin'
WHERE NOT EXISTS (SELECT TOP 1 1 FROM dbo.[tblCMDataImportStatus] WHERE [intDataImportStatusId] = 1)
UNION ALL
SELECT 
	[intDataImportStatusId]		= 2
    ,[strDescription]			= 'Import Bank Transactions from Origin'
WHERE NOT EXISTS (SELECT TOP 1 1 FROM dbo.[tblCMDataImportStatus] WHERE [intDataImportStatusId] = 2)
UNION ALL
SELECT 
	[intDataImportStatusId]		= 3
    ,[strDescription]			= 'Import Bank Reconciliation from Origin'
WHERE NOT EXISTS (SELECT TOP 1 1 FROM dbo.[tblCMDataImportStatus] WHERE [intDataImportStatusId] = 3)

SET IDENTITY_INSERT [dbo].[tblCMDataImportStatus] OFF
	
print('/*******************  END Populate Cash Management Import Status *******************/')