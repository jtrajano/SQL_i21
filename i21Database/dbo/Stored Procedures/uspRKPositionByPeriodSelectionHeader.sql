CREATE PROC uspRKPositionByPeriodSelectionHeader 
	@intCommodityId  int ,
	@intCompanyLocationId  nvarchar(max),
	@intQuantityUOMId int
AS

declare @strCommodityCode nvarchar(100)

select @strCommodityCode=strCommodityCode from tblICCommodity WHERE intCommodityId=@intCommodityId

SELECT 1 AS intSeqId
		,'Ownership' AS [strType]
		,ISNULL(invQty, 0) + ISNULL(ReserveQty, 0) + ISNULL(InTransite, 0) + (isnull(dblPurchase,0) - ISNULL(dblSales,0)) AS dblTotal into #temp
	FROM (
		SELECT (
				SELECT 
				sum(isnull(dbo.fnCTConvertQuantityToTargetCommodityUOM(ium.intCommodityUnitMeasureId,ium1.intCommodityUnitMeasureId,isnull(it1.dblUnitOnHand,0)),0))
				FROM tblICItem i
				INNER JOIN tblICItemStock it1 ON it1.intItemId = i.intItemId
				INNER JOIN tblICItemUOM iuom on i.intItemId=iuom.intItemId and ysnStockUnit=1
				INNER JOIN tblICCommodityUnitMeasure ium on ium.intCommodityId=i.intCommodityId AND iuom.intUnitMeasureId=ium.intUnitMeasureId 
				JOIN tblICCommodityUnitMeasure ium1 on ium1.intCommodityId=i.intCommodityId AND ium1.intUnitMeasureId=@intQuantityUOMId
				INNER JOIN tblICItemLocation il ON il.intItemLocationId = it1.intItemLocationId
				WHERE i.intCommodityId =@intCommodityId	AND il.intLocationId in (SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCompanyLocationId, ','))
				) AS invQty

			,(SELECT sum(isnull(dbo.fnCTConvertQuantityToTargetCommodityUOM(ium.intCommodityUnitMeasureId,ium1.intCommodityUnitMeasureId,isnull(sr1.dblQty,0)),0))
				FROM tblICItem i
				INNER JOIN tblICItemStock it1 ON it1.intItemId = i.intItemId
				INNER JOIN tblICItemUOM iuom on i.intItemId=iuom.intItemId and ysnStockUnit=1
				INNER JOIN tblICCommodityUnitMeasure ium on ium.intCommodityId=i.intCommodityId AND iuom.intUnitMeasureId=ium.intUnitMeasureId 
				JOIN tblICCommodityUnitMeasure ium1 on ium1.intCommodityId=i.intCommodityId AND ium1.intUnitMeasureId=@intQuantityUOMId
				INNER JOIN tblICStockReservation sr1 ON it1.intItemId = sr1.intItemId
				INNER JOIN tblICItemLocation il ON il.intItemLocationId = it1.intItemLocationId
				WHERE i.intCommodityId =@intCommodityId 
				AND il.intLocationId in (SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCompanyLocationId, ','))
			  ) AS ReserveQty
				
			,(SELECT sum(isnull(dbo.fnCTConvertQuantityToTargetCommodityUOM(ium.intCommodityUnitMeasureId,ium1.intCommodityUnitMeasureId,isnull(dblStockQty,0)),0)) 
			  FROM vyuLGInventoryView iv 
				JOIN tblICItem i on iv.intItemId=i.intItemId 
				JOIN vyuCTContractDetailView cd on iv.intContractDetailId=cd.intContractDetailId and cd.intContractStatusId <> 3
				JOIN tblICCommodityUnitMeasure ium on ium.intCommodityId=cd.intCommodityId AND cd.intUnitMeasureId=ium.intUnitMeasureId 
				JOIN tblICCommodityUnitMeasure ium1 on ium1.intCommodityId=cd.intCommodityId AND ium1.intUnitMeasureId=@intQuantityUOMId
				WHERE cd.intCommodityId =@intCommodityId
				AND cd.intCompanyLocationId in (SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCompanyLocationId, ','))
				) InTransite
				
			,(SELECT isnull(SUM(dblOriginalQuantity), 0) - isnull(sum(dblAdjustmentAmount), 0) dblTotal
			FROM (
				SELECT 
				sum(isnull(dbo.fnCTConvertQuantityToTargetCommodityUOM(ium.intCommodityUnitMeasureId,ium1.intCommodityUnitMeasureId,isnull(dblAdjustmentAmount,0)),0))  dblAdjustmentAmount, 
				c.intCollateralId,
				(SELECT 
				isnull(dbo.fnCTConvertQuantityToTargetCommodityUOM(ium.intCommodityUnitMeasureId,ium1.intCommodityUnitMeasureId,isnull(dblOriginalQuantity,0)),0)
				 from tblRKCollateral cc where cc.intCollateralId=c.intCollateralId) dblOriginalQuantity
				FROM tblRKCollateral c
				JOIN tblICCommodityUnitMeasure ium on ium.intCommodityId=c.intCommodityId AND c.intUnitMeasureId=ium.intUnitMeasureId 
				JOIN tblICCommodityUnitMeasure ium1 on ium1.intCommodityId=c.intCommodityId AND ium1.intUnitMeasureId=@intQuantityUOMId
				LEFT JOIN tblRKCollateralAdjustment ca ON c.intCollateralId = ca.intCollateralId
				WHERE strType = 'Sale' 	AND c.intCommodityId =@intCommodityId 
				AND c.intLocationId in (SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCompanyLocationId, ','))	
				GROUP BY c.intCollateralId,ium.intCommodityUnitMeasureId,ium1.intCommodityUnitMeasureId  ) t
			WHERE dblAdjustmentAmount <> dblOriginalQuantity) dblSales,
						
			(SELECT isnull(SUM(dblOriginalQuantity), 0) - isnull(sum(dblAdjustmentAmount), 0) dblTotal
			FROM (
				SELECT sum(isnull(dbo.fnCTConvertQuantityToTargetCommodityUOM(ium.intCommodityUnitMeasureId,ium1.intCommodityUnitMeasureId,isnull(dblAdjustmentAmount,0)),0)) dblAdjustmentAmount,c.intCollateralId,
					(SELECT 
						isnull(dbo.fnCTConvertQuantityToTargetCommodityUOM(ium.intCommodityUnitMeasureId,ium1.intCommodityUnitMeasureId,isnull(dblOriginalQuantity,0)),0)
					FROM tblRKCollateral cc where cc.intCollateralId=c.intCollateralId) dblOriginalQuantity
				FROM tblRKCollateral c
				JOIN tblICCommodityUnitMeasure ium on ium.intCommodityId=c.intCommodityId AND c.intUnitMeasureId=ium.intUnitMeasureId 
				JOIN tblICCommodityUnitMeasure ium1 on ium1.intCommodityId=c.intCommodityId AND ium1.intUnitMeasureId=@intQuantityUOMId
				LEFT JOIN tblRKCollateralAdjustment ca ON c.intCollateralId = ca.intCollateralId
				WHERE strType = 'Purchase' 	AND c.intCommodityId =@intCommodityId 
				AND c.intLocationId in (SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCompanyLocationId, ','))
				GROUP BY c.intCollateralId,ium.intCommodityUnitMeasureId ,ium1.intCommodityUnitMeasureId ) t
			WHERE dblAdjustmentAmount <> dblOriginalQuantity) dblPurchase				
		) t

