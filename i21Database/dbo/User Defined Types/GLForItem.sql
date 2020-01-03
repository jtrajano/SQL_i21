CREATE TYPE [dbo].[GLForItem] AS TABLE 
(
	intItemId INT
	,intItemLocationId INT
	,intItemUOMId INT
	,dtmDate Datetime
	,dblQty DECIMAL(24,10)
	,dblUOMQty DECIMAL(24,10)
	,dblCost DECIMAL(24,10)
	,dblSalesPrice DECIMAL(24,10)
	,intCurrencyId INT
	,dblExchangeRate DECIMAL(24,10)
	,intTransactionId INT
	,intTransactionDetailId INT
	,strTransactionId NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
	,intTransactionTypeId INT
	,intLotId INT
	,intSubLocationId INT
	,intStorageLocationId INT
	,ysnIsStorage BIT NULL
	,intStorageScheduleTypeId INT
)