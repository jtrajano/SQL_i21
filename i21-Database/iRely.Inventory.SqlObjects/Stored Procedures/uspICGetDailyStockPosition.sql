CREATE PROCEDURE [dbo].[uspICGetDailyStockPosition]
	@dtmDate AS DATETIME
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

DECLARE	@InventoryAutoVariance AS INT = 1
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

CREATE TABLE #tmpDailyStockPosition
(
	intKey							INT		IDENTITY,
	intSourceType					INT,
	intItemId						INT,
	intLocationId					INT,
	intTransactionTypeId			INT,
	intLotId						INT,
	intInTransitSourceLocationId	INT,
	dblQty							NUMERIC(38,20)
)	
	
	-----===== SOURCE 1 - Opening Qty
	INSERT INTO #tmpDailyStockPosition
	SELECT	1,
			t.intItemId,
			intLocationId,
			intTransactionTypeId,
			intLotId,
			intInTransitSourceLocationId,
			dblQty = SUM(dbo.fnICConvertUOMtoStockUnit(t.intItemId, intItemUOMId, dblQty))
	FROM tblICInventoryTransaction t 
	INNER JOIN tblICItemLocation ItemLocation 
		ON ItemLocation.intItemLocationId = t.intItemLocationId
	WHERE ysnIsUnposted <> 1
		AND dtmDate < @dtmDate
	GROUP BY t.intItemId,
			ItemLocation.intLocationId,
			intTransactionTypeId,
			intLotId,
			intInTransitSourceLocationId

	-----===== SOURCE 2 - Received 
	INSERT INTO #tmpDailyStockPosition
	SELECT	2,
			t.intItemId,
			ItemLocation.intLocationId,
			intTransactionTypeId,
			intLotId,
			intInTransitSourceLocationId,
			dblQty = SUM(dbo.fnICConvertUOMtoStockUnit(t.intItemId, intItemUOMId, dblQty))
	FROM tblICInventoryTransaction t 
	INNER JOIN tblICItemLocation ItemLocation 
		ON ItemLocation.intItemLocationId = t.intItemLocationId
	WHERE ysnIsUnposted <> 1
		AND intTransactionTypeId = @InventoryReceipt
		AND intInTransitSourceLocationId IS NULL
		AND dtmDate = @dtmDate
	GROUP BY t.intItemId,
			ItemLocation.intLocationId,
			intTransactionTypeId,
			intLotId,
			intInTransitSourceLocationId

	-----===== SOURCE 3 - Invoiced 
	INSERT INTO #tmpDailyStockPosition
	SELECT	3,
			t.intItemId,
			ItemLocation.intLocationId,
			intTransactionTypeId,
			intLotId,
			intInTransitSourceLocationId,
			dblQty = SUM(dbo.fnICConvertUOMtoStockUnit(t.intItemId, intItemUOMId, -dblQty))
	FROM tblICInventoryTransaction t 
	INNER JOIN tblICItemLocation ItemLocation 
		ON ItemLocation.intItemLocationId = ISNULL(t.intInTransitSourceLocationId, t.intItemLocationId) 
	WHERE ysnIsUnposted <> 1
		AND intTransactionTypeId = @Invoice
		AND dtmDate = @dtmDate
	GROUP BY t.intItemId,
			ItemLocation.intLocationId,
			intTransactionTypeId,
			intLotId,
			intInTransitSourceLocationId

	-----===== SOURCE 4 - Adjustments
	INSERT INTO #tmpDailyStockPosition
	SELECT	4,
			t.intItemId,
			ItemLocation.intLocationId,
			intTransactionTypeId,
			intLotId,
			intInTransitSourceLocationId,
			dblQty = SUM(dbo.fnICConvertUOMtoStockUnit(t.intItemId, intItemUOMId, dblQty))
	FROM tblICInventoryTransaction t 
	INNER JOIN tblICItemLocation ItemLocation 
		ON ItemLocation.intItemLocationId = t.intItemLocationId
	WHERE ysnIsUnposted <> 1
		--AND intTransactionTypeId IN (10,14,15,16,17,18,19,20,43)
		AND intTransactionTypeId IN (
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
		AND dtmDate = @dtmDate
	GROUP BY t.intItemId,
			ItemLocation.intLocationId,
			intTransactionTypeId,
			intLotId,
			intInTransitSourceLocationId

	-----===== SOURCE 5 - Transfers Received
	INSERT INTO #tmpDailyStockPosition
	SELECT	5,
			t.intItemId,
			ItemLocation.intLocationId,
			intTransactionTypeId,
			intLotId,
			intInTransitSourceLocationId,
			dblQty = SUM(dbo.fnICConvertUOMtoStockUnit(t.intItemId, intItemUOMId, dblQty))
	FROM tblICInventoryTransaction t
	INNER JOIN tblICInventoryTransfer InvTransfer
		ON InvTransfer.intInventoryTransferId = t.intTransactionId AND InvTransfer.strTransferType = 'Location to Location'
	INNER JOIN tblICItemLocation ItemLocation
		ON ItemLocation.intItemLocationId = t.intItemLocationId 
		AND InvTransfer.intToLocationId = ItemLocation.intLocationId
	WHERE ysnIsUnposted <> 1
		AND t.intTransactionTypeId IN (@InventoryTransfer)
		AND t.intInTransitSourceLocationId IS NULL
		AND t.dtmDate = @dtmDate
	GROUP BY t.intItemId,
			ItemLocation.intLocationId,
			intTransactionTypeId,
			intLotId,
			intInTransitSourceLocationId

	-----===== SOURCE 6 - Transfers Shipped
	INSERT INTO #tmpDailyStockPosition
	SELECT	6,
			t.intItemId,
			ItemLocation.intLocationId,
			intTransactionTypeId,
			intLotId,
			intInTransitSourceLocationId,
			dblQty = SUM(dbo.fnICConvertUOMtoStockUnit(t.intItemId, intItemUOMId, -dblQty))
	FROM tblICInventoryTransaction t
	INNER JOIN tblICInventoryTransfer InvTransfer
		ON InvTransfer.intInventoryTransferId = t.intTransactionId AND InvTransfer.strTransferType = 'Location to Location'
	INNER JOIN tblICItemLocation ItemLocation
		ON ItemLocation.intItemLocationId = t.intItemLocationId 
		AND InvTransfer.intFromLocationId = ItemLocation.intLocationId
	WHERE ysnIsUnposted <> 1
		AND t.intTransactionTypeId IN (@InventoryTransfer)
		AND t.intInTransitSourceLocationId IS NULL
		AND t.dtmDate = @dtmDate
	GROUP BY t.intItemId,
			ItemLocation.intLocationId,
			intTransactionTypeId,
			intLotId,
			intInTransitSourceLocationId

	-----===== SOURCE 7 - In Transit Inbound
	INSERT INTO #tmpDailyStockPosition
	SELECT	7,
			t.intItemId,
			ItemLocation.intLocationId,
			intTransactionTypeId,
			intLotId,
			intInTransitSourceLocationId,
			dblQty = SUM(dbo.fnICConvertUOMtoStockUnit(t.intItemId, intItemUOMId, dblQty))
	FROM tblICInventoryTransaction t
	INNER JOIN tblICItemLocation ItemLocation
		ON ItemLocation.intItemLocationId = t.intInTransitSourceLocationId 
	WHERE ysnIsUnposted <> 1
		AND t.intTransactionTypeId IN (
			@InboundShipments		
		)
		AND t.intInTransitSourceLocationId IS NOT NULL
		AND t.dtmDate = @dtmDate
	GROUP BY t.intItemId,
			ItemLocation.intLocationId,
			intTransactionTypeId,
			intLotId,
			intInTransitSourceLocationId

	-----===== SOURCE 8 - In Transit Outbound
	INSERT INTO #tmpDailyStockPosition
	SELECT	8,
			t.intItemId,
			ItemLocation.intLocationId,
			intTransactionTypeId,
			intLotId,
			intInTransitSourceLocationId,
			dblQty = SUM(dbo.fnICConvertUOMtoStockUnit(t.intItemId, intItemUOMId, dblQty))
	FROM tblICInventoryTransaction t
	INNER JOIN tblICItemLocation ItemLocation
		ON ItemLocation.intItemLocationId = t.intInTransitSourceLocationId 
	WHERE ysnIsUnposted <> 1
		AND t.intTransactionTypeId IN (
			@InventoryShipment
			,@OutboundShipment
			,@Invoice
		)
		AND t.intInTransitSourceLocationId IS NOT NULL
		AND t.dtmDate = @dtmDate
	GROUP BY t.intItemId,
			ItemLocation.intLocationId,
			intTransactionTypeId,
			intLotId,
			intInTransitSourceLocationId

	-----===== SOURCE 9 - Consumed
	INSERT INTO #tmpDailyStockPosition
	SELECT	9,
			t.intItemId,
			ItemLocation.intLocationId,
			intTransactionTypeId,
			intLotId,
			intInTransitSourceLocationId,
			dblQty = SUM(dbo.fnICConvertUOMtoStockUnit(t.intItemId, intItemUOMId, -dblQty))
	FROM tblICInventoryTransaction t 
	INNER JOIN tblICItemLocation ItemLocation 
		ON ItemLocation.intItemLocationId = t.intItemLocationId
	WHERE ysnIsUnposted <> 1
		AND intTransactionTypeId IN (@Consume)
		AND intInTransitSourceLocationId IS NULL
		AND dtmDate = @dtmDate
	GROUP BY t.intItemId,
			ItemLocation.intLocationId,
			intTransactionTypeId,
			intLotId,
			intInTransitSourceLocationId

	-----===== SOURCE 10 - Produced
	INSERT INTO #tmpDailyStockPosition
	SELECT	10,
			t.intItemId,
			ItemLocation.intLocationId,
			intTransactionTypeId,
			intLotId,
			intInTransitSourceLocationId,
			dblQty = SUM(dbo.fnICConvertUOMtoStockUnit(t.intItemId, intItemUOMId, dblQty))
	FROM tblICInventoryTransaction t 
	INNER JOIN tblICItemLocation ItemLocation 
		ON ItemLocation.intItemLocationId = t.intItemLocationId
	WHERE ysnIsUnposted <> 1
		AND intTransactionTypeId IN (@Produce)
		AND intInTransitSourceLocationId IS NULL
		AND dtmDate = @dtmDate
	GROUP BY t.intItemId,
			ItemLocation.intLocationId,
			intTransactionTypeId,
			intLotId,
			intInTransitSourceLocationId

	-----===== READ DAILY STOCK POSITION
	SELECT	intKey					= CAST(ROW_NUMBER() OVER(ORDER BY Item.intCommodityId, Item.intItemId) AS INT),
			intCommodityId			= Item.intCommodityId,
			strCommodityCode		= ISNULL(Commodity.strCommodityCode, ''),
			dtmDate					= CAST(CONVERT(VARCHAR(10),@dtmDate,112) AS datetime),
			intCategoryId			= Item.intCategoryId,
			strCategoryCode			= ISNULL(Category.strCategoryCode, ''),
			intLocationId			= tmpDSP.intLocationId,
			strLocationName			= Loc.strLocationName,
			intItemId				= Item.intItemId,
			strItemNo				= Item.strItemNo,
			strDescription			= Item.strDescription,
			intItemUOMId			= StockUOM.intItemUOMId,
			strItemUOM				= sUOM.strUnitMeasure,
			dblOpeningQty			= ISNULL(tmpDSP.dblOpeningQty, 0),
			dblReceivedQty			= ISNULL(tmpDSP.dblReceivedQty, 0),
			dblInvoicedQty			= ISNULL(tmpDSP.dblInvoicedQty, 0),
			dblAdjustments			= ISNULL(tmpDSP.dblAdjustments, 0),
			dblTransfersReceived	= ISNULL(tmpDSP.dblTransfersReceived, 0),
			dblTransfersShipped		= ISNULL(tmpDSP.dblTransfersShipped, 0),
			dblInTransitInbound		= ISNULL(tmpDSP.dblInTransitInbound, 0),
			dblInTransitOutbound	= ISNULL(tmpDSP.dblInTransitOutbound, 0),
			dblConsumed				= ISNULL(tmpDSP.dblConsumedQty, 0),
			dblProduced				= ISNULL(tmpDSP.dblProduced, 0),
			dblClosingQty			= 
										tmpDSP.dblOpeningQty 
										+ tmpDSP.dblReceivedQty 
										- tmpDSP.dblInvoicedQty 
										+ tmpDSP.dblAdjustments 
										+ tmpDSP.dblTransfersReceived 
										- tmpDSP.dblTransfersShipped 
										+ tmpDSP.dblInTransitInbound 
										- tmpDSP.dblInTransitOutbound 
										- tmpDSP.dblConsumedQty 
										+ tmpDSP.dblProduced
	FROM tblICItem Item
	INNER JOIN (
		tblICItemUOM StockUOM INNER JOIN tblICUnitMeasure sUOM
			ON StockUOM.intUnitMeasureId = sUOM.intUnitMeasureId
	) ON StockUOM.intItemId = Item.intItemId
		AND StockUOM.ysnStockUnit = 1
	LEFT JOIN (SELECT	intItemId,
					intLocationId,
					dblOpeningQty			= SUM(CASE WHEN intSourceType = 1 THEN dblQty ELSE 0 END),
					dblReceivedQty			= SUM(CASE WHEN intSourceType = 2 THEN dblQty ELSE 0 END),
					dblInvoicedQty			= SUM(CASE WHEN intSourceType = 3 THEN dblQty ELSE 0 END),
					dblAdjustments			= SUM(CASE WHEN intSourceType = 4 THEN dblQty ELSE 0 END),
					dblTransfersReceived	= SUM(CASE WHEN intSourceType = 5 THEN dblQty ELSE 0 END),
					dblTransfersShipped		= SUM(CASE WHEN intSourceType = 6 THEN dblQty ELSE 0 END),
					dblInTransitInbound		= SUM(CASE WHEN intSourceType = 7 THEN dblQty ELSE 0 END),
					dblInTransitOutbound	= SUM(CASE WHEN intSourceType = 8 THEN dblQty ELSE 0 END),
					dblConsumedQty			= SUM(CASE WHEN intSourceType = 9 THEN dblQty ELSE 0 END),
					dblProduced				= SUM(CASE WHEN intSourceType = 10 THEN dblQty ELSE 0 END)
		FROM #tmpDailyStockPosition 
		GROUP BY intItemId, intLocationId
	) tmpDSP
		ON Item.intItemId = tmpDSP.intItemId
	LEFT JOIN tblICCommodity Commodity
		ON Commodity.intCommodityId = Item.intCommodityId
	LEFT JOIN tblICCategory Category
		ON Category.intCategoryId = Item.intCategoryId
	INNER JOIN tblSMCompanyLocation Loc 
		ON Loc.intCompanyLocationId = tmpDSP.intLocationId