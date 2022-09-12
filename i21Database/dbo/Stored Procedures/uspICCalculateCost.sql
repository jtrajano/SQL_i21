CREATE PROCEDURE [dbo].[uspICCalculateCost] (
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

IF @Date IS NULL
    SET @Date = GETDATE()

IF (@ItemUOMId IS NULL)
  SELECT @ItemUOMId = intItemUOMId FROM vyuICItemUOM WHERE strUnitMeasure = 'GALLON'

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
DECLARE @IsAvgLifo BIT
-- 1: AVG
-- 2: FIFO
-- 3: LIFO
-- 4: LOT
-- 5: Actual
-- 6: CATEGORY
DECLARE @CostingMethod INT
SELECT @CostingMethod = dbo.fnGetCostingMethod(@ItemId, @ItemLocationId)

SELECT TOP 1 @LastTransactionId = t.intInventoryTransactionId
FROM tblICInventoryTransaction t
WHERE t.intItemId = @ItemId
  AND t.intItemLocationId = @ItemLocationId
  AND t.dblQty > 0
  AND t.ysnIsUnposted = 0
  AND dbo.fnDateLessThanEquals(CONVERT(VARCHAR(10), t.dtmDate,112), @Date) = 1
ORDER BY t.intInventoryTransactionId DESC

SELECT TOP 1 @FirstTransactionId = t.intInventoryTransactionId
FROM tblICInventoryTransaction t
WHERE t.intItemId = @ItemId
  AND t.intItemLocationId = @ItemLocationId
  AND t.dblQty > 0
  AND t.ysnIsUnposted = 0
  AND dbo.fnDateLessThanEquals(CONVERT(VARCHAR(10), t.dtmDate,112), @Date) = 1
ORDER BY t.intInventoryTransactionId ASC

DECLARE cur CURSOR LOCAL FAST_FORWARD
FOR 
  SELECT t.intInventoryTransactionId, t.dblQty, t.dblCost
  FROM tblICInventoryTransaction t
  WHERE t.intItemId = @ItemId
    AND t.intItemLocationId = @ItemLocationId
    AND t.dblQty > 0
    -- AND t.ysnIsUnposted = 0
    AND dbo.fnDateLessThanEquals(CONVERT(VARCHAR(10), t.dtmDate,112), @Date) = 1
  ORDER BY t.intInventoryTransactionId DESC

OPEN cur

FETCH NEXT FROM cur INTO @TransactionId, @TransactionQty, @TransactionCost

WHILE @@FETCH_STATUS = 0 
BEGIN  
--  SET @MovingAverageCost = dbo.fnCalculateAverageCost(@TransactionQty, @TransactionCost, @RunningQty, ISNULL(@MovingAverageCost, 0))
  
  IF @Quantity <= @RunningQty
  BEGIN
    SET @LastTransactionId = @TransactionId
  END

  IF @RunningQty < @Quantity
  BEGIN
    SET @IsAvgLifo = 1
  END

  SET @RunningQty = ISNULL(@RunningQty, 0) + @TransactionQty

  FETCH NEXT FROM cur INTO @TransactionId, @TransactionQty, @TransactionCost
END

CLOSE cur
DEALLOCATE cur

IF @CostingMethod = 2 -- FIFO
SET @Cost = ISNULL(dbo.fnICGetMovingAverageCost(@ItemId, @ItemLocationId, @LastTransactionId), @LastCost)

IF @CostingMethod = 1 -- AVG
  SET @Cost = ISNULL(dbo.fnICGetItemRunningCost(@ItemId, @LocationId, NULL, NULL, NULL, NULL, NULL, @Date, 0), @AverageCost)

IF @CostingMethod = 3 -- LIFO
BEGIN
  DECLARE curLifo CURSOR LOCAL FAST_FORWARD
  FOR 
    SELECT t.intInventoryTransactionId, t.dblQty, t.dblCost
    FROM tblICInventoryTransaction t
    WHERE t.intItemId = @ItemId
      AND t.intItemLocationId = @ItemLocationId
      AND t.dblQty > 0
      -- AND t.ysnIsUnposted = 0
      AND dbo.fnDateLessThanEquals(CONVERT(VARCHAR(10), t.dtmDate,112), @Date) = 1
    ORDER BY t.intInventoryTransactionId ASC

  OPEN curLifo

  FETCH NEXT FROM curLifo INTO @TransactionId, @TransactionQty, @TransactionCost

  WHILE @@FETCH_STATUS = 0 
  BEGIN  
  --  SET @MovingAverageCost = dbo.fnCalculateAverageCost(@TransactionQty, @TransactionCost, @RunningQty, ISNULL(@MovingAverageCost, 0))
    
    IF @Quantity <= @RunningQty
    BEGIN
      SET @FirstTransactionId = @TransactionId
    END

    IF @RunningQty < @Quantity
    BEGIN
      SET @IsAvgLifo = 1
    END

    SET @RunningQty = ISNULL(@RunningQty, 0) + @TransactionQty

    FETCH NEXT FROM curLifo INTO @TransactionId, @TransactionQty, @TransactionCost
  END

  CLOSE curLifo
  DEALLOCATE curLifo

  SET @Cost = CASE WHEN @IsAvgLifo = 1 THEN ISNULL(dbo.fnICGetMovingAverageCost(@ItemId, @ItemLocationId, @FirstTransactionId), @LastCost) ELSE @LastCost END
END

IF @ShowBucket = 1
BEGIN
  SELECT t.intInventoryTransactionId, t.dtmDate, t.dblQty, t.dblCost, t.ysnIsUnposted
  FROM tblICInventoryTransaction t
  WHERE t.intItemId = @ItemId
    AND t.intItemLocationId = @ItemLocationId
    AND t.dblQty > 0
    AND t.ysnIsUnposted = 0
    AND dbo.fnDateLessThanEquals(CONVERT(VARCHAR(10), t.dtmDate,112), @Date) = 1
  ORDER BY t.intInventoryTransactionId DESC

  SELECT @Cost Cost, @LastCost LastCost, @StandardCost StdCost, @AverageCost AvgCost, 
  dbo.fnICGetItemRunningCost(@ItemId, @LocationId, NULL, NULL, NULL, NULL, NULL, @Date, 0) fnRunning,
  dbo.fnICGetMovingAverageCost(@ItemId, @ItemLocationId, @LastTransactionId) fnAvg
END

-- SELECT @LastCost LastCost, @StandardCost StdCost, @AverageCost AvgCost, 
--   dbo.fnICGetItemRunningCost(@ItemId, @LocationId, NULL, NULL, NULL, NULL, NULL, @Date, 0) fnRunning,
--   dbo.fnICGetMovingAverageCost(@ItemId, @ItemLocationId, @LastTransactionId) fnAvg

-- SELECT @Cost
rollback
