CREATE PROCEDURE [dbo].[uspRKDPRInvDailyPositionDetail] 
	 @intCommodityId nvarchar(max)  
	,@intLocationId int = NULL
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
		SELECT @intCommodityUnitMeasureId=intCommodityUnitMeasureId from tblICCommodityUnitMeasure where intCommodityId=@intCommodityId
if @intCommodityId >= 0
BEGIN
INSERT INTO @Final(intSeqId,strCommodityCode,strType,dblTotal,strLocationName,strItemNo,intCommodityId,intFromCommodityUnitMeasureId)

				SELECT 1 AS intSeqId,@strDescription,'In-House' AS [strType],(isnull(it1.dblUnitOnHand, 0)), ic.strLocationName,i.strItemNo,@intCommodityId,@intCommodityUnitMeasureId	
				FROM tblICItem i
				INNER JOIN tblICInventoryReceiptItem ii on ii.intItemId = i.intItemId
				INNER JOIN tblICInventoryReceipt ir on ir.intInventoryReceiptId=ii.intInventoryReceiptId
				INNER JOIN tblICItemStock it1 ON it1.intItemId = i.intItemId
				INNER JOIN tblICItemLocation il ON il.intItemLocationId = it1.intItemLocationId
				INNER JOIN tblSMCompanyLocation ic on ic.intCompanyLocationId = il.intLocationId
				WHERE i.intCommodityId =@intCommodityId AND il.intLocationId= case when isnull(0,0)=0 then il.intLocationId else 0 end
				UNION
				SELECT 1 AS intSeqId,@strDescription,'In-House' AS [strType],-isnull(sr1.dblQty, 0), ic.strLocationName,i.strItemNo,@intCommodityId,@intCommodityUnitMeasureId
				FROM tblICItem i
				INNER JOIN tblICItemStock it1 ON it1.intItemId = i.intItemId
				INNER JOIN tblICStockReservation sr1 ON it1.intItemId = sr1.intItemId
				INNER JOIN tblICItemLocation il ON il.intItemLocationId = it1.intItemLocationId
				INNER JOIN tblSMCompanyLocation ic on ic.intCompanyLocationId = il.intLocationId
				WHERE i.intCommodityId = @intCommodityId	AND il.intLocationId= case when isnull(0,0)=0 then il.intLocationId else 0 end
				UNION
				SELECT 1 AS intSeqId,@strDescription,'In-House' AS [strType],(ISNULL(Balance,0)),strLocationName,strItemNo,@intCommodityId,@intCommodityUnitMeasureId
				FROM vyuGRGetStorageDetail 
				WHERE ysnCustomerStorage <> 1 AND intCommodityId = @intCommodityId AND intCompanyLocationId= case when isnull(0,0)=0 then intCompanyLocationId else 0 end

INSERT INTO @Final (intSeqId,strCommodityCode,strType,dblTotal,intCommodityId ,strLocationName ,dtmDeliveryDate ,strTicket ,
					strCustomerReference,strDPAReceiptNo ,dblDiscDue ,dblStorageDue , dtmLastStorageAccrueDate ,strScheduleId,intFromCommodityUnitMeasureId)
		SELECT 2,@strDescription,'Off-Site' strType,ISNULL(Balance, 0) dblTotal,intCommodityId,Loc AS strLocation ,[Delivery Date] AS dtmDeliveryDate ,
				Ticket strTicket ,Customer as strCustomerReference ,Receipt AS strDPAReceiptNo ,[Disc Due] AS dblDiscDue ,
				[Storage Due] AS dblStorageDue ,dtmLastStorageAccrueDate ,strScheduleId,@intCommodityUnitMeasureId  
		FROM vyuGRGetStorageOffSiteDetail  
		WHERE ysnReceiptedStorage = 1 AND ysnExternal = 1 AND strOwnedPhysicalStock = 'Customer' AND intCommodityId = @intCommodityId 
		AND intCompanyLocationId= case when isnull(@intLocationId,0)=0 then intCompanyLocationId else @intLocationId end

