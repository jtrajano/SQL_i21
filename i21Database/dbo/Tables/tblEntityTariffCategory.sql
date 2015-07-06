CREATE TABLE [dbo].[tblEntityTariffCategory]
(
	[intEntityTariffCategoryId]				INT IDENTITY(1,1) NOT NULL,
	[intEntityTariffId]						INT,
	[strCategory]							NVARCHAR(50),
	[intConcurrencyId]						INT            CONSTRAINT [DF_tblEntityTariffCategory_intConcurrencyId] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_tblEntityTariffCategory] PRIMARY KEY CLUSTERED ([intEntityTariffCategoryId] ASC),     
	CONSTRAINT [FK_dbo_tblEntityTariffCategory_tblEntityTariff_intEntityTariffId] FOREIGN KEY ([intEntityTariffId]) REFERENCES [dbo].[tblEntityTariff] ([intEntityTariffId]) ON DELETE CASCADE
)
