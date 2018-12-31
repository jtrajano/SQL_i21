CREATE PROCEDURE uspMFGetInventoryAsOnDate @dtmFromDate AS DATETIME
	,@dtmToDate AS DATETIME
	,@guidSessionId UNIQUEIDENTIFIER 
	,@intUserId INT 
	,@ysnInventoryByParentLot INT = 0
	,@intLocationId INT
AS
SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

DECLARE @InventoryAutoVariance AS INT = 1
	,@InventoryWriteOffSold AS INT = 2
	,@InventoryRevalueSold AS INT = 3
	,@InventoryReceipt AS INT = 4
	,@InventoryShipment AS INT = 5
	,@PurchaseOrder AS INT = 6
	,@SalesOrder AS INT = 7
	,@Consume AS INT = 8
	,@Produce AS INT = 9
	,@InventoryAdjustmentQuantityChange AS INT = 10
	,@BuildAssembly AS INT = 11
	,@InventoryTransfer AS INT = 12
	,@InventoryTransferwithShipment AS INT = 13
	,@InventoryAdjustmentUOMChange AS INT = 14
	,@InventoryAdjustmentItemChange AS INT = 15
	,@InventoryAdjustmentLotStatusChange AS INT = 16
	,@InventoryAdjustmentSplitLot AS INT = 17
	,@InventoryAdjustmentExpiryDateChange AS INT = 18
	,@InventoryAdjustmentLotMerge AS INT = 19
	,@InventoryAdjustmentLotMove AS INT = 20
	,@PickLots AS INT = 21
	,@InboundShipments AS INT = 22
	,@InventoryCount AS INT = 23
	,@EmptyOut AS INT = 24
	,@ProcessInventoryCount AS INT = 25
	,@CostAdjustment AS INT = 26
	,@Bill AS INT = 27
	,@RevalueConsume AS INT = 28
	,@RevalueProduce AS INT = 29
	,@RevalueTransfer AS INT = 30
	,@RevalueBuildAssembly AS INT = 31
	,@iProcess AS INT = 32
	,@Invoice AS INT = 33
	,@PickList AS INT = 34
	,@InventoryAutoVarianceonNegativelySoldorUsedStock AS INT = 35
	,@RevalueItemChange AS INT = 36
	,@RevalueSplitLot AS INT = 37
	,@RevalueLotMerge AS INT = 38
	,@RevalueLotMove AS INT = 39
	,@RevalueShipment AS INT = 40
	,@SAPstockintegration AS INT = 41
	,@InventoryReturn AS INT = 42
	,@InventoryAdjustmentOwnershipChange AS INT = 43
	,@StorageSettlement AS INT = 44
	,@CreditMemo AS INT = 45
	,@OutboundShipment AS INT = 46
	,@InventoryAdjustmentOpeningInventory AS INT = 47
	,@InventoryAdjustmentChangeLotWeight AS INT = 48
	,@RetailMarkUpsDowns AS INT = 49
	,@RetailWriteOffs AS INT = 50
	,@SalesReturn AS INT = 51
DECLARE @Transactions TABLE (
	intId INT IDENTITY(1, 1)
	,intTransactionId INT
	,intItemId INT
	,intItemUOMId INT
	,intTransactionTypeId INT
	,intLotId INT
	,dblQty NUMERIC(38, 20)
	,intItemLocationId INT
	,intInTransitSourceLocationId INT
	,ysnOwned BIT
	,PRIMARY KEY (intId)
	)

INSERT INTO @Transactions (
	intTransactionId
	,intItemId
	,intItemUOMId
	,intTransactionTypeId
	,intLotId
	,dblQty
	,intItemLocationId
	,intInTransitSourceLocationId
	,ysnOwned
	)
SELECT t.intTransactionId
	,t.intItemId
	,t.intItemUOMId
	,t.intTransactionTypeId
	,t.intLotId
	,t.dblQty
	,t.intItemLocationId
	,t.intInTransitSourceLocationId
	,1
FROM tblICInventoryTransaction t
INNER JOIN tblICItemLocation ItemLocation ON ItemLocation.intItemLocationId = t.intItemLocationId and ItemLocation.intLocationId=@intLocationId
WHERE t.ysnIsUnposted <> 1
	AND dbo.fnRemoveTimeOnDate(t.dtmDate) >= @dtmFromDate
	AND dbo.fnRemoveTimeOnDate(t.dtmDate) <= @dtmToDate

