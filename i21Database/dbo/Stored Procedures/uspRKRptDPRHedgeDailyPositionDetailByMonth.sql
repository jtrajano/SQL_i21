﻿CREATE PROCEDURE [dbo].[uspRKRptDPRHedgeDailyPositionDetailByMonth]
		@xmlParam NVARCHAR(MAX) = NULL
AS
BEGIN
	DECLARE @idoc INT
		,@intCommodityId nvarchar(max)
		,@intLocationId nvarchar(max) = NULL		
		,@intVendorId int = null
		,@strPurchaseSales nvarchar(50) = NULL
		,@strPositionIncludes nvarchar(max) 
		,@dtmToDate nvarchar(max) 
	IF LTRIM(RTRIM(@xmlParam)) = ''
		SET @xmlParam = NULL

	DECLARE @temp_xml_table TABLE (
		fieldname NVARCHAR(50)
		,condition NVARCHAR(20)
		,[from] NVARCHAR(50)
		,[to] NVARCHAR(50)
		,[join] NVARCHAR(10)
		,[begingroup] NVARCHAR(50)
		,[endgroup] NVARCHAR(50)
		,[datatype] NVARCHAR(50)
		)

	EXEC sp_xml_preparedocument @idoc OUTPUT
		,@xmlParam

	INSERT INTO @temp_xml_table
SELECT *
	FROM OPENXML(@idoc, 'xmlparam/filters/filter', 2) WITH (
			 fieldname NVARCHAR(50)
			,condition NVARCHAR(20)
			,[from] NVARCHAR(50)
			,[to] NVARCHAR(50)
			,[join] NVARCHAR(10)
			,[begingroup] NVARCHAR(50)
			,[endgroup] NVARCHAR(50)
			,[datatype] NVARCHAR(50)
			)

	SELECT @intCommodityId = [from]
	FROM @temp_xml_table	
	WHERE [fieldname] = 'intCommodityId'
	
	SELECT @intLocationId = [from]
	FROM @temp_xml_table	
	WHERE [fieldname] = 'intLocationId'
	
	SELECT @intVendorId = [from]
	FROM @temp_xml_table	
	WHERE [fieldname] = 'intVendorId'
	
	SELECT @strPurchaseSales = [from]
	FROM @temp_xml_table	
	WHERE [fieldname] = 'strPurchaseSales'
			SELECT @strPositionIncludes = [from]
	FROM @temp_xml_table	
	WHERE [fieldname] = 'strPositionIncludes'

		SELECT @dtmToDate = [from]
	FROM @temp_xml_table	
	WHERE [fieldname] = 'dtmToDate'
SET @dtmToDate = convert(DATETIME, CONVERT(VARCHAR(10), @dtmToDate, 110), 110)

IF ISNULL(@strPurchaseSales,'') <> ''
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

DECLARE @strCommodityCode NVARCHAR(50)

	 DECLARE @Commodity AS TABLE 
	 (
		intCommodityIdentity int IDENTITY(1,1) PRIMARY KEY , 
		intCommodity  INT
	 )
	 INSERT INTO @Commodity(intCommodity)
	 SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCommodityId, ',')  

DECLARE @List AS TABLE (  
     intRowNumber INT IDENTITY(1,1),
	 intContractHeaderId int,
	 strContractNumber NVARCHAR(200),
	 intFutOptTransactionHeaderId int,
	 strInternalTradeNo NVARCHAR(200),
	 intCommodityId int,
	 strCommodityCode NVARCHAR(200),   
     strType  NVARCHAR(50), 
	 strLocationName NVARCHAR(100),
	 strContractEndMonth NVARCHAR(50),
	 strContractEndMonthNearBy NVARCHAR(50),
	 dblTotal DECIMAL(24,10)
	 ,intSeqNo int
	 ,strUnitMeasure NVARCHAR(50)
	 ,intFromCommodityUnitMeasureId int
	 ,intToCommodityUnitMeasureId int
	 ,strAccountNumber NVARCHAR(100)
	 ,strTranType NVARCHAR(20)
	 ,dblNoOfLot NUMERIC(24, 10)
	 ,dblDelta NUMERIC(24, 10)
	 ,intBrokerageAccountId int
	 ,strInstrumentType nvarchar(50)
	 ,strEntityName  nvarchar(100)
     ) 

