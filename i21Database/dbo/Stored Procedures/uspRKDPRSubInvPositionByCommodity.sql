CREATE PROCEDURE [dbo].[uspRKDPRSubInvPositionByCommodity] 
	 @intCommodityId nvarchar(max)  
	,@intLocationId int = NULL	
	,@intVendorId int = null
	,@strPurchaseSales nvarchar(250) = NULL
	,@strPositionIncludes nvarchar(100) = NULL
	,@dtmToDate datetime=null
	,@strByType nvarchar(50) = null
AS



--DECLARE 
--	 @intCommodityId nvarchar(max)  = '3023'
--	,@intLocationId int = NULL	
--	,@intVendorId int = null
--	,@strPurchaseSales nvarchar(250) = NULL
--	,@strPositionIncludes nvarchar(100) = 'All Storage'
--	,@dtmToDate datetime=getdate()
--	,@strByType nvarchar(50) = 'ByCommodity'


BEGIN
SET @dtmToDate = convert(DATETIME, CONVERT(VARCHAR(10), @dtmToDate, 110), 110)
DECLARE @ysnDisplayAllStorage bit
select @ysnDisplayAllStorage= isnull(ysnDisplayAllStorage,0) from tblRKCompanyPreference

	 DECLARE @Commodity AS TABLE 
	 (
		intCommodityIdentity int IDENTITY(1,1) PRIMARY KEY , 
		intCommodity  INT
	 )

	IF(@strByType='ByCommodity')
	BEGIN
		INSERT INTO @Commodity(intCommodity)
		SELECT intCommodityId from tblICCommodity where isnull(ysnExchangeTraded,0)=1
	END
	ELSE
	BEGIN
		INSERT INTO @Commodity(intCommodity)
		SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCommodityId, ',')  
	END	

if isnull(@strPurchaseSales,'') <> ''
BEGIN
if @strPurchaseSales='Purchase'
BEGIN
	SELECT @strPurchaseSales='Sales'
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
					strLocationName nvarchar(250),
					strCustomer nvarchar(250),
					intReceiptNo nvarchar(250),
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
					,intStorageScheduleTypeId int
					,intItemId int
					,intTicketId int,
					strTicketNumber nvarchar(100)
					,strShipmentNumber nvarchar(100)
					,intInventoryShipmentId int
					,intInventoryReceiptId int, 
					strReceiptNumber  nvarchar(100)
)

DECLARE @FinalTable AS TABLE (
					intRow int IDENTITY(1,1) PRIMARY KEY , 
					intSeqId int, 
					strSeqHeader nvarchar(100),
					strCommodityCode nvarchar(100),
					strType nvarchar(100),
					dblTotal DECIMAL(24,10),
					intCollateralId int,
					strLocationName nvarchar(250),
					strCustomer nvarchar(250),
					intReceiptNo nvarchar(250),
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
					,intItemId int
					,intTicketId int,
					strTicketNumber nvarchar(100)
					,strShipmentNumber nvarchar(100)
					,intInventoryShipmentId int
					,intInventoryReceiptId int, 
					strReceiptNumber  nvarchar(100)
)

DECLARE @tblGetOpenContractDetail TABLE (
		intRowNum int, 
		strCommodityCode  NVARCHAR(200),
		intCommodityId int, 
		intContractHeaderId int, 
	    strContractNumber  NVARCHAR(200),
		strLocationName  NVARCHAR(200),
		dtmEndDate datetime,
		dblBalance DECIMAL(24,10),
		intUnitMeasureId int, 	
		intPricingTypeId int,
		intContractTypeId int,
		intCompanyLocationId int,
		strContractType  NVARCHAR(200), 
		strPricingType  NVARCHAR(200),
		intCommodityUnitMeasureId int,
		intContractDetailId int,
		intContractStatusId int,
		intEntityId int,
		intCurrencyId int,
		strType	  NVARCHAR(200),
		intItemId int,
		strItemNo  NVARCHAR(200),
		dtmContractDate datetime,
		strEntityName  NVARCHAR(200),
		strCustomerContract  NVARCHAR(200)
				,intFutureMarketId int
		,intFutureMonthId int
		,strCurrency NVARCHAR(200))

--===============================
-- CONTRACTS
--================================
INSERT INTO @tblGetOpenContractDetail(intRowNum,strCommodityCode,intCommodityId,intContractHeaderId,strContractNumber,strLocationName,dtmEndDate,dblBalance,intUnitMeasureId,intPricingTypeId,
		intContractTypeId,intCompanyLocationId,strContractType,strPricingType,intCommodityUnitMeasureId,intContractDetailId	,intContractStatusId	,intEntityId	,intCurrencyId,
strType,intItemId,strItemNo,strEntityName,strCustomerContract,intFutureMarketId,intFutureMonthId,strCurrency)
SELECT intRowNum,strCommodityCode,intCommodityId,intContractHeaderId,strContractNumber,strLocationName,dtmEndDate,dblBalance,intUnitMeasureId,intPricingTypeId,
		intContractTypeId,intCompanyLocationId,strContractType,strPricingType,intCommodityUnitMeasureId,intContractDetailId	,intContractStatusId	,intEntityId	,intCurrencyId,
