CREATE TABLE [dbo].[tblICInventoryTransfer]
(
	[intInventoryTransferId] INT NOT NULL IDENTITY, 
    [strTransferNo] NVARCHAR(50) NOT NULL, 
    [dtmTransferDate] DATETIME NULL DEFAULT (getdate()), 
    [strTransferType] NVARCHAR(50) NOT NULL, 
    [intTransferredById] INT NULL, 
    [strDescription] NVARCHAR(100) NULL, 
    [intFromLocationId] INT NULL, 
    [intToLocationId] INT NULL, 
    [ysnShipmentRequired] BIT NULL DEFAULT ((0)), 
    [intCarrierId] INT NULL, 
    [intFreightUOMId] INT NULL, 
    [intAccountCategoryId] INT NULL, 
    [intAccountId] INT NULL, 
    [intSort] INT NULL, 
    [intConcurrencyId] INT NULL DEFAULT ((0)), 
    CONSTRAINT [PK_tblICInventoryTransfer] PRIMARY KEY ([intInventoryTransferId]), 
    CONSTRAINT [AK_tblICInventoryTransfer_strTransferNo] UNIQUE ([strTransferNo]), 
    CONSTRAINT [FK_tblICInventoryTransfer_tblEntity] FOREIGN KEY ([intTransferredById]) REFERENCES [tblEntity]([intEntityId]), 
    CONSTRAINT [FK_tblICInventoryTransfer_FromLocation] FOREIGN KEY ([intFromLocationId]) REFERENCES [tblSMCompanyLocation]([intCompanyLocationId]), 
    CONSTRAINT [FK_tblICInventoryTransfer_ToLocation] FOREIGN KEY ([intToLocationId]) REFERENCES [tblSMCompanyLocation]([intCompanyLocationId]), 
    CONSTRAINT [FK_tblICInventoryTransfer_tblICUnitMeasure] FOREIGN KEY ([intFreightUOMId]) REFERENCES [tblICUnitMeasure]([intUnitMeasureId]), 
    CONSTRAINT [FK_tblICInventoryTransfer_tblGLAccountCategory] FOREIGN KEY ([intAccountCategoryId]) REFERENCES [tblGLAccountCategory]([intAccountCategoryId]), 
    CONSTRAINT [FK_tblICInventoryTransfer_tblGLAccount] FOREIGN KEY ([intAccountId]) REFERENCES [tblGLAccount]([intAccountId]) 
)

GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Identity Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICInventoryTransfer',
    @level2type = N'COLUMN',
    @level2name = N'intInventoryTransferId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Transfer Number',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICInventoryTransfer',
    @level2type = N'COLUMN',
    @level2name = N'strTransferNo'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Transfer Date',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICInventoryTransfer',
    @level2type = N'COLUMN',
    @level2name = N'dtmTransferDate'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Transfer Type',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICInventoryTransfer',
    @level2type = N'COLUMN',
    @level2name = N'strTransferType'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Transfer By Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICInventoryTransfer',
    @level2type = N'COLUMN',
    @level2name = N'intTransferredById'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Description',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICInventoryTransfer',
    @level2type = N'COLUMN',
    @level2name = N'strDescription'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'From Location Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICInventoryTransfer',
    @level2type = N'COLUMN',
    @level2name = N'intFromLocationId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'To Location Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICInventoryTransfer',
    @level2type = N'COLUMN',
    @level2name = N'intToLocationId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Shipment Required',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICInventoryTransfer',
    @level2type = N'COLUMN',
    @level2name = N'ysnShipmentRequired'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Carrier Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICInventoryTransfer',
    @level2type = N'COLUMN',
    @level2name = N'intCarrierId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Freight Unit of Measure Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICInventoryTransfer',
    @level2type = N'COLUMN',
    @level2name = N'intFreightUOMId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Account Category Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICInventoryTransfer',
    @level2type = N'COLUMN',
    @level2name = N'intAccountCategoryId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Account Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICInventoryTransfer',
    @level2type = N'COLUMN',
    @level2name = N'intAccountId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Sort Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICInventoryTransfer',
    @level2type = N'COLUMN',
    @level2name = N'intSort'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Concurrency Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICInventoryTransfer',
    @level2type = N'COLUMN',
    @level2name = N'intConcurrencyId'