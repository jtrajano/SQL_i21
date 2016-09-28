CREATE TABLE [dbo].[tblCRMQuote]
(
	[intQuoteId] [int] IDENTITY(1,1) NOT NULL,
	[intOpportunityId] [int] NOT NULL,
	[intSalesOrderId] [int] NOT NULL,
	[intConcurrencyId] [int] NOT NULL DEFAULT 1,
	CONSTRAINT [PK_tblCRMQuote] PRIMARY KEY CLUSTERED ([intQuoteId] ASC)
	--CONSTRAINT [UQ_tblCRMQuote_intOpportunityId_intSalesOrderId] UNIQUE ([intOpportunityId],[intSalesOrderId]),
 --   CONSTRAINT [FK_tblCRMQuote_tblHDProject] FOREIGN KEY ([intOpportunityId]) REFERENCES [dbo].[tblCRMOpportunity] ([intOpportunityId]),
 --   CONSTRAINT [FK_tblCRMQuote_tblSOSalesorder_intSalesOrderId] FOREIGN KEY ([intSalesOrderId]) REFERENCES [dbo].[tblSOSalesOrder] ([intSalesOrderId])
)
