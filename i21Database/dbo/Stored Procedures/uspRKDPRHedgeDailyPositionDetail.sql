CREATE PROCEDURE [dbo].[uspRKDPRHedgeDailyPositionDetail] 
		 @intCommodityId nvarchar(max)= null
		,@intLocationId int = null
		,@intVendorId int = null
		,@strPurchaseSales nvarchar(50) = null
		,@strPositionIncludes NVARCHAR(100) = NULL
		,@dtmToDate datetime = NULL
AS

IF isnull(@strPurchaseSales,'') <> ''
BEGIN
	if @strPurchaseSales='Purchase'
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
INSERT INTO @Commodity(intCommodity)
SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCommodityId, ',')  
	 
DECLARE @tempFinal AS TABLE (
		 intRow INT IDENTITY(1,1),
		 intContractHeaderId int,
		 strContractNumber NVARCHAR(200),
		 intFutOptTransactionHeaderId int,
		 strInternalTradeNo NVARCHAR(200),
		 strCommodityCode NVARCHAR(200),   
		 strType  NVARCHAR(50), 
		 strSubType  NVARCHAR(50), 
		 strContractType NVARCHAR(50),
		 strLocationName NVARCHAR(100),
		 strContractEndMonth NVARCHAR(50),
		 intInventoryReceiptItemId INT
		,strTicketNumber  NVARCHAR(50)
		,dtmTicketDateTime DATETIME
		,strCustomerReference NVARCHAR(100)
		,strDistributionOption NVARCHAR(50)
		,dblUnitCost NUMERIC(24, 10)
		,dblQtyReceived NUMERIC(24, 10)
		,dblTotal DECIMAL(24,10)
		,intSeqNo int
		,intFromCommodityUnitMeasureId int
		,intToCommodityUnitMeasureId int
		,intCommodityId int
		,strAccountNumber NVARCHAR(100)
		,strTranType NVARCHAR(20)
		,dblNoOfLot NUMERIC(24, 10)
		,dblDelta NUMERIC(24, 10)
		,intBrokerageAccountId int
		,strInstrumentType nvarchar(50)
		,invQty NUMERIC(24, 10),
		 PurBasisDelivary NUMERIC(24, 10),
		 OpenPurQty NUMERIC(24, 10),
		 OpenSalQty NUMERIC(24, 10), 
		 dblCollatralSales NUMERIC(24, 10), 
		 SlsBasisDeliveries NUMERIC(24, 10),
		 intNoOfContract NUMERIC(24, 10),
		 dblContractSize NUMERIC(24, 10),
		 CompanyTitled NUMERIC(24, 10),
		 strCurrency nvarchar(50),
		 intCompanyLocationId int
)

DECLARE @Final AS TABLE (
		 intRow INT IDENTITY(1,1),
		 intContractHeaderId int,
		 strContractNumber NVARCHAR(200),
		 intFutOptTransactionHeaderId int,
		 strInternalTradeNo NVARCHAR(200),
		 strCommodityCode NVARCHAR(200),   
		 strType  NVARCHAR(50), 
		 strSubType NVARCHAR(50), 
		 strContractType NVARCHAR(50),
		 strLocationName NVARCHAR(100),
		 strContractEndMonth NVARCHAR(50),
		 intInventoryReceiptItemId INT
		,strTicketNumber  NVARCHAR(50)
		,dtmTicketDateTime DATETIME
		,strCustomerReference NVARCHAR(100)
		,strDistributionOption NVARCHAR(50)
		,dblUnitCost NUMERIC(24, 10)
		,dblQtyReceived NUMERIC(24, 10)
		,dblTotal DECIMAL(24,10)
		,strUnitMeasure NVARCHAR(50)
		,intSeqNo int
		,intFromCommodityUnitMeasureId int
		,intToCommodityUnitMeasureId int
		,intCommodityId int
		,strAccountNumber NVARCHAR(100)
		,strTranType NVARCHAR(20)
		,dblNoOfLot NUMERIC(24, 10)
		,dblDelta NUMERIC(24, 10)
		,intBrokerageAccountId int
		,strInstrumentType nvarchar(50)
		,invQty NUMERIC(24, 10),
		 PurBasisDelivary NUMERIC(24, 10),
		 OpenPurQty NUMERIC(24, 10),
		 OpenSalQty NUMERIC(24, 10), 
		 dblCollatralSales NUMERIC(24, 10), 
		 SlsBasisDeliveries NUMERIC(24, 10),
		 intNoOfContract NUMERIC(24, 10),
		 dblContractSize NUMERIC(24, 10),
		 CompanyTitled NUMERIC(24, 10),
		 strCurrency nvarchar(50)
)

DECLARE @mRowNumber INT
DECLARE @intCommodityId1 INT
DECLARE @strDescription NVARCHAR(50)
declare @intOneCommodityId int
declare @intCommodityUnitMeasureId int
DECLARE @intUnitMeasureId int
DECLARE @strUnitMeasure nvarchar(50)
SELECT @mRowNumber = MIN(intCommodityIdentity) FROM @Commodity
WHILE @mRowNumber >0
BEGIN
	SELECT @intCommodityId = intCommodity FROM @Commodity WHERE intCommodityIdentity = @mRowNumber
	SELECT @strDescription = strCommodityCode FROM tblICCommodity	WHERE intCommodityId = @intCommodityId
	SELECT @intCommodityUnitMeasureId=intCommodityUnitMeasureId from tblICCommodityUnitMeasure where intCommodityId=@intCommodityId AND ysnDefault=1
IF  @intCommodityId >0
BEGIN
DECLARE @tblGetOpenContractDetail TABLE (
		intRowNum int, 
		strCommodityCode  nvarchar(100),
		intCommodityId int, 
		intContractHeaderId int, 
	    strContractNumber  nvarchar(100),
		strLocationName  nvarchar(100),
		dtmEndDate datetime,
		dblBalance DECIMAL(24,10),
		intUnitMeasureId int, 	
		intPricingTypeId int,
		intContractTypeId int,
		intCompanyLocationId int,
		strContractType  nvarchar(100), 
		strPricingType  nvarchar(100),
		intCommodityUnitMeasureId int,
		intContractDetailId int,
		intContractStatusId int,
		intEntityId int,
		intCurrencyId int,
		strType	  nvarchar(100),
		intItemId int,
		strItemNo  nvarchar(100),
		dtmContractDate datetime,
		strEntityName  nvarchar(100),
		strCustomerContract  nvarchar(100)
				,intFutureMarketId int
		,intFutureMonthId int)

INSERT INTO @tblGetOpenContractDetail (intRowNum,strCommodityCode,intCommodityId,intContractHeaderId,strContractNumber,strLocationName,dtmEndDate,dblBalance,intUnitMeasureId,intPricingTypeId,intContractTypeId,
	   intCompanyLocationId,strContractType,strPricingType,intCommodityUnitMeasureId,intContractDetailId,intContractStatusId,intEntityId,intCurrencyId,strType,intItemId,strItemNo ,dtmContractDate,strEntityName,strCustomerContract
	   	   ,intFutureMarketId,intFutureMonthId)
EXEC uspRKDPRContractDetail @intCommodityId, @dtmToDate


DECLARE @tblGetOpenFutureByDate TABLE (
		intFutOptTransactionId int, 
		intOpenContract  int)
INSERT INTO @tblGetOpenFutureByDate (intFutOptTransactionId,intOpenContract)
EXEC uspRKGetOpenContractByDate @intCommodityId, @dtmToDate

DECLARE @tblGetStorageDetailByDate TABLE (
		intRowNum int, 
		intCustomerStorageId int,
		intCompanyLocationId int	
		,[Loc] nvarchar(100)
		,[Delivery Date] datetime
		,[Ticket] nvarchar(100)
		,intEntityId int
		,[Customer] nvarchar(100)
		,[Receipt] nvarchar(100)
		,[Disc Due] numeric(24,10)
		,[Storage Due] numeric(24,10)
		,[Balance] numeric(24,10)
		,intStorageTypeId int
		,[Storage Type] nvarchar(100)
		,intCommodityId int
		,[Commodity Code] nvarchar(100)
		,[Commodity Description] nvarchar(100)
		,strOwnedPhysicalStock nvarchar(100)
		,ysnReceiptedStorage bit
		,ysnDPOwnedType bit
		,ysnGrainBankType bit
		,ysnCustomerStorage bit
		,strCustomerReference  nvarchar(100)
 		,dtmLastStorageAccrueDate  datetime
 		,strScheduleId nvarchar(100)
		,strItemNo nvarchar(100)
		,strLocationName nvarchar(100)
		,intCommodityUnitMeasureId int
		,intItemId int)

INSERT INTO @tblGetStorageDetailByDate
EXEC uspRKGetStorageDetailByDate @intCommodityId, @dtmToDate

SELECT 	dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId,@intCommodityUnitMeasureId,(isnull(s.dblQuantity ,0)))  dblTotal,'' strCustomer,null Ticket,null dtmDeliveryDate
	,s.strLocationName,s.strItemNo,@intCommodityId intCommodityId,@intCommodityUnitMeasureId intFromCommodityUnitMeasureId,'' strTruckName,'' strDriverName
	,null [Storage Due],s.intLocationId intLocationId,strTransactionId,strTransactionType into #invQty
	FROM vyuICGetInventoryValuation s  		
	JOIN tblICItem i on i.intItemId=s.intItemId
	JOIN tblICItemUOM iuom on s.intItemId=iuom.intItemId and iuom.ysnStockUnit=1 and  isnull(ysnInTransit,0)=0 
	JOIN tblICCommodityUnitMeasure ium on ium.intCommodityId=i.intCommodityId AND iuom.intUnitMeasureId=ium.intUnitMeasureId   		  
	WHERE i.intCommodityId = @intCommodityId and iuom.ysnStockUnit=1 AND ISNULL(s.dblQuantity,0) <>0
				and convert(DATETIME, CONVERT(VARCHAR(10), s.dtmDate, 110), 110)<=convert(datetime,@dtmToDate)
							and s.intLocationId  IN (
				SELECT intCompanyLocationId FROM tblSMCompanyLocation
				WHERE isnull(ysnLicensed, 0) = CASE WHEN @strPositionIncludes = 'licensed storage' THEN 1 
								WHEN @strPositionIncludes = 'Non-licensed storage' THEN 0 
								ELSE isnull(ysnLicensed, 0) END
				)

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
		LEFT JOIN @tblGetOpenContractDetail ch on c.intContractHeaderId=ch.intContractHeaderId and ch.intContractStatusId <> 3
		WHERE c.intCommodityId = @intCommodityId and convert(DATETIME, CONVERT(VARCHAR(10), dtmTransactionDate, 110), 110) <= convert(datetime,@dtmToDate) 
											AND  c.intLocationId   IN (SELECT intCompanyLocationId FROM tblSMCompanyLocation
									WHERE isnull(ysnLicensed, 0) = CASE WHEN @strPositionIncludes = 'licensed storage' THEN 1 
									WHEN @strPositionIncludes = 'Non-licensed storage' THEN 0 
									ELSE isnull(ysnLicensed, 0) END
									)
		) a where   a.intRowNum =1
	
