CREATE PROCEDURE [dbo].[uspICUpdateInventoryShiftCountDetails]
	  @intInventoryCountId INT
	, @intEntityUserSecurityId INT
	, @strHeaderNo NVARCHAR(50)
	, @intLocationId INT = 0
	, @intCountGroupId INT = 0
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS ON

DELETE FROM tblICInventoryCountDetail
WHERE intInventoryCountId = @intInventoryCountId

--;WITH LastShiftCount AS
--(
--	SELECT c.intInventoryCountId, c.strCountNo, cd.intCountGroupId, cd.dblPhysicalCount, cd.intInventoryCountDetailId,
--		ROW_NUMBER() OVER
--        (
--			PARTITION BY cd.intCountGroupId
--            ORDER BY cd.intInventoryCountDetailId DESC
--        ) AS intRank
--    FROM tblICInventoryCountDetail cd
--		INNER JOIN tblICInventoryCount c ON c.intInventoryCountId = cd.intInventoryCountId
--	WHERE ISNULL(NULLIF(c.strCountBy, ''), 'Item') = 'Retail Count'
--		AND cd.intCountGroupId IS NOT NULL
--		AND (cd.intCountGroupId = @intCountGroupId OR ISNULL(@intCountGroupId, 0) = 0)
--)
--INSERT INTO tblICInventoryCountDetail(
--	  intInventoryCountId
--	, dblSystemCount
--	, strCountLine
--	, dblQtyReceived
--	, dblQtySold
--	, intCountGroupId
--	, intEntityUserSecurityId
--	, intConcurrencyId
--	, intSort)
--SELECT
--	  @intInventoryCountId
--	, ISNULL(sc.dblPhysicalCount, 0.00)
--	, @strHeaderNo + '-' + CAST(ROW_NUMBER() OVER(ORDER BY sc.intCountGroupId ASC) AS NVARCHAR(50))
--	, 0.00
--	, 0.00
--	, cg.intCountGroupId
--	, intEntityUserSecurityId = @intEntityUserSecurityId
--	, intConcurrencyId = 1
--	, intSort = 1
--FROM tblICCountGroup cg
--OUTER APPLY (
--	SELECT lsc.*
--	FROM LastShiftCount lsc
--	WHERE lsc.intRank = 1
--		AND lsc.intCountGroupId = cg.intCountGroupId
--) sc
--WHERE (cg.intCountGroupId = @intCountGroupId OR ISNULL(@intCountGroupId, 0) = 0)

--;WITH CountGroupItems AS
--(
	

--)
INSERT INTO tblICInventoryCountDetail(
	intInventoryCountId
	, intItemId
	, intCountGroupId
	, intItemLocationId
	, intSubLocationId
	, intStorageLocationId
	, intLotId
	, dblSystemCount
	, dblLastCost
	, strCountLine
	, intItemUOMId
	, ysnRecount
	, ysnFetched
	, intEntityUserSecurityId
	, intConcurrencyId
	, intSort
	, dblPhysicalCount
	, dblQtyReceived
	, dblQtySold
)
SELECT 
	@intInventoryCountId
	,CountGroupItems.intItemId 
	,@intCountGroupId
	,CountGroupItems.intItemLocationId
	,intSubLocationId = NULL 
	,intStorageLocationId = NULL
	,intLotId = NULL
	,dblSystemCount = ISNULL(CountGroupItems.dblQty, 0) 
	,dblLastCost = ISNULL(CountGroupItems.dblCost, 0) 
	,strCountLine = @strHeaderNo + '-' + CAST(CountGroupItems.intRank AS NVARCHAR(50))
	,intItemUOMId = CountGroupItems.intItemUOMId
	,ysnRecount = 0 
	,ysnFetched = 1
	,intEntityUserSecurityId = @intEntityUserSecurityId
	,intConcurrencyId = 1
	,intSort = CountGroupItems.intRank 
	,dblPhysicalCount = NULL
	,dblQtyReceived = ISNULL(CountGroupItems.dblQtyReceived, 0)
	,dblQtySold = ISNULL(CountGroupItems.dblQtySold, 0) 

