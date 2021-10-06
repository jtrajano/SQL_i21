CREATE PROCEDURE [dbo].[uspICGetCountGroupAsOfDate]
	@intCountGroupId AS INT,
	@intLocationId AS INT,
	@intSubLocationId AS INT = NULL,
	@intStorageLocationId AS INT = NULL,
	@dtmDate AS DATETIME = NULL	
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS ON

DECLARE @DefaultLotCondition NVARCHAR(50)
SELECT @DefaultLotCondition = strLotCondition FROM tblICCompanyPreference

DECLARE @strSubLocationDefault NVARCHAR(50);
DECLARE @strStorageUnitDefault NVARCHAR(50);

DECLARE @tblInventoryTransaction TABLE(
	intCountGroupId			INT
	,intLocationId			INT
	,intSubLocationId		INT NULL
	,intStorageLocationId	INT NULL
	,dtmDate				DATETIME
	,dblBeginQty			NUMERIC(38, 20)
	,dblOnHandQty			NUMERIC(38, 20)
	,dblReceived			NUMERIC(38, 20)
	,dblSold				NUMERIC(38, 20)
);

DECLARE @dtmDateFrom AS DATETIME 

-- Get the last 'pack count'
SELECT TOP 1 
	@dtmDateFrom = spHistory.dtmDate
FROM 
	tblICInventoryShiftPhysicalHistory spHistory
WHERE
	spHistory.intCountGroupId = @intCountGroupId
	AND spHistory.intLocationId = @intLocationId
	AND (@intSubLocationId IS NULL OR @intSubLocationId = spHistory.intSubLocationId)
	AND (@intStorageLocationId IS NULL OR @intStorageLocationId = spHistory.intStorageLocationId)
	AND spHistory.ysnIsUnposted = 0 
ORDER BY 
	intInventoryShiftPhysicalCountId DESC 

--INSERT INTO @tblInventoryTransaction (
--	intCountGroupId
--	,intLocationId
--	,intSubLocationId
--	,intStorageLocationId
--	,dtmDate
--	,dblBeginQty
--)
---- Get the begin Qty
--SELECT	
--	IL.intCountGroupId
--	,intLocationId		= IL.intLocationId
--	,intSubLocationId	= t.intSubLocationId 
--	,intStorageLocationId = t.intStorageLocationId 
--	,dtmDate			= dbo.fnRemoveTimeOnDate(dtmDate)
--	,dblOnHandQty		= dbo.fnCalculateQtyBetweenUOM(t.intItemUOMId, stockUnit.intItemUOMId, t.dblQty) 
--FROM	
--	tblICInventoryTransaction t INNER JOIN tblICItemLocation IL 
--		ON IL.intItemLocationId = t.intItemLocationId	
--	INNER JOIN tblICItemUOM stockUnit
--		ON stockUnit.intItemId = t.intItemId
--		AND stockUnit.ysnStockUnit = 1
--WHERE	
--	IL.intCountGroupId = @intCountGroupId
--	AND dbo.fnDateLessThan(t.dtmDate, @dtmDate) = 1
--	AND IL.intLocationId = @intLocationId
--	AND (@intSubLocationId IS NULL OR @intSubLocationId = t.intSubLocationId)
--	AND (@intStorageLocationId IS NULL OR @intStorageLocationId = t.intStorageLocationId)

---- Get the On-Hand Qty
--INSERT INTO @tblInventoryTransaction (
--	intCountGroupId
--	,intLocationId
--	,intSubLocationId
--	,intStorageLocationId
--	,dtmDate
--	,dblOnHandQty
--)
--SELECT	
--	IL.intCountGroupId
--	,intLocationId		= IL.intLocationId
--	,intSubLocationId	= t.intSubLocationId 
--	,intStorageLocationId = t.intStorageLocationId 
--	,dtmDate			= dbo.fnRemoveTimeOnDate(dtmDate)
--	,dblOnHandQty		= dbo.fnCalculateQtyBetweenUOM(t.intItemUOMId, stockUnit.intItemUOMId, t.dblQty) 
--FROM	
--	tblICInventoryTransaction t INNER JOIN tblICItemLocation IL 
--		ON IL.intItemLocationId = t.intItemLocationId	
--	INNER JOIN tblICItemUOM stockUnit
--		ON stockUnit.intItemId = t.intItemId
--		AND stockUnit.ysnStockUnit = 1
--WHERE	
--	IL.intCountGroupId = @intCountGroupId
--	AND dbo.fnDateLessThanEquals(t.dtmDate, @dtmDate) = 1
--	AND IL.intLocationId = @intLocationId
--	AND (@intSubLocationId IS NULL OR @intSubLocationId = t.intSubLocationId)
--	AND (@intStorageLocationId IS NULL OR @intStorageLocationId = t.intStorageLocationId)

