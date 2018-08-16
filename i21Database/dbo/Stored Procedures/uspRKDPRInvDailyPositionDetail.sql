CREATE PROCEDURE [dbo].[uspRKDPRInvDailyPositionDetail] 
	 @intCommodityId nvarchar(max)  
	,@intLocationId int = NULL	
	,@intVendorId int = null
	,@strPurchaseSales nvarchar(250) = NULL
	,@strPositionIncludes nvarchar(100) = NULL
	,@dtmToDate datetime=null
	,@strByType nvarchar(50) = null
AS
--declare 		 @intCommodityId nvarchar(max)= '3023'
--		,@intLocationId int = null
--		,@intVendorId int = null
--		,@strPurchaseSales nvarchar(50) = null
--		,@strPositionIncludes NVARCHAR(100) = 'All Storage'
--		,@dtmToDate datetime = getdate()
--		,@strByType nvarchar(50) = ''

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

IF OBJECT_ID('tempdb..#tblGetOpenContractDetail') IS NOT NULL
DROP TABLE #tblGetOpenContractDetail
IF OBJECT_ID('tempdb..#tblGetStorageDetailByDate') IS NOT NULL
DROP TABLE #tblGetStorageDetailByDate
IF OBJECT_ID('tempdb..#tblGetStorageOffSiteDetail') IS NOT NULL
DROP TABLE #tblGetStorageOffSiteDetail
IF OBJECT_ID('tempdb..#tblGetSalesIntransitWOPickLot') IS NOT NULL
DROP TABLE #tblGetSalesIntransitWOPickLot
IF OBJECT_ID('tempdb..#tempDeliverySheet') IS NOT NULL
DROP TABLE #tempDeliverySheet
IF OBJECT_ID('tempdb..#tempCollateral') IS NOT NULL
DROP TABLE #tempCollateral
IF OBJECT_ID('tempdb..#invQty') IS NOT NULL
DROP TABLE #invQty
IF OBJECT_ID('tempdb..#tempOnHold') IS NOT NULL
DROP TABLE  #tempOnHold

SELECT intRowNum,strCommodityCode,intCommodityId,intContractHeaderId,strContractNumber,strLocationName,dtmEndDate,dblBalance,intUnitMeasureId,intPricingTypeId,intContractTypeId,
intCompanyLocationId,strContractType,strPricingType,intCommodityUnitMeasureId,intContractDetailId	,intContractStatusId	,intEntityId	,intCurrencyId,
strType,intItemId,strItemNo,dtmContractDate,	strEntityName,strCustomerContract,intFutureMarketId,
intFutureMonthId into #tblGetOpenContractDetail
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
		,intFutureMonthId,strPricingStatus
	FROM tblCTSequenceHistory h
	JOIN tblICItem i ON h.intItemId = i.intItemId
	JOIN tblEMEntity e ON e.intEntityId = h.intEntityId
	WHERE  convert(DATETIME, CONVERT(VARCHAR(10), dtmHistoryCreated, 110), 110) <= @dtmToDate 
	AND h.intCommodityId = case when isnull(@intCommodityId,0)=0 then h.intCommodityId else @intCommodityId end 
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
		,strPricingStatus
	FROM tblCTSequenceHistory h
	JOIN tblICItem i ON h.intItemId = i.intItemId
	JOIN tblEMEntity e ON e.intEntityId = h.intEntityId
	WHERE  convert(DATETIME, CONVERT(VARCHAR(10), dtmHistoryCreated, 110), 110) <= @dtmToDate 
	AND h.intCommodityId = case when isnull(@intCommodityId,0)=0 then h.intCommodityId else @intCommodityId end 
	
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
		,strPricingStatus
	FROM tblCTSequenceHistory h
	JOIN tblICItem i ON h.intItemId = i.intItemId
	JOIN tblEMEntity e ON e.intEntityId = h.intEntityId
	WHERE convert(DATETIME, CONVERT(VARCHAR(10), dtmHistoryCreated, 110), 110) <= @dtmToDate 
	AND h.intCommodityId = case when isnull(@intCommodityId,0)=0 then h.intCommodityId else @intCommodityId end 

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
		,strPricingStatus
	FROM tblCTSequenceHistory h
	JOIN tblICItem i ON h.intItemId = i.intItemId
	JOIN tblEMEntity e ON e.intEntityId = h.intEntityId
	WHERE intContractDetailId NOT IN (
			SELECT intContractDetailId
			FROM tblCTPriceFixation
			) AND convert(DATETIME, CONVERT(VARCHAR(10), convert(DATETIME, CONVERT(VARCHAR(10), dtmHistoryCreated, 110), 110), 110), 110) <= convert(DATETIME, @dtmToDate) 
			AND h.intCommodityId = case when isnull(@intCommodityId,0)=0 then h.intCommodityId else @intCommodityId end 
				
	) a
WHERE a.intRowNum = 1  AND intContractStatusId NOT IN (2, 3, 6) and intPricingTypeId not in (1,2)
)t

--=============================
-- Storage Detail By Date
--=============================
select * into #tblGetStorageDetailByDate from(
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
	,i.intItemId as intItemId  ,t.intTicketId,t.strTicketNumber,a.strStorageTicketNumber strTicket
	,gh.intInventoryReceiptId
	,gh.intInventoryShipmentId
	,ghm.strReceiptNumber
	,ghm.strShipmentNumber
FROM tblGRStorageHistory gh
JOIN vyuGRStorageHistoryNotMapped ghm on gh.intStorageHistoryId = ghm.intStorageHistoryId
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
and a.intCommodityId=case when isnull(@intCommodityId,0)=0 then a.intCommodityId else @intCommodityId end

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
	,i.intItemId as intItemId  ,null intTicketId,strStorageTicketNumber strTicketNumber,a.strStorageTicketNumber strTicket
	,gh.intInventoryReceiptId
	,gh.intInventoryShipmentId
	,ghm.strReceiptNumber
	,ghm.strShipmentNumber
FROM tblGRStorageHistory gh
JOIN vyuGRStorageHistoryNotMapped ghm on gh.intStorageHistoryId = ghm.intStorageHistoryId
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
and a.intCommodityId=case when isnull(@intCommodityId,0)=0 then a.intCommodityId else @intCommodityId end)t

--=============================
-- Storage Off Site
--=============================
SELECT * INTO #tblGetStorageOffSiteDetail FROM (
SELECT ROW_NUMBER() OVER (PARTITION BY sh.intCustomerStorageId ORDER BY dtmDistributionDate DESC) intRowNum,
 a.intCustomerStorageId
	 ,a.intCompanyLocationId	
	,sl.strSubLocationName [Loc]
	,a.dtmDeliveryDate [Delivery Date]
	,a.strStorageTicketNumber [Ticket]
	,a.intEntityId
	,E.strName [Customer]
	,a.strDPARecieptNumber [Receipt]
	,a.dblDiscountsDue [Disc Due]
	,a.dblStorageDue   [Storage Due]
	,sh.dblUnits   [Balance]
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
 	,c1.strScheduleId,
 	isnull(ysnExternal,0) as ysnExternal,
	i.intItemId,  	 
	sh.dtmDistributionDate,r.intInventoryReceiptId, r.strReceiptNumber
FROM tblICInventoryReceipt r
JOIN tblICInventoryReceiptItem ri ON r.intInventoryReceiptId = ri.intInventoryReceiptId
JOIN tblSCTicket sc on sc.intTicketId = ri.intSourceId
LEFT JOIN tblSMCompanyLocationSubLocation sl on sl.intCompanyLocationSubLocationId =sc.intSubLocationId and sl.intCompanyLocationId=sc.intProcessingLocationId 
join tblICItem i on i.intItemId=sc.intItemId
join tblGRStorageHistory sh on sh.intTicketId= sc.intTicketId 
join tblGRCustomerStorage a on a.intCustomerStorageId=sh.intCustomerStorageId
JOIN tblGRStorageType b ON b.intStorageScheduleTypeId = a.intStorageTypeId and b.ysnCustomerStorage = 1
JOIN tblICCommodity CM ON CM.intCommodityId=a.intCommodityId
JOIN tblEMEntity E ON E.intEntityId=a.intEntityId
LEFT JOIN tblGRStorageScheduleRule c1 on c1.intStorageScheduleRuleId=a.intStorageScheduleId
and convert(DATETIME, CONVERT(VARCHAR(10), dtmDistributionDate, 110), 110)  <= convert(datetime,@dtmToDate) and a.intCommodityId=case when isnull(@intCommodityId,0)=0 then a.intCommodityId else @intCommodityId end
and isnull(strTicketStatus,'') <> 'V'
	) a WHERE a.intRowNum =1 

--=============================
-- Sales In Transit w/o Pick Lot
--=============================
SELECT 	strShipmentNumber ,
		intInventoryShipmentId,
		strContractNumber,
		dblShipmentQty,
		intCompanyLocationId,
		strLocationName,
		intContractDetailId,
		dblInvoiceQty,
		(isnull(dblShipmentQty,0)-isnull(dblInvoiceQty,0)) dblBalanceToInvoice,
		intCommodityId,
		strContractItemName as  strItemName, 
		intCommodityUnitMeasureId as intUnitMeasureId
		,intEntityId,strName as strCustomerReference into #tblGetSalesIntransitWOPickLot	
FROM(
				SELECT b.strShipmentNumber,d1.strContractNumber +'-' +Convert(nvarchar,d.intContractSeq) strContractNumber,b.intInventoryShipmentId,
				(SELECT TOP 1 dblQty FROM tblICInventoryShipment sh WHERE sh.strShipmentNumber=it.strTransactionId) dblShipmentQty,
				il.intLocationId intCompanyLocationId,
				il.strDescription strLocationName,
				d.intContractDetailId,
				i.intCommodityId,
				iuom.intItemUOMId,
				i.strItemNo as strContractItemName,
				ium.intCommodityUnitMeasureId,
				b.intEntityCustomerId as intEntityId,
				(SELECT TOP 1 dblQty FROM tblARInvoice ia
				JOIN tblARInvoiceDetail ad on  ia.intInvoiceId=ad.intInvoiceId 
				WHERE ad.strDocumentNumber=it.strTransactionId and ysnPosted=1 ) dblInvoiceQty,
					e.strName
		FROM tblICInventoryTransaction it
		JOIN tblICInventoryShipment b on b.strShipmentNumber=it.strTransactionId  
		JOIN tblICInventoryShipmentItem c on c.intInventoryShipmentId=b.intInventoryShipmentId and b.ysnPosted=1 
		join tblICItem i on c.intItemId=i.intItemId
		JOIN tblICItemUOM iuom on i.intItemId=iuom.intItemId and ysnStockUnit=1 
		JOIN tblICCommodityUnitMeasure ium on ium.intCommodityId=i.intCommodityId AND iuom.intUnitMeasureId=ium.intUnitMeasureId 
		JOIN tblICItemLocation il ON it.intItemId = i.intItemId and it.intItemLocationId=il.intItemLocationId and il.strDescription='In-Transit'		
		JOIN tblEMEntity e on b.intEntityCustomerId=e.intEntityId
		LEFT JOIN tblCTContractDetail d on d.intContractDetailId=c.intLineNo		
		LEFT JOIN tblCTContractHeader d1 on d1.intContractHeaderId=d.intContractHeaderId
		WHERE i.intCommodityId = @intCommodityId and convert(DATETIME, CONVERT(VARCHAR(10), it.dtmCreated, 110), 110)<=convert(datetime,@dtmToDate)
	)t