INSERT INTO @Final(intSeqId,strCommodityCode,strType,dblTotal,strLocationName,strItemNo,intCommodityId,intFromCommodityUnitMeasureId)
	SELECT 3 AS intSeqId,@strDescription,'Purchase In-Transit' AS [strType],ISNULL(ReserveQty, 0) AS dblTotal,strLocationName,strItemNo,@intCommodityId,@intCommodityUnitMeasureId
	FROM (
				SELECT (isnull(sr1.dblQty, 0)) as ReserveQty,ic.strLocationName,i.strItemNo
				FROM tblICItem i
				INNER JOIN tblICItemStock it1 ON it1.intItemId = i.intItemId
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
		SELECT (isnull(sr1.dblQty, 0)) as ReserveQty,ic.strLocationName,i.strItemNo
				FROM tblICItem i
				INNER JOIN tblICItemStock it1 ON it1.intItemId = i.intItemId
				INNER JOIN tblICStockReservation sr1 ON it1.intItemId = sr1.intItemId
				INNER JOIN tblICItemLocation il ON il.intItemLocationId = it1.intItemLocationId
				INNER JOIN tblSMCompanyLocation ic on ic.intCompanyLocationId = il.intLocationId
				WHERE i.intCommodityId = @intCommodityId
			    AND il.intLocationId= case when isnull(@intLocationId,0)=0 then il.intLocationId else @intLocationId end	
		) t

INSERT INTO @Final (intSeqId,strCommodityCode,strType,dblTotal,intCommodityId,strLocationName ,dtmDeliveryDate ,strTicket ,strCustomerReference,strDPAReceiptNo ,	dblDiscDue ,
					  dblStorageDue ,	dtmLastStorageAccrueDate ,strScheduleId,intFromCommodityUnitMeasureId)
		SELECT 5,@strDescription,[Storage Type] strType,ISNULL(Balance, 0) dblTotal,intCommodityId,Loc AS strLocation ,[Delivery Date] AS dtmDeliveryDate ,Ticket strTicket  
		,Customer as strCustomerReference,Receipt AS strDPAReceiptNo ,[Disc Due] AS dblDiscDue ,[Storage Due] AS dblStorageDue  
		,dtmLastStorageAccrueDate ,strScheduleId ,@intCommodityUnitMeasureId   
		FROM vyuGRGetStorageDetail  
		WHERE intCommodityId = @intCommodityId AND ysnDPOwnedType = 0  AND ysnReceiptedStorage = 0  
		AND	intCompanyLocationId  = case when isnull(@intLocationId,0)=0 then intCompanyLocationId else @intLocationId end

INSERT INTO @Final(intSeqId,strCommodityCode,strType,dblTotal,strLocationName,strItemNo,intCommodityId,intFromCommodityUnitMeasureId)
	SELECT 7 AS intSeqId,@strDescription
		,'Total Non-Receipted' [Storage Type]
		,(Balance) dblTotal,strLocationName,strItemNo, @intCommodityId,@intCommodityUnitMeasureId
	FROM vyuGRGetStorageDetail
	WHERE ysnReceiptedStorage = 0
		AND strOwnedPhysicalStock = 'Customer'
		AND intCommodityId = @intCommodityId
		AND intCompanyLocationId= case when isnull(@intLocationId,0)=0 then intCompanyLocationId else @intLocationId end
	
--Collatral Sale
INSERT INTO @Final(intSeqId,strCommodityCode,strType,dblTotal,intCollateralId,strLocationName,strCustomer,intReceiptNo,intContractHeaderId,strContractNumber,dtmOpenDate,dblOriginalQuantity,dblRemainingQuantity,intCommodityId,intFromCommodityUnitMeasureId)
		SELECT 8, @strDescription,'Collateral Receipts - Sales' ,isnull(dblRemainingQuantity,0), c.intCollateralId,cl.strLocationName,ch.strEntityName,c.intReceiptNo,ch.intContractHeaderId,
		ch.strContractNumber +'-' +Convert(nvarchar,intContractSeq) strContractNumber,
		c.dtmOpenDate,
		isnull(c.dblOriginalQuantity,0) dblOriginalQuantity,c.dblRemainingQuantity,@intCommodityId,ch.intUnitMeasureId	
		FROM tblRKCollateral c
		JOIN tblICCommodity co on co.intCommodityId=c.intCommodityId
		LEFT JOIN vyuCTContractDetailView ch on c.intContractHeaderId=ch.intContractHeaderId
		JOIN tblSMCompanyLocation cl on cl.intCompanyLocationId=c.intLocationId
		WHERE strType = 'Sale' AND c.intCommodityId = @intCommodityId 
		AND c.intLocationId = case when isnull(@intLocationId,0)=0 then c.intLocationId  else @intLocationId end
