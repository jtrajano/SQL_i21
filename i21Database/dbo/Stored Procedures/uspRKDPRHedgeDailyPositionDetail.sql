CREATE PROCEDURE [dbo].[uspRKDPRHedgeDailyPositionDetail] 
		 @intCommodityId nvarchar(max)= null
		,@intLocationId int = null
		,@intVendorId int = null
		,@strPurchaseSales NVARCHAR(200) = null
		,@strPositionIncludes NVARCHAR(200) = NULL
		,@dtmToDate datetime = NULL
		,@strByType NVARCHAR(200) = null
AS

--declare 		 @intCommodityId nvarchar(max)= ''
--		,@intLocationId int = null
--		,@intVendorId int = null
--		,@strPurchaseSales NVARCHAR(200) = null
--		,@strPositionIncludes NVARCHAR(200) = 'All Storage'
--		,@dtmToDate datetime = getdate()
--		,@strByType NVARCHAR(200) = 'ByCommodity'

DECLARE @strCommodityCode NVARCHAR(max)
IF ISNULL(@strPurchaseSales,'') <> ''
BEGIN
	IF @strPurchaseSales='Purchase'
	BEGIN
		SELECT @strPurchaseSales='Sale'
	END
	ELSE
	BEGIN
		SELECT @strPurchaseSales='Purchase'
	END
END
SET @dtmToDate = convert(DATETIME, CONVERT(VARCHAR(10), @dtmToDate, 110), 110)
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
DECLARE @tempFinal AS TABLE (
		 intRow INT IDENTITY(1,1),
		 intContractHeaderId int,
		 strContractNumber NVARCHAR(200),
		 intFutOptTransactionHeaderId int,
		 strInternalTradeNo NVARCHAR(200),
		 strCommodityCode NVARCHAR(200),   
		 strType  NVARCHAR(200), 
		 strSubType  NVARCHAR(200), 
		 strContractType NVARCHAR(200),
		 strLocationName NVARCHAR(200),
		 strContractEndMonth NVARCHAR(200),
		 intInventoryReceiptItemId INT
		,strTicketNumber  NVARCHAR(200)
		,dtmTicketDateTime DATETIME
		,strCustomerReference NVARCHAR(200)
		,strDistributionOption NVARCHAR(200)
		,dblUnitCost NUMERIC(24, 10)
		,dblQtyReceived NUMERIC(24, 10)
		,dblTotal DECIMAL(24,10)
		,intSeqNo int
		,intFromCommodityUnitMeasureId int
		,intToCommodityUnitMeasureId int
		,intCommodityId int
		,strAccountNumber NVARCHAR(200)
		,strTranType NVARCHAR(20)
		,dblNoOfLot NUMERIC(24, 10)
		,dblDelta NUMERIC(24, 10)
		,intBrokerageAccountId int
		,strInstrumentType NVARCHAR(200)
		 ,intNoOfContract NUMERIC(24, 10),
		 dblContractSize NUMERIC(24, 10),		 
		 strCurrency NVARCHAR(200),
		 intCompanyLocationId int,
		 intInvoiceId  int,
		 strInvoiceNumber NVARCHAR(200),
		 intBillId  int,
		 strBillId NVARCHAR(200),
		 intInventoryReceiptId int,
		 strReceiptNumber NVARCHAR(200),
		 intTicketId int,
		 strShipmentNumber NVARCHAR(200),
		 intInventoryShipmentId int ,
		 intItemId int,
		 intContractTypeId int
		  
)

DECLARE @Final AS TABLE (
		 intRow INT IDENTITY(1,1),
		 intContractHeaderId int,
		 strContractNumber NVARCHAR(200),
		 intFutOptTransactionHeaderId int,
		 strInternalTradeNo NVARCHAR(200),
		 strCommodityCode NVARCHAR(200),   
		 strType  NVARCHAR(200), 
		 strSubType NVARCHAR(200), 
		 strContractType NVARCHAR(200),
		 strLocationName NVARCHAR(200),
		 strContractEndMonth NVARCHAR(200),
		 intInventoryReceiptItemId INT
		,strTicketNumber  NVARCHAR(200)
		,dtmTicketDateTime DATETIME
		,strCustomerReference NVARCHAR(200)
		,strDistributionOption NVARCHAR(200)
		,dblUnitCost NUMERIC(24, 10)
		,dblQtyReceived NUMERIC(24, 10)
		,dblTotal DECIMAL(24,10)
		,strUnitMeasure NVARCHAR(200)
		,intSeqNo int
		,intFromCommodityUnitMeasureId int
		,intToCommodityUnitMeasureId int
		,intCommodityId int
		,strAccountNumber NVARCHAR(200)
		,strTranType NVARCHAR(20)
		,dblNoOfLot NUMERIC(24, 10)
		,dblDelta NUMERIC(24, 10)
		,intBrokerageAccountId int
		,strInstrumentType NVARCHAR(200)
		 ,intNoOfContract NUMERIC(24, 10),
		 dblContractSize NUMERIC(24, 10),
		 strCurrency NVARCHAR(200),
		 intInvoiceId  int,
		 strInvoiceNumber NVARCHAR(200),
		 intBillId  int,
		 strBillId NVARCHAR(200),
		 intInventoryReceiptId int,
		 strReceiptNumber NVARCHAR(200),
		  intTicketId int,
		 strShipmentNumber NVARCHAR(200),
		 intInventoryShipmentId int ,
		 intItemId int,
		 intContractTypeId int
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

INSERT INTO @tblGetOpenContractDetail(
	intRowNum,
	strCommodityCode,
	intCommodityId,
	intContractHeaderId,
	strContractNumber,
	strLocationName,
	dtmEndDate,
	dblBalance,
	intUnitMeasureId,
	intPricingTypeId,
	intContractTypeId,
	intCompanyLocationId,
	strContractType,
	strPricingType,
	intCommodityUnitMeasureId,
	intContractDetailId,
	intContractStatusId,
	intEntityId,
	intCurrencyId,
	strType,
	intItemId,
	strItemNo,
	strEntityName,
	strCustomerContract,
	intFutureMarketId,
	intFutureMonthId,
	strCurrency
)
SELECT  
	ROW_NUMBER() OVER (PARTITION BY intContractDetailId ORDER BY dtmContractDate DESC) intRowNum,
	strCommodityCode,
	intCommodityId,
	intContractHeaderId,
	strContractNumber,
	strLocationName,
	dtmEndDate,
	dblBalance,
	intUnitMeasureId,
	intPricingTypeId,
	intContractTypeId,
	intCompanyLocationId,
	strContractType,
	strPricingType,
	intCommodityUnitMeasureId,
	intContractDetailId,
	intContractStatusId,
	intEntityId,
	intCurrencyId,
	strType,
	intItemId,
	strItemNo,
	strEntityName,
	strCustomerContract,
	NULL intFutureMarketId,
	NULL intFutureMonthId, 
	NULL strCurrency 
FROM 
vyuRKContractDetail CD
WHERE convert(DATETIME, CONVERT(VARCHAR(10), dtmContractDate, 110), 110) <= @dtmToDate 

DECLARE @tblGetOpenFutureByDate TABLE (
		intRowNum int,
		dtmTransactionDate datetime,
		intFutOptTransactionId int, 
		intOpenContract  int,
		strCommodityCode NVARCHAR(200) COLLATE Latin1_General_CI_AS,
		strInternalTradeNo NVARCHAR(200) COLLATE Latin1_General_CI_AS,
		strLocationName NVARCHAR(200) COLLATE Latin1_General_CI_AS,
		dblContractSize numeric(24,10),
		strFutureMarket NVARCHAR(200) COLLATE Latin1_General_CI_AS,
		strFutureMonth NVARCHAR(200) COLLATE Latin1_General_CI_AS,
		strOptionMonth NVARCHAR(200) COLLATE Latin1_General_CI_AS,
		dblStrike numeric(24,10),
		strOptionType NVARCHAR(200) COLLATE Latin1_General_CI_AS,
		strInstrumentType NVARCHAR(200) COLLATE Latin1_General_CI_AS,
		strBrokerAccount NVARCHAR(200) COLLATE Latin1_General_CI_AS,
		strBroker NVARCHAR(200) COLLATE Latin1_General_CI_AS,
		strNewBuySell NVARCHAR(200) COLLATE Latin1_General_CI_AS,
		intFutOptTransactionHeaderId int 
		)
		
INSERT INTO @tblGetOpenFutureByDate
select * from (
SELECT ROW_NUMBER() OVER (
				PARTITION BY intFutOptTransactionId ORDER BY dtmTransactionDate DESC
				) intRowNum,*  FROM(
	--Futures Buy
	SELECT 
		FOT.dtmTransactionDate,
		intFutOptTransactionId, 
		intOpenContract,
		FOT.strCommodityCode,
		strInternalTradeNo,
		strLocationName,
		FOT.dblContractSize,
		FOT.strFutMarketName,
		FOT.strFutureMonthYear AS strFutureMonth,
		FOT.strOptionMonthYear AS strOptionMonth,
		dblStrike,
		strOptionType,
		FOT.strInstrumentType,
		FOT.strBrokerageAccount AS strBrokerAccount,
		FOT.strName AS strBroker,
		strBuySell,
		FOTH.intFutOptTransactionHeaderId 
		FROM tblRKFutOptTransactionHeader FOTH
		INNER JOIN vyuRKFutOptTransaction FOT ON FOTH.intFutOptTransactionHeaderId = FOT.intFutOptTransactionHeaderId
		WHERE FOT.strBuySell = 'Buy' AND FOT.strInstrumentType = 'Futures'
		AND convert(DATETIME, CONVERT(VARCHAR(10), FOT.dtmTransactionDate, 110), 110) <= convert(DATETIME, @dtmToDate) 

	UNION
	--Futures Sell
	SELECT 
		FOT.dtmTransactionDate,
		intFutOptTransactionId, 
		intOpenContract,
		FOT.strCommodityCode,
		strInternalTradeNo,
		strLocationName,
		FOT.dblContractSize,
		FOT.strFutMarketName,
		FOT.strFutureMonthYear AS strFutureMonth,
		FOT.strOptionMonthYear AS strOptionMonth,
		dblStrike,
		strOptionType,
		FOT.strInstrumentType,
		FOT.strBrokerageAccount AS strBrokerAccount,
		FOT.strName AS strBroker,
		strBuySell,
		FOTH.intFutOptTransactionHeaderId 
		FROM tblRKFutOptTransactionHeader FOTH
		INNER JOIN vyuRKFutOptTransaction FOT ON FOTH.intFutOptTransactionHeaderId = FOT.intFutOptTransactionHeaderId
		WHERE FOT.strBuySell = 'Sell' AND FOT.strInstrumentType = 'Futures'
		AND convert(DATETIME, CONVERT(VARCHAR(10), FOT.dtmTransactionDate, 110), 110) <= convert(DATETIME, @dtmToDate) 

	UNION
	--Options Buy
	SELECT 
		FOT.dtmTransactionDate,
		intFutOptTransactionId, 
		intOpenContract,
		FOT.strCommodityCode,
		strInternalTradeNo,
		strLocationName,
		FOT.dblContractSize,
		FOT.strFutMarketName,
		FOT.strFutureMonthYear AS strFutureMonth,
		FOT.strOptionMonthYear AS strOptionMonth,
		dblStrike,
		strOptionType,
		FOT.strInstrumentType,
		FOT.strBrokerageAccount AS strBrokerAccount,
		FOT.strName AS strBroker,
		strBuySell,
		FOTH.intFutOptTransactionHeaderId 
		FROM tblRKFutOptTransactionHeader FOTH
		INNER JOIN vyuRKFutOptTransaction FOT ON FOTH.intFutOptTransactionHeaderId = FOT.intFutOptTransactionHeaderId
		WHERE FOT.strBuySell = 'BUY' AND FOT.strInstrumentType = 'Options'
		AND convert(DATETIME, CONVERT(VARCHAR(10), FOT.dtmTransactionDate, 110), 110) <= convert(DATETIME, @dtmToDate) 

	UNION
	--Options Sell
	SELECT 
		FOT.dtmTransactionDate,
		intFutOptTransactionId, 
		intOpenContract,
		FOT.strCommodityCode,
		strInternalTradeNo,
		strLocationName,
		FOT.dblContractSize,
		FOT.strFutMarketName,
		FOT.strFutureMonthYear AS strFutureMonth,
		FOT.strOptionMonthYear AS strOptionMonth,
		dblStrike,
		strOptionType,
		FOT.strInstrumentType,
		FOT.strBrokerageAccount AS strBrokerAccount,
		FOT.strName AS strBroker,
		strBuySell,
		FOTH.intFutOptTransactionHeaderId 
		FROM tblRKFutOptTransactionHeader FOTH
		INNER JOIN vyuRKFutOptTransaction FOT ON FOTH.intFutOptTransactionHeaderId = FOT.intFutOptTransactionHeaderId
		WHERE FOT.strBuySell = 'Sell' AND FOT.strInstrumentType = 'Options'
		AND convert(DATETIME, CONVERT(VARCHAR(10), FOT.dtmTransactionDate, 110), 110) <= convert(DATETIME, @dtmToDate) 

)t2 )t3 WHERE t3.intRowNum = 1


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
join tblSCTicket t on t.intTicketId=gh.intTicketId
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
		)