if isnull(@intVendorId,0) = 0
BEGIN
	INSERT INTO @tempFinal (strCommodityCode,intContractHeaderId,strContractNumber,strType,strContractType,strLocationName,strContractEndMonth,dblTotal,intFromCommodityUnitMeasureId,intCommodityId,intCompanyLocationId)
	SELECT * FROM 
	(SELECT cd.strCommodityCode,cd.intContractHeaderId,strContractNumber,cd.strType [strType],'Physical' strContractType,strLocationName,
		RIGHT(CONVERT(VARCHAR(11),dtmEndDate,106),8) strContractEndMonth,
		dbo.fnCTConvertQuantityToTargetCommodityUOM(cd.intCommodityUnitMeasureId,@intCommodityUnitMeasureId,isnull((cd.dblBalance),0)) AS dblTotal
	   ,cd.intUnitMeasureId,@intCommodityId as intCommodityId,cd.intCompanyLocationId 
	FROM @tblGetOpenContractDetail cd
	WHERE cd.intContractTypeId in(1,2) and
		cd.intCommodityId in (SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCommodityId, ','))
	AND cd.intCompanyLocationId= CASE WHEN ISNULL(@intLocationId,0)=0 THEN cd.intCompanyLocationId ELSE @intLocationId END)t
		WHERE intCompanyLocationId  IN (SELECT intCompanyLocationId FROM tblSMCompanyLocation
				WHERE isnull(ysnLicensed, 0) = CASE WHEN @strPositionIncludes = 'licensed storage' THEN 1 
								WHEN @strPositionIncludes = 'Non-licensed storage' THEN 0 
								ELSE isnull(ysnLicensed, 0) END
				)

	-- Hedge
	INSERT INTO @tempFinal (strCommodityCode,strInternalTradeNo,intFutOptTransactionHeaderId,strType,strContractType,strLocationName,strContractEndMonth,dblTotal,
							intFromCommodityUnitMeasureId,intCommodityId,strAccountNumber,strTranType,intBrokerageAccountId,strInstrumentType,dblNoOfLot)		
	
	SELECT strCommodityCode,strInternalTradeNo,intFutOptTransactionHeaderId,'Net Hedge','Future' strContractType,strLocationName, strFutureMonth,
	HedgedQty,@intCommodityUnitMeasureId intFromCommodityUnitMeasureId,@intCommodityId intCommodityId,strAccountNumber,strTranType,intBrokerageAccountId,strInstrumentType,dblNoOfLot
	FROM (
		SELECT strCommodityCode,strInternalTradeNo,intFutOptTransactionHeaderId,f.intCommodityId,dtmFutureMonthsDate,
		dbo.fnCTConvertQuantityToTargetCommodityUOM(cuc1.intCommodityUnitMeasureId,@intCommodityUnitMeasureId,  
		intOpenContract	 * 	 dblContractSize) AS HedgedQty,
		l.strLocationName,left(strFutureMonth,4) +  '20'+convert(nvarchar(2),intYear) strFutureMonth,m.intUnitMeasureId,
		e.strName + '-' + ba.strAccountNumber strAccountNumber,strBuySell as strTranType,f.intBrokerageAccountId,
		'Futures' as strInstrumentType,
		intOpenContract dblNoOfLot 
		FROM @tblGetOpenFutureByDate oc
		JOIN tblRKFutOptTransaction f on oc.intFutOptTransactionId=f.intFutOptTransactionId 
		INNER JOIN tblRKFutureMarket m ON f.intFutureMarketId = m.intFutureMarketId	     
		INNER JOIN tblICCommodity ic on f.intCommodityId=ic.intCommodityId
		JOIN tblICCommodityUnitMeasure cuc1 on f.intCommodityId=cuc1.intCommodityId and m.intUnitMeasureId=cuc1.intUnitMeasureId
		INNER JOIN tblRKFuturesMonth fm on fm.intFutureMonthId=f.intFutureMonthId
		INNER JOIN tblSMCompanyLocation l on f.intLocationId=l.intCompanyLocationId 
											AND  intCompanyLocationId  IN (SELECT intCompanyLocationId FROM tblSMCompanyLocation
											WHERE isnull(ysnLicensed, 0) = CASE WHEN @strPositionIncludes = 'licensed storage' THEN 1 
															WHEN @strPositionIncludes = 'Non-licensed storage' THEN 0 
															ELSE isnull(ysnLicensed, 0) END
											)
		INNER JOIN tblRKBrokerageAccount ba ON f.intBrokerageAccountId = ba.intBrokerageAccountId
		INNER JOIN tblEMEntity e ON e.intEntityId = f.intEntityId AND f.intInstrumentTypeId = 1		
		WHERE ic.intCommodityId in (SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCommodityId, ','))
			AND f.intLocationId= CASE WHEN ISNULL(@intLocationId,0)=0 then f.intLocationId else @intLocationId end			
		) t	

--	-- Option NetHEdge
	INSERT INTO @tempFinal (strCommodityCode,strInternalTradeNo,intFutOptTransactionHeaderId,strType,strContractType,strLocationName,strContractEndMonth,dblTotal,
							intFromCommodityUnitMeasureId,intCommodityId,strAccountNumber,strTranType,dblNoOfLot,dblDelta,intBrokerageAccountId,strInstrumentType)	
		SELECT DISTINCT strCommodityCode,ft.strInternalTradeNo,intFutOptTransactionHeaderId,'Net Hedge' ,'Options',strLocationName,
				 LEFT(strFutureMonth,4) +  '20'+convert(nvarchar(2),intYear) strFutureMonth, 				
				intOpenContract * isnull((
						SELECT TOP 1 dblDelta
						FROM tblRKFuturesSettlementPrice sp
						INNER JOIN tblRKOptSettlementPriceMarketMap mm ON sp.intFutureSettlementPriceId = mm.intFutureSettlementPriceId
						WHERE intFutureMarketId = ft.intFutureMarketId AND mm.intOptionMonthId = ft.intOptionMonthId AND mm.intTypeId = CASE WHEN ft.strOptionType = 'Put' THEN 1 ELSE 2 END
						AND ft.dblStrike = mm.dblStrike
						ORDER BY dtmPriceDate DESC
				),0)*m.dblContractSize AS dblNoOfContract, m.intUnitMeasureId,ft.intCommodityId,				
		e.strName + '-' + strAccountNumber AS strAccountNumber, 		
		strBuySell AS TranType, 
		intOpenContract AS dblNoOfLot, 
		isnull((SELECT TOP 1 dblDelta
		FROM tblRKFuturesSettlementPrice sp
		INNER JOIN tblRKOptSettlementPriceMarketMap mm ON sp.intFutureSettlementPriceId = mm.intFutureSettlementPriceId
		WHERE intFutureMarketId = ft.intFutureMarketId AND mm.intOptionMonthId = ft.intOptionMonthId AND mm.intTypeId = CASE WHEN ft.strOptionType = 'Put' THEN 1 ELSE 2 END
		AND ft.dblStrike = mm.dblStrike
		ORDER BY dtmPriceDate DESC
		),0) AS dblDelta,
		ft.intBrokerageAccountId, 'Options' as strInstrumentType
	FROM @tblGetOpenFutureByDate oc
	JOIN tblRKFutOptTransaction ft on oc.intFutOptTransactionId=ft.intFutOptTransactionId 
	INNER JOIN tblRKFutureMarket m ON ft.intFutureMarketId = m.intFutureMarketId
											AND  ft.intLocationId  IN (SELECT intCompanyLocationId FROM tblSMCompanyLocation
										WHERE isnull(ysnLicensed, 0) = CASE WHEN @strPositionIncludes = 'licensed storage' THEN 1 
														WHEN @strPositionIncludes = 'Non-licensed storage' THEN 0 
														ELSE isnull(ysnLicensed, 0) END
										)
	INNER JOIN tblSMCompanyLocation l on ft.intLocationId=l.intCompanyLocationId
	INNER JOIN tblICCommodity ic on ft.intCommodityId=ic.intCommodityId
	INNER JOIN tblRKBrokerageAccount ba ON ft.intBrokerageAccountId = ba.intBrokerageAccountId
	INNER JOIN tblEMEntity e ON e.intEntityId = ft.intEntityId AND ft.intInstrumentTypeId = 2
	INNER JOIN tblRKFuturesMonth fm ON fm.intFutureMonthId = ft.intFutureMonthId AND fm.intFutureMarketId = ft.intFutureMarketId AND fm.ysnExpired = 0
	WHERE ft.intCommodityId = @intCommodityId AND intLocationId = case when isnull(@intLocationId,0)=0 then intLocationId else @intLocationId end AND ft.intFutOptTransactionId NOT IN (
	SELECT intFutOptTransactionId FROM tblRKOptionsPnSExercisedAssigned) 
	AND ft.intFutOptTransactionId NOT IN (SELECT intFutOptTransactionId FROM tblRKOptionsPnSExpired)

