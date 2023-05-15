CREATE PROCEDURE [dbo].[uspICCalculateCost] (
    @ItemId INT,                     -- The primary ID of the inventory item.
    @LocationId INT,                 -- The primary ID of the company location.
    @Quantity NUMERIC(38, 20),       -- The quantity sold.
    @Date DATETIME,                  -- The date of transaction. This is optional and will default to the current date.
    @Cost NUMERIC(18, 6) OUTPUT,     -- The cost of the item. This is the output value of this procedure.
    @ItemUOMId INT,                  -- The item UOM ID. This is optional and will default to ID of the GALLONS uom.
    @ShowBucket BIT = 0,              -- Lists the cost bucket
    @MiscellaneousCost NUMERIC(18, 6) = 0
)
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS ON

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

-- 1: AVG
-- 2: FIFO
-- 3: LIFO
-- 4: LOT
-- 5: Actual
-- 6: CATEGORY
DECLARE @CostingMethod INT
SELECT @CostingMethod = dbo.fnGetCostingMethod(@ItemId, @ItemLocationId)

IF @CostingMethod = 2
  EXEC dbo.uspICCalculateFIFOCost 
    @ItemId = @ItemId,
    @LocationId = @LocationId,
    @Quantity = @Quantity,
    @Cost = @Cost OUTPUT,
    @Date = @Date,
    @ItemUOMId = @ItemUOMId,
    @ShowBucket = @ShowBucket,
    @MiscellaneousCost = @MiscellaneousCost
ELSE IF @CostingMethod = 3
  EXEC dbo.uspICCalculateLIFOCost 
    @ItemId = @ItemId,
    @LocationId = @LocationId,
    @Quantity = @Quantity,
    @Cost = @Cost OUTPUT,
    @Date = @Date,
    @ItemUOMId = @ItemUOMId,
    @ShowBucket = @ShowBucket,
    @MiscellaneousCost = @MiscellaneousCost
ELSE IF @CostingMethod = 1
BEGIN
  SET @Cost = ISNULL(dbo.fnICGetItemRunningCost(@ItemId, @LocationId, NULL, NULL, NULL, NULL, NULL, @Date, 0), @AverageCost)
END

ELSE
  RAISERROR('Costing method is invalid or not supported.', 11, 1)