--==================
-- DELIVERY SHEET
--==================
SELECT [Storage Type] as [Storage Type], strCommodityCode,strType,
	 sum(dblTotal) dblTotal,	
	intCommodityId,strLocationName,strItemNo,dtmDelivarydate,
	 strTicket,strCustomerReference, intFromCommodityUnitMeasureId,intCompanyLocationId,intEntityId,strOwnedPhysicalStock,ysnReceiptedStorage,
	 intStorageScheduleTypeId,intTicketId,strTicketNumber,strCustomer into #tempDeliverySheet from(
SELECT * FROM (
SELECT ROW_NUMBER() OVER (PARTITION BY   GR1.intCustomerStorageId ORDER BY dtmHistoryDate DESC) intRowNum,  GR1.intCustomerStorageId,GR.strStorageTypeDescription [Storage Type],@strDescription strCommodityCode,GR.strStorageTypeDescription strType,
	dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId,@intCommodityUnitMeasureId,GR1.dblUnits) dblTotal,	
	strName strCustomerReference,strDeliverySheetNumber strTicket,CONVERT(DATETIME,CONVERT(VARCHAR(10),dtmDeliverySheetDate ,110),110) dtmDelivarydate,
	l.strLocationName strLocationName,i.strItemNo,
	SCT.intCommodityId intCommodityId, @intCommodityUnitMeasureId intFromCommodityUnitMeasureId,'' strTruckName,'' strDriverName,null [Storage Due],l.intCompanyLocationId  intCompanyLocationId	
	, E.intEntityId , strOwnedPhysicalStock,ysnReceiptedStorage,GR.intStorageScheduleTypeId,SCT.intTicketId,SCD.strDeliverySheetNumber strTicketNumber,E.strName strCustomer
	FROM tblSCDeliverySheet SCD 
	INNER JOIN tblSCTicket SCT ON SCD.intDeliverySheetId = SCT.intDeliverySheetId 
	INNER JOIN tblGRStorageHistory GR1 on SCD.intDeliverySheetId = GR1.intDeliverySheetId
	INNER JOIN tblSCDeliverySheetHistory SCDS ON SCDS.intDeliverySheetId = SCD.intDeliverySheetId and GR1.intEntityId=SCDS.intEntityId
	INNER JOIN tblICItem i on i.intItemId=SCT.intItemId
	JOIN tblICItemUOM iuom on i.intItemId=iuom.intItemId and ysnStockUnit=1
	JOIN tblICCommodityUnitMeasure ium on ium.intCommodityId=i.intCommodityId AND iuom.intUnitMeasureId=ium.intUnitMeasureId 
	INNER JOIN tblSMCompanyLocation l on SCT.intProcessingLocationId=l.intCompanyLocationId
	INNER JOIN tblEMEntity E on E.intEntityId=SCDS.intEntityId
	LEFT JOIN tblGRStorageType GR ON GR.intStorageScheduleTypeId = SCDS.intStorageScheduleTypeId 
	WHERE SCT.strTicketStatus = 'H' and isnull(SCT.intDeliverySheetId,0) <>0   and isnull(SCD.ysnPost,0) =1
	AND SCT.intCommodityId = @intCommodityId  --AND isnull(GR.intStorageScheduleTypeId,0) > 0
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
		SCDS.intDeliverySheetSplitId, GR.strStorageTypeDescription [Storage Type],@strDescription strCommodityCode,GR.strStorageTypeDescription strType,
	dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId,@intCommodityUnitMeasureId,(SCDS.dblQuantity)) dblTotal,
	strName strCustomerReference,strDeliverySheetNumber+('*') strTicket,convert(datetime,CONVERT(VARCHAR(10),dtmDeliverySheetDate ,110),110) dtmDelivarydate,l.strLocationName strLocationName,i.strItemNo,
	SCT.intCommodityId intCommodityId, @intCommodityUnitMeasureId intFromCommodityUnitMeasureId,'' strTruckName,'' strDriverName,null [Storage Due],l.intCompanyLocationId  intCompanyLocationId
	, E.intEntityId , strOwnedPhysicalStock,ysnReceiptedStorage,GR.intStorageScheduleTypeId,intTicketId,SCD.strDeliverySheetNumber  strTicketNumber,E.strName strCustomer
	FROM tblSCDeliverySheet SCD
	INNER JOIN tblSCTicket SCT ON SCD.intDeliverySheetId = SCT.intDeliverySheetId AND SCT.ysnDeliverySheetPost = 0
	INNER JOIN tblSCDeliverySheetHistory SCDS ON SCDS.intDeliverySheetId = SCD.intDeliverySheetId
	INNER JOIN tblICItem i on i.intItemId=SCD.intItemId
	JOIN tblICItemUOM iuom on i.intItemId=iuom.intItemId and ysnStockUnit=1
	JOIN tblICCommodityUnitMeasure ium on ium.intCommodityId=i.intCommodityId AND iuom.intUnitMeasureId=ium.intUnitMeasureId 
	INNER JOIN tblSMCompanyLocation l on SCT.intProcessingLocationId=l.intCompanyLocationId
	INNER JOIN tblEMEntity E on E.intEntityId=SCDS.intEntityId
	LEFT JOIN tblGRStorageType GR ON GR.intStorageScheduleTypeId = SCDS.intStorageScheduleTypeId 
	WHERE SCT.strTicketStatus = 'H' and isnull(SCT.intDeliverySheetId,0) <>0 and isnull(SCD.ysnPost,0) = 0 and isnull(strTicketStatus,'') <> 'V'
	AND SCT.intCommodityId = @intCommodityId  --AND GR.intStorageScheduleTypeId > 0
		AND	l.intCompanyLocationId  = case when isnull(@intLocationId,0)=0 then l.intCompanyLocationId else @intLocationId end and   convert(DATETIME, CONVERT(VARCHAR(10), dtmDeliverySheetHistoryDate, 110), 110) <= convert(datetime,@dtmToDate)
		)a where a.intRowNum =1 	
	)t  
	WHERE dblTotal >0 AND intCompanyLocationId IN (
				SELECT intCompanyLocationId FROM tblSMCompanyLocation
				WHERE isnull(ysnLicensed, 0) = CASE WHEN @strPositionIncludes = 'licensed storage' THEN 1 
								WHEN @strPositionIncludes = 'Non-licensed storage' THEN 0 
								ELSE isnull(ysnLicensed, 0) END)
	GROUP BY  [Storage Type], strCommodityCode,strType,strOwnedPhysicalStock, intEntityId,	 intCommodityId,strLocationName,strItemNo,dtmDelivarydate,ysnReceiptedStorage, strTicket,strCustomerReference, intFromCommodityUnitMeasureId,intCompanyLocationId,intStorageScheduleTypeId,
	intTicketId,strTicketNumber,strCustomer	


SELECT * into #tempCollateral FROM (
		SELECT  ROW_NUMBER() OVER (PARTITION BY intCollateralId ORDER BY dtmTransactionDate DESC) intRowNum,
		dbo.fnCTConvertQuantityToTargetCommodityUOM(ium.intCommodityUnitMeasureId,@intCommodityUnitMeasureId,isnull((c.dblRemainingQuantity),0)) dblTotal,
		c.intCollateralId,cl.strLocationName,ch.strItemNo,ch.strEntityName,c.intReceiptNo,ch.intContractHeaderId,	strContractNumber, c.dtmOpenDate,
		dbo.fnCTConvertQuantityToTargetCommodityUOM(ium.intCommodityUnitMeasureId,@intCommodityUnitMeasureId,isnull((c.dblOriginalQuantity),0)) dblOriginalQuantity,
		dbo.fnCTConvertQuantityToTargetCommodityUOM(ium.intCommodityUnitMeasureId,@intCommodityUnitMeasureId,isnull((c.dblRemainingQuantity),0)) dblRemainingQuantity,
	    @intCommodityId as intCommodityId,c.intUnitMeasureId,c.intLocationId intCompanyLocationId,
		case when c.strType='Purchase' then 1 else 2 end	intContractTypeId
		,c.intLocationId,intEntityId
		FROM tblRKCollateralHistory c
		JOIN tblICCommodity co on co.intCommodityId=c.intCommodityId
		JOIN tblICCommodityUnitMeasure ium on ium.intCommodityId=c.intCommodityId AND c.intUnitMeasureId=ium.intUnitMeasureId 
		JOIN tblSMCompanyLocation cl on cl.intCompanyLocationId=c.intLocationId
		LEFT JOIN #tblGetOpenContractDetail ch on c.intContractHeaderId=ch.intContractHeaderId and ch.intContractStatusId <> 3
		WHERE c.intCommodityId = @intCommodityId and convert(DATETIME, CONVERT(VARCHAR(10), dtmTransactionDate, 110), 110) <= convert(datetime,@dtmToDate) 
		and cl.intCompanyLocationId   IN (SELECT intCompanyLocationId FROM tblSMCompanyLocation
									WHERE isnull(ysnLicensed, 0) = CASE WHEN @strPositionIncludes = 'licensed storage' THEN 1 
									WHEN @strPositionIncludes = 'Non-licensed storage' THEN 0 
									ELSE isnull(ysnLicensed, 0) END
									)
		) a where   a.intRowNum =1 

--=============================
-- Inventory Valuation
--=============================
SELECT 	dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId,@intCommodityUnitMeasureId,(isnull(s.dblQuantity ,0)))  dblTotal,'' strCustomer,null Ticket,null dtmDeliveryDate
	,s.strLocationName,s.strItemNo,@intCommodityId intCommodityId,@intCommodityUnitMeasureId intFromCommodityUnitMeasureId,'' strTruckName,'' strDriverName
	,null [Storage Due],s.intLocationId intLocationId, intTransactionId, strTransactionId,strTransactionType,i.intItemId  into #invQty
	FROM vyuRKGetInventoryValuation s  		
	JOIN tblICItem i on i.intItemId=s.intItemId
	--Join tblICItemLocaiton il on  il.intItemLocationId
	JOIN tblICItemUOM iuom on s.intItemId=iuom.intItemId and iuom.ysnStockUnit=1
	JOIN tblICCommodityUnitMeasure ium on ium.intCommodityId=i.intCommodityId AND iuom.intUnitMeasureId=ium.intUnitMeasureId   
	LEFT JOIN tblSCTicket t on s.strSourceNumber=t.strTicketNumber		  
	WHERE i.intCommodityId = @intCommodityId AND iuom.ysnStockUnit=1 AND ISNULL(s.dblQuantity,0) <>0 
			AND s.intLocationId= CASE WHEN ISNULL(@intLocationId,0)=0 then s.intLocationId else @intLocationId end and isnull(strTicketStatus,'') <> 'V'
			and convert(DATETIME, CONVERT(VARCHAR(10), s.dtmCreated, 110), 110)<=convert(datetime,@dtmToDate) 
			and isnull(t.strDistributionOption,'') <> 'DP'
			and ysnInTransit = 0
			and s.intLocationId  IN (
				SELECT intCompanyLocationId FROM tblSMCompanyLocation
				WHERE isnull(ysnLicensed, 0) = CASE WHEN @strPositionIncludes = 'licensed storage' THEN 1 
								WHEN @strPositionIncludes = 'Non-licensed storage' THEN 0 
								ELSE isnull(ysnLicensed, 0) END
				)