-- Net Hedge option end			
	INSERT INTO @tempFinal(strCommodityCode,strType,strContractType,dblTotal,intFromCommodityUnitMeasureId,intCommodityId,invQty,PurBasisDelivary,OpenPurQty,OpenSalQty,dblCollatralSales, SlsBasisDeliveries)

	SELECT @strDescription,'Price Risk' [strType],'Physical' strContractType
		,isnull(invQty, 0)
		-isnull(PurBasisDelivary,0) 
		 + (isnull(OpenPurQty, 0) -isnull(OpenSalQty, 0))
		 + isnull(dblCollatralSales,0) 
		+ isnull(SlsBasisDeliveries,0)
		 + CASE WHEN (SELECT TOP 1 ysnIncludeDPPurchasesInCompanyTitled from tblRKCompanyPreference)=1 then  isnull(DP ,0) ELSE 0 end 
		 AS dblTotal,
		@intCommodityUnitMeasureId,@intCommodityId,
		 isnull(invQty, 0) invQty ,-isnull(PurBasisDelivary,0) as PurBasisDelivary, isnull(OpenPurQty, 0) as OpenPurQty,
		 -isnull(OpenSalQty, 0) OpenSalQty,  isnull(dblCollatralSales,0) dblCollatralSales, isnull(SlsBasisDeliveries,0)
		SlsBasisDeliveries		 
	FROM (
		SELECT 
			
			(SELECT sum(dblTotal) dblTotal  from #invQty) AS invQty
			,( SELECT sum(dblBalance) dblBalance from (
				SELECT dbo.fnCTConvertQuantityToTargetCommodityUOM(cd.intCommodityUnitMeasureId,@intCommodityUnitMeasureId,isnull(cd.dblBalance,0)) dblBalance,intCompanyLocationId
				FROM @tblGetOpenContractDetail cd
				WHERE intContractTypeId = 1 and intPricingTypeId IN (1,3) AND cd.intCommodityId  = @intCommodityId 
				AND cd.intCompanyLocationId= case when isnull(@intLocationId,0)=0 then cd.intCompanyLocationId else @intLocationId end 
				)t	WHERE  intCompanyLocationId  IN (SELECT intCompanyLocationId FROM tblSMCompanyLocation
						WHERE isnull(ysnLicensed, 0) = CASE WHEN @strPositionIncludes = 'licensed storage' THEN 1 
						WHEN @strPositionIncludes = 'Non-licensed storage' THEN 0 
						ELSE isnull(ysnLicensed, 0) END
						)
			) AS OpenPurQty
			,( SELECT sum(dblBalance) dblBalance from (
				SELECT dbo.fnCTConvertQuantityToTargetCommodityUOM(cd.intCommodityUnitMeasureId,@intCommodityUnitMeasureId,isnull(cd.dblBalance,0)) dblBalance,intCompanyLocationId
				FROM @tblGetOpenContractDetail cd
				WHERE cd.intContractStatusId <> 3 AND intContractTypeId = 2 AND cd.intPricingTypeId IN (1, 3)
				 AND cd.intCommodityId  = @intCommodityId 
				AND cd.intCompanyLocationId= case when isnull(@intLocationId,0)=0 then cd.intCompanyLocationId else @intLocationId end
				)t	WHERE  intCompanyLocationId  IN (SELECT intCompanyLocationId FROM tblSMCompanyLocation
						WHERE isnull(ysnLicensed, 0) = CASE WHEN @strPositionIncludes = 'licensed storage' THEN 1 
						WHEN @strPositionIncludes = 'Non-licensed storage' THEN 0 
						ELSE isnull(ysnLicensed, 0) END
						)) AS OpenSalQty,				
			(select sum(dblTotal) dblTotal from (
					SELECT 
					dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId,@intCommodityUnitMeasureId,(isnull(Balance,0))) dblTotal
					,ch.intCompanyLocationId
					FROM @tblGetStorageDetailByDate ch
					WHERE ch.intCommodityId  = @intCommodityId	AND ysnDPOwnedType = 1
						AND ch.intCompanyLocationId= case when isnull(@intLocationId,0)=0 then ch.intCompanyLocationId else @intLocationId end
					)t 	WHERE intCompanyLocationId  IN (
								SELECT intCompanyLocationId FROM tblSMCompanyLocation
								WHERE isnull(ysnLicensed, 0) = CASE WHEN @strPositionIncludes = 'licensed storage' THEN 1 
								WHEN @strPositionIncludes = 'Non-licensed storage' THEN 0 
								ELSE isnull(ysnLicensed, 0) END
				) ) AS DP
	
			,					
			(select sum(dblTotal) dblTotal from(
			select dbo.fnCTConvertQuantityToTargetCommodityUOM(ium.intCommodityUnitMeasureId,@intCommodityUnitMeasureId,isnull(v.dblQuantity ,0)) AS dblTotal,cl.intCompanyLocationId
			FROM vyuICGetInventoryValuation v
			join tblICInventoryReceipt r on r.strReceiptNumber=v.strTransactionId
			INNER JOIN tblICInventoryReceiptItem ri ON r.intInventoryReceiptId = ri.intInventoryReceiptId AND r.strReceiptType = 'Purchase Contract'
			INNER JOIN tblSCTicket st ON st.intTicketId = ri.intSourceId  AND strDistributionOption IN ('CNT') and  isnull(ysnInTransit,0)=0 
			INNER JOIN @tblGetOpenContractDetail cd ON cd.intContractDetailId = ri.intLineNo AND cd.intPricingTypeId = 2  and cd.intContractStatusId <> 3
			JOIN tblICCommodityUnitMeasure ium on ium.intCommodityId=cd.intCommodityId AND cd.intUnitMeasureId=ium.intUnitMeasureId 
			INNER JOIN tblSMCompanyLocation  cl on cl.intCompanyLocationId=st.intProcessingLocationId 
			WHERE v.strTransactionType ='Inventory Receipt' and cd.intCommodityId = @intCommodityId AND st.intProcessingLocationId  = case when isnull(@intLocationId,0)=0 then st.intProcessingLocationId else @intLocationId end
			and convert(DATETIME, CONVERT(VARCHAR(10), v.dtmDate, 110), 110)<=convert(datetime,@dtmToDate)
			)t	WHERE  intCompanyLocationId  IN (
				SELECT intCompanyLocationId FROM tblSMCompanyLocation
				WHERE isnull(ysnLicensed, 0) = CASE WHEN @strPositionIncludes = 'licensed storage' THEN 1 
								WHEN @strPositionIncludes = 'Non-licensed storage' THEN 0 
								ELSE isnull(ysnLicensed, 0) END)) as PurBasisDelivary,

			isnull((SELECT SUM(dblRemainingQuantity) CollateralSale
			FROM ( 
			SELECT 
				-dblRemainingQuantity  dblRemainingQuantity,
					intContractHeaderId					
					FROM #tempCollateral c1									
					WHERE c1.intLocationId= case when isnull(@intLocationId,0)=0 then c1.intLocationId else @intLocationId end and intContractTypeId = 2
					 ) t 	
			), 0) AS dblCollatralSales			

		,(SELECT sum(SlsBasisDeliveries) FROM
			( SELECT dbo.fnCTConvertQuantityToTargetCommodityUOM(cd.intCommodityUnitMeasureId,@intCommodityUnitMeasureId,
										isnull((SELECT TOP 1 dblQty FROM tblICInventoryShipment sh
										 WHERE sh.strShipmentNumber=it.strTransactionId),0)) AS SlsBasisDeliveries  
		  FROM tblICInventoryTransaction it
		  join tblICInventoryShipment r on r.strShipmentNumber=it.strTransactionId  
		  INNER JOIN tblICInventoryShipmentItem ri ON r.intInventoryShipmentId = ri.intInventoryShipmentId  
		  INNER JOIN @tblGetOpenContractDetail cd ON cd.intContractDetailId = ri.intLineNo AND cd.intPricingTypeId = 2 AND cd.intContractTypeId = 2 and cd.intContractStatusId <> 3 
		  		  					AND  cd.intCompanyLocationId   IN (SELECT intCompanyLocationId FROM tblSMCompanyLocation
									WHERE isnull(ysnLicensed, 0) = CASE WHEN @strPositionIncludes = 'licensed storage' THEN 1 
									WHEN @strPositionIncludes = 'Non-licensed storage' THEN 0 
									ELSE isnull(ysnLicensed, 0) END
									)
		  WHERE cd.intCommodityId = c.intCommodityId AND 
		  cd.intCompanyLocationId= case when isnull(@intLocationId,0)=0 then   cd.intCompanyLocationId else @intLocationId end  
		  		and convert(DATETIME, CONVERT(VARCHAR(10), dtmDate, 110), 110)<=convert(datetime,@dtmToDate)
		  )t) as SlsBasisDeliveries 			
		FROM tblICCommodity c
		WHERE c.intCommodityId  = @intCommodityId
		) t
				
	INSERT INTO @tempFinal(strCommodityCode,strType,strContractType,dblTotal,intFromCommodityUnitMeasureId,intCommodityId,intNoOfContract)	
	SELECT @strDescription,'Price Risk' [strType],'Future'
		,dblTotal,
		@intCommodityUnitMeasureId,@intCommodityId,
		dblNoOfLot intNoOfContract
	FROM (		
		select strCommodityCode,strInternalTradeNo,intFutOptTransactionHeaderId,strType,strContractType,strLocationName,strContractEndMonth,dblTotal ,
							intFromCommodityUnitMeasureId,intCommodityId,strAccountNumber,strTranType,dblNoOfLot,dblDelta,intBrokerageAccountId,strInstrumentType
		from @tempFinal where  strType='Net Hedge')t

	