UNION
SELECT 2 AS intSeqId
		,'Delayed Price' AS [strType],0 AS dblTotal 

UNION
SELECT 3 AS intSeqId
		,'Purchase Basis Delivery' AS [strType],
		sum(isnull(dbo.fnCTConvertQuantityToTargetCommodityUOM(ium.intCommodityUnitMeasureId,ium1.intCommodityUnitMeasureId,isnull(ris.dblReceived,0)),0)) AS dblTotal 
FROM tblICInventoryReceipt r
INNER JOIN tblICInventoryReceiptItem ri ON r.intInventoryReceiptId = ri.intInventoryReceiptId AND r.strReceiptType = 'Purchase Contract'
INNER JOIN vyuICGetReceiptItemSource ris on ris.intInventoryReceiptItemId=ri.intInventoryReceiptItemId
INNER JOIN vyuCTContractDetailView cd ON cd.intContractDetailId = ri.intLineNo	AND cd.intPricingTypeId = 2 and cd.intContractStatusId <> 3
JOIN tblICCommodityUnitMeasure ium on ium.intCommodityId=cd.intCommodityId AND cd.intUnitMeasureId=ium.intUnitMeasureId 
JOIN tblICCommodityUnitMeasure ium1 on ium1.intCommodityId=cd.intCommodityId AND ium1.intUnitMeasureId=@intQuantityUOMId
WHERE cd.intCommodityId =@intCommodityId AND cd.intCompanyLocationId in (SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCompanyLocationId, ','))

UNION

SELECT 4 AS intSeqId
		,'Sales Basis Delivery' AS [strType],
		sum(isnull(dbo.fnCTConvertQuantityToTargetCommodityUOM(ium.intCommodityUnitMeasureId,ium1.intCommodityUnitMeasureId,isnull(ri.dblQuantity,0)),0)) AS dblTotal 
  FROM tblICInventoryShipment r  
  INNER JOIN tblICInventoryShipmentItem ri ON r.intInventoryShipmentId = ri.intInventoryShipmentId  
  INNER JOIN vyuCTContractDetailView cd ON cd.intContractDetailId = ri.intLineNo AND cd.intPricingTypeId = 2  and cd.intContractStatusId <> 3
  JOIN tblICCommodityUnitMeasure ium on ium.intCommodityId=cd.intCommodityId AND cd.intUnitMeasureId=ium.intUnitMeasureId 
  JOIN tblICCommodityUnitMeasure ium1 on ium1.intCommodityId=cd.intCommodityId AND ium1.intUnitMeasureId=@intQuantityUOMId
  WHERE cd.intCommodityId =@intCommodityId 
  AND cd.intCompanyLocationId in (SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCompanyLocationId, ','))
  
  SELECT @strCommodityCode,'Inventory' strType,'Inventory' as strSecondSubHeading,strType as strSubHeading,'Inventory' as strMonth, round(isnull(dblTotal,0),4) dblTotal FROM #temp	