DECLARE @FinalList AS TABLE (  
     intRowNumber INT IDENTITY(1,1),
	 intContractHeaderId int,
	 strContractNumber NVARCHAR(200),
	 intFutOptTransactionHeaderId int,
	 strInternalTradeNo NVARCHAR(200),
	 intCommodityId int,
	 strCommodityCode NVARCHAR(200),   
     strType  NVARCHAR(50), 
	 strLocationName NVARCHAR(100),
	 strContractEndMonth NVARCHAR(50),
	 strContractEndMonthNearBy NVARCHAR(50),
	 dblTotal DECIMAL(24,10)
	 ,intSeqNo int
	 ,strUnitMeasure NVARCHAR(50)
	 ,intFromCommodityUnitMeasureId int
	 ,intToCommodityUnitMeasureId int
	 ,strAccountNumber NVARCHAR(100)
	 ,strTranType NVARCHAR(20)
	 ,dblNoOfLot NUMERIC(24, 10)
	 ,dblDelta NUMERIC(24, 10)
	 ,intBrokerageAccountId int
	 ,strInstrumentType nvarchar(50)
	 ,strEntityName  nvarchar(100)
     ) 


DECLARE @mRowNumber INT
DECLARE @intCommodityId1 INT
DECLARE @strDescription NVARCHAR(50)
DECLARE @intOneCommodityId int
DECLARE @intCommodityUnitMeasureId int
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
		,intFutureMonthId	int
		)

INSERT INTO @tblGetOpenContractDetail (intRowNum,strCommodityCode,intCommodityId,intContractHeaderId,strContractNumber,strLocationName,dtmEndDate,dblBalance,intUnitMeasureId,intPricingTypeId,intContractTypeId,
	   intCompanyLocationId,strContractType,strPricingType,intCommodityUnitMeasureId,intContractDetailId,intContractStatusId,intEntityId,intCurrencyId,strType,intItemId,strItemNo ,dtmContractDate,strEntityName,strCustomerContract
	   	,intFutureMarketId,intFutureMonthId)	
EXEC uspRKDPRContractDetail @intCommodityId, @dtmToDate

DECLARE @tblGetOpenFutureByDate TABLE (
		intFutOptTransactionId int, 
		intOpenContract  int,
		strCommodityCode nvarchar(100) COLLATE Latin1_General_CI_AS,
		strInternalTradeNo nvarchar(100) COLLATE Latin1_General_CI_AS,
		strLocationName nvarchar(100) COLLATE Latin1_General_CI_AS,
		dblContractSize numeric(24,10),
		strFutureMarket nvarchar(100) COLLATE Latin1_General_CI_AS,
		strFutureMonth nvarchar(100) COLLATE Latin1_General_CI_AS,
		strOptionMonth nvarchar(100) COLLATE Latin1_General_CI_AS,
		dblStrike numeric(24,10),
		strOptionType nvarchar(100) COLLATE Latin1_General_CI_AS,
		strInstrumentType nvarchar(100) COLLATE Latin1_General_CI_AS,
		strBrokerAccount nvarchar(100) COLLATE Latin1_General_CI_AS,
		strBroker nvarchar(100) COLLATE Latin1_General_CI_AS,
		strNewBuySell nvarchar(100) COLLATE Latin1_General_CI_AS,
		intFutOptTransactionHeaderId int 
		)
INSERT INTO @tblGetOpenFutureByDate (intFutOptTransactionId,intOpenContract,strCommodityCode,strInternalTradeNo,strLocationName,dblContractSize,
			strFutureMarket,strFutureMonth,strOptionMonth,dblStrike,strOptionType,strInstrumentType,strBrokerAccount,strBroker,strNewBuySell,intFutOptTransactionHeaderId)
EXEC uspRKGetOpenContractByDate @intCommodityId, @dtmToDate