INSERT INTO @tempFinal(strCommodityCode,strType,strContractType,dblTotal,intFromCommodityUnitMeasureId,intCommodityId,strContractNumber,CompanyTitled,OpenPurQty,OpenSalQty)
SELECT @strDescription,
		'Basis Risk' [strType],'Physical'
		,isnull(CompanyTitled, 0) AS dblTotal,
		@intCommodityUnitMeasureId,@intCommodityId,null strContractNumber,isnull(CompanyTitled, 0) CompanyTitled,isnull(OpenPurchasesQty, 0) OpenPurchasesQty,-isnull(OpenSalesQty, 0)
	FROM (
              SELECT 
			   isnull(invQty, 0) 
			   + CASE WHEN (
                                  SELECT TOP 1 ysnIncludeOffsiteInventoryInCompanyTitled
                                  FROM tblRKCompanyPreference
                                  ) = 1 THEN isnull(OffSite, 0) ELSE 0 END + CASE WHEN (
                                  SELECT TOP 1 ysnIncludeDPPurchasesInCompanyTitled
                                  FROM tblRKCompanyPreference
                                  ) = 1 THEN 0 ELSE -isnull(DP ,0) END 
								   + isnull(dblCollatralSales, 0) 
								   + isnull(SlsBasisDeliveries, 0)
								   +(isnull(OpenPurchasesQty, 0) - isnull(OpenSalesQty, 0))
								    AS CompanyTitled

			,OpenPurchasesQty
			,OpenSalesQty,DP
		FROM (
				SELECT (SELECT sum(dblTotal) Qty from #invQty) AS invQty
				, ( SELECT Sum(dblTotal)
                           FROM (
                                  SELECT dbo.fnCTConvertQuantityToTargetCommodityUOM(s.intCommodityUnitMeasureId, @intCommodityUnitMeasureId, isnull(Balance, 0)) dblTotal,
								  intCompanyLocationId
                                  FROM @tblGetStorageDetailByDate s
                                  WHERE ysnCustomerStorage = 1 AND strOwnedPhysicalStock = 'Company' AND s.intCommodityId = @intCommodityId 
								  AND s.intCompanyLocationId = s.intCompanyLocationId 
                                  ) t WHERE intCompanyLocationId  IN (SELECT intCompanyLocationId FROM tblSMCompanyLocation
															WHERE isnull(ysnLicensed, 0) = CASE WHEN @strPositionIncludes = 'licensed storage' THEN 1 
															WHEN @strPositionIncludes = 'Non-licensed storage' THEN 0 
															ELSE isnull(ysnLicensed, 0) END
															))  AS OffSite
				,( select sum(dblBalance) dblBalance from (
					SELECT dbo.fnCTConvertQuantityToTargetCommodityUOM(cd.intCommodityUnitMeasureId,@intCommodityUnitMeasureId,isnull(cd.dblBalance,0)) dblBalance,
					intCompanyLocationId
					FROM @tblGetOpenContractDetail cd
					WHERE intContractTypeId = 1 and intPricingTypeId IN (1,2) AND cd.intCommodityId  = @intCommodityId 
					AND cd.intCompanyLocationId= case when isnull(@intLocationId,0)=0 then cd.intCompanyLocationId else @intLocationId end
					)t 	WHERE intCompanyLocationId   IN (SELECT intCompanyLocationId FROM tblSMCompanyLocation
									WHERE isnull(ysnLicensed, 0) = CASE WHEN @strPositionIncludes = 'licensed storage' THEN 1 
									WHEN @strPositionIncludes = 'Non-licensed storage' THEN 0 
									ELSE isnull(ysnLicensed, 0) END
									))  AS OpenPurchasesQty
				,( select sum(dblBalance) dblBalance from (
					SELECT dbo.fnCTConvertQuantityToTargetCommodityUOM(cd.intCommodityUnitMeasureId,@intCommodityUnitMeasureId,isnull(cd.dblBalance,0)) dblBalance,intCompanyLocationId
					FROM @tblGetOpenContractDetail cd
					WHERE intContractTypeId = 2 and intPricingTypeId IN (1,2) AND cd.intCommodityId  = @intCommodityId 
					AND cd.intCompanyLocationId= case when isnull(@intLocationId,0)=0 then cd.intCompanyLocationId else @intLocationId end
	
					)t WHERE intCompanyLocationId   IN (SELECT intCompanyLocationId FROM tblSMCompanyLocation
									WHERE isnull(ysnLicensed, 0) = CASE WHEN @strPositionIncludes = 'licensed storage' THEN 1 
									WHEN @strPositionIncludes = 'Non-licensed storage' THEN 0 
									ELSE isnull(ysnLicensed, 0) END
									))  AS OpenSalesQty
				,(select sum(dblTotal) dblTotal from (
					SELECT 
					dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId,@intCommodityUnitMeasureId,(isnull(Balance,0))) dblTotal
					,ch.intCompanyLocationId
					FROM @tblGetStorageDetailByDate ch
					WHERE ch.intCommodityId  = @intCommodityId	AND ysnDPOwnedType = 1
						AND ch.intCompanyLocationId= case when isnull(@intLocationId,0)=0 then ch.intCompanyLocationId else @intLocationId end
					)t 	WHERE intCompanyLocationId  IN (
				SELECT intCompanyLocationId FROM tblSMCompanyLocation
				WHERE isnull(ysnLicensed, 0) = CASE WHEN @strPositionIncludes = 'licensed storage' THEN 1 
								WHEN @strPositionIncludes = 'Non-licensed storage' THEN 0 
								ELSE isnull(ysnLicensed, 0) END
				) ) AS DP
			,(SELECT sum(SlsBasisDeliveries) FROM
						( SELECT dbo.fnCTConvertQuantityToTargetCommodityUOM(cd.intCommodityUnitMeasureId,@intCommodityUnitMeasureId,isnull((ri.dblQuantity),0)) AS SlsBasisDeliveries  
					  FROM tblICInventoryShipment r  
					  INNER JOIN tblICInventoryShipmentItem ri ON r.intInventoryShipmentId = ri.intInventoryShipmentId  
					  INNER JOIN @tblGetOpenContractDetail cd ON cd.intContractDetailId = ri.intLineNo AND cd.intPricingTypeId = 2 AND cd.intContractTypeId = 2 and cd.intContractStatusId <> 3 
		  		  								AND  cd.intCompanyLocationId   IN (SELECT intCompanyLocationId FROM tblSMCompanyLocation
												WHERE isnull(ysnLicensed, 0) = CASE WHEN @strPositionIncludes = 'licensed storage' THEN 1 
												WHEN @strPositionIncludes = 'Non-licensed storage' THEN 0 
												ELSE isnull(ysnLicensed, 0) END
												)
					  WHERE cd.intCommodityId = c.intCommodityId AND 
					  cd.intCompanyLocationId= case when isnull(@intLocationId,0)=0 then   cd.intCompanyLocationId else @intLocationId end  
					  )t) as SlsBasisDeliveries 
		,          isnull((SELECT SUM(dblRemainingQuantity) CollateralSale
                     FROM ( 
                     SELECT 
                     case when strType = 'Purchase' then 
						 dbo.fnCTConvertQuantityToTargetCommodityUOM(ium.intCommodityUnitMeasureId,@intCommodityUnitMeasureId,isnull(dblRemainingQuantity,0)) else
                     -dbo.fnCTConvertQuantityToTargetCommodityUOM(ium.intCommodityUnitMeasureId,@intCommodityUnitMeasureId,isnull(dblRemainingQuantity,0)) end dblRemainingQuantity,
                                  intContractHeaderId,c1.intLocationId                             
                                  FROM tblRKCollateral c1                                                            
                                  JOIN tblICCommodityUnitMeasure ium on ium.intCommodityId=c1.intCommodityId AND c1.intUnitMeasureId=ium.intUnitMeasureId 
                                  WHERE c1.intCommodityId = c.intCommodityId 
                                  AND c1.intLocationId= case when isnull(@intLocationId,0)=0 then c1.intLocationId else @intLocationId end) t  
								  WHERE intLocationId  IN (
										SELECT intCompanyLocationId FROM tblSMCompanyLocation
										WHERE isnull(ysnLicensed, 0) = CASE WHEN @strPositionIncludes = 'licensed storage' THEN 1 
										WHEN @strPositionIncludes = 'Non-licensed storage' THEN 0 
										ELSE isnull(ysnLicensed, 0) END				)   
                     ), 0) AS dblCollatralSales 
             
				
			FROM tblICCommodity c
			WHERE c.intCommodityId  = @intCommodityId
			) t
		) t1

				
	INSERT INTO @tempFinal (strCommodityCode,strType,dblTotal,intContractHeaderId,strContractNumber,strLocationName,strTicketNumber,dtmTicketDateTime,
					strDistributionOption,dblUnitCost,dblQtyReceived,intCommodityId,strCurrency)
	SELECT @strDescription, 'Net Payable  ($)' [strType],dblTotal dblTotal,
		intContractHeaderId,strContractNumber,strLocationName,strTicketNumber,dtmTicketDateTime,strDistributionOption,dblUnitCost1,
		dblQtyReceived,intCommodityId,strCurrency
	 FROM(	
		SELECT DISTINCT 		
				strLocationName
				,tr.strTicketNumber
				,tr.dtmTicketDateTime
				,strDistributionOption
				,dblCost dblUnitCost
				,sum(tr.dblQtyReceived) over (partition by tr.intBillId) dblQtyReceived
				,sum(dblTotal) over (partition by tr.intBillId) dblTotal
				,tr.dblCost
				,dblAmountDue
				,dblCost dblUnitCost1
				,c.intCommodityId, NULL as intContractHeaderId, NULL as strContractNumber,tr.strCurrency
				FROM tblAPVoucherHistory tr
				LEFT JOIN tblSCTicket t on tr.strTicketNumber=t.strTicketNumber
				join tblICCommodity c on tr.strCommodity=c.strCommodityCode
				join tblSMCompanyLocation cl on cl.strLocationName=tr.strLocation
				WHERE 
				c.intCommodityId = @intCommodityId  and
				cl.intCompanyLocationId = CASE WHEN ISNULL(@intLocationId,0)=0 then cl.intCompanyLocationId else @intLocationId end
				and convert(DATETIME, CONVERT(VARCHAR(10), dtmTransactionDate, 110), 110) <= convert(datetime,@dtmToDate) 			
			)t 
						
	INSERT INTO @tempFinal (strCommodityCode,strType,dblTotal,strLocationName,intContractHeaderId,strContractNumber,strTicketNumber,
		dtmTicketDateTime,strCustomerReference,strDistributionOption,dblUnitCost,dblQtyReceived,intCommodityId,strCurrency)
	SELECT @strDescription, 'Net Receivable  ($)' [strType],dblUnitCost AS dblTotal,strLocationName,
			intContractHeaderId,'' strContractNumber
			,strTicketNumber
			, dtmTicketDate dtmTicketDateTime
			,strCustomerReference
			,strDistributionOption, dblUCost
			,dblQtyReceived,@intCommodityId,strCurrency	
		FROM (
		select * FROM (
			SELECT DISTINCT ROW_NUMBER() OVER (PARTITION BY c.intTicketId ORDER BY dtmTransactionDate DESC) intRowNum, 
				strLocationName
				,strInvoiceNumber
				,dtmTicketDate
				,c.intTicketId intContractHeaderId
				,s.strTicketNumber strTicketNumber	
				,dblPrice dblUCost
				,dblAmountDue AS dblUnitCost
				,dblQtyReceived
				,c.intCommodityId,c.strCurrency,strCustomerReference,strDistributionOption,ysnPost
			FROM vyuARInvoiceTransactionHistory c		
			LEFT JOIN tblSCTicket s on s.intTicketId=c.intTicketId
			WHERE c.intCommodityId = @intCommodityId
				AND intCompanyLocationId= case when isnull(@intLocationId,0)=0 then intCompanyLocationId else @intLocationId end	
				 and convert(DATETIME, CONVERT(VARCHAR(10), dtmTransactionDate, 110), 110) <= convert(datetime,@dtmToDate) 
				
			) a WHERE a.intRowNum = 1) b  where isnull(ysnPost,0) =1
			
	INSERT INTO @tempFinal (strCommodityCode,strType,dblTotal,intContractHeaderId,strContractNumber,strLocationName,strTicketNumber,dtmTicketDateTime,
					strCustomerReference,strDistributionOption,dblUnitCost,dblQtyReceived,intCommodityId,strContractType)

	select strCommodityCode,'NP Un-Paid Quantity' strType,dblTotal/case when isnull(dblUnitCost,0)=0 then 1 else dblUnitCost end,intContractHeaderId,strContractNumber,strLocationName,strTicketNumber,dtmTicketDateTime,
					strCustomerReference,strDistributionOption,dblUnitCost,dblQtyReceived,intCommodityId,strContractType
					 FROM @tempFinal where strType='Net Payable  ($)' and intCommodityId=@intCommodityId


	INSERT INTO @tempFinal (strCommodityCode,strType,dblTotal,intInventoryReceiptItemId,strLocationName,intContractHeaderId,strContractNumber,strTicketNumber,dtmTicketDateTime,
	strCustomerReference,strDistributionOption,dblUnitCost,dblQtyReceived,intCommodityId,strContractType)
	select @strDescription,'NR Un-Paid Quantity' strType,dblTotal/case when isnull(dblUnitCost,0)=0 then 1 else dblUnitCost end,intInventoryReceiptItemId,strLocationName,intContractHeaderId,strContractNumber,strTicketNumber,dtmTicketDateTime,
	strCustomerReference,strDistributionOption,dblUnitCost,dblQtyReceived,intCommodityId,strContractType from @tempFinal where strType= 'Net Receivable  ($)' and intCommodityId=@intCommodityId

	INSERT INTO @tempFinal(strCommodityCode,strType,dblTotal,intFromCommodityUnitMeasureId,intCommodityId)
	SELECT @strDescription
		,'Avail for Spot Sale' [strType],sum(dblTotal)-sum(dblPurQty),@intCommodityUnitMeasureId,@intCommodityId from(
		select dblTotal,
		(SELECT sum(Qty) FROM (
					SELECT dbo.fnCTConvertQuantityToTargetCommodityUOM(CD.intCommodityUnitMeasureId,@intCommodityUnitMeasureId,isnull((CD.dblBalance),0)) as Qty ,CD.intCompanyLocationId                 
					FROM @tblGetOpenContractDetail  CD  
					WHERE  intContractTypeId=1 and intPricingTypeId in(1,2) and CD.intCommodityId=@intCommodityId
					 and CD.intCompanyLocationId = case when isnull(@intLocationId,0)=0 then CD.intCompanyLocationId else @intLocationId end 
				)t 	WHERE intCompanyLocationId IN (SELECT intCompanyLocationId FROM tblSMCompanyLocation
								WHERE isnull(ysnLicensed, 0) = CASE WHEN @strPositionIncludes = 'licensed storage' THEN 1 
								WHEN @strPositionIncludes = 'Non-licensed storage' THEN 0 
								ELSE isnull(ysnLicensed, 0) END)			
				) dblPurQty
		
	  FROM @tempFinal t where strType='Basis Risk' and t.intCommodityId=@intCommodityId)t			

	select @intUnitMeasureId =null
	select @strUnitMeasure =null
	SELECT TOP 1 @intUnitMeasureId = intUnitMeasureId FROM tblRKCompanyPreference
	SELECT @strUnitMeasure=strUnitMeasure from tblICUnitMeasure where intUnitMeasureId=@intUnitMeasureId
	INSERT INTO @Final (strCommodityCode ,intContractHeaderId,strContractNumber,intFutOptTransactionHeaderId,strInternalTradeNo, strType,strContractType,strContractEndMonth, 
		dblTotal,strUnitMeasure,intInventoryReceiptItemId,strLocationName,strTicketNumber,dtmTicketDateTime,strCustomerReference,strDistributionOption,dblUnitCost,dblQtyReceived,strAccountNumber,strTranType,dblNoOfLot,dblDelta,intBrokerageAccountId,strInstrumentType 
		,invQty,PurBasisDelivary,OpenPurQty,OpenSalQty,dblCollatralSales, SlsBasisDeliveries,intNoOfContract,dblContractSize,CompanyTitled,strCurrency)

	SELECT strCommodityCode ,intContractHeaderId,strContractNumber,intFutOptTransactionHeaderId,strInternalTradeNo, strType,strContractType,strContractEndMonth, 	
	    case when (isnull(@intUnitMeasureId, 0) = 0 OR cuc.intCommodityUnitMeasureId = @intUnitMeasureId) then dblTotal else
		Convert(decimal(24,10),dbo.fnCTConvertQuantityToTargetCommodityUOM(cuc.intCommodityUnitMeasureId,cuc1.intCommodityUnitMeasureId ,dblTotal)) end dblTotal,
		case when isnull(@strUnitMeasure,'')='' then um.strUnitMeasure else @strUnitMeasure end as strUnitMeasure,intInventoryReceiptItemId,strLocationName,strTicketNumber,dtmTicketDateTime,strCustomerReference,strDistributionOption,dblUnitCost,dblQtyReceived,
		strAccountNumber,strTranType,dblNoOfLot,dblDelta,intBrokerageAccountId,strInstrumentType		,
		case when (isnull(@intUnitMeasureId, 0) = 0 OR cuc.intCommodityUnitMeasureId = @intUnitMeasureId) then invQty else
		Convert(decimal(24,10),dbo.fnCTConvertQuantityToTargetCommodityUOM(cuc.intCommodityUnitMeasureId,cuc1.intCommodityUnitMeasureId ,invQty)) end invQty,
		case when (isnull(@intUnitMeasureId, 0) = 0 OR cuc.intCommodityUnitMeasureId = @intUnitMeasureId) then PurBasisDelivary else
		Convert(decimal(24,10),dbo.fnCTConvertQuantityToTargetCommodityUOM(cuc.intCommodityUnitMeasureId, cuc1.intCommodityUnitMeasureId ,PurBasisDelivary)) end PurBasisDelivary,
		case when (isnull(@intUnitMeasureId, 0) = 0 OR cuc.intCommodityUnitMeasureId = @intUnitMeasureId) then OpenPurQty else
		Convert(decimal(24,10),dbo.fnCTConvertQuantityToTargetCommodityUOM(cuc.intCommodityUnitMeasureId,cuc1.intCommodityUnitMeasureId ,OpenPurQty)) end OpenPurQty,
		case when (isnull(@intUnitMeasureId, 0) = 0 OR cuc.intCommodityUnitMeasureId = @intUnitMeasureId) then OpenSalQty else
		Convert(decimal(24,10),dbo.fnCTConvertQuantityToTargetCommodityUOM(cuc.intCommodityUnitMeasureId, cuc1.intCommodityUnitMeasureId ,OpenSalQty)) end OpenSalQty,
		 case when (isnull(@intUnitMeasureId, 0) = 0 OR cuc.intCommodityUnitMeasureId = @intUnitMeasureId) then dblCollatralSales else
		Convert(decimal(24,10),dbo.fnCTConvertQuantityToTargetCommodityUOM(cuc.intCommodityUnitMeasureId,cuc1.intCommodityUnitMeasureId ,dblCollatralSales)) end dblCollatralSales,
		 case when (isnull(@intUnitMeasureId, 0) = 0 OR cuc.intCommodityUnitMeasureId = @intUnitMeasureId) then SlsBasisDeliveries else
		Convert(decimal(24,10),dbo.fnCTConvertQuantityToTargetCommodityUOM(cuc.intCommodityUnitMeasureId,cuc1.intCommodityUnitMeasureId ,SlsBasisDeliveries)) end SlsBasisDeliveries
		,intNoOfContract,dblContractSize,
		case when (isnull(@intUnitMeasureId, 0) = 0 OR cuc.intCommodityUnitMeasureId = @intUnitMeasureId) then CompanyTitled else
		Convert(decimal(24,10),dbo.fnCTConvertQuantityToTargetCommodityUOM(cuc.intCommodityUnitMeasureId, cuc1.intCommodityUnitMeasureId ,CompanyTitled)) end CompanyTitled
		,strCurrency  
	FROM @tempFinal t
	JOIN tblICCommodityUnitMeasure cuc on t.intCommodityId=cuc.intCommodityId and cuc.ysnDefault=1 
	JOIN tblICUnitMeasure um on um.intUnitMeasureId=cuc.intUnitMeasureId
	LEFT JOIN tblICCommodityUnitMeasure cuc1 on t.intCommodityId=cuc1.intCommodityId and @intUnitMeasureId=cuc1.intUnitMeasureId
	WHERE t.intCommodityId= @intCommodityId  and strType not in('Net Payable  ($)','Net Receivable  ($)')
	UNION
	SELECT strCommodityCode ,intContractHeaderId,strContractNumber,intFutOptTransactionHeaderId,strInternalTradeNo, strType,strContractType,strContractEndMonth, 	
	    dblTotal dblTotal,
		case when isnull(@strUnitMeasure,'')='' then um.strUnitMeasure else @strUnitMeasure end as strUnitMeasure,intInventoryReceiptItemId,strLocationName,strTicketNumber,dtmTicketDateTime,strCustomerReference,strDistributionOption,dblUnitCost,dblQtyReceived,strAccountNumber,strTranType,dblNoOfLot,dblDelta,intBrokerageAccountId,strInstrumentType  
		,invQty,PurBasisDelivary,OpenPurQty,OpenSalQty,dblCollatralSales, SlsBasisDeliveries,intNoOfContract,dblContractSize,CompanyTitled,strCurrency
	FROM @tempFinal t
	JOIN tblICCommodityUnitMeasure cuc on t.intCommodityId=cuc.intCommodityId and cuc.ysnDefault=1 
	JOIN tblICUnitMeasure um on um.intUnitMeasureId=cuc.intUnitMeasureId
	WHERE t.intCommodityId= @intCommodityId and strType in( 'Net Payable  ($)','Net Receivable  ($)')

