CREATE PROCEDURE [dbo].[uspRKDPRSubInvPositionByCommodity] 
	 @intCommodityId nvarchar(max)  
	,@intLocationId int = NULL	
	,@intVendorId int = null
	,@strPurchaseSales nvarchar(250) = NULL
	,@strPositionIncludes nvarchar(100) = NULL
	,@dtmToDate datetime=null
	,@strByType nvarchar(50) = null
AS


BEGIN

SET @dtmToDate = convert(DATETIME, CONVERT(VARCHAR(10), @dtmToDate, 110), 110)
DECLARE @ysnDisplayAllStorage bit
DECLARE @ysnIncludeDPPurchasesInCompanyTitled bit
SELECT @ysnDisplayAllStorage= isnull(ysnDisplayAllStorage,0) ,@ysnIncludeDPPurchasesInCompanyTitled = isnull(ysnIncludeDPPurchasesInCompanyTitled,0) FROM tblRKCompanyPreference

DECLARE @Commodity AS TABLE 
(
	intCommodityIdentity int IDENTITY(1,1) PRIMARY KEY , 
	intCommodity  INT
)

IF(@strByType='ByCommodity')
BEGIN
	INSERT INTO @Commodity(intCommodity)
	SELECT intCommodityId from tblICCommodity 
END
ELSE
BEGIN
	INSERT INTO @Commodity(intCommodity)
	SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCommodityId, ',')  
END	

IF ISNULL(@strPurchaseSales,'') <> ''
BEGIN
	IF @strPurchaseSales='Purchase'
	BEGIN
		SELECT @strPurchaseSales='Sales'
	END
	ELSE
	BEGIN
		SELECT @strPurchaseSales='Purchase'
	END
END

SELECT intCompanyLocationId
INTO #LicensedLocation
FROM tblSMCompanyLocation
WHERE ISNULL(ysnLicensed, 0) = CASE WHEN @strPositionIncludes = 'Licensed Storage' THEN 1
									WHEN @strPositionIncludes = 'Non-licensed Storage' THEN 0
									ELSE ISNULL(ysnLicensed, 0) END

DECLARE @Final AS TABLE (intRow int IDENTITY(1,1) PRIMARY KEY
	,intSeqId int
	,strSeqHeader nvarchar(100)
	,strCommodityCode nvarchar(100)
	,strType nvarchar(100)
	,dblTotal DECIMAL(24,10)
	,intCollateralId int
	,strLocationName nvarchar(250)
	,strCustomer nvarchar(250)
	,intReceiptNo nvarchar(250)
	,intContractHeaderId int
	,strContractNumber nvarchar(100)
	,strCustomerReference nvarchar(100)
	,strDistributionOption nvarchar(100)
	,strDPAReceiptNo nvarchar(100)
	,dblDiscDue DECIMAL(24,10)
	,[Storage Due] DECIMAL(24,10)
	,dtmLastStorageAccrueDate datetime
	,strScheduleId nvarchar(100)
	,strTicket nvarchar(100)
	,dtmOpenDate datetime
	,dtmDeliveryDate datetime
	,dtmTicketDateTime datetime
	,dblOriginalQuantity  DECIMAL(24,10)
	,dblRemainingQuantity DECIMAL(24,10)
	,intCommodityId int
	,strItemNo nvarchar(100)
	,strUnitMeasure nvarchar(100)
	,intFromCommodityUnitMeasureId int
	,intToCommodityUnitMeasureId int
	,strTruckName  nvarchar(100)
	,strDriverName  nvarchar(100)
	,intCompanyLocationId int
	,intStorageScheduleTypeId int
	,intItemId int
	,intTicketId int
	,strTicketNumber nvarchar(100)
	,strShipmentNumber nvarchar(100)
	,intInventoryShipmentId int
	,intInventoryReceiptId int
	,strReceiptNumber  nvarchar(100)
)

DECLARE @FinalTable AS TABLE (intRow int IDENTITY(1,1) PRIMARY KEY
	,intSeqId int
	,strSeqHeader nvarchar(100)
	,strCommodityCode nvarchar(100)
	,strType nvarchar(100)
	,dblTotal DECIMAL(24,10)
	,intCollateralId int
	,strLocationName nvarchar(250)
	,strCustomer nvarchar(250)
	,intReceiptNo nvarchar(250)
	,intContractHeaderId int
	,strContractNumber nvarchar(100)
	,strCustomerReference nvarchar(100)
	,strDistributionOption nvarchar(100)
	,strDPAReceiptNo nvarchar(100)
	,dblDiscDue DECIMAL(24,10)
	,[Storage Due] DECIMAL(24,10)
	,dtmLastStorageAccrueDate datetime
	,strScheduleId nvarchar(100)
	,strTicket nvarchar(100)
	,dtmOpenDate datetime
	,dtmDeliveryDate datetime
	,dtmTicketDateTime datetime
	,dblOriginalQuantity  DECIMAL(24,10)
	,dblRemainingQuantity DECIMAL(24,10)
	,intCommodityId int
	,strItemNo nvarchar(100)
	,strUnitMeasure nvarchar(100)
	,intFromCommodityUnitMeasureId int
	,intToCommodityUnitMeasureId int
	,strTruckName  nvarchar(100)
	,strDriverName  nvarchar(100)
	,intCompanyLocationId int
	,intItemId int
	,intTicketId int
	,strTicketNumber nvarchar(100)
	,strShipmentNumber nvarchar(100)
	,intInventoryShipmentId int
	,intInventoryReceiptId int
	,strReceiptNumber  nvarchar(100)
)