INSERT INTO @Transactions (
	intTransactionId
	,intItemId
	,intItemUOMId
	,intTransactionTypeId
	,intLotId
	,dblQty
	,intItemLocationId
	,intInTransitSourceLocationId
	,ysnOwned
	)
SELECT t.intTransactionId
	,t.intItemId
	,t.intItemUOMId
	,t.intTransactionTypeId
	,t.intLotId
	,t.dblQty
	,t.intItemLocationId
	,NULL
	,0
FROM tblICInventoryTransactionStorage t
INNER JOIN tblICItemLocation ItemLocation ON ItemLocation.intItemLocationId = t.intItemLocationId and ItemLocation.intLocationId=@intLocationId
WHERE t.ysnIsUnposted <> 1
	AND dbo.fnRemoveTimeOnDate(t.dtmDate) >= @dtmFromDate
	AND dbo.fnRemoveTimeOnDate(t.dtmDate) <= @dtmToDate

CREATE TABLE #tmpInventoryAsOnDate (
	intKey INT IDENTITY
	,intSourceType INT
	,intItemId INT
	,intLocationId INT
	,intTransactionTypeId INT
	,intLotId INT
	,intInTransitSourceLocationId INT
	,dblQty NUMERIC(38, 20)
	)

-----===== SOURCE 1 - Opening Qty
INSERT INTO #tmpInventoryAsOnDate
SELECT 1
	,t.intItemId
	,intLocationId
	,t.intTransactionTypeId
	,t.intLotId
	,t.intInTransitSourceLocationId
	,dblQty = SUM(dbo.fnICConvertUOMtoStockUnit(t.intItemId, t.intItemUOMId, t.dblQty))
FROM tblICInventoryTransaction t
INNER JOIN tblICItemLocation ItemLocation ON ItemLocation.intItemLocationId = t.intItemLocationId and ItemLocation.intLocationId=@intLocationId
WHERE t.ysnIsUnposted <> 1
	AND t.dtmDate < @dtmFromDate
GROUP BY t.intItemId
	,ItemLocation.intLocationId
	,t.intTransactionTypeId
	,t.intLotId
	,t.intInTransitSourceLocationId

----===== SOURCE 1 = Opening Storage Qty
INSERT INTO #tmpInventoryAsOnDate
SELECT 1
	,t.intItemId
	,intLocationId
	,t.intTransactionTypeId
	,t.intLotId
	,NULL
	,dblQty = SUM(dbo.fnICConvertUOMtoStockUnit(t.intItemId, t.intItemUOMId, t.dblQty))
FROM tblICInventoryTransactionStorage t
INNER JOIN tblICItemLocation ItemLocation ON ItemLocation.intItemLocationId = t.intItemLocationId and ItemLocation.intLocationId=@intLocationId
WHERE t.ysnIsUnposted <> 1
	AND t.dtmDate < @dtmFromDate
GROUP BY t.intItemId
	,ItemLocation.intLocationId
	,t.intTransactionTypeId
	,t.intLotId

-----===== SOURCE 2 - Received 
INSERT INTO #tmpInventoryAsOnDate
SELECT 2
	,t.intItemId
	,ItemLocation.intLocationId
	,t.intTransactionTypeId
	,t.intLotId
	,t.intInTransitSourceLocationId
	,dblQty = SUM(dbo.fnICConvertUOMtoStockUnit(t.intItemId, t.intItemUOMId, t.dblQty))
FROM @Transactions t
INNER JOIN tblICItemLocation ItemLocation ON ItemLocation.intItemLocationId = t.intItemLocationId and ItemLocation.intLocationId=@intLocationId
WHERE t.intTransactionTypeId = @InventoryReceipt
	AND t.intInTransitSourceLocationId IS NULL
GROUP BY t.intItemId
	,ItemLocation.intLocationId
	,t.intTransactionTypeId
	,t.intLotId
	,t.intInTransitSourceLocationId

-----===== SOURCE 3 - Invoiced 
INSERT INTO #tmpInventoryAsOnDate
SELECT 3
	,t.intItemId
	,ItemLocation.intLocationId
	,t.intTransactionTypeId
	,t.intLotId
	,t.intInTransitSourceLocationId
	,dblQty = SUM(dbo.fnICConvertUOMtoStockUnit(t.intItemId, t.intItemUOMId, - t.dblQty))
