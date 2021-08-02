CREATE TABLE [dbo].[tblICInventoryTransferCondition]
(
	[intInventoryTransferConditionId] INT IDENTITY(1, 1) NOT NULL,
	[intInventoryTransferId] INT NOT NULL,
	[strName] NVARCHAR(100) COLLATE Latin1_General_CI_AS NOT NULL,
	[strDescription] NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NOT NULL,
	[intConcurrencyId] INT NULL,
	[dtmDateModified] DATETIME NULL,
	[dtmDateCreated] DATETIME NULL,
	[intCreatedByUserId] INT NULL,
	[intModifiedByUserId] INT NULL,
	[intCompanyId] INT NULL,
	CONSTRAINT [PK_tblICInventoryTransferCondition_intInventoryTransferConditionId] PRIMARY KEY([intInventoryTransferConditionId]),
	CONSTRAINT [FK_tblICInventoryTransferCondition_tblICInventoryTransfer_intInventoryTransferId]
		FOREIGN KEY ([intInventoryTransferId]) REFERENCES [tblICInventoryTransfer] ([intInventoryTransferId])
		ON DELETE CASCADE
)
