CREATE TABLE [dbo].[tblICInventoryStockAsOfDate]
(
	[intId] INT NOT NULL IDENTITY, 
	[intItemId] INT NOT NULL,
	[intItemLocationId] INT NOT NULL,
	[intItemUOMId] INT NULL,
	[dtmDate] DATETIME NOT NULL, 	
	[dblQty] NUMERIC(38, 20) NOT NULL DEFAULT 0, 
	CONSTRAINT [PK_tblICInventoryStockAsOfDate] PRIMARY KEY NONCLUSTERED ([intId]),
	CONSTRAINT [FK_tblICInventoryStockAsOfDate_tblICItem] FOREIGN KEY ([intItemId]) REFERENCES [tblICItem]([intItemId]),
	CONSTRAINT [FK_tblICInventoryStockAsOfDate_tblICItemLocation] FOREIGN KEY ([intItemLocationId]) REFERENCES [tblICItemLocation]([intItemLocationId]),
)
GO

CREATE CLUSTERED INDEX [IX_tblICInventoryStockAsOfDate]
ON [dbo].[tblICInventoryStockAsOfDate](
	[intItemId] ASC
	, [intItemLocationId] ASC
	, [intItemUOMId] ASC
	, [dtmDate] DESC
);

GO

