CREATE TABLE [dbo].[tblTRComboFreightShipVia]
(
	[intComboFreightShipViaId] INT NOT NULL IDENTITY,
	[intShipViaEntityId] INT NULL,
	[dblMinimumUnit] DECIMAL(18, 6) NOT NULL,
	[strFreightRateType] NVARCHAR(100) COLLATE Latin1_General_CI_AS NOT NULL,
	[strGallonType]  NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
	[intCategoryId] INT NULL,
	[dtmEffectiveDateTime] DATETIME NULL,
	[intConcurrencyId] INT NOT NULL DEFAULT ((1)),
	CONSTRAINT [PK_tblTRComboFreightShipVia] PRIMARY KEY ([intComboFreightShipViaId]),
	CONSTRAINT [FK_tblTRComboFreightShipVia_tblSMShipVia_intShipViaEntityId] FOREIGN KEY ([intShipViaEntityId]) REFERENCES [dbo].[tblSMShipVia] (intEntityId),
	CONSTRAINT [FK_tblTRComboFreightShipVia_tblICCategory] FOREIGN KEY ([intCategoryId]) REFERENCES [tblICCategory]([intCategoryId]),
	CONSTRAINT [AK_tblTRComboFreightShipVia_UniqueCombo] UNIQUE ([intShipViaEntityId],[strFreightRateType],[strGallonType],[intCategoryId],[dtmEffectiveDateTime])
)
