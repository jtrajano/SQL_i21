﻿CREATE PROCEDURE [dbo].[uspRKDPRInvDailyPositionDetail] 

	 @intCommodityId nvarchar(max)  
	,@intLocationId int = NULL
as
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
					dblTotal DECIMAL(24,10),
					intCollateralId int,
					strLocationName nvarchar(50),
					strCustomer nvarchar(50),
					intReceiptNo nvarchar(50),
					intContractHeaderId int,
					strContractNumber nvarchar(100),
					strCustomerReference nvarchar(100),
					strDistributionOption nvarchar(100),
					strDPAReceiptNo nvarchar(100),
					dblDiscDue DECIMAL(24,10),
					dblStorageDue DECIMAL(24,10),	
					dtmLastStorageAccrueDate datetime,
					strScheduleId nvarchar(100),
					strTicket nvarchar(100),
					dtmOpenDate datetime,
					dtmDeliveryDate datetime,
					dtmTicketDateTime datetime,
					dblOriginalQuantity  DECIMAL(24,10),
					dblRemainingQuantity DECIMAL(24,10),
					intCommodityId int,
					strItemNo nvarchar(100),
					strUnitMeasure nvarchar(100)
					,intFromCommodityUnitMeasureId int
					,intToCommodityUnitMeasureId int
)

DECLARE @FinalTable AS TABLE (
					intRow int IDENTITY(1,1) PRIMARY KEY , 
					intSeqId int, 
					strCommodityCode nvarchar(100),
					strType nvarchar(100),
					dblTotal DECIMAL(24,10),
					intCollateralId int,
					strLocationName nvarchar(50),
					strCustomer nvarchar(50),
					intReceiptNo nvarchar(50),
					intContractHeaderId int,
					strContractNumber nvarchar(100),
					strCustomerReference nvarchar(100),
					strDistributionOption nvarchar(100),
					strDPAReceiptNo nvarchar(100),
					dblDiscDue DECIMAL(24,10),
					dblStorageDue DECIMAL(24,10),	
					dtmLastStorageAccrueDate datetime,
					strScheduleId nvarchar(100),
					strTicket nvarchar(100),
					dtmOpenDate datetime,
					dtmDeliveryDate datetime,
					dtmTicketDateTime datetime,
					dblOriginalQuantity  DECIMAL(24,10),
					dblRemainingQuantity DECIMAL(24,10),
					intCommodityId int,
					strItemNo nvarchar(100),
					strUnitMeasure nvarchar(100)
					,intFromCommodityUnitMeasureId int
					,intToCommodityUnitMeasureId int
)

DECLARE @mRowNumber INT
DECLARE @intCommodityId1 INT
DECLARE @strDescription NVARCHAR(50)
declare @intCommodityUnitMeasureId int

SELECT @mRowNumber = MIN(intCommodityIdentity) FROM @Commodity

WHILE @mRowNumber > 0
	BEGIN
		SELECT @intCommodityId = intCommodity FROM @Commodity WHERE intCommodityIdentity = @mRowNumber
		SELECT @strDescription = strCommodityCode	FROM tblICCommodity	WHERE intCommodityId = @intCommodityId
		SELECT @intCommodityUnitMeasureId=intCommodityUnitMeasureId from tblICCommodityUnitMeasure where intCommodityId=@intCommodityId and ysnDefault=1

if @intCommodityId >= 0
BEGIN
INSERT INTO @Final(intSeqId,strCommodityCode,strType,dblTotal,strLocationName,strItemNo,intCommodityId,intFromCommodityUnitMeasureId)

				SELECT 1 AS intSeqId,@strDescription,'In-House' AS [strType],
				dbo.fnCTConvertQuantityToTargetCommodityUOM(ium.intCommodityUnitMeasureId,@intCommodityUnitMeasureId,isnull((it1.dblUnitOnHand),0))
				, ic.strLocationName,i.strItemNo,@intCommodityId,@intCommodityUnitMeasureId	
				FROM tblICItem i
				INNER JOIN tblICInventoryReceiptItem ii on ii.intItemId = i.intItemId
				INNER JOIN tblICInventoryReceipt ir on ir.intInventoryReceiptId=ii.intInventoryReceiptId
				INNER JOIN tblICItemStock it1 ON it1.intItemId = i.intItemId
				INNER JOIN tblICItemUOM iuom on i.intItemId=iuom.intItemId and ysnStockUnit=1
				INNER JOIN tblICCommodityUnitMeasure ium on ium.intCommodityId=i.intCommodityId AND iuom.intUnitMeasureId=ium.intUnitMeasureId 
				INNER JOIN tblICItemLocation il ON il.intItemLocationId = it1.intItemLocationId
				INNER JOIN tblSMCompanyLocation ic on ic.intCompanyLocationId = il.intLocationId
				WHERE i.intCommodityId =@intCommodityId AND il.intLocationId= case when isnull(@intLocationId,0)=0 then il.intLocationId else @intLocationId end
				UNION
				SELECT 1 AS intSeqId,@strDescription,'In-House' AS [strType],
				dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId,@intCommodityUnitMeasureId,isnull(Balance,0))
				,strLocationName,strItemNo,@intCommodityId,@intCommodityUnitMeasureId
				FROM vyuGRGetStorageDetail 
				WHERE ysnCustomerStorage <> 1 AND
				intCommodityId = @intCommodityId AND intCompanyLocationId= case when isnull(@intLocationId,0)=0 then intCompanyLocationId else @intLocationId end
				
				
				UNION


				(select 1 AS intSeqId,@strDescription,'In-House' AS [strType],				
				 CASE WHEN (SELECT TOP 1 ysnIncludeDPPurchasesInCompanyTitled from tblRKCompanyPreference)=1 then dblTotal  else 0 end dblTotal 
				 ,strLocationName,strItemNo,@intCommodityId,@intCommodityUnitMeasureId
				 FROM (
				SELECT 
				dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId,@intCommodityUnitMeasureId,(isnull(Balance,0))) dblTotal,strLocationName,strItemNo
				FROM vyuGRGetStorageDetail ch
				WHERE ch.intCommodityId  = @intCommodityId	AND ysnDPOwnedType = 1
					AND ch.intCompanyLocationId= case when isnull(@intLocationId,0)=0 then ch.intCompanyLocationId else @intLocationId end
				)t)