strType,intItemId,strItemNo,dtmContractDate	strEntityName,strCustomerContract,intFutureMarketId,intFutureMonthId,strCurrency 
FROM 
(
select * 
FROM (
	SELECT ROW_NUMBER() OVER (
			PARTITION BY intContractDetailId ORDER BY dtmHistoryCreated DESC
			) intRowNum
		,strCommodity strCommodityCode
		,h.intCommodityId intCommodityId
		,intContractHeaderId
		,strContractNumber + '-' + Convert(NVARCHAR, intContractSeq) strContractNumber
		,strLocation strLocationName
		,dtmEndDate
		, dblBalance
		,intDtlQtyUnitMeasureId intUnitMeasureId
		,intPricingTypeId
		,intContractTypeId
		,intCompanyLocationId
		,strContractType
		,strPricingType
		,intDtlQtyInCommodityUOMId intCommodityUnitMeasureId
		,intContractDetailId
		,intContractStatusId
		,e.intEntityId intEntityId
		,intCurrencyId
		,strContractType + ' Priced' AS strType
		,i.intItemId intItemId
		,strItemNo
		,getdate() dtmContractDate
		,e.strName strEntityName
		,'' strCustomerContract
		,intFutureMarketId
		,intFutureMonthId,strPricingStatus,c.strCurrency
	FROM tblCTSequenceHistory h
	join tblSMCurrency c on h.intCurrencyId=h.intCurrencyId
	JOIN tblICItem i ON h.intItemId = i.intItemId
	JOIN tblEMEntity e ON e.intEntityId = h.intEntityId
	WHERE  convert(DATETIME, CONVERT(VARCHAR(10), dtmHistoryCreated, 110), 110) <= @dtmToDate 
	AND h.intCommodityId in (select intCommodity from @Commodity)
	) a
WHERE a.intRowNum = 1  AND strPricingStatus IN ('Fully Priced') AND intContractStatusId NOT IN (2, 3, 6) and intPricingTypeId  in (1,2)

UNION

SELECT *
FROM (
	SELECT ROW_NUMBER() OVER (
			PARTITION BY intContractDetailId ORDER BY dtmHistoryCreated DESC
			) intRowNum
		,strCommodity strCommodityCode
		,h.intCommodityId intCommodityId
		,intContractHeaderId
		,strContractNumber + '-' + Convert(NVARCHAR, intContractSeq) strContractNumber
		,strLocation strLocationName
		,dtmEndDate
		--,isnull(dblQtyUnpriced,dblQuantity) + ISNULL(dblQtyPriced - (dblQuantity - dblBalance),0) dblBalance
		,case when strPricingStatus='Parially Priced' then dblQuantity - ISNULL(dblQtyPriced + (dblQuantity - dblBalance),0) 
				else isnull(dblQtyUnpriced,dblQuantity) end dblBalance 		
		,-- wrong need to check
		intDtlQtyUnitMeasureId intUnitMeasureId
		,intPricingTypeId
		,intContractTypeId
		,intCompanyLocationId
		,strContractType
		,strPricingType
		,intDtlQtyInCommodityUOMId intCommodityUnitMeasureId
		,intContractDetailId
		,intContractStatusId
		,e.intEntityId intEntityId
		,intCurrencyId
		,strContractType + ' Basis' AS strType
		,i.intItemId intItemId
		,strItemNo
		,getdate() dtmContractDate
		,e.strName strEntityName
		,'' strCustomerContract
		,intFutureMarketId
		,intFutureMonthId
		,strPricingStatus,c.strCurrency
	FROM tblCTSequenceHistory h
	join tblSMCurrency c on h.intCurrencyId=h.intCurrencyId
	JOIN tblICItem i ON h.intItemId = i.intItemId
	JOIN tblEMEntity e ON e.intEntityId = h.intEntityId
	WHERE  convert(DATETIME, CONVERT(VARCHAR(10), dtmHistoryCreated, 110), 110) <= @dtmToDate 
	AND h.intCommodityId in (select intCommodity from @Commodity)
	
	) a
WHERE a.intRowNum = 1  AND intContractStatusId NOT IN (2, 3, 6) and intPricingTypeId=2 and strPricingStatus in( 'Parially Priced','Unpriced') 

UNION

SELECT *
FROM (
	SELECT ROW_NUMBER() OVER (
			PARTITION BY intContractDetailId ORDER BY dtmHistoryCreated DESC
			) intRowNum
		,strCommodity strCommodityCode
		,h.intCommodityId intCommodityId
		,intContractHeaderId
		,strContractNumber + '-' + Convert(NVARCHAR, intContractSeq) strContractNumber
		,strLocation strLocationName
		,dtmEndDate
		,CASE WHEN dblQtyPriced - (dblQuantity - dblBalance) < 0 THEN 0 ELSE dblQtyPriced - (dblQuantity - dblBalance) END dblBalance
		,-- wrong need to check
		intDtlQtyUnitMeasureId intUnitMeasureId
		,intPricingTypeId
		,intContractTypeId
		,intCompanyLocationId
		,strContractType
		,strPricingType
		,intDtlQtyInCommodityUOMId intCommodityUnitMeasureId
		,intContractDetailId
		,intContractStatusId
		,e.intEntityId intEntityId
		,intCurrencyId
		,strContractType + ' Priced' AS strType
		,i.intItemId intItemId
		,strItemNo
		,getdate() dtmContractDate
		,e.strName strEntityName
		,'' strCustomerContract
		,intFutureMarketId
		,intFutureMonthId 
		,strPricingStatus,c.strCurrency
	FROM tblCTSequenceHistory h
	join tblSMCurrency c on h.intCurrencyId=h.intCurrencyId
	JOIN tblICItem i ON h.intItemId = i.intItemId
	JOIN tblEMEntity e ON e.intEntityId = h.intEntityId
	WHERE convert(DATETIME, CONVERT(VARCHAR(10), dtmHistoryCreated, 110), 110) <= @dtmToDate 
	AND h.intCommodityId in (select intCommodity from @Commodity)

	) a
WHERE a.intRowNum = 1  AND intContractStatusId NOT IN (2, 3, 6) and strPricingStatus = 'Parially Priced'  and intPricingTypeId=2


UNION

SELECT *
FROM (
	SELECT ROW_NUMBER() OVER (
			PARTITION BY intContractDetailId ORDER BY dtmHistoryCreated DESC
			) intRowNum
		,strCommodity strCommodityCode
		,h.intCommodityId intCommodityId
		,intContractHeaderId
		,strContractNumber + '-' + Convert(NVARCHAR, intContractSeq) strContractNumber
		,strLocation strLocationName
		,dtmEndDate
		,dblBalance dblBalance
		,intDtlQtyUnitMeasureId intUnitMeasureId
		,intPricingTypeId
		,intContractTypeId
		,intCompanyLocationId
		,strContractType
		,strPricingType
		,intDtlQtyInCommodityUOMId intCommodityUnitMeasureId
		,intContractDetailId
		,intContractStatusId
		,e.intEntityId intEntityId
		,intCurrencyId
		,strContractType + ' ' + strPricingType AS strType
		,i.intItemId intItemId
		,strItemNo
		,getdate() dtmContractDate
		,e.strName strEntityName
		,'' strCustomerContract
		,intFutureMarketId
		,intFutureMonthId 
		,strPricingStatus,c.strCurrency
	FROM tblCTSequenceHistory h
	join tblSMCurrency c on h.intCurrencyId=h.intCurrencyId
	JOIN tblICItem i ON h.intItemId = i.intItemId
	JOIN tblEMEntity e ON e.intEntityId = h.intEntityId
	WHERE intContractDetailId NOT IN (
			SELECT intContractDetailId
			FROM tblCTPriceFixation
			) AND convert(DATETIME, CONVERT(VARCHAR(10), convert(DATETIME, CONVERT(VARCHAR(10), dtmHistoryCreated, 110), 110), 110), 110) <= convert(DATETIME, @dtmToDate) 
			AND h.intCommodityId  in (select intCommodity from @Commodity)				
	) a
WHERE a.intRowNum = 1  AND intContractStatusId NOT IN (2, 3, 6) and intPricingTypeId not in (1,2)
)t

