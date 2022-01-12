CREATE TABLE [dbo].[tblICInventoryDailyTransaction]
(
	[intId] INT NOT NULL IDENTITY, 
	[intItemId] INT NOT NULL,
	[intItemLocationId] INT NOT NULL,
	[intInTransitSourceLocationId] INT NULL,
	[intCompanyLocationId] INT NULL,
	[intSubLocationId] INT NULL,
	[intStorageLocationId] INT NULL,
	[intItemUOMId] INT NULL,
	[intCompanyId] INT NULL, 
	[dtmDate] DATETIME NOT NULL, 	
	[dblQty] NUMERIC(38, 20) NOT NULL DEFAULT 0, 
	[dblValue] NUMERIC(38, 20) NULL, 
	[dblValueRounded] NUMERIC(38, 20) NULL, 
	CONSTRAINT [PK_tblICInventoryDailyTransaction] PRIMARY KEY NONCLUSTERED ([intId]),
	CONSTRAINT [FK_tblICInventoryDailyTransaction_tblICItem] FOREIGN KEY ([intItemId]) REFERENCES [tblICItem]([intItemId]),
	CONSTRAINT [FK_tblICInventoryDailyTransaction_tblICItemLocation] FOREIGN KEY ([intItemLocationId]) REFERENCES [tblICItemLocation]([intItemLocationId]),
	CONSTRAINT [FK_tblICInventoryDailyTransaction_tblSMCompanyLocationSubLocation] FOREIGN KEY ([intSubLocationId]) REFERENCES [tblSMCompanyLocationSubLocation]([intCompanyLocationSubLocationId]),
	CONSTRAINT [FK_tblICInventoryDailyTransaction_tblICStorageLocation] FOREIGN KEY ([intStorageLocationId]) REFERENCES [tblICStorageLocation]([intStorageLocationId])
)
GO

CREATE CLUSTERED INDEX [IX_tblICInventoryDailyTransaction]
ON [dbo].[tblICInventoryDailyTransaction](
	[intItemId] ASC
	, [intItemLocationId] ASC
	, [intInTransitSourceLocationId] ASC 
	, [intCompanyLocationId] ASC
	, [intSubLocationId] ASC
	, [intStorageLocationId] ASC
	, [intItemUOMId] ASC
	, [intCompanyId] ASC
	, [dtmDate] ASC
);

GO

