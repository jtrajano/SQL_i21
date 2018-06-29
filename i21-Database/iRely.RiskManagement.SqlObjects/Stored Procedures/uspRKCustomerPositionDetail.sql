CREATE PROCEDURE [dbo].[uspRKCustomerPositionDetail]  
	 @intCommodityId INT
	,@intLocationId INT = NULL
	,@strPurchaseSales nvarchar(50) = NULL
	,@intVendorCustomerId INT = NULL
AS

BEGIN
SELECT * INTO #temp FROM (		
		SELECT 1 AS intSeqId
		,*
		FROM (
		SELECT [Storage Type] strType,ISNULL(SUM(ISNULL(Balance, 0)), 0) dblTotal FROM vyuGRGetStorageDetail
		WHERE intCommodityId = @intCommodityId AND  intEntityId=@intVendorCustomerId	AND intCompanyLocationId=
		CASE WHEN ISNULL(@intLocationId,0)=0 then intCompanyLocationId else @intLocationId end AND ysnDPOwnedType = 0 AND ysnReceiptedStorage = 0
		GROUP BY [Storage Type]
		) t
	
UNION
	SELECT 2 AS intSeqId
		,'Total Non-Receipted' [Storage Type]
		,sum(Balance) dblTotal
	FROM vyuGRGetStorageDetail
	WHERE ysnReceiptedStorage = 0 AND strOwnedPhysicalStock = 'Customer' AND intEntityId=@intVendorCustomerId
	AND intCommodityId = @intCommodityId AND intCompanyLocationId = CASE WHEN ISNULL(@intLocationId,0)=0 then intCompanyLocationId else @intLocationId end
	
UNION		
		
	SELECT 3 AS intSeqId
		,'Collatral Receipts - Purchase' AS [strType]
		,isnull(SUM(dblOriginalQuantity), 0) - isnull(sum(dblAdjustmentAmount), 0) dblTotal
	FROM (
		SELECT isnull(SUM(dblAdjustmentAmount),0) dblAdjustmentAmount,c.intCollateralId,
		(select dblOriginalQuantity from tblRKCollateral cc where cc.intCollateralId=c.intCollateralId) dblOriginalQuantity
		FROM tblRKCollateral c
		LEFT JOIN tblRKCollateralAdjustment ca ON c.intCollateralId = ca.intCollateralId
		LEFT JOIN vyuCTContractHeaderView e on e.intContractHeaderId=c.intContractHeaderId
		WHERE strType = 'Purchase' 	AND c.intCommodityId = @intCommodityId AND e.intEntityId=@intVendorCustomerId AND 
		c.intLocationId = CASE WHEN ISNULL(@intLocationId,0)=0 then intLocationId else @intLocationId end
			GROUP BY c.intCollateralId ) t
	WHERE dblAdjustmentAmount <> dblOriginalQuantity
	
UNION
	
	SELECT 4 AS intSeqId
		,'Collatral Receipts - Sales' AS [strType]
		,isnull(SUM(dblOriginalQuantity), 0) - isnull(sum(dblAdjustmentAmount), 0) dblTotal
	FROM (
		SELECT isnull(SUM(dblAdjustmentAmount),0) dblAdjustmentAmount	,c.intCollateralId,
		(select dblOriginalQuantity from tblRKCollateral cc where cc.intCollateralId=c.intCollateralId) dblOriginalQuantity
		FROM tblRKCollateral c
		LEFT JOIN tblRKCollateralAdjustment ca ON c.intCollateralId = ca.intCollateralId
		LEFT JOIN vyuCTContractHeaderView e on e.intContractHeaderId=c.intContractHeaderId
		WHERE strType = 'Sale' 	AND c.intCommodityId = @intCommodityId and e.intEntityId=@intVendorCustomerId AND 
		c.intLocationId = CASE WHEN ISNULL(@intLocationId,0)=0 then intLocationId else @intLocationId end	GROUP BY c.intCollateralId ) t
	WHERE dblAdjustmentAmount <> dblOriginalQuantity 


UNION
	
	SELECT 5 AS intSeqId
		,*
	FROM (
		SELECT [Storage Type] strType,isnull(SUM(Balance), 0) dblTotal
		FROM vyuGRGetStorageDetail
		WHERE intCommodityId = @intCommodityId and intEntityId=@intVendorCustomerId	AND intCompanyLocationId = CASE WHEN ISNULL(@intLocationId,0)=0 then intCompanyLocationId else @intLocationId end AND ysnReceiptedStorage = 1
		GROUP BY [Storage Type]
		) t
	