--===============================
-- CONTRACTS
--================================
DECLARE @tblGetOpenContractDetail TABLE (
	  intRowNum int
	,strCommodityCode  NVARCHAR(200)
	,intCommodityId int
	,intContractHeaderId int
	,strContractNumber  NVARCHAR(200)
	,strLocationName  NVARCHAR(200)
	,dtmEndDate datetime
	,dblBalance DECIMAL(24,10)
	,intUnitMeasureId int
	,intPricingTypeId int
	,intContractTypeId int
	,intCompanyLocationId int
	,strContractType  NVARCHAR(200)
	,strPricingType  NVARCHAR(200)
	,intCommodityUnitMeasureId int
	,intContractDetailId int
	,intContractStatusId int
	,intEntityId int
	,intCurrencyId int
	,strType	  NVARCHAR(200)
	,intItemId int
	,strItemNo  NVARCHAR(200)
	,dtmContractDate datetime
	,strEntityName  NVARCHAR(200)
	,strCustomerContract  NVARCHAR(200)
	,intFutureMarketId int
	,intFutureMonthId int
	,strCurrency NVARCHAR(200)
)

INSERT INTO @tblGetOpenContractDetail(
	 intRowNum
	,strCommodityCode
    ,intCommodityId
    ,intContractHeaderId
    ,strContractNumber
    ,strLocationName
    ,dtmEndDate
    ,dblBalance
    ,intUnitMeasureId
    ,intPricingTypeId
    ,intContractTypeId
    ,intCompanyLocationId
    ,strContractType
    ,strPricingType
    ,intCommodityUnitMeasureId
    ,intContractDetailId
    ,intContractStatusId
    ,intEntityId
    ,intCurrencyId
    ,strType
    ,intItemId
    ,strItemNo
    ,strEntityName
    ,strCustomerContract
    ,intFutureMarketId
    ,intFutureMonthId
    ,strCurrency)
SELECT  
     ROW_NUMBER() OVER (PARTITION BY CD.intContractDetailId ORDER BY dtmContractDate DESC) intRowNum
    ,strCommodityCode
    ,intCommodityId
    ,intContractHeaderId
    ,strContractNumber
    ,strLocationName
    ,dtmEndDate
    ,CD.dblBalance
    ,intUnitMeasureId
    ,intPricingTypeId
    ,intContractTypeId
    ,intCompanyLocationId
    ,strContractType
    ,strPricingType
    ,intCommodityUnitMeasureId
    ,CD.intContractDetailId
    ,intContractStatusId
    ,intEntityId
    ,intCurrencyId
    ,strType
    ,intItemId
    ,strItemNo
    ,strEntityName
    ,strCustomerContract
    ,NULL intFutureMarketId
    ,NULL intFutureMonthId
    ,strCurrency 
FROM [dbo].fnRKGetContractDetail(@dtmToDate) CD
WHERE CONVERT(DATETIME, CONVERT(VARCHAR(10), dtmContractDate, 110), 110) <= @dtmToDate 
	AND CD.intCommodityId in (select intCommodity from @Commodity)

--=============================================================
-- STORAGE
--=============================================================
DECLARE @tblGetStorageDetailByDate TABLE (
	 intRowNum int
	,intCustomerStorageId int
	,intCompanyLocationId int	
	,[Loc] NVARCHAR(200)
	,[Delivery Date] datetime
	,[Ticket] NVARCHAR(200)
	,intEntityId int
	,[Customer] NVARCHAR(200)
	,[Receipt] NVARCHAR(200)
	,[Disc Due] numeric(24,10)
	,[Storage Due] numeric(24,10)
	,[Balance] numeric(24,10)
	,intStorageTypeId int
	,[Storage Type] NVARCHAR(200)
	,intCommodityId int
	,[Commodity Code] NVARCHAR(200)
	,[Commodity Description] NVARCHAR(200)
	,strOwnedPhysicalStock NVARCHAR(200)
	,ysnReceiptedStorage bit
	,ysnDPOwnedType bit
	,ysnGrainBankType bit
	,ysnCustomerStorage bit
	,strCustomerReference  NVARCHAR(200)
 	,dtmLastStorageAccrueDate  datetime
 	,strScheduleId NVARCHAR(200)
	,strItemNo NVARCHAR(200)
	,strLocationName NVARCHAR(200)
	,intCommodityUnitMeasureId int
	,intItemId int
	,intTicketId int
	,strTicketNumber NVARCHAR(200)
)

INSERT INTO @tblGetStorageDetailByDate
SELECT 
	ROW_NUMBER() OVER (PARTITION BY a.intCustomerStorageId ORDER BY a.intCustomerStorageId DESC) intRowNum
	,a.intCustomerStorageId
	,a.intCompanyLocationId	
	,c.strLocationName [Loc]
	,CONVERT(DATETIME,CONVERT(VARCHAR(10),a.dtmDeliveryDate ,110),110) [Delivery Date]
	,a.strStorageTicketNumber [Ticket]
	,a.intEntityId
	,E.strName [Customer]
	,a.strDPARecieptNumber [Receipt]
	,a.dblDiscountsDue [Disc Due]
	,a.dblStorageDue   [Storage Due]
	,(case when gh.strType ='Reduced By Inventory Shipment' OR gh.strType = 'Settlement' then -gh.dblUnits else gh.dblUnits   end) [Balance]
	,a.intStorageTypeId
	,b.strStorageTypeDescription [Storage Type]
	,a.intCommodityId
	,CM.strCommodityCode [Commodity Code]
	,CM.strDescription   [Commodity Description]
	,b.strOwnedPhysicalStock
	,b.ysnReceiptedStorage
	,b.ysnDPOwnedType
	,b.ysnGrainBankType
	,b.ysnActive ysnCustomerStorage 
	,a.strCustomerReference  
 	,a.dtmLastStorageAccrueDate  
 	,c1.strScheduleId
	,i.strItemNo
	,c.strLocationName
	,ium.intCommodityUnitMeasureId as intCommodityUnitMeasureId
	,i.intItemId as intItemId  
	,t.intTicketId
	,t.strTicketNumber
