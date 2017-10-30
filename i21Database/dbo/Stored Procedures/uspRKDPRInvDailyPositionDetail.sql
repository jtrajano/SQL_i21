﻿CREATE PROCEDURE [dbo].[uspRKDPRInvDailyPositionDetail] 
	 @intCommodityId nvarchar(max)  
	,@intLocationId int = NULL	
	,@intVendorId int = null
	,@strPurchaseSales nvarchar(50) = NULL
	,@strPositionIncludes nvarchar(100) = NULL
as


BEGIN
	 DECLARE @Commodity AS TABLE 
	 (
		intCommodityIdentity int IDENTITY(1,1) PRIMARY KEY , 
		intCommodity  INT
	 )
	 INSERT INTO @Commodity(intCommodity)
	 SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCommodityId, ',')  

if isnull(@strPurchaseSales,'') <> ''
BEGIN
if @strPurchaseSales='Purchase'
BEGIN
select @strPurchaseSales='Sales'
END
ELSE
BEGIN
SELECT @strPurchaseSales='Purchase'
END
END

DECLARE @Final AS TABLE (
					intRow int IDENTITY(1,1) PRIMARY KEY , 
					intSeqId int, 
					strSeqHeader nvarchar(100),
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
					[Storage Due] DECIMAL(24,10),	
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
					,strTruckName  nvarchar(100)
					,strDriverName  nvarchar(100)
					,intCompanyLocationId int
)

DECLARE @FinalTable AS TABLE (
					intRow int IDENTITY(1,1) PRIMARY KEY , 
					intSeqId int, 
					strSeqHeader nvarchar(100),
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
					[Storage Due] DECIMAL(24,10),	
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
					,strTruckName  nvarchar(100)
					,strDriverName  nvarchar(100)
					,intCompanyLocationId int
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
if isnull(@intVendorId,0) = 0
BEGIN

	INSERT INTO @Final(intSeqId,strSeqHeader,strCommodityCode,strType,dblTotal,strLocationName,strItemNo,intCommodityId,intFromCommodityUnitMeasureId,strTruckName,strDriverName,[Storage Due],intCompanyLocationId)
	SELECT intSeqId,strSeqHeader,strCommodityCode,[strType],dblTotal,strLocationName,strItemNo,intCommodityId,intFromCommodityUnitMeasureId,strTruckName,strDriverName
			,[Storage Due],intLocationId 
	FROM(	SELECT distinct 1 AS intSeqId,'In-House' strSeqHeader,@strDescription strCommodityCode,'Receipt' AS [strType],
					s.dblOnHand dblTotal
					,s.strLocationName,s.strItemNo,@intCommodityId intCommodityId,@intCommodityUnitMeasureId intFromCommodityUnitMeasureId,'' strTruckName,'' strDriverName
					,null [Storage Due],s.intLocationId intLocationId
					FROM vyuICGetItemStockUOM s  				  
					WHERE s.intCommodityId = @intCommodityId AND s.intLocationId= CASE WHEN ISNULL(@intLocationId,0)=0 then s.intLocationId else @intLocationId end												 
			UNION
				SELECT DISTINCT 1 AS intSeqId,'In-House',@strDescription,[Storage Type] AS [strType],
				dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId,@intCommodityUnitMeasureId,isnull(Balance,0))
				,strLocationName,strItemNo,@intCommodityId intCommodityId,@intCommodityUnitMeasureId intFromCommodityUnitMeasureId,'' strTruckName,'' strDriverName,[Storage Due]
				,intCompanyLocationId intLocationId
				FROM vyuGRGetStorageDetail s
				WHERE 
				intCommodityId = @intCommodityId AND intCompanyLocationId= case when isnull(@intLocationId,0)=0 then intCompanyLocationId else @intLocationId end
			UNION
				SELECT DISTINCT 1,'In-House',@strDescription,'On-Hold' strType,
				dbo.fnCTConvertQuantityToTargetCommodityUOM(ium.intCommodityUnitMeasureId,@intCommodityUnitMeasureId,isnull(st.dblNetUnits, 0))  AS dblTotal,
				cl.strLocationName,i1.strItemNo,@intCommodityId,@intCommodityUnitMeasureId,strTruckName,strDriverName,null [Storage Due], st.intProcessingLocationId intLocationId
				FROM tblSCTicket st
				JOIN tblSMCompanyLocation  cl on cl.intCompanyLocationId=st.intProcessingLocationId and st.strDistributionOption='HLD'
				JOIN tblICItem i1 on i1.intItemId=st.intItemId
				JOIN tblICItemUOM iuom on i1.intItemId=iuom.intItemId and ysnStockUnit=1
				JOIN tblICCommodityUnitMeasure ium on ium.intCommodityId=i1.intCommodityId AND iuom.intUnitMeasureId=ium.intUnitMeasureId 
				WHERE st.intCommodityId  = @intCommodityId
					  AND st.intProcessingLocationId  = case when isnull(@intLocationId,0)=0 then st.intProcessingLocationId else @intLocationId end
				)t 	WHERE intLocationId IN (
					SELECT intCompanyLocationId FROM tblSMCompanyLocation
					WHERE isnull(ysnLicensed, 0) = CASE WHEN @strPositionIncludes = 'licensed storage' THEN 1 
									WHEN @strPositionIncludes = 'Non-licensed storage' THEN 0 
									ELSE isnull(ysnLicensed, 0) END
					) 

	INSERT INTO @Final (intSeqId,strSeqHeader,strCommodityCode,strType,dblTotal,intCommodityId ,strLocationName ,strItemNo,dtmDeliveryDate ,strTicket ,
					strCustomerReference,strDPAReceiptNo ,dblDiscDue ,[Storage Due] , dtmLastStorageAccrueDate ,strScheduleId,intFromCommodityUnitMeasureId,intCompanyLocationId)
		select 2,'Off-Site',@strDescription,'Off-Site',	dblTotal,intCommodityId,strLocation,strItemNo ,dtmDeliveryDate ,strTicket ,strCustomerReference ,strDPAReceiptNo,dblDiscDue,
		[Storage Due] ,dtmLastStorageAccrueDate,strScheduleId,@intCommodityUnitMeasureId intFromCommodityUnitMeasureId ,intCompanyLocationId 
		FROM 
		(SELECT dbo.fnCTConvertQuantityToTargetCommodityUOM(ium.intCommodityUnitMeasureId,@intCommodityUnitMeasureId,(Balance)) dblTotal,r.intCommodityId,Loc AS strLocation,i.strItemNo ,[Delivery Date] AS dtmDeliveryDate ,
				Ticket strTicket ,Customer as strCustomerReference ,Receipt AS strDPAReceiptNo ,[Disc Due] AS dblDiscDue ,
				[Storage Due] AS [Storage Due] ,dtmLastStorageAccrueDate ,strScheduleId,intCompanyLocationId  
		FROM vyuGRGetStorageOffSiteDetail r
		join tblICItem i on r.intItemId=i.intItemId
		JOIN tblICItemUOM iuom on i.intItemId=iuom.intItemId and ysnStockUnit=1 
		JOIN tblICCommodityUnitMeasure ium on ium.intCommodityId=i.intCommodityId AND iuom.intUnitMeasureId=ium.intUnitMeasureId 
		WHERE ysnReceiptedStorage = 1 AND ysnExternal = 1 AND strOwnedPhysicalStock = 'Customer' AND r.intCommodityId = @intCommodityId 
		AND intCompanyLocationId= case when isnull(@intLocationId,0)=0 then intCompanyLocationId else @intLocationId end
		) t where intCompanyLocationId IN (
				SELECT intCompanyLocationId FROM tblSMCompanyLocation
				WHERE isnull(ysnLicensed, 0) = CASE WHEN @strPositionIncludes = 'licensed storage' THEN 1 
								WHEN @strPositionIncludes = 'Non-licensed storage' THEN 0 
								ELSE isnull(ysnLicensed, 0) END
				)

	INSERT INTO @Final(intSeqId,strSeqHeader,strCommodityCode,strType,dblTotal,strLocationName,strItemNo,strContractNumber,intCommodityId,intFromCommodityUnitMeasureId)
	SELECT 3 AS intSeqId,'Purchase In-Transit',@strDescription,'Purchase In-Transit' AS [strType],
	dbo.fnCTConvertQuantityToTargetCommodityUOM(intUnitMeasureId,@intCommodityUnitMeasureId,ISNULL(ReserveQty, 0)) 
	 AS dblTotal,strLocationName,strItemNo,strContractNumber,@intCommodityId,@intCommodityUnitMeasureId
	FROM (
			SELECT i.intUnitMeasureId,			
			isnull(i.dblPurchaseContractShippedQty, 0) as ReserveQty,
			i.strLocationName,i.strItemNo,
			i.strContractNumber,intCompanyLocationId			 
			FROM vyuRKPurchaseIntransitView i
			WHERE i.intCommodityId = @intCommodityId
			AND i.intCompanyLocationId= case when isnull(@intLocationId,0)=0 then i.intCompanyLocationId else @intLocationId end					
		) t where intCompanyLocationId IN (
				SELECT intCompanyLocationId FROM tblSMCompanyLocation
				WHERE isnull(ysnLicensed, 0) = CASE WHEN @strPositionIncludes = 'licensed storage' THEN 1 
								WHEN @strPositionIncludes = 'Non-licensed storage' THEN 0 
								ELSE isnull(ysnLicensed, 0) END
				)

	INSERT INTO @Final(intSeqId,strSeqHeader,strCommodityCode,strType,dblTotal,strLocationName,strItemNo,strTicket,strCustomerReference,strContractNumber,intCommodityId,intFromCommodityUnitMeasureId,intCompanyLocationId)
	SELECT 4 AS intSeqId,'Sales In-Transit',@strDescription
		,'Sales In-Transit' AS [strType]
		,ISNULL(ReserveQty, 0) AS dblTotal,strLocationName,strItemName,strTicket,strCustomerReference,strContractNumber,@intCommodityId,@intCommodityUnitMeasureId,intCompanyLocationId
	FROM (
		SELECT dbo.fnCTConvertQuantityToTargetCommodityUOM(i.intUnitMeasureId,@intCommodityUnitMeasureId,isnull(i.dblBalanceToInvoice, 0)) as ReserveQty,
				i.strLocationName,i.strItemName,strContractNumber,strTicket,strCustomerReference,i.intCompanyLocationId
				FROM vyuRKGetSalesIntransitWOPickLot i
				WHERE i.intCommodityId = @intCommodityId
			    AND i.intCompanyLocationId= case when isnull(@intLocationId,0)=0 then i.intCompanyLocationId else @intLocationId end	
				)t WHERE intCompanyLocationId IN (
				SELECT intCompanyLocationId FROM tblSMCompanyLocation
				WHERE isnull(ysnLicensed, 0) = CASE WHEN @strPositionIncludes = 'licensed storage' THEN 1 
								WHEN @strPositionIncludes = 'Non-licensed storage' THEN 0 
								ELSE isnull(ysnLicensed, 0) END
				)

	INSERT INTO @Final (intSeqId,strSeqHeader,strCommodityCode,strType,dblTotal,intCommodityId,strLocationName ,strItemNo,dtmDeliveryDate ,strTicket ,strCustomerReference,strDPAReceiptNo ,	dblDiscDue ,
					  [Storage Due], dtmLastStorageAccrueDate ,strScheduleId,intFromCommodityUnitMeasureId,intCompanyLocationId)
		select 5,[Storage Type],@strDescription,strType,dblTotal,intCommodityId,strLocation,strItemNo,dtmDeliveryDate ,strTicket  
		,strCustomerReference,strDPAReceiptNo ,dblDiscDue ,[Storage Due]  
		,dtmLastStorageAccrueDate ,strScheduleId ,@intCommodityUnitMeasureId,intCompanyLocationId   from (
		SELECT [Storage Type],[Storage Type] strType,
		dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId,@intCommodityUnitMeasureId,ISNULL(Balance, 0)) dblTotal,
		r.intCommodityId,Loc AS strLocation ,r.strItemNo,[Delivery Date] AS dtmDeliveryDate ,Ticket strTicket  
		,Customer as strCustomerReference,Receipt AS strDPAReceiptNo ,[Disc Due] AS dblDiscDue ,[Storage Due] AS [Storage Due]  
		,dtmLastStorageAccrueDate ,strScheduleId ,intCompanyLocationId   
		FROM vyuGRGetStorageDetail  r
		WHERE r.intCommodityId = @intCommodityId AND ysnDPOwnedType = 0  AND ysnReceiptedStorage = 0  
		AND	intCompanyLocationId  = case when isnull(@intLocationId,0)=0 then intCompanyLocationId else @intLocationId end)t
				WHERE intCompanyLocationId IN (
				SELECT intCompanyLocationId FROM tblSMCompanyLocation
				WHERE isnull(ysnLicensed, 0) = CASE WHEN @strPositionIncludes = 'licensed storage' THEN 1 
								WHEN @strPositionIncludes = 'Non-licensed storage' THEN 0 
								ELSE isnull(ysnLicensed, 0) END
				) 

	INSERT INTO @Final(intSeqId,strSeqHeader,strCommodityCode,strType,dblTotal,strLocationName,strItemNo,intCommodityId,intFromCommodityUnitMeasureId,[Storage Due],intCompanyLocationId)
	select * from 
	(SELECT 7 AS intSeqId,'Total Non-Receipted' strSeqHeader,@strDescription strCommodityCode
		,'Total Non-Receipted' [Storage Type]
		,dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId,@intCommodityUnitMeasureId ,ISNULL(Balance, 0)) dblTotal,
		strLocationName,r.strItemNo, @intCommodityId intCommodityId,@intCommodityUnitMeasureId intCommodityUnitMeasureId
		,[Storage Due],intCompanyLocationId
	FROM vyuGRGetStorageDetail  r
	WHERE ysnReceiptedStorage = 0
		AND strOwnedPhysicalStock = 'Customer'
		AND r.intCommodityId = @intCommodityId
		AND intCompanyLocationId= case when isnull(@intLocationId,0)=0 then intCompanyLocationId else @intLocationId end)t	
				WHERE intCompanyLocationId  IN (
				SELECT intCompanyLocationId FROM tblSMCompanyLocation
				WHERE isnull(ysnLicensed, 0) = CASE WHEN @strPositionIncludes = 'licensed storage' THEN 1 
								WHEN @strPositionIncludes = 'Non-licensed storage' THEN 0 
								ELSE isnull(ysnLicensed, 0) END
				) 
