CREATE PROCEDURE [dbo].[uspICCalculateFIFOCost] (
    @ItemId INT,                     -- The primary ID of the inventory item.
    @LocationId INT,                 -- The primary ID of the company location.
    @Quantity NUMERIC(38, 20),       -- The quantity sold.
    @Date DATETIME,                  -- The date of transaction. This is optional and will default to the current date.
    @Cost NUMERIC(18, 6) OUTPUT,     -- The cost of the item. This is the output value of this procedure.
    @ItemUOMId INT,                  -- The item UOM ID. This is optional and will default to ID of the GALLONS uom.
    @ShowBucket BIT = 0              -- Lists the cost bucket
)
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS ON

DECLARE @CategoryId INT
DECLARE @UnitQty INT
DECLARE @LastCost NUMERIC(18, 6)
DECLARE @StandardCost NUMERIC(18, 6)
DECLARE @AverageCost NUMERIC(18, 6)
DECLARE @ItemLocationId INT
DECLARE @StockUOMId INT

IF @Date IS NULL
    SET @Date = GETDATE()

IF (@ItemUOMId IS NULL)
  SELECT @ItemUOMId = intItemUOMId FROM vyuICItemUOM WHERE strUnitMeasure = 'GALLON' AND intItemId = @ItemId

SELECT @CategoryId = intCategoryId FROM tblICItem WHERE intItemId = @ItemId
SELECT @UnitQty = dblUnitQty FROM vyuICItemUOM WHERE intItemUOMId = @ItemUOMId

SELECT @ItemLocationId = intItemLocationId FROM tblICItemLocation WHERE intLocationId = @LocationId AND intItemId = @ItemId
SELECT @LastCost = dblLastCost, @StandardCost = dblStandardCost, @AverageCost = dblAverageCost FROM tblICItemPricing WHERE intItemId = @ItemId AND intItemLocationId = @ItemLocationId
DECLARE @DefaultCurrencyId AS INT = dbo.fnSMGetDefaultCurrency('FUNCTIONAL')

IF @ItemUOMId IS NULL
BEGIN
  RAISERROR('Invalid Item UOM Id', 11, 1)
  RETURN
END

IF @ItemId IS NULL
BEGIN
  RAISERROR('Invalid Item Id.', 11, 1)
  RETURN
END

IF @ItemLocationId IS NULL
BEGIN
  RAISERROR('Invalid Item Location Id.', 11, 1)
  RETURN
END

SELECT @StockUOMId = iu.intItemUOMId 
FROM tblICItemUOM iu
WHERE iu.intItemId = @ItemId
	AND iu.ysnStockUnit = 1


begin tran

DECLARE @ACCOUNT_CATEGORY_TO_COUNTER_INVENTORY AS NVARCHAR(255) = 'Inventory Adjustment'
DECLARE @BatchId NVARCHAR(40) = ''
DECLARE @InventoryCount_TransactionType INT = 10
DECLARE @strCountDescription AS NVARCHAR(255)
DECLARE @ItemsForConsignment AS ItemCostingTableType
DECLARE @strTransactionId AS NVARCHAR(50) = CAST(NEWID() AS NVARCHAR(50))

INSERT INTO @ItemsForConsignment (  
      intItemId  
    , intItemLocationId 
    , intItemUOMId  
    , dtmDate  
    , dblQty  
    , dblUOMQty  
    , dblCost  
    , dblValue 
    , dblSalesPrice  
    , intCurrencyId  
    , dblExchangeRate  
    , intTransactionId  
    , intTransactionDetailId  
    , strTransactionId   
    , intTransactionTypeId  
    , intLotId 
    , intSubLocationId
    , intStorageLocationId
    , dblForexRate
    , intCategoryId
)
SELECT    
      intItemId = @ItemId
    , intItemLocationId = @ItemLocationId
    , intItemUOMId = @ItemUOMId
    , dtmDate = @Date
    , dblQty = -@Quantity
    , dblUOMQty = @UnitQty
    , dblCost = COALESCE(dbo.fnICGetItemRunningCost(@ItemId, @LocationId, NULL, NULL, NULL, NULL, NULL, @Date, 0), @LastCost, @StandardCost, 0) 
    , dblValue = 0
    , dblSalesPrice = 0
    , intCurrencyId = @DefaultCurrencyId
    , dblExchangeRate = 1
    , intTransactionId = 1
    , intTransactionDetailId = 1
    , strTransactionId = @strTransactionId
    , intTransactionTypeId = @InventoryCount_TransactionType
    , intLotId = NULL
    , intSubLocationId = NULL
    , intStorageLocationId = NULL
    , dblForexRate = 1
    , intCategoryId = @CategoryId

EXEC dbo.uspICPostCosting 
      @ItemsForConsignment  
    , @BatchId  
    , @ACCOUNT_CATEGORY_TO_COUNTER_INVENTORY
    , 1
    , @strCountDescription
    , 0
    , 0
    , 1

