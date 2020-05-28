CREATE PROCEDURE [dbo].[uspICLogRiskPositionFromOnHand]
	@strBatchId AS NVARCHAR(40)
	,@strTransactionId AS NVARCHAR(50) = NULL 
	,@intEntityUserSecurityId AS INT
AS
	
SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

DECLARE @strBucketType AS NVARCHAR(50) = 'Company Owned'
		,@strActionType AS NVARCHAR(500)

--SELECT @strBucketType = 
--	CASE 
--		WHEN @intBucketType = 1 THEN 'Company Owned'
--		WHEN @intBucketType = 2 THEN 'Sales In-Transit'
--		WHEN @intBucketType = 3 THEN 'Purchase In-Transit'
--		WHEN @intBucketType = 4 THEN 'In-House'
--	END

--SELECT @strActionType =
--	CASE 
--		WHEN @intActionType = 1 THEN 'Work Order Production'
--		WHEN @intActionType = 2 THEN 'Work Order Consumption'
--		WHEN @intActionType = 3 THEN 'Inventory Adjustment'
--		WHEN @intActionType = 4 THEN 'Inventory Transfer'
--		WHEN @intActionType = 5 THEN 'Receipt on Purchase Priced Contract'
--		WHEN @intActionType = 6 THEN 'Receipt on Purchase Basis Contract (PBD)'
--		WHEN @intActionType = 7 THEN 'Receipt on Company Owned Storage'
--		WHEN @intActionType = 8 THEN 'Receipt on Spot Priced'
--		WHEN @intActionType = 9 THEN 'Customer owned to Company owned Storage'
--		WHEN @intActionType = 10 THEN 'Delivery on Sales Priced Contract'
--		WHEN @intActionType = 11 THEN 'Delivery on Sales Basis Contract (SBD)'
--		WHEN @intActionType = 12 THEN 'Shipment on Spot Priced'
--	END

-- Create the temp table to skip a batch id from logging into the summary log. 
IF OBJECT_ID('tempdb..#tmpICLogRiskPositionFromOnHandSkipList') IS NULL  
BEGIN 
	CREATE TABLE #tmpICLogRiskPositionFromOnHandSkipList (
		strBatchId NVARCHAR(50) COLLATE Latin1_General_CI_AS 
	)
END 

