CREATE TABLE [dbo].[tblTRComboFreightCustomer]
(
	[intComboFreightCustomerId] INT NOT NULL IDENTITY,
	[intCustomerEntityId] INT NULL,
	[intCustomerLocationId] INT NULL,
	[dblMinimumUnit] DECIMAL(18, 6) NOT NULL,
	[strFreightRateType] NVARCHAR(100) COLLATE Latin1_General_CI_AS NOT NULL,
	[strGallonType]  NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
	[intCategoryId] INT NULL,
	[dtmEffectiveDateTime] DATETIME NULL,
	[intConcurrencyId] INT NOT NULL DEFAULT ((1)),
	CONSTRAINT [PK_tblTRComboFreightCustomer] PRIMARY KEY ([intComboFreightCustomerId]),
	CONSTRAINT [FK_tblTRComboFreightCustomer_tblARCustomer_intCustomerEntityId] FOREIGN KEY ([intCustomerEntityId]) REFERENCES [dbo].[tblARCustomer] (intEntityId),
	CONSTRAINT [FK_tblTRComboFreightCustomer_tblEMEntityLocation_intCustomerLocationId] FOREIGN KEY ([intCustomerLocationId]) REFERENCES [dbo].[tblEMEntityLocation] (intEntityLocationId),
	CONSTRAINT [FK_tblTRComboFreightCustomer_tblICCategory] FOREIGN KEY ([intCategoryId]) REFERENCES [tblICCategory]([intCategoryId]),
	CONSTRAINT [AK_tblTRComboFreightCustomer_UniqueCombo] UNIQUE ([intCustomerEntityId],[intCustomerLocationId],[strFreightRateType],[strGallonType],[intCategoryId],[dtmEffectiveDateTime])
)
