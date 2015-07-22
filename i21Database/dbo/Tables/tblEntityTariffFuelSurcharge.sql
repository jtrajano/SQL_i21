CREATE TABLE [dbo].[tblEntityTariffFuelSurcharge]
(
	[intEntityTariffFuelSurchargeId]		INT IDENTITY(1,1) NOT NULL,
	[intEntityTariffId]						INT,
	[dblFuelSurcharge]						NUMERIC(8, 5),
	[dtmEffectiveDate]						DATETIME,
	[intConcurrencyId]						INT            CONSTRAINT [DF_tblEntityTariffFuelSurcharge_intConcurrencyId] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_tblEntityTariffFuelSurcharge] PRIMARY KEY CLUSTERED ([intEntityTariffFuelSurchargeId] ASC),     
	CONSTRAINT [FK_dbo_tblEntityTariffFuelSurcharge_tblEntityTariff_intEntityTariffId] FOREIGN KEY ([intEntityTariffId]) REFERENCES [dbo].[tblEntityTariff] ([intEntityTariffId]) ON DELETE CASCADE
)
