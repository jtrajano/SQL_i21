CREATE TABLE [dbo].[tblEMEntityTariff]
(
	[intEntityTariffId]				INT IDENTITY(1,1) NOT NULL,
	[intEntityId]					INT,
	[strDescription]				NVARCHAR(50)  COLLATE Latin1_General_CI_AS NULL,
	[dtmEffectiveDate]				DATETIME NULL,
	[intEntityTariffTypeId]			INT NULL,
	[intConcurrencyId]    INT            CONSTRAINT [DF_tblEMEntityTariff_intConcurrencyId] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_tblEMEntityTariff] PRIMARY KEY CLUSTERED ([intEntityTariffId] ASC),     
	CONSTRAINT [FK_dbo_tblEMEntityTariff_tblEMEntity_intEntityId] FOREIGN KEY ([intEntityId]) REFERENCES [dbo].tblEMEntity ([intEntityId]) ON DELETE CASCADE,
	CONSTRAINT [FK_dbo_tblEMEntityTariff_tblEMEntityTariffType_intEntityTariffTypeId] FOREIGN KEY ([intEntityTariffTypeId]) REFERENCES [dbo].[tblEMEntityTariffType] ([intEntityTariffTypeId])
)
