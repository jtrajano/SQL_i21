﻿CREATE TABLE [dbo].[tblICBackupDetailInventoryTransaction]
(
	[intBackupDetailId]			INT NOT NULL IDENTITY(1, 1),
	[intBackupId]				INT NOT NULL,
	[intIdentityId]				INT NOT NULL,
	[intItemId] INT NOT NULL,
	[intItemLocationId] INT NOT NULL,
	[intItemUOMId] INT NULL,
	[intSubLocationId] INT NULL,
	[intStorageLocationId] INT NULL,
	[dtmDate] DATETIME NOT NULL, 
	[dblQty] NUMERIC(38, 20) NOT NULL DEFAULT 0, 
	[dblUOMQty] NUMERIC(38, 20) NOT NULL DEFAULT 0, 		
	[dblCost] NUMERIC(38, 20) NOT NULL DEFAULT 0, 
	[dblValue] NUMERIC(38, 20) NULL, 
	[dblSalesPrice] NUMERIC(18, 6) NOT NULL DEFAULT 0, 
	[intCurrencyId] INT NULL,
	[dblExchangeRate] DECIMAL (38, 20) DEFAULT 1 NOT NULL,
	[intTransactionId] INT NOT NULL, 
	[strTransactionId] NVARCHAR(40) COLLATE Latin1_General_CI_AS NOT NULL, 
	[intTransactionDetailId] INT NULL, 
	[strBatchId] NVARCHAR(40) COLLATE Latin1_General_CI_AS NOT NULL, 
	[intTransactionTypeId] INT NOT NULL, 
	[intLotId] INT NULL, 
	[ysnIsUnposted] BIT NULL,
	[intRelatedInventoryTransactionId] INT NULL,
	[intRelatedTransactionId] INT NULL,
	[strRelatedTransactionId] NVARCHAR(40) COLLATE Latin1_General_CI_AS NULL,
	[strTransactionForm] NVARCHAR (255) COLLATE Latin1_General_CI_AS NULL,
	[intCostingMethod] INT NULL, 
	[intInTransitSourceLocationId] INT NULL, 
	[dtmCreated] DATETIME NULL, 
	[strDescription] NVARCHAR(255) COLLATE Latin1_General_CI_AS NULL, 
	[intFobPointId] TINYINT NULL,
	[ysnNoGLPosting] BIT NULL DEFAULT 0, 
	[intForexRateTypeId] INT NULL,
	[dblForexRate] NUMERIC(38, 20) NULL DEFAULT 1, 
	[strActualCostId] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
	[dblUnitRetail] NUMERIC(38, 20) NULL,
	[dblCategoryCostValue] NUMERIC(38, 20) NULL, 
	[dblCategoryRetailValue] NUMERIC(38, 20) NULL, 
	[intCategoryId] INT NULL,
	[intCreatedUserId] INT NULL, 
	[intCreatedEntityId] INT NULL, 
	[intCompanyId] INT NULL, 
	[strSourceType] NVARCHAR(100) NULL,
	[strSourceNumber] NVARCHAR(100) NULL,
	[strBOLNumber] NVARCHAR(100) NULL,
	[intTicketId] INT NULL,
	CONSTRAINT [PK_tblICBackupDetailInventoryTransaction] PRIMARY KEY ([intBackupDetailId]),
	CONSTRAINT [FK_tblICBackupDetailInventoryTransaction_tblICBackup] FOREIGN KEY ([intBackupId]) REFERENCES [tblICBackup]([intBackupId])
)