FROM @Transactions t
INNER JOIN tblICItemLocation ItemLocation ON ItemLocation.intItemLocationId = ISNULL(t.intInTransitSourceLocationId, t.intItemLocationId) and ItemLocation.intLocationId=@intLocationId
WHERE t.intTransactionTypeId = @Invoice
GROUP BY t.intItemId
	,ItemLocation.intLocationId
	,t.intTransactionTypeId
	,t.intLotId
	,t.intInTransitSourceLocationId

-----===== SOURCE 4 - Adjustments
INSERT INTO #tmpInventoryAsOnDate
SELECT 4
	,t.intItemId
	,ItemLocation.intLocationId
	,t.intTransactionTypeId
	,t.intLotId
	,t.intInTransitSourceLocationId
	,dblQty = SUM(dbo.fnICConvertUOMtoStockUnit(t.intItemId, t.intItemUOMId, t.dblQty))
FROM @Transactions t
INNER JOIN tblICItemLocation ItemLocation ON ItemLocation.intItemLocationId = t.intItemLocationId  and ItemLocation.intLocationId=@intLocationId
WHERE t.intTransactionTypeId IN (
		@InventoryAdjustmentQuantityChange
		,@InventoryAdjustmentUOMChange
		,@InventoryAdjustmentItemChange
		,@InventoryAdjustmentLotStatusChange
		,@InventoryAdjustmentSplitLot
		,@InventoryAdjustmentExpiryDateChange
		,@InventoryAdjustmentLotMerge
		,@InventoryAdjustmentLotMove
		,@InventoryAdjustmentOwnershipChange
		)
	AND intInTransitSourceLocationId IS NULL
GROUP BY t.intItemId
	,ItemLocation.intLocationId
	,t.intTransactionTypeId
	,t.intLotId
	,t.intInTransitSourceLocationId

-----===== SOURCE 5 - Transfers Received
INSERT INTO #tmpInventoryAsOnDate
SELECT 5
	,t.intItemId
	,ItemLocation.intLocationId
	,t.intTransactionTypeId
	,t.intLotId
	,t.intInTransitSourceLocationId
	,dblQty = SUM(dbo.fnICConvertUOMtoStockUnit(t.intItemId, t.intItemUOMId, t.dblQty))
FROM @Transactions t
INNER JOIN tblICInventoryTransfer InvTransfer ON InvTransfer.intInventoryTransferId = t.intTransactionId
	AND InvTransfer.strTransferType = 'Location to Location'
INNER JOIN tblICItemLocation ItemLocation ON ItemLocation.intItemLocationId = t.intItemLocationId
	AND InvTransfer.intToLocationId = ItemLocation.intLocationId  and ItemLocation.intLocationId=@intLocationId
WHERE t.intTransactionTypeId = @InventoryTransfer
	AND t.intInTransitSourceLocationId IS NULL
GROUP BY t.intItemId
	,ItemLocation.intLocationId
	,t.intTransactionTypeId
	,t.intLotId
	,t.intInTransitSourceLocationId

-----===== SOURCE 6 - Transfers Shipped
INSERT INTO #tmpInventoryAsOnDate
SELECT 6
	,t.intItemId
	,ItemLocation.intLocationId
	,t.intTransactionTypeId
	,t.intLotId
	,t.intInTransitSourceLocationId
	,dblQty = SUM(dbo.fnICConvertUOMtoStockUnit(t.intItemId, t.intItemUOMId, - t.dblQty))
FROM @Transactions t
INNER JOIN tblICInventoryTransfer InvTransfer ON InvTransfer.intInventoryTransferId = t.intTransactionId
	AND InvTransfer.strTransferType = 'Location to Location'
INNER JOIN tblICItemLocation ItemLocation ON ItemLocation.intItemLocationId = t.intItemLocationId
	AND InvTransfer.intFromLocationId = ItemLocation.intLocationId  and ItemLocation.intLocationId=@intLocationId
WHERE t.intTransactionTypeId = @InventoryTransfer
	AND t.intInTransitSourceLocationId IS NULL
GROUP BY t.intItemId
	,ItemLocation.intLocationId
	,t.intTransactionTypeId
	,t.intLotId
	,t.intInTransitSourceLocationId

-----===== SOURCE 7 - In Transit Inbound
INSERT INTO #tmpInventoryAsOnDate
SELECT 7
	,t.intItemId
	,ItemLocation.intLocationId
	,t.intTransactionTypeId
	,t.intLotId
	,t.intInTransitSourceLocationId
	,dblQty = SUM(dbo.fnICConvertUOMtoStockUnit(t.intItemId, t.intItemUOMId, t.dblQty))