--Collatral Sale
	INSERT INTO @Final(intSeqId,strSeqHeader,strCommodityCode,strType,dblTotal,intCollateralId,strLocationName,strItemNo,strCustomer,intReceiptNo,intContractHeaderId,strContractNumber,dtmOpenDate,dblOriginalQuantity,dblRemainingQuantity,intCommodityId,intFromCommodityUnitMeasureId,intCompanyLocationId)
		select * from (
		SELECT 8 intSeqId,'Collateral Receipts - Sales' strSeqHeader, @strDescription strCommodityCode,'Collateral Receipts - Sales' strType,
		dbo.fnCTConvertQuantityToTargetCommodityUOM(ium.intCommodityUnitMeasureId,@intCommodityUnitMeasureId,isnull((dblRemainingQuantity),0)) dblTotal
		, c.intCollateralId,cl.strLocationName,ch.strItemNo,ch.strEntityName,c.intReceiptNo,ch.intContractHeaderId,
		ch.strContractNumber +'-' +Convert(nvarchar,intContractSeq) strContractNumber,
		c.dtmOpenDate,
		dbo.fnCTConvertQuantityToTargetCommodityUOM(ium.intCommodityUnitMeasureId,@intCommodityUnitMeasureId,isnull((c.dblOriginalQuantity),0)) dblOriginalQuantity,
		dbo.fnCTConvertQuantityToTargetCommodityUOM(ium.intCommodityUnitMeasureId,@intCommodityUnitMeasureId,isnull((c.dblRemainingQuantity),0)) dblRemainingQuantity
	   ,@intCommodityId as intCommodityId,c.intUnitMeasureId,c.intLocationId intCompanyLocationId
		FROM tblRKCollateral c
		JOIN tblICCommodity co on co.intCommodityId=c.intCommodityId
		JOIN tblICCommodityUnitMeasure ium on ium.intCommodityId=c.intCommodityId AND c.intUnitMeasureId=ium.intUnitMeasureId 
		JOIN tblSMCompanyLocation cl on cl.intCompanyLocationId=c.intLocationId
		LEFT JOIN vyuCTContractDetailView ch on c.intContractHeaderId=ch.intContractHeaderId and ch.intContractStatusId <> 3
		WHERE strType = 'Sale' AND c.intCommodityId = @intCommodityId 
		AND c.intLocationId = case when isnull(@intLocationId,0)=0 then c.intLocationId  else @intLocationId end)t
						WHERE intCompanyLocationId  IN (
				SELECT intCompanyLocationId FROM tblSMCompanyLocation
				WHERE isnull(ysnLicensed, 0) = CASE WHEN @strPositionIncludes = 'licensed storage' THEN 1 
								WHEN @strPositionIncludes = 'Non-licensed storage' THEN 0 
								ELSE isnull(ysnLicensed, 0) END
				) 
-- Collatral Purchase
	INSERT INTO @Final(intSeqId,strSeqHeader,strCommodityCode,strType,dblTotal,intCollateralId,strLocationName,strItemNo,strCustomer,intReceiptNo,intContractHeaderId,strContractNumber,dtmOpenDate,dblOriginalQuantity,dblRemainingQuantity,intCommodityId,intFromCommodityUnitMeasureId,intCompanyLocationId)
		SELECT * FROM (
		SELECT 9 intSeqId,'Collateral Receipts - Purchase' strSeqHeader, @strDescription strCommodityCode,'Collateral Receipts - Purchase' strType,
		dbo.fnCTConvertQuantityToTargetCommodityUOM(ium.intCommodityUnitMeasureId,@intCommodityUnitMeasureId,isnull((dblRemainingQuantity),0)) dblTotal, c.intCollateralId,
		cl.strLocationName,ch.strItemNo,ch.strEntityName,c.intReceiptNo,ch.intContractHeaderId,
		ch.strContractNumber +'-' +Convert(nvarchar,intContractSeq) strContractNumber,c.dtmOpenDate,
			dbo.fnCTConvertQuantityToTargetCommodityUOM(ium.intCommodityUnitMeasureId,@intCommodityUnitMeasureId,isnull((c.dblOriginalQuantity),0)) dblOriginalQuantity,
		dbo.fnCTConvertQuantityToTargetCommodityUOM(ium.intCommodityUnitMeasureId,@intCommodityUnitMeasureId,isnull((c.dblRemainingQuantity),0)) dblRemainingQuantity,
		@intCommodityId AS intCommodityId,c.intUnitMeasureId,c.intLocationId intCompanyLocationId	
		FROM tblRKCollateral c
		JOIN tblICCommodity co on co.intCommodityId=c.intCommodityId
		JOIN tblICCommodityUnitMeasure ium on ium.intCommodityId=c.intCommodityId AND c.intUnitMeasureId=ium.intUnitMeasureId
		LEFT JOIN vyuCTContractDetailView ch on c.intContractHeaderId=ch.intContractHeaderId and ch.intContractStatusId <> 3
		JOIN tblSMCompanyLocation cl on cl.intCompanyLocationId=c.intLocationId
		WHERE strType = 'Purchase' AND c.intCommodityId = @intCommodityId 
		AND c.intLocationId = case when isnull(@intLocationId,0)=0 then c.intLocationId  else @intLocationId end)t
								WHERE intCompanyLocationId  IN (
				SELECT intCompanyLocationId FROM tblSMCompanyLocation
				WHERE isnull(ysnLicensed, 0) = CASE WHEN @strPositionIncludes = 'licensed storage' THEN 1 
								WHEN @strPositionIncludes = 'Non-licensed storage' THEN 0 
								ELSE isnull(ysnLicensed, 0) END
				) 

	INSERT INTO @Final (intSeqId,strSeqHeader,strCommodityCode,strType,dblTotal,intCommodityId,strLocationName ,strItemNo,dtmDeliveryDate ,strTicket ,strCustomerReference,strDPAReceiptNo ,	dblDiscDue ,
					  [Storage Due] ,	dtmLastStorageAccrueDate ,strScheduleId,intFromCommodityUnitMeasureId,intCompanyLocationId)
