CREATE TABLE [dbo].[tblICEffectiveItemCost]
(
	[intEffectiveItemCostId] INT NOT NULL IDENTITY,
	[intItemId] INT NOT NULL,
	[intItemLocationId] INT NOT NULL,
	[dblCost] NUMERIC(38, 20) NOT NULL DEFAULT ((0)),
	[dtmEffectiveCostDate] DATETIME NOT NULL,
	[intConcurrencyId] INT NULL DEFAULT ((0)),
	[dtmDateCreated] DATETIME NULL,
	[dtmDateModified] DATETIME NULL,
	[intCreatedByUserId] INT NULL,
	[intModifiedByUserId] INT NULL,
	[intDataSourceId] TINYINT NULL,
	[intImportFlagInternal] INT NULL,
	[guiApiUniqueId] UNIQUEIDENTIFIER NULL,
	CONSTRAINT [PK_intEffectiveItemCostId] PRIMARY KEY ([intEffectiveItemCostId]),
	CONSTRAINT [FK_intEffectiveItemCostId_tblICItemLocation] FOREIGN KEY ([intItemLocationId]) REFERENCES [tblICItemLocation]([intItemLocationId]) ON DELETE CASCADE,
	CONSTRAINT [FK_intEffectiveItemCostId_tblICItem] FOREIGN KEY ([intItemId]) REFERENCES [tblICItem]([intItemId])
)