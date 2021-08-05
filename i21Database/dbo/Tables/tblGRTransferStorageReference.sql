CREATE TABLE tblGRTransferStorageReference
(
	intTransferStorageReferenceId INT NOT NULL IDENTITY(1,1),
	intSourceCustomerStorageId INT NOT NULL,
	intToCustomerStorageId INT NOT NULL,
	intTransferStorageSplitId INT NOT NULL,
	intTransferStorageId INT NOT NULL,
	dblUnitQty NUMERIC(38,20) NOT NULL DEFAULT(0),
	dblSplitPercent NUMERIC(38,20) NOT NULL DEFAULT(0),
	dtmProcessDate DATETIME NOT NULL DEFAULT(GETDATE()),
	-- For cost bucket for DP to DP
	intCostBucketCustomerStorageId INT NULL DEFAULT(NULL),
	CONSTRAINT [FK_tblGRTransferStorageReference_tblGRTransferStorage_intTransferStorageId] FOREIGN KEY ([intTransferStorageId]) REFERENCES [dbo].[tblGRTransferStorage] ([intTransferStorageId]) ON DELETE CASCADE,	
)
GO

CREATE NONCLUSTERED INDEX [IX_tblGRTransferStorageReference_intSourceCustomerStorageId]
ON [dbo].[tblGRTransferStorageReference]([intSourceCustomerStorageId])
GO

CREATE NONCLUSTERED INDEX [IX_tblGRTransferStorageReference_intToCustomerStorageId]
ON [dbo].[tblGRTransferStorageReference]([intToCustomerStorageId])
INCLUDE (
	intSourceCustomerStorageId
	,intTransferStorageSplitId
	,intTransferStorageId
	,intCostBucketCustomerStorageId
)
GO