INSERT INTO @Final (intSeqId,strCommodityCode,strType,dblTotal,intCommodityId ,strLocationName ,dtmDeliveryDate ,strTicket ,
					strCustomerReference,strDPAReceiptNo ,dblDiscDue ,dblStorageDue , dtmLastStorageAccrueDate ,strScheduleId,intFromCommodityUnitMeasureId)
		SELECT 2,@strDescription,'Off-Site' strType,
		dbo.fnCTConvertQuantityToTargetCommodityUOM(ium.intCommodityUnitMeasureId,@intCommodityUnitMeasureId,(Balance)) dblTotal,r.intCommodityId,Loc AS strLocation ,[Delivery Date] AS dtmDeliveryDate ,
				Ticket strTicket ,Customer as strCustomerReference ,Receipt AS strDPAReceiptNo ,[Disc Due] AS dblDiscDue ,
				[Storage Due] AS dblStorageDue ,dtmLastStorageAccrueDate ,strScheduleId,@intCommodityUnitMeasureId  
		FROM vyuGRGetStorageOffSiteDetail r
		join tblICItem i on r.intItemId=i.intItemId
		JOIN tblICItemUOM iuom on i.intItemId=iuom.intItemId and ysnStockUnit=1 
		JOIN tblICCommodityUnitMeasure ium on ium.intCommodityId=i.intCommodityId AND iuom.intUnitMeasureId=ium.intUnitMeasureId 
		WHERE ysnReceiptedStorage = 1 AND ysnExternal = 1 AND strOwnedPhysicalStock = 'Customer' AND r.intCommodityId = @intCommodityId 
		AND intCompanyLocationId= case when isnull(@intLocationId,0)=0 then intCompanyLocationId else @intLocationId end

INSERT INTO @Final(intSeqId,strCommodityCode,strType,dblTotal,strLocationName,strItemNo,intCommodityId,intFromCommodityUnitMeasureId)
	SELECT 3 AS intSeqId,@strDescription,'Purchase In-Transit' AS [strType],ISNULL(ReserveQty, 0) AS dblTotal,strLocationName,strItemNo,@intCommodityId,@intCommodityUnitMeasureId
	FROM (
				SELECT 
				dbo.fnCTConvertQuantityToTargetCommodityUOM(ium.intCommodityUnitMeasureId,@intCommodityUnitMeasureId,isnull(sr1.dblQty, 0)) as ReserveQty,ic.strLocationName,i.strItemNo
				FROM tblICItem i
				INNER JOIN tblICItemStock it1 ON it1.intItemId = i.intItemId
				JOIN tblICItemUOM iuom on i.intItemId=iuom.intItemId and ysnStockUnit=1
				JOIN tblICCommodityUnitMeasure ium on ium.intCommodityId=i.intCommodityId AND iuom.intUnitMeasureId=ium.intUnitMeasureId 
				INNER JOIN tblICStockReservation sr1 ON it1.intItemId = sr1.intItemId
				INNER JOIN tblICItemLocation il ON il.intItemLocationId = it1.intItemLocationId
				INNER JOIN tblSMCompanyLocation ic on ic.intCompanyLocationId = il.intLocationId
				WHERE i.intCommodityId = @intCommodityId
			    AND il.intLocationId= case when isnull(@intLocationId,0)=0 then il.intLocationId else @intLocationId end					
		) t