UNION
	
	SELECT 6 AS intSeqId
		,'Total Receipted Purchase' AS [strType]
		,isnull(dblTotal1, 0) +  isnull(CollateralPurchases, 0) dblTotal
	FROM (
		SELECT SUM(Balance) dblTotal1
		FROM vyuGRGetStorageDetail
		WHERE ysnReceiptedStorage = 1
			AND intCommodityId = @intCommodityId and intEntityId=@intVendorCustomerId
			AND intCompanyLocationId = CASE WHEN ISNULL(@intLocationId,0)=0 then intCompanyLocationId else @intLocationId end
		) dblTotal1
		,(
			SELECT isnull(SUM(dblOriginalQuantity), 0) - isnull(sum(dblAdjustmentAmount), 0) CollateralSale
			FROM (
				SELECT isnull(SUM(dblAdjustmentAmount),0) dblAdjustmentAmount
					,c.intContractHeaderId
					,SUM(dblOriginalQuantity) dblOriginalQuantity
				FROM tblRKCollateral c
				LEFT JOIN tblRKCollateralAdjustment ca ON c.intCollateralId = ca.intCollateralId
				LEFT JOIN vyuCTContractHeaderView e on e.intContractHeaderId=c.intContractHeaderId
				WHERE strType = 'Sale'
					AND c.intCommodityId = @intCommodityId and e.intEntityId=@intVendorCustomerId
					AND c.intLocationId = CASE WHEN ISNULL(@intLocationId,0)=0 then intLocationId else @intLocationId end
				GROUP BY c.intContractHeaderId
				) t
			WHERE dblAdjustmentAmount <> dblOriginalQuantity
			) AS CollateralSale
		,(
			SELECT isnull(SUM(dblOriginalQuantity), 0) - isnull(sum(dblAdjustmentAmount), 0) CollateralPurchases
			FROM (
				SELECT isnull(SUM(dblAdjustmentAmount), 0) dblAdjustmentAmount
					,c.intContractHeaderId
					,isnull(SUM(dblOriginalQuantity), 0) dblOriginalQuantity
				FROM tblRKCollateral c
				LEFT JOIN tblRKCollateralAdjustment ca ON c.intCollateralId = ca.intCollateralId
				LEFT JOIN vyuCTContractHeaderView e on e.intContractHeaderId=c.intContractHeaderId
				WHERE strType = 'Purchase'
					AND c.intCommodityId = @intCommodityId and intEntityId=@intVendorCustomerId
					AND c.intLocationId = CASE WHEN ISNULL(@intLocationId,0)=0 then intLocationId else @intLocationId end
				GROUP BY c.intContractHeaderId
				) t
			WHERE dblAdjustmentAmount <> dblOriginalQuantity
			) AS CollateralPurchases
			