FROM (
	SELECT 
			i.intItemId
			,i.strItemNo
			,il.intItemLocationId
			,stockUOM.intItemUOMId
			,stockAsOfDate.dblQty
			,lastCostAsOfDate.dblCost
			,dblQtyReceived = qtyReceived.dblQty
			,dblQtySold = 
				ISNULL(qtyShipped.dblQty, 0) 
				+ ISNULL(qtySold.dblQty, 0) 
				+ ISNULL(qtyItemMovements.dblQty, 0) 
				+ ISNULL(qtyPumpTotals.dblQty, 0)
				+ ISNULL(qtyConsumed.dblQty, 0) 
			,intRank = ROW_NUMBER() OVER( PARTITION BY i.intItemId ORDER BY i.strItemNo DESC) 
		FROM 
			tblICItem i INNER JOIN tblICItemLocation il 
				ON i.intItemId = il.intItemId
				AND il.intLocationId IS NOT NULL 
			CROSS APPLY (
				SELECT TOP 1 
					stockUOM.intItemUOMId
				FROM 
					tblICItemUOM stockUOM
				WHERE
					stockUOM.intItemId = i.intItemId
					AND stockUOM.ysnStockUnit = 1				
			) stockUOM		
			OUTER APPLY (
				SELECT 
					t.* 
				FROM 
					tblICInventoryCount c
					OUTER APPLY (
						SELECT 
							dblQty = SUM(
									dbo.fnCalculateQtyBetweenUOM(t.intItemUOMId, sUOM.intItemUOMId, t.dblQty)
								)
						FROM 
							tblICInventoryTransaction t
							CROSS APPLY (
								SELECT TOP 1 
									sUOM.intItemUOMId
								FROM 
									tblICItemUOM sUOM
								WHERE
									sUOM.intItemId = t.intItemId
									AND sUOM.ysnStockUnit = 1				
							) sUOM		
						WHERE
							t.intItemId = i.intItemId
							AND t.intItemLocationId = il.intItemLocationId
							AND dbo.fnDateLessThan(t.dtmDate, c.dtmCountDate) = 1	
					) t
				WHERE
					c.intInventoryCountId = @intInventoryCountId
		
			) stockAsOfDate
			OUTER APPLY (
				SELECT 
					lastCost.* 
				FROM 
					tblICInventoryCount c
					OUTER APPLY (
						SELECT 
							TOP 1 
							dblCost = dbo.fnCalculateCostBetweenUOM(t.intItemUOMId, stockUOM.intItemUOMId, t.dblCost) 
						FROM 
							tblICInventoryTransaction t
						WHERE
							t.intItemId = i.intItemId
							AND t.intItemLocationId = il.intItemLocationId
							AND dbo.fnDateLessThan(t.dtmDate, c.dtmCountDate) = 1	
						ORDER BY
							t.intInventoryTransactionId DESC 
					) lastCost
				WHERE
					c.intInventoryCountId = @intInventoryCountId
		
			) lastCostAsOfDate
			OUTER APPLY (
				SELECT 
					receipt.* 
				FROM 
					tblICInventoryCount c
					OUTER APPLY (
						SELECT 
							dblQty = SUM (
								dbo.fnCalculateQtyBetweenUOM(
									ISNULL(ri.intWeightUOMId, ri.intUnitMeasureId)
									, sUOM.intItemUOMId
									, CASE WHEN ri.intWeightUOMId IS NOT NULL THEN ri.dblNet ELSE ri.dblOpenReceive END 
								) 
							) 
						FROM
							tblICInventoryReceipt r INNER JOIN tblICInventoryReceiptItem ri
								ON r.intInventoryReceiptId = ri.intInventoryReceiptId
							CROSS APPLY (
								SELECT TOP 1 
									sUOM.intItemUOMId
								FROM 
									tblICItemUOM sUOM
								WHERE
									sUOM.intItemId = ri.intItemId
									AND sUOM.ysnStockUnit = 1				
							) sUOM	

						WHERE
							ri.intItemId = i.intItemId
							AND r.intLocationId = il.intLocationId
							AND dbo.fnDateEquals(r.dtmReceiptDate, c.dtmCountDate) = 1

					) receipt
				WHERE
					c.intInventoryCountId = @intInventoryCountId		
			) qtyReceived
			OUTER APPLY (
				SELECT 
					shipment.* 
				FROM 
					tblICInventoryCount c
					OUTER APPLY (
						SELECT 
							dblQty = SUM (
								dbo.fnCalculateQtyBetweenUOM(
									si.intItemUOMId
									, sUOM.intItemUOMId
									, si.dblQuantity
								) 
							) 
						FROM
							tblICInventoryShipment s INNER JOIN tblICInventoryShipmentItem si
								ON s.intInventoryShipmentId = si.intInventoryShipmentId
							CROSS APPLY (
								SELECT TOP 1 
									sUOM.intItemUOMId
								FROM 
									tblICItemUOM sUOM
								WHERE
									sUOM.intItemId = si.intItemId
									AND sUOM.ysnStockUnit = 1				
							) sUOM	
						WHERE
							si.intItemId = i.intItemId
							AND s.intShipFromLocationId = il.intLocationId
							AND dbo.fnDateEquals(s.dtmShipDate, c.dtmCountDate) = 1

					) shipment
				WHERE
					c.intInventoryCountId = @intInventoryCountId		
			) qtyShipped

			OUTER APPLY (
				SELECT 
					invoice.* 
				FROM 
					tblICInventoryCount c
					OUTER APPLY (
						SELECT 
							dblQty = SUM (
								dbo.fnCalculateQtyBetweenUOM(
									invD.intItemUOMId
									, sUOM.intItemUOMId
									, invD.dblQtyShipped
								) 
							) 
						FROM
							tblARInvoice inv INNER JOIN tblARInvoiceDetail invD
								ON inv.intInvoiceId = invD.intInvoiceId
								AND invD.intInventoryShipmentItemId IS NULL 
							CROSS APPLY (
								SELECT TOP 1 
									sUOM.intItemUOMId
								FROM 
									tblICItemUOM sUOM
								WHERE
									sUOM.intItemId = invD.intItemId
									AND sUOM.ysnStockUnit = 1				
							) sUOM	
						WHERE
							invD.intItemId = i.intItemId
							AND inv.intCompanyLocationId = il.intLocationId
							AND dbo.fnDateEquals(inv.dtmDate, c.dtmCountDate) = 1

					) invoice
				WHERE
					c.intInventoryCountId = @intInventoryCountId		
			) qtySold

			OUTER APPLY (
				SELECT 
					consume.* 
				FROM 
					tblICInventoryCount c
					OUTER APPLY (
						SELECT 
							dblQty = SUM (
								dbo.fnCalculateQtyBetweenUOM(
									t.intItemUOMId
									, sUOM.intItemUOMId
									, -t.dblQty
								) 
							) 
						FROM
							tblICInventoryTransaction t 							
							CROSS APPLY (
								SELECT TOP 1 
									sUOM.intItemUOMId
								FROM 
									tblICItemUOM sUOM
								WHERE
									sUOM.intItemId = t.intItemId
									AND sUOM.ysnStockUnit = 1				
							) sUOM	
						WHERE
							t.intItemId = i.intItemId
							AND t.intItemLocationId = il.intItemLocationId
							AND dbo.fnDateEquals(t.dtmDate, c.dtmCountDate) = 1
							AND t.intTransactionTypeId = 8 -- Consume
					) consume
				WHERE
					c.intInventoryCountId = @intInventoryCountId		
			) qtyConsumed

			OUTER APPLY (
				SELECT 
					itemMovements.* 
				FROM 
					tblICInventoryCount c
					OUTER APPLY (
						SELECT 
							dblQty = SUM (
								dbo.fnCalculateQtyBetweenUOM(
									v.intItemUOMId
									, sUOM.intItemUOMId
									, v.dblQuantity
								) 
							) 
						FROM
							vyuSTUnpostedItemMovements v 
							CROSS APPLY (
								SELECT TOP 1 
									sUOM.intItemUOMId
								FROM 
									tblICItemUOM sUOM
								WHERE
									sUOM.intItemId = v.intItemId
									AND sUOM.ysnStockUnit = 1				
							) sUOM	
						WHERE
							v.intItemId = i.intItemId
							AND v.intCompanyLocationId = il.intLocationId					
							AND dbo.fnDateEquals(v.dtmCheckoutDate, c.dtmCountDate) = 1

					) itemMovements
				WHERE
					c.intInventoryCountId = @intInventoryCountId		
			) qtyItemMovements
		
			OUTER APPLY (
				SELECT 
					itemMovements.* 
				FROM 
					tblICInventoryCount c
					OUTER APPLY (
						SELECT 
							dblQty = SUM (
								dbo.fnCalculateQtyBetweenUOM(
									v.intItemUOMId
									, sUOM.intItemUOMId
									, v.dblQuantity
								) 
							) 
						FROM
							vyuSTUnpostedPumpTotals v 
							CROSS APPLY (
								SELECT TOP 1 
									sUOM.intItemUOMId
								FROM 
									tblICItemUOM sUOM
								WHERE
									sUOM.intItemId = v.intItemId
									AND sUOM.ysnStockUnit = 1				
							) sUOM	
						WHERE
							v.intItemId = i.intItemId
							AND v.intCompanyLocationId = il.intLocationId					
							AND dbo.fnDateEquals(v.dtmCheckoutDate, c.dtmCountDate) = 1

					) itemMovements
				WHERE
					c.intInventoryCountId = @intInventoryCountId		
			) qtyPumpTotals

		WHERE 
			il.intLocationId = @intLocationId
			AND il.intCountGroupId = @intCountGroupId 
			AND dbo.fnIsStockTrackingItem(i.intItemId) = 1
) CountGroupItems


