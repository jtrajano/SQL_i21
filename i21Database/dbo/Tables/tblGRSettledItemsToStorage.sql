CREATE TABLE [dbo].[tblGRSettledItemsToStorage]
(
	[intSettledItemsToStorage] INT IDENTITY(1,1)
	,[intItemId] INT NOT NULL
	,[intItemLocationId] INT NULL
	,[intItemUOMId] INT NULL
	,[dtmDate] DATETIME NOT NULL
    ,[dblQty] NUMERIC(38, 20) NOT NULL DEFAULT 0
	,[dblUOMQty] NUMERIC(38, 20) NOT NULL DEFAULT 1
    ,[dblCost] NUMERIC(38, 20) NOT NULL DEFAULT 0
	,[dblSalesPrice] NUMERIC(18, 6) NOT NULL DEFAULT 0
	,[intCurrencyId] INT NULL
	,[dblExchangeRate] NUMERIC (38, 20) DEFAULT 1 NOT NULL
    ,[intTransactionId] INT NOT NULL
	,[intTransactionDetailId] INT NULL
	,[strTransactionId] NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL
	,[intTransactionTypeId] INT NOT NULL
	,[intLotId] INT NULL
	,[intSubLocationId] INT NULL
	,[intStorageLocationId] INT NULL
	,[ysnIsStorage] BIT NULL
	,[intConcurrencyId] INT NOT NULL DEFAULT 1
)
