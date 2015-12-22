CREATE PROC uspRKPositionByPeriodSelectionHeader 
	@intCommodityId  int ,
	@intCompanyLocationId  nvarchar(max) 
AS

declare @strCommodityCode nvarchar(100)

select @strCommodityCode=strCommodityCode from tblICCommodity WHERE intCommodityId=@intCommodityId

SELECT 1 AS intSeqId
		,'Ownership' AS [strType]
		,ISNULL(invQty, 0) +ISNULL(ReserveQty, 0) + ISNULL(InTransite, 0)+(isnull(dblPurchase,0)-ISNULL(dblSales,0)) AS dblTotal into #temp
	FROM (
		SELECT (
				SELECT sum(isnull(it1.dblUnitOnHand, 0))
				FROM tblICItem i
				INNER JOIN tblICItemStock it1 ON it1.intItemId = i.intItemId
				INNER JOIN tblICItemLocation il ON il.intItemLocationId = it1.intItemLocationId
				WHERE i.intCommodityId =@intCommodityId
					AND il.intLocationId in (SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCompanyLocationId, ','))
				) AS invQty
			,(SELECT SUM(isnull(sr1.dblQty, 0))
				FROM tblICItem i
				INNER JOIN tblICItemStock it1 ON it1.intItemId = i.intItemId
				INNER JOIN tblICStockReservation sr1 ON it1.intItemId = sr1.intItemId
				INNER JOIN tblICItemLocation il ON il.intItemLocationId = it1.intItemLocationId
				WHERE i.intCommodityId =@intCommodityId 
				AND il.intLocationId in (SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCompanyLocationId, ','))
				) AS ReserveQty
				
			,(SELECT SUM(dblStockQty) from vyuLGInventoryView iv 
				JOIN tblICItem i on iv.intItemId=i.intItemId 
				JOIN vyuCTContractDetailView cd on iv.intContractDetailId=cd.intContractDetailId
				where cd.intCommodityId =@intCommodityId
				AND cd.intCompanyLocationId in (SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCompanyLocationId, ','))
				) InTransite

				
			,(SELECT isnull(SUM(dblOriginalQuantity), 0) - isnull(sum(dblAdjustmentAmount), 0) dblTotal
			FROM (
				SELECT isnull(SUM(dblAdjustmentAmount),0) dblAdjustmentAmount	,c.intCollateralId,
				(SELECT dblOriginalQuantity from tblRKCollateral cc where cc.intCollateralId=c.intCollateralId) dblOriginalQuantity
				FROM tblRKCollateral c
				LEFT JOIN tblRKCollateralAdjustment ca ON c.intCollateralId = ca.intCollateralId
				WHERE strType = 'Sale' 	AND c.intCommodityId =@intCommodityId 
				AND c.intLocationId in (SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCompanyLocationId, ','))	
				GROUP BY c.intCollateralId ) t
			WHERE dblAdjustmentAmount <> dblOriginalQuantity) dblSales,
						
			(SELECT isnull(SUM(dblOriginalQuantity), 0) - isnull(sum(dblAdjustmentAmount), 0) dblTotal
			FROM (
				SELECT isnull(SUM(dblAdjustmentAmount),0) dblAdjustmentAmount	,c.intCollateralId,
				(select dblOriginalQuantity from tblRKCollateral cc where cc.intCollateralId=c.intCollateralId) dblOriginalQuantity
				FROM tblRKCollateral c
				LEFT JOIN tblRKCollateralAdjustment ca ON c.intCollateralId = ca.intCollateralId
				WHERE strType = 'Purchase' 	AND c.intCommodityId =@intCommodityId 
				AND c.intLocationId in (SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCompanyLocationId, ','))
				GROUP BY c.intCollateralId ) t
			WHERE dblAdjustmentAmount <> dblOriginalQuantity) dblPurchase
				
		) t

UNION
SELECT 2 AS intSeqId
		,'Delayed Price' AS [strType],0 AS dblTotal 
UNION
SELECT 3 AS intSeqId
		,'Purchase Basis Delivery' AS [strType],sum(ris.dblReceived) AS dblTotal 
FROM tblICInventoryReceipt r
INNER JOIN tblICInventoryReceiptItem ri ON r.intInventoryReceiptId = ri.intInventoryReceiptId AND r.strReceiptType = 'Purchase Contract'
INNER JOIN vyuICGetReceiptItemSource ris on ris.intInventoryReceiptItemId=ri.intInventoryReceiptItemId
INNER JOIN vyuCTContractDetailView cd ON cd.intContractDetailId = ri.intLineNo	AND cd.intPricingTypeId = 2
WHERE cd.intCommodityId =@intCommodityId	--AND cd.intCompanyLocationId = @intLocationId	
	AND cd.intCompanyLocationId in (SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCompanyLocationId, ','))
UNION

SELECT 4 AS intSeqId
		,'Sales Basis Delivery' AS [strType],isnull(SUM(isnull(ri.dblQuantity, 0)),0) AS dblTotal 
  FROM tblICInventoryShipment r  
  INNER JOIN tblICInventoryShipmentItem ri ON r.intInventoryShipmentId = ri.intInventoryShipmentId  
  INNER JOIN tblCTContractDetail cd ON cd.intContractDetailId = ri.intLineNo AND cd.intPricingTypeId = 2 
  INNER JOIN tblCTContractHeader ch ON ch.intContractHeaderId = cd.intContractHeaderId  
  WHERE ch.intCommodityId =@intCommodityId --AND cd.intCompanyLocationId = cl.intCompanyLocationId
  AND cd.intCompanyLocationId in (SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCompanyLocationId, ','))
  
  SELECT @strCommodityCode,'Inventory' strType,'Inventory' as strSecondSubHeading,strType as strSubHeading,'Inventory' as strMonth, round(isnull(dblTotal,0),4) dblTotal FROM #temp	