INSERT INTO @List (strCommodityCode,intCommodityId,intContractHeaderId,strContractNumber,strType,strLocationName,strContractEndMonth,strContractEndMonthNearBy,dblTotal,intFromCommodityUnitMeasureId,strEntityName)
	SELECT strCommodityCode,CD.intCommodityId,intContractHeaderId,strContractNumber
		,CD.strType [strType]
		,strLocationName
		,RIGHT(CONVERT(VARCHAR(11),dtmEndDate,106),8) strContractEndMonth,RIGHT(CONVERT(VARCHAR(11),dtmEndDate,106),8) 
		, case when intContractTypeId = 1 then
		dbo.fnCTConvertQuantityToTargetCommodityUOM(ium.intCommodityUnitMeasureId,@intCommodityUnitMeasureId,isnull((CD.dblBalance),0))		
		else
		-dbo.fnCTConvertQuantityToTargetCommodityUOM(ium.intCommodityUnitMeasureId,@intCommodityUnitMeasureId,isnull((CD.dblBalance),0))
		end AS dblTotal,		
		CD.intUnitMeasureId,
		CD.strEntityName
	FROM @tblGetOpenContractDetail CD
	JOIN tblICCommodityUnitMeasure ium on ium.intCommodityId=CD.intCommodityId AND CD.intUnitMeasureId=ium.intUnitMeasureId  and CD.intContractStatusId <> 3
			AND intCompanyLocationId  IN (SELECT intCompanyLocationId FROM tblSMCompanyLocation
				WHERE isnull(ysnLicensed, 0) = CASE WHEN @strPositionIncludes = 'licensed storage' THEN 1 
								WHEN @strPositionIncludes = 'Non-licensed storage' THEN 0 
								ELSE isnull(ysnLicensed, 0) END
				)
	WHERE intContractTypeId in(1,2) AND  CD.intCommodityId =@intCommodityId	
	AND intCompanyLocationId= case when isnull(@intLocationId,0)=0 then intCompanyLocationId else @intLocationId end
	 and  CD.intEntityId= CASE WHEN ISNULL(@intVendorId,0)=0 then CD.intEntityId else @intVendorId end 
	 