INSERT INTO @Final(intSeqId,strCommodityCode,strType,dblTotal,strLocationName,strItemNo,intCommodityId,intFromCommodityUnitMeasureId)
SELECT 4 AS intSeqId,@strDescription
		,'Sales In-Transit' AS [strType]
		,ISNULL(ReserveQty, 0) AS dblTotal,strLocationName,strItemNo,@intCommodityId,@intCommodityUnitMeasureId
	FROM (
		SELECT dbo.fnCTConvertQuantityToTargetCommodityUOM(ium.intCommodityUnitMeasureId,@intCommodityUnitMeasureId,isnull(sr1.dblQty, 0)) as ReserveQty,ic.strLocationName,i.strItemNo
				FROM tblICItem i
				INNER JOIN tblICItemStock it1 ON it1.intItemId = i.intItemId
				JOIN tblICItemUOM iuom on i.intItemId=iuom.intItemId and ysnStockUnit=1
				JOIN tblICCommodityUnitMeasure ium on ium.intCommodityId=i.intCommodityId AND iuom.intUnitMeasureId=ium.intUnitMeasureId 
				INNER JOIN tblICStockReservation sr1 ON it1.intItemId = sr1.intItemId
				INNER JOIN tblICItemLocation il ON il.intItemLocationId = it1.intItemLocationId
				INNER JOIN tblSMCompanyLocation ic on ic.intCompanyLocationId = il.intLocationId
				WHERE i.intCommodityId = @intCommodityId
			    AND il.intLocationId= case when isnull(@intLocationId,0)=0 then il.intLocationId else @intLocationId end	
		) t

INSERT INTO @Final (intSeqId,strCommodityCode,strType,dblTotal,intCommodityId,strLocationName ,dtmDeliveryDate ,strTicket ,strCustomerReference,strDPAReceiptNo ,	dblDiscDue ,
					  dblStorageDue ,	dtmLastStorageAccrueDate ,strScheduleId,intFromCommodityUnitMeasureId)
		SELECT 5,@strDescription,[Storage Type] strType,
		dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId,@intCommodityUnitMeasureId,ISNULL(Balance, 0)) dblTotal,
		r.intCommodityId,Loc AS strLocation ,[Delivery Date] AS dtmDeliveryDate ,Ticket strTicket  
		,Customer as strCustomerReference,Receipt AS strDPAReceiptNo ,[Disc Due] AS dblDiscDue ,[Storage Due] AS dblStorageDue  
		,dtmLastStorageAccrueDate ,strScheduleId ,@intCommodityUnitMeasureId   
		FROM vyuGRGetStorageDetail  r
		WHERE r.intCommodityId = @intCommodityId AND ysnDPOwnedType = 0  AND ysnReceiptedStorage = 0  
		AND	intCompanyLocationId  = case when isnull(@intLocationId,0)=0 then intCompanyLocationId else @intLocationId end

INSERT INTO @Final(intSeqId,strCommodityCode,strType,dblTotal,strLocationName,strItemNo,intCommodityId,intFromCommodityUnitMeasureId)
	SELECT 7 AS intSeqId,@strDescription
		,'Total Non-Receipted' [Storage Type]
		,dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId,@intCommodityUnitMeasureId,ISNULL(Balance, 0)) dblTotal,strLocationName,r.strItemNo, @intCommodityId,@intCommodityUnitMeasureId
	FROM vyuGRGetStorageDetail  r
	WHERE ysnReceiptedStorage = 0
		AND strOwnedPhysicalStock = 'Customer'
		AND r.intCommodityId = @intCommodityId
		AND intCompanyLocationId= case when isnull(@intLocationId,0)=0 then intCompanyLocationId else @intLocationId end	
--Collatral Sale
INSERT INTO @Final(intSeqId,strCommodityCode,strType,dblTotal,intCollateralId,strLocationName,strCustomer,intReceiptNo,intContractHeaderId,strContractNumber,dtmOpenDate,dblOriginalQuantity,dblRemainingQuantity,intCommodityId,intFromCommodityUnitMeasureId)
		SELECT 8, @strDescription,'Collateral Receipts - Sales' ,
		dbo.fnCTConvertQuantityToTargetCommodityUOM(ium.intCommodityUnitMeasureId,@intCommodityUnitMeasureId,isnull((dblRemainingQuantity),0))
		, c.intCollateralId,cl.strLocationName,ch.strEntityName,c.intReceiptNo,ch.intContractHeaderId,
		ch.strContractNumber +'-' +Convert(nvarchar,intContractSeq) strContractNumber,
		c.dtmOpenDate,
		dbo.fnCTConvertQuantityToTargetCommodityUOM(ium.intCommodityUnitMeasureId,@intCommodityUnitMeasureId,isnull((c.dblOriginalQuantity),0)) dblOriginalQuantity,
		dbo.fnCTConvertQuantityToTargetCommodityUOM(ium.intCommodityUnitMeasureId,@intCommodityUnitMeasureId,isnull((c.dblRemainingQuantity),0)) dblRemainingQuantity
	   ,@intCommodityId,c.intUnitMeasureId
		FROM tblRKCollateral c
		JOIN tblICCommodity co on co.intCommodityId=c.intCommodityId
		JOIN tblICCommodityUnitMeasure ium on ium.intCommodityId=c.intCommodityId AND c.intUnitMeasureId=ium.intUnitMeasureId 
		LEFT JOIN vyuCTContractDetailView ch on c.intContractHeaderId=ch.intContractHeaderId
		JOIN tblSMCompanyLocation cl on cl.intCompanyLocationId=c.intLocationId
		WHERE strType = 'Sale' AND c.intCommodityId = @intCommodityId 
		AND c.intLocationId = case when isnull(@intLocationId,0)=0 then c.intLocationId  else @intLocationId end