-- Get the Begin Qty
INSERT INTO @tblInventoryTransaction (
	intCountGroupId
	,intLocationId
	,intSubLocationId
	,intStorageLocationId
	,dtmDate
	,dblOnHandQty
)
SELECT TOP 1 
	spHistory.intCountGroupId
	,spHistory.intLocationId
	,spHistory.intSubLocationId
	,spHistory.intStorageLocationId
	,@dtmDate
	,dblOnHandQty = ISNULL(spHistory.dblPhysicalCount, 0) 
		--ISNULL(spHistory.dblPhysicalCount, 0) 
		--- ISNULL(spHistory.dblSystemCount, 0) 
		--+ ISNULL(spHistory.dblQtyReceived, 0) 
		--- ISNULL(spHistory.dblQtySold, 0)
FROM 
	tblICInventoryShiftPhysicalHistory spHistory
WHERE
	spHistory.intCountGroupId = @intCountGroupId
	AND spHistory.intLocationId = @intLocationId
	AND (@intSubLocationId IS NULL OR @intSubLocationId = spHistory.intSubLocationId)
	AND (@intStorageLocationId IS NULL OR @intStorageLocationId = spHistory.intStorageLocationId)
	AND spHistory.ysnIsUnposted = 0 
ORDER BY 
	spHistory.intInventoryShiftPhysicalCountId DESC  

-- Get the receipts
INSERT INTO @tblInventoryTransaction (
	intCountGroupId
	,intLocationId
	,intSubLocationId
	,intStorageLocationId
	,dtmDate
	,dblReceived
)
SELECT 
	il.intCountGroupId
	,r.intLocationId
	,ri.intSubLocationId
	,ri.intStorageLocationId
	,dbo.fnRemoveTimeOnDate(r.dtmReceiptDate)
	,dblQty = 
		CASE 
			WHEN ri.intWeightUOMId IS NOT NULL THEN dbo.fnCalculateQtyBetweenUOM(ri.intWeightUOMId, stockUnit.intItemUOMId, ri.dblNet)
			ELSE dbo.fnCalculateQtyBetweenUOM(ri.intUnitMeasureId, stockUnit.intItemUOMId, ri.dblOpenReceive)
		END
FROM 
	tblICInventoryReceipt r INNER JOIN tblICInventoryReceiptItem ri
		ON r.intInventoryReceiptId = ri.intInventoryReceiptId
	INNER JOIN tblICItemLocation il
		ON il.intItemId = ri.intItemId
		AND il.intLocationId = r.intLocationId
	INNER JOIN tblICItemUOM stockUnit
		ON stockUnit.intItemId = ri.intItemId
		AND stockUnit.ysnStockUnit = 1
WHERE	
	il.intCountGroupId = @intCountGroupId
	AND dbo.fnDateGreaterThanEquals(r.dtmReceiptDate, @dtmDateFrom) = 1
	AND dbo.fnDateLessThanEquals(r.dtmReceiptDate, @dtmDate) = 1
	AND il.intLocationId = @intLocationId
	AND (@intSubLocationId IS NULL OR @intSubLocationId = ri.intSubLocationId)
	AND (@intStorageLocationId IS NULL OR @intStorageLocationId = ri.intStorageLocationId)
	--AND ISNULL(r.ysnPosted, 0) = 0 

-- Get the unposted sales invoices
INSERT INTO @tblInventoryTransaction (
	intCountGroupId
	,intLocationId
	,intSubLocationId
	,intStorageLocationId
	,dtmDate
	,dblSold
)
SELECT 
	il.intCountGroupId
	,inv.intCompanyLocationId
	,invD.intSubLocationId
	,invD.intStorageLocationId
	,dbo.fnRemoveTimeOnDate(inv.dtmDate)
	,dblQty = dbo.fnCalculateQtyBetweenUOM(invD.intItemUOMId, stockUnit.intItemUOMId, invD.dblQtyShipped)