SELECT * FROM (
			SELECT 10 intSeqId,[Storage Type],@strDescription strCommodityCode,[Storage Type] strType,
			dbo.fnCTConvertQuantityToTargetCommodityUOM(ium.intCommodityUnitMeasureId,@intCommodityUnitMeasureId,(Balance)) dblTotal,
			r.intCommodityId  ,Loc AS strLocation ,i.strItemNo,[Delivery Date] AS dtmDeliveryDate ,Ticket strTicket  
			,Customer as strCustomerReference ,Receipt AS strDPAReceiptNo ,[Disc Due] AS dblDiscDue ,[Storage Due] AS [Storage Due]  
			,dtmLastStorageAccrueDate ,strScheduleId,@intCommodityUnitMeasureId intCommodityUnitMeasureId,intCompanyLocationId  
			FROM vyuGRGetStorageOffSiteDetail  r
			join tblICItem i on r.intItemId=i.intItemId
			JOIN tblICItemUOM iuom on i.intItemId=iuom.intItemId and ysnStockUnit=1 
			JOIN tblICCommodityUnitMeasure ium on ium.intCommodityId=i.intCommodityId AND iuom.intUnitMeasureId=ium.intUnitMeasureId 
			WHERE ysnReceiptedStorage = 1 AND ysnExternal <> 1 AND strOwnedPhysicalStock = 'Customer'  
			AND r.intCommodityId = @intCommodityId  
			AND intCompanyLocationId  = case when isnull(@intLocationId,0)=0 then intCompanyLocationId else @intLocationId end)t
				WHERE intCompanyLocationId  IN (
				SELECT intCompanyLocationId FROM tblSMCompanyLocation
				WHERE isnull(ysnLicensed, 0) = CASE WHEN @strPositionIncludes = 'licensed storage' THEN 1 
								WHEN @strPositionIncludes = 'Non-licensed storage' THEN 0 
								ELSE isnull(ysnLicensed, 0) END
				) 
			 

	INSERT INTO @Final(intSeqId,strSeqHeader,strCommodityCode,strType,dblTotal,intCommodityId,intFromCommodityUnitMeasureId)
SELECT 11 AS intSeqId,'Total Receipted',@strDescription
		,'Total Receipted' AS [strType]
		,isnull(dblTotal, 0)  + (isnull(CollateralSale, 0) - isnull(CollateralPurchases, 0)) dblTotal,@intCommodityId,@intCommodityUnitMeasureId
	FROM (select sum(dblTotal) dblTotal from (
		SELECT dbo.fnCTConvertQuantityToTargetCommodityUOM(ium.intCommodityUnitMeasureId,@intCommodityUnitMeasureId,isnull(Balance,0))dblTotal,intCompanyLocationId
		FROM vyuGRGetStorageOffSiteDetail r
			join tblICItem i on r.intItemId=i.intItemId
			JOIN tblICItemUOM iuom on i.intItemId=iuom.intItemId and ysnStockUnit=1 
			JOIN tblICCommodityUnitMeasure ium on ium.intCommodityId=i.intCommodityId AND iuom.intUnitMeasureId=ium.intUnitMeasureId 
		WHERE r.intCommodityId = @intCommodityId 
		AND intCompanyLocationId = case when isnull(@intLocationId,0)=0 then intCompanyLocationId  else @intLocationId end
		AND ysnReceiptedStorage = 1 AND ysnExternal <> 1
		)t 	WHERE intCompanyLocationId  IN (
				SELECT intCompanyLocationId FROM tblSMCompanyLocation
				WHERE isnull(ysnLicensed, 0) = CASE WHEN @strPositionIncludes = 'licensed storage' THEN 1 
								WHEN @strPositionIncludes = 'Non-licensed storage' THEN 0 
								ELSE isnull(ysnLicensed, 0) END
				) ) dblTotal1
		,(SELECT dblTotal CollateralSale FROM @Final where intSeqId = 8 and strSeqHeader='Collateral Receipts - Sales') AS CollateralSale
		,(SELECT dblTotal CollateralPurchases FROM @Final where intSeqId = 9 and strSeqHeader='Collateral Receipts - Purchase') AS  CollateralPurchases

	INSERT INTO @Final (intSeqId,strSeqHeader,strCommodityCode,strType,dblTotal,intCommodityId,strLocationName,strItemNo,dtmDeliveryDate ,strTicket ,strCustomerReference,strDPAReceiptNo ,	dblDiscDue ,
					  [Storage Due] ,	dtmLastStorageAccrueDate ,strScheduleId,intFromCommodityUnitMeasureId,intCompanyLocationId)
		SELECT * FROM (
			SELECT distinct 12 intSeqId,[Storage Type],@strDescription strCommodityCode,[Storage Type] strType,
			dbo.fnCTConvertQuantityToTargetCommodityUOM(ium.intCommodityUnitMeasureId,@intCommodityUnitMeasureId,ISNULL(Balance, 0)) dblTotal,r.intCommodityId  ,Loc AS strLocation ,
			i.strItemNo,[Delivery Date] AS dtmDeliveryDate ,Ticket strTicket  
			,Customer as strCustomerReference ,Receipt AS strDPAReceiptNo ,[Disc Due] AS dblDiscDue ,[Storage Due] AS [Storage Due]  
			,dtmLastStorageAccrueDate ,strScheduleId,@intCommodityUnitMeasureId intCommodityUnitMeasureId,intCompanyLocationId  
			FROM vyuGRGetStorageDetail  r
			join tblICItem i on r.intItemId=i.intItemId
			JOIN tblICItemUOM iuom on i.intItemId=iuom.intItemId and ysnStockUnit=1 
			JOIN tblICCommodityUnitMeasure ium on ium.intCommodityId=i.intCommodityId AND iuom.intUnitMeasureId=ium.intUnitMeasureId 
			WHERE  ysnDPOwnedType = 1  
			AND r.intCommodityId = @intCommodityId  AND intCompanyLocationId  = CASE WHEN ISNULL(@intLocationId,0)=0 then intCompanyLocationId else @intLocationId end
			)t where  intCompanyLocationId  IN (
				SELECT intCompanyLocationId FROM tblSMCompanyLocation
				WHERE isnull(ysnLicensed, 0) = CASE WHEN @strPositionIncludes = 'licensed storage' THEN 1 
								WHEN @strPositionIncludes = 'Non-licensed storage' THEN 0 
								ELSE isnull(ysnLicensed, 0) END
				) 

	INSERT INTO @Final (intSeqId,strSeqHeader,strCommodityCode,strType,dblTotal,intCommodityId,strLocationName,strItemNo,strTicket,dtmTicketDateTime,strCustomerReference, strDistributionOption,intFromCommodityUnitMeasureId,intCompanyLocationId)
			SELECT * FROM (
			SELECT 13 intSeqId,'Pur Basis Deliveries' strSeqHeader,@strDescription strCommodityCode,'Pur Basis Deliveries' strType,
			dbo.fnCTConvertQuantityToTargetCommodityUOM(ium.intCommodityUnitMeasureId,@intCommodityUnitMeasureId,isnull((PLDetail.dblLotPickedQty),0)) AS dblTotal,
			CT.intCommodityId,cl.strLocationName,CT.strItemNo,convert(nvarchar,CT.strContractNumber)+'/'+convert(nvarchar,CT.intContractSeq) strTicket,CT.dtmContractDate as dtmTicketDateTime ,
			CT.strCustomerContract as strCustomerReference, 'CNT' as strDistributionOption,@intCommodityUnitMeasureId as intCommodityUnitMeasureId,
			CT.intCompanyLocationId
			FROM tblLGDeliveryPickDetail Del
			INNER JOIN tblLGPickLotDetail PLDetail ON PLDetail.intPickLotDetailId = Del.intPickLotDetailId
			INNER JOIN vyuLGPickOpenInventoryLots Lots ON Lots.intLotId = PLDetail.intLotId
			INNER JOIN vyuCTContractDetailView CT ON CT.intContractDetailId = Lots.intContractDetailId  and CT.intContractStatusId <> 3
			JOIN tblICCommodityUnitMeasure ium on ium.intCommodityId=CT.intCommodityId AND CT.intUnitMeasureId=ium.intUnitMeasureId 
			INNER JOIN tblSMCompanyLocation  cl on cl.intCompanyLocationId=CT.intCompanyLocationId
			WHERE CT.intPricingTypeId = 2 AND CT.intCommodityId = @intCommodityId 
			AND CT.intCompanyLocationId  = case when isnull(@intLocationId,0)=0 then CT.intCompanyLocationId   else @intLocationId end

			UNION ALL
			
			SELECT 13 intSeqId,'Pur Basis Deliveries' strSeqHeader,@strDescription strCommodityCode,'Pur Basis Deliveries' strType,
			dbo.fnCTConvertQuantityToTargetCommodityUOM(ium.intCommodityUnitMeasureId,@intCommodityUnitMeasureId,isnull(ri.dblReceived, 0))  AS dblTotal,
			st.intCommodityId,cl.strLocationName,cd.strItemNo,strTicketNumber strTicket,st.dtmTicketDateTime,strCustomerReference,
					strDistributionOption,@intCommodityUnitMeasureId intCommodityUnitMeasureId,st.intProcessingLocationId intCompanyLocationId
			FROM tblICInventoryReceipt r
			INNER JOIN tblICInventoryReceiptItem ri ON r.intInventoryReceiptId = ri.intInventoryReceiptId AND r.strReceiptType = 'Purchase Contract'
			INNER JOIN tblSCTicket st ON st.intTicketId = ri.intSourceId  AND strDistributionOption IN ('CNT')
			INNER JOIN vyuCTContractDetailView cd ON cd.intContractDetailId = ri.intLineNo AND cd.intPricingTypeId = 2  and cd.intContractStatusId <> 3
			JOIN tblICCommodityUnitMeasure ium on ium.intCommodityId=cd.intCommodityId AND cd.intUnitMeasureId=ium.intUnitMeasureId 
			INNER JOIN tblSMCompanyLocation  cl on cl.intCompanyLocationId=st.intProcessingLocationId 
			WHERE cd.intCommodityId = @intCommodityId AND st.intProcessingLocationId  = case when isnull(@intLocationId,0)=0 then st.intProcessingLocationId else @intLocationId end
			)t	WHERE  intCompanyLocationId  IN (
				SELECT intCompanyLocationId FROM tblSMCompanyLocation
				WHERE isnull(ysnLicensed, 0) = CASE WHEN @strPositionIncludes = 'licensed storage' THEN 1 
								WHEN @strPositionIncludes = 'Non-licensed storage' THEN 0 
								ELSE isnull(ysnLicensed, 0) END
				) 
	INSERT INTO @Final (intSeqId,strSeqHeader,strCommodityCode,strType,dblTotal,intCommodityId,strLocationName,strItemNo,strTicket,dtmTicketDateTime,strCustomerReference, strDistributionOption,intFromCommodityUnitMeasureId,intCompanyLocationId)
			select * from (
			SELECT 14 intSeqId,'Sls Basis Deliveries' strSeqHeader,@strDescription strCommodityCode,'Sls Basis Deliveries' strType,
			dbo.fnCTConvertQuantityToTargetCommodityUOM(ium.intCommodityUnitMeasureId,@intCommodityUnitMeasureId,isnull(ri.dblQuantity, 0))  AS dblTotal,
			cd.intCommodityId,cl.strLocationName,cd.strItemNo,convert(nvarchar,cd.strContractNumber)+'/'+convert(nvarchar,cd.intContractSeq) strTicketNumber,
			cd.dtmContractDate as dtmTicketDateTime ,
			cd.strCustomerContract as strCustomerReference, 'CNT' as strDistributionOption,cd.intUnitMeasureId,cl.intCompanyLocationId
			FROM tblICInventoryShipment r
			INNER JOIN tblICInventoryShipmentItem ri ON r.intInventoryShipmentId = ri.intInventoryShipmentId
			INNER JOIN vyuCTContractDetailView cd ON cd.intContractDetailId = ri.intLineNo AND cd.intPricingTypeId = 2	and cd.intContractStatusId <> 3
			JOIN tblICCommodityUnitMeasure ium on ium.intCommodityId=cd.intCommodityId AND cd.intUnitMeasureId=ium.intUnitMeasureId 
			INNER JOIN tblSMCompanyLocation  cl on cl.intCompanyLocationId=cd.intCompanyLocationId
			WHERE cd.intCommodityId = @intCommodityId 
			AND cl.intCompanyLocationId  = case when isnull(@intLocationId,0)=0 then cl.intCompanyLocationId else @intLocationId end)t
				WHERE intCompanyLocationId IN (
				SELECT intCompanyLocationId FROM tblSMCompanyLocation
				WHERE isnull(ysnLicensed, 0) = CASE WHEN @strPositionIncludes = 'licensed storage' THEN 1 
								WHEN @strPositionIncludes = 'Non-licensed storage' THEN 0 
								ELSE isnull(ysnLicensed, 0) END
				)  
	INSERT INTO @Final(intSeqId,strSeqHeader,strCommodityCode,strType,dblTotal,intCommodityId,intFromCommodityUnitMeasureId)

