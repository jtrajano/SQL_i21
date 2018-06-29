CREATE TABLE [dbo].[tblEMEntityTariffMileage]
(
	[intEntityTarifffMileageId]			INT IDENTITY(1,1) NOT NULL,
	[intEntityTariffId]					INT,
	[intFromMiles]						INT,
	[intToMiles]						INT,
	[dblCostRatePerUnit]				NUMERIC(18, 6) NULL DEFAULT ((0)), 
	[dblInvoiceRatePerUnit]				NUMERIC(18, 6) NULL DEFAULT ((0)), 
	[intConcurrencyId]						INT            CONSTRAINT [DF_tblEMEntityTariffMileage_intConcurrencyId] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_tblEMEntityTariffMileage] PRIMARY KEY CLUSTERED ([intEntityTarifffMileageId] ASC),     
	CONSTRAINT [FK_dbo_tblEMEntityTariffMileage_tblEMEntityTariff_intEntityTariffId] FOREIGN KEY ([intEntityTariffId]) REFERENCES [dbo].[tblEMEntityTariff] ([intEntityTariffId]) ON DELETE CASCADE
)
