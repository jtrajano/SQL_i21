CREATE PROCEDURE [dbo].[uspRKDPRInvDailyPositionDetail]  
	 @intCommodityId nvarchar(max)
	,@intLocationId nvarchar(max) = NULL
AS
BEGIN
	 DECLARE @Commodity AS TABLE 
	 (
		intCommodityIdentity int IDENTITY(1,1) PRIMARY KEY , 
		intCommodity  INT
	 )
	 INSERT INTO @Commodity(intCommodity)
	 SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCommodityId, ',')  

DECLARE @Final AS TABLE (
intRow int IDENTITY(1,1) PRIMARY KEY , 
intSeqId int, 
strCommodityCode nvarchar(100),
strType nvarchar(100),
dblTotal DECIMAL(24,10)
)


DECLARE @mRowNumber INT
DECLARE @intCommodityId1 INT
DECLARE @strDescription NVARCHAR(50)

SELECT @mRowNumber = MIN(intCommodityIdentity) FROM @Commodity

WHILE @mRowNumber > 0
BEGIN
	SELECT @intCommodityId = intCommodity FROM @Commodity WHERE intCommodityIdentity = @mRowNumber
	SELECT @strDescription = strDescription	FROM tblICCommodity	WHERE intCommodityId = @intCommodityId

