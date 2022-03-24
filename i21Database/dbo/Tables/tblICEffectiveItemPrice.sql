CREATE TABLE [dbo].[tblICEffectiveItemPrice]
(
	[intEffectiveItemPriceId] INT NOT NULL IDENTITY,
	[intItemId] INT NOT NULL,
	[intItemLocationId] INT NOT NULL,
	[dblRetailPrice] NUMERIC(38, 20) NULL DEFAULT ((0)),
	[dtmEffectiveRetailPriceDate] DATETIME NULL,
	[intConcurrencyId] INT NULL DEFAULT ((0)),
	[dtmDateCreated] DATETIME NULL,
	[dtmDateModified] DATETIME NULL,
	[intCreatedByUserId] INT NULL,
	[intModifiedByUserId] INT NULL,
	[intDataSourceId] TINYINT NULL,
	[intImportFlagInternal] INT NULL,	
	[guiApiUniqueId] UNIQUEIDENTIFIER NULL,	
	CONSTRAINT [PK_tblICEffectiveItemPrice] PRIMARY KEY ([intEffectiveItemPriceId]),
	CONSTRAINT [FK_tblICEffectiveItemPrice_tblICItemLocation] FOREIGN KEY ([intItemLocationId]) REFERENCES [tblICItemLocation]([intItemLocationId]) ON DELETE CASCADE,
	CONSTRAINT [FK_tblICEffectiveItemPrice_tblICItem] FOREIGN KEY ([intItemId]) REFERENCES [tblICItem]([intItemId])
)