﻿CREATE PROCEDURE [dbo].[uspRKCustomerPositionDetail]
	@intCommodityId INT
	, @intLocationId INT = NULL
	, @strPurchaseSales nvarchar(50) = NULL
	, @intVendorCustomerId INT = NULL

AS

BEGIN

	IF (ISNULL(@intLocationId, 0) = 0)
	BEGIN
		SET @intLocationId = NULL
	END

	SELECT * INTO #temp
	FROM (
		SELECT 1 AS intSeqId
			, *
		FROM (
			SELECT [Storage Type] strType
				, ISNULL(SUM(ISNULL(Balance, 0)), 0) dblTotal
			FROM vyuGRGetStorageDetail
			WHERE intCommodityId = @intCommodityId AND intEntityId=@intVendorCustomerId
				AND intCompanyLocationId = ISNULL(@intLocationId, intCompanyLocationId) AND ysnDPOwnedType = 0 AND ysnReceiptedStorage = 0
			GROUP BY [Storage Type]
		) t
		
		UNION ALL SELECT 2 AS intSeqId
			, 'Total Non-Receipted' COLLATE Latin1_General_CI_AS [Storage Type]
			, sum(Balance) dblTotal
		FROM vyuGRGetStorageDetail
		WHERE ysnReceiptedStorage = 0 AND strOwnedPhysicalStock = 'Customer' AND intEntityId=@intVendorCustomerId
			AND intCommodityId = @intCommodityId AND intCompanyLocationId = ISNULL(@intLocationId, intCompanyLocationId)
		
		UNION ALL SELECT 3 AS intSeqId
			, 'Collatral Receipts - Purchase' COLLATE Latin1_General_CI_AS AS [strType]
			, isnull(SUM(dblOriginalQuantity), 0) - isnull(sum(dblAdjustmentAmount), 0) dblTotal
		FROM (
			SELECT isnull(SUM(dblAdjustmentAmount),0) dblAdjustmentAmount
				, c.intCollateralId
				, (select dblOriginalQuantity from tblRKCollateral cc where cc.intCollateralId=c.intCollateralId) dblOriginalQuantity
			FROM tblRKCollateral c
			LEFT JOIN tblRKCollateralAdjustment ca ON c.intCollateralId = ca.intCollateralId
			LEFT JOIN vyuCTContractHeaderView e on e.intContractHeaderId=c.intContractHeaderId
			WHERE strType = 'Purchase' AND c.intCommodityId = @intCommodityId AND e.intEntityId=@intVendorCustomerId AND c.intLocationId = ISNULL(@intLocationId, c.intLocationId)
			GROUP BY c.intCollateralId
		) t
		WHERE dblAdjustmentAmount <> dblOriginalQuantity
		
		UNION ALL SELECT 4 AS intSeqId
			, 'Collatral Receipts - Sales' COLLATE Latin1_General_CI_AS AS [strType]
			, isnull(SUM(dblOriginalQuantity), 0) - isnull(sum(dblAdjustmentAmount), 0) dblTotal
		FROM (
			SELECT isnull(SUM(dblAdjustmentAmount),0) dblAdjustmentAmount
				, c.intCollateralId
				, (select dblOriginalQuantity from tblRKCollateral cc where cc.intCollateralId=c.intCollateralId) dblOriginalQuantity
			FROM tblRKCollateral c
			LEFT JOIN tblRKCollateralAdjustment ca ON c.intCollateralId = ca.intCollateralId
			LEFT JOIN vyuCTContractHeaderView e on e.intContractHeaderId=c.intContractHeaderId
			WHERE strType = 'Sale' AND c.intCommodityId = @intCommodityId and e.intEntityId=@intVendorCustomerId
				AND c.intLocationId = ISNULL(@intLocationId, c.intLocationId)
			GROUP BY c.intCollateralId
		) t
		WHERE dblAdjustmentAmount <> dblOriginalQuantity
		
		UNION ALL SELECT 5 AS intSeqId
			, *
		FROM (
			SELECT [Storage Type] strType
				, isnull(SUM(Balance), 0) dblTotal
			FROM vyuGRGetStorageDetail
			WHERE intCommodityId = @intCommodityId and intEntityId=@intVendorCustomerId
				AND intCompanyLocationId = ISNULL(@intLocationId, intCompanyLocationId) AND ysnReceiptedStorage = 1
			GROUP BY [Storage Type]
		) t
		
		UNION ALL SELECT 6 AS intSeqId
			, 'Total Receipted Purchase' COLLATE Latin1_General_CI_AS AS [strType]
			, isnull(dblTotal1, 0) +  isnull(CollateralPurchases, 0) dblTotal
		FROM (
			SELECT SUM(Balance) dblTotal1
			FROM vyuGRGetStorageDetail
			WHERE ysnReceiptedStorage = 1
				AND intCommodityId = @intCommodityId and intEntityId=@intVendorCustomerId
				AND intCompanyLocationId = ISNULL(@intLocationId, intCompanyLocationId)
		) dblTotal1
		INNER JOIN (SELECT isnull(SUM(dblOriginalQuantity), 0) - isnull(sum(dblAdjustmentAmount), 0) CollateralSale
			FROM (
				SELECT isnull(SUM(dblAdjustmentAmount),0) dblAdjustmentAmount
					, c.intContractHeaderId
					, SUM(dblOriginalQuantity) dblOriginalQuantity
				FROM tblRKCollateral c
				LEFT JOIN tblRKCollateralAdjustment ca ON c.intCollateralId = ca.intCollateralId
				LEFT JOIN vyuCTContractHeaderView e on e.intContractHeaderId=c.intContractHeaderId
				WHERE strType = 'Sale'
					AND c.intCommodityId = @intCommodityId and e.intEntityId=@intVendorCustomerId
					AND c.intLocationId = ISNULL(@intLocationId, c.intLocationId)
				GROUP BY c.intContractHeaderId
			) t
			WHERE dblAdjustmentAmount <> dblOriginalQuantity
		) AS CollateralSale ON 1=1
		INNER JOIN (SELECT isnull(SUM(dblOriginalQuantity), 0) - isnull(sum(dblAdjustmentAmount), 0) CollateralPurchases
			FROM (
				SELECT isnull(SUM(dblAdjustmentAmount), 0) dblAdjustmentAmount
					, c.intContractHeaderId
					, isnull(SUM(dblOriginalQuantity), 0) dblOriginalQuantity
				FROM tblRKCollateral c
				LEFT JOIN tblRKCollateralAdjustment ca ON c.intCollateralId = ca.intCollateralId
				LEFT JOIN vyuCTContractHeaderView e on e.intContractHeaderId=c.intContractHeaderId
				WHERE strType = 'Purchase'
					AND c.intCommodityId = @intCommodityId and intEntityId=@intVendorCustomerId
					AND c.intLocationId = ISNULL(@intLocationId, c.intLocationId)
				GROUP BY c.intContractHeaderId
			) t
			WHERE dblAdjustmentAmount <> dblOriginalQuantity
		) AS CollateralPurchases ON 1=1
		
		UNION ALL SELECT 7 AS intSeqId
			, 'Total Receipted Sales' COLLATE Latin1_General_CI_AS AS [strType]
			, isnull(dblTotal1, 0) + (isnull(CollateralSale, 0)) dblTotal
		FROM (
			SELECT SUM(Balance) dblTotal1
			FROM vyuGRGetStorageDetail
			WHERE ysnReceiptedStorage = 1
				AND intCommodityId = @intCommodityId and intEntityId=@intVendorCustomerId
				AND intCompanyLocationId = ISNULL(@intLocationId, intCompanyLocationId)
		) dblTotal1
		INNER JOIN (SELECT isnull(SUM(dblOriginalQuantity), 0) - isnull(sum(dblAdjustmentAmount), 0) CollateralSale
			FROM (
				SELECT isnull(SUM(dblAdjustmentAmount),0) dblAdjustmentAmount
					, c.intContractHeaderId
					, SUM(dblOriginalQuantity) dblOriginalQuantity
				FROM tblRKCollateral c
				LEFT JOIN tblRKCollateralAdjustment ca ON c.intCollateralId = ca.intCollateralId
				LEFT JOIN vyuCTContractHeaderView e on e.intContractHeaderId=c.intContractHeaderId
				WHERE strType = 'Sale'
					AND c.intCommodityId = @intCommodityId and e.intEntityId=@intVendorCustomerId
					AND c.intLocationId = ISNULL(@intLocationId, c.intLocationId)
				GROUP BY c.intContractHeaderId
			) t
			WHERE dblAdjustmentAmount <> dblOriginalQuantity
		) AS CollateralSale ON 1=1
		INNER JOIN (SELECT isnull(SUM(dblOriginalQuantity), 0) - isnull(sum(dblAdjustmentAmount), 0) CollateralPurchases
			FROM (
				SELECT isnull(SUM(dblAdjustmentAmount), 0) dblAdjustmentAmount
					, c.intContractHeaderId
					, isnull(SUM(dblOriginalQuantity), 0) dblOriginalQuantity
				FROM tblRKCollateral c
				LEFT JOIN tblRKCollateralAdjustment ca ON c.intCollateralId = ca.intCollateralId
				LEFT JOIN vyuCTContractHeaderView e on e.intContractHeaderId=c.intContractHeaderId
				WHERE strType = 'Purchase'
					AND c.intCommodityId = @intCommodityId and intEntityId=@intVendorCustomerId
					AND c.intLocationId = ISNULL(@intLocationId, c.intLocationId)
				GROUP BY c.intContractHeaderId
			) t
			WHERE dblAdjustmentAmount <> dblOriginalQuantity
		) AS CollateralPurchases ON 1=1
		
		UNION ALL SELECT 8 AS intSeqId
			, 'Purchase Priced' COLLATE Latin1_General_CI_AS [strType]
			, isnull(Sum(CD.dblBalance), 0) AS dblTotal
		FROM tblCTContractDetail CD
		INNER JOIN tblCTContractHeader CH ON CH.intContractHeaderId = CD.intContractHeaderId AND CH.intContractTypeId = 1 and CD.intContractStatusId <> 3
		INNER JOIN tblCTPricingType PT ON PT.intPricingTypeId = CD.intPricingTypeId AND PT.intPricingTypeId IN (1)
		WHERE CH.intCommodityId = @intCommodityId and intEntityId=@intVendorCustomerId
			AND CD.intCompanyLocationId = ISNULL(@intLocationId, CD.intCompanyLocationId)
			
		UNION ALL SELECT 9 AS intSeqId
			, 'Sales Priced' COLLATE Latin1_General_CI_AS [strType]
			, isnull(Sum(CD.dblBalance), 0) AS dblTotal
		FROM tblCTContractDetail CD
		INNER JOIN tblCTContractHeader CH ON CH.intContractHeaderId = CD.intContractHeaderId AND CH.intContractTypeId = 2 and CD.intContractStatusId <> 3
		INNER JOIN tblCTPricingType PT ON PT.intPricingTypeId = CD.intPricingTypeId AND PT.intPricingTypeId IN (1)
		WHERE CH.intCommodityId = @intCommodityId and intEntityId=@intVendorCustomerId AND CD.intCompanyLocationId = ISNULL(@intLocationId, CD.intCompanyLocationId)
		
		UNION ALL SELECT 10 AS intSeqId
			, 'Purchase Basis' COLLATE Latin1_General_CI_AS [strType]
			, isnull(Sum(CD.dblBalance), 0) AS dblTotal
		FROM tblCTContractDetail CD
		INNER JOIN tblCTContractHeader CH ON CH.intContractHeaderId = CD.intContractHeaderId AND CH.intContractTypeId = 1  and CD.intContractStatusId <> 3
		INNER JOIN tblCTPricingType PT ON PT.intPricingTypeId = CD.intPricingTypeId AND PT.intPricingTypeId IN (2)
		WHERE CH.intCommodityId = @intCommodityId and intEntityId=@intVendorCustomerId
			AND CD.intCompanyLocationId = ISNULL(@intLocationId, CD.intCompanyLocationId)
		
		UNION ALL SELECT 11 AS intSeqId
			, 'Sales Basis' COLLATE Latin1_General_CI_AS [strType]
			, isnull(Sum(CD.dblBalance), 0) AS dblTotal
		FROM tblCTContractDetail CD
		INNER JOIN tblCTContractHeader CH ON CH.intContractHeaderId = CD.intContractHeaderId AND CH.intContractTypeId = 2  and CD.intContractStatusId <> 3
		LEFT JOIN tblCTPricingType PT ON PT.intPricingTypeId = CD.intPricingTypeId
		WHERE ISNULL(PT.intPricingTypeId, 0) = 2
			AND CH.intCommodityId = @intCommodityId and intEntityId=@intVendorCustomerId
			AND CD.intCompanyLocationId = ISNULL(@intLocationId, CD.intCompanyLocationId)
		
		UNION ALL SELECT 12 AS intSeqId
			, 'Purchase HTA' COLLATE Latin1_General_CI_AS [strType]
			, isnull(Sum(CD.dblBalance), 0) AS dblTotal
		FROM tblCTContractDetail CD
		INNER JOIN tblCTContractHeader CH ON CH.intContractHeaderId = CD.intContractHeaderId AND CH.intContractTypeId = 1  and CD.intContractStatusId <> 3
		INNER JOIN tblCTPricingType PT ON PT.intPricingTypeId = CD.intPricingTypeId AND PT.intPricingTypeId IN (3)
		WHERE CH.intCommodityId = @intCommodityId and intEntityId=@intVendorCustomerId
			AND CD.intCompanyLocationId = ISNULL(@intLocationId, CD.intCompanyLocationId)
		
		UNION ALL SELECT 13 AS intSeqId
			, 'Sales HTA' COLLATE Latin1_General_CI_AS [strType]
			, isnull(Sum(CD.dblBalance), 0) AS dblTotal
		FROM tblCTContractDetail CD
		INNER JOIN tblCTContractHeader CH ON CH.intContractHeaderId = CD.intContractHeaderId AND CH.intContractTypeId = 2  and CD.intContractStatusId <> 3
		INNER JOIN tblCTPricingType PT ON PT.intPricingTypeId = CD.intPricingTypeId AND PT.intPricingTypeId IN (3)
			AND CH.intCommodityId = @intCommodityId and intEntityId=@intVendorCustomerId
			AND CD.intCompanyLocationId = ISNULL(@intLocationId, CD.intCompanyLocationId)
		
		UNION ALL SELECT 14 AS intSeqId
			, 'Purchase Basis Deliveries' COLLATE Latin1_General_CI_AS AS [strType]
			, isnull(SUM(dblTotal), 0) AS dblTotal
		FROM (
			SELECT isnull(SUM(isnull(ri.dblOpenReceive, 0)), 0) AS dblTotal
			FROM tblICInventoryReceipt r
			INNER JOIN tblICInventoryReceiptItem ri ON r.intInventoryReceiptId = ri.intInventoryReceiptId AND r.strReceiptType = 'Purchase Contract'
			INNER JOIN tblCTContractDetail cd ON cd.intContractDetailId = ri.intLineNo AND cd.intPricingTypeId = 2  and cd.intContractStatusId <> 3
			INNER JOIN tblCTContractHeader ch ON ch.intContractHeaderId = cd.intContractHeaderId
			WHERE ch.intCommodityId = @intCommodityId and ch.intEntityId=@intVendorCustomerId
				AND cd.intCompanyLocationId = ISNULL(@intLocationId, cd.intCompanyLocationId)
		) tot
		
		UNION ALL SELECT 15 AS intSeqId
			, 'Purchase In-Transit' COLLATE Latin1_General_CI_AS AS [strType]
			, ISNULL(ReserveQty, 0) AS dblTotal
		FROM (SELECT sum(dblStockQty) ReserveQty FROM vyuLGInventoryView v
			JOIN vyuCTContractDetailView cd on cd.intContractDetailId=v.intContractDetailId and cd.intContractStatusId <> 3
			WHERE  strStatus='In-transit' AND cd.intCommodityId = @intCommodityId AND intVendorEntityId=@intVendorCustomerId
				AND cd.intCompanyLocationId = ISNULL(@intLocationId, cd.intCompanyLocationId)
		) t
	) t1
END

IF @strPurchaseSales = 'Sales'
BEGIN
	SELECT intSeqId
		, strType
		, dblTotal
	FROM #temp
	WHERE strType NOT LIKE '%Purchase%'
END
ELSE
BEGIN
	SELECT intSeqId
		, strType
		, dblTotal
	FROM #temp
	WHERE strType NOT LIKE '%Sales%'
END