INSERT INTO @Final(intSeqId,strCommodityCode,strType,dblTotal)
SELECT intSeqId,@strDescription,strType,ISNULL(dblTotal,0) FROM (
	SELECT 1 AS intSeqId
		,'In-House' AS [strType]
		,ISNULL(invQty, 0) - ISNULL(ReserveQty, 0) + ISNULL(dblBalance, 0) AS dblTotal
	FROM (
		SELECT (
				SELECT sum(isnull(it1.dblUnitOnHand, 0))
				FROM tblICItem i
				INNER JOIN tblICItemStock it1 ON it1.intItemId = i.intItemId
				INNER JOIN tblICItemLocation il ON il.intItemLocationId = it1.intItemLocationId
				WHERE i.intCommodityId =@intCommodityId
					AND il.intLocationId= case when isnull(@intLocationId,0)=0 then il.intLocationId else @intLocationId end
				) AS invQty
			,(
				SELECT SUM(isnull(sr1.dblQty, 0))
				FROM tblICItem i
				INNER JOIN tblICItemStock it1 ON it1.intItemId = i.intItemId
				INNER JOIN tblICStockReservation sr1 ON it1.intItemId = sr1.intItemId
				INNER JOIN tblICItemLocation il ON il.intItemLocationId = it1.intItemLocationId
				WHERE i.intCommodityId = @intCommodityId
					AND il.intLocationId= case when isnull(@intLocationId,0)=0 then il.intLocationId else @intLocationId end
				) AS ReserveQty
			,(
				SELECT ISNULL(SUM(ISNULL(Balance,0)),0)
				FROM vyuGRGetStorageDetail
				WHERE ysnCustomerStorage <> 1
					AND intCommodityId = @intCommodityId
					AND intCompanyLocationId= case when isnull(@intLocationId,0)=0 then intCompanyLocationId else @intLocationId end
				) dblBalance
		) t
	
	UNION ALL
	
	SELECT 2 AS intSeqId
		,'Off-Site' [Storage Type]
		,isnull(sum(Balance), 0) dblTotal
	FROM vyuGRGetStorageOffSiteDetail
	WHERE ysnReceiptedStorage = 1 AND ysnExternal = 1
		AND strOwnedPhysicalStock = 'Customer'
		AND intCommodityId = @intCommodityId
		AND intCompanyLocationId= case when isnull(@intLocationId,0)=0 then intCompanyLocationId else @intLocationId end
	
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
				AND il.intLocationId= case when isnull(@intLocationId,0)=0 then il.intLocationId else @intLocationId end
				) AS invQty
			,(
				SELECT SUM(isnull(sr1.dblQty, 0))
				FROM tblICItem i
				INNER JOIN tblICItemStock it1 ON it1.intItemId = i.intItemId
				INNER JOIN tblICStockReservation sr1 ON it1.intItemId = sr1.intItemId
				INNER JOIN tblICItemLocation il ON il.intItemLocationId = it1.intItemLocationId
				WHERE i.intCommodityId = @intCommodityId
			    AND il.intLocationId= case when isnull(@intLocationId,0)=0 then il.intLocationId else @intLocationId end					
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
					  AND il.intLocationId= case when isnull(@intLocationId,0)=0 then il.intLocationId else @intLocationId end
				) AS invQty
			,(
				SELECT SUM(isnull(sr1.dblQty, 0))
				FROM tblICItem i
				INNER JOIN tblICItemStock it1 ON it1.intItemId = i.intItemId
				INNER JOIN tblICStockReservation sr1 ON it1.intItemId = sr1.intItemId
				INNER JOIN tblICItemLocation il ON il.intItemLocationId = it1.intItemLocationId
				WHERE i.intCommodityId = @intCommodityId
					 AND il.intLocationId= case when isnull(@intLocationId,0)=0 then il.intLocationId else @intLocationId end
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
		     AND intCompanyLocationId= case when isnull(@intLocationId,0)=0 then intCompanyLocationId else @intLocationId end
			AND ysnDPOwnedType = 0 AND ysnReceiptedStorage = 0	GROUP BY [Storage Type]
		) t
	
	UNION ALL
	
	SELECT 7 AS intSeqId
		,'Total Non-Receipted' [Storage Type]
		,sum(Balance) dblTotal
	FROM vyuGRGetStorageDetail
	WHERE ysnReceiptedStorage = 0
		AND strOwnedPhysicalStock = 'Customer'
		AND intCommodityId = @intCommodityId
		AND intCompanyLocationId= case when isnull(@intLocationId,0)=0 then intCompanyLocationId else @intLocationId end
	
	UNION ALL
	
	SELECT 8 AS intSeqId
		,'Collatral Receipts - Sales' AS [strType]
		,isnull(SUM(dblOriginalQuantity), 0) - isnull(sum(dblAdjustmentAmount), 0) dblTotal
	FROM (
		SELECT isnull(SUM(dblAdjustmentAmount),0) dblAdjustmentAmount	,c.intCollateralId,
		(select dblOriginalQuantity from tblRKCollateral cc where cc.intCollateralId=c.intCollateralId) dblOriginalQuantity
		FROM tblRKCollateral c
		LEFT JOIN tblRKCollateralAdjustment ca ON c.intCollateralId = ca.intCollateralId
		WHERE strType = 'Sale' 	AND c.intCommodityId = @intCommodityId 
		AND c.intLocationId = case when isnull(@intLocationId,0)=0 then c.intLocationId  else @intLocationId end
		GROUP BY c.intCollateralId ) t
	WHERE dblAdjustmentAmount <> dblOriginalQuantity
	
	UNION ALL
	
	SELECT 9 AS intSeqId
		,'Collatral Receipts - Purchase' AS [strType]
		,isnull(SUM(dblOriginalQuantity), 0) - isnull(sum(dblAdjustmentAmount), 0) dblTotal
	FROM (
		SELECT isnull(SUM(dblAdjustmentAmount),0) dblAdjustmentAmount	,c.intCollateralId,
		(select dblOriginalQuantity from tblRKCollateral cc where cc.intCollateralId=c.intCollateralId) dblOriginalQuantity
		FROM tblRKCollateral c
		LEFT JOIN tblRKCollateralAdjustment ca ON c.intCollateralId = ca.intCollateralId
		WHERE strType = 'Purchase' 	AND c.intCommodityId = @intCommodityId 
		AND c.intLocationId = case when isnull(@intLocationId,0)=0 then c.intLocationId  else @intLocationId end
			GROUP BY c.intCollateralId ) t
	WHERE dblAdjustmentAmount <> dblOriginalQuantity
	
	UNION ALL
	
	SELECT 10 AS intSeqId
		,*
	FROM (
		SELECT [Storage Type] strType
			,isnull(SUM(Balance), 0) dblTotal
		FROM vyuGRGetStorageOffSiteDetail
		WHERE intCommodityId = @intCommodityId AND 
		intCompanyLocationId = case when isnull(@intLocationId,0)=0 then intCompanyLocationId  else @intLocationId end
		AND ysnReceiptedStorage = 1 AND ysnExternal <> 1
		GROUP BY [Storage Type]
		) t
	
	UNION ALL
	
	SELECT 11 AS intSeqId
		,'Total Receipted' AS [strType]
		,isnull(dblTotal1, 0) + (isnull(CollateralSale, 0) - isnull(CollateralPurchases, 0)) dblTotal
	FROM (
		SELECT isnull(SUM(Balance), 0) dblTotal1
		FROM vyuGRGetStorageOffSiteDetail
		WHERE intCommodityId = @intCommodityId 
		AND intCompanyLocationId = case when isnull(@intLocationId,0)=0 then intCompanyLocationId  else @intLocationId end
		AND ysnReceiptedStorage = 1 AND ysnExternal <> 1
		) dblTotal1
		,(
			SELECT isnull(SUM(dblOriginalQuantity), 0) - isnull(sum(dblAdjustmentAmount), 0) CollateralSale
			FROM (
				SELECT isnull(SUM(dblAdjustmentAmount),0) dblAdjustmentAmount
					,intContractHeaderId
					,SUM(dblOriginalQuantity) dblOriginalQuantity
				FROM tblRKCollateral c
				LEFT JOIN tblRKCollateralAdjustment ca ON c.intCollateralId = ca.intCollateralId
				WHERE strType = 'Sale'
					AND c.intCommodityId = @intCommodityId
					AND c.intLocationId  = case when isnull(@intLocationId,0)=0 then c.intLocationId   else @intLocationId end
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
				LEFT JOIN tblRKCollateralAdjustment ca ON c.intCollateralId = ca.intCollateralId
				WHERE strType = 'Purchase'
					AND c.intCommodityId = @intCommodityId
					AND c.intLocationId  = case when isnull(@intLocationId,0)=0 then c.intLocationId   else @intLocationId end
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
			AND intCompanyLocationId  = case when isnull(@intLocationId,0)=0 then intCompanyLocationId else @intLocationId end
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
			AND CT.intCompanyLocationId  = case when isnull(@intLocationId,0)=0 then CT.intCompanyLocationId else @intLocationId end
					
		UNION ALL
		
		SELECT isnull(SUM(isnull(ri.dblReceived, 0)), 0) AS dblTotal
		FROM tblICInventoryReceipt r
		INNER JOIN tblICInventoryReceiptItem ri ON r.intInventoryReceiptId = ri.intInventoryReceiptId	AND r.strReceiptType = 'Purchase Contract'
		INNER JOIN tblCTContractDetail cd ON cd.intContractDetailId = ri.intLineNo	AND cd.intPricingTypeId = 2
		INNER JOIN tblCTContractHeader ch ON ch.intContractHeaderId = cd.intContractHeaderId
		WHERE ch.intCommodityId = @intCommodityId
		AND cd.intCompanyLocationId  = case when isnull(@intLocationId,0)=0 then cd.intCompanyLocationId else @intLocationId end			
		) tot
	
	UNION ALL
	
	SELECT 14 AS intSeqId
		,'Sls Basis Deliveries' AS [strType]
		,isnull(SUM(isnull(ri.dblQuantity, 0)), 0) AS dblTotal
	FROM tblICInventoryShipment r
	INNER JOIN tblICInventoryShipmentItem ri ON r.intInventoryShipmentId = ri.intInventoryShipmentId
	INNER JOIN tblCTContractDetail cd ON cd.intContractDetailId = ri.intLineNo
		AND cd.intPricingTypeId = 2
	INNER JOIN tblCTContractHeader ch ON ch.intContractHeaderId = cd.intContractHeaderId
	WHERE ch.intCommodityId = @intCommodityId
	AND cd.intCompanyLocationId  = case when isnull(@intLocationId,0)=0 then cd.intCompanyLocationId else @intLocationId end	
			
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
					AND il.intLocationId  = case when isnull(@intLocationId,0)=0 then il.intLocationId else @intLocationId end							
					), 0) AS invQty
			,isnull((
					SELECT isnull(SUM(isnull(sr1.dblQty, 0)), 0)
					FROM tblICItem i
					INNER JOIN tblICItemStock it1 ON it1.intItemId = i.intItemId
					INNER JOIN tblICStockReservation sr1 ON it1.intItemId = sr1.intItemId
					INNER JOIN tblICItemLocation il ON il.intItemLocationId = it1.intItemLocationId
					WHERE i.intCommodityId = @intCommodityId
					AND il.intLocationId  = case when isnull(@intLocationId,0)=0 then il.intLocationId else @intLocationId end							
					), 0) AS ReserveQty
			,isnull((
					SELECT isnull(SUM(Balance), 0)
					FROM vyuGRGetStorageDetail
					WHERE (
							strOwnedPhysicalStock = 'Company'
							OR ysnDPOwnedType = 1
							)
						AND intCommodityId = @intCommodityId
						AND intCompanyLocationId = case when isnull(@intLocationId,0)=0 then intCompanyLocationId else @intLocationId end	
					), 0) dblBalance
			,isnull((
					SELECT isnull(SUM(dblOriginalQuantity), 0) - isnull(sum(dblAdjustmentAmount), 0) CollateralSale
					FROM (
						SELECT isnull(SUM(dblAdjustmentAmount), 0) dblAdjustmentAmount
							,intContractHeaderId
							,isnull(SUM(dblOriginalQuantity), 0) dblOriginalQuantity
						FROM tblRKCollateral c
						LEFT JOIN tblRKCollateralAdjustment ca ON c.intCollateralId = ca.intCollateralId
						WHERE strType = 'Sale'
							AND c.intCommodityId = @intCommodityId
							AND c.intLocationId = case when isnull(@intLocationId,0)=0 then c.intLocationId else @intLocationId end	
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
						LEFT JOIN tblRKCollateralAdjustment ca ON c.intCollateralId = ca.intCollateralId
						WHERE strType = 'Purchase'
							AND c.intCommodityId = @intCommodityId
							AND c.intLocationId = case when isnull(@intLocationId,0)=0 then c.intLocationId else @intLocationId end	
						GROUP BY intContractHeaderId
						) t
					WHERE dblAdjustmentAmount <> dblOriginalQuantity
					), 0) AS CollateralPurchases
		) t
		)t1

	SELECT @mRowNumber = MIN(intCommodityIdentity)	FROM @Commodity	WHERE intCommodityIdentity > @mRowNumber
	END
