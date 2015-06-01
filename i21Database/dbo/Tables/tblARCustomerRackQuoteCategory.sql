CREATE TABLE [dbo].[tblARCustomerRackQuoteCategory]
(
	[intCustomerRackQuoteCategoryId]		INT			IDENTITY (1, 1) NOT NULL,
	[intCustomerRackQuoteHeaderId]			INT			NOT NULL,
	[intCategoryId]							INT         NOT NULL,	
	[intConcurrencyId]						INT         CONSTRAINT [DF_tblARCustomerRackQuoteCategory_intConcurrencyId] DEFAULT ((0)) NOT NULL,
	CONSTRAINT [PK_tblARCustomerRackQuoteCategory] PRIMARY KEY CLUSTERED ([intCustomerRackQuoteCategoryId] ASC),
	CONSTRAINT [FK_tblARCustomerRackQuoteCategory_tblARCustomerRackQuoteHeader] FOREIGN KEY ([intCustomerRackQuoteHeaderId]) REFERENCES [dbo].[tblARCustomerRackQuoteHeader] ([intCustomerRackQuoteHeaderId]) ON DELETE CASCADE,
	CONSTRAINT [FK_tblARCustomerRackQuoteCategory_tblICCategory] FOREIGN KEY ([intCategoryId]) REFERENCES [dbo].[tblICCategory] ([intCategoryId]) 
	
)