--=============================
-- On Hold
--=============================
SELECT * into #tempOnHold  FROM (
	SELECT  ROW_NUMBER() OVER (PARTITION BY t.intTicketId ORDER BY t.dtmTicketHistoryDate DESC) intSeqId,
	(case when st.strInOutFlag = 'I' then dbo.fnCTConvertQuantityToTargetCommodityUOM(ium.intCommodityUnitMeasureId,@intCommodityUnitMeasureId,isnull(st.dblNetUnits, 0)) else abs(dbo.fnCTConvertQuantityToTargetCommodityUOM(ium.intCommodityUnitMeasureId,@intCommodityUnitMeasureId,isnull(st.dblNetUnits, 0))) * -1 end ) AS dblTotal,
	strName strCustomer,st.strTicketNumber Ticket,dtmTicketDateTime dtmDeliveryDate,
	cl.strLocationName,i1.strItemNo,@intCommodityId intCommodityId,@intCommodityUnitMeasureId intCommodityUnitMeasureId,strTruckName,strDriverName,null [Storage Due], st.intProcessingLocationId intLocationId
	,strCustomerReference,strDistributionOption,e.intEntityId,intDeliverySheetId,st.intTicketId,st.strTicketNumber
	FROM tblSCTicketHistory t
	JOIN tblSCTicket st on t.intTicketId=st.intTicketId
	JOIN tblEMEntity e on e.intEntityId= st.intEntityId
	JOIN tblSMCompanyLocation  cl on cl.intCompanyLocationId=st.intProcessingLocationId and st.strDistributionOption='HLD'
	JOIN tblICItem i1 on i1.intItemId=st.intItemId
	JOIN tblICItemUOM iuom on i1.intItemId=iuom.intItemId and ysnStockUnit=1
	JOIN tblICCommodityUnitMeasure ium on ium.intCommodityId=i1.intCommodityId AND iuom.intUnitMeasureId=ium.intUnitMeasureId 
	WHERE st.intCommodityId  = @intCommodityId and isnull(st.intDeliverySheetId,0) =0
			AND st.intProcessingLocationId  = CASE WHEN ISNULL(@intLocationId,0)=0 then st.intProcessingLocationId else @intLocationId end
			AND convert(DATETIME, CONVERT(VARCHAR(10), t.dtmTicketHistoryDate, 110), 110) <=CONVERT(DATETIME,@dtmToDate)
			and isnull(strTicketStatus,'') <> 'V'
	)t 	WHERE intLocationId IN (
		SELECT intCompanyLocationId FROM tblSMCompanyLocation
		WHERE isnull(ysnLicensed, 0) = CASE WHEN @strPositionIncludes = 'licensed storage' THEN 1 
						WHEN @strPositionIncludes = 'Non-licensed storage' THEN 0 
						ELSE isnull(ysnLicensed, 0) END)
	AND t.intSeqId =1 
	