SELECT 15 AS intSeqId,'Company Titled Stock',@strDescription
		,'Company Titled Stock' AS [strType]
		,ISNULL(invQty, 0) +
		  (isnull(CollateralPurchases, 0) - isnull(CollateralSale, 0)) +
		 CASE WHEN (SELECT TOP 1 ysnIncludeOffsiteInventoryInCompanyTitled from tblRKCompanyPreference)=1 then isnull(OffSite,0) else 0 end +  
		CASE WHEN (SELECT TOP 1 ysnIncludeDPPurchasesInCompanyTitled from tblRKCompanyPreference)=1 then 0 else -isnull(DP,0) end  
		 +isnull(SlsBasisDeliveries ,0)
		 AS dblTotal,@intCommodityId,@intCommodityUnitMeasureId
	FROM (
		SELECT 
		isnull((select sum(dblUnitOnHand) from (
					SELECT s.dblOnHand dblUnitOnHand,s.intLocationId
				FROM vyuICGetItemStockUOM s  				  
				WHERE s.intCommodityId = @intCommodityId 
				AND s.intLocationId= CASE WHEN ISNULL(@intLocationId,0)=0 then s.intLocationId else @intLocationId end
				 )t WHERE intLocationId  IN (
				SELECT intCompanyLocationId FROM tblSMCompanyLocation
				WHERE isnull(ysnLicensed, 0) = CASE WHEN @strPositionIncludes = 'licensed storage' THEN 1 
								WHEN @strPositionIncludes = 'Non-licensed storage' THEN 0 
								ELSE isnull(ysnLicensed, 0) END
				)			 
				 ), 0) AS invQty
			
			,(SELECT dblTotal CollateralSale FROM @Final where intSeqId = 8 and strSeqHeader='Collateral Receipts - Sales') AS CollateralSale
			,(SELECT dblTotal CollateralPurchases FROM @Final where intSeqId = 9 and strSeqHeader='Collateral Receipts - Purchase')   AS CollateralPurchases
			,(select sum(dblTotal) dblTotal from (SELECT 
					dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId,@intCommodityUnitMeasureId,(Balance)) dblTotal,CH.intCompanyLocationId
					FROM vyuGRGetStorageDetail CH
					WHERE ysnCustomerStorage = 1
						AND strOwnedPhysicalStock = 'Company'
						AND CH.intCommodityId  = @intCommodityId
						AND CH.intCompanyLocationId= case when isnull(@intLocationId,0)=0 then CH.intCompanyLocationId else @intLocationId end	
				 )t WHERE intCompanyLocationId IN (
				SELECT intCompanyLocationId FROM tblSMCompanyLocation
				WHERE isnull(ysnLicensed, 0) = CASE WHEN @strPositionIncludes = 'licensed storage' THEN 1 
								WHEN @strPositionIncludes = 'Non-licensed storage' THEN 0 
								ELSE isnull(ysnLicensed, 0) END
				)) AS OffSite

				,(select sum(dblTotal) from @Final where intSeqId = 14 and intCommodityId=@intCommodityId) as SlsBasisDeliveries

				,(select sum(dblTotal) dblTotal from (
					SELECT 
					dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId,@intCommodityUnitMeasureId,(isnull(Balance,0))) dblTotal
					,ch.intCompanyLocationId
					FROM vyuGRGetStorageDetail ch
					WHERE ch.intCommodityId  = @intCommodityId
						AND ysnDPOwnedType = 1
						AND ch.intCompanyLocationId= case when isnull(@intLocationId,0)=0 then ch.intCompanyLocationId else @intLocationId end
					)t 	WHERE intCompanyLocationId  IN (
				SELECT intCompanyLocationId FROM tblSMCompanyLocation
				WHERE isnull(ysnLicensed, 0) = CASE WHEN @strPositionIncludes = 'licensed storage' THEN 1 
								WHEN @strPositionIncludes = 'Non-licensed storage' THEN 0 
								ELSE isnull(ysnLicensed, 0) END
				) ) AS DP

		) t

INSERT INTO @Final (intSeqId,strSeqHeader,strCommodityCode,strType,dblTotal,intCommodityId,strLocationName,strItemNo,strTicket,dtmTicketDateTime,strCustomerReference, strDistributionOption,intFromCommodityUnitMeasureId,strTruckName,strDriverName,intCompanyLocationId)
select * from (
SELECT 16 intSeqId,'On-Hold' strSeqHeader,@strDescription strCommodityCode,'On-Hold' strType,
dbo.fnCTConvertQuantityToTargetCommodityUOM(ium.intCommodityUnitMeasureId,@intCommodityUnitMeasureId,isnull(st.dblNetUnits, 0))  AS dblTotal,
st.intCommodityId,cl.strLocationName,i1.strItemNo,strTicketNumber strTicket,st.dtmTicketDateTime,strCustomerReference,
		strDistributionOption,@intCommodityUnitMeasureId AS intCommodityUnitMeasureId
		,strTruckName
		,strDriverName, st.intProcessingLocationId intCompanyLocationId
FROM tblSCTicket st
JOIN tblSMCompanyLocation  cl on cl.intCompanyLocationId=st.intProcessingLocationId and st.strDistributionOption='HLD'
JOIN tblICItem i1 on i1.intItemId=st.intItemId
JOIN tblICItemUOM iuom on i1.intItemId=iuom.intItemId and ysnStockUnit=1
JOIN tblICCommodityUnitMeasure ium on ium.intCommodityId=i1.intCommodityId AND iuom.intUnitMeasureId=ium.intUnitMeasureId 
WHERE st.intCommodityId  = @intCommodityId
	  AND st.intProcessingLocationId  = case when isnull(@intLocationId,0)=0 then st.intProcessingLocationId else @intLocationId end)t
				WHERE intCompanyLocationId  IN (
				SELECT intCompanyLocationId FROM tblSMCompanyLocation
				WHERE isnull(ysnLicensed, 0) = CASE WHEN @strPositionIncludes = 'licensed storage' THEN 1 
								WHEN @strPositionIncludes = 'Non-licensed storage' THEN 0 
								ELSE isnull(ysnLicensed, 0) END
				) 
