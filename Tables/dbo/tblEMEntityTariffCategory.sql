CREATE TABLE [dbo].[tblEMEntityTariffCategory]
(
	[intEntityTariffCategoryId]				INT IDENTITY(1,1) NOT NULL,
	[intEntityTariffId]						INT,	
	[intCategoryId]							INT	NULL,
	[intConcurrencyId]						INT            CONSTRAINT [DF_tblEMEntityTariffCategory_intConcurrencyId] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_tblEMEntityTariffCategory] PRIMARY KEY CLUSTERED ([intEntityTariffCategoryId] ASC),     
	CONSTRAINT [FK_dbo_tblEMEntityTariffCategory_tblEMEntityTariff_intEntityTariffId] FOREIGN KEY ([intEntityTariffId]) REFERENCES [dbo].[tblEMEntityTariff] ([intEntityTariffId]) ON DELETE CASCADE,
	CONSTRAINT [FK_dbo_tblEMEntityTariffCategory_tblICCategory_intCategoryId] FOREIGN KEY ([intCategoryId]) REFERENCES [dbo].[tblICCategory] ([intCategoryId])
)
