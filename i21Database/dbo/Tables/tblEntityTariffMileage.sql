CREATE TABLE [dbo].[tblEntityTariffMileage]
(
	[intEntityTarifffMileageId]			INT IDENTITY(1,1) NOT NULL,
	[intEntityTariffId]					INT,
	[intFromMiles]						INT,
	[intToMiles]						INT,
	[dblCostRatePerUnit]				NUMERIC(18, 6) NULL DEFAULT ((0)), 
	[dblInvoiceRatePerUnit]				NUMERIC(18, 6) NULL DEFAULT ((0)), 
	[intConcurrencyId]						INT            CONSTRAINT [DF_tblEntityTariffMileage_intConcurrencyId] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_tblEntityTariffMileage] PRIMARY KEY CLUSTERED ([intEntityTarifffMileageId] ASC),     
	CONSTRAINT [FK_dbo_tblEntityTariffMileage_tblEntityTariff_intEntityTariffId] FOREIGN KEY ([intEntityTariffId]) REFERENCES [dbo].[tblEntityTariff] ([intEntityTariffId]) ON DELETE CASCADE
)