FROM @Transactions t
INNER JOIN tblICItemLocation ItemLocation ON ItemLocation.intItemLocationId = t.intInTransitSourceLocationId  and ItemLocation.intLocationId=@intLocationId
WHERE t.intTransactionTypeId IN (@InboundShipments)
	AND t.intInTransitSourceLocationId IS NOT NULL
GROUP BY t.intItemId
	,ItemLocation.intLocationId
	,t.intTransactionTypeId
	,t.intLotId
	,t.intInTransitSourceLocationId

UNION ALL

SELECT 7
	,t.intItemId
	,ItemLocation.intLocationId
	,t.intTransactionTypeId
	,t.intLotId
	,t.intInTransitSourceLocationId
	,dblQty = SUM(dbo.fnICConvertUOMtoStockUnit(t.intItemId, t.intItemUOMId, t.dblQty))
FROM @Transactions t
INNER JOIN tblICInventoryTransfer InvTransfer ON InvTransfer.intInventoryTransferId = t.intTransactionId
	AND InvTransfer.ysnShipmentRequired = 1
INNER JOIN tblICItemLocation ItemLocation ON ItemLocation.intItemId = t.intItemId
	AND ItemLocation.intLocationId = InvTransfer.intToLocationId  and ItemLocation.intLocationId=@intLocationId
WHERE t.intTransactionTypeId IN (@InventoryTransferwithShipment)
	AND t.intInTransitSourceLocationId IS NOT NULL
GROUP BY t.intItemId
	,ItemLocation.intLocationId
	,t.intTransactionTypeId
	,t.intLotId
	,t.intInTransitSourceLocationId

-----===== SOURCE 8 - In Transit Outbound
INSERT INTO #tmpInventoryAsOnDate
SELECT 8
	,t.intItemId
	,ItemLocation.intLocationId
	,t.intTransactionTypeId
	,t.intLotId
	,t.intInTransitSourceLocationId
	,dblQty = SUM(dbo.fnICConvertUOMtoStockUnit(t.intItemId, t.intItemUOMId, t.dblQty))
FROM @Transactions t
INNER JOIN tblICItemLocation ItemLocation ON ItemLocation.intItemLocationId = t.intInTransitSourceLocationId  and ItemLocation.intLocationId=@intLocationId
WHERE t.intTransactionTypeId IN (
		@InventoryShipment
		,@OutboundShipment
		,@Invoice
		,@InventoryTransferwithShipment
		)
	AND t.intInTransitSourceLocationId IS NOT NULL
GROUP BY t.intItemId
	,ItemLocation.intLocationId
	,intTransactionTypeId
	,intLotId
	,intInTransitSourceLocationId

-----===== SOURCE 9 - Consumed
INSERT INTO #tmpInventoryAsOnDate
SELECT 9
	,t.intItemId
	,ItemLocation.intLocationId
	,t.intTransactionTypeId
	,t.intLotId
	,t.intInTransitSourceLocationId
	,dblQty = SUM(dbo.fnICConvertUOMtoStockUnit(t.intItemId, t.intItemUOMId, - t.dblQty))
FROM @Transactions t
INNER JOIN tblICItemLocation ItemLocation ON ItemLocation.intItemLocationId = t.intItemLocationId  and ItemLocation.intLocationId=@intLocationId
WHERE t.intTransactionTypeId IN (@Consume)
	AND t.intInTransitSourceLocationId IS NULL
GROUP BY t.intItemId
	,ItemLocation.intLocationId
	,intTransactionTypeId
	,intLotId
	,intInTransitSourceLocationId

-----===== SOURCE 10 - Produced
INSERT INTO #tmpInventoryAsOnDate
SELECT 10
	,t.intItemId
	,ItemLocation.intLocationId
	,t.intTransactionTypeId
	,t.intLotId
	,t.intInTransitSourceLocationId
	,dblQty = SUM(dbo.fnICConvertUOMtoStockUnit(t.intItemId, t.intItemUOMId, t.dblQty))
FROM @Transactions t
INNER JOIN tblICItemLocation ItemLocation ON ItemLocation.intItemLocationId = t.intItemLocationId  and ItemLocation.intLocationId=@intLocationId
WHERE t.intTransactionTypeId = @Produce
	AND t.intInTransitSourceLocationId IS NULL
