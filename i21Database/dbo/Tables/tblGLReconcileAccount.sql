CREATE TABLE [dbo].[tblGLReconcileAccount]
(
	[intId] INT NOT NULL PRIMARY KEY, 
    [intConcurrencyId] INT NOT NULL, 
    [intAccountId] INT NOT NULL, 
    [dtmReconcileDate] DATETIME NOT NULL, 
    [strReconciledId] NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL,
)