DECLARE @intSort AS INT 
SELECT @intSort = MAX(intSort)
FROM 
	tblICInventoryCountDetail
WHERE 
	intInventoryCountId = @intInventoryCountId

SET @intSort = ISNULL(@intSort, 0) 

-- Insert the Count Group
INSERT INTO tblICInventoryCountDetail(
	intInventoryCountId
	, intItemId
	, intCountGroupId
	, intItemLocationId
	, intSubLocationId
	, intStorageLocationId
	, intLotId
	, dblSystemCount
	, dblLastCost
	, strCountLine
	, intItemUOMId
	, ysnRecount
	, ysnFetched
	, intEntityUserSecurityId
	, intConcurrencyId
	, intSort
	, dblPhysicalCount
	, dblQtyReceived
	, dblQtySold
)
SELECT 
	@intInventoryCountId
	,intItemId = NULL
	,CountGroup.intCountGroupId
	,intItemLocationId = NULL 
	,intSubLocationId = NULL 
	,intStorageLocationId = NULL
	,intLotId = NULL
	,dblSystemCount = ISNULL(CountGroup.dblQty, 0) 
	,dblLastCost = 0
	,strCountLine = @strHeaderNo + '-' + CAST(@intSort + CountGroup.intRank AS NVARCHAR(50))
	,intItemUOMId = NULL 
	,ysnRecount = 0 
	,ysnFetched = 1
	,intEntityUserSecurityId = @intEntityUserSecurityId
	,intConcurrencyId = 1
	,intSort = CountGroup.intRank 
	,dblPhysicalCount = NULL
	,dblQtyReceived = ISNULL(CountGroup.dblQtyReceived, 0)
	,dblQtySold = ISNULL(CountGroup.dblQtySold, 0) 

