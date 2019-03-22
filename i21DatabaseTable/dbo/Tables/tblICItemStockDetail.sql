/*
## Overview
This table will hold the qty per UOM for an item per location. 
It only tracks the qty of those non-'Stock UOM's. 

## Fields, description, and mapping. 
*	[intItemStockUOMId] INT NOT NULL IDENTITY
	Internal id for this table. 
	Maps: None


## Important Notes:
	The cost fields like Average Cost, Last Cost, and Standard Cost are moved to tblICItemPricing table. The users can edit that cost from that table whereas editing of values are not allowed on this table. 

## Source Code:
*/
CREATE TABLE [dbo].[tblICItemStockDetail]
(
	[intItemStockDetailId] INT NOT NULL IDENTITY
	,[intItemStockTypeId] INT NOT NULL
	,[intItemId] INT NOT NULL
	,[intItemLocationId] INT NOT NULL
	,[intItemUOMId] INT NOT NULL
	,[intSubLocationId] INT NULL
	,[intStorageLocationId] INT NULL
	,[strTransactionId] NVARCHAR (50) COLLATE Latin1_General_CI_AS NOT NULL
	,[dblQty] NUMERIC(38, 20) NULL DEFAULT ((0))
	,[dtmDateCreated] DATETIME NULL
	,[dtmDateModified] DATETIME NULL
	,[intCreatedByUserId] INT NULL
	,[intModifiedByUserId] INT NULL
	,[intConcurrencyId] INT NULL DEFAULT ((1))
	,CONSTRAINT [PK_tblICItemStockDetail] PRIMARY KEY NONCLUSTERED ([intItemStockDetailId])
	,CONSTRAINT [FK_tblICItemStockDetail_tblICItemStockType] FOREIGN KEY ([intItemStockTypeId]) REFERENCES [tblICItemStockType]([intItemStockTypeId])
	,CONSTRAINT [FK_tblICItemStockDetail_tblICItem] FOREIGN KEY ([intItemId]) REFERENCES [tblICItem]([intItemId])
	,CONSTRAINT [FK_tblICItemStockDetail_tblICItemLocation] FOREIGN KEY ([intItemLocationId]) REFERENCES [tblICItemLocation]([intItemLocationId])
	,CONSTRAINT [FK_tblICItemStockDetail_tblICItemUOM] FOREIGN KEY ([intItemUOMId]) REFERENCES [tblICItemUOM]([intItemUOMId])
)
GO 

CREATE CLUSTERED INDEX [IDX_tblICItemStockDetail]
ON [dbo].[tblICItemStockDetail](
	[intItemStockTypeId] ASC
	,[intItemId] ASC
	,[intItemLocationId] ASC
	,[intItemStockDetailId] ASC 
);
GO

CREATE NONCLUSTERED INDEX [IX_tblICItemStockDetail]
ON [dbo].[tblICItemStockDetail](
	[intItemId] ASC
	,[intItemLocationId] ASC 
	,[intItemStockTypeId] ASC
)
INCLUDE(
	intItemUOMId
	,intSubLocationId
	,intStorageLocationId 
	,dblQty
);
GO