-- Collatral Purchase
INSERT INTO @Final(intSeqId,strCommodityCode,strType,dblTotal,intCollateralId,strLocationName,strCustomer,intReceiptNo,intContractHeaderId,strContractNumber,dtmOpenDate,dblOriginalQuantity,dblRemainingQuantity,intCommodityId,intFromCommodityUnitMeasureId)
		SELECT 9, @strDescription,'Collateral Receipts - Purchase' ,isnull(dblRemainingQuantity,0), c.intCollateralId,cl.strLocationName,ch.strEntityName,c.intReceiptNo,ch.intContractHeaderId,
		ch.strContractNumber +'-' +Convert(nvarchar,intContractSeq) strContractNumber,c.dtmOpenDate,
		isnull(c.dblOriginalQuantity,0) dblOriginalQuantity,c.dblRemainingQuantity,@intCommodityId,ch.intUnitMeasureId	
		FROM tblRKCollateral c
		JOIN tblICCommodity co on co.intCommodityId=c.intCommodityId
		LEFT JOIN vyuCTContractDetailView ch on c.intContractHeaderId=ch.intContractHeaderId
		JOIN tblSMCompanyLocation cl on cl.intCompanyLocationId=c.intLocationId
		WHERE strType = 'Purchase' AND c.intCommodityId = @intCommodityId 
		AND c.intLocationId = case when isnull(@intLocationId,0)=0 then c.intLocationId  else @intLocationId end

INSERT INTO @Final (intSeqId,strCommodityCode,strType,dblTotal,intCommodityId,strLocationName ,dtmDeliveryDate ,strTicket ,strCustomerReference,strDPAReceiptNo ,	dblDiscDue ,
					  dblStorageDue ,	dtmLastStorageAccrueDate ,strScheduleId,intFromCommodityUnitMeasureId)
			SELECT 10,@strDescription,[Storage Type] strType,ISNULL(Balance, 0) dblTotal,intCommodityId  ,Loc AS strLocation ,[Delivery Date] AS dtmDeliveryDate ,Ticket strTicket  
			,Customer as strCustomerReference ,Receipt AS strDPAReceiptNo ,[Disc Due] AS dblDiscDue ,[Storage Due] AS dblStorageDue  
			,dtmLastStorageAccrueDate ,strScheduleId,@intCommodityUnitMeasureId  
			FROM vyuGRGetStorageOffSiteDetail  WHERE ysnReceiptedStorage = 1 AND ysnExternal <> 1 AND strOwnedPhysicalStock = 'Customer'  
			AND intCommodityId = @intCommodityId  AND intCompanyLocationId  = case when isnull(@intLocationId,0)=0 then intCompanyLocationId else @intLocationId end 

