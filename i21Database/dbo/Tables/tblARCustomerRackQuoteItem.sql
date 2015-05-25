CREATE TABLE [dbo].[tblARCustomerRackQuoteItem]
(
	[intCustomerRackQuoteItemId]		INT			NOT NULL,
	[intCustomerRackQuoteHeaderId]		INT			NOT NULL,
	[intItemId]							INT         NULL,	
	[intConcurrencyId]					INT         CONSTRAINT [DF_tblARCustomerRackQuoteItem_intConcurrencyId] DEFAULT ((0)) NOT NULL,
	CONSTRAINT [PK_tblARCustomerRackQuoteItem] PRIMARY KEY CLUSTERED ([intCustomerRackQuoteItemId] ASC),
	CONSTRAINT [FK_tblARCustomerRackQuoteItem_tblARCustomerRackQuoteHeader] FOREIGN KEY ([intCustomerRackQuoteHeaderId]) REFERENCES [dbo].[tblARCustomerRackQuoteHeader] ([intCustomerRackQuoteHeaderId]) ON DELETE CASCADE,
	CONSTRAINT [FK_tblARCustomerRackQuoteItem_tblICItem] FOREIGN KEY ([intItemId]) REFERENCES [dbo].[tblICItem] ([intItemId])

)