-- Collatral Purchase
INSERT INTO @Final(intSeqId,strCommodityCode,strType,dblTotal,intCollateralId,strLocationName,strCustomer,intReceiptNo,intContractHeaderId,strContractNumber,dtmOpenDate,dblOriginalQuantity,dblRemainingQuantity,intCommodityId,intFromCommodityUnitMeasureId)
		SELECT 9, @strDescription,'Collateral Receipts - Purchase' ,dbo.fnCTConvertQuantityToTargetCommodityUOM(ium.intCommodityUnitMeasureId,@intCommodityUnitMeasureId,isnull((dblRemainingQuantity),0)), c.intCollateralId,cl.strLocationName,ch.strEntityName,c.intReceiptNo,ch.intContractHeaderId,
		ch.strContractNumber +'-' +Convert(nvarchar,intContractSeq) strContractNumber,c.dtmOpenDate,
			dbo.fnCTConvertQuantityToTargetCommodityUOM(ium.intCommodityUnitMeasureId,@intCommodityUnitMeasureId,isnull((c.dblOriginalQuantity),0)) dblOriginalQuantity,
		dbo.fnCTConvertQuantityToTargetCommodityUOM(ium.intCommodityUnitMeasureId,@intCommodityUnitMeasureId,isnull((c.dblRemainingQuantity),0)) dblRemainingQuantity,
		@intCommodityId,c.intUnitMeasureId	
		FROM tblRKCollateral c
		JOIN tblICCommodity co on co.intCommodityId=c.intCommodityId
		JOIN tblICCommodityUnitMeasure ium on ium.intCommodityId=c.intCommodityId AND c.intUnitMeasureId=ium.intUnitMeasureId
		LEFT JOIN vyuCTContractDetailView ch on c.intContractHeaderId=ch.intContractHeaderId
		JOIN tblSMCompanyLocation cl on cl.intCompanyLocationId=c.intLocationId
		WHERE strType = 'Purchase' AND c.intCommodityId = @intCommodityId 
		AND c.intLocationId = case when isnull(@intLocationId,0)=0 then c.intLocationId  else @intLocationId end

INSERT INTO @Final (intSeqId,strCommodityCode,strType,dblTotal,intCommodityId,strLocationName ,dtmDeliveryDate ,strTicket ,strCustomerReference,strDPAReceiptNo ,	dblDiscDue ,
					  dblStorageDue ,	dtmLastStorageAccrueDate ,strScheduleId,intFromCommodityUnitMeasureId)
			SELECT 10,@strDescription,[Storage Type] strType,
			dbo.fnCTConvertQuantityToTargetCommodityUOM(ium.intCommodityUnitMeasureId,@intCommodityUnitMeasureId,(Balance)) dblTotal,
			r.intCommodityId  ,Loc AS strLocation ,[Delivery Date] AS dtmDeliveryDate ,Ticket strTicket  
			,Customer as strCustomerReference ,Receipt AS strDPAReceiptNo ,[Disc Due] AS dblDiscDue ,[Storage Due] AS dblStorageDue  
			,dtmLastStorageAccrueDate ,strScheduleId,@intCommodityUnitMeasureId  
			FROM vyuGRGetStorageOffSiteDetail  r
			join tblICItem i on r.intItemId=i.intItemId
			JOIN tblICItemUOM iuom on i.intItemId=iuom.intItemId and ysnStockUnit=1 
			JOIN tblICCommodityUnitMeasure ium on ium.intCommodityId=i.intCommodityId AND iuom.intUnitMeasureId=ium.intUnitMeasureId 
			WHERE ysnReceiptedStorage = 1 AND ysnExternal <> 1 AND strOwnedPhysicalStock = 'Customer'  
			AND r.intCommodityId = @intCommodityId  AND intCompanyLocationId  = case when isnull(@intLocationId,0)=0 then intCompanyLocationId else @intLocationId end 

