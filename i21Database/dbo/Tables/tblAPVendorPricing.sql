CREATE TABLE [dbo].[tblAPVendorPricing]
(
	[intVendorPricingId] INT NOT NULL PRIMARY KEY IDENTITY(1,1),
	[intEntityVendorId] INT NOT NULL,
	[intEntityLocationId] INT NULL,
	[intItemId] int not null,
	[intItemUOMId] int not null,
	[dtmBeginDate] datetime not null,
	[dtmEndDate] datetime not null,
	[dblUnit] numeric(18,6) not null,
	[intCurrencyId] INT NULL,
	[intConcurrencyId] int default(0),

	CONSTRAINT [FK_tblAPVendorPricing_tblAPVendor_intEntityVendorId] FOREIGN KEY ([intEntityVendorId]) REFERENCES [tblAPVendor]([intEntityId]) ON DELETE CASCADE,
	CONSTRAINT [FK_tblAPVendorPricing_tblICItem_intItemId] FOREIGN KEY (intItemId) REFERENCES [tblICItem](intItemId),
	CONSTRAINT [FK_tblAPVendorPricing_tblICUnitMeasure_intItemUOM] FOREIGN KEY (intItemUOMId) REFERENCES [tblICUnitMeasure](intUnitMeasureId),
	CONSTRAINT [FK_tblAPVendorPricing_tblSMCurrency_intCurrencyId] FOREIGN KEY ([intCurrencyId]) REFERENCES [tblSMCurrency]([intCurrencyID])



)