GROUP BY t.intItemId
	,ItemLocation.intLocationId
	,intTransactionTypeId
	,intLotId
	,intInTransitSourceLocationId

DELETE
FROM tblMFInventoryAsOnDate
WHERE (
		guidSessionId = @guidSessionId
		OR DATEDIFF(SECOND, dtmDateCreated, GETDATE()) > 10
		)

-----===== READ DAILY STOCK POSITION
SELECT intItemId
	,intLotId
	,intLocationId
	,dblOpeningQty = SUM(CASE 
			WHEN intSourceType = 1
				THEN dblQty
			ELSE 0
			END)
	,dblReceivedQty = SUM(CASE 
			WHEN intSourceType = 2
				THEN dblQty
			ELSE 0
			END)
	,dblInvoicedQty = SUM(CASE 
			WHEN intSourceType = 3
				THEN dblQty
			ELSE 0
			END)
	,dblAdjustments = SUM(CASE 
			WHEN intSourceType = 4
				THEN dblQty
			ELSE 0
			END)
	,dblTransfersReceived = SUM(CASE 
			WHEN intSourceType = 5
				THEN dblQty
			ELSE 0
			END)
	,dblTransfersShipped = SUM(CASE 
			WHEN intSourceType = 6
				THEN dblQty
			ELSE 0
			END)
	,dblInTransitInbound = SUM(CASE 
			WHEN intSourceType = 7
				THEN dblQty
			ELSE 0
			END)
	,dblInTransitOutbound = SUM(CASE 
			WHEN intSourceType = 8
				THEN dblQty
			ELSE 0
			END)
	,dblConsumedQty = SUM(CASE 
			WHEN intSourceType = 9
				THEN dblQty
			ELSE 0
			END)
	,dblProduced = SUM(CASE 
			WHEN intSourceType = 10
				THEN dblQty
			ELSE 0
			END)
INTO #tmpFinalInventoryAsOnDate
FROM #tmpInventoryAsOnDate
GROUP BY intItemId
	,intLotId
	,intLocationId

DELETE
FROM #tmpFinalInventoryAsOnDate
WHERE dblOpeningQty = 0
	AND dblReceivedQty = 0
	AND dblInvoicedQty = 0
	AND dblAdjustments = 0
	AND dblTransfersReceived = 0
	AND dblTransfersShipped = 0
	AND dblInTransitInbound = 0
	AND dblInTransitOutbound = 0
	AND dblConsumedQty = 0
	AND dblProduced = 0