INSERT INTO @Final(intSeqId,strCommodityCode,strType,dblTotal,intCommodityId,intFromCommodityUnitMeasureId)
SELECT 11 AS intSeqId,@strDescription
		,'Total Receipted' AS [strType]
		,isnull(dblTotal, 0)  + (isnull(CollateralSale, 0) - isnull(CollateralPurchases, 0)) dblTotal,@intCommodityId,@intCommodityUnitMeasureId
	FROM (select sum(dblTotal) dblTotal from (
		SELECT dbo.fnCTConvertQuantityToTargetCommodityUOM(ium.intCommodityUnitMeasureId,@intCommodityUnitMeasureId,isnull(Balance,0))dblTotal
		FROM vyuGRGetStorageOffSiteDetail r
			join tblICItem i on r.intItemId=i.intItemId
			JOIN tblICItemUOM iuom on i.intItemId=iuom.intItemId and ysnStockUnit=1 
			JOIN tblICCommodityUnitMeasure ium on ium.intCommodityId=i.intCommodityId AND iuom.intUnitMeasureId=ium.intUnitMeasureId 
		WHERE r.intCommodityId = @intCommodityId 
		AND intCompanyLocationId = case when isnull(@intLocationId,0)=0 then intCompanyLocationId  else @intLocationId end
		AND ysnReceiptedStorage = 1 AND ysnExternal <> 1
		)t) dblTotal1
		,(
			SELECT isnull(SUM(dblOriginalQuantity), 0) - isnull(sum(dblAdjustmentAmount), 0) CollateralSale
			FROM (select sum(dblAdjustmentAmount) dblAdjustmentAmount, sum(dblOriginalQuantity) dblOriginalQuantity from (
				SELECT
				dbo.fnCTConvertQuantityToTargetCommodityUOM(ium.intCommodityUnitMeasureId,@intCommodityUnitMeasureId,(isnull(dblAdjustmentAmount,0))) dblAdjustmentAmount, 
				dbo.fnCTConvertQuantityToTargetCommodityUOM(ium.intCommodityUnitMeasureId,@intCommodityUnitMeasureId,(isnull(dblOriginalQuantity,0))) dblOriginalQuantity
				FROM tblRKCollateral c
				JOIN tblICCommodityUnitMeasure ium on ium.intCommodityId=c.intCommodityId AND c.intUnitMeasureId=ium.intUnitMeasureId
				LEFT JOIN tblRKCollateralAdjustment ca ON c.intCollateralId = ca.intCollateralId
				WHERE strType = 'Sale' AND c.intCommodityId = @intCommodityId
					AND c.intLocationId  = case when isnull(@intLocationId,0)=0 then c.intLocationId   else @intLocationId end				
				)t) t1	WHERE dblAdjustmentAmount <> dblOriginalQuantity
			) AS CollateralSale
		,(
			SELECT isnull(SUM(dblOriginalQuantity), 0) - isnull(sum(dblAdjustmentAmount), 0) CollateralPurchases
			FROM (select sum(dblAdjustmentAmount) dblAdjustmentAmount, sum(dblOriginalQuantity) dblOriginalQuantity from (
				SELECT
				dbo.fnCTConvertQuantityToTargetCommodityUOM(ium.intCommodityUnitMeasureId,@intCommodityUnitMeasureId,(isnull(dblAdjustmentAmount,0))) dblAdjustmentAmount, 
				dbo.fnCTConvertQuantityToTargetCommodityUOM(ium.intCommodityUnitMeasureId,@intCommodityUnitMeasureId,(isnull(dblOriginalQuantity,0))) dblOriginalQuantity
				FROM tblRKCollateral c
				JOIN tblICCommodityUnitMeasure ium on ium.intCommodityId=c.intCommodityId AND c.intUnitMeasureId=ium.intUnitMeasureId
				LEFT JOIN tblRKCollateralAdjustment ca ON c.intCollateralId = ca.intCollateralId
				WHERE strType = 'Purchase' AND c.intCommodityId = @intCommodityId
					AND c.intLocationId  = case when isnull(@intLocationId,0)=0 then c.intLocationId   else @intLocationId end				
				)t) t1	WHERE dblAdjustmentAmount <> dblOriginalQuantity
			) AS  CollateralPurchases

INSERT INTO @Final (intSeqId,strCommodityCode,strType,dblTotal,intCommodityId,strLocationName ,dtmDeliveryDate ,strTicket ,strCustomerReference,strDPAReceiptNo ,	dblDiscDue ,
					  dblStorageDue ,	dtmLastStorageAccrueDate ,strScheduleId,intFromCommodityUnitMeasureId)
			SELECT distinct 12,@strDescription,[Storage Type] strType,dbo.fnCTConvertQuantityToTargetCommodityUOM(ium.intCommodityUnitMeasureId,@intCommodityUnitMeasureId,ISNULL(Balance, 0)) dblTotal,r.intCommodityId  ,Loc AS strLocation ,[Delivery Date] AS dtmDeliveryDate ,Ticket strTicket  
			,Customer as strCustomerReference ,Receipt AS strDPAReceiptNo ,[Disc Due] AS dblDiscDue ,[Storage Due] AS dblStorageDue  
			,dtmLastStorageAccrueDate ,strScheduleId,@intCommodityUnitMeasureId  
			FROM vyuGRGetStorageOffSiteDetail  r
			join tblICItem i on r.intItemId=i.intItemId
			JOIN tblICItemUOM iuom on i.intItemId=iuom.intItemId and ysnStockUnit=1 
			JOIN tblICCommodityUnitMeasure ium on ium.intCommodityId=i.intCommodityId AND iuom.intUnitMeasureId=ium.intUnitMeasureId 
			WHERE  ysnDPOwnedType = 1  
			AND r.intCommodityId = @intCommodityId  AND intCompanyLocationId  = CASE WHEN ISNULL(@intLocationId,0)=0 then intCompanyLocationId else @intLocationId end 

