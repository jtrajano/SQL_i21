﻿CREATE TABLE [dbo].[tblICBackupDetailInventoryTransactionStorage]
(
	[intBackupDetailId]			INT NOT NULL IDENTITY(1, 1),
	[intBackupId]				INT NOT NULL,
	[intIdentityId]				INT NOT NULL,
	[intItemId] INT NOT NULL,
	[intItemLocationId] INT NOT NULL,
	[intItemUOMId] INT NOT NULL,
	[intSubLocationId] INT NULL,
	[intStorageLocationId] INT NULL,
	[intLotId] INT NULL, 
	[dtmDate] DATETIME NOT NULL,	
	[dblQty] NUMERIC(38, 20) NOT NULL DEFAULT 0, 
	[dblUOMQty] NUMERIC(38, 20) NOT NULL DEFAULT 0, 		
	[dblCost] NUMERIC(38, 20) NOT NULL DEFAULT 0, 
	[dblValue] NUMERIC(38, 20) NULL, 
	[dblSalesPrice] NUMERIC(18, 6) NOT NULL DEFAULT 0, 
	[intCurrencyId] INT NULL,
	[dblExchangeRate] DECIMAL (38, 20) DEFAULT 1 NOT NULL,
	[intTransactionId] INT NOT NULL, 
	[intTransactionDetailId] INT NULL, 
	[strTransactionId] NVARCHAR(40) COLLATE Latin1_General_CI_AS NOT NULL, 
	[intInventoryCostBucketStorageId] INT NULL, 
	[strBatchId] NVARCHAR(20) COLLATE Latin1_General_CI_AS NOT NULL, 
	[intTransactionTypeId] INT NOT NULL, 		
	[ysnIsUnposted] BIT NULL,
	[strTransactionForm] NVARCHAR (255) COLLATE Latin1_General_CI_AS NULL,
	[intRelatedInventoryTransactionId] INT NULL, 
	[intRelatedTransactionId] INT NULL, 
	[strRelatedTransactionId] NVARCHAR(40) COLLATE Latin1_General_CI_AS NULL, 
	[intCostingMethod] INT NULL, 
	[dtmCreated] DATETIME NULL, 
	[intCreatedUserId] INT NULL,
	[intCreatedEntityId] INT NULL,
	CONSTRAINT [PK_tblICBackupDetailInventoryTransactionStorage] PRIMARY KEY ([intBackupDetailId]),
	CONSTRAINT [FK_tblICBackupDetailInventoryTransactionStorage_tblICBackup] FOREIGN KEY ([intBackupId]) REFERENCES [tblICBackup]([intBackupId])
)
GO