INSERT INTO @invQty
SELECT 	
	s.dblQuantity dblTotal,
	t.strTicketNumber Ticket,
	s.strLocationName,
	s.strItemNo,
	i.intCommodityId intCommodityId,
	intCommodityUnitMeasureId intFromCommodityUnitMeasureId,
	s.intLocationId intLocationId,
	strTransactionId,
	strTransactionType,
	i.intItemId 	
FROM vyuRKGetInventoryValuation s  		
	JOIN tblICItem i on i.intItemId=s.intItemId
	JOIN tblICItemUOM iuom on s.intItemId=iuom.intItemId and iuom.ysnStockUnit=1 and  isnull(ysnInTransit,0)=0 
	JOIN tblICCommodityUnitMeasure ium on ium.intCommodityId=i.intCommodityId AND iuom.intUnitMeasureId=ium.intUnitMeasureId  
	LEFT JOIN tblSCTicket t on s.strSourceNumber=t.strTicketNumber		   		  
WHERE i.intCommodityId in (select intCommodity from @Commodity) and iuom.ysnStockUnit=1 AND ISNULL(s.dblQuantity,0) <>0
			and isnull(t.strDistributionOption,'') <> 'DP' and isnull(strTicketStatus,'') <> 'V'
				and convert(DATETIME, CONVERT(VARCHAR(10), s.dtmCreated, 110), 110)<=convert(datetime,@dtmToDate)
							and s.intLocationId  IN (
				SELECT intCompanyLocationId FROM tblSMCompanyLocation
				WHERE isnull(ysnLicensed, 0) = CASE WHEN @strPositionIncludes = 'Licensed Storage' THEN 1 
								WHEN @strPositionIncludes = 'Non-licensed Storage' THEN 0 
								ELSE isnull(ysnLicensed, 0) END
				)

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
		intContractTypeId int,
		intLocationId int,
		intEntityId int
		)

INSERT INTO @tempCollateral
SELECT *  FROM (
		SELECT  
			ROW_NUMBER() OVER (PARTITION BY intCollateralId ORDER BY dtmOpenDate DESC) intRowNum,		
			c.intCollateralId,
			cl.strLocationName,
			ch.strItemNo,
			ch.strEntityName,
			c.intReceiptNo,
			ch.intContractHeaderId,
			strContractNumber, 
			c.dtmOpenDate,
			isnull(c.dblOriginalQuantity,0) dblOriginalQuantity,
			isnull(c.dblRemainingQuantity,0) dblRemainingQuantity,
			c.intCommodityId as intCommodityId,
			c.intUnitMeasureId,
			c.intLocationId intCompanyLocationId,
			case when c.strType='Purchase' then 1 else 2 end intContractTypeId,
			c.intLocationId,
			intEntityId
		FROM tblRKCollateral c
			JOIN tblICCommodity co on co.intCommodityId=c.intCommodityId
			JOIN tblICCommodityUnitMeasure ium on ium.intCommodityId=c.intCommodityId AND c.intUnitMeasureId=ium.intUnitMeasureId 
			JOIN tblSMCompanyLocation cl on cl.intCompanyLocationId=c.intLocationId
			LEFT JOIN @tblGetOpenContractDetail ch on c.intContractHeaderId=ch.intContractHeaderId and ch.intContractStatusId <> 3
		WHERE c.intCommodityId in (select intCommodity from @Commodity)
								 AND convert(DATETIME, CONVERT(VARCHAR(10), dtmOpenDate, 110), 110) <= convert(datetime,@dtmToDate) 
									AND  c.intLocationId   IN (SELECT intCompanyLocationId FROM tblSMCompanyLocation
									WHERE isnull(ysnLicensed, 0) = CASE WHEN @strPositionIncludes = 'Licensed Storage' THEN 1 
									WHEN @strPositionIncludes = 'Non-licensed Storage' THEN 0 
									ELSE isnull(ysnLicensed, 0) END
									)
) a where   a.intRowNum =1



DECLARE @mRowNumber INT
DECLARE @intCommodityId1 INT
DECLARE @strDescription NVARCHAR(200)
declare @intOneCommodityId int
declare @intCommodityUnitMeasureId int
DECLARE @intUnitMeasureId int
DECLARE @ysnExchangeTraded bit
DECLARE @strUnitMeasure NVARCHAR(200)
SELECT @mRowNumber = MIN(intCommodityIdentity) FROM @Commodity
WHILE @mRowNumber >0
BEGIN
	SELECT @intCommodityId = intCommodity FROM @Commodity WHERE intCommodityIdentity = @mRowNumber
	SELECT @strDescription = strCommodityCode, @ysnExchangeTraded = ysnExchangeTraded FROM tblICCommodity	WHERE intCommodityId = @intCommodityId
	SELECT @intCommodityUnitMeasureId=intCommodityUnitMeasureId from tblICCommodityUnitMeasure where intCommodityId=@intCommodityId AND ysnDefault=1
IF  @intCommodityId >0 
BEGIN
	
