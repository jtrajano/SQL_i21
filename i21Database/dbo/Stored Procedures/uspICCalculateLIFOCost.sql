CREATE PROCEDURE [dbo].[uspICCalculateLIFOCost] (
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
      @ItemId
    , @ItemLocationId
    , @ItemUOMId
    , @Date
    , -@Quantity
    , @UnitQty
    , COALESCE(dbo.fnICGetItemRunningCost(@ItemId, @LocationId, NULL, NULL, NULL, NULL, NULL, @Date, 0), @LastCost, @StandardCost, 0)
    , 0
    , 0
    , @DefaultCurrencyId
    , 1
    , 1
    , 1
    , CAST(NEWID() AS nvarchar(200))
    , @InventoryCount_TransactionType
    , NULL
    , NULL
    , NULL
    , 1
    , @CategoryId

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

IF @CostingMethod = 3 -- LIFO
BEGIN
    DECLARE @RunningTotals TABLE (RowNumber INT, TransactionId INT, Date DATETIME, Qty NUMERIC(38, 20), RunningQty NUMERIC(38, 20), 
      Cost NUMERIC(18, 6), AvgCost NUMERIC(18, 6), ItemUOMId INT)

    INSERT INTO @RunningTotals
    SELECT ROW_NUMBER() OVER (ORDER BY t.dtmDate DESC) RowNumber,
        t.intTransactionId,
        t.dtmDate,
        dbo.fnCalculateQtyBetweenUOM(t.intItemUOMId, @StockUOMId, t.dblQty) dblQty,
        SUM(dbo.fnCalculateQtyBetweenUOM(t.intItemUOMId, @StockUOMId, t.dblQty)) OVER (ORDER BY t.dtmDate DESC) as dblRunningQty,
        dbo.fnCalculateCostBetweenUOM(t.intItemUOMId, @StockUOMId, t.dblCost) dblCost,
        AVG(dbo.fnCalculateCostBetweenUOM(t.intItemUOMId, @StockUOMId, t.dblCost)) OVER(ORDER BY t.dtmDate DESC ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) AvgCost,
        t.intItemUOMId
    FROM tblICInventoryTransaction t
    WHERE t.intItemId = @ItemId
        AND t.intItemLocationId = @ItemLocationId
        AND t.dblQty > 0
        AND t.ysnIsUnposted = 0
        AND dbo.fnDateLessThanEquals(CONVERT(VARCHAR(10), t.dtmDate,112), @Date) = 1
    ORDER BY t.dtmDate DESC

    -- DECLARE @RowNumber INT

    -- SELECT TOP 1 @RowNumber = RowNumber FROM @RunningTotals WHERE RunningQty >= @Quantity

    -- IF @RowNumber = 1
    --     SELECT @Cost = Cost FROM @RunningTotals WHERE RowNumber = 1
    -- ELSE
    -- BEGIN
    --     DECLARE @MinRow INT
    --     SELECT @MinRow = MIN(RowNumber)
    --     FROM @RunningTotals
    --     WHERE RunningQty >= @Quantity

    --     SELECT *, AVG(Cost) OVER(ORDER BY RowNumber ASC ROWS BETWEEN 2 PRECEDING AND CURRENT ROW)
    --     FROM @RunningTotals
    --     --WHERE RunningQty >= @Quantity

    --     SELECT @Cost = AVG(Cost) OVER(ORDER BY RowNumber ASC ROWS BETWEEN 2 PRECEDING AND CURRENT ROW)
    --     FROM @RunningTotals
    --     WHERE RowNumber <= @MinRow

    --     IF @Cost IS NULL
    --       SELECT @Cost = @LastCost--(SELECT TOP 1 AvgCost FROM @RunningTotals ORDER BY RowNumber DESC)
    -- END

    DECLARE @MinRow INT
    SELECT @MinRow = MIN(RowNumber)
    FROM @RunningTotals
    WHERE RunningQty >= @Quantity

    SELECT *, AVG(Cost) OVER(ORDER BY RowNumber ASC ROWS BETWEEN 2 PRECEDING AND CURRENT ROW)
    FROM @RunningTotals
    --WHERE RunningQty >= @Quantity

    SELECT @Cost = AVG(Cost) OVER(ORDER BY RowNumber ASC ROWS BETWEEN 2 PRECEDING AND CURRENT ROW)
    FROM @RunningTotals
    WHERE RowNumber <= @MinRow

    IF @Cost IS NULL
        SELECT @Cost = (SELECT TOP 1 AvgCost FROM @RunningTotals ORDER BY RowNumber DESC)

    IF @ShowBucket = 1
    BEGIN
        -- SELECT 'Avg', * FROM @RunningTotals
        SELECT 'Costs', @Cost Cost, @LastCost LastCost, @StandardCost StdCost, @AverageCost AvgCost, 
        dbo.fnICGetItemRunningCost(@ItemId, @LocationId, NULL, NULL, NULL, NULL, NULL, @Date, 0) fnRunning,
        dbo.fnICGetMovingAverageCost(@ItemId, @ItemLocationId, @LastTransactionId) fnAvg
    END
END
ELSE
BEGIN
    RAISERROR('Invalid Costing Method. Must be LIFO.', 11, 1)
END

rollback

