CREATE TABLE [dbo].[tblICInventoryTransfer]
(
	[intInventoryTransferId] INT NOT NULL IDENTITY, 
    [strTransferNo] NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL, 
    [dtmTransferDate] DATETIME NULL DEFAULT (getdate()), 
    [strTransferType] NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL, 
	[intSourceType] INT NOT NULL DEFAULT ((0)),
    [intTransferredById] INT NULL, 
    [strDescription] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL, 
    [intFromLocationId] INT NULL, 
    [intToLocationId] INT NULL, 
    [ysnShipmentRequired] BIT NULL DEFAULT ((0)), 
	[intStatusId] INT NOT NULL,
    [intShipViaId] INT NULL, 
    [intFreightUOMId] INT NULL, 
	[ysnPosted] BIT NULL DEFAULT((0)),
	[intCreatedUserId] INT NULL,
	[intEntityId] INT NULL,
    [intSort] INT NULL, 
    [intConcurrencyId] INT NULL DEFAULT ((0)), 
	[strActualCostId] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[dtmCreated] DATETIME NULL DEFAULT (GETDATE()),
    CONSTRAINT [PK_tblICInventoryTransfer] PRIMARY KEY ([intInventoryTransferId]), 
    CONSTRAINT [AK_tblICInventoryTransfer_strTransferNo] UNIQUE ([strTransferNo]), 
    CONSTRAINT [FK_tblICInventoryTransfer_tblEMEntity] FOREIGN KEY ([intTransferredById]) REFERENCES tblEMEntity([intEntityId]), 
    CONSTRAINT [FK_tblICInventoryTransfer_FromLocation] FOREIGN KEY ([intFromLocationId]) REFERENCES [tblSMCompanyLocation]([intCompanyLocationId]), 
    CONSTRAINT [FK_tblICInventoryTransfer_ToLocation] FOREIGN KEY ([intToLocationId]) REFERENCES [tblSMCompanyLocation]([intCompanyLocationId]), 
    CONSTRAINT [FK_tblICInventoryTransfer_tblICUnitMeasure] FOREIGN KEY ([intFreightUOMId]) REFERENCES [tblICUnitMeasure]([intUnitMeasureId]), 
    CONSTRAINT [FK_tblICInventoryTransfer_tblSMShipVia] FOREIGN KEY ([intShipViaId]) REFERENCES [tblSMShipVia]([intEntityId]), 
    CONSTRAINT [FK_tblICInventoryTransfer_EntityCreator] FOREIGN KEY ([intEntityId]) REFERENCES tblEMEntity([intEntityId]), 
    CONSTRAINT [FK_tblICInventoryTransfer_tblICStatus] FOREIGN KEY ([intStatusId]) REFERENCES [tblICStatus]([intStatusId]) 
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
    @value = N'Ship Via Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICInventoryTransfer',
    @level2type = N'COLUMN',
    @level2name = 'intShipViaId'
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

GO

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
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Posted',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICInventoryTransfer',
    @level2type = N'COLUMN',
    @level2name = N'ysnPosted'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Created User Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICInventoryTransfer',
    @level2type = N'COLUMN',
    @level2name = N'intCreatedUserId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Entity Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICInventoryTransfer',
    @level2type = N'COLUMN',
    @level2name = N'intEntityId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Status Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICInventoryTransfer',
    @level2type = N'COLUMN',
    @level2name = N'intStatusId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Source Type',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICInventoryTransfer',
    @level2type = N'COLUMN',
    @level2name = N'intSourceType'