FROM tblGRStorageHistory gh
	JOIN tblGRCustomerStorage a  on gh.intCustomerStorageId=a.intCustomerStorageId
	JOIN tblGRStorageType b ON b.intStorageScheduleTypeId = a.intStorageTypeId
	JOIN tblICItem i on i.intItemId=a.intItemId
	JOIN tblICItemUOM iuom on i.intItemId=iuom.intItemId and ysnStockUnit=1
	JOIN tblICCommodityUnitMeasure ium on ium.intCommodityId=i.intCommodityId AND iuom.intUnitMeasureId=ium.intUnitMeasureId 
	LEFT JOIN tblGRStorageScheduleRule c1 on c1.intStorageScheduleRuleId=a.intStorageScheduleId  
	JOIN tblSMCompanyLocation c ON c.intCompanyLocationId=a.intCompanyLocationId
	JOIN tblEMEntity E ON E.intEntityId=a.intEntityId
	JOIN tblICCommodity CM ON CM.intCommodityId=a.intCommodityId
	LEFT JOIN tblSCTicket t on t.intTicketId=gh.intTicketId
WHERE ISNULL(a.strStorageType,'') <> 'ITR'  
	AND isnull(a.intDeliverySheetId,0) = 0 
	AND isnull(strTicketStatus,'') <> 'V' 
	AND gh.intTransactionTypeId IN (1,3,4,5,9)
	AND convert(DATETIME, CONVERT(VARCHAR(10), dtmHistoryDate, 110), 110) <= convert(datetime,@dtmToDate) 
	AND i.intCommodityId in (select intCommodity from @Commodity)

UNION ALL
SELECT 
	ROW_NUMBER() OVER (PARTITION BY a.intCustomerStorageId ORDER BY a.intCustomerStorageId DESC) intRowNum
	,a.intCustomerStorageId
	,a.intCompanyLocationId	
	,c.strLocationName [Loc]
	,CONVERT(DATETIME,CONVERT(VARCHAR(10),a.dtmDeliveryDate ,110),110) [Delivery Date]
	,a.strStorageTicketNumber [Ticket]
	,a.intEntityId
	,E.strName [Customer]
	,a.strDPARecieptNumber [Receipt]
	,a.dblDiscountsDue [Disc Due]
	,a.dblStorageDue   [Storage Due]
	,(case when gh.strType ='Reduced By Inventory Shipment'  OR gh.strType = 'Settlement' then -gh.dblUnits else gh.dblUnits   end) [Balance]
	,a.intStorageTypeId
	,b.strStorageTypeDescription [Storage Type]
	,a.intCommodityId
	,CM.strCommodityCode [Commodity Code]
	,CM.strDescription   [Commodity Description]
	,b.strOwnedPhysicalStock
	,b.ysnReceiptedStorage
	,b.ysnDPOwnedType
	,b.ysnGrainBankType
	,b.ysnActive ysnCustomerStorage 
	,a.strCustomerReference  
 	,a.dtmLastStorageAccrueDate  
 	,c1.strScheduleId
	,i.strItemNo
	,c.strLocationName
	,ium.intCommodityUnitMeasureId as intCommodityUnitMeasureId
	,i.intItemId as intItemId  
	,null intTicketId
	,'' strTicketNumber
FROM tblGRStorageHistory gh
	JOIN tblGRCustomerStorage a  on gh.intCustomerStorageId=a.intCustomerStorageId
	JOIN tblGRStorageType b ON b.intStorageScheduleTypeId = a.intStorageTypeId
	JOIN tblICItem i on i.intItemId=a.intItemId
	JOIN tblICItemUOM iuom on i.intItemId=iuom.intItemId and ysnStockUnit=1
	JOIN tblICCommodityUnitMeasure ium on ium.intCommodityId=i.intCommodityId AND iuom.intUnitMeasureId=ium.intUnitMeasureId 
	LEFT JOIN tblGRStorageScheduleRule c1 on c1.intStorageScheduleRuleId=a.intStorageScheduleId  
	JOIN tblSMCompanyLocation c ON c.intCompanyLocationId=a.intCompanyLocationId
	JOIN tblEMEntity E ON E.intEntityId=a.intEntityId
	JOIN tblICCommodity CM ON CM.intCommodityId=a.intCommodityId
WHERE ISNULL(a.strStorageType,'') <> 'ITR'  
	AND isnull(a.intDeliverySheetId,0) <>0 
	AND gh.intTransactionTypeId IN (1,3,4,5,9)
	AND convert(DATETIME, CONVERT(VARCHAR(10), dtmHistoryDate, 110), 110) <= convert(datetime,@dtmToDate) 
	AND i.intCommodityId in (select intCommodity from @Commodity)


--========================================
-- COLLATERAL
--=========================================
DECLARE @tempCollateral TABLE (		
	 intRowNum int
	,intCollateralId int
	,strLocationName NVARCHAR(200)
	,strItemNo NVARCHAR(200)
	,strEntityName NVARCHAR(200)
	,intReceiptNo NVARCHAR(100)
	,intContractHeaderId int
	,strContractNumber NVARCHAR(200)
	,dtmOpenDate datetime
	,dblOriginalQuantity numeric(24,10)
	,dblRemainingQuantity numeric(24,10)
	,intCommodityId int
	,intUnitMeasureId int
	,intCompanyLocationId int
	,intContractTypeId int
	,intLocationId int
	,intEntityId int
	,strCommodityCode NVARCHAR(200)
)