if isnull(@intVendorId,0) = 0
BEGIN
	INSERT INTO @tempFinal (strCommodityCode,intContractHeaderId,strContractNumber,strType,strContractType,strLocationName,strContractEndMonth,dblTotal,intFromCommodityUnitMeasureId,intCommodityId,intCompanyLocationId,strCurrency,intContractTypeId)
	SELECT * FROM 
	(SELECT cd.strCommodityCode,cd.intContractHeaderId,strContractNumber,cd.strType [strType],'Physical Contract' strContractType,strLocationName,
		RIGHT(CONVERT(VARCHAR(11),dtmEndDate,106),8) strContractEndMonth,
		dbo.fnCTConvertQuantityToTargetCommodityUOM(cd.intCommodityUnitMeasureId,@intCommodityUnitMeasureId,isnull((cd.dblBalance),0)) AS dblTotal
	   ,cd.intUnitMeasureId,@intCommodityId as intCommodityId,cd.intCompanyLocationId,strCurrency,intContractTypeId 
	FROM @tblGetOpenContractDetail cd
	WHERE cd.intContractTypeId in(1,2) and cd.intCommodityId =@intCommodityId
	AND cd.intCompanyLocationId= CASE WHEN ISNULL(@intLocationId,0)=0 THEN cd.intCompanyLocationId ELSE @intLocationId END)t
		WHERE intCompanyLocationId  IN (SELECT intCompanyLocationId FROM tblSMCompanyLocation
				WHERE isnull(ysnLicensed, 0) = CASE WHEN @strPositionIncludes = 'Licensed Storage' THEN 1 
								WHEN @strPositionIncludes = 'Non-licensed Storage' THEN 0 
								ELSE isnull(ysnLicensed, 0) END
				)
				
	-- Hedge
	INSERT INTO @tempFinal (strCommodityCode,strInternalTradeNo,intFutOptTransactionHeaderId,strType,strContractType,strLocationName,strContractEndMonth,dblTotal,
							intFromCommodityUnitMeasureId,intCommodityId,strAccountNumber,strTranType,intBrokerageAccountId,strInstrumentType,dblNoOfLot,strCurrency)		
	
	SELECT strCommodityCode,strInternalTradeNo,intFutOptTransactionHeaderId,'Net Hedge','Future' strContractType,strLocationName, strFutureMonth,
	HedgedQty,@intCommodityUnitMeasureId intFromCommodityUnitMeasureId,@intCommodityId intCommodityId,strAccountNumber,strTranType,intBrokerageAccountId,
	strInstrumentType,dblNoOfLot,strCurrency
	FROM (
		SELECT distinct t.strCommodityCode,strInternalTradeNo,t.intFutOptTransactionHeaderId,th.intCommodityId,dtmFutureMonthsDate,
		dbo.fnCTConvertQuantityToTargetCommodityUOM(cuc1.intCommodityUnitMeasureId,@intCommodityUnitMeasureId,  
		intOpenContract	 * 	 t.dblContractSize) AS HedgedQty,
		l.strLocationName,left(t.strFutureMonth,4) +  '20'+convert(nvarchar(2),intYear) strFutureMonth,m.intUnitMeasureId,
		t.strBroker + '-' + t.strBrokerAccount strAccountNumber,strNewBuySell as strTranType,ba.intBrokerageAccountId,
		'Future' as strInstrumentType,
		intOpenContract dblNoOfLot ,cu.strCurrency
		FROM @tblGetOpenFutureByDate t
		JOIN tblICCommodity th on th.strCommodityCode=t.strCommodityCode
		join tblSMCompanyLocation l on l.strLocationName=t.strLocationName
		join tblRKFutureMarket m on m.strFutMarketName=t.strFutureMarket
		join tblSMCurrency cu on cu.intCurrencyID=m.intCurrencyId
		LEFT join tblRKBrokerageAccount ba on ba.strAccountNumber=t.strBrokerAccount
			INNER JOIN tblEMEntity e ON e.strName = t.strBroker AND t.strInstrumentType= 'Futures'
		JOIN tblICCommodityUnitMeasure cuc1 on cuc1.intCommodityId=@intCommodityId and m.intUnitMeasureId=cuc1.intUnitMeasureId	
		INNER JOIN tblRKFuturesMonth fm ON fm.strFutureMonth = t.strFutureMonth AND fm.intFutureMarketId = m.intFutureMarketId AND fm.ysnExpired = 0
		WHERE th.intCommodityId = @intCommodityId
			AND l.intCompanyLocationId= CASE WHEN ISNULL(@intLocationId,0)=0 then l.intCompanyLocationId else @intLocationId end	
			and intCompanyLocationId   IN (SELECT intCompanyLocationId FROM tblSMCompanyLocation
									WHERE isnull(ysnLicensed, 0) = CASE WHEN @strPositionIncludes = 'Licensed Storage' THEN 1 
									WHEN @strPositionIncludes = 'Non-licensed Storage' THEN 0 
									ELSE isnull(ysnLicensed, 0) END
									AND @ysnExchangeTraded = 1
									)		
		) t	
		
--	-- Option NetHEdge
	INSERT INTO @tempFinal (strCommodityCode,strInternalTradeNo,intFutOptTransactionHeaderId,strType,strContractType,strLocationName,strContractEndMonth,dblTotal,
							intFromCommodityUnitMeasureId,intCommodityId,strAccountNumber,strTranType,dblNoOfLot,dblDelta,intBrokerageAccountId,strInstrumentType,strCurrency)	
		SELECT DISTINCT t.strCommodityCode,t.strInternalTradeNo,intFutOptTransactionHeaderId,'Net Hedge','Option',t.strLocationName,
				 LEFT(t.strFutureMonth,4) +  '20'+convert(nvarchar(2),fm.intYear) strFutureMonth, 				
				intOpenContract * isnull((
						SELECT TOP 1 dblDelta
						FROM tblRKFuturesSettlementPrice sp
						INNER JOIN tblRKOptSettlementPriceMarketMap mm ON sp.intFutureSettlementPriceId = mm.intFutureSettlementPriceId
						WHERE intFutureMarketId = m.intFutureMarketId AND mm.intOptionMonthId = om.intOptionMonthId AND mm.intTypeId = CASE WHEN t.strOptionType = 'Put' THEN 1 ELSE 2 END
						AND t.dblStrike = mm.dblStrike
						ORDER BY dtmPriceDate DESC
				),0)*m.dblContractSize AS dblNoOfContract, m.intUnitMeasureId,th.intCommodityId,				
		e.strName + '-' + strAccountNumber AS strAccountNumber, 		
		strNewBuySell AS TranType, 
		intOpenContract AS dblNoOfLot, 
		isnull((SELECT TOP 1 dblDelta
		FROM tblRKFuturesSettlementPrice sp
		INNER JOIN tblRKOptSettlementPriceMarketMap mm ON sp.intFutureSettlementPriceId = mm.intFutureSettlementPriceId
		WHERE intFutureMarketId = m.intFutureMarketId AND mm.intOptionMonthId = om.intOptionMonthId AND mm.intTypeId = CASE WHEN t.strOptionType = 'Put' THEN 1 ELSE 2 END
		AND t.dblStrike = mm.dblStrike
		ORDER BY dtmPriceDate DESC
		),0) AS dblDelta,
		ba.intBrokerageAccountId, 'Option' as strInstrumentType,strCurrency
	FROM @tblGetOpenFutureByDate t
	join tblICCommodity th on th.strCommodityCode=t.strCommodityCode
	join tblSMCompanyLocation l on l.strLocationName=t.strLocationName 
	join tblRKFutureMarket m on m.strFutMarketName=t.strFutureMarket
		join tblSMCurrency cu on cu.intCurrencyID=m.intCurrencyId
	join tblRKOptionsMonth om on om.strOptionMonth=t.strOptionMonth
	INNER JOIN tblRKBrokerageAccount ba ON t.strBrokerAccount = ba.strAccountNumber
	INNER JOIN tblEMEntity e ON e.strName = t.strBroker AND t.strInstrumentType= 'Options'
	INNER JOIN tblRKFuturesMonth fm ON fm.strFutureMonth = t.strFutureMonth AND fm.intFutureMarketId = m.intFutureMarketId AND fm.ysnExpired = 0
	WHERE th.intCommodityId = @intCommodityId  
	AND intCompanyLocationId = case when isnull(@intLocationId,0)=0 then intCompanyLocationId else @intLocationId end 
	AND t.intFutOptTransactionId NOT IN (SELECT intFutOptTransactionId FROM tblRKOptionsPnSExercisedAssigned) 
	AND t.intFutOptTransactionId NOT IN (SELECT intFutOptTransactionId FROM tblRKOptionsPnSExpired)
	and intCompanyLocationId   IN (SELECT intCompanyLocationId FROM tblSMCompanyLocation
									WHERE isnull(ysnLicensed, 0) = CASE WHEN @strPositionIncludes = 'Licensed Storage' THEN 1 
									WHEN @strPositionIncludes = 'Non-licensed Storage' THEN 0 
									ELSE isnull(ysnLicensed, 0) END
									AND @ysnExchangeTraded = 1
									)
