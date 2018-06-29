CREATE TABLE [dbo].[tblEMEntityTariffFuelSurcharge]
(
	[intEntityTariffFuelSurchargeId]		INT IDENTITY(1,1) NOT NULL,
	[intEntityTariffId]						INT,
	[dblFuelSurcharge]						NUMERIC(18, 6),
	[dtmEffectiveDate]						DATETIME,
	[intConcurrencyId]						INT            CONSTRAINT [DF_tblEMEntityTariffFuelSurcharge_intConcurrencyId] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_tblEMEntityTariffFuelSurcharge] PRIMARY KEY CLUSTERED ([intEntityTariffFuelSurchargeId] ASC),     
	CONSTRAINT [FK_dbo_tblEMEntityTariffFuelSurcharge_tblEMEntityTariff_intEntityTariffId] FOREIGN KEY ([intEntityTariffId]) REFERENCES [dbo].[tblEMEntityTariff] ([intEntityTariffId]) ON DELETE CASCADE
)