END
ELSE
BEGIN

	INSERT INTO @Final(intSeqId,strSeqHeader,strCommodityCode,strType,dblTotal,strLocationName,strItemNo,strCustomer,intCommodityId,intFromCommodityUnitMeasureId,strTruckName,strDriverName,[Storage Due],intCompanyLocationId)
	
				(select distinct 1 AS intSeqId,'In-House',@strDescription,StorageType AS [strType],				
				 CASE WHEN (SELECT TOP 1 ysnIncludeDPPurchasesInCompanyTitled from tblRKCompanyPreference)=1 then dblTotal  else 0 end dblTotal 
				 ,strLocationName,strItemNo,strName,@intCommodityId,@intCommodityUnitMeasureId,'' strTruckName,'' strDriverName,[Storage Due],intCompanyLocationId
				 FROM (
				SELECT 
				dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId,@intCommodityUnitMeasureId,(isnull(Balance,0))) dblTotal,strLocationName,strItemNo
				,Ticket,
				[Storage Type] StorageType,strName,[Storage Due],intCompanyLocationId
				FROM vyuGRGetStorageDetail ch
				JOIN tblEMEntity e on ch.intEntityId=e.intEntityId
				WHERE ch.intCommodityId  = @intCommodityId	and strOwnedPhysicalStock='Customer'
					AND ch.intCompanyLocationId= case when isnull(@intLocationId,0)=0 then ch.intCompanyLocationId else @intLocationId end
					AND ch.intEntityId= @intVendorId
				)t WHERE intCompanyLocationId  IN (
				SELECT intCompanyLocationId FROM tblSMCompanyLocation
				WHERE isnull(ysnLicensed, 0) = CASE WHEN @strPositionIncludes = 'licensed storage' THEN 1 
								WHEN @strPositionIncludes = 'Non-licensed storage' THEN 0 
								ELSE isnull(ysnLicensed, 0) END
				) )
				UNION  
				SELECT * FROM (
				SELECT DISTINCT 1 intSeqId,'In-House' strSeqHeader,@strDescription strCommodityCode,'On-Hold' strType,
				dbo.fnCTConvertQuantityToTargetCommodityUOM(ium.intCommodityUnitMeasureId,@intCommodityUnitMeasureId,isnull(st.dblNetUnits, 0))  AS dblTotal,
				cl.strLocationName,i1.strItemNo,strName,@intCommodityId intCommodityId,@intCommodityUnitMeasureId intCommodityUnitMeasureId,strTruckName,strDriverName,null [Storage Due]
				,st.intProcessingLocationId intCompanyLocationId
				FROM tblSCTicket st
				JOIN tblEMEntity e on st.intEntityId=e.intEntityId
				JOIN tblSMCompanyLocation  cl on cl.intCompanyLocationId=st.intProcessingLocationId and st.strDistributionOption='HLD'
				JOIN tblICItem i1 on i1.intItemId=st.intItemId
				JOIN tblICItemUOM iuom on i1.intItemId=iuom.intItemId and ysnStockUnit=1
				JOIN tblICCommodityUnitMeasure ium on ium.intCommodityId=i1.intCommodityId AND iuom.intUnitMeasureId=ium.intUnitMeasureId 
				WHERE st.intCommodityId  = @intCommodityId
				AND st.intProcessingLocationId  = case when isnull(@intLocationId,0)=0 then st.intProcessingLocationId else @intLocationId end
				AND st.intEntityId= @intVendorId )t	
				WHERE intCompanyLocationId  IN (
				SELECT intCompanyLocationId FROM tblSMCompanyLocation
				WHERE isnull(ysnLicensed, 0) = CASE WHEN @strPositionIncludes = 'licensed storage' THEN 1 
								WHEN @strPositionIncludes = 'Non-licensed storage' THEN 0 
								ELSE isnull(ysnLicensed, 0) END
				) 

	INSERT INTO @Final (intSeqId,strSeqHeader,strCommodityCode,strType,dblTotal,intCommodityId ,strLocationName,strItemNo,strCustomer,dtmDeliveryDate ,strTicket ,
					strCustomerReference,strDPAReceiptNo ,dblDiscDue ,[Storage Due] , dtmLastStorageAccrueDate ,strScheduleId,intFromCommodityUnitMeasureId,intCompanyLocationId)
		select * from (
		SELECT 2 intSeqId,'Off-Site' strSeqHeader,@strDescription strCommodityCode,'Off-Site' strType,
		dbo.fnCTConvertQuantityToTargetCommodityUOM(ium.intCommodityUnitMeasureId,@intCommodityUnitMeasureId,(Balance)) dblTotal,r.intCommodityId,Loc AS strLocation,
		i.strItemNo ,strName,[Delivery Date] AS dtmDeliveryDate ,
				Ticket strTicket ,Customer as strCustomerReference ,Receipt AS strDPAReceiptNo ,[Disc Due] AS dblDiscDue ,
				[Storage Due] AS [Storage Due] ,dtmLastStorageAccrueDate ,strScheduleId,@intCommodityUnitMeasureId intCommodityUnitMeasureId,intCompanyLocationId  
		FROM vyuGRGetStorageOffSiteDetail r
		JOIN tblEMEntity e on r.intEntityId=e.intEntityId
		join tblICItem i on r.intItemId=i.intItemId
		JOIN tblICItemUOM iuom on i.intItemId=iuom.intItemId and ysnStockUnit=1 
		JOIN tblICCommodityUnitMeasure ium on ium.intCommodityId=i.intCommodityId AND iuom.intUnitMeasureId=ium.intUnitMeasureId 
		WHERE ysnReceiptedStorage = 1 AND ysnExternal = 1 AND strOwnedPhysicalStock = 'Customer' AND r.intCommodityId = @intCommodityId 
		AND intCompanyLocationId= case when isnull(@intLocationId,0)=0 then intCompanyLocationId else @intLocationId end
		AND r.intEntityId= @intVendorId )t
				where intCompanyLocationId  IN (
				SELECT intCompanyLocationId FROM tblSMCompanyLocation
				WHERE isnull(ysnLicensed, 0) = CASE WHEN @strPositionIncludes = 'licensed storage' THEN 1 
								WHEN @strPositionIncludes = 'Non-licensed storage' THEN 0 
								ELSE isnull(ysnLicensed, 0) END
				) 

	INSERT INTO @Final(intSeqId,strSeqHeader,strCommodityCode,strType,dblTotal,strLocationName,strItemNo,strContractNumber,intCommodityId,intFromCommodityUnitMeasureId)
	SELECT 3 AS intSeqId,'Purchase In-Transit',@strDescription,'Purchase In-Transit' AS [strType],
	dbo.fnCTConvertQuantityToTargetCommodityUOM(intUnitMeasureId,@intCommodityUnitMeasureId,ISNULL(ReserveQty, 0)) 
	 AS dblTotal,strLocationName,strItemNo,strContractNumber,@intCommodityId,@intCommodityUnitMeasureId
	FROM (
			SELECT i.intUnitMeasureId,			
			isnull(i.dblPurchaseContractShippedQty, 0) as ReserveQty,
			i.strLocationName,i.strItemNo,
			i.strContractNumber,i.intCompanyLocationId
			FROM vyuRKPurchaseIntransitView i
			WHERE i.intCommodityId = @intCommodityId
			AND i.intCompanyLocationId= case when isnull(@intLocationId,0)=0 then i.intCompanyLocationId else @intLocationId end
			AND i.intEntityId= @intVendorId 
								
		) t WHERE intCompanyLocationId  IN (
				SELECT intCompanyLocationId FROM tblSMCompanyLocation
				WHERE isnull(ysnLicensed, 0) = CASE WHEN @strPositionIncludes = 'licensed storage' THEN 1 
								WHEN @strPositionIncludes = 'Non-licensed storage' THEN 0 
								ELSE isnull(ysnLicensed, 0) END
				)

	INSERT INTO @Final(intSeqId,strSeqHeader,strCommodityCode,strType,dblTotal,strLocationName,strItemNo,strTicket,strCustomerReference,strContractNumber,intCommodityId,intFromCommodityUnitMeasureId,intCompanyLocationId)
	SELECT 4 AS intSeqId,'Sales In-Transit',@strDescription
		,'Sales In-Transit' AS [strType]
		,ISNULL(ReserveQty, 0) AS dblTotal,strLocationName,strItemName,strTicket,strCustomerReference,strContractNumber,@intCommodityId,@intCommodityUnitMeasureId,intCompanyLocationId
	FROM (
		SELECT dbo.fnCTConvertQuantityToTargetCommodityUOM(i.intUnitMeasureId,@intCommodityUnitMeasureId,isnull(i.dblBalanceToInvoice, 0)) as ReserveQty,
				i.strLocationName,i.strItemName,strContractNumber,strTicket,strCustomerReference,i.intCompanyLocationId
				FROM vyuRKGetSalesIntransitWOPickLot i
				WHERE i.intCommodityId = @intCommodityId
			    AND i.intCompanyLocationId= case when isnull(@intLocationId,0)=0 then i.intCompanyLocationId else @intLocationId end	
				AND i.intEntityId= @intVendorId 
		) t WHERE intCompanyLocationId  IN (
				SELECT intCompanyLocationId FROM tblSMCompanyLocation
				WHERE isnull(ysnLicensed, 0) = CASE WHEN @strPositionIncludes = 'licensed storage' THEN 1 
								WHEN @strPositionIncludes = 'Non-licensed storage' THEN 0 
								ELSE isnull(ysnLicensed, 0) END
				) 	

	INSERT INTO @Final (intSeqId,strSeqHeader,strCommodityCode,strType,dblTotal,intCommodityId,strLocationName,strItemNo,strCustomer,dtmDeliveryDate ,strTicket ,strCustomerReference,strDPAReceiptNo ,	dblDiscDue ,
					  [Storage Due] ,	dtmLastStorageAccrueDate ,strScheduleId,intFromCommodityUnitMeasureId,intCompanyLocationId)
		select * from (
		SELECT 5 intSeqId,[Storage Type] strSeqHeader,@strDescription strCommodityCode,[Storage Type] strType,
		dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId,@intCommodityUnitMeasureId,ISNULL(Balance, 0)) dblTotal,
		r.intCommodityId,Loc AS strLocation ,r.strItemNo,strName,[Delivery Date] AS dtmDeliveryDate ,Ticket strTicket  
		,Customer as strCustomerReference,Receipt AS strDPAReceiptNo ,[Disc Due] AS dblDiscDue ,[Storage Due] AS [Storage Due]  
		,dtmLastStorageAccrueDate ,strScheduleId ,@intCommodityUnitMeasureId intCommodityUnitMeasureId,intCompanyLocationId   
		FROM vyuGRGetStorageDetail  r
		JOIN tblEMEntity e on r.intEntityId=e.intEntityId
		WHERE r.intCommodityId = @intCommodityId AND ysnDPOwnedType = 0  AND ysnReceiptedStorage = 0  
		AND	intCompanyLocationId  = case when isnull(@intLocationId,0)=0 then intCompanyLocationId else @intLocationId end
		AND r.intEntityId= @intVendorId )t
				WHERE intCompanyLocationId  IN (
				SELECT intCompanyLocationId FROM tblSMCompanyLocation
				WHERE isnull(ysnLicensed, 0) = CASE WHEN @strPositionIncludes = 'licensed storage' THEN 1 
								WHEN @strPositionIncludes = 'Non-licensed storage' THEN 0 
								ELSE isnull(ysnLicensed, 0) END
				) 
		
	INSERT INTO @Final(intSeqId,strSeqHeader,strCommodityCode,strType,dblTotal,strLocationName,strItemNo,strCustomer,intCommodityId,intFromCommodityUnitMeasureId,[Storage Due],intCompanyLocationId)
	select * from (
	SELECT 7 AS intSeqId,'Total Non-Receipted' strSeqHeader,@strDescription strCommodityCode
		,'Total Non-Receipted' [Storage Type]
		,dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId,@intCommodityUnitMeasureId,ISNULL(Balance, 0)) dblTotal,strLocationName,r.strItemNo,
		strName, @intCommodityId AS intCommodityId,@intCommodityUnitMeasureId AS intCommodityUnitMeasureId,[Storage Due],intCompanyLocationId
	FROM vyuGRGetStorageDetail  r
	JOIN tblEMEntity e on r.intEntityId=e.intEntityId
	WHERE ysnReceiptedStorage = 0
		AND strOwnedPhysicalStock = 'Customer'
		AND r.intCommodityId = @intCommodityId
		AND intCompanyLocationId= case when isnull(@intLocationId,0)=0 then intCompanyLocationId else @intLocationId end	
		AND r.intEntityId= @intVendorId )t
				WHERE intCompanyLocationId  IN (
				SELECT intCompanyLocationId FROM tblSMCompanyLocation
				WHERE isnull(ysnLicensed, 0) = CASE WHEN @strPositionIncludes = 'licensed storage' THEN 1 
								WHEN @strPositionIncludes = 'Non-licensed storage' THEN 0 
								ELSE isnull(ysnLicensed, 0) END
				) 

	INSERT INTO @Final(intSeqId,strSeqHeader,strCommodityCode,strType,dblTotal,intCollateralId,strLocationName,strItemNo,strCustomer,intReceiptNo,intContractHeaderId,strContractNumber,dtmOpenDate,dblOriginalQuantity,dblRemainingQuantity,intCommodityId,intFromCommodityUnitMeasureId,intCompanyLocationId)
		SELECT * FROM (
		SELECT 8 intSeqId,'Collateral Receipts - Sales' strSeqHeader, @strDescription strCommodityCode,'Collateral Receipts - Sales' strType,
		dbo.fnCTConvertQuantityToTargetCommodityUOM(ium.intCommodityUnitMeasureId,@intCommodityUnitMeasureId,isnull((dblRemainingQuantity),0)) dblTotal
		, c.intCollateralId,cl.strLocationName,ch.strItemNo,ch.strEntityName,c.intReceiptNo,ch.intContractHeaderId,
		ch.strContractNumber +'-' +Convert(nvarchar,intContractSeq) strContractNumber,
		c.dtmOpenDate,
		dbo.fnCTConvertQuantityToTargetCommodityUOM(ium.intCommodityUnitMeasureId,@intCommodityUnitMeasureId,isnull((c.dblOriginalQuantity),0)) dblOriginalQuantity,
		dbo.fnCTConvertQuantityToTargetCommodityUOM(ium.intCommodityUnitMeasureId,@intCommodityUnitMeasureId,isnull((c.dblRemainingQuantity),0)) dblRemainingQuantity
	   ,@intCommodityId AS intCommodityId,c.intUnitMeasureId,c.intLocationId intCompanyLocationId 
		FROM tblRKCollateral c
		LEFT JOIN tblRKCollateralAdjustment ca ON c.intCollateralId = ca.intCollateralId
		JOIN tblICCommodity co on co.intCommodityId=c.intCommodityId
		JOIN tblICCommodityUnitMeasure ium on ium.intCommodityId=c.intCommodityId AND c.intUnitMeasureId=ium.intUnitMeasureId 
		JOIN tblSMCompanyLocation cl on cl.intCompanyLocationId=c.intLocationId
		LEFT JOIN vyuCTContractDetailView ch on c.intContractHeaderId=ch.intContractHeaderId  and ch.intContractStatusId <> 3
		WHERE strType = 'Sale' AND c.intCommodityId = @intCommodityId 
		AND c.intLocationId = case when isnull(@intLocationId,0)=0 then c.intLocationId  else @intLocationId end
		AND intEntityId= @intVendorId )t WHERE intCompanyLocationId  IN (
				SELECT intCompanyLocationId FROM tblSMCompanyLocation
				WHERE isnull(ysnLicensed, 0) = CASE WHEN @strPositionIncludes = 'licensed storage' THEN 1 
								WHEN @strPositionIncludes = 'Non-licensed storage' THEN 0 
								ELSE isnull(ysnLicensed, 0) END
				)

	INSERT INTO @Final(intSeqId,strSeqHeader,strCommodityCode,strType,dblTotal,intCollateralId,strLocationName,strItemNo,strCustomer,intReceiptNo,intContractHeaderId,strContractNumber,dtmOpenDate,dblOriginalQuantity,dblRemainingQuantity,intCommodityId,intFromCommodityUnitMeasureId,intCompanyLocationId)
		SELECT * FROM (
		SELECT 9 intSeqId,'Collateral Receipts - Purchase' strSeqHeader, @strDescription strCommodityCode,'Collateral Receipts - Purchase' strType,
		dbo.fnCTConvertQuantityToTargetCommodityUOM(ium.intCommodityUnitMeasureId,@intCommodityUnitMeasureId,isnull((dblRemainingQuantity),0)) dblTotal,
		c.intCollateralId,
		cl.strLocationName,ch.strItemNo,ch.strEntityName,c.intReceiptNo,ch.intContractHeaderId,
		ch.strContractNumber +'-' +Convert(nvarchar,intContractSeq) strContractNumber,c.dtmOpenDate,
			dbo.fnCTConvertQuantityToTargetCommodityUOM(ium.intCommodityUnitMeasureId,@intCommodityUnitMeasureId,isnull((c.dblOriginalQuantity),0)) dblOriginalQuantity,
		dbo.fnCTConvertQuantityToTargetCommodityUOM(ium.intCommodityUnitMeasureId,@intCommodityUnitMeasureId,isnull((c.dblRemainingQuantity),0)) dblRemainingQuantity,
		@intCommodityId intCommodityId,c.intUnitMeasureId,c.intLocationId intCompanyLocationId	
		FROM tblRKCollateral c
		LEFT JOIN tblRKCollateralAdjustment ca ON c.intCollateralId = ca.intCollateralId
		JOIN tblICCommodity co on co.intCommodityId=c.intCommodityId
		JOIN tblICCommodityUnitMeasure ium on ium.intCommodityId=c.intCommodityId AND c.intUnitMeasureId=ium.intUnitMeasureId
		LEFT JOIN vyuCTContractDetailView ch on c.intContractHeaderId=ch.intContractHeaderId  and ch.intContractStatusId <> 3
		JOIN tblSMCompanyLocation cl on cl.intCompanyLocationId=c.intLocationId
		WHERE strType = 'Purchase' AND c.intCommodityId = @intCommodityId 
		AND c.intLocationId = case when isnull(@intLocationId,0)=0 then c.intLocationId  else @intLocationId end
		AND intEntityId= @intVendorId)t  WHERE intCompanyLocationId  IN (
				SELECT intCompanyLocationId FROM tblSMCompanyLocation
				WHERE isnull(ysnLicensed, 0) = CASE WHEN @strPositionIncludes = 'licensed storage' THEN 1 
								WHEN @strPositionIncludes = 'Non-licensed storage' THEN 0 
								ELSE isnull(ysnLicensed, 0) END
				)

	INSERT INTO @Final (intSeqId,strSeqHeader,strCommodityCode,strType,dblTotal,intCommodityId,strLocationName ,strItemNo,strCustomer,dtmDeliveryDate ,strTicket ,strCustomerReference,strDPAReceiptNo ,	dblDiscDue ,
					  [Storage Due] , dtmLastStorageAccrueDate ,strScheduleId,intFromCommodityUnitMeasureId,intCompanyLocationId)
		SELECT * FROM (
			SELECT 10 intSeqId,[Storage Type],@strDescription strCommodityCode,[Storage Type] strType,
			dbo.fnCTConvertQuantityToTargetCommodityUOM(ium.intCommodityUnitMeasureId,@intCommodityUnitMeasureId,(Balance)) dblTotal,
			r.intCommodityId  ,Loc AS strLocation ,i.strItemNo,strName,[Delivery Date] AS dtmDeliveryDate ,Ticket strTicket  
			,Customer as strCustomerReference, Receipt AS strDPAReceiptNo ,[Disc Due] AS dblDiscDue ,[Storage Due] AS [Storage Due]  
			,dtmLastStorageAccrueDate,strScheduleId,@intCommodityUnitMeasureId as intCommodityUnitMeasureId,intCompanyLocationId  
			FROM vyuGRGetStorageOffSiteDetail  r
			JOIN tblEMEntity e on r.intEntityId=e.intEntityId
			join tblICItem i on r.intItemId=i.intItemId
			JOIN tblICItemUOM iuom on i.intItemId=iuom.intItemId and ysnStockUnit=1 
			JOIN tblICCommodityUnitMeasure ium on ium.intCommodityId=i.intCommodityId AND iuom.intUnitMeasureId=ium.intUnitMeasureId 
			WHERE ysnReceiptedStorage = 1 AND ysnExternal <> 1 AND strOwnedPhysicalStock = 'Customer'  
			AND r.intCommodityId = @intCommodityId  AND intCompanyLocationId  = case when isnull(@intLocationId,0)=0 then intCompanyLocationId else @intLocationId end 
			AND r.intEntityId= @intVendorId)t
				WHERE intCompanyLocationId IN (
				SELECT intCompanyLocationId FROM tblSMCompanyLocation
				WHERE isnull(ysnLicensed, 0) = CASE WHEN @strPositionIncludes = 'licensed storage' THEN 1 
								WHEN @strPositionIncludes = 'Non-licensed storage' THEN 0 
								ELSE isnull(ysnLicensed, 0) END
				) 

	INSERT INTO @Final(intSeqId,strSeqHeader,strCommodityCode,strType,dblTotal,intCommodityId,intFromCommodityUnitMeasureId)
    SELECT 11 AS intSeqId,'Total Receipted',@strDescription
		,'Total Receipted' AS [strType]
		,isnull(dblTotal, 0)  + case when @strPurchaseSales = 'Purchase' then isnull(CollateralSale, 0) else 0 end  + case when @strPurchaseSales ='Sales' then isnull(CollateralPurchases, 0) else 0 end  dblTotal,@intCommodityId,@intCommodityUnitMeasureId
	FROM (select sum(dblTotal) dblTotal from (
		SELECT dbo.fnCTConvertQuantityToTargetCommodityUOM(ium.intCommodityUnitMeasureId,@intCommodityUnitMeasureId,isnull(Balance,0))dblTotal,intCompanyLocationId
		FROM vyuGRGetStorageOffSiteDetail r
			join tblICItem i on r.intItemId=i.intItemId
			JOIN tblICItemUOM iuom on i.intItemId=iuom.intItemId and ysnStockUnit=1 
			JOIN tblICCommodityUnitMeasure ium on ium.intCommodityId=i.intCommodityId AND iuom.intUnitMeasureId=ium.intUnitMeasureId 
		WHERE r.intCommodityId = @intCommodityId 
		AND intCompanyLocationId = case when isnull(@intLocationId,0)=0 then intCompanyLocationId  else @intLocationId end
		AND ysnReceiptedStorage = 1 AND ysnExternal <> 1 AND intEntityId= @intVendorId 
		)t WHERE intCompanyLocationId IN (
				SELECT intCompanyLocationId FROM tblSMCompanyLocation
				WHERE isnull(ysnLicensed, 0) = CASE WHEN @strPositionIncludes = 'licensed storage' THEN 1 
								WHEN @strPositionIncludes = 'Non-licensed storage' THEN 0 
								ELSE isnull(ysnLicensed, 0) END
				) 
		) dblTotal1
		,(SELECT dblTotal CollateralSale FROM @Final where intSeqId = 8 and strSeqHeader='Collateral Receipts - Sales') AS CollateralSale
		,(SELECT dblTotal CollateralPurchases FROM @Final where intSeqId = 9 and strSeqHeader='Collateral Receipts - Purchase')   AS CollateralPurchases

	INSERT INTO @Final (intSeqId,strSeqHeader,strCommodityCode,strType,dblTotal,intCommodityId,strLocationName,strItemNo,strCustomer,strTicket,dtmTicketDateTime,strCustomerReference, strDistributionOption,intFromCommodityUnitMeasureId,intCompanyLocationId)
			SELECT * FROM (
			SELECT 13 intSeqId,'Pur Basis Deliveries' strSeqHeader,@strDescription strCommodityCode,'Purchase Basis Deliveries' strType,
			dbo.fnCTConvertQuantityToTargetCommodityUOM(ium.intCommodityUnitMeasureId,@intCommodityUnitMeasureId,isnull((PLDetail.dblLotPickedQty),0))
			 AS dblTotal,CT.intCommodityId,cl.strLocationName,CT.strItemNo,strName,convert(nvarchar,CT.strContractNumber)+'/'+convert(nvarchar,CT.intContractSeq) strTicket,CT.dtmContractDate as dtmTicketDateTime ,
			CT.strCustomerContract as strCustomerReference, 'CNT' as strDistributionOption,@intCommodityUnitMeasureId intCommodityUnitMeasureId,CT.intCompanyLocationId intCompanyLocationId
			FROM tblLGDeliveryPickDetail Del
			INNER JOIN tblLGPickLotDetail PLDetail ON PLDetail.intPickLotDetailId = Del.intPickLotDetailId
			INNER JOIN vyuLGPickOpenInventoryLots Lots ON Lots.intLotId = PLDetail.intLotId
			INNER JOIN vyuCTContractDetailView CT ON CT.intContractDetailId = Lots.intContractDetailId  and CT.intContractStatusId <> 3
			JOIN tblEMEntity e on e.intEntityId=CT.intEntityId
			JOIN tblICCommodityUnitMeasure ium on ium.intCommodityId=CT.intCommodityId AND CT.intUnitMeasureId=ium.intUnitMeasureId 
			INNER JOIN tblSMCompanyLocation  cl on cl.intCompanyLocationId=CT.intCompanyLocationId
			WHERE CT.intPricingTypeId = 2 AND CT.intCommodityId = @intCommodityId 
			AND CT.intCompanyLocationId  = case when isnull(@intLocationId,0)=0 then CT.intCompanyLocationId   else @intLocationId end
			AND CT.intEntityId= @intVendorId 

			UNION ALL
			
			SELECT 13 intSeqId,'Pur Basis Deliveries' strSeqHeader,@strDescription strCommodityCode,'Purchase Basis Deliveries' strType,
			dbo.fnCTConvertQuantityToTargetCommodityUOM(ium.intCommodityUnitMeasureId,@intCommodityUnitMeasureId,isnull(ri.dblReceived, 0))  AS dblTotal,
			st.intCommodityId,cl.strLocationName,cd.strItemNo,strName,strTicketNumber strTicket,st.dtmTicketDateTime,strCustomerReference,
					strDistributionOption,@intCommodityUnitMeasureId AS intCommodityUnitMeasureId,st.intProcessingLocationId intCompanyLocationId
			FROM tblICInventoryReceipt r
			INNER JOIN tblICInventoryReceiptItem ri ON r.intInventoryReceiptId = ri.intInventoryReceiptId AND r.strReceiptType = 'Purchase Contract'
			INNER JOIN tblSCTicket st ON st.intTicketId = ri.intSourceId  AND strDistributionOption IN ('CNT')
			JOIN tblEMEntity e on st.intEntityId=e.intEntityId
			INNER JOIN vyuCTContractDetailView cd ON cd.intContractDetailId = ri.intLineNo AND cd.intPricingTypeId = 2  and cd.intContractStatusId <> 3
			JOIN tblICCommodityUnitMeasure ium on ium.intCommodityId=cd.intCommodityId AND cd.intUnitMeasureId=ium.intUnitMeasureId 
			INNER JOIN tblSMCompanyLocation  cl on cl.intCompanyLocationId=st.intProcessingLocationId 
			WHERE cd.intCommodityId = @intCommodityId 
			AND st.intProcessingLocationId  = case when isnull(@intLocationId,0)=0 then st.intProcessingLocationId else @intLocationId end
			AND st.intEntityId= @intVendorId 
			)t 	WHERE intCompanyLocationId IN (
				SELECT intCompanyLocationId FROM tblSMCompanyLocation
				WHERE isnull(ysnLicensed, 0) = CASE WHEN @strPositionIncludes = 'licensed storage' THEN 1 
								WHEN @strPositionIncludes = 'Non-licensed storage' THEN 0 
								ELSE isnull(ysnLicensed, 0) END
				) 

	INSERT INTO @Final (intSeqId,strSeqHeader,strCommodityCode,strType,dblTotal,intCommodityId,strLocationName,strItemNo,strCustomer,strTicket,dtmTicketDateTime,strCustomerReference, 
						strDistributionOption,intFromCommodityUnitMeasureId,intCompanyLocationId )
			select * from (
			SELECT 14 intSeqId,'Sls Basis Deliveries' strSeqHeader,@strDescription strCommodityCode,'Sales Basis Deliveries' strType,
			dbo.fnCTConvertQuantityToTargetCommodityUOM(ium.intCommodityUnitMeasureId,@intCommodityUnitMeasureId,isnull(ri.dblQuantity, 0))  AS dblTotal,
			cd.intCommodityId,cl.strLocationName,cd.strItemNo,strName,convert(nvarchar,cd.strContractNumber)+'/'+convert(nvarchar,cd.intContractSeq) strTicketNumber,
			cd.dtmContractDate as dtmTicketDateTime ,
			cd.strCustomerContract as strCustomerReference, 'CNT' as strDistributionOption,cd.intUnitMeasureId,cl.intCompanyLocationId 
			FROM tblICInventoryShipment r
			INNER JOIN tblICInventoryShipmentItem ri ON r.intInventoryShipmentId = ri.intInventoryShipmentId
			INNER JOIN vyuCTContractDetailView cd ON cd.intContractDetailId = ri.intLineNo AND cd.intPricingTypeId = 2	and cd.intContractStatusId <> 3
			JOIN tblEMEntity e on r.intEntityId=cd.intEntityId
			JOIN tblICCommodityUnitMeasure ium on ium.intCommodityId=cd.intCommodityId AND cd.intUnitMeasureId=ium.intUnitMeasureId 
			INNER JOIN tblSMCompanyLocation  cl on cl.intCompanyLocationId=cd.intCompanyLocationId
			WHERE cd.intCommodityId = @intCommodityId 
			AND cl.intCompanyLocationId  = case when isnull(@intLocationId,0)=0 then cl.intCompanyLocationId else @intLocationId end
			and cd.intEntityId= @intVendorId )t
				WHERE intCompanyLocationId IN (
				SELECT intCompanyLocationId FROM tblSMCompanyLocation
				WHERE isnull(ysnLicensed, 0) = CASE WHEN @strPositionIncludes = 'licensed storage' THEN 1 
								WHEN @strPositionIncludes = 'Non-licensed storage' THEN 0 
								ELSE isnull(ysnLicensed, 0) END
				) 

	INSERT INTO @Final (intSeqId,strSeqHeader,strCommodityCode,strType,dblTotal,intCommodityId,strLocationName,strItemNo,strCustomer,strTicket,dtmTicketDateTime,strCustomerReference,
					 strDistributionOption,intFromCommodityUnitMeasureId,strTruckName,strDriverName,intCompanyLocationId)
	SELECT * FROM (
	SELECT 16 intSeqId,'On-Hold' strSeqHeader,@strDescription strCommodityCode,'On-Hold' strType,
		dbo.fnCTConvertQuantityToTargetCommodityUOM(ium.intCommodityUnitMeasureId,@intCommodityUnitMeasureId,isnull(st.dblNetUnits, 0))  AS dblTotal,
		st.intCommodityId,cl.strLocationName,i1.strItemNo,strName,strTicketNumber strTicket,st.dtmTicketDateTime,strCustomerReference,
				strDistributionOption,@intCommodityUnitMeasureId intCommodityUnitMeasureId
				,strTruckName
				,strDriverName,st.intProcessingLocationId  intCompanyLocationId
		FROM tblSCTicket st
		JOIN tblEMEntity e on e.intEntityId=st.intEntityId
		JOIN tblSMCompanyLocation  cl on cl.intCompanyLocationId=st.intProcessingLocationId and st.strDistributionOption='HLD'
		JOIN tblICItem i1 on i1.intItemId=st.intItemId
		JOIN tblICItemUOM iuom on i1.intItemId=iuom.intItemId and ysnStockUnit=1
		JOIN tblICCommodityUnitMeasure ium on ium.intCommodityId=i1.intCommodityId AND iuom.intUnitMeasureId=ium.intUnitMeasureId 
		WHERE st.intCommodityId  = @intCommodityId
			  AND st.intProcessingLocationId  = case when isnull(@intLocationId,0)=0 then st.intProcessingLocationId else @intLocationId end
			  AND st.intEntityId= @intVendorId )t
				WHERE intCompanyLocationId IN (
				SELECT intCompanyLocationId FROM tblSMCompanyLocation
				WHERE isnull(ysnLicensed, 0) = CASE WHEN @strPositionIncludes = 'licensed storage' THEN 1 
								WHEN @strPositionIncludes = 'Non-licensed storage' THEN 0 
								ELSE isnull(ysnLicensed, 0) END
				) 