-- Net Hedge option end

	INSERT INTO @tempFinal(strCommodityCode,strType,strContractType,dblTotal,intContractHeaderId,strContractNumber,intFromCommodityUnitMeasureId,intCommodityId,strLocationName)
	SELECT DISTINCT @strCommodityCode,'Price Risk' [strType],'Inventory' strContractType,sum(dblTotal) dblTotal,intItemId,strItemNo,
					intFromCommodityUnitMeasureId,intCommodityId,strLocationName  
			FROM @invQty where intCommodityId=@intCommodityId  AND @ysnExchangeTraded = 1
				AND intLocationId= CASE WHEN ISNULL(@intLocationId,0)=0 THEN intLocationId ELSE @intLocationId END
			GROUP BY intItemId,strItemNo,intFromCommodityUnitMeasureId,strLocationName,intCommodityId
		
	--Net Hedge Derivative Entry (Futures and Options)
    INSERT INTO @tempFinal(strCommodityCode,strType,strContractType,dblTotal,intContractHeaderId,strContractNumber,intFromCommodityUnitMeasureId,intCommodityId,strLocationName)
    SELECT strCommodityCode,'Price Risk',strContractType,dblTotal,intContractHeaderId,strContractNumber,intFromCommodityUnitMeasureId,intCommodityId,strLocationName 
    FROM @tempFinal
    WHERE intCommodityId=@intCommodityId 
        AND strType = 'Net Hedge' AND @ysnExchangeTraded = 1
				 
	INSERT INTO @tempFinal(strCommodityCode,strType,strContractType,dblTotal,intInventoryReceiptId,strReceiptNumber,intFromCommodityUnitMeasureId,intCommodityId,strLocationName,strCurrency)
	SELECT @strCommodityCode,'Price Risk' [strType],'PurBasisDelivary' strContractType,-sum(dblTotal),intInventoryReceiptId,strReceiptNumber,intCommodityUnitMeasureId,intCommodityId,strLocationName ,strCurrency
	FROM (
	SELECT dbo.fnCTConvertQuantityToTargetCommodityUOM(ium.intCommodityUnitMeasureId,@intCommodityUnitMeasureId,isnull(v.dblQuantity ,0)) AS dblTotal,
			r.intInventoryReceiptId,strReceiptNumber, ium.intCommodityUnitMeasureId, cd.intCommodityId,cd.strLocationName,cd.intCompanyLocationId,strCurrency
	FROM vyuRKGetInventoryValuation v
	join tblICInventoryReceipt r on r.strReceiptNumber=v.strTransactionId
	INNER JOIN tblICInventoryReceiptItem ri ON r.intInventoryReceiptId = ri.intInventoryReceiptId AND r.strReceiptType = 'Purchase Contract'
	INNER JOIN tblSCTicket st ON st.intTicketId = ri.intSourceId  AND strDistributionOption IN ('CNT') and  isnull(ysnInTransit,0)=0 
	INNER JOIN @tblGetOpenContractDetail cd ON cd.intContractDetailId = ri.intLineNo AND cd.intPricingTypeId = 2  and cd.intContractStatusId <> 3
	JOIN tblICCommodityUnitMeasure ium on ium.intCommodityId=cd.intCommodityId AND cd.intUnitMeasureId=ium.intUnitMeasureId 
	INNER JOIN tblSMCompanyLocation  cl on cl.intCompanyLocationId=st.intProcessingLocationId 
	WHERE v.strTransactionType ='Inventory Receipt' and cd.intCommodityId = @intCommodityId  and isnull(strTicketStatus,'') <> 'V'
	AND st.intProcessingLocationId  = case when isnull(@intLocationId,0)=0 then st.intProcessingLocationId else @intLocationId end
	and convert(DATETIME, CONVERT(VARCHAR(10), v.dtmCreated, 110), 110)<=convert(datetime,@dtmToDate))t 
	WHERE  intCompanyLocationId  IN (
		SELECT intCompanyLocationId FROM tblSMCompanyLocation
		WHERE isnull(ysnLicensed, 0) = CASE WHEN @strPositionIncludes = 'Licensed Storage' THEN 1 
						WHEN @strPositionIncludes = 'Non-licensed Storage' THEN 0 
						ELSE isnull(ysnLicensed, 0) END
						AND @ysnExchangeTraded = 1)
	GROUP BY intInventoryReceiptId,strReceiptNumber,intCommodityUnitMeasureId,intCommodityId,strLocationName,strCurrency						
	
	INSERT INTO @tempFinal(strCommodityCode,strType,strContractType,dblTotal,intContractHeaderId,strContractNumber,intFromCommodityUnitMeasureId,intCommodityId,strLocationName,strCurrency)
	SELECT strCommodityCode,'Price Risk' [strType],'Open Contract' strContractType,
	CASE WHEN intContractTypeId =1 then sum(dblTotal) else -sum(dblTotal) end dblTotal,intContractHeaderId,strContractNumber,intFromCommodityUnitMeasureId,intCommodityId,strLocationName ,strCurrency
		FROM (SELECT strCommodityCode,			
				dbo.fnCTConvertQuantityToTargetCommodityUOM(cd.intCommodityUnitMeasureId,@intCommodityUnitMeasureId,isnull(cd.dblBalance,0)) dblTotal,
				intContractHeaderId,strContractNumber,cd.intCommodityUnitMeasureId intFromCommodityUnitMeasureId,intCommodityId,strLocationName,intCompanyLocationId,intContractTypeId,strCurrency
				FROM @tblGetOpenContractDetail cd
				WHERE intContractTypeId in(1,2) and intPricingTypeId IN (1,3) AND cd.intCommodityId  = @intCommodityId 
				AND cd.intCompanyLocationId= case when isnull(@intLocationId,0)=0 then cd.intCompanyLocationId else @intLocationId end 
				)t	
				WHERE  intCompanyLocationId  IN (SELECT intCompanyLocationId FROM tblSMCompanyLocation
						WHERE isnull(ysnLicensed, 0) = CASE WHEN @strPositionIncludes = 'Licensed Storage' THEN 1 
						WHEN @strPositionIncludes = 'Non-licensed Storage' THEN 0 
						ELSE isnull(ysnLicensed, 0) END
						AND @ysnExchangeTraded = 1)
				 group by strCommodityCode,intContractHeaderId,strContractNumber,intFromCommodityUnitMeasureId,intCommodityId,strLocationName,intContractTypeId,strCurrency	

	INSERT INTO @tempFinal(strCommodityCode,strType,strContractType,dblTotal,intFromCommodityUnitMeasureId,intCommodityId,strLocationName)
	SELECT @strCommodityCode,'Price Risk' [strType],'Collateral' strContractType,sum(dblRemainingQuantity) dblTotal,intFromCommodityUnitMeasureId,
	intCommodityId,strLocationName  from(
			SELECT 
				CASE WHEN isnull(intContractTypeId,1) = 2 then -dblRemainingQuantity else dblRemainingQuantity   end dblRemainingQuantity,
					intContractHeaderId,strContractNumber,intUnitMeasureId intFromCommodityUnitMeasureId,intCommodityId,strLocationName,intCollateralId			
					FROM @tempCollateral c1									
					WHERE c1.intLocationId= case when isnull(@intLocationId,0)=0 then c1.intLocationId else @intLocationId end)t 
	GROUP BY intCommodityId,intFromCommodityUnitMeasureId,intCommodityId,strLocationName	

	INSERT INTO @tempFinal(strCommodityCode,strType,strContractType,dblTotal,strShipmentNumber,intInventoryShipmentId,intFromCommodityUnitMeasureId,intCommodityId,strLocationName,strCurrency)
	SELECT distinct 
		strCommodityCode
		,'Price Risk' as strType
		,'Sls Basis Deliveries' as strContractType
		,isnull(ri.dblQuantity, 0) AS dblTotal
		,r.strShipmentNumber
		,r.intInventoryShipmentId
		,ium.intCommodityUnitMeasureId as intFromCommodityUnitMeasureId
		,cd.intCommodityId
		,cl.strLocationName
		,strCurrency
	FROM vyuRKGetInventoryValuation v 
	JOIN tblICInventoryShipment r on r.strShipmentNumber=v.strTransactionId
	INNER JOIN tblICInventoryShipmentItem ri ON r.intInventoryShipmentId = ri.intInventoryShipmentId
	INNER JOIN @tblGetOpenContractDetail cd ON cd.intContractDetailId = ri.intLineNo AND cd.intPricingTypeId = 2	and cd.intContractStatusId <> 3  AND cd.intContractTypeId = 2
	JOIN tblICCommodityUnitMeasure ium on ium.intCommodityId=cd.intCommodityId AND cd.intUnitMeasureId=ium.intUnitMeasureId 
	INNER JOIN tblSMCompanyLocation  cl on cl.intCompanyLocationId=cd.intCompanyLocationId
	LEFT JOIN tblARInvoiceDetail invD ON ri.intInventoryShipmentItemId = invD.intInventoryShipmentItemId
	INNER JOIN tblARInvoice inv ON invD.intInvoiceId = inv.intInvoiceId
	WHERE cd.intCommodityId = @intCommodityId AND v.strTransactionType ='Inventory Shipment'
	AND cl.intCompanyLocationId  = case when isnull(@intLocationId,0)=0 then cl.intCompanyLocationId else @intLocationId end
	and convert(DATETIME, CONVERT(VARCHAR(10), v.dtmCreated, 110), 110)<=convert(datetime,@dtmToDate)
	and ISNULL(inv.ysnPosted,0) = 0
	AND @ysnExchangeTraded = 1
	and cl.intCompanyLocationId IN (
		SELECT intCompanyLocationId FROM tblSMCompanyLocation
		WHERE isnull(ysnLicensed, 0) = CASE WHEN @strPositionIncludes = 'Licensed Storage' THEN 1 
						WHEN @strPositionIncludes = 'Non-licensed Storage' THEN 0 
						ELSE isnull(ysnLicensed, 0) END
		)  
			
				
	If ((SELECT TOP 1 ysnIncludeDPPurchasesInCompanyTitled from tblRKCompanyPreference)=1)
	BEGIN
	INSERT INTO @tempFinal(strCommodityCode,strType,strContractType,dblTotal,intTicketId,strTicketNumber,intFromCommodityUnitMeasureId,intCommodityId,strLocationName)
	SELECT @strCommodityCode,'Price Risk' [strType],'DP' strContractType,sum(dblTotal) dblTotal,intTicketId,strTicketNumber,intFromCommodityUnitMeasureId,intCommodityId,strLocationName  from(
			SELECT intTicketId,strTicketNumber,
					dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId,@intCommodityUnitMeasureId,(isnull(Balance,0))) dblTotal
					,ch.intCompanyLocationId,intCommodityUnitMeasureId intFromCommodityUnitMeasureId,intCommodityId,strLocationName
					FROM @tblGetStorageDetailByDate ch
					WHERE ch.intCommodityId  = @intCommodityId	AND ysnDPOwnedType = 1
						AND ch.intCompanyLocationId= case when isnull(@intLocationId,0)=0 then ch.intCompanyLocationId else @intLocationId end
					)t 	WHERE intCompanyLocationId  IN (
								SELECT intCompanyLocationId FROM tblSMCompanyLocation
								WHERE isnull(ysnLicensed, 0) = CASE WHEN @strPositionIncludes = 'Licensed Storage' THEN 1 
								WHEN @strPositionIncludes = 'Non-licensed Storage' THEN 0 
								ELSE isnull(ysnLicensed, 0) END
								AND @ysnExchangeTraded = 1
				) group by intTicketId,strTicketNumber,intFromCommodityUnitMeasureId,intCommodityId,strLocationName
	
	END
	If ((SELECT TOP 1 ysnIncludeOffsiteInventoryInCompanyTitled from tblRKCompanyPreference)=1)
	BEGIN
	INSERT INTO @tempFinal(strCommodityCode,strType,strContractType,dblTotal,intTicketId,strTicketNumber,intFromCommodityUnitMeasureId,intCommodityId,strLocationName)
	SELECT @strCommodityCode,'Price Risk' [strType],'OffSite' strContractType,sum(dblTotal) dblTotal,intTicketId,strTicketNumber,intFromCommodityUnitMeasureId,intCommodityId,strLocationName  
		from(
				SELECT intTicketId,strTicketNumber,
					dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId,@intCommodityUnitMeasureId,(isnull(Balance,0))) dblTotal
					,CH.intCompanyLocationId,intCommodityUnitMeasureId intFromCommodityUnitMeasureId,intCommodityId,strLocationName
					FROM @tblGetStorageDetailByDate CH
					WHERE ysnCustomerStorage = 1
						AND strOwnedPhysicalStock = 'Company'
						AND CH.intCommodityId  = @intCommodityId
						AND CH.intCompanyLocationId= case when isnull(@intLocationId,0)=0 then CH.intCompanyLocationId else @intLocationId end	
				 )t WHERE intCompanyLocationId IN (
								SELECT intCompanyLocationId FROM tblSMCompanyLocation
								WHERE isnull(ysnLicensed, 0) = CASE WHEN @strPositionIncludes = 'Licensed Storage' THEN 1 
												WHEN @strPositionIncludes = 'Non-licensed Storage' THEN 0 ELSE isnull(ysnLicensed, 0) END 
												AND @ysnExchangeTraded = 1
				) group by intTicketId,strTicketNumber,intFromCommodityUnitMeasureId,intCommodityId,strLocationName

	END			


	
	INSERT INTO @tempFinal(strCommodityCode,strType,strContractType,dblTotal,intContractHeaderId,strContractNumber,strShipmentNumber,intInventoryShipmentId,intTicketId,strTicketNumber,intFromCommodityUnitMeasureId,intCommodityId,strLocationName)
	SELECT strCommodityCode,'Basis Risk' strType, strContractType,sum(dblTotal),intContractHeaderId,strContractNumber,strShipmentNumber,intInventoryShipmentId,intTicketId,strTicketNumber,intFromCommodityUnitMeasureId,intCommodityId,strLocationName 
	FROM @tempFinal where strType='Price Risk' and strContractType in('Inventory','Collateral','DP','Sls Basis Deliveries','OffSite') AND @ysnExchangeTraded = 1
		group by strCommodityCode,strContractType,intContractHeaderId,strContractNumber,strShipmentNumber,intInventoryShipmentId,intTicketId,strTicketNumber,intFromCommodityUnitMeasureId,intCommodityId,strLocationName
	
	INSERT INTO @tempFinal (strCommodityCode,intContractHeaderId,strContractNumber,strType,strContractType,strLocationName,strContractEndMonth,dblTotal,intFromCommodityUnitMeasureId,intCommodityId,intCompanyLocationId,strCurrency)
	select strCommodityCode,intContractHeaderId,strContractNumber,strType,strContractType,strLocationName,strContractEndMonth,sum(dblTotal),intFromCommodityUnitMeasureId,intCommodityId,intCompanyLocationId,strCurrency from (
	SELECT strCommodityCode,intContractHeaderId,strContractNumber,'Basis Risk' strType,strContractType,strLocationName,strContractEndMonth,
	case when intContractTypeId=1 then (dblTotal) else -(dblTotal) end dblTotal
	 ,intFromCommodityUnitMeasureId,intCommodityId,intCompanyLocationId,strCurrency,intContractTypeId from @tempFinal 
	WHERE strContractType in('Physical Contract'))t
		GROUP BY strType,strCommodityCode,intContractHeaderId,strContractNumber,strContractType,strLocationName,strContractEndMonth,intFromCommodityUnitMeasureId,intCommodityId,intCompanyLocationId,strCurrency,intContractTypeId
		
					
	INSERT INTO @tempFinal (strCommodityCode,strType,dblTotal,intContractHeaderId,strContractNumber,strLocationName,strTicketNumber,dtmTicketDateTime,
					strDistributionOption,dblUnitCost,dblQtyReceived,intCommodityId,strCurrency,intBillId,strBillId,strCustomerReference)
	SELECT @strDescription, 'Net Payable  ($)' [strType],dblTotal dblTotal,
		intContractHeaderId,strContractNumber,strLocationName,strTicketNumber,dtmTicketDateTime,strDistributionOption,dblUnitCost1,
		dblQtyReceived,intCommodityId,strCurrency,intBillId,strBillId,strCustomerReference
	 FROM(	
		SELECT DISTINCT B.intBillId,strBillId,		
				strLocationName
				,t.strTicketNumber
				,t.dtmTicketDateTime
				,strDistributionOption
				,dblCost dblUnitCost
				,sum(BD.dblQtyReceived) over (partition by B.intBillId) dblQtyReceived
				,sum(B.dblTotal) over (partition by B.intBillId) dblTotal
				,BD.dblCost
				,dblAmountDue
				,dblCost dblUnitCost1
				,c.intCommodityId, NULL as intContractHeaderId, NULL as strContractNumber,Cur.strCurrency,strName strCustomerReference
				FROM tblAPBill B
				JOIN tblAPBillDetail BD ON B.intBillId = BD.intBillId
				JOIN tblICItem I ON BD.intItemId = I.intItemId AND BD.intInventoryReceiptChargeId IS NULL
				JOIN tblICCommodity c on I.intCommodityId = c.intCommodityId
				JOIN tblSMCurrency Cur ON B.intCurrencyId = Cur.intCurrencyID
				JOIN tblSMCompanyLocation cl on cl.intCompanyLocationId = B.intShipToId
				LEFT JOIN tblSCTicket t on BD.intScaleTicketId = t.intTicketId
				LEFT JOIN tblEMEntity e on t.intEntityId=e.intEntityId 
				WHERE 
				c.intCommodityId = @intCommodityId  and isnull(strTicketStatus,'') <> 'V' and
				cl.intCompanyLocationId = CASE WHEN ISNULL(@intLocationId,0)=0 then cl.intCompanyLocationId else @intLocationId end
				and convert(DATETIME, CONVERT(VARCHAR(10), B.dtmDate, 110), 110) <= convert(datetime,@dtmToDate)
				and intCompanyLocationId   IN (SELECT intCompanyLocationId FROM tblSMCompanyLocation
									WHERE isnull(ysnLicensed, 0) = CASE WHEN @strPositionIncludes = 'Licensed Storage' THEN 1 
									WHEN @strPositionIncludes = 'Non-licensed Storage' THEN 0 
									ELSE isnull(ysnLicensed, 0) END
									) 			
			)t  where dblTotal <> 0
						
	INSERT INTO @tempFinal (strCommodityCode,strType,dblTotal,strLocationName,intContractHeaderId,strContractNumber,strTicketNumber,
		dtmTicketDateTime,strCustomerReference,strDistributionOption,dblUnitCost,dblQtyReceived,intCommodityId,strCurrency,intInvoiceId,strInvoiceNumber)
	SELECT 
		@strDescription
		,'Net Receivable  ($)' [strType] 
		,I.dblAmountDue
		,L.strLocationName
		,null intContractHeaderId
		,'' strContractNumber
		,T.strTicketNumber
		,I.dtmDate
		,E.strName
		,'' strDistributionOption
		,null dblUCost
		,SUM(ID.dblQtyShipped) dblQtyReceived
		,intCommodityId
		,Cur.strCurrency
		,I.intInvoiceId
		,I.strInvoiceNumber
	FROM tblARInvoice I
		INNER JOIN tblARInvoiceDetail ID ON I.intInvoiceId = ID.intInvoiceId AND intInventoryShipmentChargeId IS NULL
		INNER JOIN tblSMCompanyLocation L ON I.intCompanyLocationId = L.intCompanyLocationId
		INNER JOIN tblSCTicket T ON ID.intTicketId = T.intTicketId
		INNER JOIN tblEMEntity E ON I.intEntityCustomerId = E.intEntityId
		INNER JOIN tblSMCurrency Cur ON I.intCurrencyId = Cur.intCurrencyID
	WHERE I.ysnPosted = 1
		AND convert(DATETIME, CONVERT(VARCHAR(10), I.dtmDate, 110), 110) <= convert(datetime,@dtmToDate) 
		AND dblAmountDue <> 0
		AND intCommodityId = @intCommodityId 
		AND L.intCompanyLocationId= case when isnull(@intLocationId,0)=0 then L.intCompanyLocationId else @intLocationId end	
		AND L.intCompanyLocationId   IN (SELECT intCompanyLocationId FROM tblSMCompanyLocation
							WHERE isnull(ysnLicensed, 0) = CASE WHEN @strPositionIncludes = 'Licensed Storage' THEN 1 
							WHEN @strPositionIncludes = 'Non-licensed Storage' THEN 0 
							ELSE isnull(ysnLicensed, 0) END
							)
	GROUP BY
		I.dblAmountDue
		,L.strLocationName
		,T.strTicketNumber
		,I.dtmDate
		,E.strName
		,intCommodityId
		,Cur.strCurrency
		,I.intInvoiceId
		,I.strInvoiceNumber
			
	INSERT INTO @tempFinal (strCommodityCode,strType,dblTotal,intContractHeaderId,strContractNumber,strLocationName,strTicketNumber,dtmTicketDateTime,
					strCustomerReference,strDistributionOption,dblUnitCost,dblQtyReceived,intCommodityId,strContractType,intBillId,strBillId,strCurrency)

	select strCommodityCode,'NP Un-Paid Quantity' strType,dblTotal/case when isnull(dblUnitCost,0)=0 then 1 else dblUnitCost end,intContractHeaderId,strContractNumber,strLocationName,strTicketNumber,dtmTicketDateTime,
					strCustomerReference,strDistributionOption,dblUnitCost,dblQtyReceived,intCommodityId,strContractType,intBillId,strBillId,strCurrency
					 FROM @tempFinal where strType='Net Payable  ($)' and intCommodityId=@intCommodityId

	INSERT INTO @tempFinal (strCommodityCode,strType,dblTotal,intInventoryReceiptItemId,strLocationName,intContractHeaderId,strContractNumber,strTicketNumber,dtmTicketDateTime,
	strCustomerReference,strDistributionOption,dblUnitCost,dblQtyReceived,intCommodityId,strContractType,intInvoiceId,strInvoiceNumber,strCurrency	)
	select @strDescription,'NR Un-Paid Quantity' strType,dblQtyReceived,intInventoryReceiptItemId,strLocationName,intContractHeaderId,strContractNumber,strTicketNumber,dtmTicketDateTime,
	strCustomerReference,strDistributionOption,dblUnitCost,dblQtyReceived,intCommodityId,strContractType,intInvoiceId,strInvoiceNumber,strCurrency	
	 from @tempFinal where strType= 'Net Receivable  ($)' and intCommodityId=@intCommodityId 

	 INSERT INTO @tempFinal(strCommodityCode,strType,strContractType,dblTotal,intContractHeaderId,strContractNumber,strShipmentNumber,intInventoryShipmentId,intTicketId,strTicketNumber,intFromCommodityUnitMeasureId,intCommodityId,strLocationName,strCurrency)
	 SELECT strCommodityCode,'Avail for Spot Sale' strType,strContractType,dblTotal,intContractHeaderId,strContractNumber,strShipmentNumber,intInventoryShipmentId,intTicketId,strTicketNumber,intFromCommodityUnitMeasureId,intCommodityId,strLocationName,strCurrency 
	 from @tempFinal  where strType='Basis Risk' and intCommodityId=@intCommodityId AND @ysnExchangeTraded = 1

	 INSERT INTO @tempFinal (strCommodityCode,intContractHeaderId,strContractNumber,strType,strContractType,strLocationName,strContractEndMonth,dblTotal,intFromCommodityUnitMeasureId,intCommodityId,intCompanyLocationId,strCurrency,intContractTypeId)
	SELECT * FROM 
	(SELECT cd.strCommodityCode,cd.intContractHeaderId,strContractNumber,'Avail for Spot Sale' [strType], strContractType,strLocationName,
		RIGHT(CONVERT(VARCHAR(11),dtmEndDate,106),8) strContractEndMonth,
		dbo.fnCTConvertQuantityToTargetCommodityUOM(cd.intCommodityUnitMeasureId,@intCommodityUnitMeasureId,-(cd.dblBalance)) AS dblTotal
	   ,cd.intUnitMeasureId,@intCommodityId as intCommodityId,cd.intCompanyLocationId,strCurrency,intContractTypeId 
	FROM @tblGetOpenContractDetail cd
	WHERE  intContractTypeId=1 and strType in('Purchase Priced','Purchase Basis') and cd.intCommodityId=@intCommodityId
					 and cd.intCompanyLocationId = case when isnull(@intLocationId,0)=0 then cd.intCompanyLocationId else @intLocationId end)t
		WHERE intCompanyLocationId  IN (SELECT intCompanyLocationId FROM tblSMCompanyLocation
				WHERE isnull(ysnLicensed, 0) = CASE WHEN @strPositionIncludes = 'Licensed Storage' THEN 1 
								WHEN @strPositionIncludes = 'Non-licensed Storage' THEN 0 
								ELSE isnull(ysnLicensed, 0) END
								AND @ysnExchangeTraded = 1
				)	
		 
		 SELECT @intUnitMeasureId =null
	select @strUnitMeasure =null
	SELECT TOP 1 @intUnitMeasureId = intUnitMeasureId FROM tblRKCompanyPreference
	SELECT @strUnitMeasure=strUnitMeasure from tblICUnitMeasure where intUnitMeasureId=@intUnitMeasureId
	INSERT INTO @Final (intCommodityId,strCommodityCode ,intContractHeaderId,strContractNumber,intFutOptTransactionHeaderId,strInternalTradeNo,
		 strType,strContractType,strContractEndMonth, dblTotal,strUnitMeasure,intInventoryReceiptItemId,strLocationName,strTicketNumber,dtmTicketDateTime,
		strCustomerReference,strDistributionOption,dblUnitCost,dblQtyReceived,strAccountNumber,strTranType,dblNoOfLot,dblDelta,intBrokerageAccountId,strInstrumentType 
		,intNoOfContract,dblContractSize,strCurrency,intInvoiceId,strInvoiceNumber,intBillId,strBillId 
		,intInventoryReceiptId,strReceiptNumber,intTicketId,strShipmentNumber,intInventoryShipmentId,intItemId
		)

	SELECT t.intCommodityId, strCommodityCode ,intContractHeaderId,strContractNumber,intFutOptTransactionHeaderId,strInternalTradeNo, strType,strContractType,strContractEndMonth, 	
	    case when (isnull(@intUnitMeasureId, 0) = 0 OR cuc.intCommodityUnitMeasureId = @intUnitMeasureId) then dblTotal else
		Convert(decimal(24,10),dbo.fnCTConvertQuantityToTargetCommodityUOM(cuc.intCommodityUnitMeasureId,cuc1.intCommodityUnitMeasureId ,dblTotal)) end dblTotal,
		case when isnull(@strUnitMeasure,'')='' then um.strUnitMeasure else @strUnitMeasure end as strUnitMeasure,intInventoryReceiptItemId,strLocationName,strTicketNumber,
		dtmTicketDateTime,strCustomerReference,strDistributionOption,dblUnitCost,dblQtyReceived,strAccountNumber,strTranType,dblNoOfLot,dblDelta,intBrokerageAccountId,
		strInstrumentType,intNoOfContract,dblContractSize,strCurrency ,intInvoiceId,strInvoiceNumber,intBillId,strBillId,intInventoryReceiptId,strReceiptNumber,intTicketId,strShipmentNumber,
		intInventoryShipmentId,intItemId 
	FROM @tempFinal t
	JOIN tblICCommodityUnitMeasure cuc on t.intCommodityId=cuc.intCommodityId and cuc.ysnDefault=1 
	JOIN tblICUnitMeasure um on um.intUnitMeasureId=cuc.intUnitMeasureId
	LEFT JOIN tblICCommodityUnitMeasure cuc1 on t.intCommodityId=cuc1.intCommodityId and @intUnitMeasureId=cuc1.intUnitMeasureId
	WHERE t.intCommodityId= @intCommodityId  and strType not in('Net Payable  ($)','Net Receivable  ($)')

	INSERT INTO @Final (intCommodityId,strCommodityCode ,intContractHeaderId,strContractNumber,intFutOptTransactionHeaderId,strInternalTradeNo, strType,strContractType,strContractEndMonth, 
		dblTotal,strUnitMeasure,intInventoryReceiptItemId,strLocationName,strTicketNumber,dtmTicketDateTime,strCustomerReference,strDistributionOption,dblUnitCost,dblQtyReceived,strAccountNumber,strTranType,dblNoOfLot,dblDelta,intBrokerageAccountId,strInstrumentType 
		,intNoOfContract,dblContractSize,strCurrency,intInvoiceId,strInvoiceNumber,intBillId,strBillId 
		,intInventoryReceiptId,strReceiptNumber,intTicketId,strShipmentNumber,intInventoryShipmentId,intItemId)

	SELECT t.intCommodityId,strCommodityCode ,intContractHeaderId,strContractNumber,intFutOptTransactionHeaderId,strInternalTradeNo, strType,strContractType,
	strContractEndMonth, dblTotal dblTotal,case when isnull(@strUnitMeasure,'')='' then um.strUnitMeasure else @strUnitMeasure end as strUnitMeasure,
		intInventoryReceiptItemId,strLocationName,strTicketNumber,dtmTicketDateTime,strCustomerReference,strDistributionOption,dblUnitCost,dblQtyReceived,
		strAccountNumber,strTranType,dblNoOfLot,dblDelta,intBrokerageAccountId,strInstrumentType,intNoOfContract,dblContractSize,strCurrency,intInvoiceId,strInvoiceNumber,intBillId,strBillId 
		,intInventoryReceiptId,strReceiptNumber,intTicketId,strShipmentNumber,intInventoryShipmentId,intItemId
	FROM @tempFinal t
	JOIN tblICCommodityUnitMeasure cuc on t.intCommodityId=cuc.intCommodityId and cuc.ysnDefault=1 
	JOIN tblICUnitMeasure um on um.intUnitMeasureId=cuc.intUnitMeasureId
	WHERE t.intCommodityId= @intCommodityId and strType in( 'Net Payable  ($)','Net Receivable  ($)')