END
ELSE
BEGIN
	INSERT INTO @tempFinal (strCommodityCode,intContractHeaderId,strContractNumber,strType,strSubType,strContractType,strLocationName,strContractEndMonth,dblTotal,intFromCommodityUnitMeasureId,intCommodityId,intCompanyLocationId)
	SELECT * FROM (
	SELECT strCommodityCode,intContractHeaderId,
	 strContractNumber
		,strContractType+ ' ' + strPricingType [strType],strContractType+ ' ' + strPricingType strSubType,'Physical' strContractType
		,strLocationName,
		RIGHT(CONVERT(VARCHAR(11),dtmEndDate,106),8) strContractEndMonth,
		dbo.fnCTConvertQuantityToTargetCommodityUOM(CD.intCommodityUnitMeasureId,@intCommodityUnitMeasureId,isnull((CD.dblBalance),0)) AS dblTotal
		,CD.intUnitMeasureId,@intCommodityId as intCommodityId,intCompanyLocationId
	FROM @tblGetOpenContractDetail CD
	WHERE intContractTypeId in(1,2) AND intPricingTypeId IN (1,2,3) and CD.intCommodityId in (SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCommodityId, ','))
	AND intCompanyLocationId= case when isnull(@intLocationId,0)=0 then intCompanyLocationId else @intLocationId end
	AND intEntityId= @intVendorId) t 
	WHERE intCompanyLocationId IN (SELECT intCompanyLocationId FROM tblSMCompanyLocation
								WHERE isnull(ysnLicensed, 0) = CASE WHEN @strPositionIncludes = 'licensed storage' THEN 1 
								WHEN @strPositionIncludes = 'Non-licensed storage' THEN 0 
								ELSE isnull(ysnLicensed, 0) END)
	
	INSERT INTO @tempFinal (strCommodityCode,strType,strSubType,dblTotal,intContractHeaderId,strContractNumber,strLocationName,strTicketNumber,dtmTicketDateTime,
					strCustomerReference,strDistributionOption,dblUnitCost,dblQtyReceived,intCommodityId)
	SELECT  @strDescription, 'Quantity Purchase' [strType],'Quantity Purchase',isnull(dblOpenReceive,0) dblTotal,
			cd.intContractHeaderId, strContractNumber,
					cl.strLocationName
				,r.strReceiptNumber strTicketNumber
				,r.dtmReceiptDate dtmTicketDateTime
				,r.strVendorRefNo as strCustomerReference
				,'Purchase Contract' as strDistributionOption
				,dblUnitCost AS dblUnitCost
				,isnull(dblUnitCost,0)*isnull(dblOpenReceive,0) AS dblQtyReceived
				,cd.intCommodityId
	FROM tblICInventoryTransaction it
	JOIN tblICInventoryReceipt r on r.strReceiptNumber=it.strTransactionId
	INNER JOIN tblICInventoryReceiptItem ri ON r.intInventoryReceiptId = ri.intInventoryReceiptId AND r.strReceiptType in('Purchase Contract')
	INNER JOIN @tblGetOpenContractDetail cd ON  cd.intContractHeaderId = ri.intOrderId AND cd.intContractDetailId=ri.intLineNo AND cd.intPricingTypeId = 1 and cd.intContractStatusId <> 3
	INNER JOIN tblSMCompanyLocation cl ON cl.intCompanyLocationId = r.intLocationId
								AND r.intLocationId IN (SELECT intCompanyLocationId FROM tblSMCompanyLocation
								WHERE isnull(ysnLicensed, 0) = CASE WHEN @strPositionIncludes = 'licensed storage' THEN 1 
								WHEN @strPositionIncludes = 'Non-licensed storage' THEN 0 
								ELSE isnull(ysnLicensed, 0) END)
	WHERE cd.intCommodityId = @intCommodityId and cd.intEntityId=@intVendorId 
	AND r.intLocationId = CASE WHEN ISNULL(@intLocationId,0)=0 then r.intLocationId else @intLocationId end
			and convert(DATETIME, CONVERT(VARCHAR(10), dtmDate, 110), 110)<=convert(datetime,@dtmToDate)

	UNION

	SELECT @strDescription, 'Quantity Purchase' [strType], 'Quantity Purchase',isnull(dblOpenReceive,0) dblTotal
				,null as intContractHeaderId, null as strContractNumber
				,cl.strLocationName
				,r.strReceiptNumber strTicketNumber
				,r.dtmReceiptDate dtmTicketDateTime
				,r.strVendorRefNo as strCustomerReference
				,'Direct' as strDistributionOption
				,dblUnitCost AS dblUnitCost
				,isnull(dblUnitCost,0)*isnull(dblOpenReceive,0) AS dblQtyReceived
				,i.intCommodityId			
	FROM tblICInventoryTransaction it
	JOIN tblICInventoryReceipt r on r.strReceiptNumber=it.strTransactionId
	INNER JOIN tblICInventoryReceiptItem ri ON r.intInventoryReceiptId = ri.intInventoryReceiptId AND r.strReceiptType in('Direct') 
	AND r.intSourceType=1 and isnull(dblUnitCost,0) <> 0 
	INNER JOIN tblICItem i on ri.intItemId=i.intItemId 
								AND r.intLocationId IN (SELECT intCompanyLocationId FROM tblSMCompanyLocation
								WHERE isnull(ysnLicensed, 0) = CASE WHEN @strPositionIncludes = 'licensed storage' THEN 1 
								WHEN @strPositionIncludes = 'Non-licensed storage' THEN 0 
								ELSE isnull(ysnLicensed, 0) END)
	INNER JOIN tblSMCompanyLocation cl ON cl.intCompanyLocationId = r.intLocationId
	WHERE i.intCommodityId = @intCommodityId AND r.intEntityVendorId =@intVendorId
	AND r.intLocationId = CASE WHEN ISNULL(@intLocationId,0)=0 then r.intLocationId else @intLocationId end	
			and convert(DATETIME, CONVERT(VARCHAR(10), dtmDate, 110), 110)<=convert(datetime,@dtmToDate)
	
	INSERT INTO @tempFinal (strCommodityCode,strType,strSubType,dblTotal,intContractHeaderId,strContractNumber,strLocationName,strTicketNumber,dtmTicketDateTime,
					strCustomerReference,strDistributionOption,dblUnitCost,dblQtyReceived,intCommodityId)