END
		
DECLARE @intUnitMeasureId int
DECLARE @strUnitMeasure nvarchar(50)
SELECT TOP 1 @intUnitMeasureId = intUnitMeasureId FROM tblRKCompanyPreference
select @strUnitMeasure=strUnitMeasure from tblICUnitMeasure where intUnitMeasureId=@intUnitMeasureId
INSERT INTO @FinalTable (intSeqId,strSeqHeader, strCommodityCode ,strType ,dblTotal ,strUnitMeasure, intCollateralId,strLocationName,strCustomer,
				intReceiptNo,intContractHeaderId,strContractNumber ,dtmOpenDate,dblOriginalQuantity ,dblRemainingQuantity ,intCommodityId,
				strCustomerReference ,strDistributionOption ,strDPAReceiptNo,dblDiscDue ,[Storage Due] ,dtmLastStorageAccrueDate ,strScheduleId ,strTicket ,
				dtmDeliveryDate ,dtmTicketDateTime,strItemNo,strTruckName,strDriverName)

SELECT	intSeqId,strSeqHeader, strCommodityCode ,strType ,
			    Convert(decimal(24,10),dbo.fnCTConvertQuantityToTargetCommodityUOM(cuc.intCommodityUnitMeasureId,
		case when isnull(@intUnitMeasureId,0) = 0 then cuc.intCommodityUnitMeasureId else cuc1.intCommodityUnitMeasureId end,dblTotal)) dblTotal,
			case when isnull(@strUnitMeasure,'')='' then um.strUnitMeasure else @strUnitMeasure end as strUnitMeasure, intCollateralId,strLocationName,strCustomer,
		intReceiptNo,intContractHeaderId,strContractNumber ,dtmOpenDate,dblOriginalQuantity ,dblRemainingQuantity ,t.intCommodityId,
		strCustomerReference ,strDistributionOption ,strDPAReceiptNo ,
		dblDiscDue ,[Storage Due] ,	dtmLastStorageAccrueDate ,strScheduleId ,strTicket ,
		dtmDeliveryDate ,dtmTicketDateTime,strItemNo,strTruckName,strDriverName  