INSERT INTO @Final (intSeqId,strCommodityCode,strType,dblTotal,intCommodityId,strLocationName,strTicket,dtmTicketDateTime,strCustomerReference, strDistributionOption,intFromCommodityUnitMeasureId)
			SELECT 13,@strDescription,'Pur Basis Deliveries' strType,
			dbo.fnCTConvertQuantityToTargetCommodityUOM(ium.intCommodityUnitMeasureId,@intCommodityUnitMeasureId,isnull((PLDetail.dblLotPickedQty),0))
			 AS dblTotal,CT.intCommodityId,cl.strLocationName,convert(nvarchar,CT.strContractNumber)+'/'+convert(nvarchar,CT.intContractSeq) strTicket,CT.dtmContractDate as dtmTicketDateTime ,
			CT.strCustomerContract as strCustomerReference, 'CNT' as strDistributionOption,@intCommodityUnitMeasureId
			FROM tblLGDeliveryPickDetail Del
			INNER JOIN tblLGPickLotDetail PLDetail ON PLDetail.intPickLotDetailId = Del.intPickLotDetailId
			INNER JOIN vyuLGPickOpenInventoryLots Lots ON Lots.intLotId = PLDetail.intLotId
			INNER JOIN vyuCTContractDetailView CT ON CT.intContractDetailId = Lots.intContractDetailId
			JOIN tblICCommodityUnitMeasure ium on ium.intCommodityId=CT.intCommodityId AND CT.intUnitMeasureId=ium.intUnitMeasureId 
			INNER JOIN tblSMCompanyLocation  cl on cl.intCompanyLocationId=CT.intCompanyLocationId
			WHERE CT.intPricingTypeId = 2 AND CT.intCommodityId = @intCommodityId 
			AND CT.intCompanyLocationId  = case when isnull(@intLocationId,0)=0 then CT.intCompanyLocationId   else @intLocationId end
			
			UNION ALL
			
			SELECT 13,@strDescription,'Pur Basis Deliveries' strType,
			dbo.fnCTConvertQuantityToTargetCommodityUOM(ium.intCommodityUnitMeasureId,@intCommodityUnitMeasureId,isnull(ri.dblReceived, 0))  AS dblTotal,
			st.intCommodityId,cl.strLocationName,strTicketNumber strTicket,st.dtmTicketDateTime,strCustomerReference,
					strDistributionOption,@intCommodityUnitMeasureId
			FROM tblICInventoryReceipt r
			INNER JOIN tblICInventoryReceiptItem ri ON r.intInventoryReceiptId = ri.intInventoryReceiptId AND r.strReceiptType = 'Purchase Contract'
			INNER JOIN tblSCTicket st ON st.intTicketId = ri.intSourceId  AND strDistributionOption IN ('CNT')
			INNER JOIN vyuCTContractDetailView cd ON cd.intContractDetailId = ri.intLineNo AND cd.intPricingTypeId = 2
			JOIN tblICCommodityUnitMeasure ium on ium.intCommodityId=cd.intCommodityId AND cd.intUnitMeasureId=ium.intUnitMeasureId 
			INNER JOIN tblSMCompanyLocation  cl on cl.intCompanyLocationId=st.intProcessingLocationId 
			WHERE cd.intCommodityId = @intCommodityId 
			AND st.intProcessingLocationId  = case when isnull(@intLocationId,0)=0 then st.intProcessingLocationId else @intLocationId end

INSERT INTO @Final (intSeqId,strCommodityCode,strType,dblTotal,intCommodityId,strLocationName,strTicket,dtmTicketDateTime,strCustomerReference, strDistributionOption,intFromCommodityUnitMeasureId)
			SELECT 13,@strDescription,'Sls Basis Deliveries' strType,
			dbo.fnCTConvertQuantityToTargetCommodityUOM(ium.intCommodityUnitMeasureId,@intCommodityUnitMeasureId,isnull(ri.dblQuantity, 0))  AS dblTotal,
			cd.intCommodityId,cl.strLocationName,convert(nvarchar,cd.strContractNumber)+'/'+convert(nvarchar,cd.intContractSeq) strTicketNumber,
			cd.dtmContractDate as dtmTicketDateTime ,
			cd.strCustomerContract as strCustomerReference, 'CNT' as strDistributionOption,cd.intUnitMeasureId
			FROM tblICInventoryShipment r
			INNER JOIN tblICInventoryShipmentItem ri ON r.intInventoryShipmentId = ri.intInventoryShipmentId
			INNER JOIN vyuCTContractDetailView cd ON cd.intContractDetailId = ri.intLineNo AND cd.intPricingTypeId = 2	
			JOIN tblICCommodityUnitMeasure ium on ium.intCommodityId=cd.intCommodityId AND cd.intUnitMeasureId=ium.intUnitMeasureId 
			INNER JOIN tblSMCompanyLocation  cl on cl.intCompanyLocationId=cd.intCompanyLocationId
			WHERE cd.intCommodityId = @intCommodityId 
			AND cl.intCompanyLocationId  = case when isnull(@intLocationId,0)=0 then cl.intCompanyLocationId else @intLocationId end

INSERT INTO @Final(intSeqId,strCommodityCode,strType,dblTotal,intCommodityId,intFromCommodityUnitMeasureId)

