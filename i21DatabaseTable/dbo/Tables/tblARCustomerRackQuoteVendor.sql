CREATE TABLE [dbo].[tblARCustomerRackQuoteVendor]
(
	[intCustomerRackQuoteVendorId]			INT			IDENTITY (1, 1) NOT NULL,
	[intCustomerRackQuoteHeaderId]			INT			NOT NULL,
	[intSupplyPointId]						INT         NULL,
	[ysnQuote]								BIT         NULL,
	[intEntityCustomerLocationId]			INT			NULL,	
	[intCompanyId]							INT			NULL,
	[intConcurrencyId]						INT         CONSTRAINT [DF_tblARCustomerRackQuoteVendor_intConcurrencyId] DEFAULT ((0)) NOT NULL,
	CONSTRAINT [PK_tblARCustomerRackQuoteVendor] PRIMARY KEY CLUSTERED ([intCustomerRackQuoteVendorId] ASC),
	CONSTRAINT [FK_tblARCustomerRackQuoteHeader_tblARCustomerRackQuoteHeader] FOREIGN KEY ([intCustomerRackQuoteHeaderId]) REFERENCES [dbo].[tblARCustomerRackQuoteHeader] ([intCustomerRackQuoteHeaderId]) ON DELETE CASCADE,
	CONSTRAINT [FK_tblARCustomerRackQuoteHeader_tblTRSupplyPoint] FOREIGN KEY ([intSupplyPointId]) REFERENCES [dbo].[tblTRSupplyPoint] ([intSupplyPointId]),
	CONSTRAINT [FK_tblARCustomerRackQuoteHeader_tblEMEntityLocation] FOREIGN KEY ([intEntityCustomerLocationId]) REFERENCES [dbo].[tblEMEntityLocation]([intEntityLocationId]),
	CONSTRAINT [UK_tblARCustomerRackQuoteHeader_intSupplyPointId_intEntityCustomerLocationId] UNIQUE NONCLUSTERED ([intEntityCustomerLocationId] ASC, [intSupplyPointId] ASC)	

)