INSERT INTO @List (strCommodityCode,intCommodityId,strInternalTradeNo,intFutOptTransactionHeaderId,strType,strLocationName,strContractEndMonth,strContractEndMonthNearBy,dblTotal,intFromCommodityUnitMeasureId
					,strAccountNumber,strTranType,intBrokerageAccountId,strInstrumentType,dblNoOfLot)
       SELECT strCommodityCode,intCommodityId,strInternalTradeNo,intFutOptTransactionHeaderId,'Net Hedge',strLocationName, strFutureMonth,dtmFutureMonthsDate,HedgedQty,intUnitMeasureId
       ,strAccountNumber,strTranType,intBrokerageAccountId,strInstrumentType,dblNoOfLot
       FROM (
         SELECT t.strCommodityCode,strInternalTradeNo,intFutOptTransactionHeaderId,th.intCommodityId,dtmFutureMonthsDate,
		dbo.fnCTConvertQuantityToTargetCommodityUOM(cuc1.intCommodityUnitMeasureId,@intCommodityUnitMeasureId,  
		ISNULL(intOpenContract, 0) * t.dblContractSize) AS HedgedQty,
		l.strLocationName,left(t.strFutureMonth,4) +  '20'+convert(nvarchar(2),intYear) strFutureMonth,m.intUnitMeasureId,
		e.strName + '-' + ba.strAccountNumber strAccountNumber,strNewBuySell as strTranType,ba.intBrokerageAccountId,
		t.strInstrumentType as strInstrumentType,
		ISNULL(intOpenContract, 0) dblNoOfLot 
		FROM @tblGetOpenFutureByDate t
		join tblICCommodity th on th.strCommodityCode=t.strCommodityCode
		join tblSMCompanyLocation l on l.strLocationName=t.strLocationName
		join tblRKFutureMarket m on m.strFutMarketName=t.strFutureMarket
		LEFT join tblRKBrokerageAccount ba on ba.strAccountNumber=t.strBrokerAccount
		INNER JOIN tblEMEntity e ON e.strName = t.strBroker AND t.strInstrumentType= 'Futures'
		JOIN tblICCommodityUnitMeasure cuc1 on cuc1.intCommodityId=@intCommodityId and m.intUnitMeasureId=cuc1.intUnitMeasureId	
		INNER JOIN tblRKFuturesMonth fm ON fm.strFutureMonth = t.strFutureMonth AND fm.intFutureMarketId = m.intFutureMarketId AND fm.ysnExpired = 0	
		WHERE th.intCommodityId in (SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCommodityId, ','))
			AND intCompanyLocationId= case when isnull(@intLocationId,0)=0 then intCompanyLocationId else @intLocationId end		
				 and  e.intEntityId= CASE WHEN ISNULL(@intVendorId,0)=0 then e.intEntityId else @intVendorId end 
		AND  intCompanyLocationId  IN (SELECT intCompanyLocationId FROM tblSMCompanyLocation
												WHERE isnull(ysnLicensed, 0) = CASE WHEN @strPositionIncludes = 'licensed storage' THEN 1 
																WHEN @strPositionIncludes = 'Non-licensed storage' THEN 0 
																ELSE isnull(ysnLicensed, 0) END
												)
		) t

 --Option NetHEdge
		INSERT INTO @List (strCommodityCode,intCommodityId,strInternalTradeNo,intFutOptTransactionHeaderId,strType,strLocationName,strContractEndMonth,strContractEndMonthNearBy,dblTotal,
							intFromCommodityUnitMeasureId,strAccountNumber,strTranType,dblNoOfLot,dblDelta,intBrokerageAccountId,strInstrumentType)	
		SELECT DISTINCT t.strCommodityCode,th.intCommodityId,t.strInternalTradeNo,intFutOptTransactionHeaderId,'Net Hedge' ,t.strLocationName,
				 left(t.strFutureMonth,4) +  '20'+convert(nvarchar(2),fm.intYear) strFutureMonth, 	
				 left(t.strFutureMonth,4) +  '20'+convert(nvarchar(2),fm.intYear) dtmFutureMonthsDate,			
				intOpenContract * isnull((
						SELECT TOP 1 dblDelta
						FROM tblRKFuturesSettlementPrice sp
						INNER JOIN tblRKOptSettlementPriceMarketMap mm ON sp.intFutureSettlementPriceId = mm.intFutureSettlementPriceId
						WHERE intFutureMarketId = m.intFutureMarketId AND mm.intOptionMonthId = om.intOptionMonthId AND mm.intTypeId = CASE WHEN t.strOptionType = 'Put' THEN 1 ELSE 2 END
						AND t.dblStrike = mm.dblStrike
						ORDER BY dtmPriceDate DESC
				),0)*m.dblContractSize AS dblTotal, m.intUnitMeasureId,				
		e.strName + '-' + strAccountNumber AS strAccountNumber, 		
		strNewBuySell AS TranType, 
		intOpenContract AS dblNoOfLot, 
		ISNULL((SELECT TOP 1 dblDelta
		FROM tblRKFuturesSettlementPrice sp
		INNER JOIN tblRKOptSettlementPriceMarketMap mm ON sp.intFutureSettlementPriceId = mm.intFutureSettlementPriceId
		WHERE intFutureMarketId = m.intFutureMarketId AND mm.intOptionMonthId = om.intOptionMonthId AND mm.intTypeId = CASE WHEN t.strOptionType = 'Put' THEN 1 ELSE 2 END
		AND t.dblStrike = mm.dblStrike
		ORDER BY dtmPriceDate DESC
		),0) AS dblDelta,ba.intBrokerageAccountId,'Options ' as strInstrumentType
	FROM @tblGetOpenFutureByDate t
	join tblICCommodity th on th.strCommodityCode=t.strCommodityCode
	join tblSMCompanyLocation l on l.strLocationName=t.strLocationName 
	join tblRKFutureMarket m on m.strFutMarketName=t.strFutureMarket
	join tblRKOptionsMonth om on om.strOptionMonth=t.strOptionMonth
	INNER JOIN tblRKBrokerageAccount ba ON t.strBrokerAccount = ba.strAccountNumber
	INNER JOIN tblEMEntity e ON e.strName = t.strBroker AND t.strInstrumentType= 'Options'
	INNER JOIN tblRKFuturesMonth fm ON fm.strFutureMonth = t.strFutureMonth AND fm.intFutureMarketId = m.intFutureMarketId AND fm.ysnExpired = 0
	WHERE th.intCommodityId = @intCommodityId AND intCompanyLocationId = case when isnull(@intLocationId,0)=0 then intCompanyLocationId else @intLocationId end 
	AND t.intFutOptTransactionId NOT IN (
			SELECT intFutOptTransactionId FROM tblRKOptionsPnSExercisedAssigned	) AND t.intFutOptTransactionId NOT IN (SELECT intFutOptTransactionId FROM tblRKOptionsPnSExpired)
				 and  e.intEntityId= CASE WHEN ISNULL(@intVendorId,0)=0 then e.intEntityId else @intVendorId end 
			AND  intCompanyLocationId  IN (SELECT intCompanyLocationId FROM tblSMCompanyLocation
											WHERE isnull(ysnLicensed, 0) = CASE WHEN @strPositionIncludes = 'licensed storage' THEN 1 
															WHEN @strPositionIncludes = 'Non-licensed storage' THEN 0 
															ELSE isnull(ysnLicensed, 0) END
											)
--Net Hedge option end
		
