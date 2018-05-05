CREATE PROCEDURE [dbo].[uspICGetDailyStockPosition]
	@dtmDate AS DATETIME
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF



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
		AND intTransactionTypeId = 4
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
			dblQty = SUM(dbo.fnICConvertUOMtoStockUnit(t.intItemId, intItemUOMId, dblQty))
	FROM tblICInventoryTransaction t 
	INNER JOIN tblICItemLocation ItemLocation 
		ON ItemLocation.intItemLocationId = t.intItemLocationId
	WHERE ysnIsUnposted <> 1
		AND intTransactionTypeId = 33
		AND intInTransitSourceLocationId IS NULL
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
		AND intTransactionTypeId IN (10,14,15,16,17,18,19,20,43)
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
		AND t.intTransactionTypeId IN (12)
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
			dblQty = SUM(dbo.fnICConvertUOMtoStockUnit(t.intItemId, intItemUOMId, dblQty))
	FROM tblICInventoryTransaction t
	INNER JOIN tblICInventoryTransfer InvTransfer
		ON InvTransfer.intInventoryTransferId = t.intTransactionId AND InvTransfer.strTransferType = 'Location to Location'
	INNER JOIN tblICItemLocation ItemLocation
		ON ItemLocation.intItemLocationId = t.intItemLocationId 
		AND InvTransfer.intFromLocationId = ItemLocation.intLocationId
	WHERE ysnIsUnposted <> 1
		AND t.intTransactionTypeId IN (12)
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
			CompanyLocation.intCompanyLocationId,
			intTransactionTypeId,
			intLotId,
			intInTransitSourceLocationId,
			dblQty = SUM(dbo.fnICConvertUOMtoStockUnit(t.intItemId, intItemUOMId, dblQty))
	FROM tblICInventoryTransaction t
	INNER JOIN tblICInventoryTransfer InvTransfer
		ON InvTransfer.intInventoryTransferId = t.intTransactionId AND InvTransfer.strTransferType = 'Location to Location'
	INNER JOIN tblSMCompanyLocation CompanyLocation
		ON InvTransfer.intToLocationId = CompanyLocation.intCompanyLocationId
	WHERE ysnIsUnposted <> 1
		AND t.intTransactionTypeId IN (13)
		AND t.intInTransitSourceLocationId IS NOT NULL
		AND t.dtmDate = @dtmDate
	GROUP BY t.intItemId,
			CompanyLocation.intCompanyLocationId,
			intTransactionTypeId,
			intLotId,
			intInTransitSourceLocationId


	-----===== SOURCE 8 - In Transit Outbound
	INSERT INTO #tmpDailyStockPosition
	SELECT	8,
			t.intItemId,
			CompanyLocation.intCompanyLocationId,
			intTransactionTypeId,
			intLotId,
			intInTransitSourceLocationId,
			dblQty = SUM(dbo.fnICConvertUOMtoStockUnit(t.intItemId, intItemUOMId, dblQty))
	FROM tblICInventoryTransaction t
	INNER JOIN tblICInventoryTransfer InvTransfer
		ON InvTransfer.intInventoryTransferId = t.intTransactionId AND InvTransfer.strTransferType = 'Location to Location'
	INNER JOIN tblSMCompanyLocation CompanyLocation
		ON InvTransfer.intFromLocationId = CompanyLocation.intCompanyLocationId
	WHERE ysnIsUnposted <> 1
		AND t.intTransactionTypeId IN (13)
		AND t.intInTransitSourceLocationId IS NULL
		AND t.dtmDate = @dtmDate
	GROUP BY t.intItemId,
			CompanyLocation.intCompanyLocationId,
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
			dblQty = SUM(dbo.fnICConvertUOMtoStockUnit(t.intItemId, intItemUOMId, dblQty))
	FROM tblICInventoryTransaction t 
	INNER JOIN tblICItemLocation ItemLocation 
		ON ItemLocation.intItemLocationId = t.intItemLocationId
	WHERE ysnIsUnposted <> 1
		AND intTransactionTypeId IN (8)
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
		AND intTransactionTypeId IN (9)
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
			dblInvoicedQty			= ISNULL(ABS(tmpDSP.dblInvoicedQty), 0),
			dblAdjustments			= ISNULL(tmpDSP.dblAdjustments, 0),
			dblTransfersReceived	= ISNULL(tmpDSP.dblTransfersReceived, 0),
			dblTransfersShipped		= ISNULL(ABS(tmpDSP.dblTransfersShipped), 0),
			dblInTransitInbound		= ISNULL(tmpDSP.dblInTransitInbound, 0),
			dblInTransitOutbound	= ISNULL(ABS(tmpDSP.dblInTransitOutbound), 0),
			dblConsumed				= ISNULL(tmpDSP.dblConsumedQty, 0),
			dblProduced				= ISNULL(tmpDSP.dblProduced, 0),
			dblClosingQty			= tmpDSP.dblOpeningQty + tmpDSP.dblReceivedQty + tmpDSP.dblInvoicedQty + tmpDSP.dblAdjustments + tmpDSP.dblTransfersReceived + tmpDSP.dblTransfersShipped + 
										tmpDSP.dblInTransitInbound + tmpDSP.dblInTransitOutbound + tmpDSP.dblConsumedQty + tmpDSP.dblProduced
	FROM tblICItem Item
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
	INNER JOIN (
		tblICItemUOM StockUOM INNER JOIN tblICUnitMeasure sUOM
			ON StockUOM.intUnitMeasureId = sUOM.intUnitMeasureId
	) ON StockUOM.intItemId = Item.intItemId
		AND StockUOM.ysnStockUnit = 1
	INNER JOIN tblSMCompanyLocation Loc 
		ON Loc.intCompanyLocationId = tmpDSP.intLocationId