END
ELSE--==================== Specific Customer/Vendor =================================================
BEGIN

	INSERT INTO @tempFinal (strCommodityCode,intContractHeaderId,strContractNumber,strType,strSubType,strContractType,strLocationName,strContractEndMonth,dblTotal,intFromCommodityUnitMeasureId,intCommodityId,intCompanyLocationId)
	SELECT * FROM 
	(SELECT cd.strCommodityCode,cd.intContractHeaderId,strContractNumber,cd.strType [strType],[strType] strSubType,'Physical' strContractType,strLocationName,
		RIGHT(CONVERT(VARCHAR(11),dtmEndDate,106),8) strContractEndMonth,
		dbo.fnCTConvertQuantityToTargetCommodityUOM(cd.intCommodityUnitMeasureId,@intCommodityUnitMeasureId,isnull((cd.dblBalance),0)) AS dblTotal
	   ,cd.intUnitMeasureId,@intCommodityId as intCommodityId,cd.intCompanyLocationId 
	FROM @tblGetOpenContractDetail cd
	WHERE cd.intContractTypeId in(1,2) and
		cd.intCommodityId in (SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCommodityId, ','))
	AND cd.intCompanyLocationId= CASE WHEN ISNULL(@intLocationId,0)=0 THEN cd.intCompanyLocationId ELSE @intLocationId END
	AND intEntityId= @intVendorId
	)t
	WHERE intCompanyLocationId  IN (SELECT intCompanyLocationId FROM tblSMCompanyLocation
						WHERE isnull(ysnLicensed, 0) = CASE WHEN @strPositionIncludes = 'Licensed Storage' THEN 1 
								WHEN @strPositionIncludes = 'Non-licensed Storage' THEN 0 
								ELSE isnull(ysnLicensed, 0) END
				)		
	INSERT INTO @tempFinal (strCommodityCode,strType,dblTotal,intContractHeaderId,strContractNumber,strLocationName,strTicketNumber,dtmTicketDateTime,
					strDistributionOption,dblUnitCost,dblQtyReceived,intCommodityId,strCurrency,intBillId,strBillId,strCustomerReference)
	SELECT @strDescription, 'Net Payable  ($)' [strType],dblTotal dblTotal,
		intContractHeaderId,strContractNumber,strLocationName,strTicketNumber,dtmTicketDateTime,strDistributionOption,dblUnitCost1,
		dblQtyReceived,intCommodityId,strCurrency,intBillId,strBillId,strCustomerReference
	 FROM(	
		SELECT DISTINCT B.intBillId,B.strBillId,	
				strLocationName
				,t.strTicketNumber
				,t.dtmTicketDateTime
				,strDistributionOption
				,dblCost dblUnitCost
				,sum(BD.dblQtyReceived) over (partition by B.intBillId) dblQtyReceived
				,sum(B.dblTotal) over (partition by B.intBillId) dblTotal
				,BD.dblCost
				,dblAmountDue
				,dblCost dblUnitCost1
				,c.intCommodityId, NULL as intContractHeaderId, NULL as strContractNumber,Cur.strCurrency,strName strCustomerReference
				FROM tblAPBill B
					JOIN tblAPBillDetail BD ON B.intBillId = BD.intBillId
					JOIN tblICItem I ON BD.intItemId = I.intItemId AND BD.intInventoryReceiptChargeId IS NULL
					JOIN tblICCommodity c on I.intCommodityId = c.intCommodityId
					JOIN tblSMCurrency Cur ON B.intCurrencyId = Cur.intCurrencyID
					JOIN tblSMCompanyLocation cl on cl.intCompanyLocationId = B.intShipToId
					LEFT JOIN tblSCTicket t on BD.intScaleTicketId = t.intTicketId
					LEFT JOIN tblEMEntity e on t.intEntityId=e.intEntityId 
				WHERE 
				c.intCommodityId = @intCommodityId  and isnull(strTicketStatus,'') <> 'V' and
				cl.intCompanyLocationId = CASE WHEN ISNULL(@intLocationId,0)=0 then cl.intCompanyLocationId else @intLocationId end
				and B.intEntityVendorId = @intVendorId
				and convert(DATETIME, CONVERT(VARCHAR(10), B.dtmDate, 110), 110) <= convert(datetime,@dtmToDate)
				and intCompanyLocationId   IN (SELECT intCompanyLocationId FROM tblSMCompanyLocation
									WHERE isnull(ysnLicensed, 0) = CASE WHEN @strPositionIncludes = 'Licensed Storage' THEN 1 
									WHEN @strPositionIncludes = 'Non-licensed Storage' THEN 0 
									ELSE isnull(ysnLicensed, 0) END
									) 			
			)t  where dblTotal <> 0
						
	INSERT INTO @tempFinal (strCommodityCode,strType,dblTotal,strLocationName,intContractHeaderId,strContractNumber,strTicketNumber,
		dtmTicketDateTime,strCustomerReference,strDistributionOption,dblUnitCost,dblQtyReceived,intCommodityId,strCurrency,intInvoiceId,strInvoiceNumber)
	SELECT 
		@strDescription
		,'Net Receivable  ($)' [strType] 
		,I.dblAmountDue
		,L.strLocationName
		,null intContractHeaderId
		,'' strContractNumber
		,T.strTicketNumber
		,I.dtmDate
		,E.strName
		,'' strDistributionOption
		,null dblUCost
		,SUM(ID.dblQtyShipped) dblQtyReceived
		,intCommodityId
		,Cur.strCurrency
		,I.intInvoiceId
		,I.strInvoiceNumber
	FROM tblARInvoice I
		INNER JOIN tblARInvoiceDetail ID ON I.intInvoiceId = ID.intInvoiceId AND intInventoryShipmentChargeId IS NULL
		INNER JOIN tblSMCompanyLocation L ON I.intCompanyLocationId = L.intCompanyLocationId
		INNER JOIN tblSCTicket T ON ID.intTicketId = T.intTicketId
		INNER JOIN tblEMEntity E ON I.intEntityCustomerId = E.intEntityId
		INNER JOIN tblSMCurrency Cur ON I.intCurrencyId = Cur.intCurrencyID
	WHERE I.ysnPosted = 1
		AND convert(DATETIME, CONVERT(VARCHAR(10), I.dtmDate, 110), 110) <= convert(datetime,@dtmToDate) 
		AND dblAmountDue <> 0
		AND intCommodityId = 12 
		AND L.intCompanyLocationId= case when isnull(@intLocationId,0)=0 then L.intCompanyLocationId else @intLocationId end	
		AND L.intCompanyLocationId   IN (SELECT intCompanyLocationId FROM tblSMCompanyLocation
							WHERE isnull(ysnLicensed, 0) = CASE WHEN @strPositionIncludes = 'Licensed Storage' THEN 1 
							WHEN @strPositionIncludes = 'Non-licensed Storage' THEN 0 
							ELSE isnull(ysnLicensed, 0) END
							)
		AND I.intEntityCustomerId = @intVendorId
	GROUP BY
		I.dblAmountDue
		,L.strLocationName
		,T.strTicketNumber
		,I.dtmDate
		,E.strName
		,intCommodityId
		,Cur.strCurrency
		,I.intInvoiceId
		,I.strInvoiceNumber
		

	INSERT INTO @tempFinal (strCommodityCode,strType,dblTotal,intContractHeaderId,strContractNumber,strLocationName,strTicketNumber,dtmTicketDateTime,
					strCustomerReference,strDistributionOption,dblUnitCost,dblQtyReceived,intCommodityId,strContractType,intBillId,strBillId)

	select strCommodityCode,'NP Un-Paid Quantity' strType,dblTotal/case when isnull(dblUnitCost,0)=0 then 1 else dblUnitCost end,intContractHeaderId,strContractNumber,strLocationName,strTicketNumber,dtmTicketDateTime,
					strCustomerReference,strDistributionOption,dblUnitCost,dblQtyReceived,intCommodityId,strContractType,intBillId,strBillId
					 FROM @tempFinal where strType='Net Payable  ($)' and intCommodityId=@intCommodityId

	INSERT INTO @tempFinal (strCommodityCode,strType,dblTotal,intInventoryReceiptItemId,strLocationName,intContractHeaderId,strContractNumber,strTicketNumber,dtmTicketDateTime,
	strCustomerReference,strDistributionOption,dblUnitCost,dblQtyReceived,intCommodityId,strContractType,intInvoiceId,strInvoiceNumber	)
	select @strDescription,'NR Un-Paid Quantity' strType,dblQtyReceived,intInventoryReceiptItemId,strLocationName,intContractHeaderId,strContractNumber,strTicketNumber,dtmTicketDateTime,
 	 strCustomerReference,strDistributionOption,dblUnitCost,dblQtyReceived,intCommodityId,strContractType,intInvoiceId,strInvoiceNumber
	 from @tempFinal where strType= 'Net Receivable  ($)' and intCommodityId=@intCommodityId

	SELECT @intUnitMeasureId =null
	SELECT @strUnitMeasure =null
	SELECT TOP 1 @intUnitMeasureId = intUnitMeasureId FROM tblRKCompanyPreference
	SELECT @strUnitMeasure=strUnitMeasure from tblICUnitMeasure where intUnitMeasureId=@intUnitMeasureId
	INSERT INTO @Final (intCommodityId, strCommodityCode ,intContractHeaderId,strContractNumber,intFutOptTransactionHeaderId,strInternalTradeNo, strType,strSubType,strContractType,strContractEndMonth, 
		dblTotal,strUnitMeasure,intInventoryReceiptItemId,strLocationName,strTicketNumber,dtmTicketDateTime,strCustomerReference,strDistributionOption,dblUnitCost,dblQtyReceived,strAccountNumber,strTranType,dblNoOfLot,dblDelta,intBrokerageAccountId,strInstrumentType 
		,intNoOfContract,dblContractSize,strCurrency,intInvoiceId,strInvoiceNumber,intBillId,strBillId)

	SELECT t.intCommodityId , strCommodityCode,intContractHeaderId,strContractNumber,intFutOptTransactionHeaderId,strInternalTradeNo, strType,strSubType,strContractType,strContractEndMonth, 	
	    Convert(decimal(24,10),dbo.fnCTConvertQuantityToTargetCommodityUOM(cuc.intCommodityUnitMeasureId,
		case when (isnull(@intUnitMeasureId, 0) = 0 OR cuc.intCommodityUnitMeasureId = @intUnitMeasureId) then cuc.intCommodityUnitMeasureId else cuc1.intCommodityUnitMeasureId end,dblTotal)) dblTotal,
		case when isnull(@strUnitMeasure,'')='' then um.strUnitMeasure else @strUnitMeasure end as strUnitMeasure,intInventoryReceiptItemId,strLocationName,strTicketNumber,dtmTicketDateTime,strCustomerReference,strDistributionOption,dblUnitCost,dblQtyReceived,
		strAccountNumber,strTranType,dblNoOfLot,dblDelta,intBrokerageAccountId,strInstrumentType
		,intNoOfContract,dblContractSize,strCurrency,intInvoiceId,strInvoiceNumber,intBillId,strBillId
	FROM @tempFinal t
	JOIN tblICCommodityUnitMeasure cuc on t.intCommodityId=cuc.intCommodityId and cuc.ysnDefault=1 
	JOIN tblICUnitMeasure um on um.intUnitMeasureId=cuc.intUnitMeasureId
	LEFT JOIN tblICCommodityUnitMeasure cuc1 on t.intCommodityId=cuc1.intCommodityId and @intUnitMeasureId=cuc1.intUnitMeasureId
	WHERE t.intCommodityId= @intCommodityId and strType not in('Net Payable  ($)','Net Receivable  ($)')
	UNION

	SELECT t.intCommodityId,strCommodityCode ,intContractHeaderId,strContractNumber,intFutOptTransactionHeaderId,strInternalTradeNo, strType,strSubType,strContractType,
	strContractEndMonth, dblTotal dblTotal,case when isnull(@strUnitMeasure,'')='' then um.strUnitMeasure else @strUnitMeasure end as strUnitMeasure,intInventoryReceiptItemId,strLocationName,strTicketNumber,dtmTicketDateTime,strCustomerReference,
	strDistributionOption,dblUnitCost,dblQtyReceived,strAccountNumber,strTranType,dblNoOfLot,dblDelta,intBrokerageAccountId,strInstrumentType  
	,intNoOfContract,dblContractSize,strCurrency,intInvoiceId,strInvoiceNumber,intBillId,strBillId
	FROM @tempFinal t
	JOIN tblICCommodityUnitMeasure cuc on t.intCommodityId=cuc.intCommodityId and cuc.ysnDefault=1 
	JOIN tblICUnitMeasure um on um.intUnitMeasureId=cuc.intUnitMeasureId
	 WHERE t.intCommodityId= @intCommodityId and strType in( 'Net Payable  ($)','Net Receivable  ($)')
	