--select * from @tblGetOpenContractDetail where intCommodityId = 18

--=============================================================
-- STORAGE
--=============================================================
DECLARE @tblGetStorageDetailByDate TABLE (
		intRowNum int, 
		intCustomerStorageId int,
		intCompanyLocationId int	
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
		,strTicketNumber NVARCHAR(200))
insert into @tblGetStorageDetailByDate
SELECT ROW_NUMBER() OVER (PARTITION BY a.intCustomerStorageId ORDER BY a.intCustomerStorageId DESC) intRowNum, 
	a.intCustomerStorageId,
	a.intCompanyLocationId	
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
	,i.intItemId as intItemId  ,t.intTicketId,t.strTicketNumber
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
left join tblSCTicket t on t.intTicketId=gh.intTicketId
WHERE ISNULL(a.strStorageType,'') <> 'ITR'  and isnull(a.intDeliverySheetId,0) =0 and isnull(strTicketStatus,'') <> 'V'
and convert(DATETIME, CONVERT(VARCHAR(10), dtmDistributionDate, 110), 110) <= convert(datetime,@dtmToDate) 
and a.intCommodityId in (select intCommodity from @Commodity)

union all
SELECT ROW_NUMBER() OVER (PARTITION BY a.intCustomerStorageId ORDER BY a.intCustomerStorageId DESC) intRowNum, 
	a.intCustomerStorageId,
	a.intCompanyLocationId	
	,c.strLocationName [Loc]
	,CONVERT(DATETIME,CONVERT(VARCHAR(10),a.dtmDeliveryDate ,110),110) [Delivery Date]
	,a.strStorageTicketNumber [Ticket]
	,a.intEntityId
	,E.strName [Customer]
	,a.strDPARecieptNumber [Receipt]
	,a.dblDiscountsDue [Disc Due]
	,a.dblStorageDue   [Storage Due]
	,(case when gh.strType ='Reduced By Inventory Shipment' then -gh.dblUnits else gh.dblUnits   end) [Balance]
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
	,i.intItemId as intItemId  ,null intTicketId,'' strTicketNumber
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
WHERE ISNULL(a.strStorageType,'') <> 'ITR'  and isnull(a.intDeliverySheetId,0) <>0
and convert(DATETIME, CONVERT(VARCHAR(10), dtmDistributionDate, 110), 110) <= convert(datetime,@dtmToDate) 
and a.intCommodityId in (select intCommodity from @Commodity)

--select * from @tblGetStorageDetailByDate where intCommodityId = 3023
--========================================
-- COLLATERAL
--=========================================

DECLARE @tempCollateral TABLE (		
		intRowNum int,
		intCollateralId int,
		strLocationName NVARCHAR(200),
		strItemNo NVARCHAR(200),
		strEntityName NVARCHAR(200),
		intReceiptNo NVARCHAR(100),
		intContractHeaderId int,	
		strContractNumber NVARCHAR(200), 
		dtmOpenDate datetime,
		dblOriginalQuantity numeric(24,10),
		dblRemainingQuantity numeric(24,10),
	    intCommodityId int,
	    intUnitMeasureId int,
	    intCompanyLocationId int,
		intContractTypeId int
		,intLocationId int,
		intEntityId int,
		strCommodityCode NVARCHAR(200)
		)
INSERT INTO @tempCollateral
SELECT *  FROM (
		SELECT  ROW_NUMBER() OVER (PARTITION BY intCollateralId ORDER BY dtmTransactionDate DESC) intRowNum,		
		c.intCollateralId,cl.strLocationName,ch.strItemNo,ch.strEntityName,c.intReceiptNo,ch.intContractHeaderId,	strContractNumber, c.dtmOpenDate,
		isnull(c.dblOriginalQuantity,0) dblOriginalQuantity,
		isnull(c.dblRemainingQuantity,0) dblRemainingQuantity,
	    c.intCommodityId as intCommodityId,c.intUnitMeasureId,c.intLocationId intCompanyLocationId,
		case when c.strType='Purchase' then 1 else 2 end	intContractTypeId
		,c.intLocationId,intEntityId,co.strCommodityCode
		FROM tblRKCollateralHistory c
		JOIN tblICCommodity co on co.intCommodityId=c.intCommodityId
		JOIN tblICCommodityUnitMeasure ium on ium.intCommodityId=c.intCommodityId AND c.intUnitMeasureId=ium.intUnitMeasureId 
		JOIN tblSMCompanyLocation cl on cl.intCompanyLocationId=c.intLocationId
		LEFT JOIN @tblGetOpenContractDetail ch on c.intContractHeaderId=ch.intContractHeaderId and ch.intContractStatusId <> 3
		WHERE c.intCommodityId in (select intCommodity from @Commodity)
								 AND convert(DATETIME, CONVERT(VARCHAR(10), dtmTransactionDate, 110), 110) <= convert(datetime,@dtmToDate) 
									AND  c.intLocationId   IN (SELECT intCompanyLocationId FROM tblSMCompanyLocation
									WHERE isnull(ysnLicensed, 0) = CASE WHEN @strPositionIncludes = 'licensed storage' THEN 1 
									WHEN @strPositionIncludes = 'Non-licensed storage' THEN 0 
									ELSE isnull(ysnLicensed, 0) END
									)
		) a where   a.intRowNum =1

--select * from @tempCollateral where intCommodityId = 2018
--========================
-- INVENTORY VALUATION
--========================

DECLARE @invQty TABLE (		
		dblTotal numeric(24,10),
		Ticket NVARCHAR(200)	
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
		)