FROM (
	SELECT 
			countGroup.intCountGroupId
			,stockAsOfDate.dblQty			
			,dblQtyReceived = qtyReceived.dblQty
			,dblQtySold = 
				ISNULL(qtyShipped.dblQty, 0) 
				+ ISNULL(qtySold.dblQty, 0) 
				+ ISNULL(qtyItemMovements.dblQty, 0) 
				+ ISNULL(qtyPumpTotals.dblQty, 0)
				+ ISNULL(qtyConsumed.dblQty, 0) 
			,intRank = ROW_NUMBER() OVER( PARTITION BY countGroup.intCountGroupId ORDER BY countGroup.intCountGroupId DESC) 
		FROM 
			vyuICGetCountGroup countGroup
			OUTER APPLY (
				SELECT 					
					t.* 
				FROM 
					tblICInventoryCount c
					OUTER APPLY (						
						SELECT TOP 1 
							dblQty = t.dblPhysicalCount
						FROM 
							tblICInventoryShiftPhysicalHistory t
						WHERE
							t.intCountGroupId = countGroup.intCountGroupId
							AND t.intLocationId = c.intLocationId
							AND dbo.fnDateLessThan(t.dtmDate, c.dtmCountDate) = 1	
						ORDER BY
							t.dtmDate DESC, t.intInventoryShiftPhysicalCountId DESC 
					) t
				WHERE
					c.intInventoryCountId = @intInventoryCountId		
			) stockAsOfDate

			OUTER APPLY (
				SELECT 
					receipt.* 
				FROM 
					tblICInventoryCount c
					OUTER APPLY (
						SELECT 
							dblQty = SUM (
								dbo.fnCalculateQtyBetweenUOM(
									ISNULL(ri.intWeightUOMId, ri.intUnitMeasureId)
									, sUOM.intItemUOMId
									, CASE WHEN ri.intWeightUOMId IS NOT NULL THEN ri.dblNet ELSE ri.dblOpenReceive END 
								) 
							) 
						FROM
							tblICInventoryReceipt r INNER JOIN tblICInventoryReceiptItem ri
								ON r.intInventoryReceiptId = ri.intInventoryReceiptId
							INNER JOIN tblICItem i 
								ON i.intItemId = ri.intItemId
							INNER JOIN tblICItemLocation il
								ON il.intItemId = i.intItemId								
								AND r.intLocationId = il.intLocationId
							CROSS APPLY (
								SELECT TOP 1 
									sUOM.intItemUOMId
								FROM 
									tblICItemUOM sUOM
								WHERE
									sUOM.intItemId = ri.intItemId
									AND sUOM.ysnStockUnit = 1				
							) sUOM	
						WHERE
							il.intCountGroupId = countGroup.intCountGroupId														
							AND dbo.fnDateEquals(r.dtmReceiptDate, c.dtmCountDate) = 1

					) receipt
				WHERE
					c.intInventoryCountId = @intInventoryCountId		
			) qtyReceived
			OUTER APPLY (
				SELECT 
					shipment.* 
				FROM 
					tblICInventoryCount c
					OUTER APPLY (
						SELECT 
							dblQty = SUM (
								dbo.fnCalculateQtyBetweenUOM(
									si.intItemUOMId
									, sUOM.intItemUOMId
									, si.dblQuantity
								) 
							) 
						FROM
							tblICInventoryShipment s INNER JOIN tblICInventoryShipmentItem si
								ON s.intInventoryShipmentId = si.intInventoryShipmentId
							INNER JOIN tblICItem i 
								ON i.intItemId = si.intItemId
							INNER JOIN tblICItemLocation il
								ON il.intItemId = i.intItemId								
								AND s.intShipFromLocationId = il.intLocationId
							CROSS APPLY (
								SELECT TOP 1 
									sUOM.intItemUOMId
								FROM 
									tblICItemUOM sUOM
								WHERE
									sUOM.intItemId = si.intItemId
									AND sUOM.ysnStockUnit = 1				
							) sUOM	
						WHERE
							il.intCountGroupId = countGroup.intCountGroupId							
							AND dbo.fnDateEquals(s.dtmShipDate, c.dtmCountDate) = 1
					) shipment
				WHERE
					c.intInventoryCountId = @intInventoryCountId		
			) qtyShipped
			OUTER APPLY (
				SELECT 
					invoice.* 
				FROM 
					tblICInventoryCount c
					OUTER APPLY (
						SELECT 
							dblQty = SUM (
								dbo.fnCalculateQtyBetweenUOM(
									invD.intItemUOMId
									, sUOM.intItemUOMId
									, invD.dblQtyShipped
								) 
							) 
						FROM
							tblARInvoice inv INNER JOIN tblARInvoiceDetail invD
								ON inv.intInvoiceId = invD.intInvoiceId
								AND invD.intInventoryShipmentItemId IS NULL 
							INNER JOIN tblICItem i 
								ON i.intItemId = invD.intItemId
							INNER JOIN tblICItemLocation il
								ON il.intItemId = i.intItemId								
								AND inv.intCompanyLocationId = il.intLocationId
							CROSS APPLY (
								SELECT TOP 1 
									sUOM.intItemUOMId
								FROM 
									tblICItemUOM sUOM
								WHERE
									sUOM.intItemId = invD.intItemId
									AND sUOM.ysnStockUnit = 1				
							) sUOM	
						WHERE
							il.intCountGroupId = countGroup.intCountGroupId							
							AND dbo.fnDateEquals(inv.dtmDate, c.dtmCountDate) = 1

					) invoice
				WHERE
					c.intInventoryCountId = @intInventoryCountId		
			) qtySold

			OUTER APPLY (
				SELECT 
					invoice.* 
				FROM 
					tblICInventoryCount c
					OUTER APPLY (
						SELECT 
							dblQty = SUM (
								dbo.fnCalculateQtyBetweenUOM(
									t.intItemUOMId
									, sUOM.intItemUOMId
									, -t.dblQty
								) 
							) 
						FROM
							tblICInventoryTransaction t 
							INNER JOIN tblICItem i 
								ON i.intItemId = t.intItemId
							INNER JOIN tblICItemLocation il
								ON il.intItemId = i.intItemId								
								AND t.intItemLocationId = il.intItemLocationId
							CROSS APPLY (
								SELECT TOP 1 
									sUOM.intItemUOMId
								FROM 
									tblICItemUOM sUOM
								WHERE
									sUOM.intItemId = t.intItemId
									AND sUOM.ysnStockUnit = 1				
							) sUOM	
						WHERE
							il.intCountGroupId = countGroup.intCountGroupId							
							AND dbo.fnDateEquals(t.dtmDate, c.dtmCountDate) = 1
							AND t.intTransactionTypeId = 8 -- Consume

					) invoice
				WHERE
					c.intInventoryCountId = @intInventoryCountId		
			) qtyConsumed

			OUTER APPLY (
				SELECT 
					itemMovements.* 
				FROM 
					tblICInventoryCount c
					OUTER APPLY (
						SELECT 
							dblQty = SUM (
								dbo.fnCalculateQtyBetweenUOM(
									v.intItemUOMId
									, sUOM.intItemUOMId
									, v.dblQuantity
								) 
							) 
						FROM
							vyuSTUnpostedItemMovements v 
							INNER JOIN tblICItem i 
								ON i.intItemId = v.intItemId
							INNER JOIN tblICItemLocation il
								ON il.intItemId = i.intItemId								
								AND v.intCompanyLocationId = il.intLocationId
							CROSS APPLY (
								SELECT TOP 1 
									sUOM.intItemUOMId
								FROM 
									tblICItemUOM sUOM
								WHERE
									sUOM.intItemId = v.intItemId
									AND sUOM.ysnStockUnit = 1				
							) sUOM	
						WHERE
							il.intCountGroupId = countGroup.intCountGroupId							
							AND dbo.fnDateEquals(v.dtmCheckoutDate, c.dtmCountDate) = 1

					) itemMovements
				WHERE
					c.intInventoryCountId = @intInventoryCountId		
			) qtyItemMovements

			OUTER APPLY (
				SELECT 
					itemMovements.* 
				FROM 
					tblICInventoryCount c
					OUTER APPLY (
						SELECT 
							dblQty = SUM (
								dbo.fnCalculateQtyBetweenUOM(
									v.intItemUOMId
									, sUOM.intItemUOMId
									, v.dblQuantity
								) 
							) 
						FROM
							vyuSTUnpostedPumpTotals v 
							INNER JOIN tblICItem i 
								ON i.intItemId = v.intItemId
							INNER JOIN tblICItemLocation il
								ON il.intItemId = i.intItemId								
								AND v.intCompanyLocationId = il.intLocationId
							CROSS APPLY (
								SELECT TOP 1 
									sUOM.intItemUOMId
								FROM 
									tblICItemUOM sUOM
								WHERE
									sUOM.intItemId = v.intItemId
									AND sUOM.ysnStockUnit = 1				
							) sUOM	
						WHERE
							il.intCountGroupId = countGroup.intCountGroupId							
							AND dbo.fnDateEquals(v.dtmCheckoutDate, c.dtmCountDate) = 1

					) itemMovements
				WHERE
					c.intInventoryCountId = @intInventoryCountId		
			) qtyPumpTotals
		
		WHERE 
			countGroup.intCountWithGroupId = @intCountGroupId			
) CountGroup