IF ISNULL(@intVendorId,0) = 0
BEGIN

	--IR
	INSERT INTO @Final(intSeqId,strSeqHeader,strCommodityCode,strType,dblTotal,strLocationName,intItemId,strItemNo,intCommodityId,intFromCommodityUnitMeasureId,intCompanyLocationId,strReceiptNumber, intInventoryReceiptId)
	select intSeqId,strSeqHeader,strCommodityCode,strType,sum(dblTotal) dblTotal,strLocationName,intItemId,strItemNo,intCommodityId,intFromCommodityUnitMeasureId,intCompanyLocationId, strTransactionId, intTransactionId from(
	SELECT 1 AS intSeqId,'In-House' strSeqHeader,@strDescription strCommodityCode,'Receipt' AS [strType],isnull(dblTotal,0) dblTotal,strLocationName,intItemId,strItemNo,
			@intCommodityId intCommodityId,@intCommodityUnitMeasureId intFromCommodityUnitMeasureId,intLocationId intCompanyLocationId, strTransactionId, intTransactionId
	FROM #invQty where intCommodityId=@intCommodityId and strTransactionType = 'Inventory Receipt')t
	group by intSeqId,strSeqHeader,strCommodityCode,strType,strLocationName,intItemId,strItemNo,intCommodityId,intFromCommodityUnitMeasureId,intCompanyLocationId,strTransactionId,intTransactionId
	

	--IS
	INSERT INTO @Final(intSeqId,strSeqHeader,strCommodityCode,strType,dblTotal,strLocationName,intItemId,strItemNo,intCommodityId,intFromCommodityUnitMeasureId,intCompanyLocationId,strShipmentNumber, intInventoryShipmentId)
	select intSeqId,strSeqHeader,strCommodityCode,strType,sum(dblTotal) dblTotal,strLocationName,intItemId,strItemNo,intCommodityId,intFromCommodityUnitMeasureId,intCompanyLocationId, strTransactionId, intTransactionId from(
	SELECT 1 AS intSeqId,'In-House' strSeqHeader,@strDescription strCommodityCode,'Receipt' AS [strType],isnull(dblTotal,0) dblTotal,strLocationName,intItemId,strItemNo,
			@intCommodityId intCommodityId,@intCommodityUnitMeasureId intFromCommodityUnitMeasureId,intLocationId intCompanyLocationId, strTransactionId, intTransactionId
	FROM #invQty where intCommodityId=@intCommodityId and strTransactionType = 'Inventory Shipment')t
	group by intSeqId,strSeqHeader,strCommodityCode,strType,strLocationName,intItemId,strItemNo,intCommodityId,intFromCommodityUnitMeasureId,intCompanyLocationId,strTransactionId,intTransactionId
	
	--IR from Settlement
	INSERT INTO @Final(intSeqId,strSeqHeader,strCommodityCode,strType,dblTotal,strLocationName,intItemId,strItemNo,intCommodityId,intFromCommodityUnitMeasureId,intCompanyLocationId,strReceiptNumber, intInventoryReceiptId)
	select intSeqId,strSeqHeader,strCommodityCode,strType,sum(dblTotal) dblTotal,strLocationName,intItemId,strItemNo,intCommodityId,intFromCommodityUnitMeasureId,intCompanyLocationId, strTransactionId, intTransactionId from(
	SELECT 1 AS intSeqId,'In-House' strSeqHeader,@strDescription strCommodityCode,'Receipt' AS [strType],isnull(dblTotal,0) dblTotal,strLocationName,intItemId,strItemNo,
			@intCommodityId intCommodityId,@intCommodityUnitMeasureId intFromCommodityUnitMeasureId,intLocationId intCompanyLocationId, strTransactionId, intTransactionId
	FROM #invQty where intCommodityId=@intCommodityId and strTransactionType = 'Storage Settlement')t
	group by intSeqId,strSeqHeader,strCommodityCode,strType,strLocationName,intItemId,strItemNo,intCommodityId,intFromCommodityUnitMeasureId,intCompanyLocationId,strTransactionId,intTransactionId

	--From Storages
	INSERT INTO @Final(intSeqId,strSeqHeader,strCommodityCode,strType,dblTotal,strCustomer,intTicketId,strTicketNumber,dtmDeliveryDate,strLocationName,strItemNo,intCommodityId,intFromCommodityUnitMeasureId,intCompanyLocationId,intInventoryReceiptId,intInventoryShipmentId,strReceiptNumber,strShipmentNumber,strDistributionOption)
	--select intSeqId,strSeqHeader,strCommodityCode,strType,sum(dblTotal),strCustomer,intCustomerStorageId,strTicket,dtmDeliveryDate,strLocationName,strItemNo,intCommodityId,intFromCommodityUnitMeasureId,intCompanyLocationId from(
	SELECT distinct 1 AS intSeqId,'In-House' strSeqHeader,@strDescription strCommodityCode,[Storage Type] AS [strType],
	dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId,@intCommodityUnitMeasureId,Balance) dblTotal,
	strName strCustomer,intCustomerStorageId,strTicket,[Delivery Date] dtmDeliveryDate
	,strLocationName,strItemNo,@intCommodityId intCommodityId,@intCommodityUnitMeasureId intFromCommodityUnitMeasureId
	,intCompanyLocationId
	,s.intInventoryReceiptId
	,s.intInventoryShipmentId
	,s.strReceiptNumber
	,s.strShipmentNumber
	,'Storage'
	FROM #tblGetStorageDetailByDate s
	JOIN tblEMEntity e on e.intEntityId= s.intEntityId
	WHERE 
	intCommodityId = @intCommodityId AND intCompanyLocationId= case when isnull(@intLocationId,0)=0 then intCompanyLocationId else @intLocationId end
	and intCompanyLocationId   IN (SELECT intCompanyLocationId FROM tblSMCompanyLocation
						WHERE isnull(ysnLicensed, 0) = CASE WHEN @strPositionIncludes = 'licensed storage' THEN 1 
						WHEN @strPositionIncludes = 'Non-licensed storage' THEN 0 
						ELSE isnull(ysnLicensed, 0) END
						)--)t 
	--GROUP BY intSeqId,strSeqHeader,strCommodityCode,strType,strCustomer,intCustomerStorageId,strTicket,dtmDeliveryDate,strLocationName,strItemNo,intCommodityId,intFromCommodityUnitMeasureId,intCompanyLocationId
	
	INSERT INTO @Final(intSeqId,strSeqHeader,strCommodityCode,strType,dblTotal,strCustomer,intTicketId,strTicketNumber,dtmDeliveryDate,strLocationName,strItemNo,intCommodityId,intFromCommodityUnitMeasureId,[Storage Due],intCompanyLocationId)
	SELECT intSeqId,strSeqHeader,strCommodityCode,strType,sum(dblTotal) dblTotal,strCustomer,intTicketId,strTicketNumber,dtmDeliveryDate,strLocationName,strItemNo,intCommodityId, intCommodityUnitMeasureId intFromCommodityUnitMeasureId,[Storage Due],intCompanyLocationId from(
	SELECT distinct  1 intSeqId,'In-House' strSeqHeader,@strDescription strCommodityCode,'On-Hold' strType, dblTotal dblTotal, strCustomer,intTicketId,strTicketNumber, dtmDeliveryDate,strLocationName,
			strItemNo,intCommodityId,intCommodityUnitMeasureId,strTruckName,strDriverName,[Storage Due],intLocationId intCompanyLocationId
	FROM #tempOnHold  where intCommodityId=@intCommodityId)t
	group by intSeqId,strSeqHeader,strCommodityCode,strType,strCustomer,intTicketId,strTicketNumber,dtmDeliveryDate,strLocationName,strItemNo,intCommodityId,intCommodityUnitMeasureId,[Storage Due],intCompanyLocationId

	-- Delivery sheet
	INSERT INTO @Final (intSeqId,strSeqHeader,strCommodityCode,strType,dblTotal,intCommodityId,strLocationName ,strItemNo,dtmDeliveryDate ,strTicket ,strCustomerReference,
	strCustomer ,intFromCommodityUnitMeasureId,intCompanyLocationId,strTicketNumber,intTicketId)
	SELECT distinct   1,'In-House', strCommodityCode,strType, dblTotal  dblTotal,intCommodityId,strLocationName,
	strItemNo,dtmDelivarydate, strTicket,strCustomerReference,strCustomer, intFromCommodityUnitMeasureId,intCompanyLocationId,strTicketNumber,intTicketId  
	FROM #tempDeliverySheet 

	INSERT INTO @Final(intSeqId,strSeqHeader,strCommodityCode,strType,dblTotal,strLocationName,strItemNo,strShipmentNumber,intInventoryShipmentId,strCustomerReference,strContractNumber,intCommodityId,intFromCommodityUnitMeasureId,intCompanyLocationId)
	SELECT 1 AS intSeqId,'In-House',@strDescription
	,'Sales In-Transit' AS [strType]
	,-ISNULL(ReserveQty, 0) AS dblTotal,strLocationName,strItemName,strShipmentNumber,intInventoryShipmentId ,strCustomerReference,strContractNumber,@intCommodityId,@intCommodityUnitMeasureId,intCompanyLocationId
	FROM (
	SELECT dbo.fnCTConvertQuantityToTargetCommodityUOM(i.intUnitMeasureId,@intCommodityUnitMeasureId,isnull(i.dblBalanceToInvoice, 0)) as ReserveQty,
			i.strLocationName,i.strItemName,strContractNumber,strShipmentNumber,intInventoryShipmentId,strCustomerReference,i.intCompanyLocationId
			FROM #tblGetSalesIntransitWOPickLot i
			WHERE i.intCommodityId = @intCommodityId
			AND i.intCompanyLocationId= case when isnull(@intLocationId,0)=0 then i.intCompanyLocationId else @intLocationId end	
			)t 
			
	INSERT INTO @Final (intSeqId,strSeqHeader,strCommodityCode,strType,dblTotal,intCommodityId ,strLocationName ,strItemNo,dtmDeliveryDate ,strTicket ,
					strCustomerReference,strDPAReceiptNo ,dblDiscDue ,[Storage Due] , dtmLastStorageAccrueDate ,strScheduleId,intFromCommodityUnitMeasureId,intCompanyLocationId,intInventoryReceiptId,strReceiptNumber)
		SELECT 2,'Off-Site',@strDescription,'Off-Site',	dblTotal,intCommodityId,strLocation,strItemNo ,dtmDeliveryDate ,strTicket ,strCustomerReference ,strDPAReceiptNo,dblDiscDue,
		[Storage Due] ,dtmLastStorageAccrueDate,strScheduleId,@intCommodityUnitMeasureId intFromCommodityUnitMeasureId ,intCompanyLocationId ,intInventoryReceiptId,strReceiptNumber
		FROM 
		(SELECT dbo.fnCTConvertQuantityToTargetCommodityUOM(ium.intCommodityUnitMeasureId,@intCommodityUnitMeasureId,(Balance)) dblTotal,r.intCommodityId,Loc AS strLocation,i.strItemNo ,[Delivery Date] AS dtmDeliveryDate ,
				Ticket strTicket ,Customer as strCustomerReference ,Receipt AS strDPAReceiptNo ,[Disc Due] AS dblDiscDue ,
				[Storage Due] AS [Storage Due] ,dtmLastStorageAccrueDate ,strScheduleId,intCompanyLocationId,intInventoryReceiptId,strReceiptNumber
		FROM #tblGetStorageOffSiteDetail r 
		join tblICItem i on r.intItemId=i.intItemId
		JOIN tblICItemUOM iuom on i.intItemId=iuom.intItemId and ysnStockUnit=1 
		JOIN tblICCommodityUnitMeasure ium on ium.intCommodityId=i.intCommodityId AND iuom.intUnitMeasureId=ium.intUnitMeasureId 
		WHERE ysnReceiptedStorage = 1 AND ysnExternal = 1 AND strOwnedPhysicalStock = 'Customer' AND r.intCommodityId = @intCommodityId 
		AND intCompanyLocationId= case when isnull(@intLocationId,0)=0 then intCompanyLocationId else @intLocationId end
		) t WHERE intCompanyLocationId IN (
				SELECT intCompanyLocationId FROM tblSMCompanyLocation
				WHERE isnull(ysnLicensed, 0) = CASE WHEN @strPositionIncludes = 'licensed storage' THEN 1 
								WHEN @strPositionIncludes = 'Non-licensed storage' THEN 0 
								ELSE isnull(ysnLicensed, 0) END
				)
				


	INSERT INTO @Final(intSeqId,strSeqHeader,strCommodityCode,strType,dblTotal,strLocationName,strItemNo,strShipmentNumber,intInventoryShipmentId,strCustomerReference,strContractNumber,intCommodityId,intFromCommodityUnitMeasureId,intCompanyLocationId)
	SELECT 4 AS intSeqId,'Sales In-Transit',@strDescription
		,'Sales In-Transit' AS [strType]
		,abs(dblTotal) dblTotal,strLocationName,strItemNo,strShipmentNumber,intInventoryShipmentId,strCustomerReference,strContractNumber,intCommodityId,intFromCommodityUnitMeasureId,intCompanyLocationId
	FROM (
		SELECT * from @Final where strSeqHeader='In-House' and strType='Sales In-Transit')t 

	--========================
	--Customer Storage
	--==========================
	INSERT INTO @Final(intSeqId,strSeqHeader,strCommodityCode,strType,dblTotal,strCustomer,intTicketId,strTicketNumber,dtmDeliveryDate,strLocationName,strItemNo,intCommodityId,intFromCommodityUnitMeasureId,intCompanyLocationId,intInventoryReceiptId,intInventoryShipmentId,strReceiptNumber,strShipmentNumber)
	--select intSeqId,strSeqHeader,strCommodityCode,strType,sum(dblTotal),strCustomer,intCustomerStorageId,strTicket,dtmDeliveryDate,strLocationName,strItemNo,intCommodityId,intFromCommodityUnitMeasureId,intCompanyLocationId from(
	SELECT distinct 5 AS intSeqId,[Storage Type] strSeqHeader,@strDescription strCommodityCode,[Storage Type] AS [strType],
	dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId,@intCommodityUnitMeasureId,Balance) dblTotal,
	strName strCustomer,intCustomerStorageId,strTicket,[Delivery Date] dtmDeliveryDate
	,strLocationName,strItemNo,@intCommodityId intCommodityId,@intCommodityUnitMeasureId intFromCommodityUnitMeasureId
	,intCompanyLocationId
	,s.intInventoryReceiptId
	,s.intInventoryShipmentId
	,s.strReceiptNumber
	,s.strShipmentNumber
	FROM #tblGetStorageDetailByDate s
	JOIN tblEMEntity e on e.intEntityId= s.intEntityId
	WHERE 
	s.strOwnedPhysicalStock = 'Customer' and
	intCommodityId = @intCommodityId AND intCompanyLocationId= case when isnull(@intLocationId,0)=0 then intCompanyLocationId else @intLocationId end
	and intCompanyLocationId   IN (SELECT intCompanyLocationId FROM tblSMCompanyLocation
						WHERE isnull(ysnLicensed, 0) = CASE WHEN @strPositionIncludes = 'licensed storage' THEN 1 
						WHEN @strPositionIncludes = 'Non-licensed storage' THEN 0 
						ELSE isnull(ysnLicensed, 0) END
						)--)t 
	--GROUP BY intSeqId,strSeqHeader,strCommodityCode,strType,strCustomer,intCustomerStorageId,strTicket,dtmDeliveryDate,strLocationName,strItemNo,intCommodityId,intFromCommodityUnitMeasureId,intCompanyLocationId


	INSERT INTO @Final (intSeqId,strSeqHeader,strCommodityCode,strType,dblTotal,intCommodityId,strLocationName ,strItemNo,dtmDeliveryDate ,strTicket ,strCustomerReference,strCustomer,
					  intFromCommodityUnitMeasureId,intCompanyLocationId,strTicketNumber,intTicketId)

	SELECT distinct  5 intSeqId , [Storage Type], strCommodityCode,strType, dblTotal  dblTotal,intCommodityId,strLocationName,
	strItemNo,dtmDelivarydate, strTicket,strCustomerReference,strCustomerReference, intFromCommodityUnitMeasureId,intCompanyLocationId,strTicketNumber,intTicketId  
	FROM #tempDeliverySheet



	IF (@ysnDisplayAllStorage=1)
	BEGIN
		INSERT INTO @Final (intSeqId,strSeqHeader,strCommodityCode,strType,dblTotal,intCommodityId)
		SELECT 5,strStorageTypeDescription [Storage Type],@strDescription,strStorageTypeDescription,0.00,@intCommodityId
		FROM tblGRStorageType  
		WHERE ISNULL(ysnActive,0) = 1 AND intStorageScheduleTypeId > 0 AND ysnReceiptedStorage =0
			  AND intStorageScheduleTypeId NOT IN(SELECT DISTINCT isnull(intStorageScheduleTypeId,0) FROM @Final WHERE intSeqId=5)
	END

	INSERT INTO @Final(intSeqId,strSeqHeader,strCommodityCode,strType,dblTotal,dtmDeliveryDate ,strTicket ,strLocationName,strItemNo,intCommodityId,
	intFromCommodityUnitMeasureId,[Storage Due],intCompanyLocationId,intTicketId,strTicketNumber)
	SELECT * FROM 
	(SELECT 7 AS intSeqId,'Total Non-Receipted' strSeqHeader,@strDescription strCommodityCode
		,'Total Non-Receipted' [Storage Type]
		,dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId,@intCommodityUnitMeasureId ,ISNULL(Balance, 0)) dblTotal,
		[Delivery Date],
		 Ticket,
		strLocationName,r.strItemNo, @intCommodityId intCommodityId,@intCommodityUnitMeasureId intCommodityUnitMeasureId
		,[Storage Due],intCompanyLocationId,r.intTicketId,r.strTicketNumber
	FROM #tblGetStorageDetailByDate  r
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

-- Delivery sheet
	INSERT INTO @Final (intSeqId,strSeqHeader,strCommodityCode,strType,dblTotal,intCommodityId,strLocationName ,strItemNo,dtmDeliveryDate ,strTicket ,strCustomerReference,strCustomer
					  ,intFromCommodityUnitMeasureId,intCompanyLocationId,intTicketId,strTicketNumber)

	SELECT DISTINCT 7 AS intSeqId,'Total Non-Receipted' strSeqHeader, strCommodityCode,strType, dblTotal  dblTotal,intCommodityId,strLocationName,
	strItemNo,dtmDelivarydate, strTicket,strCustomerReference,strCustomerReference, intFromCommodityUnitMeasureId,intCompanyLocationId,intTicketId,strTicketNumber  
	FROM #tempDeliverySheet where ysnReceiptedStorage=0 AND strOwnedPhysicalStock = 'Customer'

--Collatral Sale
	INSERT INTO @Final(intSeqId,strSeqHeader,strCommodityCode,strType,dblTotal,intCollateralId,strLocationName,strItemNo,strCustomer,intReceiptNo,intContractHeaderId,strContractNumber,dtmOpenDate,dblOriginalQuantity,dblRemainingQuantity,intCommodityId,intFromCommodityUnitMeasureId,intCompanyLocationId)
		SELECT * FROM (
		SELECT 8 intSeqId,'Collateral Receipts - Sales' strSeqHeader, @strDescription strCommodityCode,'Collateral Receipts - Sales' strType,
		 dblTotal,intCollateralId,strLocationName,strItemNo,strEntityName,intReceiptNo,intContractHeaderId,
		strContractNumber,dtmOpenDate,dblOriginalQuantity,dblRemainingQuantity ,intCommodityId,intUnitMeasureId,intCompanyLocationId
		FROM #tempCollateral
		WHERE intContractTypeId = 2 AND intCommodityId = @intCommodityId 
		AND intLocationId = case when isnull(@intLocationId,0)=0 then intLocationId  else @intLocationId end)t
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
		 dblTotal,intCollateralId,strLocationName,strItemNo,strEntityName,intReceiptNo,intContractHeaderId,
		strContractNumber,dtmOpenDate,dblOriginalQuantity,dblRemainingQuantity ,intCommodityId,intUnitMeasureId,intCompanyLocationId
		FROM #tempCollateral 
		WHERE intContractTypeId = 1 AND
		  intCommodityId = @intCommodityId 
		AND intLocationId = case when isnull(@intLocationId,0)=0 then intLocationId  else @intLocationId end)t
								WHERE intCompanyLocationId  IN (
				SELECT intCompanyLocationId FROM tblSMCompanyLocation
				WHERE isnull(ysnLicensed, 0) = CASE WHEN @strPositionIncludes = 'licensed storage' THEN 1 
								WHEN @strPositionIncludes = 'Non-licensed storage' THEN 0 
								ELSE isnull(ysnLicensed, 0) END
				) 

	INSERT INTO @Final (intSeqId,strSeqHeader,strCommodityCode,strType,dblTotal,intCommodityId,strLocationName ,strItemNo,dtmDeliveryDate ,strTicket ,strCustomerReference,strDPAReceiptNo ,	dblDiscDue ,
					  [Storage Due] ,	dtmLastStorageAccrueDate ,strScheduleId,intFromCommodityUnitMeasureId,intCompanyLocationId,intInventoryReceiptId,strReceiptNumber)
SELECT * FROM (
			SELECT 10 intSeqId,[Storage Type],@strDescription strCommodityCode,[Storage Type] strType,
			dbo.fnCTConvertQuantityToTargetCommodityUOM(ium.intCommodityUnitMeasureId,@intCommodityUnitMeasureId,(Balance)) dblTotal,
			r.intCommodityId  ,Loc AS strLocation ,i.strItemNo,[Delivery Date] AS dtmDeliveryDate ,Ticket strTicket  
			,Customer as strCustomerReference ,Receipt AS strDPAReceiptNo ,[Disc Due] AS dblDiscDue ,[Storage Due] AS [Storage Due]  
			,dtmLastStorageAccrueDate ,strScheduleId,@intCommodityUnitMeasureId intCommodityUnitMeasureId,intCompanyLocationId,intInventoryReceiptId,strReceiptNumber  
			FROM #tblGetStorageOffSiteDetail  r
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

IF (@ysnDisplayAllStorage=1)
	BEGIN			 
		INSERT INTO @Final (intSeqId,strSeqHeader,strCommodityCode,strType,dblTotal,intCommodityId)
		SELECT 10,strStorageTypeDescription [Storage Type],@strDescription,strStorageTypeDescription,0.00,@intCommodityId
		FROM tblGRStorageType  
		WHERE ISNULL(ysnActive,0) = 1 AND intStorageScheduleTypeId > 0 AND ysnReceiptedStorage = 1
				AND intStorageScheduleTypeId NOT IN(SELECT DISTINCT isnull(intStorageScheduleTypeId,0) FROM @Final WHERE intSeqId=5)
	END
	INSERT INTO @Final(intSeqId,strSeqHeader,strCommodityCode,strType,dblTotal,intCommodityId,intFromCommodityUnitMeasureId,strLocationName)
	select 11 AS intSeqId,'Total Receipted',@strDescription,'Collateral Purchase' AS [strType],-isnull(dblTotal, 0) dblTotal,@intCommodityId,@intCommodityUnitMeasureId,strLocationName dblTotal from @Final where intSeqId=9
	union
	select 11 AS intSeqId,'Total Receipted',@strDescription,'Collateral Sale' AS [strType],isnull(dblTotal, 0)dblTotal,@intCommodityId,@intCommodityUnitMeasureId,strLocationName dblTotal from @Final where intSeqId=8
	union
	select 11 AS intSeqId,'Total Receipted',@strDescription,'Collateral Receipted' AS [strType],isnull(dblTotal, 0) dblTotal,@intCommodityId,@intCommodityUnitMeasureId,strLocationName dblTotal from @Final where intSeqId=10
	
	INSERT INTO @Final (intSeqId,strSeqHeader,strCommodityCode,strType,dblTotal,intCommodityId,strLocationName,strItemNo,dtmDeliveryDate ,strTicket ,strCustomerReference,strDPAReceiptNo ,	dblDiscDue ,
					  [Storage Due] ,	dtmLastStorageAccrueDate ,strScheduleId,intFromCommodityUnitMeasureId,intCompanyLocationId,intTicketId,strTicketNumber)
		SELECT * FROM (
			SELECT 12 intSeqId,[Storage Type],@strDescription strCommodityCode,[Storage Type] strType,
			dbo.fnCTConvertQuantityToTargetCommodityUOM(ium.intCommodityUnitMeasureId,@intCommodityUnitMeasureId,ISNULL(Balance, 0)) dblTotal,r.intCommodityId  ,Loc AS strLocation ,
			i.strItemNo,[Delivery Date] AS dtmDeliveryDate ,Ticket strTicket  
			,Customer as strCustomerReference ,Receipt AS strDPAReceiptNo ,[Disc Due] AS dblDiscDue ,[Storage Due] AS [Storage Due]  
			,dtmLastStorageAccrueDate ,strScheduleId,@intCommodityUnitMeasureId intCommodityUnitMeasureId,intCompanyLocationId ,r.intTicketId,r.strTicketNumber 
			FROM #tblGetStorageDetailByDate  r
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


	INSERT INTO @Final (intSeqId,strSeqHeader,strCommodityCode,strType,dblTotal,intCommodityId,strLocationName,strItemNo,strTicket,dtmTicketDateTime,strCustomerReference, strDistributionOption,intFromCommodityUnitMeasureId,intCompanyLocationId,strDPAReceiptNo,strContractNumber,intContractHeaderId,intInventoryReceiptId,strReceiptNumber)
			SELECT intSeqId,strSeqHeader,strCommodityCode,strType,sum(dblTotal),intCommodityId,strLocationName,strItemNo,strTicket,dtmTicketDateTime,strCustomerReference, strDistributionOption,intCommodityUnitMeasureId ,intCompanyLocationId,strReceiptNumber ,strContractNumber,intContractHeaderId,intInventoryReceiptId,strReceiptNumber FROM (
		
			SELECT 13 intSeqId,'Pur Basis Deliveries' strSeqHeader,@strDescription strCommodityCode,'Pur Basis Deliveries' strType,
			dbo.fnCTConvertQuantityToTargetCommodityUOM(ium.intCommodityUnitMeasureId,@intCommodityUnitMeasureId,isnull(v.dblQuantity ,0)) AS dblTotal,
			@intCommodityId intCommodityId,cl.strLocationName,cd.strItemNo,strTicketNumber strTicket,st.dtmTicketDateTime,strCustomerReference,
					strDistributionOption,@intCommodityUnitMeasureId intCommodityUnitMeasureId,st.intProcessingLocationId intCompanyLocationId,strReceiptNumber,
					cd.strContractNumber,intContractHeaderId,r.intInventoryReceiptId
						FROM vyuRKGetInventoryValuation v
			join tblICInventoryReceipt r on r.strReceiptNumber=v.strTransactionId
			INNER JOIN tblICInventoryReceiptItem ri ON r.intInventoryReceiptId = ri.intInventoryReceiptId AND r.strReceiptType = 'Purchase Contract'
			INNER JOIN tblSCTicket st ON st.intTicketId = ri.intSourceId  AND strDistributionOption IN ('CNT') and  isnull(ysnInTransit,0)=0 
			INNER JOIN #tblGetOpenContractDetail cd ON cd.intContractDetailId = ri.intLineNo AND cd.intPricingTypeId = 2  and cd.intContractStatusId <> 3
			JOIN tblICCommodityUnitMeasure ium on ium.intCommodityId=cd.intCommodityId AND cd.intUnitMeasureId=ium.intUnitMeasureId 
			INNER JOIN tblSMCompanyLocation  cl on cl.intCompanyLocationId=st.intProcessingLocationId 
			WHERE v.strTransactionType ='Inventory Receipt' and cd.intCommodityId = @intCommodityId AND st.intProcessingLocationId  = case when isnull(@intLocationId,0)=0 then st.intProcessingLocationId else @intLocationId end
			and convert(DATETIME, CONVERT(VARCHAR(10), v.dtmCreated, 110), 110)<=convert(datetime,@dtmToDate) and isnull(strTicketStatus,'') <> 'V'
			)t	WHERE  intCompanyLocationId  IN (
				SELECT intCompanyLocationId FROM tblSMCompanyLocation
				WHERE isnull(ysnLicensed, 0) = CASE WHEN @strPositionIncludes = 'licensed storage' THEN 1 
								WHEN @strPositionIncludes = 'Non-licensed storage' THEN 0 
								ELSE isnull(ysnLicensed, 0) END)
								group by intSeqId,strSeqHeader,strCommodityCode,strType,intCommodityId,strLocationName,strItemNo,strTicket,dtmTicketDateTime,strCustomerReference, strDistributionOption,intCommodityUnitMeasureId ,intCompanyLocationId,strReceiptNumber ,strContractNumber,intContractHeaderId 
								,intInventoryReceiptId,strReceiptNumber
	--
	INSERT INTO @Final (intSeqId,strSeqHeader,strCommodityCode,strType,dblTotal,intCommodityId,strLocationName,strItemNo,strTicket,dtmTicketDateTime,strCustomerReference, strDistributionOption,
						intFromCommodityUnitMeasureId,intCompanyLocationId,strDPAReceiptNo,strContractNumber,intInventoryShipmentId,strShipmentNumber)
			select * from (
			SELECT distinct 14 intSeqId,'Sls Basis Deliveries' strSeqHeader,@strDescription strCommodityCode,'Sls Basis Deliveries' strType,
			dbo.fnCTConvertQuantityToTargetCommodityUOM(ium.intCommodityUnitMeasureId,@intCommodityUnitMeasureId,isnull(ri.dblQuantity, 0))  AS dblTotal,
			cd.intCommodityId,cl.strLocationName,cd.strItemNo,strContractNumber strTicketNumber,
			cd.dtmContractDate as dtmTicketDateTime ,
			cd.strCustomerContract as strCustomerReference, 'CNT' as strDistributionOption,cd.intUnitMeasureId,cl.intCompanyLocationId,strShipmentNumber,cd.strContractNumber
			,r.intInventoryShipmentId,strShipmentNumber strShipmentNumber1
			FROM vyuRKGetInventoryValuation v 
			JOIN tblICInventoryShipment r on r.strShipmentNumber=v.strTransactionId
			INNER JOIN tblICInventoryShipmentItem ri ON r.intInventoryShipmentId = ri.intInventoryShipmentId
			INNER JOIN #tblGetOpenContractDetail cd ON cd.intContractDetailId = ri.intLineNo AND cd.intPricingTypeId = 2	and cd.intContractStatusId <> 3  AND cd.intContractTypeId = 2
			JOIN tblICCommodityUnitMeasure ium on ium.intCommodityId=cd.intCommodityId AND cd.intUnitMeasureId=ium.intUnitMeasureId 
			INNER JOIN tblSMCompanyLocation  cl on cl.intCompanyLocationId=cd.intCompanyLocationId
			WHERE cd.intCommodityId = @intCommodityId AND v.strTransactionType ='Inventory Shipment'
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
	--INSERT INTO @Final(intSeqId,strSeqHeader,strCommodityCode,strType,dblTotal,strLocationName,intItemId,strItemNo,intCommodityId,intFromCommodityUnitMeasureId,intCompanyLocationId)
	--select intSeqId,strSeqHeader,strCommodityCode,strType,sum(dblTotal) dblTotal,strLocationName,intItemId,strItemNo,intCommodityId,intFromCommodityUnitMeasureId,intCompanyLocationId from (
	--SELECT 15 intSeqId,'Company Titled Stock' strSeqHeader,strCommodityCode,'Receipt' strType,dblTotal ,strLocationName,intItemId,strItemNo,intCommodityId,intFromCommodityUnitMeasureId,intCompanyLocationId 
	--FROM @Final where strSeqHeader='In-House' and strType='Receipt' and intCommodityId=@intCommodityId)t
	--group by intSeqId,strSeqHeader,strCommodityCode,strType,strLocationName,intItemId,strItemNo,intCommodityId,intFromCommodityUnitMeasureId,intCompanyLocationId

	--Company Title from Inventory Valuation
	INSERT INTO @Final(intSeqId,strSeqHeader,strCommodityCode,strType,dblTotal,strLocationName,intItemId,strItemNo,intCommodityId,intFromCommodityUnitMeasureId,intCompanyLocationId,strReceiptNumber,strShipmentNumber,intInventoryReceiptId,intInventoryShipmentId )
	SELECT 15 intSeqId,'Company Titled Stock' strSeqHeader,strCommodityCode,'Receipt' strType,dblTotal ,strLocationName,intItemId,strItemNo,intCommodityId,intFromCommodityUnitMeasureId,intCompanyLocationId,strReceiptNumber,strShipmentNumber,intInventoryReceiptId,intInventoryShipmentId 
	FROM @Final where strSeqHeader='In-House' and strType='Receipt' and intCommodityId=@intCommodityId

	INSERT INTO @Final(intSeqId,strSeqHeader,strCommodityCode,strType,dblTotal,intCommodityId,intFromCommodityUnitMeasureId,strLocationName)
	select * from (
	SELECT distinct intSeqId,strSeqHeader,strCommodityCode,strType,sum(dblTotal) dblTotal ,intCommodityId,intFromCommodityUnitMeasureId,strLocationName from(
	SELECT 15 AS intSeqId,'Company Titled Stock' strSeqHeader ,@strDescription strCommodityCode,[strType],
	case when strType = 'Collateral Receipts - Purchase' then isnull(dblTotal, 0) else -isnull(dblTotal, 0) end dblTotal,
		@intCommodityId intCommodityId,@intCommodityUnitMeasureId intFromCommodityUnitMeasureId,strLocationName strLocationName
		 FROM @Final where intSeqId in (9,8) and strType in('Collateral Receipts - Purchase','Collateral Receipts - Sales') and intCommodityId=@intCommodityId )t
		 GROUP BY intSeqId,strSeqHeader,strCommodityCode,strType,intCommodityId,intFromCommodityUnitMeasureId,strLocationName) t where dblTotal<>0


	INSERT INTO @Final (intSeqId,strSeqHeader,strCommodityCode,strType,dblTotal,intCommodityId,strLocationName,strItemNo,strTicket,dtmTicketDateTime,strCustomerReference, strDistributionOption,
							intFromCommodityUnitMeasureId,intCompanyLocationId,strDPAReceiptNo,strContractNumber,intInventoryShipmentId,strShipmentNumber)
	select 15 intSeqId,'Company Titled Stock'strSeqHeader,strCommodityCode,strType,dblTotal,intCommodityId,strLocationName,strItemNo,strTicket,dtmTicketDateTime,strCustomerReference, strDistributionOption,
						intFromCommodityUnitMeasureId,intCompanyLocationId,strDPAReceiptNo,strContractNumber,intInventoryShipmentId,strShipmentNumber 
	FROM @Final WHERE intSeqId = 14 and intCommodityId=@intCommodityId

	If ((SELECT TOP 1 ysnIncludeOffsiteInventoryInCompanyTitled from tblRKCompanyPreference)=1)
	BEGIN

	INSERT INTO @Final (intSeqId,strSeqHeader,strCommodityCode,strType,dblTotal,intCommodityId ,strLocationName ,strItemNo,dtmDeliveryDate ,strTicket ,
					strCustomerReference,strDPAReceiptNo ,dblDiscDue ,[Storage Due] , dtmLastStorageAccrueDate ,strScheduleId,intFromCommodityUnitMeasureId,intCompanyLocationId,intInventoryReceiptId,strReceiptNumber)
	SELECT 15 intSeqId,'Company Titled Stock',@strDescription,'Off-Site',	dblTotal,intCommodityId,strLocation,strItemNo ,dtmDeliveryDate ,strTicket ,strCustomerReference ,strDPAReceiptNo,dblDiscDue,
		[Storage Due] ,dtmLastStorageAccrueDate,strScheduleId,@intCommodityUnitMeasureId intFromCommodityUnitMeasureId ,intCompanyLocationId ,intTicketId,strTicketNumber
		FROM  (
	SELECT dbo.fnCTConvertQuantityToTargetCommodityUOM(ium.intCommodityUnitMeasureId,@intCommodityUnitMeasureId,(Balance)) dblTotal,CH.intCommodityId,Loc AS strLocation,i.strItemNo ,[Delivery Date] AS dtmDeliveryDate ,
				Ticket strTicket ,Customer as strCustomerReference ,Receipt AS strDPAReceiptNo ,[Disc Due] AS dblDiscDue ,
				[Storage Due] AS [Storage Due] ,dtmLastStorageAccrueDate ,strScheduleId,intCompanyLocationId,intTicketId,strTicketNumber
			FROM #tblGetStorageDetailByDate CH
			join tblICItem i on CH.intItemId=i.intItemId
			JOIN tblICItemUOM iuom on i.intItemId=iuom.intItemId and ysnStockUnit=1 
			JOIN tblICCommodityUnitMeasure ium on ium.intCommodityId=i.intCommodityId AND iuom.intUnitMeasureId=ium.intUnitMeasureId 
			 WHERE ysnCustomerStorage = 1	AND strOwnedPhysicalStock = 'Company'
			AND CH.intCommodityId  = @intCommodityId
						AND CH.intCompanyLocationId= case when isnull(@intLocationId,0)=0 then CH.intCompanyLocationId else @intLocationId end	
				 )t WHERE intCompanyLocationId IN (
								SELECT intCompanyLocationId FROM tblSMCompanyLocation
								WHERE isnull(ysnLicensed, 0) = CASE WHEN @strPositionIncludes = 'licensed storage' THEN 1 
												WHEN @strPositionIncludes = 'Non-licensed storage' THEN 0 ELSE isnull(ysnLicensed, 0) END
				)
	END


	--=========================================
	-- Includes DP based on Company Preference
	--========================================
	If ((SELECT TOP 1 ysnIncludeDPPurchasesInCompanyTitled from tblRKCompanyPreference)=1)
	BEGIN
		
	INSERT INTO @Final(intSeqId,strSeqHeader,strCommodityCode,strType,dblTotal,intTicketId,strTicketNumber,intFromCommodityUnitMeasureId,intCommodityId,strLocationName)
	SELECT 15 intSeqId,'Company Titled Stock',@strDescription,'DP',sum(dblTotal) dblTotal,intTicketId,strTicketNumber,intFromCommodityUnitMeasureId,intCommodityId,strLocationName  from(
			SELECT intTicketId,strTicketNumber,
					dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId,@intCommodityUnitMeasureId,(isnull(Balance,0))) dblTotal
					,ch.intCompanyLocationId,intCommodityUnitMeasureId intFromCommodityUnitMeasureId,intCommodityId,strLocationName
					FROM #tblGetStorageDetailByDate ch
					WHERE 
					
					ch.intCommodityId  = @intCommodityId	AND ysnDPOwnedType = 1
						AND ch.intCompanyLocationId= case when isnull(@intLocationId,0)=0 then ch.intCompanyLocationId else @intLocationId end
					)t 	WHERE intCompanyLocationId  IN (
								SELECT intCompanyLocationId FROM tblSMCompanyLocation
								WHERE isnull(ysnLicensed, 0) = CASE WHEN @strPositionIncludes = 'licensed storage' THEN 1 
								WHEN @strPositionIncludes = 'Non-licensed storage' THEN 0 
								ELSE isnull(ysnLicensed, 0) END
				) group by intTicketId,strTicketNumber,intFromCommodityUnitMeasureId,intCommodityId,strLocationName

	END
	
	INSERT INTO @Final(intSeqId,strSeqHeader,strCommodityCode,strType,dblTotal,strLocationName,intItemId,strItemNo,intCommodityId,intFromCommodityUnitMeasureId,intCompanyLocationId)
	SELECT 15 intSeqId,'On-Hold' strSeqHeader,strCommodityCode,strType,dblTotal,strLocationName,intItemId,strItemNo,intCommodityId,intFromCommodityUnitMeasureId,intCompanyLocationId 
	FROM @Final where strSeqHeader='In-House' and strType='On-Hold'
END
ELSE 
BEGIN
    INSERT INTO @Final(intSeqId,strSeqHeader,strCommodityCode,strType,dblTotal,dtmDeliveryDate ,strTicket,strLocationName,strItemNo,strCustomer,intCommodityId,intFromCommodityUnitMeasureId,strTruckName,strDriverName,[Storage Due],intCompanyLocationId)                                
    (SELECT 1 intSeqId,'In-House' strSeqHeader,@strDescription strCommodityCode,[strType],dblTotal,dtmDeliveryDate,strTicket,strLocationName,strItemNo,strName,intCommodityId,intFromCommodityUnitMeasureId,strTruckName,strDriverName
                    ,[Storage Due],intLocationId 
    FROM(  SELECT  [Storage Type] AS [strType],
            dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId,@intCommodityUnitMeasureId,isnull(Balance,0)) dblTotal,
			Ticket strTicket,s.[Delivery Date] dtmDeliveryDate
                ,strLocationName,strItemNo,@intCommodityId intCommodityId,@intCommodityUnitMeasureId intFromCommodityUnitMeasureId,'' strTruckName,'' strDriverName,[Storage Due]
                ,intCompanyLocationId intLocationId,strName
                FROM #tblGetStorageDetailByDate s
                JOIN tblEMEntity e on s.intEntityId=e.intEntityId
                WHERE intCommodityId = @intCommodityId AND 
                intCompanyLocationId= case when isnull(@intLocationId,0)=0 then intCompanyLocationId else @intLocationId end
                AND s.intEntityId= @intVendorId and strOwnedPhysicalStock='Customer'

            UNION all
                SELECT 'On-Hold' strType, dblTotal,
				Ticket,dtmDeliveryDate, strLocationName,strItemNo,@intCommodityId,@intCommodityUnitMeasureId,strTruckName,strDriverName,null [Storage Due], 
                        intLocationId,strCustomer
                FROM #tempOnHold
                WHERE intEntityId= @intVendorId 
				)t     WHERE intLocationId IN (
                        SELECT intCompanyLocationId FROM tblSMCompanyLocation
                        WHERE isnull(ysnLicensed, 0) = CASE WHEN @strPositionIncludes = 'licensed storage' THEN 1 
                                                    WHEN @strPositionIncludes = 'Non-licensed storage' THEN 0 
                                                    ELSE isnull(ysnLicensed, 0) END)
		)
		 
	INSERT INTO @Final (intSeqId,strSeqHeader,strCommodityCode,strType,dblTotal,intCommodityId,strLocationName ,strItemNo,dtmDeliveryDate ,strTicket ,strCustomerReference,strCustomer
					  ,intFromCommodityUnitMeasureId,intCompanyLocationId)
	SELECT distinct   1,'In-House', strCommodityCode,strType, dblTotal  dblTotal,intCommodityId,strLocationName,
	strItemNo,dtmDelivarydate, strTicket,strCustomerReference,strCustomerReference, intFromCommodityUnitMeasureId,intCompanyLocationId  
	FROM #tempDeliverySheet  where intEntityId= @intVendorId  AND strOwnedPhysicalStock = 'Customer'

	INSERT INTO @Final (intSeqId,strSeqHeader,strCommodityCode,strType,dblTotal,intCommodityId ,strLocationName,strItemNo,strCustomer,dtmDeliveryDate ,strTicket ,
					strCustomerReference,strDPAReceiptNo ,dblDiscDue ,[Storage Due] , dtmLastStorageAccrueDate ,strScheduleId,intFromCommodityUnitMeasureId,intCompanyLocationId)
		select * from (
		SELECT 2 intSeqId,'Off-Site' strSeqHeader,@strDescription strCommodityCode,'Off-Site' strType,
		dbo.fnCTConvertQuantityToTargetCommodityUOM(ium.intCommodityUnitMeasureId,@intCommodityUnitMeasureId,(Balance)) dblTotal,r.intCommodityId,Loc AS strLocation,
		i.strItemNo ,strName,[Delivery Date] AS dtmDeliveryDate ,
				Ticket strTicket ,Customer as strCustomerReference ,Receipt AS strDPAReceiptNo ,[Disc Due] AS dblDiscDue ,
				[Storage Due] AS [Storage Due] ,dtmLastStorageAccrueDate ,strScheduleId,@intCommodityUnitMeasureId intCommodityUnitMeasureId,intCompanyLocationId  
		FROM #tblGetStorageOffSiteDetail r
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
		FROM #tblGetStorageDetailByDate  r
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
			-- Delivary sheet

	INSERT INTO @Final (intSeqId,strSeqHeader,strCommodityCode,strType,dblTotal,intCommodityId,strLocationName ,strItemNo,dtmDeliveryDate ,strTicket ,strCustomerReference,strCustomer
					  ,intFromCommodityUnitMeasureId,intCompanyLocationId)
	SELECT distinct   5,[Storage Type], strCommodityCode,strType, dblTotal  dblTotal,intCommodityId,strLocationName,
	strItemNo,dtmDelivarydate, strTicket,strCustomerReference,strCustomerReference, intFromCommodityUnitMeasureId,intCompanyLocationId  
	FROM #tempDeliverySheet  where intEntityId= @intVendorId  AND strOwnedPhysicalStock = 'Customer'
	IF (@ysnDisplayAllStorage=1)
	BEGIN
		INSERT INTO @Final (intSeqId,strSeqHeader,strCommodityCode,strType,dblTotal,intCommodityId)
		SELECT 5,strStorageTypeDescription [Storage Type],@strDescription,strStorageTypeDescription,0.00,@intCommodityId
		FROM tblGRStorageType  
		WHERE ISNULL(ysnActive,0) = 1 AND intStorageScheduleTypeId > 0 AND ysnReceiptedStorage =0
			  AND intStorageScheduleTypeId NOT IN(SELECT DISTINCT isnull(intStorageScheduleTypeId,0) FROM @Final WHERE intSeqId=5)
	END
	
	INSERT INTO @Final(intSeqId,strSeqHeader,strCommodityCode,strType,dblTotal,dtmDeliveryDate ,strTicket,strLocationName,strItemNo,strCustomer,intCommodityId,intFromCommodityUnitMeasureId,[Storage Due],intCompanyLocationId)
	select * from (
	SELECT 7 AS intSeqId,'Total Non-Receipted' strSeqHeader,@strDescription strCommodityCode
		,'Total Non-Receipted' [Storage Type]
		,dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId,@intCommodityUnitMeasureId,ISNULL(Balance, 0)) dblTotal,
		[Delivery Date],Ticket,
		strLocationName,r.strItemNo,
		strName, @intCommodityId AS intCommodityId,@intCommodityUnitMeasureId AS intCommodityUnitMeasureId,[Storage Due],intCompanyLocationId
	FROM #tblGetStorageDetailByDate  r
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

	INSERT INTO @Final (intSeqId,strSeqHeader,strCommodityCode,strType,dblTotal,intCommodityId,strLocationName ,strItemNo,dtmDeliveryDate ,strTicket ,strCustomerReference,strCustomer
					  ,intFromCommodityUnitMeasureId,intCompanyLocationId)
	SELECT distinct   7 AS intSeqId,'Total Non-Receipted' strSeqHeader, strCommodityCode,strType, dblTotal  dblTotal,intCommodityId,strLocationName,
	strItemNo,dtmDelivarydate, strTicket,strCustomerReference,strCustomerReference, intFromCommodityUnitMeasureId,intCompanyLocationId  
	FROM #tempDeliverySheet  where intEntityId= @intVendorId  AND strOwnedPhysicalStock = 'Customer' and  ysnReceiptedStorage=0


	INSERT INTO @Final(intSeqId,strSeqHeader,strCommodityCode,strType,dblTotal,intCollateralId,strLocationName,strItemNo,strCustomer,intReceiptNo,intContractHeaderId,strContractNumber,dtmOpenDate,dblOriginalQuantity,dblRemainingQuantity,intCommodityId,intFromCommodityUnitMeasureId,intCompanyLocationId)
		SELECT * FROM (
		SELECT 8 intSeqId,'Collateral Receipts - Sales' strSeqHeader, @strDescription strCommodityCode,'Collateral Receipts - Sales' strType,
		dblTotal,intCollateralId,strLocationName,strItemNo,strEntityName,intReceiptNo,intContractHeaderId,strContractNumber,dtmOpenDate,
		dblOriginalQuantity,dblRemainingQuantity,@intCommodityId AS intCommodityId,intUnitMeasureId,intLocationId intCompanyLocationId 
		FROM #tempCollateral
		WHERE intContractTypeId = 2 AND intCommodityId = @intCommodityId 
		AND intLocationId = case when isnull(@intLocationId,0)=0 then intLocationId  else @intLocationId end
		AND intEntityId= @intVendorId )t WHERE intCompanyLocationId  IN (
				SELECT intCompanyLocationId FROM tblSMCompanyLocation
				WHERE isnull(ysnLicensed, 0) = CASE WHEN @strPositionIncludes = 'licensed storage' THEN 1 
								WHEN @strPositionIncludes = 'Non-licensed storage' THEN 0 
								ELSE isnull(ysnLicensed, 0) END
				)

	INSERT INTO @Final(intSeqId,strSeqHeader,strCommodityCode,strType,dblTotal,intCollateralId,strLocationName,strItemNo,strCustomer,intReceiptNo,intContractHeaderId,strContractNumber,dtmOpenDate,dblOriginalQuantity,dblRemainingQuantity,intCommodityId,intFromCommodityUnitMeasureId,intCompanyLocationId)
		SELECT * FROM (
		SELECT 9 intSeqId,'Collateral Receipts - Purchase' strSeqHeader, @strDescription strCommodityCode,'Collateral Receipts - Purchase' strType,
		dblTotal,intCollateralId,strLocationName,strItemNo,strEntityName,intReceiptNo,intContractHeaderId,strContractNumber,dtmOpenDate,
		dblOriginalQuantity,dblRemainingQuantity,@intCommodityId intCommodityId,intUnitMeasureId,intLocationId intCompanyLocationId	
		FROM #tempCollateral
		WHERE intContractTypeId = 1 AND intCommodityId = @intCommodityId 
		AND intLocationId = case when isnull(@intLocationId,0)=0 then intLocationId  else @intLocationId end
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
			FROM #tblGetStorageOffSiteDetail  r
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
IF (@ysnDisplayAllStorage=1)
	BEGIN			 
			INSERT INTO @Final (intSeqId,strSeqHeader,strCommodityCode,strType,dblTotal,intCommodityId)
			SELECT 10,strStorageTypeDescription [Storage Type],@strDescription,strStorageTypeDescription,0.00,@intCommodityId
			FROM tblGRStorageType  
			WHERE ISNULL(ysnActive,0) = 1 AND intStorageScheduleTypeId > 0 AND ysnReceiptedStorage = 1
				  AND intStorageScheduleTypeId NOT IN(SELECT DISTINCT isnull(intStorageScheduleTypeId,0) FROM @Final WHERE intSeqId=5)
	END

	INSERT INTO @Final(intSeqId,strSeqHeader,strCommodityCode,strType,dblTotal,intCommodityId,intFromCommodityUnitMeasureId)
    SELECT 11 AS intSeqId,'Total Receipted',@strDescription
		,'Total Receipted' AS [strType]
		,isnull(dblTotal, 0)  + case when @strPurchaseSales = 'Purchase' then isnull(CollateralSale, 0) else 0 end  + case when @strPurchaseSales ='Sales' then isnull(CollateralPurchases, 0) else 0 end  dblTotal,@intCommodityId,@intCommodityUnitMeasureId
	FROM (select sum(dblTotal) dblTotal from @Final where intSeqId=10) dblTotal
		,(SELECT dblTotal CollateralSale FROM @Final where intSeqId = 8 and strSeqHeader='Collateral Receipts - Sales') AS CollateralSale
		,(SELECT dblTotal CollateralPurchases FROM @Final where intSeqId = 9 and strSeqHeader='Collateral Receipts - Purchase')   AS CollateralPurchases

	INSERT INTO @Final (intSeqId,strSeqHeader,strCommodityCode,strType,dblTotal,intCommodityId,strLocationName,strItemNo,strCustomer,strTicket,dtmTicketDateTime,strCustomerReference, strDistributionOption,intFromCommodityUnitMeasureId,intCompanyLocationId,strContractNumber,intContractHeaderId)
			SELECT * FROM (
			SELECT 13 intSeqId,'Pur Basis Deliveries' strSeqHeader,@strDescription strCommodityCode,'Purchase Basis Deliveries' strType,
			dbo.fnCTConvertQuantityToTargetCommodityUOM(ium.intCommodityUnitMeasureId,@intCommodityUnitMeasureId,isnull((PLDetail.dblLotPickedQty),0))
			 AS dblTotal,@intCommodityId intCommodityId,cl.strLocationName,CT.strItemNo,strName,CT.strContractNumber strTicket,CT.dtmContractDate as dtmTicketDateTime ,
			CT.strCustomerContract as strCustomerReference, 'CNT' as strDistributionOption,@intCommodityUnitMeasureId intCommodityUnitMeasureId,CT.intCompanyLocationId intCompanyLocationId,CT.strContractNumber,intContractHeaderId
			FROM tblLGDeliveryPickDetail Del
			INNER JOIN tblLGPickLotDetail PLDetail ON PLDetail.intPickLotDetailId = Del.intPickLotDetailId
			INNER JOIN vyuLGPickOpenInventoryLots Lots ON Lots.intLotId = PLDetail.intLotId
			INNER JOIN #tblGetOpenContractDetail CT ON CT.intContractDetailId = Lots.intContractDetailId  and CT.intContractStatusId <> 3
			JOIN tblEMEntity e on e.intEntityId=CT.intEntityId
			JOIN tblICCommodityUnitMeasure ium on ium.intCommodityId=CT.intCommodityId AND CT.intUnitMeasureId=ium.intUnitMeasureId 
			INNER JOIN tblSMCompanyLocation  cl on cl.intCompanyLocationId=CT.intCompanyLocationId
			WHERE CT.intPricingTypeId = 2 AND CT.intCommodityId = @intCommodityId 
			AND CT.intCompanyLocationId  = case when isnull(@intLocationId,0)=0 then CT.intCompanyLocationId   else @intLocationId end
			AND CT.intEntityId= @intVendorId 

			UNION ALL
			
			SELECT 13 intSeqId,'Pur Basis Deliveries' strSeqHeader,@strDescription strCommodityCode,'Purchase Basis Deliveries' strType,
			dbo.fnCTConvertQuantityToTargetCommodityUOM(ium.intCommodityUnitMeasureId,@intCommodityUnitMeasureId,isnull(v.dblQuantity ,0)) AS dblTotal,
			@intCommodityId intCommodityId,cl.strLocationName,cd.strItemNo,strName,strTicketNumber strTicket,st.dtmTicketDateTime,strCustomerReference,
					strDistributionOption,@intCommodityUnitMeasureId AS intCommodityUnitMeasureId,st.intProcessingLocationId intCompanyLocationId,cd.strContractNumber,intContractHeaderId
			FROM vyuRKGetInventoryValuation v
			join tblICInventoryReceipt r on r.strReceiptNumber=v.strTransactionId
			INNER JOIN tblICInventoryReceiptItem ri ON r.intInventoryReceiptId = ri.intInventoryReceiptId AND r.strReceiptType = 'Purchase Contract'
			INNER JOIN tblSCTicket st ON st.intTicketId = ri.intSourceId  AND strDistributionOption IN ('CNT')
			JOIN tblEMEntity e on st.intEntityId=e.intEntityId
			INNER JOIN #tblGetOpenContractDetail cd ON cd.intContractDetailId = ri.intLineNo AND cd.intPricingTypeId = 2  and cd.intContractStatusId <> 3
			JOIN tblICCommodityUnitMeasure ium on ium.intCommodityId=cd.intCommodityId AND cd.intUnitMeasureId=ium.intUnitMeasureId 
			INNER JOIN tblSMCompanyLocation  cl on cl.intCompanyLocationId=st.intProcessingLocationId 
			WHERE cd.intCommodityId = @intCommodityId 
			AND st.intProcessingLocationId  = case when isnull(@intLocationId,0)=0 then st.intProcessingLocationId else @intLocationId end
			AND st.intEntityId= @intVendorId and convert(DATETIME, CONVERT(VARCHAR(10), v.dtmCreated, 110), 110)<=convert(datetime,@dtmToDate)
			and isnull(strTicketStatus,'') <> 'V'
			)t 	WHERE intCompanyLocationId IN (
				SELECT intCompanyLocationId FROM tblSMCompanyLocation
				WHERE isnull(ysnLicensed, 0) = CASE WHEN @strPositionIncludes = 'licensed storage' THEN 1 
								WHEN @strPositionIncludes = 'Non-licensed storage' THEN 0 
								ELSE isnull(ysnLicensed, 0) END
				) 

	INSERT INTO @Final (intSeqId,strSeqHeader,strCommodityCode,strType,dblTotal,intCommodityId,strLocationName,strItemNo,strCustomer,strTicket,dtmTicketDateTime,strCustomerReference, 
						strDistributionOption,intFromCommodityUnitMeasureId,intCompanyLocationId,strContractNumber )
			select * from (
			SELECT 14 intSeqId,'Sls Basis Deliveries' strSeqHeader,@strDescription strCommodityCode,'Sales Basis Deliveries' strType,
			dbo.fnCTConvertQuantityToTargetCommodityUOM(ium.intCommodityUnitMeasureId,@intCommodityUnitMeasureId,isnull(ri.dblQuantity, 0))  AS dblTotal,
			cd.intCommodityId,cl.strLocationName,cd.strItemNo,strName,cd.strContractNumber strTicketNumber,
			cd.dtmContractDate as dtmTicketDateTime ,
			cd.strCustomerContract as strCustomerReference, 'CNT' as strDistributionOption,cd.intUnitMeasureId,cl.intCompanyLocationId,cd.strContractNumber 
			FROM  vyuRKGetInventoryValuation v 
			JOIN tblICInventoryShipment r on r.strShipmentNumber=v.strTransactionId
			INNER JOIN tblICInventoryShipmentItem ri ON r.intInventoryShipmentId = ri.intInventoryShipmentId
			INNER JOIN #tblGetOpenContractDetail cd ON cd.intContractDetailId = ri.intLineNo AND cd.intPricingTypeId = 2	and cd.intContractStatusId <> 3
			JOIN tblEMEntity e on r.intEntityId=cd.intEntityId
			JOIN tblICCommodityUnitMeasure ium on ium.intCommodityId=cd.intCommodityId AND cd.intUnitMeasureId=ium.intUnitMeasureId 
			INNER JOIN tblSMCompanyLocation  cl on cl.intCompanyLocationId=cd.intCompanyLocationId
			WHERE cd.intCommodityId = @intCommodityId 
			AND cl.intCompanyLocationId  = case when isnull(@intLocationId,0)=0 then cl.intCompanyLocationId else @intLocationId end
			and cd.intEntityId= @intVendorId and convert(DATETIME, CONVERT(VARCHAR(10), v.dtmCreated, 110), 110)<=CONVERT(DATETIME,@dtmToDate))t
				WHERE intCompanyLocationId IN (
				SELECT intCompanyLocationId FROM tblSMCompanyLocation
				WHERE isnull(ysnLicensed, 0) = CASE WHEN @strPositionIncludes = 'licensed storage' THEN 1 
								WHEN @strPositionIncludes = 'Non-licensed storage' THEN 0 
								ELSE isnull(ysnLicensed, 0) END
				) 

	INSERT INTO @Final (intSeqId,strSeqHeader,strCommodityCode,strType,dblTotal,intCommodityId,strLocationName,strItemNo,strCustomer,strTicket,dtmDeliveryDate,strCustomerReference,
					 strDistributionOption,intFromCommodityUnitMeasureId,strTruckName,strDriverName,intCompanyLocationId)
	SELECT * FROM (
	SELECT 16 intSeqId,'On-Hold' strSeqHeader,@strDescription strCommodityCode,'On-Hold' strType,
		dblTotal,intCommodityId,strLocationName,strItemNo,strCustomer,Ticket strTicket,dtmDeliveryDate,strCustomerReference,strDistributionOption,
		@intCommodityUnitMeasureId intCommodityUnitMeasureId,strTruckName,strDriverName,intLocationId
		FROM #tempOnHold
		WHERE intCommodityId  = @intCommodityId
			  AND intLocationId  = case when isnull(@intLocationId,0)=0 then intLocationId else @intLocationId end
			  AND intEntityId= @intVendorId and isnull(intDeliverySheetId,0) =0 )t
				WHERE intLocationId IN (
				SELECT intCompanyLocationId FROM tblSMCompanyLocation
				WHERE isnull(ysnLicensed, 0) = CASE WHEN @strPositionIncludes = 'licensed storage' THEN 1 
								WHEN @strPositionIncludes = 'Non-licensed storage' THEN 0 
								ELSE isnull(ysnLicensed, 0) END
				) 
END
		
DECLARE @intUnitMeasureId int
DECLARE @strUnitMeasure nvarchar(250)
SELECT TOP 1 @intUnitMeasureId = intUnitMeasureId FROM tblRKCompanyPreference
select @strUnitMeasure=strUnitMeasure from tblICUnitMeasure where intUnitMeasureId=@intUnitMeasureId
INSERT INTO @FinalTable (intSeqId,strSeqHeader, strCommodityCode ,strType ,dblTotal ,strUnitMeasure, intCollateralId,strLocationName,strCustomer,
				intReceiptNo,intContractHeaderId,strContractNumber ,dtmOpenDate,dblOriginalQuantity ,dblRemainingQuantity ,intCommodityId,
				strCustomerReference ,strDistributionOption ,strDPAReceiptNo,dblDiscDue ,[Storage Due] ,dtmLastStorageAccrueDate ,strScheduleId ,strTicket ,
				dtmDeliveryDate ,dtmTicketDateTime,strItemNo,strTruckName,strDriverName,intInventoryReceiptId,strReceiptNumber,intTicketId,strTicketNumber,strShipmentNumber,
				intInventoryShipmentId,intItemId
)

SELECT	intSeqId,strSeqHeader, strCommodityCode ,strType ,
			    Convert(decimal(24,10),dbo.fnCTConvertQuantityToTargetCommodityUOM(cuc.intCommodityUnitMeasureId,
		case when isnull(@intUnitMeasureId,0) = 0 then cuc.intCommodityUnitMeasureId else cuc1.intCommodityUnitMeasureId end,dblTotal)) dblTotal,
			case when isnull(@strUnitMeasure,'')='' then um.strUnitMeasure else @strUnitMeasure end as strUnitMeasure, intCollateralId,strLocationName,strCustomer,
		intReceiptNo,intContractHeaderId,strContractNumber ,dtmOpenDate,dblOriginalQuantity ,dblRemainingQuantity ,t.intCommodityId,
		strCustomerReference ,strDistributionOption ,strDPAReceiptNo ,
		dblDiscDue ,[Storage Due] ,	dtmLastStorageAccrueDate ,strScheduleId ,strTicket ,
		dtmDeliveryDate ,dtmTicketDateTime,strItemNo,strTruckName,strDriverName,intInventoryReceiptId,strReceiptNumber,intTicketId,
		strTicketNumber,strShipmentNumber,intInventoryShipmentId,intItemId
  
FROM @Final  t
	LEFT JOIN tblICCommodityUnitMeasure cuc on t.intCommodityId=cuc.intCommodityId and cuc.ysnDefault=1 
	LEFT JOIN tblICUnitMeasure um on um.intUnitMeasureId=cuc.intUnitMeasureId
	LEFT JOIN tblICCommodityUnitMeasure cuc1 on t.intCommodityId=cuc1.intCommodityId and @intUnitMeasureId=cuc1.intUnitMeasureId
	WHERE t.intCommodityId= @intCommodityId	
END

SELECT @mRowNumber = MIN(intCommodityIdentity)	FROM @Commodity	WHERE intCommodityIdentity > @mRowNumber
END  
END

IF(@strByType='ByLocation')
BEGIN

			SELECT strCommodityCode,strUnitMeasure,strSeqHeader,sum(dblTotal) dblTotal,intCommodityId,strLocationName
			FROM @FinalTable 
			where  strSeqHeader in('Company Titled Stock','In-House') and isnull(dblTotal,0) <>0 
			GROUP BY strCommodityCode,strUnitMeasure,strSeqHeader,intCommodityId,strLocationName
END
ELSE
IF(@strByType='ByCommodity')
BEGIN
			SELECT strCommodityCode,strUnitMeasure,strSeqHeader,SUM(dblTotal) dblTotal,intCommodityId
			FROM @FinalTable 
			where dblTotal <> 0 and strSeqHeader in('Company Titled Stock','In-House')  and isnull(dblTotal,0) <>0
			GROUP BY strCommodityCode,strUnitMeasure,strSeqHeader,intCommodityId 
END
ELSE
BEGIN
		if isnull(@intVendorId,0) = 0
		BEGIN
		SELECT intRow,intSeqId,strSeqHeader, strCommodityCode ,strType ,dblTotal ,strUnitMeasure, intCollateralId,strLocationName,strCustomer,
							intReceiptNo,intContractHeaderId,strContractNumber ,dtmOpenDate,dblOriginalQuantity ,dblRemainingQuantity ,intCommodityId,
							strCustomerReference ,strDistributionOption ,strDPAReceiptNo,dblDiscDue ,[Storage Due] as dblStorageDue ,dtmLastStorageAccrueDate ,
							strScheduleId ,strTicket,dtmDeliveryDate ,dtmTicketDateTime,strItemNo,strTruckName,strDriverName,
							intInventoryReceiptId,isnull(strReceiptNumber,'') strReceiptNumber,intTicketId,isnull(strShipmentNumber,'') strShipmentNumber,
							intInventoryShipmentId,intItemId, isnull(strTicketNumber,'') strTicketNumber
			
		FROM @FinalTable where   isnull(dblTotal,0) <>0 
		 ORDER BY strCommodityCode,intSeqId ASC,intContractHeaderId DESC 
		END
		ELSE
		BEGIN
		SELECT intRow,intSeqId,strSeqHeader, strCommodityCode ,strType ,dblTotal ,strUnitMeasure, intCollateralId,strLocationName,strCustomer,
							intReceiptNo,intContractHeaderId,strContractNumber ,dtmOpenDate,dblOriginalQuantity ,dblRemainingQuantity ,intCommodityId,
							strCustomerReference ,strDistributionOption ,strDPAReceiptNo,dblDiscDue ,[Storage Due] as dblStorageDue ,dtmLastStorageAccrueDate ,strScheduleId ,strTicket ,
							dtmDeliveryDate ,dtmTicketDateTime,strItemNo,strTruckName,strDriverName	,intInventoryReceiptId,isnull(strReceiptNumber,'') strReceiptNumber,intTicketId,isnull(strShipmentNumber,'') strShipmentNumber,
							intInventoryShipmentId,intItemId, isnull(strTicketNumber,'') strTicketNumber
		FROM @FinalTable WHERE strType <> 'Company Titled Stock'-- and strType not like '%'+@strPurchaseSales+'%'
		  and isnull(dblTotal,0) <>0
		 ORDER BY strCommodityCode,intSeqId ASC,intContractHeaderId DESC
		END
END