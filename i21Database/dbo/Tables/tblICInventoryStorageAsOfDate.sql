CREATE TABLE [dbo].[tblICInventoryStorageAsOfDate]
(
	[intId] INT NOT NULL IDENTITY, 
	[intItemId] INT NOT NULL,
	[intItemLocationId] INT NOT NULL,
	[intItemUOMId] INT NULL,
	[dtmDate] DATETIME NOT NULL, 	
	[dblQty] NUMERIC(38, 20) NOT NULL DEFAULT 0, 
	CONSTRAINT [PK_tblICInventoryStorageAsOfDate] PRIMARY KEY NONCLUSTERED ([intId]),
	CONSTRAINT [FK_tblICInventoryStorageAsOfDate_tblICItem] FOREIGN KEY ([intItemId]) REFERENCES [tblICItem]([intItemId]),
	CONSTRAINT [FK_tblICInventoryStorageAsOfDate_tblICItemLocation] FOREIGN KEY ([intItemLocationId]) REFERENCES [tblICItemLocation]([intItemLocationId]),
)
GO

CREATE CLUSTERED INDEX [IX_tblICInventoryStorageAsOfDate]
ON [dbo].[tblICInventoryStorageAsOfDate](
	[intItemId] ASC
	, [intItemLocationId] ASC
	, [intItemUOMId] ASC
	, [dtmDate] DESC
);

GO

