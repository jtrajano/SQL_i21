CREATE TABLE [dbo].[tblARCustomerRackQuoteHeader]
(	
	[intCustomerRackQuoteHeaderId]			INT			IDENTITY (1, 1) NOT NULL,
	[intEntityCustomerId]					INT			NOT NULL,
	[ysnQuoteAllAvailabeRackPrice]			BIT         NULL,
	[ysnShowTaxDetail]						BIT         NULL,
	[ysnShowFeightDetail]					BIT         NULL,
	[ysnShowTempAdjustments]				BIT         NULL,
	[ysnShowMargin]							BIT         NULL,
	[ysnShowLocation]						BIT         NULL,
	[intConcurrencyId]						INT         CONSTRAINT [DF_tblARCustomerRackQuoteHeader_intConcurrencyId] DEFAULT ((0)) NOT NULL,
	CONSTRAINT [PK_tblARCustomerRackQuoteHeader] PRIMARY KEY CLUSTERED ([intCustomerRackQuoteHeaderId] ASC),
	CONSTRAINT [FK_tblARCustomerRackQuoteHeader_tblARCustomer] FOREIGN KEY ([intEntityCustomerId]) REFERENCES [dbo].[tblARCustomer] ([intEntityId]) ON DELETE CASCADE
	
)
