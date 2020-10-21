CREATE TABLE [dbo].[tblICEffectiveItemPricing]
(
	[intEffectiveItemPricingId] INT NOT NULL IDENTITY,
	[intItemId] INT NOT NULL,
	[intItemLocationId] INT NOT NULL,
	[dblCost] NUMERIC(38, 20) NOT NULL DEFAULT ((0)),
	[dtmEffectiveCostDate] DATETIME NOT NULL,
	[dblRetailPrice] NUMERIC(38, 20) NULL DEFAULT ((0)),
	[dtmEffectiveRetailPriceDate] DATETIME NULL,
	[intConcurrencyId] INT NULL DEFAULT ((0)),
	[dtmDateCreated] DATETIME NULL,
	[dtmDateModified] DATETIME NULL,
	[intCreatedByUserId] INT NULL,
	[intModifiedByUserId] INT NULL,
	CONSTRAINT [PK_tblICEffectiveItemPricing] PRIMARY KEY ([intEffectiveItemPricingId]),
	CONSTRAINT [FK_tblICEffectiveItemPricing_tblICItemLocation] FOREIGN KEY ([intItemLocationId]) REFERENCES [tblICItemLocation]([intItemLocationId]) ON DELETE CASCADE,
	CONSTRAINT [FK_tblICEffectiveItemPricing_tblICItem] FOREIGN KEY ([intItemId]) REFERENCES [tblICItem]([intItemId])
)