CREATE TABLE [dbo].[tblSCTicketType]
(
	[intTicketTypeId] INT NOT NULL  IDENTITY, 
    [intTicketPoolId] INT NOT NULL, 
	[intListTicketTypeId] INT NULL, 
    [ysnTicketAllowed] BIT NOT NULL, 
    [intNextTicketNumber] INT NOT NULL, 
    [intDiscountSchedule] INT NULL, 
    [intDistributionMethod] INT NOT NULL, 
    [ysnSelectByPO] BIT NOT NULL, 
    [intSplitInvoiceOption] INT NOT NULL, 
    [intContractRequired] INT NOT NULL, 
    [intOverrideTicketCopies] INT NOT NULL, 
    [ysnPrintAtKiosk] BIT NOT NULL, 
    [ynsVerifySplitMethods] BIT NOT NULL, 
    [ysnOverrideSingleTicketSeries] BIT NOT NULL, 
    [intTransferWeight] INT NOT NULL DEFAULT 1, 
    [intConcurrencyId] INT NULL DEFAULT ((0)), 
    CONSTRAINT [PK_tblSCTicketType_intTicketTypeId] PRIMARY KEY ([intTicketTypeId]), 
    CONSTRAINT [FK_tblSCTicketType_tblSCTicketPool_intTicketPoolId] FOREIGN KEY (intTicketPoolId) REFERENCES tblSCTicketPool(intTicketPoolId),
    CONSTRAINT [FK_tblSCTicketType_tblSCListTicketType_intListTicketTypeId] FOREIGN KEY ([intListTicketTypeId]) REFERENCES [tblSCListTicketTypes]([intTicketTypeId])
)

GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Identity Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSCTicketType',
    @level2type = N'COLUMN',
    @level2name = N'intTicketTypeId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Ticket Type ID',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSCTicketType',
    @level2type = N'COLUMN',
    @level2name = N'intListTicketTypeId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Ticket Pool',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSCTicketType',
    @level2type = N'COLUMN',
    @level2name = N'intTicketPoolId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Ticket Allowed',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSCTicketType',
    @level2type = N'COLUMN',
    @level2name = N'ysnTicketAllowed'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Next Ticket Number',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSCTicketType',
    @level2type = N'COLUMN',
    @level2name = N'intNextTicketNumber'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Discount Schedule',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSCTicketType',
    @level2type = N'COLUMN',
    @level2name = N'intDiscountSchedule'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Distribution Method',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSCTicketType',
    @level2type = N'COLUMN',
    @level2name = N'intDistributionMethod'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'PO Selection',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSCTicketType',
    @level2type = N'COLUMN',
    @level2name = N'ysnSelectByPO'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Split Invoice',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSCTicketType',
    @level2type = N'COLUMN',
    @level2name = N'intSplitInvoiceOption'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Contract Requirement',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSCTicketType',
    @level2type = N'COLUMN',
    @level2name = N'intContractRequired'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Ticket Copies',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSCTicketType',
    @level2type = N'COLUMN',
    @level2name = N'intOverrideTicketCopies'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Kiosk Print',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSCTicketType',
    @level2type = N'COLUMN',
    @level2name = N'ysnPrintAtKiosk'
GO

GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Validate Split',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSCTicketType',
    @level2type = N'COLUMN',
    @level2name = N'ynsVerifySplitMethods'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Override Single Ticket Series',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSCTicketType',
    @level2type = N'COLUMN',
    @level2name = N'ysnOverrideSingleTicketSeries'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Concurrency Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSCTicketType',
    @level2type = N'COLUMN',
    @level2name = N'intConcurrencyId'
GO