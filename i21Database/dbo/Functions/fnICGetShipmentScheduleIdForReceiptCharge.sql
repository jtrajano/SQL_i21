﻿
CREATE FUNCTION [dbo].[fnICGetShipmentScheduleIdForReceiptCharge](
	@intInventoryReceiptId INT
	,@strReceiptNumber NVARCHAR(50)
)
RETURNS TABLE
RETURN (
	-- Assuming that there is only one IR per Inbound Shipment, then pick the top inbound shipment id we can retrieve 
	-- when joining the IR and LG tables. 
	SELECT	TOP 1 
			LogisticsView.intLoadDetailId
			,LogisticsView.strLoadNumber
	FROM	tblICInventoryReceipt A INNER JOIN tblICInventoryReceiptItem B
				ON A.intInventoryReceiptId = B.intInventoryReceiptId
			OUTER APPLY (
				SELECT	dblQtyReturned = ri.dblOpenReceive - ISNULL(ri.dblQtyReturned, 0) 
						,r.strReceiptType
						,r.strReceiptNumber
				FROM	tblICInventoryReceipt r INNER JOIN tblICInventoryReceiptItem ri
							ON r.intInventoryReceiptId = ri.intInventoryReceiptId				
				WHERE	r.intInventoryReceiptId = A.intSourceInventoryReceiptId
						AND ri.intInventoryReceiptItemId = B.intSourceInventoryReceiptItemId
						AND A.strReceiptType = 'Inventory Return'
			) rtn

			OUTER APPLY (
				SELECT	* 
				FROM	vyuLGLoadContainerLookup LogisticsView 
				WHERE	LogisticsView.intLoadDetailId = B.intSourceId 
						AND LogisticsView.intLoadContainerId = B.intContainerId
						AND A.intSourceType = 2
						AND (
							A.strReceiptType = 'Purchase Contract'
							OR (
								A.strReceiptType = 'Inventory Return'
								AND rtn.strReceiptType = 'Purchase Contract'
							)
						)
			) LogisticsView
	WHERE	A.intInventoryReceiptId = @intInventoryReceiptId
			AND A.strReceiptNumber = @strReceiptNumber 
			AND A.intSourceType = 2 -- Inbound Shipment 
			AND B.intSourceId IS NOT NULL 				

)	