DECLARE @intUnitMeasureId int
DECLARE @strUnitMeasure nvarchar(50)
SELECT TOP 1 @intUnitMeasureId = intUnitMeasureId FROM tblRKCompanyPreference
SELECT @strUnitMeasure=strUnitMeasure from tblICUnitMeasure WHERE intUnitMeasureId=@intUnitMeasureId

INSERT INTO @FinalList (strCommodityCode ,strContractNumber,intContractHeaderId,strInternalTradeNo,intFutOptTransactionHeaderId,strType,strLocationName,strContractEndMonth,strContractEndMonthNearBy,dblTotal,strUnitMeasure,strAccountNumber,strTranType,dblNoOfLot,dblDelta,intBrokerageAccountId,strInstrumentType,strEntityName)
SELECT strCommodityCode ,strContractNumber,intContractHeaderId,strInternalTradeNo,intFutOptTransactionHeaderId,strType,strLocationName,strContractEndMonth, strContractEndMonthNearBy,
	  		 Convert(decimal(24,10),dbo.fnCTConvertQuantityToTargetCommodityUOM(cuc.intCommodityUnitMeasureId,
		case when isnull(@intUnitMeasureId,0) = 0 then cuc.intCommodityUnitMeasureId else cuc1.intCommodityUnitMeasureId end,dblTotal)) dblTotal,
	case when isnull(@strUnitMeasure,'')='' then um.strUnitMeasure else @strUnitMeasure end as strUnitMeasure  ,strAccountNumber,strTranType,dblNoOfLot,dblDelta,
	intBrokerageAccountId,strInstrumentType,strEntityName  FROM @List t
	JOIN tblICCommodityUnitMeasure cuc on t.intCommodityId=cuc.intCommodityId and cuc.ysnDefault=1 		
	JOIN tblICUnitMeasure um on um.intUnitMeasureId=cuc.intUnitMeasureId
	LEFT JOIN tblICCommodityUnitMeasure cuc1 on t.intCommodityId=cuc1.intCommodityId and @intUnitMeasureId=cuc1.intUnitMeasureId
	WHERE t.intCommodityId= @intCommodityId 
END
SELECT @mRowNumber = MIN(intCommodityIdentity)	FROM @Commodity	WHERE intCommodityIdentity > @mRowNumber	
END
END

UPDATE @FinalList set strContractEndMonth = 'Near By' where CONVERT(DATETIME,'01 '+ strContractEndMonth) < CONVERT(DATETIME,getdate())
DELETE FROM @List
INSERT INTO @List (strCommodityCode ,strContractNumber,intContractHeaderId,strInternalTradeNo,intFutOptTransactionHeaderId,strType,strLocationName,strContractEndMonth,strContractEndMonthNearBy,dblTotal,strUnitMeasure,strAccountNumber,strTranType,dblNoOfLot,dblDelta,intBrokerageAccountId,strInstrumentType,strEntityName )
SELECT strCommodityCode ,strContractNumber,intContractHeaderId,strInternalTradeNo,intFutOptTransactionHeaderId,strType,strLocationName,strContractEndMonth, strContractEndMonthNearBy,
	isnull(dblTotal,0)  dblTotal,
	strUnitMeasure,strAccountNumber,strTranType,dblNoOfLot,dblDelta,intBrokerageAccountId,strInstrumentType,strEntityName  FROM @FinalList WHERE strContractEndMonth = 'Near By' 

INSERT INTO @List (strCommodityCode ,strContractNumber,intContractHeaderId,strInternalTradeNo,intFutOptTransactionHeaderId,strType,strLocationName,strContractEndMonth,strContractEndMonthNearBy,dblTotal,strUnitMeasure,strAccountNumber,strTranType,dblNoOfLot,dblDelta,intBrokerageAccountId,strInstrumentType,strEntityName )
SELECT strCommodityCode ,strContractNumber,intContractHeaderId,strInternalTradeNo,intFutOptTransactionHeaderId,strType,strLocationName,strContractEndMonth, strContractEndMonthNearBy,
	isnull(dblTotal,0) dblTotal,
	strUnitMeasure,strAccountNumber,strTranType,dblNoOfLot,dblDelta,intBrokerageAccountId,strInstrumentType,strEntityName  FROM @FinalList WHERE strContractEndMonth <> 'Near By' 
	ORDER BY CONVERT(DATETIME,'01 '+ strContractEndMonth) asc