SELECT	@strDescription, 'Quantity Sales' [strType], 'Quantity Sales',isnull(dblQuantity,0) dblTotal,
		cd.intContractHeaderId,strContractNumber
			,cd.strLocationName
			,s.strShipmentNumber strTicketNumber
			,s.dtmShipDate dtmTicketDateTime
			,s.strReferenceNumber as strCustomerReference
			,'Spot Sale' as strDistributionOption
			,dblUnitPrice AS dblUnitCost
			,ISNULL(dblQuantity,0)*ISNULL(dblUnitPrice,0) AS dblQtyReceived
			,cd.intCommodityId
		FROM tblICInventoryTransaction it
		  join tblICInventoryShipment s on s.strShipmentNumber=it.strTransactionId 
		join tblICInventoryShipmentItem si on s.intInventoryShipmentId=si.intInventoryShipmentId and intOrderType =4 and isnull(dblUnitPrice,0) <>0
		JOIN @tblGetOpenContractDetail cd on cd.intContractDetailId=si.intLineNo 	
								AND cd.intCompanyLocationId IN (SELECT intCompanyLocationId FROM tblSMCompanyLocation
								WHERE isnull(ysnLicensed, 0) = CASE WHEN @strPositionIncludes = 'licensed storage' THEN 1 
								WHEN @strPositionIncludes = 'Non-licensed storage' THEN 0 
								ELSE isnull(ysnLicensed, 0) END)
		join tblICItem i on si.intItemId=i.intItemId  WHERE i.intCommodityId=@intCommodityId and s.intEntityCustomerId=@intVendorId
		AND cd.intCompanyLocationId = CASE WHEN ISNULL(@intLocationId,0)=0 then cd.intCompanyLocationId else @intLocationId end
		and convert(DATETIME, CONVERT(VARCHAR(10), dtmDate, 110), 110)<=convert(datetime,@dtmToDate)
	UNION
		SELECT @strDescription, 'Quantity Sales' [strType],'Quantity Sales',ISNULL(dblQuantity,0) dblTotal
			,cd.intContractHeaderId, strContractNumber
			,cd.strLocationName
			,s.strShipmentNumber strTicketNumber
			,s.dtmShipDate dtmTicketDateTime
			,s.strReferenceNumber as strCustomerReference
			,'Sales Contract' as strDistributionOption
			,dblUnitPrice AS dblUnitCost
			,isnull(dblQuantity,0)*ISNULL(dblUnitPrice,0) AS dblQtyReceived
			,cd.intCommodityId
		from tblICInventoryTransaction it
		  join tblICInventoryShipment s on s.strShipmentNumber=it.strTransactionId 
		JOIN tblICInventoryShipmentItem si on s.intInventoryShipmentId=si.intInventoryShipmentId 
		JOIN @tblGetOpenContractDetail cd on cd.intContractDetailId=si.intLineNo and cd.intContractTypeId=2  
										AND cd.intCompanyLocationId IN (SELECT intCompanyLocationId FROM tblSMCompanyLocation
								WHERE isnull(ysnLicensed, 0) = CASE WHEN @strPositionIncludes = 'licensed storage' THEN 1 
								WHEN @strPositionIncludes = 'Non-licensed storage' THEN 0 
								ELSE isnull(ysnLicensed, 0) END)
		AND cd.intCommodityId=@intCommodityId and cd.intEntityId=@intVendorId 
		AND cd.intCompanyLocationId = CASE WHEN ISNULL(@intLocationId,0)=0 then cd.intCompanyLocationId else @intLocationId end
		and convert(DATETIME, CONVERT(VARCHAR(10), dtmDate, 110), 110)<=convert(datetime,@dtmToDate)	
	
	INSERT INTO @tempFinal (strCommodityCode,strType,strSubType,dblTotal,intContractHeaderId,strContractNumber,strLocationName,strTicketNumber,dtmTicketDateTime,
					strCustomerReference,strDistributionOption,dblUnitCost,dblQtyReceived,intCommodityId,strCurrency)
	SELECT  @strDescription, 'Purchase Gross Dollars' [strType], 'Purchase Gross Dollars',isnull(dblOpenReceive,0)*isnull(dblUnitCost,0) dblTotal,
			cd.intContractHeaderId,strContractNumber
			,cl.strLocationName
			,r.strReceiptNumber strTicketNumber
			,r.dtmReceiptDate dtmTicketDateTime
			,r.strVendorRefNo as strCustomerReference
			,'Purchase Contract' as strDistributionOption
			,dblUnitCost AS dblUnitCost
			,isnull(dblOpenReceive,0) AS dblQtyReceived
			,cd.intCommodityId,cur.strCurrency			
		FROM tblICInventoryTransaction it
		JOIN tblICInventoryReceipt r on r.strReceiptNumber=it.strTransactionId
		INNER JOIN tblICInventoryReceiptItem ri ON r.intInventoryReceiptId = ri.intInventoryReceiptId AND r.strReceiptType in('Purchase Contract')
		INNER JOIN @tblGetOpenContractDetail cd ON  cd.intContractHeaderId = ri.intOrderId AND cd.intContractDetailId=intLineNo AND cd.intPricingTypeId = 1 and cd.intContractStatusId <> 3
		INNER JOIN tblSMCurrency cur on cur.intCurrencyID=cd.intCurrencyId 
								AND r.intLocationId IN (SELECT intCompanyLocationId FROM tblSMCompanyLocation
								WHERE isnull(ysnLicensed, 0) = CASE WHEN @strPositionIncludes = 'licensed storage' THEN 1 
								WHEN @strPositionIncludes = 'Non-licensed storage' THEN 0 
								ELSE isnull(ysnLicensed, 0) END)
		INNER JOIN tblSMCompanyLocation cl ON cl.intCompanyLocationId = r.intLocationId
		WHERE cd.intCommodityId = @intCommodityId and cd.intEntityId=@intVendorId 
		AND r.intLocationId = CASE WHEN ISNULL(@intLocationId,0)=0 then r.intLocationId else @intLocationId end
		AND CONVERT(DATETIME, CONVERT(VARCHAR(10), dtmDate, 110), 110)<=CONVERT(DATETIME,@dtmToDate)	

		UNION

		SELECT	@strDescription, 'Purchase Gross Dollars' [strType], 'Purchase Gross Dollars',isnull(dblOpenReceive,0)*isnull(dblUnitCost,0) dblTotal,
					null as intContractHeaderId, null as strContractNumber
					,cl.strLocationName
					,r.strReceiptNumber strTicketNumber
					,r.dtmReceiptDate dtmTicketDateTime
					,r.strVendorRefNo as strCustomerReference
					,'Direct' as strDistributionOption
					,dblUnitCost AS dblUnitCost
					,isnull(dblOpenReceive,0) AS dblQtyReceived
					,intCommodityId,cur.strCurrency
		FROM tblICInventoryTransaction it
		JOIN tblICInventoryReceipt r on r.strReceiptNumber=it.strTransactionId
		INNER JOIN tblICInventoryReceiptItem ri ON r.intInventoryReceiptId = ri.intInventoryReceiptId AND r.strReceiptType in('Direct') 
		AND r.intSourceType=1 and isnull(dblUnitCost,0) <> 0 
		INNER JOIN tblICItem i on ri.intItemId=i.intItemId
		INNER JOIN tblSMCompanyLocation cl ON cl.intCompanyLocationId = r.intLocationId 
								AND r.intLocationId IN (SELECT intCompanyLocationId FROM tblSMCompanyLocation
								WHERE isnull(ysnLicensed, 0) = CASE WHEN @strPositionIncludes = 'licensed storage' THEN 1 
								WHEN @strPositionIncludes = 'Non-licensed storage' THEN 0 
								ELSE isnull(ysnLicensed, 0) END)
		INNER JOIN tblSMCurrency cur on cur.intCurrencyID=r.intCurrencyId
		WHERE i.intCommodityId = @intCommodityId AND r.intEntityVendorId =@intVendorId
		AND r.intLocationId = CASE WHEN ISNULL(@intLocationId,0)=0 then r.intLocationId else @intLocationId end		
		AND CONVERT(DATETIME, CONVERT(VARCHAR(10), dtmDate, 110), 110)<=CONVERT(DATETIME,@dtmToDate)	

    INSERT INTO @tempFinal (strCommodityCode,strType,strSubType,dblTotal,intContractHeaderId,strContractNumber,strLocationName,strTicketNumber,dtmTicketDateTime,
					strCustomerReference,strDistributionOption,dblUnitCost,dblQtyReceived,intCommodityId,strCurrency)
	SELECT @strDescription, 'Sales Gross Dollars' [strType], 'Sales Gross Dollars',ISNULL(dblQuantity,0) dblTotal,
			cd.intContractHeaderId, cd.strContractNumber
			,cd.strLocationName
			,s.strShipmentNumber strTicketNumber
			,s.dtmShipDate dtmTicketDateTime
			,s.strReferenceNumber as strCustomerReference
			,'Purchase Contract' as strDistributionOption			
			,dblUnitPrice AS dblUnitCost
			,ISNULL(dblQuantity,0)*ISNULL(dblUnitPrice,0) AS dblQtyReceived
			,cd.intCommodityId,cur.strCurrency
		FROM tblICInventoryTransaction it
		  join tblICInventoryShipment s on s.strShipmentNumber=it.strTransactionId 
		JOIN tblICInventoryShipmentItem si on s.intInventoryShipmentId=si.intInventoryShipmentId and intOrderType =4 and isnull(dblUnitPrice,0) <>0
		JOIN tblICItem i on si.intItemId=i.intItemId 
		JOIN @tblGetOpenContractDetail cd on cd.intContractDetailId=si.intLineNo 
							AND cd.intCompanyLocationId IN (SELECT intCompanyLocationId FROM tblSMCompanyLocation
								WHERE isnull(ysnLicensed, 0) = CASE WHEN @strPositionIncludes = 'licensed storage' THEN 1 
								WHEN @strPositionIncludes = 'Non-licensed storage' THEN 0 
								ELSE isnull(ysnLicensed, 0) END)
		INNER JOIN tblSMCurrency cur on cur.intCurrencyID=cd.intCurrencyId
		WHERE i.intCommodityId=@intCommodityId and cd.intEntityId=@intVendorId  
		AND cd.intCompanyLocationId = CASE WHEN ISNULL(@intLocationId,0)=0 then cd.intCompanyLocationId else @intLocationId end
		AND CONVERT(DATETIME, CONVERT(VARCHAR(10), dtmDate, 110), 110)<=CONVERT(DATETIME,@dtmToDate)	
		UNION
		SELECT @strDescription, 'Sales Gross Dollars' [strType], 'Sales Gross Dollars',ISNULL(dblQuantity,0)*ISNULL(dblUnitPrice,0) dblTotal,
			cd.intContractHeaderId, cd.strContractNumber
			,cd.strLocationName
			,s.strShipmentNumber strTicketNumber
			,s.dtmShipDate dtmTicketDateTime
			,s.strReferenceNumber as strCustomerReference
			,'Direct' as strDistributionOption
			,dblUnitPrice AS dblUnitCost
			,ISNULL(dblQuantity,0) AS dblQtyReceived
			,cd.intCommodityId,cur.strCurrency
		FROM tblICInventoryTransaction it
		  join tblICInventoryShipment s on s.strShipmentNumber=it.strTransactionId
		JOIN tblICInventoryShipmentItem si ON s.intInventoryShipmentId=si.intInventoryShipmentId 
		JOIN @tblGetOpenContractDetail cd ON cd.intContractDetailId=si.intLineNo and cd.intContractTypeId=2 
									AND cd.intCompanyLocationId IN (SELECT intCompanyLocationId FROM tblSMCompanyLocation
								WHERE isnull(ysnLicensed, 0) = CASE WHEN @strPositionIncludes = 'licensed storage' THEN 1 
								WHEN @strPositionIncludes = 'Non-licensed storage' THEN 0 
								ELSE isnull(ysnLicensed, 0) END)  
		INNER JOIN tblSMCurrency cur on cur.intCurrencyID=cd.intCurrencyId
		AND cd.intCommodityId=@intCommodityId AND cd.intEntityId=@intVendorId 
		AND cd.intCompanyLocationId = CASE WHEN ISNULL(@intLocationId,0)=0 then cd.intCompanyLocationId else @intLocationId end	
		AND CONVERT(DATETIME, CONVERT(VARCHAR(10), dtmDate, 110), 110)<=CONVERT(DATETIME,@dtmToDate)	

	INSERT INTO @tempFinal (strCommodityCode,strType,strSubType,dblTotal,intContractHeaderId,strContractNumber,strLocationName,strTicketNumber,dtmTicketDateTime,
					strCustomerReference,strDistributionOption,dblUnitCost,dblQtyReceived,intCommodityId,strCurrency)
	SELECT @strDescription, 'Net Receivable  ($)' [strType],'Sale Net Receivable  ($)',isnull(dblUnitCost,0)-isnull(dblQtyReceived,0) AS dblTotal,
			intContractHeaderId,strContractNumber,strLocationName
			,strTicketNumber
			,dtmTicketDateTime
			,strCustomerReference
			,strDistributionOption, dblUcost
			,dblQtyReceived,@intCommodityId,strCurrency			
		FROM (
			SELECT DISTINCT isi.intInventoryShipmentItemId AS intInventoryReceiptItemId
				,cl.strLocationName
				,st.strTicketNumber
				,st.dtmTicketDateTime
				,strCustomerReference
				,'Contract' strDistributionOption
				,cd.intContractHeaderId
				,cd.strContractNumber
				,isi.dblUnitPrice dblUcost
				,isi.dblQuantity * isi.dblUnitPrice AS dblUnitCost
				,R.dblPayment as dblQtyReceived
				,st.intCommodityId,cd.intUnitMeasureId,cur.strCurrency
			FROM  tblICInventoryTransaction it
			join tblICInventoryShipment ici on ici.strShipmentNumber=it.strTransactionId 
			INNER JOIN tblICInventoryShipmentItem isi ON isi.intInventoryShipmentId = ici.intInventoryShipmentId
			INNER JOIN tblSCTicket st ON st.intTicketId = isi.intSourceId AND strDistributionOption IN ('CNT')
			INNER JOIN @tblGetOpenContractDetail cd ON  cd.intContractHeaderId = isi.intOrderId AND cd.intPricingTypeId = 1 and cd.intContractStatusId <> 3
										AND cd.intCompanyLocationId IN (SELECT intCompanyLocationId FROM tblSMCompanyLocation
								WHERE isnull(ysnLicensed, 0) = CASE WHEN @strPositionIncludes = 'licensed storage' THEN 1 
								WHEN @strPositionIncludes = 'Non-licensed storage' THEN 0 
								ELSE isnull(ysnLicensed, 0) END)
			INNER JOIN tblSMCurrency cur on cur.intCurrencyID=cd.intCurrencyId
			INNER JOIN tblSMCompanyLocation cl ON cl.intCompanyLocationId = st.intProcessingLocationId
			LEFT JOIN tblARInvoiceDetail I on isi.intInventoryShipmentItemId = I.intInventoryShipmentItemId
			LEFT JOIN tblARPaymentDetail R  ON R.intInvoiceId = I.intInvoiceId and isnull(R.dblPayment, 0)>0
			WHERE intOrderType IN (1) AND intSourceType = 1	AND st.intCommodityId = @intCommodityId
				AND st.intProcessingLocationId= case when isnull(@intLocationId,0)=0 then st.intProcessingLocationId else @intLocationId end	
				AND st.intEntityId= @intVendorId 	
				AND CONVERT(DATETIME, CONVERT(VARCHAR(10), dtmDate, 110), 110)<=CONVERT(DATETIME,@dtmToDate)	
			) t
		