UNION
	
	SELECT 7 AS intSeqId
		,'Total Receipted Sales' AS [strType]
		,isnull(dblTotal1, 0) + (isnull(CollateralSale, 0)) dblTotal
	FROM (
		SELECT SUM(Balance) dblTotal1
		FROM vyuGRGetStorageDetail
		WHERE ysnReceiptedStorage = 1
			AND intCommodityId = @intCommodityId and intEntityId=@intVendorCustomerId
			AND intCompanyLocationId = CASE WHEN ISNULL(@intLocationId,0)=0 then intCompanyLocationId else @intLocationId end
		) dblTotal1
		,(
			SELECT isnull(SUM(dblOriginalQuantity), 0) - isnull(sum(dblAdjustmentAmount), 0) CollateralSale
			FROM (
				SELECT isnull(SUM(dblAdjustmentAmount),0) dblAdjustmentAmount
					,c.intContractHeaderId
					,SUM(dblOriginalQuantity) dblOriginalQuantity
				FROM tblRKCollateral c
				LEFT JOIN tblRKCollateralAdjustment ca ON c.intCollateralId = ca.intCollateralId
				LEFT JOIN vyuCTContractHeaderView e on e.intContractHeaderId=c.intContractHeaderId
				WHERE strType = 'Sale'
					AND c.intCommodityId = @intCommodityId and e.intEntityId=@intVendorCustomerId
					AND c.intLocationId = CASE WHEN ISNULL(@intLocationId,0)=0 then intLocationId else @intLocationId end
				GROUP BY c.intContractHeaderId
				) t
			WHERE dblAdjustmentAmount <> dblOriginalQuantity
			) AS CollateralSale
		,(
			SELECT isnull(SUM(dblOriginalQuantity), 0) - isnull(sum(dblAdjustmentAmount), 0) CollateralPurchases
			FROM (
				SELECT isnull(SUM(dblAdjustmentAmount), 0) dblAdjustmentAmount
					,c.intContractHeaderId
					,isnull(SUM(dblOriginalQuantity), 0) dblOriginalQuantity
				FROM tblRKCollateral c
				LEFT JOIN tblRKCollateralAdjustment ca ON c.intCollateralId = ca.intCollateralId
				LEFT JOIN vyuCTContractHeaderView e on e.intContractHeaderId=c.intContractHeaderId
				WHERE strType = 'Purchase'
					AND c.intCommodityId = @intCommodityId and intEntityId=@intVendorCustomerId
					AND c.intLocationId = CASE WHEN ISNULL(@intLocationId,0)=0 then intLocationId else @intLocationId end
				GROUP BY c.intContractHeaderId
				) t
			WHERE dblAdjustmentAmount <> dblOriginalQuantity
			) AS CollateralPurchases
	
UNION
		SELECT 8 AS intSeqId
		,'Purchase Priced' [strType]
		,isnull(Sum(CD.dblBalance), 0) AS dblTotal
	FROM tblCTContractDetail CD
	INNER JOIN tblCTContractHeader CH ON CH.intContractHeaderId = CD.intContractHeaderId
		AND CH.intContractTypeId = 1 and CD.intContractStatusId <> 3
	INNER JOIN tblCTPricingType PT ON PT.intPricingTypeId = CD.intPricingTypeId
		AND PT.intPricingTypeId IN (1)
	WHERE CH.intCommodityId = @intCommodityId and intEntityId=@intVendorCustomerId
		AND CD.intCompanyLocationId = CASE WHEN ISNULL(@intLocationId,0)=0 then intCompanyLocationId else @intLocationId end
		
UNION
	
		SELECT 9 AS intSeqId
		,'Sales Priced' [strType]
		,isnull(Sum(CD.dblBalance), 0) AS dblTotal
	FROM tblCTContractDetail CD
	INNER JOIN tblCTContractHeader CH ON CH.intContractHeaderId = CD.intContractHeaderId
		AND CH.intContractTypeId = 2 and CD.intContractStatusId <> 3
	INNER JOIN tblCTPricingType PT ON PT.intPricingTypeId = CD.intPricingTypeId
		AND PT.intPricingTypeId IN (1)
	WHERE CH.intCommodityId = @intCommodityId and intEntityId=@intVendorCustomerId
		AND CD.intCompanyLocationId = CASE WHEN ISNULL(@intLocationId,0)=0 then intCompanyLocationId else @intLocationId end
		
			
UNION
	
		SELECT 10 AS intSeqId
		,'Purchase Basis' [strType]
		,isnull(Sum(CD.dblBalance), 0) AS dblTotal
	FROM tblCTContractDetail CD
	INNER JOIN tblCTContractHeader CH ON CH.intContractHeaderId = CD.intContractHeaderId
		AND CH.intContractTypeId = 1  and CD.intContractStatusId <> 3
	INNER JOIN tblCTPricingType PT ON PT.intPricingTypeId = CD.intPricingTypeId
		AND PT.intPricingTypeId IN (2)
	WHERE CH.intCommodityId = @intCommodityId and intEntityId=@intVendorCustomerId
		AND CD.intCompanyLocationId = CASE WHEN ISNULL(@intLocationId,0)=0 then intCompanyLocationId else @intLocationId end
	