IF @ysnInventoryByParentLot = 0
BEGIN
	INSERT INTO tblMFInventoryAsOnDate
	SELECT guidSessionId = @guidSessionId
		,intKey = CAST(ROW_NUMBER() OVER (
				ORDER BY Item.intCommodityId
					,Item.intItemId
				) AS INT)
		,intCommodityId = Item.intCommodityId
		,strCommodityCode = ISNULL(Commodity.strCommodityCode, '')
		,dtmDate = CAST(CONVERT(VARCHAR(10), @dtmFromDate, 112) AS DATETIME)
		,intCategoryId = Item.intCategoryId
		,strCategoryCode = ISNULL(Category.strCategoryCode, '')
		,intLocationId = FL.intLocationId
		,strLocationName = Loc.strLocationName
		,intItemId = Item.intItemId
		,strItemNo = Item.strItemNo
		,strDescription = Item.strDescription
		,intParentLotId = PL.intParentLotId
		,strParentLotNumber = PL.strParentLotNumber
		,intLotId = L.intLotId
		,strLotNumber = L.strLotNumber
		,strLotAlias = L.strLotAlias
		,strSecondaryStatus = LS.strSecondaryStatus
		,intItemUOMId = StockUOM.intItemUOMId
		,strItemUOM = sUOM.strUnitMeasure
		,dblOpeningQty = ISNULL(FL.dblOpeningQty, 0)
		,dblReceivedQty = ISNULL(FL.dblReceivedQty, 0)
		,dblInvoicedQty = ISNULL(FL.dblInvoicedQty, 0)
		,dblAdjustments = ISNULL(FL.dblAdjustments, 0)
		,dblTransfersReceived = ISNULL(FL.dblTransfersReceived, 0)
		,dblTransfersShipped = ISNULL(FL.dblTransfersShipped, 0)
		,dblInTransitInbound = ISNULL(FL.dblInTransitInbound, 0)
		,dblInTransitOutbound = ISNULL(FL.dblInTransitOutbound, 0)
		,dblConsumed = ISNULL(FL.dblConsumedQty, 0)
		,dblProduced = ISNULL(FL.dblProduced, 0)
		,dblClosingQty = FL.dblOpeningQty + FL.dblReceivedQty - FL.dblInvoicedQty + FL.dblAdjustments + FL.dblTransfersReceived - FL.dblTransfersShipped + FL.dblInTransitInbound - FL.dblInTransitOutbound - FL.dblConsumedQty + FL.dblProduced
		,intConcurrencyId = 1
		,dtmDateCreated = GETDATE()
		,intCreatedByUserId = @intUserId
		,strVendorRefNo = strVendorRefNo
		,strWarehouseRefNo = LI.strWarehouseRefNo
		,strBondStatus = BS.strSecondaryStatus
		,strContainerNo = L.strContainerNo
	FROM #tmpFinalInventoryAsOnDate FL
	JOIN tblICLot L ON L.intLotId = FL.intLotId
	JOIN tblMFLotInventory LI ON LI.intLotId = L.intLotId
	JOIN tblICParentLot PL ON PL.intParentLotId = L.intParentLotId
	JOIN tblICItem Item ON L.intItemId = Item.intItemId
	INNER JOIN tblICItemUOM StockUOM ON StockUOM.intItemId = Item.intItemId
		AND StockUOM.ysnStockUnit = 1
	INNER JOIN tblICUnitMeasure sUOM ON StockUOM.intUnitMeasureId = sUOM.intUnitMeasureId
	LEFT JOIN tblICCommodity Commodity ON Commodity.intCommodityId = Item.intCommodityId
	LEFT JOIN tblICCategory Category ON Category.intCategoryId = Item.intCategoryId
	INNER JOIN tblSMCompanyLocation Loc ON Loc.intCompanyLocationId = FL.intLocationId
	JOIN tblICLotStatus LS ON LS.intLotStatusId = L.intLotStatusId
	LEFT JOIN tblICLotStatus BS ON BS.intLotStatusId = LI.intBondStatusId