INSERT INTO @invQty
SELECT distinct s.dblQuantity  dblTotal,
	t.strTicketNumber Ticket,s.strLocationName,s.strItemNo,i.intCommodityId intCommodityId,intCommodityUnitMeasureId intFromCommodityUnitMeasureId,
	s.intLocationId intLocationId,strTransactionId,strTransactionType,i.intItemId, t.strDistributionOption,strTicketStatus	FROM vyuRKGetInventoryValuation s  		
	JOIN tblICItem i on i.intItemId=s.intItemId
	JOIN tblICItemUOM iuom on s.intItemId=iuom.intItemId and iuom.ysnStockUnit=1 and  isnull(ysnInTransit,0)=0 
	JOIN tblICCommodityUnitMeasure ium on ium.intCommodityId=i.intCommodityId AND iuom.intUnitMeasureId=ium.intUnitMeasureId  
	LEFT JOIN tblSCTicket t on s.strSourceNumber=t.strTicketNumber		   		  
	WHERE i.intCommodityId in (select intCommodity from @Commodity) and iuom.ysnStockUnit=1 AND ISNULL(s.dblQuantity,0) <>0
				and convert(DATETIME, CONVERT(VARCHAR(10), s.dtmCreated, 110), 110)<=convert(datetime,@dtmToDate)
							and s.intLocationId  IN (
				SELECT intCompanyLocationId FROM tblSMCompanyLocation
				WHERE isnull(ysnLicensed, 0) = CASE WHEN @strPositionIncludes = 'licensed storage' THEN 1 
								WHEN @strPositionIncludes = 'Non-licensed storage' THEN 0 
								ELSE isnull(ysnLicensed, 0) END
				) 


--select * from @invQty where intCommodityId = 18 order by strTransactionId
--========================
-- DELIVERY SHEET
--========================

DECLARE @tempDeliverySheet TABLE (		
			[Storage Type] nvarchar(250),			 
			 strType nvarchar(250),
			  dblTotal numeric(24,10),
			  intCommodityId int,
			  strLocationName nvarchar(250),			  
			 intFromCommodityUnitMeasureId int,
			 intCompanyLocationId int,
			 intEntityId int, 
			 strCustomer nvarchar(250),
			 strOwnedPhysicalStock nvarchar(100)
		)
insert into @tempDeliverySheet([Storage Type], strType, dblTotal,intCommodityId,strLocationName,
 intFromCommodityUnitMeasureId,intCompanyLocationId,intEntityId, strCustomer,strOwnedPhysicalStock)
SELECT [Storage Type] as [Storage Type], strType,sum(dblTotal) dblTotal,intCommodityId,strLocationName,
 intFromCommodityUnitMeasureId,intCompanyLocationId,intEntityId, strCustomer,strOwnedPhysicalStock  from(
SELECT * FROM (
SELECT ROW_NUMBER() OVER (PARTITION BY   GR1.intCustomerStorageId ORDER BY dtmHistoryDate DESC) intRowNum, 
GR.strStorageTypeDescription [Storage Type],GR.strStorageTypeDescription strType,
	GR1.dblUnits dblTotal,	l.strLocationName strLocationName,SCT.intCommodityId intCommodityId, ium.intCommodityUnitMeasureId intFromCommodityUnitMeasureId,
	l.intCompanyLocationId  intCompanyLocationId	
	, E.intEntityId ,E.strName strCustomer,strOwnedPhysicalStock
	FROM tblSCDeliverySheet SCD 
	INNER JOIN tblSCTicket SCT ON SCD.intDeliverySheetId = SCT.intDeliverySheetId 
	INNER JOIN tblGRStorageHistory GR1 on SCD.intDeliverySheetId = GR1.intDeliverySheetId
	INNER JOIN tblSCDeliverySheetHistory SCDS ON SCDS.intDeliverySheetId = SCD.intDeliverySheetId and GR1.intEntityId=SCDS.intEntityId
	INNER JOIN tblICItem i on i.intItemId=SCT.intItemId
	JOIN tblICItemUOM iuom on i.intItemId=iuom.intItemId and ysnStockUnit=1
	JOIN tblICCommodityUnitMeasure ium on ium.intCommodityId=i.intCommodityId AND iuom.intUnitMeasureId=ium.intUnitMeasureId 
	INNER JOIN tblSMCompanyLocation l on SCT.intProcessingLocationId=l.intCompanyLocationId
	INNER JOIN tblEMEntity E on E.intEntityId=SCDS.intEntityId
	join tblICCommodity ic on ic.intCommodityId=SCT.intCommodityId
	LEFT JOIN tblGRStorageType GR ON GR.intStorageScheduleTypeId = SCDS.intStorageScheduleTypeId 
	WHERE SCT.strTicketStatus = 'H' and isnull(SCT.intDeliverySheetId,0) <>0   and isnull(SCD.ysnPost,0) =1
	AND SCT.intCommodityId in (select intCommodity from @Commodity)  --AND isnull(GR.intStorageScheduleTypeId,0) > 0
	AND	l.intCompanyLocationId  = case when isnull(@intLocationId,0)=0 then l.intCompanyLocationId else @intLocationId end and isnull(strTicketStatus,'') <> 'V'
	and  convert(DATETIME, CONVERT(VARCHAR(10), dtmHistoryDate, 110), 110) <= convert(datetime,@dtmToDate)
	and l.intCompanyLocationId   IN (SELECT intCompanyLocationId FROM tblSMCompanyLocation
									WHERE isnull(ysnLicensed, 0) = CASE WHEN @strPositionIncludes = 'licensed storage' THEN 1 
									WHEN @strPositionIncludes = 'Non-licensed storage' THEN 0 
									ELSE isnull(ysnLicensed, 0) END
									)
)a WHERE a.intRowNum =1 	
	UNION
SELECT * FROM (
	SELECT ROW_NUMBER() OVER (PARTITION BY SCDS.intDeliverySheetSplitId ORDER BY dtmDeliverySheetHistoryDate DESC) intRowNum, 
	 GR.strStorageTypeDescription [Storage Type],GR.strStorageTypeDescription strType,
	SCDS.dblQuantity dblTotal,
	l.strLocationName strLocationName,
	SCT.intCommodityId intCommodityId, intCommodityUnitMeasureId intFromCommodityUnitMeasureId,l.intCompanyLocationId  intCompanyLocationId
	, E.intEntityId , E.strName strCustomer,strOwnedPhysicalStock
	FROM tblSCDeliverySheet SCD
	INNER JOIN tblSCTicket SCT ON SCD.intDeliverySheetId = SCT.intDeliverySheetId AND SCT.ysnDeliverySheetPost = 0
	INNER JOIN tblSCDeliverySheetHistory SCDS ON SCDS.intDeliverySheetId = SCD.intDeliverySheetId
	INNER JOIN tblICItem i on i.intItemId=SCD.intItemId
	JOIN tblICItemUOM iuom on i.intItemId=iuom.intItemId and ysnStockUnit=1
	JOIN tblICCommodityUnitMeasure ium on ium.intCommodityId=i.intCommodityId AND iuom.intUnitMeasureId=ium.intUnitMeasureId 
	INNER JOIN tblSMCompanyLocation l on SCT.intProcessingLocationId=l.intCompanyLocationId
	INNER JOIN tblEMEntity E on E.intEntityId=SCDS.intEntityId
	join tblICCommodity ic on ic.intCommodityId=SCT.intCommodityId
	LEFT JOIN tblGRStorageType GR ON GR.intStorageScheduleTypeId = SCDS.intStorageScheduleTypeId 
	WHERE SCT.strTicketStatus = 'H' and isnull(SCT.intDeliverySheetId,0) <>0 and isnull(SCD.ysnPost,0) = 0 and isnull(strTicketStatus,'') <> 'V'
	AND SCT.intCommodityId in (select intCommodity from @Commodity)  --AND GR.intStorageScheduleTypeId > 0
		AND	l.intCompanyLocationId  = case when isnull(@intLocationId,0)=0 then l.intCompanyLocationId else @intLocationId end 
		and   convert(DATETIME, CONVERT(VARCHAR(10), dtmDeliverySheetHistoryDate, 110), 110) <= convert(datetime,@dtmToDate)
		)a where a.intRowNum =1 	
	)t  
	WHERE dblTotal >0 AND intCompanyLocationId IN (
				SELECT intCompanyLocationId FROM tblSMCompanyLocation
				WHERE isnull(ysnLicensed, 0) = CASE WHEN @strPositionIncludes = 'licensed storage' THEN 1 
								WHEN @strPositionIncludes = 'Non-licensed storage' THEN 0 
								ELSE isnull(ysnLicensed, 0) END)
	GROUP BY  [Storage Type], strType, intEntityId,	 intCommodityId,strLocationName, intFromCommodityUnitMeasureId,intCompanyLocationId,strCustomer,strOwnedPhysicalStock

