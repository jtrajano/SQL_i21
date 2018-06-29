CREATE TABLE [dbo].[tblBBBuybackExcluded](
	[intBuybackExcludedId] [int] IDENTITY(1,1) NOT NULL,
	[intInvoiceDetailId] INT NOT NULL, 
    [dtmExcludedDate] DATETIME NOT NULL, 
    [intConcurrencyId] INT NOT NULL DEFAULT 0, 
    CONSTRAINT [PK_tblBBBuybackExcluded] PRIMARY KEY ([intBuybackExcludedId]) 
	
)
GO