SELECT 15 AS intSeqId,@strDescription
		,'Company Titled Stock' AS [strType]
		,ISNULL(invQty, 0) - -Case when (select top 1 ysnIncludeInTransitInCompanyTitled from tblRKCompanyPreference)=1 then  isnull(ReserveQty,0) else 0 end +
		  (isnull(CollateralPurchases, 0) - isnull(CollateralSale, 0)) +
		 CASE WHEN (SELECT TOP 1 ysnIncludeOffsiteInventoryInCompanyTitled from tblRKCompanyPreference)=1 then isnull(OffSite,0) else 0 end +  
		CASE WHEN (SELECT TOP 1 ysnIncludeDPPurchasesInCompanyTitled from tblRKCompanyPreference)=1 then isnull(DP,0) else 0 end +  
		isnull(SlsBasisDeliveries ,0)
		 AS dblTotal,@intCommodityId,@intCommodityUnitMeasureId
	FROM (
		SELECT isnull((select sum(dblUnitOnHand) from (
					SELECT dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId,@intCommodityUnitMeasureId,isnull(it1.dblUnitOnHand,0)) dblUnitOnHand
					FROM tblICItem i
					INNER JOIN tblICItemStock it1 ON it1.intItemId = i.intItemId
					INNER JOIN tblICItemLocation il ON il.intItemLocationId = it1.intItemLocationId
					JOIN tblICItemUOM iuom on i.intItemId=iuom.intItemId and ysnStockUnit=1
					JOIN tblICCommodityUnitMeasure ium on ium.intCommodityId=i.intCommodityId AND iuom.intUnitMeasureId=ium.intUnitMeasureId 
					WHERE i.intCommodityId = @intCommodityId
					AND il.intLocationId  = case when isnull(@intLocationId,0)=0 then il.intLocationId else @intLocationId end							
					)t), 0) AS invQty
			,isnull((select sum(dblQty) from (
					SELECT 
					dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId,@intCommodityUnitMeasureId,isnull(sr1.dblQty,0)) dblQty
					FROM tblICItem i
					INNER JOIN tblICItemStock it1 ON it1.intItemId = i.intItemId
					INNER JOIN tblICStockReservation sr1 ON it1.intItemId = sr1.intItemId
					JOIN tblICItemUOM iuom on i.intItemId=iuom.intItemId and ysnStockUnit=1
					JOIN tblICCommodityUnitMeasure ium on ium.intCommodityId=i.intCommodityId AND iuom.intUnitMeasureId=ium.intUnitMeasureId 
					INNER JOIN tblICItemLocation il ON il.intItemLocationId = it1.intItemLocationId
					WHERE i.intCommodityId = @intCommodityId
					AND il.intLocationId  = case when isnull(@intLocationId,0)=0 then il.intLocationId else @intLocationId end							
					)t), 0) AS ReserveQty
			--,isnull((select sum(Balance) Balance from (
			--		SELECT dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId,@intCommodityUnitMeasureId,isnull(Balance,0)) Balance
			--		FROM vyuGRGetStorageDetail
			--		WHERE (strOwnedPhysicalStock = 'Company'OR ysnDPOwnedType = 1)
			--			AND intCommodityId = @intCommodityId
			--			AND intCompanyLocationId = case when isnull(@intLocationId,0)=0 then intCompanyLocationId else @intLocationId end	
			--		)t), 0) dblBalance
			,(select sum(dblRemainingQuantity) from (SELECT 
				dbo.fnCTConvertQuantityToTargetCommodityUOM(ium.intCommodityUnitMeasureId,@intCommodityUnitMeasureId,isnull((dblRemainingQuantity),0)) dblRemainingQuantity
			   FROM tblRKCollateral c
				JOIN tblICCommodity co on co.intCommodityId=c.intCommodityId
				JOIN tblICCommodityUnitMeasure ium on ium.intCommodityId=c.intCommodityId AND c.intUnitMeasureId=ium.intUnitMeasureId 
				LEFT JOIN vyuCTContractDetailView ch on c.intContractHeaderId=ch.intContractHeaderId
				JOIN tblSMCompanyLocation cl on cl.intCompanyLocationId=c.intLocationId
				WHERE strType = 'Sale' AND c.intCommodityId = @intCommodityId 
				AND c.intLocationId = case when isnull(@intLocationId,0)=0 then c.intLocationId  else @intLocationId end)t) AS CollateralSale
			,(select sum(dblRemainingQuantity) from (SELECT 
				dbo.fnCTConvertQuantityToTargetCommodityUOM(ium.intCommodityUnitMeasureId,@intCommodityUnitMeasureId,isnull((dblRemainingQuantity),0)) dblRemainingQuantity
			   FROM tblRKCollateral c
				JOIN tblICCommodity co on co.intCommodityId=c.intCommodityId
				JOIN tblICCommodityUnitMeasure ium on ium.intCommodityId=c.intCommodityId AND c.intUnitMeasureId=ium.intUnitMeasureId 
				LEFT JOIN vyuCTContractDetailView ch on c.intContractHeaderId=ch.intContractHeaderId
				JOIN tblSMCompanyLocation cl on cl.intCompanyLocationId=c.intLocationId
				WHERE strType = 'Purchase' AND c.intCommodityId = @intCommodityId 
				AND c.intLocationId = case when isnull(@intLocationId,0)=0 then c.intLocationId  else @intLocationId end)t)   AS CollateralPurchases
				,(	select sum(dblTotal) dblTotal from (SELECT 
					dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId,@intCommodityUnitMeasureId,(Balance)) dblTotal
					FROM vyuGRGetStorageDetail CH
					WHERE ysnCustomerStorage = 1
						AND strOwnedPhysicalStock = 'Company'
						AND CH.intCommodityId  = @intCommodityId
						AND CH.intCompanyLocationId= case when isnull(@intLocationId,0)=0 then CH.intCompanyLocationId else @intLocationId end						
					)t) AS OffSite
					,(SELECT sum(isnull(SlsBasisDeliveries,0)) from( 
					 SELECT dbo.fnCTConvertQuantityToTargetCommodityUOM(ium.intCommodityUnitMeasureId,@intCommodityUnitMeasureId,isnull(ri.dblQuantity,0)) SlsBasisDeliveries
					 FROM tblICInventoryShipment r  
					 INNER JOIN tblICInventoryShipmentItem ri ON r.intInventoryShipmentId = ri.intInventoryShipmentId  
					 INNER JOIN vyuCTContractDetailView cd ON cd.intContractDetailId = ri.intLineNo AND cd.intPricingTypeId = 2 AND ri.intOrderId = 1  
					 JOIN tblICCommodityUnitMeasure ium on ium.intCommodityId=cd.intCommodityId 
					 WHERE cd.intCommodityId = @intCommodityId)t) as SlsBasisDeliveries

				,(select sum(dblTotal) dblTotal from (
					SELECT 
					dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId,@intCommodityUnitMeasureId,(isnull(Balance,0))) dblTotal
					FROM vyuGRGetStorageDetail ch
					WHERE ch.intCommodityId  = @intCommodityId
						AND ysnDPOwnedType = 1
						AND ch.intCompanyLocationId= case when isnull(@intLocationId,0)=0 then ch.intCompanyLocationId else @intLocationId end
					)t) AS DP

		) t
		
