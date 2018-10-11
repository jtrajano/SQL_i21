CREATE TABLE [dbo].[tblGRStorageHistoryTypeTransaction]
(
	[intStorageHistoryTransactionId] INT NOT NULL IDENTITY, 
    [strType] NVARCHAR(100) COLLATE Latin1_General_CI_AS NOT NULL, 
	[intTypeId] INT NOT NULL
)

GO