-- Exist immediately if 
IF EXISTS (SELECT TOP 1 1 FROM #tmpICLogRiskPositionFromOnHandSkipList WHERE strBatchId = @strBatchId)
	RETURN;

-----------------------------------------
-- Call Risk Module's Summary Log sp
-----------------------------------------
BEGIN 
	DECLARE @SummaryLogs AS RKSummaryLog 

	BEGIN 
		INSERT INTO @SummaryLogs (	
			strBatchId
			,strBucketType
			,strTransactionType
			,intTransactionRecordHeaderId
			,intTransactionRecordId
			,strTransactionNumber 
			,dtmTransactionDate 
			,intContractDetailId 
			,intContractHeaderId 
			,intTicketId 
			,intCommodityId 
			,intCommodityUOMId 
			,intItemId 
			,intBookId 
			,intSubBookId 
			,intLocationId 
			,intFutureMarketId 
			,intFutureMonthId 
			,dblNoOfLots 
			,dblQty 
			,dblPrice 
			,intEntityId 
			,ysnDelete 
			,intUserId 
			,strNotes
			,strDistributionType
			,intActionId
		)
		SELECT 
			strBatchId = t.strBatchId
			,strBucketType = @strBucketType
			,strTransactionType = v.strTransactionType
			,intTransactionRecordHeaderId = t.intTransactionId
			,intTransactionRecordId = t.intTransactionDetailId
			,strTransactionNumber = t.strTransactionId
			,dtmTransactionDate = t.dtmDate
			,intContractDetailId = COALESCE(
				receipt.intContractDetailId
				, shipment.intContractDetailId
				, invoice.intContractDetailId
			)
			,intContractHeaderId = COALESCE(
				receipt.intContractHeaderId
				, shipment.intContractHeaderId
				, invoice.intContractHeaderId
			)
			,intTicketId = v.intTicketId
			,intCommodityId = v.intCommodityId
			,intCommodityUOMId = commodityUOM.intCommodityUnitMeasureId
			,intItemId = t.intItemId
			,intBookId = NULL
			,intSubBookId = NULL
			,intLocationId = v.intLocationId
			,intFutureMarketId = NULL
			,intFutureMonthId = NULL
			,dblNoOfLots = NULL
			,dblQty = t.dblQty
			,dblPrice = t.dblCost
			,intEntityId = v.intEntityId
			,ysnDelete = 0
			,intUserId = @intEntityUserSecurityId
			,strNotes = t.strDescription
			,strDistributionType = ''
			,intActionId = 
				 CASE	
					WHEN t.strTransactionForm = 'Produce' THEN 2
					WHEN t.strTransactionForm = 'Consume' THEN 3
					WHEN t.strTransactionForm = 'Inventory Transfer' THEN 4
					WHEN t.strTransactionForm = 'Inventory Receipt' THEN 
						CASE 
							WHEN contractDetail.strPricingType = 'Priced' THEN 5
							WHEN contractDetail.strPricingType = 'Basis' THEN 6
							WHEN contractDetail.strPricingType = 'DP (Priced Later)' THEN 45
							ELSE 8 -- Spot Priced
						END
					WHEN t.strTransactionForm = 'Inventory Shipment' THEN 
						CASE 
							WHEN contractDetail.strPricingType = 'Priced' THEN 10
							WHEN contractDetail.strPricingType = 'Basis' THEN 11
							--WHEN contractDetail.strPricingType = 'DP (Priced Later)' THEN 1
							ELSE 12 -- Spot Priced
						END
					WHEN t.strTransactionForm = 'Inventory Adjustment' THEN 				
						CASE 
							WHEN t.intTransactionTypeId = 10 THEN 20 --Inventory Adjustment - Quantity Change
							WHEN t.intTransactionTypeId = 14 THEN 21 --Inventory Adjustment - UOM Change
							WHEN t.intTransactionTypeId = 15 THEN 22 --Inventory Adjustment - Item Change
							WHEN t.intTransactionTypeId = 16 THEN 23 --Inventory Adjustment - Lot Status Change
							WHEN t.intTransactionTypeId = 17 THEN 24 --Inventory Adjustment - Split Lot
							WHEN t.intTransactionTypeId = 18 THEN 25 --Inventory Adjustment - Expiry Date Change
							WHEN t.intTransactionTypeId = 19 THEN 26 --Inventory Adjustment - Lot Merge
							WHEN t.intTransactionTypeId = 20 THEN 27 --Inventory Adjustment - Lot Move
							WHEN t.intTransactionTypeId = 43 THEN 28 --Inventory Adjustment - Ownership Change
							WHEN t.intTransactionTypeId = 47 THEN 29 --Inventory Adjustment - Opening Inventory
							WHEN t.intTransactionTypeId = 48 THEN 30 --Inventory Adjustment - Change Lot Weight
							ELSE NULL
						END
					WHEN t.strTransactionForm = 'Inbound Shipments' THEN 31
					WHEN t.strTransactionForm = 'Outbound Shipment' THEN 32
					WHEN t.strTransactionForm = 'Invoice' THEN 48
					ELSE 
						NULL
				 END 
		FROM	
			tblICInventoryTransaction t inner join vyuICGetInventoryValuation v 
				ON t.intInventoryTransactionId = v.intInventoryTransactionId
			INNER JOIN tblICItemUOM iu
				ON iu.intItemUOMId = t.intItemUOMId
			INNER JOIN tblICUnitMeasure u
				ON u.intUnitMeasureId = iu.intUnitMeasureId
			INNER JOIN tblICCommodityUnitMeasure commodityUOM
				ON commodityUOM.intCommodityId = v.intCommodityId 
				AND commodityUOM.intUnitMeasureId = u.intUnitMeasureId	

			OUTER APPLY (
				SELECT 
					intContractDetailId = ISNULL(ri.intContractDetailId, CASE WHEN r.strReceiptType IN ('Purchase Contract', 'Inventory Return') THEN ri.intLineNo ELSE NULL END ) 
					,intContractHeaderId = ISNULL(ri.intContractHeaderId, CASE WHEN r.strReceiptType IN ('Purchase Contract', 'Inventory Return') THEN ri.intOrderId ELSE NULL END )
				FROM 
					tblICInventoryReceipt r INNER JOIN tblICInventoryReceiptItem ri
						ON r.intInventoryReceiptId = ri.intInventoryReceiptId
				WHERE
					t.strTransactionForm = 'Inventory Receipt'
					AND r.strReceiptNumber = t.strTransactionId
					AND ri.intInventoryReceiptId = t.intTransactionId
					AND ri.intInventoryReceiptItemId = t.intTransactionDetailId
			) receipt

			OUTER APPLY (
				SELECT 
					intContractDetailId = si.intLineNo 
					,intContractHeaderId = si.intOrderId 
				FROM 
					tblICInventoryShipment s INNER JOIN tblICInventoryShipmentItem si
						ON s.intInventoryShipmentId = si.intInventoryShipmentId
				WHERE
					t.strTransactionForm = 'Inventory Shipment'
					AND s.strShipmentNumber = t.strTransactionId
					AND si.intInventoryShipmentId = t.intTransactionId
					AND si.intInventoryShipmentItemId = t.intTransactionDetailId
			) shipment

			OUTER APPLY (
				SELECT 
					intContractDetailId = invD.intContractDetailId
					,intContractHeaderId = invD.intContractHeaderId
				FROM 
					tblARInvoice inv INNER JOIN tblARInvoiceDetail invD
						ON inv.intInvoiceId = invD.intInvoiceId
				WHERE
					t.strTransactionForm = 'Invoice'
					AND inv.strInvoiceNumber = t.strTransactionId
					AND inv.intInvoiceId = t.intTransactionId
					AND invD.intInvoiceDetailId = t.intTransactionDetailId
			) invoice

			OUTER APPLY (
				SELECT 
					cd.intPricingTypeId
					,cPricingType.strPricingType
				FROM 
					tblCTContractHeader ch INNER JOIN tblCTContractDetail cd
						ON ch.intContractHeaderId = cd.intContractHeaderId
					INNER JOIN tblCTPricingType cPricingType
						ON cPricingType.intPricingTypeId = cd.intPricingTypeId
				WHERE
					ch.intContractHeaderId = COALESCE(
						receipt.intContractHeaderId
						, shipment.intContractHeaderId
						, invoice.intContractHeaderId
					)
					AND cd.intContractDetailId = COALESCE(
						receipt.intContractDetailId
						, shipment.intContractDetailId
						, invoice.intContractDetailId 
					)
			) contractDetail

		WHERE
			(t.strTransactionId = @strTransactionId OR @strTransactionId IS NULL) 
			AND t.strBatchId = @strBatchId
			AND t.dblQty <> 0 
			AND t.intInTransitSourceLocationId IS NULL 
			AND v.strTransactionType NOT IN ('Storage Settlement', 'Transfer Storage')
	END
	
	EXEC uspRKLogRiskPosition @SummaryLogs, 0, 0
END 