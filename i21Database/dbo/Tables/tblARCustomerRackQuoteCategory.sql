CREATE TABLE [dbo].[tblARCustomerRackQuoteCategory]
(
	[intCustomerRackQuoteCategoryId]		INT			NOT NULL,
	[intCustomerRackQuoteHeaderId]			INT			NOT NULL,
	[intCategoryId]							INT         NULL,	
	[intConcurrencyId]						INT         CONSTRAINT [DF_tblARCustomerRackQuoteCategory_intConcurrencyId] DEFAULT ((0)) NOT NULL,
	CONSTRAINT [PK_tblARCustomerRackQuoteCategory] PRIMARY KEY CLUSTERED ([intCustomerRackQuoteCategoryId] ASC),
	CONSTRAINT [FK_tblARCustomerRackQuoteCategory_tblARCustomerRackQuoteHeader] FOREIGN KEY ([intCustomerRackQuoteHeaderId]) REFERENCES [dbo].[tblARCustomerRackQuoteHeader] ([intCustomerRackQuoteHeaderId]) ON DELETE CASCADE
	
)