--select * from @tempDeliverySheet where intCommodityId = 18
--========================
-- ON HOLD
--========================

DECLARE @tempOnHold TABLE (		
		dblTotal numeric(24,10),
		strCustomer NVARCHAR(200)	
		,strLocationName NVARCHAR(200)
		,intCommodityId int
		,intCommodityUnitMeasureId int
		,intLocationId int
		,intEntityId  int
		)
insert into @tempOnHold(dblTotal,strCustomer,strLocationName,intCommodityId,intCommodityUnitMeasureId,intLocationId,intEntityId)
SELECT  dblTotal,strCustomer,strLocationName,intCommodityId,intCommodityUnitMeasureId,intLocationId,intEntityId FROM (
	SELECT  ROW_NUMBER() OVER (PARTITION BY t.intTicketId ORDER BY t.dtmTicketHistoryDate DESC) intSeqId,
	case when st.strInOutFlag = 'I' then  st.dblNetUnits else abs(st.dblNetUnits) * -1 end  AS dblTotal,strName strCustomer,cl.strLocationName, st.intCommodityId,intCommodityUnitMeasureId, 
	st.intProcessingLocationId intLocationId,e.intEntityId
	FROM tblSCTicketHistory t
	JOIN tblSCTicket st on t.intTicketId=st.intTicketId
	JOIN tblEMEntity e on e.intEntityId= st.intEntityId
	JOIN tblSMCompanyLocation  cl on cl.intCompanyLocationId=st.intProcessingLocationId and st.strDistributionOption='HLD'
	JOIN tblICItem i1 on i1.intItemId=st.intItemId
	JOIN tblICItemUOM iuom on i1.intItemId=iuom.intItemId and ysnStockUnit=1
	JOIN tblICCommodityUnitMeasure ium on ium.intCommodityId=i1.intCommodityId AND iuom.intUnitMeasureId=ium.intUnitMeasureId 
	WHERE st.intCommodityId  in(select intCommodity from @Commodity) and isnull(st.intDeliverySheetId,0) =0
			AND st.intProcessingLocationId  = CASE WHEN ISNULL(@intLocationId,0)=0 then st.intProcessingLocationId else @intLocationId end
			AND convert(DATETIME, CONVERT(VARCHAR(10), t.dtmTicketHistoryDate, 110), 110) <=CONVERT(DATETIME,@dtmToDate)
			and isnull(strTicketStatus,'') <> 'V'
	)t 	WHERE intLocationId IN (
		SELECT intCompanyLocationId FROM tblSMCompanyLocation
		WHERE isnull(ysnLicensed, 0) = CASE WHEN @strPositionIncludes = 'licensed storage' THEN 1 
						WHEN @strPositionIncludes = 'Non-licensed storage' THEN 0 
						ELSE isnull(ysnLicensed, 0) END)
	AND t.intSeqId =1 

--select * from @tempOnHold where intCommodityId = 18
--========================
-- Building of data
--========================

DECLARE @mRowNumber INT
DECLARE @intCommodityId1 INT
DECLARE @strDescription nvarchar(250)
declare @intCommodityUnitMeasureId int

SELECT @mRowNumber = MIN(intCommodityIdentity) FROM @Commodity where intCommodity>0

WHILE @mRowNumber > 0
	BEGIN
		SELECT @intCommodityId = intCommodity FROM @Commodity WHERE intCommodityIdentity = @mRowNumber
		SELECT @strDescription = strCommodityCode	FROM tblICCommodity	WHERE intCommodityId = @intCommodityId
		SELECT @intCommodityUnitMeasureId=intCommodityUnitMeasureId from tblICCommodityUnitMeasure where intCommodityId=@intCommodityId and ysnDefault=1

if isnull(@intCommodityId,0) > 0
BEGIN