FROM @Final  t
	JOIN tblICCommodityUnitMeasure cuc on t.intCommodityId=cuc.intCommodityId and cuc.ysnDefault=1 
	JOIN tblICUnitMeasure um on um.intUnitMeasureId=cuc.intUnitMeasureId
	LEFT JOIN tblICCommodityUnitMeasure cuc1 on t.intCommodityId=cuc1.intCommodityId and @intUnitMeasureId=cuc1.intUnitMeasureId
	WHERE t.intCommodityId= @intCommodityId	
END

SELECT @mRowNumber = MIN(intCommodityIdentity)	FROM @Commodity	WHERE intCommodityIdentity > @mRowNumber
END  
END

if isnull(@intVendorId,0) = 0
BEGIN

SELECT intRow,intSeqId,strSeqHeader, strCommodityCode ,strType ,dblTotal ,strUnitMeasure, intCollateralId,strLocationName,strCustomer,
					intReceiptNo,intContractHeaderId,strContractNumber ,dtmOpenDate,dblOriginalQuantity ,dblRemainingQuantity ,intCommodityId,
					strCustomerReference ,strDistributionOption ,strDPAReceiptNo,dblDiscDue ,[Storage Due] as dblStorageDue ,dtmLastStorageAccrueDate ,strScheduleId ,strTicket ,
					dtmDeliveryDate ,dtmTicketDateTime,strItemNo,strTruckName,strDriverName			
FROM @FinalTable WHERE dblTotal <> 0
 ORDER BY strCommodityCode,intSeqId ASC,intContractHeaderId DESC
END
ELSE
BEGIN
SELECT intRow,intSeqId,strSeqHeader, strCommodityCode ,strType ,dblTotal ,strUnitMeasure, intCollateralId,strLocationName,strCustomer,
					intReceiptNo,intContractHeaderId,strContractNumber ,dtmOpenDate,dblOriginalQuantity ,dblRemainingQuantity ,intCommodityId,
					strCustomerReference ,strDistributionOption ,strDPAReceiptNo,dblDiscDue ,[Storage Due] as dblStorageDue ,dtmLastStorageAccrueDate ,strScheduleId ,strTicket ,
					dtmDeliveryDate ,dtmTicketDateTime,strItemNo,strTruckName,strDriverName			
FROM @FinalTable WHERE dblTotal <> 0 and strType <> 'Company Titled Stock' and strType not like '%'+@strPurchaseSales+'%'
 ORDER BY strCommodityCode,intSeqId ASC,intContractHeaderId DESC
END