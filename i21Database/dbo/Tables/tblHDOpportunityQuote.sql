CREATE TABLE [dbo].[tblHDOpportunityQuote]
(
	[intOpportunityQuoteId] [int] IDENTITY(1,1) NOT NULL,
	[intProjectId] [int] NOT NULL,
	[intSalesOrderId] [int] NOT NULL,
	[intConcurrencyId] [int] NOT NULL DEFAULT 1,
	CONSTRAINT [PK_tblHDOpportunityQuote] PRIMARY KEY CLUSTERED ([intOpportunityQuoteId] ASC),
	CONSTRAINT [AK_tblHDOpportunityQuote_intProjectId_intSalesOrderId] UNIQUE ([intProjectId],[intSalesOrderId]),
    CONSTRAINT [FK_tblHDOpportunityQuote_tblHDProject] FOREIGN KEY ([intProjectId]) REFERENCES [dbo].[tblHDProject] ([intProjectId]),
    CONSTRAINT [FK_tblHDOpportunityQuote_tblSOSalesorder] FOREIGN KEY ([intSalesOrderId]) REFERENCES [dbo].[tblSOSalesOrder] ([intSalesOrderId])
)

GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Identity',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblHDOpportunityQuote',
    @level2type = N'COLUMN',
    @level2name = N'intOpportunityQuoteId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Reference Project Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblHDOpportunityQuote',
    @level2type = N'COLUMN',
    @level2name = N'intProjectId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Reference Sales Order Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblHDOpportunityQuote',
    @level2type = N'COLUMN',
    @level2name = N'intSalesOrderId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Concurrency Check',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblHDOpportunityQuote',
    @level2type = N'COLUMN',
    @level2name = N'intConcurrencyId'