UNION
	
	SELECT 11 AS intSeqId
		,'Sales Basis' [strType]
		,isnull(Sum(CD.dblBalance), 0) AS dblTotal
	FROM tblCTContractDetail CD
	INNER JOIN tblCTContractHeader CH ON CH.intContractHeaderId = CD.intContractHeaderId
		AND CH.intContractTypeId = 2  and CD.intContractStatusId <> 3
	LEFT JOIN tblCTPricingType PT ON PT.intPricingTypeId = CD.intPricingTypeId
	WHERE ISNULL(PT.intPricingTypeId, 0) = 2
		AND CH.intCommodityId = @intCommodityId and intEntityId=@intVendorCustomerId
		AND CD.intCompanyLocationId = CASE WHEN ISNULL(@intLocationId,0)=0 then intCompanyLocationId else @intLocationId end
		
	
UNION
		SELECT 12 AS intSeqId
		,'Purchase HTA' [strType]
		,isnull(Sum(CD.dblBalance), 0) AS dblTotal
	FROM tblCTContractDetail CD
	INNER JOIN tblCTContractHeader CH ON CH.intContractHeaderId = CD.intContractHeaderId
		AND CH.intContractTypeId = 1  and CD.intContractStatusId <> 3
	INNER JOIN tblCTPricingType PT ON PT.intPricingTypeId = CD.intPricingTypeId
		AND PT.intPricingTypeId IN (3)
	WHERE CH.intCommodityId = @intCommodityId and intEntityId=@intVendorCustomerId
		AND CD.intCompanyLocationId = CASE WHEN ISNULL(@intLocationId,0)=0 then intCompanyLocationId else @intLocationId end	
		
UNION
		
		SELECT 13 AS intSeqId
		,'Sales HTA' [strType]
		,isnull(Sum(CD.dblBalance), 0) AS dblTotal
	FROM tblCTContractDetail CD
	INNER JOIN tblCTContractHeader CH ON CH.intContractHeaderId = CD.intContractHeaderId
		AND CH.intContractTypeId = 2  and CD.intContractStatusId <> 3
	INNER JOIN tblCTPricingType PT ON PT.intPricingTypeId = CD.intPricingTypeId
		AND PT.intPricingTypeId IN (3)
		AND CH.intCommodityId = @intCommodityId and intEntityId=@intVendorCustomerId
		AND CD.intCompanyLocationId = CASE WHEN ISNULL(@intLocationId,0)=0 then intCompanyLocationId else @intLocationId end
		
UNION		
	SELECT 14 AS intSeqId
		,'Purchase Basis Deliveries' AS [strType]
		,isnull(SUM(dblTotal), 0) AS dblTotal
	FROM (			
		SELECT isnull(SUM(isnull(ri.dblOpenReceive, 0)), 0) AS dblTotal
		FROM tblICInventoryReceipt r
		INNER JOIN tblICInventoryReceiptItem ri ON r.intInventoryReceiptId = ri.intInventoryReceiptId AND r.strReceiptType = 'Purchase Contract'
		INNER JOIN tblCTContractDetail cd ON cd.intContractDetailId = ri.intLineNo AND cd.intPricingTypeId = 2  and cd.intContractStatusId <> 3
		INNER JOIN tblCTContractHeader ch ON ch.intContractHeaderId = cd.intContractHeaderId
		WHERE ch.intCommodityId = @intCommodityId and ch.intEntityId=@intVendorCustomerId
		 AND cd.intCompanyLocationId = CASE WHEN ISNULL(@intLocationId,0)=0 then cd.intCompanyLocationId else @intLocationId end
		) tot
		
UNION
		
		SELECT 15 AS intSeqId
		,'Purchase In-Transit' AS [strType]
		,ISNULL(ReserveQty, 0) AS dblTotal
	FROM (SELECT sum(dblStockQty) ReserveQty FROM  vyuLGInventoryView v
			JOIN vyuCTContractDetailView cd on cd.intContractDetailId=v.intContractDetailId and cd.intContractStatusId <> 3
			WHERE  strStatus='In-transit' AND cd.intCommodityId = @intCommodityId AND intVendorEntityId=@intVendorCustomerId
			AND cd.intCompanyLocationId = CASE WHEN ISNULL(@intLocationId,0)=0 then cd.intCompanyLocationId else @intLocationId end	) t
		
) t1
END

IF @strPurchaseSales = 'Sales'
BEGIN
SELECT intSeqId,strType, dblTotal FROM #temp where strType not like '%Purchase%'
END
ELSE
BEGIN
SELECT intSeqId,strType, dblTotal		
FROM #temp where strType not like '%Sales%'
END