DECLARE @intUnitMeasureId int
DECLARE @strUnitMeasure nvarchar(50)
SELECT TOP 1 @intUnitMeasureId = intUnitMeasureId FROM tblRKCompanyPreference
select @strUnitMeasure=strUnitMeasure from tblICUnitMeasure where intUnitMeasureId=@intUnitMeasureId
INSERT INTO @FinalTable (intSeqId, strCommodityCode ,strType ,dblTotal ,strUnitMeasure, intCollateralId,strLocationName,strCustomer,
				intReceiptNo,intContractHeaderId,strContractNumber ,dtmOpenDate,dblOriginalQuantity ,dblRemainingQuantity ,intCommodityId,
				strCustomerReference ,strDistributionOption ,strDPAReceiptNo,dblDiscDue ,dblStorageDue ,dtmLastStorageAccrueDate ,strScheduleId ,strTicket ,
				dtmDeliveryDate ,dtmTicketDateTime,strItemNo)

SELECT	intSeqId, strCommodityCode ,strType ,
			    Convert(decimal(24,10),dbo.fnCTConvertQuantityToTargetCommodityUOM(cuc.intCommodityUnitMeasureId,
		case when isnull(@intUnitMeasureId,0) = 0 then cuc.intCommodityUnitMeasureId else cuc1.intCommodityUnitMeasureId end,dblTotal)) dblTotal,
			@strUnitMeasure as strUnitMeasure, intCollateralId,strLocationName,strCustomer,
		intReceiptNo,intContractHeaderId,strContractNumber ,dtmOpenDate,dblOriginalQuantity ,dblRemainingQuantity ,t.intCommodityId,
		strCustomerReference ,strDistributionOption ,strDPAReceiptNo ,
		dblDiscDue ,dblStorageDue ,	dtmLastStorageAccrueDate ,strScheduleId ,strTicket ,
		dtmDeliveryDate ,dtmTicketDateTime,strItemNo  
FROM @Final  t
	JOIN tblICCommodityUnitMeasure cuc on t.intCommodityId=cuc.intCommodityId and cuc.ysnDefault=1 
	LEFT JOIN tblICCommodityUnitMeasure cuc1 on t.intCommodityId=cuc1.intCommodityId and @intUnitMeasureId=cuc1.intUnitMeasureId
	WHERE t.intCommodityId= @intCommodityId	
END

SELECT @mRowNumber = MIN(intCommodityIdentity)	FROM @Commodity	WHERE intCommodityIdentity > @mRowNumber
END
END


SELECT intRow,intSeqId, strCommodityCode ,strType ,dblTotal ,strUnitMeasure, intCollateralId,strLocationName,strCustomer,
					intReceiptNo,intContractHeaderId,strContractNumber ,dtmOpenDate,dblOriginalQuantity ,dblRemainingQuantity ,intCommodityId,
					strCustomerReference ,strDistributionOption ,strDPAReceiptNo,dblDiscDue ,dblStorageDue ,dtmLastStorageAccrueDate ,strScheduleId ,strTicket ,
					dtmDeliveryDate ,dtmTicketDateTime,strItemNo			
FROM @FinalTable
 ORDER BY strCommodityCode,intSeqId ASC