END
END
SELECT @mRowNumber = MIN(intCommodityIdentity)	FROM @Commodity	WHERE intCommodityIdentity > @mRowNumber	
END

UPDATE @Final set intSeqNo = 1 where strType like 'Purchase%'
UPDATE @Final set intSeqNo = 2 where strType like 'Sale%'
UPDATE @Final set intSeqNo = 3 where strType='Net Hedge'
UPDATE @Final set intSeqNo = 4 where strType='Price Risk'
UPDATE @Final set intSeqNo = 5 where strType='Basis Risk'
UPDATE @Final set intSeqNo = 6 where strType='Net Payable  ($)'
UPDATE @Final set intSeqNo = 7 where strType='NP Un-Paid Quantity'
UPDATE @Final set intSeqNo = 8 where strType='Net Receivable  ($)'
UPDATE @Final set intSeqNo = 9 where strType='NR Un-Paid Quantity'
UPDATE @Final set intSeqNo = 10 where strType='Avail for Spot Sale'

IF(@strByType = 'ByCommodity')
BEGIN
			SELECT distinct c.strCommodityCode,strUnitMeasure,strType,sum(dblTotal) dblTotal,c.intCommodityId
			FROM @Final f 
			join tblICCommodity c on c.intCommodityId= f.intCommodityId
			where dblTotal <> 0 
			GROUP BY c.strCommodityCode,strUnitMeasure,strType,c.intCommodityId