DECLARE @LastTransactionId INT
DECLARE @FirstTransactionId INT
DECLARE @TransactionId INT
DECLARE @TransactionQty NUMERIC(38, 20)
DECLARE @TransactionCost NUMERIC(38, 20)
DECLARE @RunningQty NUMERIC(38, 20)
DECLARE @MovingAverageCost NUMERIC(38, 20)
DECLARE @IsAvg BIT = 0
-- 1: AVG
-- 2: FIFO
-- 3: LIFO
-- 4: LOT
-- 5: Actual
-- 6: CATEGORY
DECLARE @CostingMethod INT
SELECT @CostingMethod = dbo.fnGetCostingMethod(@ItemId, @ItemLocationId)

IF @CostingMethod = 2 -- FIFO
BEGIN
 --   DECLARE @RunningTotals TABLE (
	--	RowNumber INT
	--	, TransactionId INT
	--	, Date DATETIME
	--	, Qty NUMERIC(38, 20)
	--	, RunningQty NUMERIC(38, 20)
	--	, Cost NUMERIC(18, 6)
	--	, AvgCost NUMERIC(18, 6)
	--	, ItemUOMId INT
	--)

  --  INSERT INTO @RunningTotals
  --  SELECT 
		--ROW_NUMBER() OVER (ORDER BY t.dtmDate ASC) RowNumber,
  --      t.intTransactionId,
  --      t.dtmDate,
  --      dbo.fnCalculateQtyBetweenUOM(t.intItemUOMId, @StockUOMId, t.dblQty) dblQty,
  --      SUM(dbo.fnCalculateQtyBetweenUOM(t.intItemUOMId, @StockUOMId, t.dblQty)) OVER (ORDER BY t.dtmDate ASC) as dblRunningQty,
  --      dbo.fnCalculateCostBetweenUOM(t.intItemUOMId, @StockUOMId, t.dblCost) dblCost,
  --      AVG(dbo.fnCalculateCostBetweenUOM(t.intItemUOMId, @StockUOMId, t.dblCost)) OVER(ORDER BY t.dtmDate ASC ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) AvgCost,
  --      t.intItemUOMId
  --  FROM tblICInventoryTransaction t
  --  WHERE 
		--t.intItemId = @ItemId
  --      AND t.intItemLocationId = @ItemLocationId
  --      AND t.dblQty > 0
  --      AND t.ysnIsUnposted = 0
  --      AND dbo.fnDateLessThanEquals(CONVERT(VARCHAR(10), t.dtmDate,112), @Date) = 1
  --  ORDER BY t.dtmDate ASC
	
  --  DECLARE @MinRow INT
  --  SELECT @MinRow = MIN(RowNumber)
  --  FROM @RunningTotals
  --  WHERE RunningQty >= @Quantity

  --  SELECT @Cost = AVG(Cost) OVER(ORDER BY RowNumber DESC ROWS BETWEEN 2 PRECEDING AND CURRENT ROW)
  --  FROM @RunningTotals
  --  WHERE RowNumber <= @MinRow

    --IF @Cost IS NULL
    --  SELECT @Cost = (SELECT TOP 1 AvgCost FROM @RunningTotals ORDER BY RowNumber DESC)

	-- Get the cost from generated inventory transaction.
	IF EXISTS (
		SELECT 1 
		FROM (
			SELECT cnt = COUNT(t.intInventoryTransactionId) 
			FROM tblICInventoryTransaction t 
			WHERE 
				t.strTransactionId = @strTransactionId 
				AND t.ysnIsUnposted = 0
		) c 
		WHERE 
			c.cnt > 1 
	) 
	BEGIN 
		SELECT 
			@Cost = 
				dbo.fnDivide(
					SUM(dbo.fnMultiply(t.dblQty, t.dblCost) + ISNULL(t.dblValue, 0)) 
					,SUM(t.dblQty)
				)
		FROM 
			tblICInventoryTransaction t 
		WHERE 
			t.strTransactionId = @strTransactionId 
			AND t.ysnIsUnposted = 0
			AND t.dblQty <> 0 
	END 
	ELSE 
	BEGIN 
		SELECT 
			@Cost = t.dblCost 				
		FROM 
			tblICInventoryTransaction t 
		WHERE 
			t.strTransactionId = @strTransactionId 
			AND t.ysnIsUnposted = 0
			AND t.dblQty <> 0 
	END 

    IF @ShowBucket = 1
    BEGIN
        --SELECT * FROM @RunningTotals
		SELECT 
			t.*	
		FROM 
			tblICInventoryTransaction t 
		WHERE 
			t.strTransactionId = @strTransactionId 
			AND t.ysnIsUnposted = 0

        SELECT 
			'Costs'
			, @Cost Cost
			, @LastCost LastCost
			, @StandardCost StdCost
			, @AverageCost AvgCost
			, dbo.fnICGetItemRunningCost(@ItemId, @LocationId, NULL, NULL, NULL, NULL, NULL, @Date, 0) fnRunning
			, dbo.fnICGetMovingAverageCost(@ItemId, @ItemLocationId, @LastTransactionId) fnAvg
    END
END
ELSE
BEGIN
    RAISERROR('Invalid Costing Method. Must be FIFO.', 11, 1)
END

rollback

GO