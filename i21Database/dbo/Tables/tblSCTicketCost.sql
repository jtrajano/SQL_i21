CREATE TABLE [dbo].[tblSCTicketCost]
(
	[intTicketCostId] INT NOT NULL IDENTITY, 
    [intTicketId] INT NOT NULL,
	[intConcurrencyId] [int] NOT NULL,
	[intCostTypeId] [int] NOT NULL,
	[intEntityId] [int] NULL,
	[intCostMethod] [int] NOT NULL,
	[dblRate] [numeric](10, 4) NOT NULL,
	[intUnitMeasureId] [int] NULL,
	[intCurrencyId] [int] NOT NULL,
	[ysnAccrue] [bit] NOT NULL DEFAULT ((1)),
	[ysnMTM] [bit] NULL,
	[ysnPrice] [bit] NULL, 
    CONSTRAINT [PK_tblSCTicketCost_intTicketCostId] PRIMARY KEY ([intTicketCostId]),
	CONSTRAINT [FK_tblSCTicketCost_tblSCTicket_intTicketId] FOREIGN KEY ([intTicketId]) REFERENCES [tblSCTicket]([intTicketId]) 
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
    @value = N'Cost Type Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSCTicketCost',
    @level2type = N'COLUMN',
    @level2name = N'intCostTypeId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Entity Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSCTicketCost',
    @level2type = N'COLUMN',
    @level2name = N'intEntityId'
GO

GO

EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Unit Measure Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSCTicketCost',
    @level2type = N'COLUMN',
    @level2name = N'intUnitMeasureId'
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
    @value = N'Cost Method',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSCTicketCost',
    @level2type = N'COLUMN',
    @level2name = N'intCostMethod'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Currency Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSCTicketCost',
    @level2type = N'COLUMN',
    @level2name = N'intCurrencyId'
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