IF ISNULL(@intVendorId,0) = 0
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
		intSeqId
		,strSeqHeader
		,strType
		,(dbo.fnCTConvertQuantityToTargetCommodityUOM(intFromCommodityUnitMeasureId,@intCommodityUnitMeasureId,isnull(dblTotal ,0))) dblTotal
		,strLocationName
		,intCommodityId
		,intFromCommodityUnitMeasureId
		,intCompanyLocationId 
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
		from @invQty 
		where intCommodityId =@intCommodityId and isnull(strDistributionOption,'') <> 'DP' and isnull(strTicketStatus,0) <> 'V' 
	)t
	--group by intSeqId,strSeqHeader,strType,strLocationName,intItemId,strItemNo,intCommodityId,intFromCommodityUnitMeasureId,intCompanyLocationId
	

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
		select distinct 
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
		where intCommodityId =@intCommodityId 
			and intCompanyLocationId= case when isnull(@intLocationId,0)=0 then intCompanyLocationId else @intLocationId end
			and intCompanyLocationId   IN (SELECT intCompanyLocationId FROM tblSMCompanyLocation
						WHERE isnull(ysnLicensed, 0) = CASE WHEN @strPositionIncludes = 'licensed storage' THEN 1 
						WHEN @strPositionIncludes = 'Non-licensed storage' THEN 0 
						ELSE isnull(ysnLicensed, 0) END
						)
	)t 


	INSERT INTO @Final(intSeqId,strSeqHeader,strType,dblTotal,strLocationName,intCommodityId,intFromCommodityUnitMeasureId,intCompanyLocationId)
	SELECT intSeqId,strSeqHeader,strType,sum(dblTotal) dblTotal,strLocationName,intCommodityId, intCommodityUnitMeasureId intFromCommodityUnitMeasureId,intCompanyLocationId from(
	SELECT distinct  1 intSeqId,'In-House' strSeqHeader,'On-Hold' strType, 
		dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId,@intCommodityUnitMeasureId,dblTotal) 
		 dblTotal, strCustomer, strLocationName,
			intCommodityId,intCommodityUnitMeasureId,intLocationId intCompanyLocationId
	FROM @tempOnHold  where intCommodityId =@intCommodityId)t
	group by intSeqId,strSeqHeader,strType,strCustomer,strLocationName,intCommodityId,intCommodityUnitMeasureId,intCompanyLocationId
	
		-- Delivery sheet
	INSERT INTO @Final (intSeqId,strSeqHeader,strType,dblTotal,strLocationName,intCommodityId,intFromCommodityUnitMeasureId,intCompanyLocationId)
	SELECT DISTINCT 1,'In-House', strType, 
		dbo.fnCTConvertQuantityToTargetCommodityUOM(intFromCommodityUnitMeasureId,@intCommodityUnitMeasureId,dblTotal) dblTotal,
		  strLocationName,intCommodityId, intFromCommodityUnitMeasureId,intCompanyLocationId  
	FROM @tempDeliverySheet where intCommodityId =@intCommodityId

--Collatral Sale
	INSERT INTO @Final(intSeqId,strSeqHeader,strType,dblTotal,strLocationName,intCommodityId,intFromCommodityUnitMeasureId,intCompanyLocationId)
		SELECT intSeqId,strSeqHeader,strType,dblTotal,strLocationName,intCommodityId,intUnitMeasureId intFromCommodityUnitMeasureId,intCompanyLocationId FROM (
		SELECT 8 intSeqId,'Collateral Receipts - Sales' strSeqHeader, strCommodityCode,'Collateral Receipts - Sales' strType,
		dblRemainingQuantity dblTotal,intCollateralId,strLocationName,strItemNo,strEntityName,intReceiptNo,intContractHeaderId,
		strContractNumber,dtmOpenDate,dblOriginalQuantity,dblRemainingQuantity ,intCommodityId,intUnitMeasureId,intCompanyLocationId
		FROM @tempCollateral
		WHERE intContractTypeId = 2 AND intCommodityId =@intCommodityId
		AND intLocationId = case when isnull(@intLocationId,0)=0 then intLocationId  else @intLocationId end)t
						WHERE intCompanyLocationId  IN (
				SELECT intCompanyLocationId FROM tblSMCompanyLocation
				WHERE isnull(ysnLicensed, 0) = CASE WHEN @strPositionIncludes = 'licensed storage' THEN 1 
								WHEN @strPositionIncludes = 'Non-licensed storage' THEN 0 
								ELSE isnull(ysnLicensed, 0) END
				) 


-- Collatral Purchase
	INSERT INTO @Final(intSeqId,strSeqHeader,strType,dblTotal,strLocationName,intCommodityId,intFromCommodityUnitMeasureId,intCompanyLocationId)
		SELECT intSeqId,strSeqHeader,strType,dblTotal,strLocationName,intCommodityId,intUnitMeasureId,intCompanyLocationId FROM (
		SELECT 9 intSeqId,'Collateral Receipts - Purchase' strSeqHeader, strCommodityCode,'Collateral Receipts - Purchase' strType,
		dblRemainingQuantity  dblTotal,intCollateralId,strLocationName,strItemNo,strEntityName,intReceiptNo,intContractHeaderId,
		strContractNumber,dtmOpenDate,dblOriginalQuantity,dblRemainingQuantity ,intCommodityId,intUnitMeasureId,intCompanyLocationId
		FROM @tempCollateral 
		WHERE intContractTypeId = 1 AND
		  intCommodityId =@intCommodityId
		AND intLocationId = case when isnull(@intLocationId,0)=0 then intLocationId  else @intLocationId end)t
								WHERE intCompanyLocationId  IN (
				SELECT intCompanyLocationId FROM tblSMCompanyLocation
				WHERE isnull(ysnLicensed, 0) = CASE WHEN @strPositionIncludes = 'licensed storage' THEN 1 
								WHEN @strPositionIncludes = 'Non-licensed storage' THEN 0 
								ELSE isnull(ysnLicensed, 0) END
				) 


	INSERT INTO @Final (intSeqId,strSeqHeader,strType,dblTotal,strLocationName,intCommodityId,intFromCommodityUnitMeasureId,intCompanyLocationId)
			select intSeqId,strSeqHeader,strType,dblTotal,strLocationName,intCommodityId,intUnitMeasureId intFromCommodityUnitMeasureId,intCompanyLocationId from (
			SELECT distinct 14 intSeqId,'Sls Basis Deliveries' strSeqHeader, strCommodityCode,'Sls Basis Deliveries' strType,
			dbo.fnCTConvertQuantityToTargetCommodityUOM(ium.intCommodityUnitMeasureId,@intCommodityUnitMeasureId,isnull(ri.dblQuantity, 0))  AS dblTotal,
			cd.intCommodityId,cl.strLocationName,cd.strItemNo,strContractNumber strTicketNumber,
			cd.dtmContractDate as dtmTicketDateTime ,
			cd.strCustomerContract as strCustomerReference, 'CNT' as strDistributionOption,cd.intUnitMeasureId,cl.intCompanyLocationId,strShipmentNumber,cd.strContractNumber
			,r.intInventoryShipmentId,strShipmentNumber strShipmentNumber1
			FROM vyuRKGetInventoryValuation v 
			JOIN tblICInventoryShipment r on r.strShipmentNumber=v.strTransactionId
			INNER JOIN tblICInventoryShipmentItem ri ON r.intInventoryShipmentId = ri.intInventoryShipmentId
			INNER JOIN @tblGetOpenContractDetail cd ON cd.intContractDetailId = ri.intLineNo AND cd.intPricingTypeId = 2	and cd.intContractStatusId <> 3  AND cd.intContractTypeId = 2
			JOIN tblICCommodityUnitMeasure ium on ium.intCommodityId=cd.intCommodityId AND cd.intUnitMeasureId=ium.intUnitMeasureId 
			INNER JOIN tblSMCompanyLocation  cl on cl.intCompanyLocationId=cd.intCompanyLocationId
			WHERE cd.intCommodityId =@intCommodityId AND v.strTransactionType ='Inventory Shipment'
			AND cl.intCompanyLocationId  = case when isnull(@intLocationId,0)=0 then cl.intCompanyLocationId else @intLocationId end
			and convert(DATETIME, CONVERT(VARCHAR(10), v.dtmCreated, 110), 110)<=convert(datetime,@dtmToDate)
			)t
				WHERE intCompanyLocationId IN (
				SELECT intCompanyLocationId FROM tblSMCompanyLocation
				WHERE isnull(ysnLicensed, 0) = CASE WHEN @strPositionIncludes = 'licensed storage' THEN 1 
								WHEN @strPositionIncludes = 'Non-licensed storage' THEN 0 
								ELSE isnull(ysnLicensed, 0) END
				)  

