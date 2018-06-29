CREATE TABLE [dbo].[tblCRMOpportunityQuote]
(
	[intOpportunityQuoteId] [int] IDENTITY(1,1) NOT NULL,
	[intOpportunityId] [int] NOT NULL,
	[intSalesOrderId] [int] NOT NULL,
	[intConcurrencyId] [int] NOT NULL DEFAULT 1,
	CONSTRAINT [PK_tblCRMOpportunityQuote_intOpportunityQuoteId] PRIMARY KEY CLUSTERED ([intOpportunityQuoteId] ASC),
	CONSTRAINT [AK_tblCRMOpportunityQuote_intOpportunityId_intSalesOrderId] UNIQUE ([intOpportunityId],[intSalesOrderId]),
    CONSTRAINT [FK_tblCRMOpportunityQuote_tblCRMOpportunity_intOpportunityId] FOREIGN KEY ([intOpportunityId]) REFERENCES [dbo].[tblCRMOpportunity] ([intOpportunityId]) ON DELETE CASCADE,
    CONSTRAINT [FK_tblCRMOpportunityQuote_tblSOSalesorder_intSalesOrderId] FOREIGN KEY ([intSalesOrderId]) REFERENCES [dbo].[tblSOSalesOrder] ([intSalesOrderId]) ON DELETE CASCADE
)
