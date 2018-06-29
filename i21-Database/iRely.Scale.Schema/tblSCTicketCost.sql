CREATE TABLE [dbo].[tblSCTicketCost]
(
	[intTicketCostId] INT NOT NULL IDENTITY, 
    [intTicketId] INT NOT NULL,
	[intConcurrencyId] [int] NOT NULL,
	[intItemId] [int] NOT NULL,
	[intEntityVendorId] INT NULL,
	[strCostMethod] [nvarchar](30) COLLATE Latin1_General_CI_AS NOT NULL,
	[dblRate] [numeric](10, 4) NOT NULL,
	[intItemUOMId] [int] NULL,
	[ysnAccrue] [bit] NOT NULL,
	[ysnMTM] [bit] NULL,
	[ysnPrice] [bit] NULL,
    CONSTRAINT [PK_tblSCTicketCost_intTicketCostId] PRIMARY KEY ([intTicketCostId]),
	CONSTRAINT [FK_tblSCTicketCost_tblSCTicket_intTicketId] FOREIGN KEY ([intTicketId]) REFERENCES [tblSCTicket]([intTicketId]),
	CONSTRAINT [FK_tblSCTicketCost_tblICItem_intItemId] FOREIGN KEY ([intItemId]) REFERENCES [tblICItem]([intItemId]),
	CONSTRAINT [FK_tblSCTicketCost_tblAPVendor_intEntityVendorId] FOREIGN KEY ([intEntityVendorId]) REFERENCES [tblAPVendor]([intEntityId]),
	CONSTRAINT [FK_tblSCTicketCost_tblICItemUOM_intItemUOMId] FOREIGN KEY ([intItemUOMId]) REFERENCES [tblICItemUOM]([intItemUOMId]) 
)

GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Internal Primary Key',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSCTicketCost',
    @level2type = N'COLUMN',
    @level2name = N'intTicketCostId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Ticket Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSCTicketCost',
    @level2type = N'COLUMN',
    @level2name = N'intTicketId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Concurrency Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSCTicketCost',
    @level2type = N'COLUMN',
    @level2name = N'intConcurrencyId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Rate',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSCTicketCost',
    @level2type = N'COLUMN',
    @level2name = N'dblRate'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Accure',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSCTicketCost',
    @level2type = N'COLUMN',
    @level2name = N'ysnAccrue'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'MTM',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSCTicketCost',
    @level2type = N'COLUMN',
    @level2name = N'ysnMTM'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Price',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSCTicketCost',
    @level2type = N'COLUMN',
    @level2name = N'ysnPrice'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Item Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSCTicketCost',
    @level2type = N'COLUMN',
    @level2name = N'intItemId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Cost Method',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSCTicketCost',
    @level2type = N'COLUMN',
    @level2name = N'strCostMethod'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Item UOM Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSCTicketCost',
    @level2type = N'COLUMN',
    @level2name = N'intItemUOMId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Entity Vendor Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSCTicketCost',
    @level2type = N'COLUMN',
    @level2name = N'intEntityVendorId'