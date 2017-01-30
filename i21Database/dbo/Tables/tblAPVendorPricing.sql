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
	[intConcurrencyId] int default(0),

	CONSTRAINT [FK_tblAPVendorPricing_tblAPVendor_intEntityVendorId] FOREIGN KEY ([intEntityVendorId]) REFERENCES [tblAPVendor]([intEntityVendorId]) ON DELETE CASCADE,
	CONSTRAINT [FK_tblAPVendorPricing_tblICItem_intItemId] FOREIGN KEY (intItemId) REFERENCES [tblICItem](intItemId),
	CONSTRAINT [FK_tblAPVendorPricing_tblICUnitMeasure_intItemUOM] FOREIGN KEY (intItemUOMId) REFERENCES [tblICUnitMeasure](intUnitMeasureId),



)
