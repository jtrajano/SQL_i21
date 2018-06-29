CREATE TABLE [dbo].[tblSMReplicationTable]
(
	[intReplicationTableId] INT NOT NULL PRIMARY KEY IDENTITY, 	
	[strTableName] NVARCHAR (100) COLLATE Latin1_General_CI_AS NULL,
    [intConcurrencyId] INT NOT NULL DEFAULT 1
)