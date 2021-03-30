CREATE TABLE [dbo].[tblICAPClearing]
(
	[intICAPClearingId] INT IDENTITY(1, 1) NOT NULL
	--HEADER
	,[intTransactionId] INT NOT NULL
	,[strTransactionId] NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL
	,[intTransactionType] INT NOT NULL
	,[strReferenceNumber] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL
	,[dtmDate] DATETIME NOT NULL
	,[intEntityVendorId] INT NOT NULL
	,[intLocationId] INT NOT NULL
	,[strBatchId] NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL
	--DETAIL
	,[intInventoryReceiptItemId] INT NULL
	,[intInventoryReceiptItemTaxId] INT NULL
	,[intInventoryReceiptChargeId] INT NULL
	,[intInventoryReceiptChargeTaxId] INT NULL
	,[intInventoryShipmentChargeId] INT NULL
	,[intInventoryShipmentChargeTaxId] INT NULL
	,[intAccountId] INT NOT NULL
	,[intItemId] INT NULL
	,[intItemUOMId] INT NULL
	,[dblQuantity] NUMERIC(18, 6) NOT NULL DEFAULT 0
	,[dblAmount] NUMERIC(18, 6) NOT NULL DEFAULT 0
	,[ysnIsUnposted] BIT NOT NULL DEFAULT 0
	,[dtmDateEntered] DATETIME DEFAULT GETDATE() 
	

	CONSTRAINT [PK_dbo.tblICAPClearing] PRIMARY KEY CLUSTERED ([intICAPClearingId] ASC)
);
GO

CREATE NONCLUSTERED INDEX [IX_tblICAPClearing_strTransactionId]
	ON [dbo].[tblICAPClearing]([strTransactionId] ASC)
	INCLUDE ([ysnIsUnposted])
GO

CREATE NONCLUSTERED INDEX [IX_tblICAPClearing_strBatchId]
	ON [dbo].[tblICAPClearing]([strBatchId] ASC)
GO