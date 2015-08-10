CREATE PROCEDURE [dbo].[uspRKDPRInvDailyPositionDetail] 
	 @intCommodityId INT
	,@intLocationId INT = NULL
AS
IF ISNULL(@intLocationId, 0) <> 0
BEGIN
	SELECT 1 AS intSeqId
		,'In-House' AS [strType]
		,ISNULL(invQty, 0) - ISNULL(ReserveQty, 0) + ISNULL(dblBalance, 0) AS dblTotal
	FROM (
		SELECT (
				SELECT sum(isnull(it1.dblUnitOnHand, 0))
				FROM tblICItem i
				INNER JOIN tblICItemStock it1 ON it1.intItemId = i.intItemId
				INNER JOIN tblICItemLocation il ON il.intItemLocationId = it1.intItemLocationId
				WHERE i.intCommodityId = @intCommodityId
					AND il.intLocationId = @intLocationId
				) AS invQty
			,(
				SELECT SUM(isnull(sr1.dblQty, 0))
				FROM tblICItem i
				INNER JOIN tblICItemStock it1 ON it1.intItemId = i.intItemId
				INNER JOIN tblICStockReservation sr1 ON it1.intItemId = sr1.intItemId
				INNER JOIN tblICItemLocation il ON il.intItemLocationId = it1.intItemLocationId
				WHERE i.intCommodityId = @intCommodityId
					AND il.intLocationId = @intLocationId
				) AS ReserveQty
			,(
				SELECT SUM(Balance)
				FROM vyuGRGetStorageDetail
				WHERE ysnCustomerStorage <> 1
					AND intCommodityId = @intCommodityId
					AND intCompanyLocationId = @intLocationId
				) dblBalance
		) t
	
	UNION ALL
	
	SELECT 2 AS intSeqId
		,'Off-Site' [Storage Type]
		,isnull(sum(Balance), 0) dblTotal
	FROM vyuGRGetStorageDetail
	WHERE ysnCustomerStorage = 1
		AND strOwnedPhysicalStock = 'Company'
		AND intCommodityId = @intCommodityId
		AND intCompanyLocationId = @intLocationId
	
	UNION ALL
	
	SELECT 3 AS intSeqId
		,'Purchase In-Transit' AS [strType]
		,ISNULL(ReserveQty, 0) AS dblTotal
	FROM (
		SELECT (
				SELECT sum(isnull(it1.dblUnitOnHand, 0))
				FROM tblICItem i
				INNER JOIN tblICItemStock it1 ON it1.intItemId = i.intItemId
				INNER JOIN tblICItemLocation il ON il.intItemLocationId = it1.intItemLocationId
				WHERE i.intCommodityId = @intCommodityId
					AND il.intLocationId = @intLocationId
				) AS invQty
			,(
				SELECT SUM(isnull(sr1.dblQty, 0))
				FROM tblICItem i
				INNER JOIN tblICItemStock it1 ON it1.intItemId = i.intItemId
				INNER JOIN tblICStockReservation sr1 ON it1.intItemId = sr1.intItemId
				INNER JOIN tblICItemLocation il ON il.intItemLocationId = it1.intItemLocationId
				WHERE i.intCommodityId = @intCommodityId
					AND il.intLocationId = @intLocationId
				) AS ReserveQty
		) t
	
	UNION ALL
	
	SELECT 4 AS intSeqId
		,'Sales In-Transit' AS [strType]
		,ISNULL(ReserveQty, 0) AS dblTotal
	FROM (
		SELECT (
				SELECT sum(isnull(it1.dblUnitOnHand, 0))
				FROM tblICItem i
				INNER JOIN tblICItemStock it1 ON it1.intItemId = i.intItemId
				INNER JOIN tblICItemLocation il ON il.intItemLocationId = it1.intItemLocationId
				WHERE i.intCommodityId = @intCommodityId
					AND il.intLocationId = @intLocationId
				) AS invQty
			,(
				SELECT SUM(isnull(sr1.dblQty, 0))
				FROM tblICItem i
				INNER JOIN tblICItemStock it1 ON it1.intItemId = i.intItemId
				INNER JOIN tblICStockReservation sr1 ON it1.intItemId = sr1.intItemId
				INNER JOIN tblICItemLocation il ON il.intItemLocationId = it1.intItemLocationId
				WHERE i.intCommodityId = @intCommodityId
					AND il.intLocationId = @intLocationId
				) AS ReserveQty
		) t
	
	UNION ALL
	
	SELECT 5 AS intSeqId
		,*
	FROM (
		SELECT [Storage Type] strType
			,ISNULL(SUM(ISNULL(Balance, 0)), 0) dblTotal
		FROM vyuGRGetStorageDetail
		WHERE intCommodityId = @intCommodityId
			AND intCompanyLocationId = @intLocationId
			AND ysnDPOwnedType = 0
			AND ysnReceiptedStorage = 0
		GROUP BY [Storage Type]
		) t
	
	UNION ALL
	
	SELECT 7 AS intSeqId
		,'Total Non-Receipted' [Storage Type]
		,sum(Balance) dblTotal
	FROM vyuGRGetStorageDetail
	WHERE ysnReceiptedStorage = 0
		AND strOwnedPhysicalStock = 'Customer'
		AND intCommodityId = @intCommodityId
		AND intCompanyLocationId = @intLocationId
	
	UNION ALL
	
	SELECT 8 AS intSeqId
		,'Collatral Receipts - Sales' AS [strType]
		,isnull(SUM(dblOriginalQuantity), 0) - isnull(sum(dblAdjustmentAmount), 0) dblTotal
	FROM (
		SELECT SUM(dblAdjustmentAmount) dblAdjustmentAmount
			,intContractHeaderId
			,isnull(SUM(dblOriginalQuantity), 0) dblOriginalQuantity
		FROM tblRKCollateral c
		INNER JOIN tblRKCollateralAdjustment ca ON c.intCollateralId = ca.intCollateralId
		WHERE strType = 'Sale'
			AND c.intCommodityId = @intCommodityId
			AND c.intLocationId = @intLocationId
		GROUP BY intContractHeaderId
		) t
	WHERE dblAdjustmentAmount <> dblOriginalQuantity
	
	UNION ALL
	
	SELECT 9 AS intSeqId
		,'Collatral Receipts - Purchase' AS [strType]
		,isnull(SUM(dblOriginalQuantity), 0) - isnull(sum(dblAdjustmentAmount), 0) dblTotal
	FROM (
		SELECT SUM(dblAdjustmentAmount) dblAdjustmentAmount
			,intContractHeaderId
			,SUM(dblOriginalQuantity) dblOriginalQuantity
		FROM tblRKCollateral c
		INNER JOIN tblRKCollateralAdjustment ca ON c.intCollateralId = ca.intCollateralId
		WHERE strType = 'Purchase'
			AND c.intCommodityId = @intCommodityId
			AND c.intLocationId = @intLocationId
		GROUP BY intContractHeaderId
		) t
	WHERE dblAdjustmentAmount <> dblOriginalQuantity
	
	UNION ALL
	
	SELECT 10 AS intSeqId
		,*
	FROM (
		SELECT [Storage Type] strType
			,isnull(SUM(Balance), 0) dblTotal
		FROM vyuGRGetStorageDetail
		WHERE intCommodityId = @intCommodityId
			AND intCompanyLocationId = @intLocationId
			AND ysnReceiptedStorage = 1
		GROUP BY [Storage Type]
		) t
	
	UNION ALL
	
	SELECT 11 AS intSeqId
		,'Total Receipted' AS [strType]
		,isnull(dblTotal1, 0) + (isnull(CollateralSale, 0) - isnull(CollateralPurchases, 0)) dblTotal
	FROM (
		SELECT SUM(Balance) dblTotal1
		FROM vyuGRGetStorageDetail
		WHERE ysnReceiptedStorage = 1
			AND intCommodityId = @intCommodityId
			AND intCompanyLocationId = @intLocationId
		) dblTotal1
		,(
			SELECT isnull(SUM(dblOriginalQuantity), 0) - isnull(sum(dblAdjustmentAmount), 0) CollateralSale
			FROM (
				SELECT SUM(dblAdjustmentAmount) dblAdjustmentAmount
					,intContractHeaderId
					,SUM(dblOriginalQuantity) dblOriginalQuantity
				FROM tblRKCollateral c
				INNER JOIN tblRKCollateralAdjustment ca ON c.intCollateralId = ca.intCollateralId
				WHERE strType = 'Sale'
					AND c.intCommodityId = @intCommodityId
					AND c.intLocationId = @intLocationId
				GROUP BY intContractHeaderId
				) t
			WHERE dblAdjustmentAmount <> dblOriginalQuantity
			) AS CollateralSale
		,(
			SELECT isnull(SUM(dblOriginalQuantity), 0) - isnull(sum(dblAdjustmentAmount), 0) CollateralPurchases
			FROM (
				SELECT isnull(SUM(dblAdjustmentAmount), 0) dblAdjustmentAmount
					,intContractHeaderId
					,isnull(SUM(dblOriginalQuantity), 0) dblOriginalQuantity
				FROM tblRKCollateral c
				INNER JOIN tblRKCollateralAdjustment ca ON c.intCollateralId = ca.intCollateralId
				WHERE strType = 'Purchase'
					AND c.intCommodityId = @intCommodityId
					AND c.intLocationId = @intLocationId
				GROUP BY intContractHeaderId
				) t
			WHERE dblAdjustmentAmount <> dblOriginalQuantity
			) AS CollateralPurchases
	
	UNION ALL
	
	SELECT 12 AS intSeqId
		,*
	FROM (
		SELECT [Storage Type] strType
			,isnull(SUM(Balance), 0) dblTotal
		FROM vyuGRGetStorageDetail
		WHERE intCommodityId = @intCommodityId
			AND intCompanyLocationId = @intLocationId
			AND ysnDPOwnedType = 1
		GROUP BY [Storage Type]
		) t
	
	UNION ALL
	
	SELECT 13 AS intSeqId
		,'Pur Basis Deliveries' AS [strType]
		,isnull(SUM(dblTotal), 0) AS dblTotal
	FROM (
		SELECT PLDetail.dblLotPickedQty AS dblTotal
		FROM tblLGDeliveryPickDetail Del
		INNER JOIN tblLGPickLotDetail PLDetail ON PLDetail.intPickLotDetailId = Del.intPickLotDetailId
		INNER JOIN vyuLGPickOpenInventoryLots Lots ON Lots.intLotId = PLDetail.intLotId
		INNER JOIN vyuCTContractDetailView CT ON CT.intContractDetailId = Lots.intContractDetailId
		WHERE CT.intPricingTypeId = 2
			AND CT.intCommodityId = @intCommodityId
			AND CT.intCompanyLocationId = @intLocationId
		
		UNION ALL
		
		SELECT isnull(SUM(isnull(ri.dblOpenReceive, 0)), 0) AS dblTotal
		FROM tblICInventoryReceipt r
		INNER JOIN tblICInventoryReceiptItem ri ON r.intInventoryReceiptId = ri.intInventoryReceiptId
			AND r.strReceiptType = 'Purchase Contract'
		INNER JOIN tblCTContractDetail cd ON cd.intContractDetailId = ri.intLineNo
			AND cd.intPricingTypeId = 2
		INNER JOIN tblCTContractHeader ch ON ch.intContractHeaderId = cd.intContractHeaderId
		WHERE ch.intCommodityId = @intCommodityId
			AND cd.intCompanyLocationId = @intLocationId
		) tot
	
	UNION ALL
	
	SELECT 14 AS intSeqId
		,'Sls Basis Deliveries' AS [strType]
		,isnull(SUM(isnull(ri.dblQuantity, 0)), 0) AS dblTotal
	FROM tblICInventoryShipment r
	INNER JOIN tblICInventoryShipmentItem ri ON r.intInventoryShipmentId = ri.intInventoryShipmentId
	INNER JOIN tblCTContractDetail cd ON cd.intContractDetailId = ri.intLineNo
		AND cd.intPricingTypeId = 2
		AND ri.intOrderId = 1
	INNER JOIN tblCTContractHeader ch ON ch.intContractHeaderId = cd.intContractHeaderId
	WHERE ch.intCommodityId = @intCommodityId
		AND cd.intCompanyLocationId = @intLocationId
	
	UNION ALL
	
	SELECT 15 AS intSeqId
		,'Company Titled Stock' AS [strType]
		,ISNULL(invQty, 0) - ISNULL(ReserveQty, 0) + isnull(dblBalance, 0) + (isnull(CollateralSale, 0) - isnull(CollateralPurchases, 0)) AS dblTotal
	FROM (
		SELECT isnull((
					SELECT isnull(sum(isnull(it1.dblUnitOnHand, 0)), 0)
					FROM tblICItem i
					INNER JOIN tblICItemStock it1 ON it1.intItemId = i.intItemId
					INNER JOIN tblICItemLocation il ON il.intItemLocationId = it1.intItemLocationId
					WHERE i.intCommodityId = @intCommodityId
						AND il.intLocationId = @intLocationId
					), 0) AS invQty
			,isnull((
					SELECT isnull(SUM(isnull(sr1.dblQty, 0)), 0)
					FROM tblICItem i
					INNER JOIN tblICItemStock it1 ON it1.intItemId = i.intItemId
					INNER JOIN tblICStockReservation sr1 ON it1.intItemId = sr1.intItemId
					INNER JOIN tblICItemLocation il ON il.intItemLocationId = it1.intItemLocationId
					WHERE i.intCommodityId = @intCommodityId
						AND il.intLocationId = @intLocationId
					), 0) AS ReserveQty
			,isnull((
					SELECT isnull(SUM(Balance), 0)
					FROM vyuGRGetStorageDetail
					WHERE (
							strOwnedPhysicalStock = 'Company'
							OR ysnDPOwnedType = 1
							)
						AND intCommodityId = @intCommodityId
						AND intCompanyLocationId = @intLocationId
					), 0) dblBalance
			,isnull((
					SELECT isnull(SUM(dblOriginalQuantity), 0) - isnull(sum(dblAdjustmentAmount), 0) CollateralSale
					FROM (
						SELECT isnull(SUM(dblAdjustmentAmount), 0) dblAdjustmentAmount
							,intContractHeaderId
							,isnull(SUM(dblOriginalQuantity), 0) dblOriginalQuantity
						FROM tblRKCollateral c
						INNER JOIN tblRKCollateralAdjustment ca ON c.intCollateralId = ca.intCollateralId
						WHERE strType = 'Sale'
							AND c.intCommodityId = @intCommodityId
							AND c.intLocationId = @intLocationId
						GROUP BY intContractHeaderId
						) t
					WHERE dblAdjustmentAmount <> dblOriginalQuantity
					), 0) AS CollateralSale
			,isnull((
					SELECT isnull(SUM(dblOriginalQuantity), 0) - isnull(sum(dblAdjustmentAmount), 0) CollateralPurchases
					FROM (
						SELECT isnull(SUM(dblAdjustmentAmount), 0) dblAdjustmentAmount
							,intContractHeaderId
							,isnull(SUM(dblOriginalQuantity), 0) dblOriginalQuantity
						FROM tblRKCollateral c
						INNER JOIN tblRKCollateralAdjustment ca ON c.intCollateralId = ca.intCollateralId
						WHERE strType = 'Purchase'
							AND c.intCommodityId = @intCommodityId
							AND c.intLocationId = @intLocationId
						GROUP BY intContractHeaderId
						) t
					WHERE dblAdjustmentAmount <> dblOriginalQuantity
					), 0) AS CollateralPurchases
		) t