--- Company Title
	INSERT INTO @Final(intSeqId,strSeqHeader,strType,dblTotal,strLocationName,intCommodityId,intFromCommodityUnitMeasureId,intCompanyLocationId)
	select intSeqId,strSeqHeader,strType,sum(dblTotal) dblTotal,strLocationName,intCommodityId,intFromCommodityUnitMeasureId,intCompanyLocationId from (
	SELECT 15 intSeqId,'Company Titled Stock' strSeqHeader,strCommodityCode,'Receipt' strType,dblTotal ,strLocationName,intItemId,strItemNo,intCommodityId,intFromCommodityUnitMeasureId,intCompanyLocationId 
	FROM @Final 
	where strSeqHeader='In-House' and strType='Receipt' and intCommodityId =@intCommodityId)t
	group by intSeqId,strSeqHeader,strType,strLocationName,intCommodityId,intFromCommodityUnitMeasureId,intCompanyLocationId



-- Company Title with Collateral
	INSERT INTO @Final(intSeqId,strSeqHeader,strCommodityCode,strType,dblTotal,intCommodityId,intFromCommodityUnitMeasureId,strLocationName)
	select * from (
	SELECT distinct intSeqId,strSeqHeader,strCommodityCode,strType,sum(dblTotal) dblTotal ,intCommodityId,intFromCommodityUnitMeasureId,strLocationName from(
	SELECT 15 AS intSeqId,'Company Titled Stock' strSeqHeader , strCommodityCode,[strType],
	case when strType = 'Collateral Receipts - Purchase' then isnull(dblTotal, 0) else -isnull(dblTotal, 0) end dblTotal,
		intCommodityId,intFromCommodityUnitMeasureId,strLocationName strLocationName
		 FROM @Final where intSeqId in (9,8) and strType in('Collateral Receipts - Purchase','Collateral Receipts - Sales') and intCommodityId =@intCommodityId )t
		 GROUP BY intSeqId,strSeqHeader,strCommodityCode,strType,intCommodityId,intFromCommodityUnitMeasureId,strLocationName) t where dblTotal<>0
		 
	INSERT INTO @Final (intSeqId,strSeqHeader,strType,dblTotal,strLocationName,intCommodityId,intFromCommodityUnitMeasureId,intCompanyLocationId)
	select 15 intSeqId,'Company Titled Stock'strSeqHeader,strType,dblTotal,strLocationName, intCommodityId,
						intFromCommodityUnitMeasureId,intCompanyLocationId
	FROM @Final WHERE intSeqId = 14 

	If ((SELECT TOP 1 ysnIncludeOffsiteInventoryInCompanyTitled from tblRKCompanyPreference)=1)
	BEGIN

	INSERT INTO @Final (intSeqId,strSeqHeader,strType,dblTotal,strLocationName,intCommodityId,intFromCommodityUnitMeasureId,intCompanyLocationId)
	SELECT 15 intSeqId,'Company Titled Stock','Off-Site',	dblTotal,intCommodityId,strLocation,intCommodityUnitMeasureId intFromCommodityUnitMeasureId ,
	intCompanyLocationId 
		FROM  (
	SELECT dbo.fnCTConvertQuantityToTargetCommodityUOM(ium.intCommodityUnitMeasureId,@intCommodityUnitMeasureId,(Balance))  dblTotal,
	CH.intCommodityId,Loc AS strLocation,i.strItemNo ,[Delivery Date] AS dtmDeliveryDate ,ium.intCommodityUnitMeasureId,
				Ticket strTicket ,Customer as strCustomerReference ,Receipt AS strDPAReceiptNo ,[Disc Due] AS dblDiscDue ,
				[Storage Due] AS [Storage Due] ,dtmLastStorageAccrueDate ,strScheduleId,intCompanyLocationId,intTicketId,strTicketNumber
			FROM @tblGetStorageDetailByDate CH
			join tblICItem i on CH.intItemId=i.intItemId
			JOIN tblICItemUOM iuom on i.intItemId=iuom.intItemId and ysnStockUnit=1 
			JOIN tblICCommodityUnitMeasure ium on ium.intCommodityId=i.intCommodityId AND iuom.intUnitMeasureId=ium.intUnitMeasureId 
			 WHERE ysnCustomerStorage = 1	AND strOwnedPhysicalStock = 'Company'
			AND CH.intCommodityId  =@intCommodityId
						AND CH.intCompanyLocationId= case when isnull(@intLocationId,0)=0 then CH.intCompanyLocationId else @intLocationId end	
				 )t WHERE intCompanyLocationId IN (
								SELECT intCompanyLocationId FROM tblSMCompanyLocation
								WHERE isnull(ysnLicensed, 0) = CASE WHEN @strPositionIncludes = 'licensed storage' THEN 1 
												WHEN @strPositionIncludes = 'Non-licensed storage' THEN 0 ELSE isnull(ysnLicensed, 0) END
				)
	END

	If ((SELECT TOP 1 ysnIncludeDPPurchasesInCompanyTitled from tblRKCompanyPreference)=1)
	BEGIN
		
	INSERT INTO @Final(intSeqId,strSeqHeader,strType,dblTotal,strLocationName,intCommodityId,intFromCommodityUnitMeasureId,intCompanyLocationId)
	SELECT 15 intSeqId,'Company Titled Stock','DP',sum(dblTotal) dblTotal,strLocationName,intCommodityId,intFromCommodityUnitMeasureId,intCompanyLocationId  from(
			SELECT intTicketId,strTicketNumber,
					dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId,@intCommodityUnitMeasureId,(isnull(Balance,0))) dblTotal
					,ch.intCompanyLocationId,intCommodityUnitMeasureId intFromCommodityUnitMeasureId,intCommodityId,strLocationName
					FROM @tblGetStorageDetailByDate ch
					WHERE ch.intCommodityId  =@intCommodityId	AND ysnDPOwnedType = 1
						AND ch.intCompanyLocationId= case when isnull(@intLocationId,0)=0 then ch.intCompanyLocationId else @intLocationId end
					)t 	WHERE intCompanyLocationId  IN (
								SELECT intCompanyLocationId FROM tblSMCompanyLocation
								WHERE isnull(ysnLicensed, 0) = CASE WHEN @strPositionIncludes = 'licensed storage' THEN 1 
								WHEN @strPositionIncludes = 'Non-licensed storage' THEN 0 
								ELSE isnull(ysnLicensed, 0) END
				) group by intTicketId,strTicketNumber,intFromCommodityUnitMeasureId,intCommodityId,strLocationName,intCompanyLocationId

	END