INSERT INTO @Final(intSeqId,strCommodityCode,strType,dblTotal,intCommodityId,intFromCommodityUnitMeasureId)
SELECT 11 AS intSeqId,@strDescription
		,'Total Receipted' AS [strType]
		,isnull(dblTotal1, 0) + (isnull(CollateralSale, 0) - isnull(CollateralPurchases, 0)) dblTotal,@intCommodityId,@intCommodityUnitMeasureId
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
		,(SELECT isnull(SUM(dblOriginalQuantity), 0) - isnull(sum(dblAdjustmentAmount), 0) CollateralPurchases
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

INSERT INTO @Final (intSeqId,strCommodityCode,strType,dblTotal,intCommodityId,strLocationName ,dtmDeliveryDate ,strTicket ,strCustomerReference,strDPAReceiptNo ,	dblDiscDue ,
					  dblStorageDue ,	dtmLastStorageAccrueDate ,strScheduleId,intFromCommodityUnitMeasureId)
			SELECT 12,@strDescription,[Storage Type] strType,ISNULL(Balance, 0) dblTotal,intCommodityId  ,Loc AS strLocation ,[Delivery Date] AS dtmDeliveryDate ,Ticket strTicket  
			,Customer as strCustomerReference ,Receipt AS strDPAReceiptNo ,[Disc Due] AS dblDiscDue ,[Storage Due] AS dblStorageDue  
			,dtmLastStorageAccrueDate ,strScheduleId,@intCommodityUnitMeasureId  
			FROM vyuGRGetStorageOffSiteDetail  WHERE  ysnDPOwnedType = 1  
			AND intCommodityId = @intCommodityId  AND intCompanyLocationId  = case when isnull(@intLocationId,0)=0 then intCompanyLocationId else @intLocationId end 

INSERT INTO @Final (intSeqId,strCommodityCode,strType,dblTotal,intCommodityId,strLocationName,strTicket,dtmTicketDateTime,strCustomerReference, strDistributionOption,intFromCommodityUnitMeasureId)
			SELECT 13,@strDescription,'Pur Basis Deliveries' strType,PLDetail.dblLotPickedQty AS dblTotal,intCommodityId,cl.strLocationName,convert(nvarchar,CT.strContractNumber)+'/'+convert(nvarchar,CT.intContractSeq) strTicket,CT.dtmContractDate as dtmTicketDateTime ,
			CT.strCustomerContract as strCustomerReference, 'CNT' as strDistributionOption,@intCommodityUnitMeasureId
			FROM tblLGDeliveryPickDetail Del
			INNER JOIN tblLGPickLotDetail PLDetail ON PLDetail.intPickLotDetailId = Del.intPickLotDetailId
			INNER JOIN vyuLGPickOpenInventoryLots Lots ON Lots.intLotId = PLDetail.intLotId
			INNER JOIN vyuCTContractDetailView CT ON CT.intContractDetailId = Lots.intContractDetailId
			INNER JOIN tblSMCompanyLocation  cl on cl.intCompanyLocationId=CT.intCompanyLocationId
			WHERE CT.intPricingTypeId = 2 AND CT.intCommodityId = @intCommodityId 
			AND CT.intCompanyLocationId  = case when isnull(@intLocationId,0)=0 then CT.intCompanyLocationId   else @intLocationId end
			
			UNION ALL
			
			SELECT 13,@strDescription,'Pur Basis Deliveries' strType,isnull(ri.dblReceived, 0) AS dblTotal,st.intCommodityId,cl.strLocationName,strTicketNumber strTicket,st.dtmTicketDateTime,strCustomerReference,
					strDistributionOption,@intCommodityUnitMeasureId
			FROM tblICInventoryReceipt r
			INNER JOIN tblICInventoryReceiptItem ri ON r.intInventoryReceiptId = ri.intInventoryReceiptId AND r.strReceiptType = 'Purchase Contract'
			INNER JOIN tblSCTicket st ON st.intTicketId = ri.intSourceId  AND strDistributionOption IN ('CNT')
			INNER JOIN tblCTContractDetail cd ON cd.intContractDetailId = ri.intLineNo AND cd.intPricingTypeId = 2
			INNER JOIN tblCTContractHeader ch ON ch.intContractHeaderId = cd.intContractHeaderId
			INNER JOIN tblSMCompanyLocation  cl on cl.intCompanyLocationId=st.intProcessingLocationId 
			WHERE ch.intCommodityId = @intCommodityId 
			AND st.intProcessingLocationId  = case when isnull(@intLocationId,0)=0 then st.intProcessingLocationId else @intLocationId end

INSERT INTO @Final (intSeqId,strCommodityCode,strType,dblTotal,intCommodityId,strLocationName,strTicket,dtmTicketDateTime,strCustomerReference, strDistributionOption,intFromCommodityUnitMeasureId)
			SELECT 13,@strDescription,'Sls Basis Deliveries' strType,ri.dblQuantity AS dblTotal,intCommodityId,cl.strLocationName,convert(nvarchar,ch.strContractNumber)+'/'+convert(nvarchar,cd.intContractSeq) strTicketNumber,
			ch.dtmContractDate as dtmTicketDateTime ,
			ch.strCustomerContract as strCustomerReference, 'CNT' as strDistributionOption,intUnitMeasureId
			FROM tblICInventoryShipment r
			INNER JOIN tblICInventoryShipmentItem ri ON r.intInventoryShipmentId = ri.intInventoryShipmentId
			INNER JOIN tblCTContractDetail cd ON cd.intContractDetailId = ri.intLineNo AND cd.intPricingTypeId = 2	
			INNER JOIN tblCTContractHeader ch ON ch.intContractHeaderId = cd.intContractHeaderId
			INNER JOIN tblSMCompanyLocation  cl on cl.intCompanyLocationId=cd.intCompanyLocationId
			WHERE ch.intCommodityId = @intCommodityId 
			AND cl.intCompanyLocationId  = case when isnull(@intLocationId,0)=0 then cl.intCompanyLocationId else @intLocationId end

INSERT INTO @Final(intSeqId,strCommodityCode,strType,dblTotal,intCommodityId,intFromCommodityUnitMeasureId)

SELECT 15 AS intSeqId,@strDescription
		,'Company Titled Stock' AS [strType]
		,ISNULL(invQty, 0) - ISNULL(ReserveQty, 0) + isnull(dblBalance, 0) + (isnull(CollateralSale, 0) - isnull(CollateralPurchases, 0)) AS dblTotal,@intCommodityId,@intCommodityUnitMeasureId
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

DECLARE @intUnitMeasureId int=null
DECLARE @intFromCommodityUnitMeasureId int=null
DECLARE @intToCommodityUnitMeasureId int=null
DECLARE @strUnitMeasure nvarchar(50)=null

SELECT TOP 1 @intUnitMeasureId = intUnitMeasureId FROM tblRKCompanyPreference

IF ISNULL(@intUnitMeasureId,'') <> ''
BEGIN

	SELECT @intFromCommodityUnitMeasureId=cuc.intCommodityUnitMeasureId,@intToCommodityUnitMeasureId=cuc1.intCommodityUnitMeasureId 
	FROM tblICCommodity t
	JOIN tblICCommodityUnitMeasure cuc on t.intCommodityId=cuc.intCommodityId and cuc.ysnDefault=1 
	JOIN tblICCommodityUnitMeasure cuc1 on t.intCommodityId=cuc1.intCommodityId and @intUnitMeasureId=cuc1.intUnitMeasureId
	WHERE t.intCommodityId= @intCommodityId
	SELECT @strUnitMeasure=strUnitMeasure from tblICUnitMeasure where intUnitMeasureId=@intUnitMeasureId
END
ELSE
BEGIN

	SELECT @strUnitMeasure=c.strUnitMeasure, @intToCommodityUnitMeasureId=cuc.intCommodityUnitMeasureId FROM
	tblICCommodity t 
	JOIN tblICCommodityUnitMeasure cuc on t.intCommodityId=cuc.intCommodityId and cuc.ysnDefault=1
	JOIN tblICUnitMeasure c on c.intUnitMeasureId=cuc.intUnitMeasureId 	
	WHERE t.intCommodityId= @intCommodityId

END
UPDATE @Final SET intFromCommodityUnitMeasureId=@intFromCommodityUnitMeasureId,intToCommodityUnitMeasureId=@intToCommodityUnitMeasureId,strUnitMeasure=@strUnitMeasure 
WHERE intCommodityId= @intCommodityId

IF ISNULL(@intUnitMeasureId,'') <> ''
	BEGIN
			
	INSERT INTO @FinalTable (intSeqId, strCommodityCode ,strType ,dblTotal ,strUnitMeasure, intCollateralId,strLocationName,strCustomer,
					intReceiptNo,intContractHeaderId,strContractNumber ,dtmOpenDate,dblOriginalQuantity ,dblRemainingQuantity ,intCommodityId,
					strCustomerReference ,strDistributionOption ,strDPAReceiptNo,dblDiscDue ,dblStorageDue ,dtmLastStorageAccrueDate ,strScheduleId ,strTicket ,
					dtmDeliveryDate ,dtmTicketDateTime,strItemNo  )

			SELECT	intSeqId, strCommodityCode ,strType ,
					Convert(decimal(24,10),dbo.fnCTConvertQuantityToTargetCommodityUOM(@intFromCommodityUnitMeasureId,@intToCommodityUnitMeasureId,dblTotal)) dblTotal ,
					 @strUnitMeasure as strUnitMeasure, intCollateralId,strLocationName,strCustomer,
					intReceiptNo,intContractHeaderId,strContractNumber ,dtmOpenDate,dblOriginalQuantity ,dblRemainingQuantity ,intCommodityId,
					strCustomerReference ,strDistributionOption ,strDPAReceiptNo ,
					dblDiscDue ,dblStorageDue ,	dtmLastStorageAccrueDate ,strScheduleId ,strTicket ,
					dtmDeliveryDate ,dtmTicketDateTime,strItemNo  
			FROM @Final WHERE intCommodityId= @intCommodityId 
	END
	ELSE
	BEGIN

		INSERT INTO @FinalTable (intSeqId, strCommodityCode ,strType ,dblTotal ,strUnitMeasure, intCollateralId,strLocationName,strCustomer,
					intReceiptNo,intContractHeaderId,strContractNumber ,dtmOpenDate,dblOriginalQuantity ,dblRemainingQuantity ,intCommodityId,
					strCustomerReference ,strDistributionOption ,strDPAReceiptNo,dblDiscDue ,dblStorageDue ,dtmLastStorageAccrueDate ,strScheduleId ,strTicket ,
					dtmDeliveryDate ,dtmTicketDateTime,strItemNo)

			SELECT	intSeqId, strCommodityCode ,strType ,Convert(decimal(24,10),dblTotal) dblTotal ,
					 @strUnitMeasure as strUnitMeasure, intCollateralId,strLocationName,strCustomer,
					intReceiptNo,intContractHeaderId,strContractNumber ,dtmOpenDate,dblOriginalQuantity ,dblRemainingQuantity ,intCommodityId,
					strCustomerReference ,strDistributionOption ,strDPAReceiptNo ,
					dblDiscDue ,dblStorageDue ,	dtmLastStorageAccrueDate ,strScheduleId ,strTicket ,
					dtmDeliveryDate ,dtmTicketDateTime,strItemNo  
			FROM @Final WHERE intCommodityId= @intCommodityId --AND isnull(dblTotal,0) <> 0
	END

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