FROM 
	tblARInvoice inv INNER JOIN tblARInvoiceDetail invD
		ON inv.intInvoiceId = invD.intInvoiceId
	INNER JOIN tblICItemLocation il
		ON il.intItemId = invD.intItemId
		AND il.intLocationId = inv.intCompanyLocationId
	INNER JOIN tblICItemUOM stockUnit
		ON stockUnit.intItemId = invD.intItemId
		AND stockUnit.ysnStockUnit = 1
WHERE	
	il.intCountGroupId = @intCountGroupId
	AND dbo.fnDateGreaterThanEquals(inv.dtmDate, @dtmDateFrom) = 1
	AND dbo.fnDateLessThanEquals(inv.dtmDate, @dtmDate) = 1
	AND il.intLocationId = @intLocationId
	AND (@intSubLocationId IS NULL OR @intSubLocationId = invD.intSubLocationId)
	AND (@intStorageLocationId IS NULL OR @intStorageLocationId = invD.intStorageLocationId)
	--AND ISNULL(inv.ysnPosted, 0) = 0 

-- Get the unposted check out -> Stock Movement
INSERT INTO @tblInventoryTransaction (
	intCountGroupId
	,intLocationId
	,intSubLocationId
	,intStorageLocationId
	,dtmDate
	,dblSold
)
SELECT 
	il.intCountGroupId
	,il.intLocationId
	,ch.intCompanyLocationSubLocationId
	,ch.intStorageLocationId
	,dbo.fnRemoveTimeOnDate(ch.dtmCheckoutDate)
	,dblQty = sm.intQtySold
FROM 
	tblSTCheckoutHeader ch INNER JOIN tblSTStore st
		ON ch.intStoreId = st.intStoreId
	INNER JOIN tblSTCheckoutItemMovements sm
		ON ch.intCheckoutId = sm.intCheckoutId
	INNER JOIN tblICItemUOM itemUOM
		ON itemUOM.intItemUOMId = sm.intItemUPCId
	INNER JOIN tblICItemLocation il
		ON il.intLocationId = st.intCompanyLocationId
		AND il.intItemId = itemUOM.intItemId
WHERE	
	il.intCountGroupId = @intCountGroupId
	AND dbo.fnDateGreaterThanEquals(ch.dtmCheckoutDate, @dtmDateFrom) = 1
	AND dbo.fnDateLessThanEquals(ch.dtmCheckoutDate, @dtmDate) = 1
	AND il.intLocationId = @intLocationId
	AND (@intSubLocationId IS NULL OR @intSubLocationId = ch.intCompanyLocationSubLocationId)
	AND (@intStorageLocationId IS NULL OR @intStorageLocationId = ch.intStorageLocationId)
	--AND ch.intInvoiceId IS NULL -- If NULL, check out is not yet posted. 
	
-- Return the result back. 
SELECT 
	intKey							= CAST(ROW_NUMBER() OVER(ORDER BY c.intCountGroupId, t.intLocationId) AS INT)
	,c.intCountGroupId
	,c.strCountGroup 
	,t.intLocationId
	,strLocationName				= CompanyLocation.strLocationName
	,t.intSubLocationId
	,SubLocation.strSubLocationName
	,t.intStorageLocationId
	,strStorageLocationName			= strgLoc.strName
	,dblBeginQty			= SUM(t.dblBeginQty) 
	,dblOnHandQty			= SUM(t.dblOnHandQty) 
	,dblReceived			= SUM(t.dblReceived) 
	,dblSold				= SUM(t.dblSold) 
FROM 
	@tblInventoryTransaction t 
	INNER JOIN tblICCountGroup c 
		ON c.intCountGroupId = c.intCountGroupId
	LEFT JOIN tblSMCompanyLocation CompanyLocation 
		ON CompanyLocation.intCompanyLocationId = t.intLocationId
	LEFT JOIN tblSMCompanyLocationSubLocation SubLocation 
		ON SubLocation.intCompanyLocationSubLocationId = t.intSubLocationId
	LEFT JOIN tblICStorageLocation strgLoc 
		ON strgLoc.intStorageLocationId = t.intStorageLocationId
GROUP BY 
	c.intCountGroupId
	,c.strCountGroup 
	,t.intLocationId
	,CompanyLocation.strLocationName
	,t.intSubLocationId
	,SubLocation.strSubLocationName
	,t.intStorageLocationId
	,strgLoc.strName
--HAVING	
--	(@ysnHasStockOnly = 1 AND SUM(t.dblBeginQty) <> 0)
--	OR @ysnHasStockOnly = 0 