END
ELSE
BEGIN
	SELECT guidSessionId = @guidSessionId
		,intKey = 0
		,intCommodityId = Item.intCommodityId
		,strCommodityCode = ISNULL(Commodity.strCommodityCode, '')
		,dtmDate = CAST(CONVERT(VARCHAR(10), @dtmFromDate, 112) AS DATETIME)
		,intCategoryId = Item.intCategoryId
		,strCategoryCode = ISNULL(Category.strCategoryCode, '')
		,intLocationId = FL.intLocationId
		,strLocationName = Loc.strLocationName
		,intItemId = Item.intItemId
		,strItemNo = Item.strItemNo
		,strDescription = Item.strDescription
		,intParentLotId = PL.intParentLotId
		,strParentLotNumber = PL.strParentLotNumber
		,intLotId = L.intLotId
		,strLotNumber = L.strLotNumber
		,strLotAlias = L.strLotAlias
		,strSecondaryStatus = LS.strSecondaryStatus
		,intItemUOMId = StockUOM.intItemUOMId
		,strItemUOM = sUOM.strUnitMeasure
		,dblOpeningQty = ISNULL(FL.dblOpeningQty, 0)
		,dblReceivedQty = ISNULL(FL.dblReceivedQty, 0)
		,dblInvoicedQty = ISNULL(FL.dblInvoicedQty, 0)
		,dblAdjustments = ISNULL(FL.dblAdjustments, 0)
		,dblTransfersReceived = ISNULL(FL.dblTransfersReceived, 0)
		,dblTransfersShipped = ISNULL(FL.dblTransfersShipped, 0)
		,dblInTransitInbound = ISNULL(FL.dblInTransitInbound, 0)
		,dblInTransitOutbound = ISNULL(FL.dblInTransitOutbound, 0)
		,dblConsumed = ISNULL(FL.dblConsumedQty, 0)
		,dblProduced = ISNULL(FL.dblProduced, 0)
		,dblClosingQty = FL.dblOpeningQty + FL.dblReceivedQty - FL.dblInvoicedQty + FL.dblAdjustments + FL.dblTransfersReceived - FL.dblTransfersShipped + FL.dblInTransitInbound - FL.dblInTransitOutbound - FL.dblConsumedQty + FL.dblProduced
		,intConcurrencyId = 1
		,dtmDateCreated = GETDATE()
		,intCreatedByUserId = @intUserId
		,strVendorRefNo = strVendorRefNo
		,strWarehouseRefNo = LI.strWarehouseRefNo
		,strBondStatus = BS.strSecondaryStatus
		,strContainerNo = L.strContainerNo
	INTO #tmpInventoryByParentLot
	FROM #tmpFinalInventoryAsOnDate FL
	JOIN tblICLot L ON L.intLotId = FL.intLotId
	JOIN tblMFLotInventory LI ON LI.intLotId = L.intLotId
	JOIN tblICParentLot PL ON PL.intParentLotId = L.intParentLotId
	JOIN tblICItem Item ON L.intItemId = Item.intItemId
	INNER JOIN tblICItemUOM StockUOM ON StockUOM.intItemId = Item.intItemId
		AND StockUOM.ysnStockUnit = 1
	INNER JOIN tblICUnitMeasure sUOM ON StockUOM.intUnitMeasureId = sUOM.intUnitMeasureId
	LEFT JOIN tblICCommodity Commodity ON Commodity.intCommodityId = Item.intCommodityId
	LEFT JOIN tblICCategory Category ON Category.intCategoryId = Item.intCategoryId
	INNER JOIN tblSMCompanyLocation Loc ON Loc.intCompanyLocationId = FL.intLocationId
	JOIN tblICLotStatus LS ON LS.intLotStatusId = L.intLotStatusId
	LEFT JOIN tblICLotStatus BS ON BS.intLotStatusId = LI.intBondStatusId

	INSERT INTO tblMFInventoryAsOnDate (
		guidSessionId
		,intKey
		,intCommodityId
		,strCommodityCode
		,dtmDate
		,intCategoryId
		,strCategoryCode
		,intLocationId
		,strLocationName
		,intItemId
		,strItemNo
		,strDescription
		,intParentLotId
		,strParentLotNumber
		,strLotAlias
		,strSecondaryStatus
		,intItemUOMId
		,strItemUOM
		,dblOpeningQty
		,dblReceivedQty
		,dblInvoicedQty
		,dblAdjustments
		,dblTransfersReceived
		,dblTransfersShipped
		,dblInTransitInbound
		,dblInTransitOutbound
		,dblConsumed
		,dblProduced
		,dblClosingQty
		,intConcurrencyId
		,dtmDateCreated
		,intCreatedByUserId
		,strVendorRefNo
		,strWarehouseRefNo
		,strBondStatus
		,strContainerNo
		)
	SELECT guidSessionId
		,intKey = CAST(ROW_NUMBER() OVER (
				ORDER BY intCommodityId
					,intItemId
				) AS INT)
		,intCommodityId
		,strCommodityCode
		,dtmDate
		,intCategoryId
		,strCategoryCode
		,intLocationId
		,strLocationName
		,intItemId
		,strItemNo
		,strDescription
		,intParentLotId
		,strParentLotNumber
		,strLotAlias
		,strSecondaryStatus
		,intItemUOMId
		,strItemUOM
		,SUM(dblOpeningQty)
		,SUM(dblReceivedQty)
		,SUM(dblInvoicedQty)
		,SUM(dblAdjustments)
		,SUM(dblTransfersReceived)
		,SUM(dblTransfersShipped)
		,SUM(dblInTransitInbound)
		,SUM(dblInTransitOutbound)
		,SUM(dblConsumed)
		,SUM(dblProduced)
		,SUM(dblClosingQty)
		,intConcurrencyId
		,MAX(dtmDateCreated)
		,intCreatedByUserId
		,strVendorRefNo
		,strWarehouseRefNo
		,strBondStatus
		,strContainerNo
	FROM #tmpInventoryByParentLot
	GROUP BY guidSessionId
		,intCommodityId
		,strCommodityCode
		,dtmDate
		,intCategoryId
		,strCategoryCode
		,intLocationId
		,strLocationName
		,intItemId
		,strItemNo
		,strDescription
		,intParentLotId
		,strParentLotNumber
		,strLotAlias
		,strSecondaryStatus
		,intItemUOMId
		,strItemUOM
		,intConcurrencyId
		,intCreatedByUserId
		,strVendorRefNo
		,strWarehouseRefNo
		,strBondStatus
		,strContainerNo
END