INSERT into @List (strCommodityCode ,strContractNumber,intContractHeaderId,strInternalTradeNo,intFutOptTransactionHeaderId,strType,strLocationName,strContractEndMonth,strContractEndMonthNearBy,dblTotal,strUnitMeasure,strAccountNumber,strTranType,dblNoOfLot,dblDelta,intBrokerageAccountId,strInstrumentType,strEntityName )
SELECT strCommodityCode ,strContractNumber,intContractHeaderId,strInternalTradeNo,intFutOptTransactionHeaderId,'Position',strLocationName,strContractEndMonth, strContractEndMonthNearBy,
	isnull(dblTotal,0) dblTotal,
	strUnitMeasure,strAccountNumber,strTranType,dblNoOfLot,dblDelta,intBrokerageAccountId,strInstrumentType,strEntityName  FROM @List 

UPDATE @List set intSeqNo = 1 where strType='Purchase DP (Priced Later)'
UPDATE @List set intSeqNo = 2 where strType='Purchase Priced'
UPDATE @List set intSeqNo = 3 where strType='Purchase Basis'
UPDATE @List set intSeqNo = 4 where strType='Purchase HTA'
UPDATE @List set intSeqNo = 5 where strType='Sale DP (Priced Later)'
UPDATE @List set intSeqNo = 6 where strType='Sale Priced'
UPDATE @List set intSeqNo = 7 where strType='Sale Basis'
UPDATE @List set intSeqNo = 8 where strType='Sale HTA'
UPDATE @List set intSeqNo = 9 where strType='Net Hedge'
UPDATE @List set intSeqNo = 10 where strType='Position'


DECLARE @FinalListforReport AS TABLE (  
     intMonthOrder INT IDENTITY(1,1),
	 intSeqNo int,
	 strCommodityCode NVARCHAR(200),
	 strContractEndMonth NVARCHAR(200),
	 dblTotal numeric(24, 10),
	 strType NVARCHAR(200),
	 intMonthSeq int
)
IF isnull(@intVendorId,0) = 0
BEGIN
	INSERT INTO @FinalListforReport (strCommodityCode,strContractEndMonth,dblTotal,strType,intMonthSeq,intSeqNo)
	SELECT strCommodityCode ,strContractEndMonth,sum(dblTotal) dblTotal,strType,1 intMonthSeq,intSeqNo
	FROM @List where dblTotal <> 0  and strContractEndMonth='Near By'
	GROUP BY intSeqNo,strCommodityCode ,strContractEndMonth,strType

	INSERT INTO @FinalListforReport (strCommodityCode,strContractEndMonth,dblTotal,strType,intMonthSeq,intSeqNo)
	SELECT strCommodityCode ,strContractEndMonth,sum(dblTotal) dblTotal,strType,RANK() OVER (ORDER BY CONVERT(DATETIME,'01 '+ strContractEndMonth) )+1 intMonthSeq,intSeqNo
	FROM @List where dblTotal <> 0  and strContractEndMonth<>'Near By'
	group by strCommodityCode ,strContractEndMonth,strType,intSeqNo
	order by CONVERT(DATETIME,'01 '+ strContractEndMonth) 

END
ELSE
BEGIN
	INSERT INTO @FinalListforReport (intSeqNo,strCommodityCode,strContractEndMonth,dblTotal,strType,intMonthSeq)
	SELECT intSeqNo,strCommodityCode ,strContractEndMonth,sum(dblTotal) dblTotal,strType,1
	FROM @List where dblTotal <> 0  --and strType NOT like '%'+@strPurchaseSales+'%'
	 and  strType<>'Net Hedge' and  strContractEndMonth='Near By'
	GROUP BY intSeqNo,strCommodityCode ,strContractEndMonth,strType 

	INSERT INTO @FinalListforReport (intSeqNo,strCommodityCode,strContractEndMonth,dblTotal,strType,intMonthSeq)

	SELECT intSeqNo,strCommodityCode ,strContractEndMonth,sum(dblTotal) dblTotal,strType,RANK() OVER (ORDER BY strContractEndMonth)+1 intMonthSeq 
	FROM @List where dblTotal <> 0 -- and strType NOT like '%'+@strPurchaseSales+'%'
	 and  strType<>'Net Hedge'  and strContractEndMonth<>'Near By'
	GROUP BY intSeqNo,strCommodityCode ,strContractEndMonth,strType
	ORDER BY CONVERT(DATETIME,'01 '+ strContractEndMonth) 

END
SELECT intMonthSeq+.123456 intSeqNo,strCommodityCode,strContractEndMonth,dblTotal,strType,intMonthSeq+.123456  as intMonthOrder,intSeqNo,@xmlParam as xmlParam FROM @FinalListforReport ORDER BY intMonthOrder asc