UNION 
		SELECT @strDescription, 'Net Receivable  ($)' [strType],'Sale Net Receivable  ($)',isnull(dblUnitCost,0)-isnull(dblQtyReceived,0) AS dblTotal,
			intContractHeaderId,strContractNumber,strLocationName
			,strTicketNumber
			,dtmTicketDateTime
			,strCustomerReference
			,strDistributionOption, dblUCost
			,dblQtyReceived,@intCommodityId,strCurrency	
		FROM (
			SELECT DISTINCT isi.intInventoryShipmentItemId AS intInventoryReceiptItemId
				,cl.strLocationName
				,st.strTicketNumber
				,st.dtmTicketDateTime
				,strCustomerReference
				,'Spot Sale' strDistributionOption
				,null as intContractHeaderId
				,null as strContractNumber
				,isi.dblUnitPrice AS dblUCost
				,isi.dblQuantity * isi.dblUnitPrice AS dblUnitCost
				,st.intCommodityId
				,R.dblPayment as dblQtyReceived,
				isi.intItemUOMId as intUnitMeasureId,cur.strCurrency
			FROM tblICInventoryTransaction it
			join tblICInventoryShipment ici on ici.strShipmentNumber=it.strTransactionId  
			INNER JOIN tblICInventoryShipmentItem isi ON isi.intInventoryShipmentId = ici.intInventoryShipmentId
			INNER JOIN tblSCTicket st ON st.intTicketId = isi.intSourceId AND strDistributionOption IN ('SPT')
			INNER JOIN tblSMCurrency cur on cur.intCurrencyID=st.intCurrencyId
			INNER JOIN tblSMCompanyLocation cl ON cl.intCompanyLocationId = st.intProcessingLocationId
										AND st.intProcessingLocationId IN (SELECT intCompanyLocationId FROM tblSMCompanyLocation
								WHERE isnull(ysnLicensed, 0) = CASE WHEN @strPositionIncludes = 'licensed storage' THEN 1 
								WHEN @strPositionIncludes = 'Non-licensed storage' THEN 0 
								ELSE isnull(ysnLicensed, 0) END)
			LEFT JOIN tblARInvoiceDetail I on isi.intInventoryShipmentItemId = I.intInventoryShipmentItemId
			LEFT JOIN tblARPaymentDetail R  ON R.intInvoiceId = I.intInvoiceId and isnull(R.dblPayment, 0)>0
			WHERE intOrderType IN (4)
				AND intSourceType = 1
				AND st.intCommodityId = @intCommodityId
				AND st.intProcessingLocationId= case when isnull(@intLocationId,0)=0 then st.intProcessingLocationId else @intLocationId end
				AND st.intEntityId= @intVendorId AND CONVERT(DATETIME, CONVERT(VARCHAR(10), dtmDate, 110), 110)<=CONVERT(DATETIME,@dtmToDate)		
			) t	
				
	INSERT INTO @tempFinal (strCommodityCode,strType,strSubType,dblTotal,intInventoryReceiptItemId,strLocationName,intContractHeaderId,strContractNumber,strTicketNumber,dtmTicketDateTime,
	strCustomerReference,strDistributionOption,dblUnitCost,dblQtyReceived,intCommodityId,strCurrency)

	SELECT @strDescription, 'Net Receivable  ($)' [strType],'Sale Net Receivable  ($)',dblQtyReceived AS dblTotal,intInventoryReceiptItemId,strLocationName,
			intContractHeaderId,strContractNumber
			,strTicketNumber
			,dtmTicketDateTime
			,strCustomerReference
			,strDistributionOption, dblUnitCost
			,dblQtyReceived,@intCommodityId,strCurrency			
		FROM (
			SELECT DISTINCT isi.intInventoryShipmentItemId AS intInventoryReceiptItemId
				,cl.strLocationName
				,st.strTicketNumber
				,st.dtmTicketDateTime
				,strCustomerReference
				,'Contract' strDistributionOption
				,cd.intContractHeaderId
				,cd.strContractNumber
				,isi.dblQuantity * isi.dblUnitPrice AS dblUnitCost
				,R.dblAmountDue dblQtyReceived
				,st.intCommodityId,cd.intUnitMeasureId,cur.strCurrency
			FROM tblICInventoryTransaction it
			join tblICInventoryShipment ici on ici.strShipmentNumber=it.strTransactionId  
			INNER JOIN tblICInventoryShipmentItem isi ON isi.intInventoryShipmentId = ici.intInventoryShipmentId
			INNER JOIN tblSCTicket st ON st.intTicketId = isi.intSourceId AND strDistributionOption IN ('CNT')			
			INNER JOIN @tblGetOpenContractDetail cd ON cd.intContractHeaderId = isi.intOrderId AND cd.intPricingTypeId = 1 and cd.intContractStatusId <> 3
													AND st.intProcessingLocationId IN (SELECT intCompanyLocationId FROM tblSMCompanyLocation
								WHERE isnull(ysnLicensed, 0) = CASE WHEN @strPositionIncludes = 'licensed storage' THEN 1 
								WHEN @strPositionIncludes = 'Non-licensed storage' THEN 0 
								ELSE isnull(ysnLicensed, 0) END)
			INNER JOIN tblSMCurrency cur on cur.intCurrencyID=cd.intCurrencyId
			INNER JOIN tblSMCompanyLocation cl ON cl.intCompanyLocationId = st.intProcessingLocationId
			LEFT JOIN tblARInvoiceDetail I on isi.intInventoryShipmentItemId = I.intInventoryShipmentItemId
			LEFT JOIN tblARPaymentDetail R  ON R.intInvoiceId = I.intInvoiceId and isnull(R.dblPayment, 0)>0
			WHERE intOrderType IN (1) AND intSourceType = 1	AND st.intCommodityId = @intCommodityId
				AND st.intProcessingLocationId= case when isnull(@intLocationId,0)=0 then st.intProcessingLocationId else @intLocationId end	
				AND st.intEntityId= @intVendorId 	 AND CONVERT(DATETIME, CONVERT(VARCHAR(10), dtmDate, 110), 110)<=CONVERT(DATETIME,@dtmToDate)	
			) t
		
