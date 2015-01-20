CREATE TABLE [dbo].[tblICInventoryTransfer]
(
	[intInventoryTransferId] INT NOT NULL IDENTITY, 
    [strTransferId] NVARCHAR(50) NOT NULL, 
    [dtmTransferDate] DATETIME NULL DEFAULT (getdate()), 
    [strTransferType] NVARCHAR(50) NULL, 
    [intTransferredBy] INT NULL, 
    [strDescription] NVARCHAR(100) NULL, 
    [intFromLocationId] INT NULL, 
    [intToLocationId] INT NULL, 
    [ysnShipmentRequired] BIT NULL DEFAULT ((0)), 
    [intCarrierId] INT NULL, 
    [intFreightUOMId] INT NULL, 
    [intAccountCategoryId] INT NULL, 
    [intAccountId] INT NULL, 
    [dblTaxAmount] NUMERIC(18, 6) NULL, 
    [intSort] INT NULL, 
    [intConcurrencyId] INT NULL DEFAULT ((0)), 
    CONSTRAINT [PK_tblICInventoryTransfer] PRIMARY KEY ([intInventoryTransferId]) 
)