END
ELSE 
BEGIN
    INSERT INTO @Final(intSeqId,strSeqHeader,strType,dblTotal,strLocationName,intCommodityId,intFromCommodityUnitMeasureId,intCompanyLocationId)                                
    (SELECT 1 intSeqId,'In-House' strSeqHeader, [strType],dblTotal,strLocationName,intCommodityId,intCommodityUnitMeasureId,intLocationId 
    FROM(  SELECT  [Storage Type] AS [strType],
            --dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId,@intCommodityUnitMeasureId,isnull(Balance,0)) 
			Balance dblTotal  ,strLocationName, intCommodityId, intCommodityUnitMeasureId,intCompanyLocationId intLocationId,strName
                FROM @tblGetStorageDetailByDate s
                JOIN tblEMEntity e on s.intEntityId=e.intEntityId
                WHERE intCommodityId =@intCommodityId AND 
                intCompanyLocationId= case when isnull(@intLocationId,0)=0 then intCompanyLocationId else @intLocationId end
                AND s.intEntityId= @intVendorId and strOwnedPhysicalStock='Customer'

            UNION all
                SELECT 'On-Hold' strType, dblTotal,
				 strLocationName,intCommodityId,intCommodityUnitMeasureId,intLocationId,strCustomer
                FROM @tempOnHold
                WHERE intEntityId= @intVendorId and intCommodityId =@intCommodityId
				)t     WHERE intLocationId IN (
                        SELECT intCompanyLocationId FROM tblSMCompanyLocation
                        WHERE isnull(ysnLicensed, 0) = CASE WHEN @strPositionIncludes = 'licensed storage' THEN 1 
                                                    WHEN @strPositionIncludes = 'Non-licensed storage' THEN 0 
                                                    ELSE isnull(ysnLicensed, 0) END)
		)
		 
	INSERT INTO @Final (intSeqId,strSeqHeader,strType,dblTotal,strLocationName,intCommodityId,intFromCommodityUnitMeasureId,intCompanyLocationId)
	SELECT distinct   1,'In-House', strType,
 	dbo.fnCTConvertQuantityToTargetCommodityUOM(intFromCommodityUnitMeasureId,@intCommodityUnitMeasureId,dblTotal) dblTotal,intCommodityId,strLocationName,
	  intFromCommodityUnitMeasureId,intCompanyLocationId  
	FROM @tempDeliverySheet  where intEntityId= @intVendorId 
	and intCommodityId =@intCommodityId
	 AND strOwnedPhysicalStock = 'Customer'

	

END

DECLARE @intUnitMeasureId int
DECLARE @strUnitMeasure nvarchar(250)
SELECT TOP 1 @intUnitMeasureId = intUnitMeasureId FROM tblRKCompanyPreference
select @strUnitMeasure=strUnitMeasure from tblICUnitMeasure where intUnitMeasureId=@intUnitMeasureId
INSERT INTO @FinalTable (intSeqId,strSeqHeader,strType,dblTotal,strUnitMeasure,strLocationName,intCommodityId,intCompanyLocationId
)

SELECT	intSeqId,strSeqHeader, strType ,
			    Convert(decimal(24,10),dbo.fnCTConvertQuantityToTargetCommodityUOM(cuc.intCommodityUnitMeasureId,
		case when isnull(@intUnitMeasureId,0) = 0 then cuc.intCommodityUnitMeasureId else cuc1.intCommodityUnitMeasureId end,dblTotal)) dblTotal,
			case when isnull(@strUnitMeasure,'')='' then um.strUnitMeasure else @strUnitMeasure end as strUnitMeasure, strLocationName,
		t.intCommodityId,	intCompanyLocationId
  
FROM @Final  t
	LEFT JOIN tblICCommodityUnitMeasure cuc on t.intCommodityId=cuc.intCommodityId and cuc.ysnDefault=1 
	LEFT JOIN tblICUnitMeasure um on um.intUnitMeasureId=cuc.intUnitMeasureId
	LEFT JOIN tblICCommodityUnitMeasure cuc1 on t.intCommodityId=cuc1.intCommodityId and @intUnitMeasureId=cuc1.intUnitMeasureId
	WHERE t.intCommodityId =@intCommodityId
END
SELECT @mRowNumber = MIN(intCommodityIdentity)	FROM @Commodity	WHERE intCommodityIdentity > @mRowNumber
END  
END

IF(@strByType='ByLocation')
BEGIN

			SELECT c.strCommodityCode,strUnitMeasure,strSeqHeader,sum(dblTotal) dblTotal,f.intCommodityId,strLocationName
			FROM @FinalTable f
			join tblICCommodity c on c.intCommodityId= f.intCommodityId			
			GROUP BY c.strCommodityCode,strUnitMeasure,strSeqHeader,f.intCommodityId,strLocationName
END
ELSE
IF(@strByType='ByCommodity')
BEGIN
			SELECT c.strCommodityCode,strUnitMeasure,strSeqHeader,SUM(dblTotal) dblTotal,f.intCommodityId
			FROM @FinalTable f
				join tblICCommodity c on c.intCommodityId= f.intCommodityId
			GROUP BY c.strCommodityCode,strUnitMeasure,strSeqHeader,f.intCommodityId 
END