END
ELSE
BEGIN
	SELECT 1 AS intSeqId
		,'In-House' AS [strType]
		,ISNULL(invQty, 0) - ISNULL(ReserveQty, 0) + dblBalance AS dblTotal
	FROM (
		SELECT (
				SELECT isnull(sum(isnull(it1.dblUnitOnHand, 0)), 0)
				FROM tblICItem i
				INNER JOIN tblICItemStock it1 ON it1.intItemId = i.intItemId
				WHERE i.intCommodityId = @intCommodityId
				) AS invQty
			,(
				SELECT isnull(SUM(isnull(sr1.dblQty, 0)), 0)
				FROM tblICItem i
				INNER JOIN tblICItemStock it1 ON it1.intItemId = i.intItemId
				INNER JOIN tblICStockReservation sr1 ON it1.intItemId = sr1.intItemId
				WHERE i.intCommodityId = @intCommodityId
				) AS ReserveQty
			,(
				SELECT isnull(SUM(Balance), 0)
				FROM vyuGRGetStorageDetail
				WHERE ysnCustomerStorage <> 1
					AND intCommodityId = @intCommodityId
				) AS dblBalance
		) t
	
	UNION ALL
	

	SELECT 2 AS intSeqId
		,'Off-Site' [Storage Type]
		,isnull(sum(Balance), 0) dblTotal
	FROM vyuGRGetStorageDetail
	WHERE ysnCustomerStorage = 1
		AND strOwnedPhysicalStock = 'Company'
		AND intCommodityId = @intCommodityId
	
	UNION ALL
	
	SELECT 3 AS intSeqId
		,'Purchase In-Transit' AS [strType]
		,ISNULL(ReserveQty, 0) AS dblTotal
	FROM (
		SELECT (
				SELECT isnull(SUM(isnull(sr1.dblQty, 0)), 0)
				FROM tblICItem i
				INNER JOIN tblICItemStock it1 ON it1.intItemId = i.intItemId
				INNER JOIN tblICStockReservation sr1 ON it1.intItemId = sr1.intItemId
				WHERE i.intCommodityId = @intCommodityId
				) AS ReserveQty
		) t
	
	UNION ALL
	
	SELECT 4 AS intSeqId
		,'Sales In-Transit' AS [strType]
		,ISNULL(ReserveQty, 0) AS dblTotal
	FROM (
		SELECT (
				SELECT isnull(SUM(isnull(sr1.dblQty, 0)), 0)
				FROM tblICItem i
				INNER JOIN tblICItemStock it1 ON it1.intItemId = i.intItemId
				INNER JOIN tblICStockReservation sr1 ON it1.intItemId = sr1.intItemId
				WHERE i.intCommodityId = @intCommodityId
				) AS ReserveQty
		) t
	
	UNION ALL
	
	SELECT 5 AS intSeqId
		,*
	FROM (
		SELECT [Storage Type] strType
			,isnull(SUM(Balance), 0) dblTotal
		FROM vyuGRGetStorageDetail
		WHERE intCommodityId = @intCommodityId
			AND ysnDPOwnedType = 0
			AND ysnReceiptedStorage = 0
		GROUP BY [Storage Type]
		) t
	
	UNION ALL
	SELECT 7 AS intSeqId
		,'Total Non-Receipted' [Storage Type]
		,isnull(sum(Balance), 0) dblTotal
	FROM vyuGRGetStorageDetail
	WHERE ysnReceiptedStorage = 0
		AND strOwnedPhysicalStock = 'Customer'
		AND intCommodityId = @intCommodityId
	
	UNION ALL
	
	SELECT 8 AS intSeqId
		,'Collatral Receipts - Sales' AS [strType]
		,isnull(SUM(dblOriginalQuantity), 0) - isnull(sum(dblAdjustmentAmount), 0) dblTotal
	FROM (
		SELECT isnull(SUM(dblAdjustmentAmount), 0) dblAdjustmentAmount
			,intContractHeaderId
			,isnull(SUM(dblOriginalQuantity), 0) dblOriginalQuantity
		FROM tblRKCollateral c
		INNER JOIN tblRKCollateralAdjustment ca ON c.intCollateralId = ca.intCollateralId
		WHERE strType = 'Sale'
			AND c.intCommodityId = @intCommodityId
		GROUP BY intContractHeaderId
		) t
	WHERE dblAdjustmentAmount <> dblOriginalQuantity
	
	UNION ALL
	
	SELECT 9 AS intSeqId
		,'Collatral Receipts - Purchase' AS [strType]
		,isnull(SUM(dblOriginalQuantity), 0) - isnull(sum(dblAdjustmentAmount), 0) dblTotal
	FROM (
		SELECT SUM(dblAdjustmentAmount) dblAdjustmentAmount
			,intContractHeaderId
			,SUM(dblOriginalQuantity) dblOriginalQuantity
		FROM tblRKCollateral c
		INNER JOIN tblRKCollateralAdjustment ca ON c.intCollateralId = ca.intCollateralId
		WHERE strType = 'Purchase'
			AND c.intCommodityId = @intCommodityId
		GROUP BY intContractHeaderId
		) t
	WHERE dblAdjustmentAmount <> dblOriginalQuantity
	
	UNION ALL
	
	SELECT 10 AS intSeqId
		,*
	FROM (
		SELECT [Storage Type] strType
			,isnull(SUM(Balance), 0) dblTotal
		FROM vyuGRGetStorageDetail
		WHERE intCommodityId = @intCommodityId
			AND ysnReceiptedStorage = 1
		GROUP BY [Storage Type]
		) t
	
	UNION ALL
	
	SELECT 11 AS intSeqId
		,'Total Receipted' AS [strType]
		,isnull(dblTotal1, 0) + (isnull(CollateralSale, 0) - isnull(CollateralPurchases, 0)) dblTotal
	FROM (
		SELECT SUM(Balance) dblTotal1
		FROM vyuGRGetStorageDetail
		WHERE ysnReceiptedStorage = 1
			AND intCommodityId = @intCommodityId
		) dblTotal1
		,(
			SELECT isnull(SUM(dblOriginalQuantity), 0) - isnull(sum(dblAdjustmentAmount), 0) CollateralSale
			FROM (
				SELECT isnull(SUM(dblAdjustmentAmount), 0) dblAdjustmentAmount
					,intContractHeaderId
					,isnull(SUM(dblOriginalQuantity), 0) dblOriginalQuantity
				FROM tblRKCollateral c
				INNER JOIN tblRKCollateralAdjustment ca ON c.intCollateralId = ca.intCollateralId
				WHERE strType = 'Sale'
					AND c.intCommodityId = @intCommodityId
				GROUP BY intContractHeaderId
				) t
			WHERE dblAdjustmentAmount <> dblOriginalQuantity
			) AS CollateralSale
		,(
			SELECT isnull(SUM(dblOriginalQuantity), 0) - isnull(sum(dblAdjustmentAmount), 0) CollateralPurchases
			FROM (
				SELECT isnull(SUM(dblAdjustmentAmount), 0) dblAdjustmentAmount
					,intContractHeaderId
					,isnull(SUM(dblOriginalQuantity), 0) dblOriginalQuantity
				FROM tblRKCollateral c
				INNER JOIN tblRKCollateralAdjustment ca ON c.intCollateralId = ca.intCollateralId
				WHERE strType = 'Purchase'
					AND c.intCommodityId = @intCommodityId
				GROUP BY intContractHeaderId
				) t
			WHERE dblAdjustmentAmount <> dblOriginalQuantity
			) AS CollateralPurchases
	
	UNION ALL
	
	SELECT 12 AS intSeqId
		,*
	FROM (
		SELECT [Storage Type] strType
			,isnull(SUM(Balance), 0) dblTotal
		FROM vyuGRGetStorageDetail
		WHERE intCommodityId = @intCommodityId
			AND ysnDPOwnedType = 1
		GROUP BY [Storage Type]
		) t
	
	UNION ALL
	
	SELECT 13 AS intSeqId
		,'Pur Basis Deliveries' AS [strType]
		,isnull(SUM(dblTotal), 0) AS dblTotal
	FROM (
		SELECT PLDetail.dblLotPickedQty AS dblTotal
		FROM tblLGDeliveryPickDetail Del
		INNER JOIN tblLGPickLotDetail PLDetail ON PLDetail.intPickLotDetailId = Del.intPickLotDetailId
		INNER JOIN vyuLGPickOpenInventoryLots Lots ON Lots.intLotId = PLDetail.intLotId
		INNER JOIN vyuCTContractDetailView CT ON CT.intContractDetailId = Lots.intContractDetailId
		WHERE CT.intPricingTypeId = 2
			AND CT.intCommodityId = @intCommodityId
		
		UNION ALL
		
		SELECT isnull(SUM(isnull(ri.dblOpenReceive, 0)), 0) AS dblTotal
		FROM tblICInventoryReceipt r
		INNER JOIN tblICInventoryReceiptItem ri ON r.intInventoryReceiptId = ri.intInventoryReceiptId
			AND r.strReceiptType = 'Purchase Contract'
		INNER JOIN tblCTContractDetail cd ON cd.intContractDetailId = ri.intLineNo
			AND cd.intPricingTypeId = 2
		INNER JOIN tblCTContractHeader ch ON ch.intContractHeaderId = cd.intContractHeaderId
		WHERE ch.intCommodityId = @intCommodityId
		) tot
	
	UNION ALL
	
	SELECT 14 AS intSeqId
		,'Sls Basis Deliveries' AS [strType]
		,isnull(SUM(isnull(ri.dblQuantity, 0)), 0) AS dblTotal
	FROM tblICInventoryShipment r
	INNER JOIN tblICInventoryShipmentItem ri ON r.intInventoryShipmentId = ri.intInventoryShipmentId
	INNER JOIN tblCTContractDetail cd ON cd.intContractDetailId = ri.intLineNo
		AND cd.intPricingTypeId = 2
		AND ri.intOrderId = 1
	INNER JOIN tblCTContractHeader ch ON ch.intContractHeaderId = cd.intContractHeaderId
	WHERE ch.intCommodityId = @intCommodityId
	
	UNION ALL
	
	SELECT 14 AS intSeqId
		,'Company Titled Stock' AS [strType]
		,ISNULL(invQty, 0) - ISNULL(ReserveQty, 0) + isnull(dblBalance, 0) + (isnull(CollateralPurchases, 0) - isnull(CollateralSale, 0)) AS dblTotal
	FROM (
		SELECT isnull((
					SELECT isnull(sum(isnull(it1.dblUnitOnHand, 0)), 0)
					FROM tblICItem i
					INNER JOIN tblICItemStock it1 ON it1.intItemId = i.intItemId
					INNER JOIN tblICItemLocation il ON il.intItemLocationId = it1.intItemLocationId
					WHERE i.intCommodityId = @intCommodityId
					), 0) AS invQty
			,isnull((
					SELECT isnull(SUM(isnull(sr1.dblQty, 0)), 0)
					FROM tblICItem i
					INNER JOIN tblICItemStock it1 ON it1.intItemId = i.intItemId
					INNER JOIN tblICStockReservation sr1 ON it1.intItemId = sr1.intItemId
					INNER JOIN tblICItemLocation il ON il.intItemLocationId = it1.intItemLocationId
					WHERE i.intCommodityId = @intCommodityId
					), 0) AS ReserveQty
			,isnull((
					SELECT isnull(SUM(Balance), 0)
					FROM vyuGRGetStorageDetail
					WHERE (
							strOwnedPhysicalStock = 'Company'
							OR ysnDPOwnedType = 1
							)
						AND intCommodityId = @intCommodityId
					), 0) dblBalance
			,isnull((
					SELECT isnull(SUM(dblOriginalQuantity), 0) - isnull(sum(dblAdjustmentAmount), 0) CollateralSale
					FROM (
						SELECT isnull(SUM(dblAdjustmentAmount), 0) dblAdjustmentAmount
							,intContractHeaderId
							,isnull(SUM(dblOriginalQuantity), 0) dblOriginalQuantity
						FROM tblRKCollateral c
						INNER JOIN tblRKCollateralAdjustment ca ON c.intCollateralId = ca.intCollateralId
						WHERE strType = 'Sale'
							AND c.intCommodityId = @intCommodityId
						GROUP BY intContractHeaderId
						) t
					WHERE dblAdjustmentAmount <> dblOriginalQuantity
					), 0) AS CollateralSale
			,isnull((
					SELECT isnull(SUM(dblOriginalQuantity), 0) - isnull(sum(dblAdjustmentAmount), 0) CollateralPurchases
					FROM (
						SELECT isnull(SUM(dblAdjustmentAmount), 0) dblAdjustmentAmount
							,intContractHeaderId
							,isnull(SUM(dblOriginalQuantity), 0) dblOriginalQuantity
						FROM tblRKCollateral c
						INNER JOIN tblRKCollateralAdjustment ca ON c.intCollateralId = ca.intCollateralId
						WHERE strType = 'Purchase'
							AND c.intCommodityId = @intCommodityId
						GROUP BY intContractHeaderId
						) t
					WHERE dblAdjustmentAmount <> dblOriginalQuantity
					), 0) AS CollateralPurchases
		) t
END