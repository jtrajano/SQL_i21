CREATE TABLE [dbo].[tblARCustomerRackQuoteVendor]
(
	[intCustomerRackQuoteVendorId]			INT			IDENTITY (1, 1) NOT NULL,
	[intCustomerRackQuoteHeaderId]			INT			NOT NULL,
	[intSupplyPointId]						INT         NOT NULL,
	[ysnQuote]								BIT         NULL,	
	[intConcurrencyId]						INT         CONSTRAINT [DF_tblARCustomerRackQuoteVendor_intConcurrencyId] DEFAULT ((0)) NOT NULL,
	CONSTRAINT [PK_tblARCustomerRackQuoteVendor] PRIMARY KEY CLUSTERED ([intCustomerRackQuoteVendorId] ASC),
	CONSTRAINT [FK_tblARCustomerRackQuoteHeader_tblARCustomerRackQuoteHeader] FOREIGN KEY ([intCustomerRackQuoteHeaderId]) REFERENCES [dbo].[tblARCustomerRackQuoteHeader] ([intCustomerRackQuoteHeaderId]) ON DELETE CASCADE
)