END


DECLARE @intUnitMeasureId int
DECLARE @intFromCommodityUnitMeasureId int
DECLARE @intToCommodityUnitMeasureId int
DECLARE @StrUnitMeasure nvarchar(50)

SELECT TOP 1 @intUnitMeasureId = intUnitMeasureId FROM tblRKCompanyPreference

IF ISNULL(@intUnitMeasureId,'') <> ''
BEGIN
SELECT @intFromCommodityUnitMeasureId=cuc.intCommodityUnitMeasureId,@intToCommodityUnitMeasureId=cuc1.intCommodityUnitMeasureId 
FROM tblICCommodity t
JOIN tblICCommodityUnitMeasure cuc on t.intCommodityId=cuc.intCommodityId and cuc.ysnDefault=1 
JOIN tblICCommodityUnitMeasure cuc1 on t.intCommodityId=cuc1.intCommodityId and @intUnitMeasureId=cuc1.intUnitMeasureId
WHERE t.intCommodityId= @intCommodityId
	SELECT @StrUnitMeasure=strUnitMeasure from tblICUnitMeasure where intUnitMeasureId=@intUnitMeasureId
END
ELSE
BEGIN
	SELECT @StrUnitMeasure=c.strUnitMeasure
	FROM tblICCommodity t
	JOIN tblICCommodityUnitMeasure cuc on t.intCommodityId=cuc.intCommodityId and cuc.ysnDefault=1
	JOIN tblICUnitMeasure c on c.intUnitMeasureId=cuc.intUnitMeasureId 	
	WHERE t.intCommodityId= @intCommodityId
END

BEGIN
		IF (ISNULL(@intToCommodityUnitMeasureId,'') <> '' and ISNULL(@intToCommodityUnitMeasureId,'') <> '')
		BEGIN
			SELECT intRow,intSeqId,strCommodityCode,strType, @StrUnitMeasure as strUnitMeasure, 
				Convert(decimal(24,10),dbo.fnCTConvertQuantityToTargetCommodityUOM(@intFromCommodityUnitMeasureId,@intToCommodityUnitMeasureId,dblTotal)) dblTotal
		FROM @Final 

		END
		ELSE
		BEGIN

			SELECT intRow,intSeqId,strCommodityCode,strType,@StrUnitMeasure as strUnitMeasure,Convert(decimal(24,10),dblTotal) dblTotal FROM @Final
		END
END