INSERT INTO @tempCollateral
SELECT * 
FROM (
	SELECT  
		ROW_NUMBER() OVER (PARTITION BY intCollateralId ORDER BY dtmOpenDate DESC) intRowNum
		,c.intCollateralId
		,cl.strLocationName
		,ch.strItemNo
		,ch.strEntityName
		,c.intReceiptNo
		,ch.intContractHeaderId
		,strContractNumber
		, c.dtmOpenDate
		,isnull(c.dblOriginalQuantity,0) dblOriginalQuantity
		,isnull(c.dblRemainingQuantity,0) dblRemainingQuantity
		,c.intCommodityId as intCommodityId
		,c.intUnitMeasureId
		,c.intLocationId intCompanyLocationId
		,case when c.strType='Purchase' then 1 else 2 end	intContractTypeId
		,c.intLocationId,intEntityId,co.strCommodityCode
	FROM tblRKCollateral c
		JOIN tblICCommodity co on co.intCommodityId=c.intCommodityId
		JOIN tblICCommodityUnitMeasure ium on ium.intCommodityId=c.intCommodityId AND c.intUnitMeasureId=ium.intUnitMeasureId 
		JOIN tblSMCompanyLocation cl on cl.intCompanyLocationId=c.intLocationId
		LEFT JOIN @tblGetOpenContractDetail ch on c.intContractHeaderId=ch.intContractHeaderId and ch.intContractStatusId <> 3
	WHERE c.intCommodityId in (select intCommodity from @Commodity)
		AND convert(DATETIME, CONVERT(VARCHAR(10), dtmOpenDate, 110), 110) <= convert(datetime,@dtmToDate) 
		AND  c.intLocationId IN (SELECT intCompanyLocationId FROM #LicensedLocation)						
) a WHERE a.intRowNum =1


--========================
-- INVENTORY VALUATION
--========================
DECLARE @invQty TABLE (		
	 dblTotal numeric(24,10)
	,Ticket NVARCHAR(200)	
	,strLocationName NVARCHAR(200)
	,strItemNo NVARCHAR(200)
	,intCommodityId int
	,intFromCommodityUnitMeasureId int
	,intLocationId int
	,strTransactionId  NVARCHAR(200)
	,strTransactionType NVARCHAR(200)
	,intItemId int
	,strDistributionOption NVARCHAR(200)
	,strTicketStatus NVARCHAR(200)
	,intEntityId INT
)

INSERT INTO @invQty
SELECT 
	dblTotal = dbo.fnCalculateQtyBetweenUOM(iuomStck.intItemUOMId, iuomTo.intItemUOMId, (ISNULL(s.dblQuantity ,0)))
	,t.strTicketNumber Ticket
	,s.strLocationName
	,s.strItemNo
	,i.intCommodityId intCommodityId
	,intCommodityUnitMeasureId intFromCommodityUnitMeasureId
	,s.intLocationId intLocationId
	,strTransactionId
	,strTransactionType
	,i.intItemId
	,t.strDistributionOption
	,strTicketStatus
	,s.intEntityId	
FROM vyuRKGetInventoryValuation s  		
	JOIN tblICItem i on i.intItemId=s.intItemId
	JOIN tblICCommodityUnitMeasure cuom ON i.intCommodityId = cuom.intCommodityId AND cuom.ysnStockUnit = 1
	JOIN tblICItemUOM iuomStck ON s.intItemId = iuomStck.intItemId AND iuomStck.ysnStockUnit = 1
	JOIN tblICItemUOM iuomTo ON s.intItemId = iuomTo.intItemId AND iuomTo.intUnitMeasureId = cuom.intUnitMeasureId
	LEFT JOIN tblSCTicket t on s.intSourceId = t.intTicketId		  
WHERE i.intCommodityId in (select intCommodity from @Commodity) AND ISNULL(s.dblQuantity,0) <>0 
	AND s.intLocationId= CASE WHEN ISNULL(@intLocationId,0)=0 then s.intLocationId else @intLocationId end and isnull(strTicketStatus,'') <> 'V'
	AND isnull(s.intEntityId,0) = case when isnull(@intVendorId,0)=0 then isnull(s.intEntityId,0) else @intVendorId end
	AND convert(DATETIME, CONVERT(VARCHAR(10), s.dtmDate, 110), 110)<=convert(datetime,@dtmToDate) 
	--AND isnull(t.strDistributionOption,'') <> 'DP'
	AND ysnInTransit = 0
	AND s.intLocationId  IN (SELECT intCompanyLocationId FROM #LicensedLocation)

--========================
-- ON HOLD
--========================

DECLARE @tempOnHold TABLE (		
	dblTotal numeric(24,10)
	,strCustomer NVARCHAR(200)	
	,strLocationName NVARCHAR(200)
	,intCommodityId int
	,intCommodityUnitMeasureId int
	,intLocationId int
	,intEntityId  int
)

INSERT INTO @tempOnHold(
	dblTotal
	,strCustomer
	,strLocationName
	,intCommodityId
	,intCommodityUnitMeasureId
	,intLocationId
	,intEntityId
)
SELECT  
	dblTotal
	,strCustomer
	,strLocationName
	,intCommodityId
	,intCommodityUnitMeasureId
	,intLocationId
	,intEntityId 
FROM (
	SELECT  
		ROW_NUMBER() OVER (PARTITION BY st.intTicketId ORDER BY st.dtmTicketDateTime DESC) intSeqId
		,case when st.strInOutFlag = 'I' then  st.dblNetUnits else abs(st.dblNetUnits) * -1 end  AS dblTotal
		,strName strCustomer
		,cl.strLocationName
		, st.intCommodityId
		,intCommodityUnitMeasureId
		, st.intProcessingLocationId intLocationId
		,e.intEntityId
	FROM tblSCTicket st 
		JOIN tblEMEntity e on e.intEntityId= st.intEntityId
		JOIN tblSMCompanyLocation  cl on cl.intCompanyLocationId=st.intProcessingLocationId and st.strDistributionOption='HLD'
		JOIN tblICItem i1 on i1.intItemId=st.intItemId
		JOIN tblICItemUOM iuom on i1.intItemId=iuom.intItemId and ysnStockUnit=1
		JOIN tblICCommodityUnitMeasure ium on ium.intCommodityId=i1.intCommodityId AND iuom.intUnitMeasureId=ium.intUnitMeasureId 
	WHERE i1.intCommodityId  in(select intCommodity from @Commodity) 
		AND isnull(st.intDeliverySheetId,0) =0
		AND st.intProcessingLocationId  = CASE WHEN ISNULL(@intLocationId,0)=0 then st.intProcessingLocationId else @intLocationId end
		AND convert(DATETIME, CONVERT(VARCHAR(10), st.dtmTicketDateTime, 110), 110) <=CONVERT(DATETIME,@dtmToDate)
		AND isnull(strTicketStatus,'') = 'H'
)t 	
WHERE intLocationId IN (SELECT intCompanyLocationId FROM #LicensedLocation)
	AND t.intSeqId =1 

--========================
-- Building of data
--========================

DECLARE @mRowNumber INT
DECLARE @intCommodityId1 INT
DECLARE @strDescription nvarchar(250)
DECLARE @intCommodityUnitMeasureId int

SELECT @mRowNumber = MIN(intCommodityIdentity) FROM @Commodity where intCommodity>0

WHILE @mRowNumber > 0
BEGIN
	SELECT @intCommodityId = intCommodity FROM @Commodity WHERE intCommodityIdentity = @mRowNumber
	SELECT @strDescription = strCommodityCode FROM tblICCommodity WHERE intCommodityId = @intCommodityId
	SELECT @intCommodityUnitMeasureId=intCommodityUnitMeasureId FROM tblICCommodityUnitMeasure WHERE intCommodityId=@intCommodityId and ysnDefault=1

	IF isnull(@intCommodityId,0) > 0
	BEGIN

		IF ISNULL(@intVendorId,0) = 0
		BEGIN
			--Inventory
			INSERT INTO @Final(
				intSeqId
				,strSeqHeader
				,strType
				,dblTotal
				,strLocationName
				,intCommodityId
				,intFromCommodityUnitMeasureId
				,intCompanyLocationId
				,strDistributionOption
			)
			SELECT 
				intSeqId
				,strSeqHeader
				,strType
				,(dbo.fnCTConvertQuantityToTargetCommodityUOM(intFromCommodityUnitMeasureId,@intCommodityUnitMeasureId,isnull(dblTotal ,0))) dblTotal
				,strLocationName
				,intCommodityId
				,intFromCommodityUnitMeasureId
				,intCompanyLocationId 
				,strDistributionOption
			FROM(
				select  
					1 as intSeqId
					,'In-House' strSeqHeader
					,'Receipt' as [strType]
					,isnull(dblTotal,0) dblTotal
					,strLocationName
					,intItemId
					,strItemNo
					,intCommodityId
					,intFromCommodityUnitMeasureId
					,intLocationId intCompanyLocationId
					,strDistributionOption
				from @invQty 
				where intCommodityId = @intCommodityId 
					and isnull(strTicketStatus,0) <> 'V' 
					--and ISNULL(strDistributionOption,'') <> 'DP'
					and isnull(intEntityId,0) = case when isnull(@intVendorId,0)=0 then isnull(intEntityId,0) else @intVendorId end
			)t
			--group by intSeqId,strSeqHeader,strType,strLocationName,intItemId,strItemNo,intCommodityId,intFromCommodityUnitMeasureId,intCompanyLocationId
		END

		--Contracts
		INSERT INTO @Final(
			intSeqId
			,strSeqHeader
			,strType
			,dblTotal
			,strLocationName
			,intCommodityId
			,intFromCommodityUnitMeasureId
			,intCompanyLocationId
		)
		SELECT 
			1 intSeqId
			,strSeqHeader
			,strType,dblTotal
			,strLocationName
			,intCommodityId
			,intFromCommodityUnitMeasureId,intCompanyLocationId 
		FROM(
			select 
				'In-House' strSeqHeader
				,[Storage Type] AS [strType]
				,dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId,@intCommodityUnitMeasureId,Balance)  dblTotal
				,strName strCustomer
				,intTicketId
				,strTicketNumber
				,[Delivery Date] dtmDeliveryDate
				,strLocationName
				,strItemNo
				,intCommodityId
				,intCommodityUnitMeasureId intFromCommodityUnitMeasureId
				,intCompanyLocationId
			from @tblGetStorageDetailByDate s
				join tblEMEntity e on e.intEntityId= s.intEntityId
			where intCommodityId = @intCommodityId 
				and intCompanyLocationId= case when isnull(@intLocationId,0)=0 then intCompanyLocationId else @intLocationId end
				and isnull(s.intEntityId,0) = case when isnull(@intVendorId,0)=0 then isnull(s.intEntityId,0) else @intVendorId end
				and ysnDPOwnedType <> 1 
				and strOwnedPhysicalStock <> 'Company' --Remove DP type storage in in-house. Stock already increases in IR.
				and intCompanyLocationId   IN (SELECT intCompanyLocationId FROM #LicensedLocation)
		)t 

		--On Hold
		INSERT INTO @Final(
			intSeqId
			,strSeqHeader
			,strType
			,dblTotal
			,strLocationName
			,intCommodityId
			,intFromCommodityUnitMeasureId
			,intCompanyLocationId
		)
		SELECT 
			intSeqId
			,strSeqHeader
			,strType
			,sum(dblTotal) dblTotal
			,strLocationName
			,intCommodityId
			,intCommodityUnitMeasureId intFromCommodityUnitMeasureId
			,intCompanyLocationId 
		FROM(
			select distinct  
				1 intSeqId
				,'In-House' strSeqHeader
				,'On-Hold' strType
				,dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId,@intCommodityUnitMeasureId,dblTotal) dblTotal
				,strCustomer
				,strLocationName
				,intCommodityId
				,intCommodityUnitMeasureId
				,intLocationId intCompanyLocationId
			from @tempOnHold
			where intCommodityId = @intCommodityId
				and isnull(intEntityId,0) = case when isnull(@intVendorId,0)=0 then isnull(intEntityId,0) else @intVendorId end
		)t
		GROUP BY intSeqId,strSeqHeader,strType,strCustomer,strLocationName,intCommodityId,intCommodityUnitMeasureId,intCompanyLocationId
	
		--Collatral Sale
		INSERT INTO @Final(
			intSeqId
			,strSeqHeader
			,strType
			,dblTotal
			,strLocationName
			,intCommodityId
			,intFromCommodityUnitMeasureId
			,intCompanyLocationId
		)
		SELECT 
			intSeqId
			,strSeqHeader
			,strType
			,dblTotal
			,strLocationName
			,intCommodityId
			,intUnitMeasureId intFromCommodityUnitMeasureId
			,intCompanyLocationId 
		FROM (
			select 
				8 intSeqId
				,'Collateral Receipts - Sales' strSeqHeader
				,strCommodityCode
				,'Collateral Receipts - Sales' strType
				,dblRemainingQuantity dblTotal
				,intCollateralId
				,strLocationName
				,strItemNo
				,strEntityName
				,intReceiptNo
				,intContractHeaderId
				,strContractNumber
				,dtmOpenDate
				,dblOriginalQuantity
				,dblRemainingQuantity 
				,intCommodityId
				,intUnitMeasureId
				,intCompanyLocationId
			from @tempCollateral
			where intContractTypeId = 2 
				and intCommodityId = @intCommodityId
				and intLocationId = case when isnull(@intLocationId,0)=0 then intLocationId  else @intLocationId end
				and isnull(intEntityId,0) = case when isnull(@intVendorId,0)=0 then isnull(intEntityId,0) else @intVendorId end
		)t 
		WHERE intCompanyLocationId  IN (SELECT intCompanyLocationId FROM #LicensedLocation)


		-- Collatral Purchase
		INSERT INTO @Final(
			intSeqId
			,strSeqHeader
			,strType
			,dblTotal
			,strLocationName
			,intCommodityId
			,intFromCommodityUnitMeasureId
			,intCompanyLocationId
		)
		SELECT 
			intSeqId
			,strSeqHeader
			,strType
			,dblTotal
			,strLocationName
			,intCommodityId
			,intUnitMeasureId
			,intCompanyLocationId 
		FROM (
			select 
				9 intSeqId
				,'Collateral Receipts - Purchase' strSeqHeader
				,strCommodityCode
				,'Collateral Receipts - Purchase' strType
				,dblRemainingQuantity  dblTotal
				,intCollateralId
				,strLocationName
				,strItemNo
				,strEntityName
				,intReceiptNo
				,intContractHeaderId
				,strContractNumber
				,dtmOpenDate
				,dblOriginalQuantity
				,dblRemainingQuantity
				,intCommodityId
				,intUnitMeasureId
				,intCompanyLocationId
			from @tempCollateral 
			where intContractTypeId = 1 
				and intCommodityId = @intCommodityId
				and intLocationId = case when isnull(@intLocationId,0)=0 then intLocationId  else @intLocationId end
				and isnull(intEntityId,0) = case when isnull(@intVendorId,0)=0 then isnull(intEntityId,0) else @intVendorId end
		)t
		WHERE intCompanyLocationId IN (SELECT intCompanyLocationId FROM #LicensedLocation)

		-- Sales Basis Deliveries
		INSERT INTO @Final (
			intSeqId
			,strSeqHeader
			,strType
			,dblTotal
			,strLocationName
			,intCommodityId
			,intFromCommodityUnitMeasureId
			,intCompanyLocationId
		)
		SELECT 
			intSeqId
			,strSeqHeader
			,strType
			,dblTotal
			,strLocationName
			,intCommodityId
			,intUnitMeasureId intFromCommodityUnitMeasureId
			,intCompanyLocationId 
		FROM (
			select distinct 
				14 intSeqId
				,'Sales Basis Deliveries' strSeqHeader
				,@strDescription strCommodityCode
				,'Sales Basis Deliveries' strType
				,dbo.fnCTConvertQuantityToTargetCommodityUOM(ium.intCommodityUnitMeasureId,@intCommodityUnitMeasureId,isnull(ri.dblQuantity, 0)) AS dblTotal
				,cd.intCommodityId
				,cl.strLocationName
				,cd.strItemNo
				,strContractNumber strTicketNumber
				,cd.dtmContractDate as dtmTicketDateTime
				,cd.strCustomerContract as strCustomerReference
				,'CNT' as strDistributionOption
				,cd.intUnitMeasureId
				,cl.intCompanyLocationId
				,r.strShipmentNumber
				,cd.strContractNumber
				,r.intInventoryShipmentId
				,r.strShipmentNumber strShipmentNumber1
			from vyuRKGetInventoryValuation v 
				join tblICInventoryShipment r on r.strShipmentNumber=v.strTransactionId
				inner join tblICInventoryShipmentItem ri ON r.intInventoryShipmentId = ri.intInventoryShipmentId
				inner join @tblGetOpenContractDetail cd ON cd.intContractDetailId = ri.intLineNo AND cd.intPricingTypeId = 2	and cd.intContractStatusId <> 3  AND cd.intContractTypeId = 2
				join tblICCommodityUnitMeasure ium on ium.intCommodityId=cd.intCommodityId AND cd.intUnitMeasureId=ium.intUnitMeasureId 
				inner join tblSMCompanyLocation  cl on cl.intCompanyLocationId=cd.intCompanyLocationId
				left join tblARInvoiceDetail invD ON ri.intInventoryShipmentItemId = invD.intInventoryShipmentItemId
				left join tblARInvoice inv ON invD.intInvoiceId = inv.intInvoiceId
			where cd.intCommodityId = @intCommodityId AND v.strTransactionType ='Inventory Shipment'
				and cl.intCompanyLocationId  = case when isnull(@intLocationId,0)=0 then cl.intCompanyLocationId else @intLocationId end
				and convert(DATETIME, CONVERT(VARCHAR(10), v.dtmDate, 110), 110)<=convert(datetime,@dtmToDate)
				and inv.intInvoiceId IS NULL
		)t
		WHERE intCompanyLocationId IN (SELECT intCompanyLocationId FROM #LicensedLocation)

		--Company Title
		INSERT INTO @Final(
			intSeqId
			,strSeqHeader
			,strType
			,dblTotal
			,strLocationName
			,intCommodityId
			,intFromCommodityUnitMeasureId
			,intCompanyLocationId
		)
		SELECT 
			intSeqId
			,strSeqHeader
			,strType
			,sum(dblTotal) dblTotal
			,strLocationName
			,intCommodityId
			,intFromCommodityUnitMeasureId
			,intCompanyLocationId 
		FROM (
			select 
				15 intSeqId
				,'Company Titled Stock' strSeqHeader
				,strCommodityCode
				,'Receipt' strType
				,dblTotal 
				,strLocationName
				,intItemId
				,strItemNo
				,intCommodityId
				,intFromCommodityUnitMeasureId
				,intCompanyLocationId 
			from @Final 
			where strSeqHeader='In-House' 
				and strType='Receipt' 
				and intCommodityId =@intCommodityId
				--and ISNULL(strDistributionOption,'') <> 'DP' Will going to include DP here but subtract in the bottom using the company pref
		)t
		GROUP BY intSeqId,strSeqHeader,strType,strLocationName,intCommodityId,intFromCommodityUnitMeasureId,intCompanyLocationId

		-- Company Title with Collateral
		INSERT INTO @Final(
			intSeqId
			,strSeqHeader
			,strCommodityCode
			,strType
			,dblTotal
			,intCommodityId
			,intFromCommodityUnitMeasureId
			,strLocationName
		)
		SELECT * 
		FROM (
			select distinct 
				intSeqId
				,strSeqHeader
				,strCommodityCode
				,strType
				,sum(dblTotal) dblTotal 
				,intCommodityId
				,intFromCommodityUnitMeasureId
				,strLocationName 
			from(
				SELECT 
					15 AS intSeqId
					,'Company Titled Stock' strSeqHeader 
					,strCommodityCode
					,[strType]
					,case when strType = 'Collateral Receipts - Purchase' then isnull(dblTotal, 0) else -isnull(dblTotal, 0) end dblTotal
					,intCommodityId
					,intFromCommodityUnitMeasureId
					,strLocationName strLocationName
				FROM @Final 
				WHERE intSeqId in (9,8) 
					AND strType in('Collateral Receipts - Purchase','Collateral Receipts - Sales') 
					AND intCommodityId =@intCommodityId 
			)t
			group by intSeqId,strSeqHeader,strCommodityCode,strType,intCommodityId,intFromCommodityUnitMeasureId,strLocationName
		) t 
		WHERE dblTotal<>0
		 
		INSERT INTO @Final (
			intSeqId
			,strSeqHeader
			,strType
			,dblTotal
			,strLocationName
			,intCommodityId
			,intFromCommodityUnitMeasureId
			,intCompanyLocationId
		)
		SELECT 
			15 intSeqId
			,'Company Titled Stock'strSeqHeader
			,strType
			,dblTotal
			,strLocationName
			,intCommodityId
			,intFromCommodityUnitMeasureId
			,intCompanyLocationId
		FROM @Final 
		WHERE intSeqId = 14 

		If ((SELECT TOP 1 ysnIncludeOffsiteInventoryInCompanyTitled from tblRKCompanyPreference)=1)
		BEGIN

			INSERT INTO @Final (
				intSeqId
				,strSeqHeader
				,strType,dblTotal
				,intCommodityId
				,strLocationName
				,intFromCommodityUnitMeasureId
				,intCompanyLocationId
			)
			SELECT 
				15 intSeqId
				,'Company Titled Stock'
				,'Off-Site'
				,dblTotal
				,intCommodityId
				,strLocation
				,intCommodityUnitMeasureId intFromCommodityUnitMeasureId 
				,intCompanyLocationId 
			FROM (
				select 
					dbo.fnCTConvertQuantityToTargetCommodityUOM(ium.intCommodityUnitMeasureId,@intCommodityUnitMeasureId,(Balance))  dblTotal
					,CH.intCommodityId
					,Loc AS strLocation
					,i.strItemNo 
					,[Delivery Date] AS dtmDeliveryDate 
					,ium.intCommodityUnitMeasureId
					,Ticket strTicket 
					,Customer as strCustomerReference 
					,Receipt AS strDPAReceiptNo 
					,[Disc Due] AS dblDiscDue 
					,[Storage Due] AS [Storage Due] 
					,dtmLastStorageAccrueDate 
					,strScheduleId
					,intCompanyLocationId
					,intTicketId
					,strTicketNumber
				from @tblGetStorageDetailByDate CH
					join tblICItem i on CH.intItemId=i.intItemId
					join tblICItemUOM iuom on i.intItemId=iuom.intItemId and ysnStockUnit=1 
					join tblICCommodityUnitMeasure ium on ium.intCommodityId=i.intCommodityId AND iuom.intUnitMeasureId=ium.intUnitMeasureId 
				where ysnCustomerStorage = 1	
					and strOwnedPhysicalStock = 'Company' 
					and ysnDPOwnedType <> 1
					and CH.intCommodityId  = @intCommodityId
					and CH.intCompanyLocationId= case when isnull(@intLocationId,0)=0 then CH.intCompanyLocationId else @intLocationId end	
					and isnull(intEntityId,0) = case when isnull(@intVendorId,0)=0 then isnull(intEntityId,0) else @intVendorId end
			)t 
			WHERE intCompanyLocationId IN (SELECT intCompanyLocationId FROM #LicensedLocation)
		END

		If ((SELECT TOP 1 ysnIncludeDPPurchasesInCompanyTitled from tblRKCompanyPreference)=0)--DP is already included in Inventory we are going to subtract it here (reverse logic in including DP)
		BEGIN
		
			INSERT INTO @Final(
				intSeqId
				,strSeqHeader
				,strType
				,dblTotal
				,strLocationName
				,intCommodityId
				,intFromCommodityUnitMeasureId
				,intCompanyLocationId
			)
			SELECT 
				15 intSeqId
				,'Company Titled Stock'
				,'DP'
				,-sum(dblTotal) dblTotal
				,strLocationName
				,intCommodityId
				,intFromCommodityUnitMeasureId
				,intCompanyLocationId  
			FROM(
				select
					intTicketId
					,strTicketNumber
					,dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId,@intCommodityUnitMeasureId,(isnull(Balance,0))) dblTotal
					,ch.intCompanyLocationId
					,intCommodityUnitMeasureId intFromCommodityUnitMeasureId
					,intCommodityId
					,strLocationName
				from @tblGetStorageDetailByDate ch
				where ch.intCommodityId = @intCommodityId	
					and ysnDPOwnedType = 1
					and ch.intCompanyLocationId= case when isnull(@intLocationId,0)=0 then ch.intCompanyLocationId else @intLocationId end
					and isnull(intEntityId,0) = case when isnull(@intVendorId,0)=0 then isnull(intEntityId,0) else @intVendorId end
			)t 	
			WHERE intCompanyLocationId IN (SELECT intCompanyLocationId FROM #LicensedLocation)
			GROUP BY intTicketId,strTicketNumber,intFromCommodityUnitMeasureId,intCommodityId,strLocationName,intCompanyLocationId

		END

	DECLARE @intUnitMeasureId int
	DECLARE @strUnitMeasure nvarchar(250)
	SELECT TOP 1 @intUnitMeasureId = intUnitMeasureId FROM tblRKCompanyPreference
	select @strUnitMeasure=strUnitMeasure from tblICUnitMeasure where intUnitMeasureId=@intUnitMeasureId

	INSERT INTO @FinalTable (
		intSeqId
		,strSeqHeader
		,strType
		,dblTotal
		,strUnitMeasure
		,strLocationName
		,intCommodityId
		,intCompanyLocationId
	)
	SELECT	
		intSeqId
		,strSeqHeader
		,strType 
		,Convert(decimal(24,10),dbo.fnCTConvertQuantityToTargetCommodityUOM(cuc.intCommodityUnitMeasureId,case when isnull(@intUnitMeasureId,0) = 0 then cuc.intCommodityUnitMeasureId else cuc1.intCommodityUnitMeasureId end,dblTotal)) dblTotal
		,case when isnull(@strUnitMeasure,'')='' then um.strUnitMeasure else @strUnitMeasure end as strUnitMeasure
		, strLocationName
		,t.intCommodityId
		,intCompanyLocationId
	FROM @Final  t
		LEFT JOIN tblICCommodityUnitMeasure cuc on t.intCommodityId=cuc.intCommodityId and cuc.ysnDefault=1 
		LEFT JOIN tblICUnitMeasure um on um.intUnitMeasureId=cuc.intUnitMeasureId
		LEFT JOIN tblICCommodityUnitMeasure cuc1 on t.intCommodityId=cuc1.intCommodityId and @intUnitMeasureId=cuc1.intUnitMeasureId
	WHERE t.intCommodityId = @intCommodityId

	END
	SELECT @mRowNumber = MIN(intCommodityIdentity)	FROM @Commodity	WHERE intCommodityIdentity > @mRowNumber
END  

END --End Begin

IF(@strByType='ByLocation')
BEGIN
		SELECT 
			c.strCommodityCode
			,strUnitMeasure
			,strSeqHeader
			,sum(dblTotal) dblTotal
			,f.intCommodityId
			,strLocationName
		FROM @FinalTable f
			JOIN tblICCommodity c on c.intCommodityId= f.intCommodityId			
		GROUP BY c.strCommodityCode,strUnitMeasure,strSeqHeader,f.intCommodityId,strLocationName
END
ELSE
IF(@strByType='ByCommodity')
BEGIN
		SELECT 
			c.strCommodityCode
			,strUnitMeasure
			,strSeqHeader
			,SUM(dblTotal) dblTotal
			,f.intCommodityId
		FROM @FinalTable f
			JOIN tblICCommodity c on c.intCommodityId = f.intCommodityId
		GROUP BY c.strCommodityCode,strUnitMeasure,strSeqHeader,f.intCommodityId 
END