END
ELSE IF(@strByType = 'ByLocation')
BEGIN
			SELECT distinct c.strCommodityCode,strUnitMeasure,strType,sum(dblTotal) dblTotal,c.intCommodityId,strLocationName
			FROM @Final f 
			JOIN tblICCommodity c on c.intCommodityId= f.intCommodityId
			WHERE dblTotal <> 0
			GROUP BY c.strCommodityCode,strUnitMeasure,strType,c.intCommodityId,strLocationName
END
ELSE 
BEGIN IF isnull(@intVendorId,0) = 0
		BEGIN
			SELECT intSeqNo,intRow, c.strCommodityCode ,intContractHeaderId,strContractNumber,strInternalTradeNo,intFutOptTransactionHeaderId, strType,strContractType,strContractEndMonth,dblTotal,strUnitMeasure 
						,intInventoryReceiptItemId,strLocationName,isnull(strTicketNumber,'' ) strTicketNumber,dtmTicketDateTime,strCustomerReference,strDistributionOption,dblUnitCost,dblQtyReceived,strAccountNumber,strTranType,dblNoOfLot,dblDelta,intBrokerageAccountId,strInstrumentType,
						0.0 invQty,0.0 PurBasisDelivary,0.0 OpenPurQty,0.0 OpenSalQty,0.0 dblCollatralSales,0.0 SlsBasisDeliveries,0.0 CompanyTitled,intNoOfContract,dblContractSize,intNoOfContract,dblContractSize,strCurrency,intInvoiceId,isnull(strInvoiceNumber,'') strInvoiceNumber,intBillId,isnull(strBillId,'') strBillId
						,intInventoryReceiptId,isnull(strReceiptNumber,'') strReceiptNumber,intTicketId,isnull(strShipmentNumber,'') strShipmentNumber,intInventoryShipmentId,intItemId,isnull(strTicketNumber,'') strTicketNumber
			FROM @Final f 
			JOIN tblICCommodity c on c.intCommodityId= f.intCommodityId			
			where dblTotal <> 0 
		
			ORDER BY intSeqNo,strType ASC,case when isnull(intContractHeaderId,0)=0 then intFutOptTransactionHeaderId else intContractHeaderId end desc
		END
		ELSE
		BEGIN
			SELECT intSeqNo,intRow, c.strCommodityCode ,intContractHeaderId,strContractNumber,strInternalTradeNo,intFutOptTransactionHeaderId, strType,strContractType,strContractEndMonth,dblTotal,strUnitMeasure 
						,intInventoryReceiptItemId,strLocationName,isnull(strTicketNumber,'' ) strTicketNumber,dtmTicketDateTime,strCustomerReference,strDistributionOption,dblUnitCost,dblQtyReceived,strAccountNumber,strTranType,dblNoOfLot,dblDelta,intBrokerageAccountId,strInstrumentType,
						0.0 invQty,0.0 PurBasisDelivary,0.0 OpenPurQty,0.0 OpenSalQty,0.0 dblCollatralSales,0.0 SlsBasisDeliveries,0.0 CompanyTitled,intNoOfContract,dblContractSize,intNoOfContract,dblContractSize,strCurrency,intInvoiceId,isnull(strInvoiceNumber,'') strInvoiceNumber,intBillId,isnull(strBillId,'') strBillId
						,intInventoryReceiptId,isnull(strReceiptNumber,'') strReceiptNumber,intTicketId,isnull(strShipmentNumber,'') strShipmentNumber,intInventoryShipmentId,intItemId,isnull(strTicketNumber,'') strTicketNumber
			FROM @Final f 
			JOIN tblICCommodity c on c.intCommodityId= f.intCommodityId			
			where dblTotal <> 0 --and strSubType NOT like '%'+@strPurchaseSales+'%'  
			ORDER BY intSeqNo,strType ASC,case when isnull(intContractHeaderId,0)=0 then intFutOptTransactionHeaderId else intContractHeaderId end desc
		END
END


	