UNION 

		SELECT @strDescription, 'Net Receivable  ($)' [strType],'Sale Net Receivable  ($)',dblQtyReceived AS dblTotal,intInventoryReceiptItemId,strLocationName,intContractHeaderId,strContractNumber
			,strTicketNumber,dtmTicketDateTime,strCustomerReference,strDistributionOption, dblUnitCost,dblQtyReceived,@intCommodityId,strCurrency
			
		FROM (
			SELECT DISTINCT isi.intInventoryShipmentItemId AS intInventoryReceiptItemId
				,cl.strLocationName
				,st.strTicketNumber
				,st.dtmTicketDateTime
				,strCustomerReference
				,'Spot Sale' strDistributionOption
				,null as intContractHeaderId
				,null as strContractNumber
				,isi.dblQuantity * isi.dblUnitPrice AS dblUnitCost
				,st.intCommodityId
				,R.dblAmountDue dblQtyReceived,
				isi.intItemUOMId as intUnitMeasureId,cur.strCurrency
			FROM tblICInventoryTransaction it
			join tblICInventoryShipment ici on ici.strShipmentNumber=it.strTransactionId  
			INNER JOIN tblICInventoryShipmentItem isi ON isi.intInventoryShipmentId = ici.intInventoryShipmentId
			INNER JOIN tblSCTicket st ON st.intTicketId = isi.intSourceId AND strDistributionOption IN ('SPT')
													AND st.intProcessingLocationId IN (SELECT intCompanyLocationId FROM tblSMCompanyLocation
								WHERE isnull(ysnLicensed, 0) = CASE WHEN @strPositionIncludes = 'licensed storage' THEN 1 
								WHEN @strPositionIncludes = 'Non-licensed storage' THEN 0 
								ELSE isnull(ysnLicensed, 0) END)
			INNER JOIN tblSMCurrency cur on cur.intCurrencyID=st.intCurrencyId
			INNER JOIN tblSMCompanyLocation cl ON cl.intCompanyLocationId = st.intProcessingLocationId
			LEFT JOIN tblARInvoiceDetail I on isi.intInventoryShipmentItemId = I.intInventoryShipmentItemId
			LEFT JOIN tblARPaymentDetail R  ON R.intInvoiceId = I.intInvoiceId and isnull(R.dblPayment, 0)>0
			WHERE intOrderType IN (4)
				AND intSourceType = 1
				AND st.intCommodityId = @intCommodityId
				AND st.intProcessingLocationId= case when isnull(@intLocationId,0)=0 then st.intProcessingLocationId else @intLocationId end
				AND st.intEntityId= @intVendorId AND st.intEntityId= @intVendorId 	 AND CONVERT(DATETIME, CONVERT(VARCHAR(10), dtmDate, 110), 110)<=CONVERT(DATETIME,@dtmToDate)		
			) t	

	INSERT INTO @tempFinal (strCommodityCode,strType,dblTotal,intContractHeaderId,strContractNumber,strLocationName,strTicketNumber,dtmTicketDateTime,
					strCustomerReference,strDistributionOption,dblUnitCost,dblQtyReceived,intCommodityId,strContractType)

	select strCommodityCode,'NP Un-Paid Quantity' strType,dblTotal/case when isnull(dblUnitCost,0)=0 then 1 else dblUnitCost end,intContractHeaderId,strContractNumber,strLocationName,strTicketNumber,dtmTicketDateTime,
					strCustomerReference,strDistributionOption,dblUnitCost,dblQtyReceived,intCommodityId,strContractType
					 FROM @tempFinal where strType='Net Payable  ($)' and intCommodityId=@intCommodityId

	INSERT INTO @tempFinal (strCommodityCode,strType,dblTotal,intInventoryReceiptItemId,strLocationName,intContractHeaderId,strContractNumber,strTicketNumber,dtmTicketDateTime,
	strCustomerReference,strDistributionOption,dblUnitCost,dblQtyReceived,intCommodityId,strContractType)
	select @strDescription,'NR Un-Paid Quantity' strType,dblTotal/case when isnull(dblUnitCost,0)=0 then 1 else dblUnitCost end,intInventoryReceiptItemId,strLocationName,intContractHeaderId,strContractNumber,strTicketNumber,dtmTicketDateTime,
	strCustomerReference,strDistributionOption,dblUnitCost,dblQtyReceived,intCommodityId,strContractType from @tempFinal where strType= 'Net Receivable  ($)' and intCommodityId=@intCommodityId

	SELECT @intUnitMeasureId =null
	SELECT @strUnitMeasure =null
	SELECT TOP 1 @intUnitMeasureId = intUnitMeasureId FROM tblRKCompanyPreference
	SELECT @strUnitMeasure=strUnitMeasure from tblICUnitMeasure where intUnitMeasureId=@intUnitMeasureId
	INSERT INTO @Final (strCommodityCode ,intContractHeaderId,strContractNumber,intFutOptTransactionHeaderId,strInternalTradeNo, strType,strSubType,strContractType,strContractEndMonth, 
		dblTotal,strUnitMeasure,intInventoryReceiptItemId,strLocationName,strTicketNumber,dtmTicketDateTime,strCustomerReference,strDistributionOption,dblUnitCost,dblQtyReceived,strAccountNumber,strTranType,dblNoOfLot,dblDelta,intBrokerageAccountId,strInstrumentType 
		,invQty,PurBasisDelivary,OpenPurQty,OpenSalQty,dblCollatralSales, SlsBasisDeliveries,intNoOfContract,dblContractSize,CompanyTitled,strCurrency)

	SELECT strCommodityCode ,intContractHeaderId,strContractNumber,intFutOptTransactionHeaderId,strInternalTradeNo, strType,strSubType,strContractType,strContractEndMonth, 	
	    Convert(decimal(24,10),dbo.fnCTConvertQuantityToTargetCommodityUOM(cuc.intCommodityUnitMeasureId,
		case when (isnull(@intUnitMeasureId, 0) = 0 OR cuc.intCommodityUnitMeasureId = @intUnitMeasureId) then cuc.intCommodityUnitMeasureId else cuc1.intCommodityUnitMeasureId end,dblTotal)) dblTotal,
		case when isnull(@strUnitMeasure,'')='' then um.strUnitMeasure else @strUnitMeasure end as strUnitMeasure,intInventoryReceiptItemId,strLocationName,strTicketNumber,dtmTicketDateTime,strCustomerReference,strDistributionOption,dblUnitCost,dblQtyReceived,
		strAccountNumber,strTranType,dblNoOfLot,dblDelta,intBrokerageAccountId,strInstrumentType
		,Convert(decimal(24,10),dbo.fnCTConvertQuantityToTargetCommodityUOM(cuc.intCommodityUnitMeasureId,
		case when (isnull(@intUnitMeasureId, 0) = 0 OR cuc.intCommodityUnitMeasureId = @intUnitMeasureId) then cuc.intCommodityUnitMeasureId else cuc1.intCommodityUnitMeasureId end,invQty)) invQty,
		Convert(decimal(24,10),dbo.fnCTConvertQuantityToTargetCommodityUOM(cuc.intCommodityUnitMeasureId,
		case when (isnull(@intUnitMeasureId, 0) = 0 OR cuc.intCommodityUnitMeasureId = @intUnitMeasureId) then cuc.intCommodityUnitMeasureId else cuc1.intCommodityUnitMeasureId end,PurBasisDelivary)) PurBasisDelivary,
		Convert(decimal(24,10),dbo.fnCTConvertQuantityToTargetCommodityUOM(cuc.intCommodityUnitMeasureId,
		case when (isnull(@intUnitMeasureId, 0) = 0 OR cuc.intCommodityUnitMeasureId = @intUnitMeasureId) then cuc.intCommodityUnitMeasureId else cuc1.intCommodityUnitMeasureId end,OpenPurQty)) OpenPurQty,
				Convert(decimal(24,10),dbo.fnCTConvertQuantityToTargetCommodityUOM(cuc.intCommodityUnitMeasureId,
		case when (isnull(@intUnitMeasureId, 0) = 0 OR cuc.intCommodityUnitMeasureId = @intUnitMeasureId) then cuc.intCommodityUnitMeasureId else cuc1.intCommodityUnitMeasureId end,OpenSalQty)) OpenSalQty,
		Convert(decimal(24,10),dbo.fnCTConvertQuantityToTargetCommodityUOM(cuc.intCommodityUnitMeasureId,
		case when (isnull(@intUnitMeasureId, 0) = 0 OR cuc.intCommodityUnitMeasureId = @intUnitMeasureId) then cuc.intCommodityUnitMeasureId else cuc1.intCommodityUnitMeasureId end,dblCollatralSales)) dblCollatralSales,
		Convert(decimal(24,10),dbo.fnCTConvertQuantityToTargetCommodityUOM(cuc.intCommodityUnitMeasureId,
		case when (isnull(@intUnitMeasureId, 0) = 0 OR cuc.intCommodityUnitMeasureId = @intUnitMeasureId) then cuc.intCommodityUnitMeasureId else cuc1.intCommodityUnitMeasureId end,SlsBasisDeliveries)) SlsBasisDeliveries
		,intNoOfContract,dblContractSize,
		Convert(decimal(24,10),dbo.fnCTConvertQuantityToTargetCommodityUOM(cuc.intCommodityUnitMeasureId,
		case when (isnull(@intUnitMeasureId, 0) = 0 OR cuc.intCommodityUnitMeasureId = @intUnitMeasureId) then cuc.intCommodityUnitMeasureId else cuc1.intCommodityUnitMeasureId end,CompanyTitled)) CompanyTitled
		  ,strCurrency
	FROM @tempFinal t
	JOIN tblICCommodityUnitMeasure cuc on t.intCommodityId=cuc.intCommodityId and cuc.ysnDefault=1 
	JOIN tblICUnitMeasure um on um.intUnitMeasureId=cuc.intUnitMeasureId
	LEFT JOIN tblICCommodityUnitMeasure cuc1 on t.intCommodityId=cuc1.intCommodityId and @intUnitMeasureId=cuc1.intUnitMeasureId
	WHERE t.intCommodityId= @intCommodityId and strType not in('Net Payable  ($)','Net Receivable  ($)')
	UNION

	SELECT strCommodityCode ,intContractHeaderId,strContractNumber,intFutOptTransactionHeaderId,strInternalTradeNo, strType,strSubType,strContractType,
	strContractEndMonth, dblTotal dblTotal,case when isnull(@strUnitMeasure,'')='' then um.strUnitMeasure else @strUnitMeasure end as strUnitMeasure,intInventoryReceiptItemId,strLocationName,strTicketNumber,dtmTicketDateTime,strCustomerReference,
	strDistributionOption,dblUnitCost,dblQtyReceived,strAccountNumber,strTranType,dblNoOfLot,dblDelta,intBrokerageAccountId,strInstrumentType  
		,invQty,PurBasisDelivary,OpenPurQty,OpenSalQty,dblCollatralSales, SlsBasisDeliveries,intNoOfContract,dblContractSize,CompanyTitled,strCurrency
	FROM @tempFinal t
	JOIN tblICCommodityUnitMeasure cuc on t.intCommodityId=cuc.intCommodityId and cuc.ysnDefault=1 
	JOIN tblICUnitMeasure um on um.intUnitMeasureId=cuc.intUnitMeasureId
	 WHERE t.intCommodityId= @intCommodityId and strType in( 'Net Payable  ($)','Net Receivable  ($)')
	
END
END
SELECT @mRowNumber = MIN(intCommodityIdentity)	FROM @Commodity	WHERE intCommodityIdentity > @mRowNumber	
END

UPDATE @Final set intSeqNo = 1 where strType='Purchase Priced'
UPDATE @Final set intSeqNo = 2 where strType='Purchase Basis'
UPDATE @Final set intSeqNo = 3 where strType='Purchase HTA'
UPDATE @Final set intSeqNo = 4 where strType='Sale Priced'
UPDATE @Final set intSeqNo = 5 where strType='Sale Basis'
UPDATE @Final set intSeqNo = 6 where strType='Sale HTA'
UPDATE @Final set intSeqNo = 7 where strType='Net Hedge'
UPDATE @Final set intSeqNo = 8 where strType='Price Risk'
UPDATE @Final set intSeqNo = 9 where strType='Basis Risk'
UPDATE @Final set intSeqNo = 10 where strType='Net Payable  ($)'
UPDATE @Final set intSeqNo = 11 where strType='NP Un-Paid Quantity'
UPDATE @Final set intSeqNo = 12 where strType='Net Receivable  ($)'
UPDATE @Final set intSeqNo = 13 where strType='NR Un-Paid Quantity'
UPDATE @Final set intSeqNo = 14 where strType='Avail for Spot Sale'
	
IF isnull(@intVendorId,0) = 0
BEGIN
	SELECT intSeqNo,intRow, strCommodityCode ,intContractHeaderId,strContractNumber,strInternalTradeNo,intFutOptTransactionHeaderId, strType,strContractType,strContractEndMonth,dblTotal,strUnitMeasure 
				,intInventoryReceiptItemId,strLocationName,strTicketNumber,dtmTicketDateTime,strCustomerReference,strDistributionOption,dblUnitCost,dblQtyReceived,strAccountNumber,strTranType,dblNoOfLot,dblDelta,intBrokerageAccountId,strInstrumentType,
				invQty,PurBasisDelivary,OpenPurQty,OpenSalQty,dblCollatralSales, SlsBasisDeliveries,intNoOfContract,dblContractSize,CompanyTitled,strCurrency  			
	FROM @Final where dblTotal <> 0 
	ORDER BY intSeqNo ASC,case when isnull(intContractHeaderId,0)=0 then intFutOptTransactionHeaderId else intContractHeaderId end desc
END
ELSE
BEGIN
	SELECT intSeqNo,intRow, strCommodityCode ,intContractHeaderId,strContractNumber,strInternalTradeNo,intFutOptTransactionHeaderId, strType,strSubType,strContractType,strContractEndMonth,dblTotal,strUnitMeasure 
				,intInventoryReceiptItemId,strLocationName,strTicketNumber,dtmTicketDateTime,strCustomerReference,strDistributionOption,dblUnitCost,dblQtyReceived,strAccountNumber,strTranType,dblNoOfLot,dblDelta,intBrokerageAccountId,strInstrumentType,
				invQty,PurBasisDelivary,OpenPurQty,OpenSalQty,dblCollatralSales, SlsBasisDeliveries,intNoOfContract,dblContractSize,CompanyTitled,strCurrency  			
	FROM @Final where dblTotal <> 0 and strSubType NOT like '%'+@strPurchaseSales+'%'  
	ORDER BY intSeqNo ASC,case when isnull(intContractHeaderId,0)=0 then intFutOptTransactionHeaderId else intContractHeaderId end desc
END