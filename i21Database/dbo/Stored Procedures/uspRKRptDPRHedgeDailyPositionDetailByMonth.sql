CREATE PROCEDURE [dbo].[uspRKRptDPRHedgeDailyPositionDetailByMonth]
		@xmlParam NVARCHAR(MAX) = NULL
AS

BEGIN
	DECLARE @idoc INT
		,@intCommodityId nvarchar(max)
		,@intLocationId nvarchar(max) = NULL		
		,@intVendorId int = null
		,@strPurchaseSales nvarchar(50) = NULL
		,@strPositionIncludes nvarchar(50) = NULL
		,@dtmToDate datetime = null
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

if isnull(@strPurchaseSales,'') <> ''
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

SELECT  @strCommodityCode = strCommodityCode FROM tblICCommodity	WHERE intCommodityId IN (SELECT intCommodityId FROM @Commodity)

	DECLARE @List AS TABLE (intRowNumber INT IDENTITY
		, intContractHeaderId INT
		, strContractNumber NVARCHAR(200)
		, intFutOptTransactionHeaderId INT
		, strInternalTradeNo NVARCHAR(200)
		, intCommodityId INT
		, strCommodityCode NVARCHAR(200)
		, strType NVARCHAR(50)
		, strLocationName NVARCHAR(100)
		, strContractEndMonth NVARCHAR(50)
		, strContractEndMonthNearBy NVARCHAR(50)
		, dblTotal DECIMAL(24,10)
		, intSeqNo INT
		, strUnitMeasure NVARCHAR(50)
		, intFromCommodityUnitMeasureId int
		, intToCommodityUnitMeasureId int
		, strAccountNumber NVARCHAR(100)
		, strTranType NVARCHAR(20)
		, dblNoOfLot NUMERIC(24, 10)
		, dblDelta NUMERIC(24, 10)
		, intBrokerageAccountId int
		, strInstrumentType NVARCHAR(50)
		, strEntityName NVARCHAR(100)
		, intItemId INT
		, strItemNo NVARCHAR(100)
		, intCategoryId INT
		, strCategory NVARCHAR(100)
		, intFutureMarketId INT
		, strFutMarketName NVARCHAR(100)
		, intFutureMonthId INT
		, strFutureMonth NVARCHAR(100)
		, dtmDeliveryDate DATETIME
		, strBrokerTradeNo NVARCHAR(100)
		, strNotes NVARCHAR(100)
		, ysnPreCrush BIT)
	
	DECLARE @FinalList AS TABLE (intRowNumber INT IDENTITY
		, intContractHeaderId INT
		, strContractNumber NVARCHAR(200)
		, intFutOptTransactionHeaderId INT
		, strInternalTradeNo NVARCHAR(200)
		, intCommodityId INT
		, strCommodityCode NVARCHAR(200)
		, strType NVARCHAR(50)
		, strLocationName NVARCHAR(100)
		, strContractEndMonth NVARCHAR(50)
		, strContractEndMonthNearBy NVARCHAR(50)
		, dblTotal DECIMAL(24,10)
		, intSeqNo INT
		, strUnitMeasure NVARCHAR(50)
		, intFromCommodityUnitMeasureId INT
		, intToCommodityUnitMeasureId INT
		, strAccountNumber NVARCHAR(100)
		, strTranType NVARCHAR(20)
		, dblNoOfLot NUMERIC(24, 10)
		, dblDelta NUMERIC(24, 10)
		, intBrokerageAccountId int
		, strInstrumentType NVARCHAR(50)
		, strEntityName NVARCHAR(100)
		, intItemId INT
		, strItemNo NVARCHAR(100)
		, intCategoryId INT
		, strCategory NVARCHAR(100)
		, intFutureMarketId INT
		, strFutMarketName NVARCHAR(100)
		, intFutureMonthId INT
		, strFutureMonth NVARCHAR(100)
		, dtmDeliveryDate DATETIME
		, strBrokerTradeNo NVARCHAR(100)
		, strNotes NVARCHAR(100)
		, ysnPreCrush BIT)


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
		DECLARE @tblGetOpenContractDetail TABLE (intRowNum INT
			, strCommodityCode  NVARCHAR(100)
			, intCommodityId INT
			, intContractHeaderId INT
			, strContractNumber  NVARCHAR(100)
			, strLocationName  NVARCHAR(100)
			, dtmEndDate DATETIME
			, strFutureMonth NVARCHAR(100)
			, dblBalance DECIMAL(24,10)
			, intUnitMeasureId INT
			, intPricingTypeId INT
			, intContractTypeId INT
			, intCompanyLocationId INT
			, strContractType NVARCHAR(100)
			, strPricingType NVARCHAR(100)
			, intCommodityUnitMeasureId INT
			, intContractDetailId INT
			, intContractStatusId INT
			, intEntityId INT
			, intCurrencyId INT
			, strType NVARCHAR(100)
			, intItemId INT
			, strItemNo NVARCHAR(100)
			, dtmContractDate DATETIME
			, strEntityName NVARCHAR(100)
			, strCustomerContract NVARCHAR(100)
			, intFutureMarketId INT
			, intFutureMonthId INT
			, intCategoryId INT
			, strCategory NVARCHAR(100)
			, strFutMarketName NVARCHAR(100)
			, dtmDeliveryDate DATETIME)

		INSERT INTO @tblGetOpenContractDetail (intRowNum
			, strCommodityCode
			, intCommodityId
			, intContractHeaderId
			, strContractNumber
			, strLocationName
			, dtmEndDate
			, strFutureMonth
			, dblBalance
			, intUnitMeasureId
			, intPricingTypeId
			, intContractTypeId
			, intCompanyLocationId
			, strContractType
			, strPricingType
			, intCommodityUnitMeasureId
			, intContractDetailId
			, intContractStatusId
			, intEntityId
			, intCurrencyId
			, strType
			, intItemId
			, strItemNo
			, dtmContractDate
			, strEntityName
			, strCustomerContract
			, intFutureMarketId
			, intFutureMonthId
			, intCategoryId
			, strCategory
			, strFutMarketName
			, dtmDeliveryDate)
		SELECT intRowNum = ROW_NUMBER() OVER (PARTITION BY CD.intContractDetailId ORDER BY dtmContractDate DESC)
			, strCommodityCode
			, intCommodityId
			, intContractHeaderId
			, strContractNumber
			, strLocationName
			, dtmEndDate
			, strFutureMonth
			, CD.dblQuantity + ISNULL(SeqHis.dblTransactionQuantity,0) AS dblBalance
			, intUnitMeasureId
			, intPricingTypeId
			, intContractTypeId
			, intCompanyLocationId
			, strContractType
			, strPricingType
			, intCommodityUnitMeasureId
			, CD.intContractDetailId
			, intContractStatusId
			, intEntityId
			, intCurrencyId
			, strType
			, intItemId
			, strItemNo
			, dtmContractDate
			, strEntityName
			, strCustomerContract
			, intFutureMarketId
			, intFutureMonthId
			, intCategoryId
			, strCategory
			, strFutMarketName
			, CD.dtmEndDate
		FROM vyuRKContractDetail CD
		OUTER APPLY (
			select 
				sum(dblTransactionQuantity) as dblTransactionQuantity
				,intContractDetailId 
			from vyuCTSequenceUsageHistory 
			where strFieldName = 'Balance' 
				and ysnDeleted = 0
				and CONVERT(DATETIME, CONVERT(VARCHAR(10), dtmScreenDate, 110), 110) <= CONVERT(DATETIME, CONVERT(VARCHAR(10), @dtmToDate, 110), 110)
				and intContractDetailId = CD.intContractDetailId
			group by intContractDetailId
		) SeqHis
		WHERE CONVERT(DATETIME, CONVERT(VARCHAR(10), dtmContractDate, 110), 110) <= CONVERT(DATETIME, CONVERT(VARCHAR(10), @dtmToDate, 110), 110)
			AND intCommodityId = @intCommodityId
			AND CD.intContractStatusId <> 6

		DECLARE @tblGetOpenFutureByDate TABLE (intFutOptTransactionId INT
			, intOpenContract INT
			, strCommodityCode NVARCHAR(100) COLLATE Latin1_General_CI_AS
			, strInternalTradeNo NVARCHAR(100) COLLATE Latin1_General_CI_AS
			, strLocationName NVARCHAR(100) COLLATE Latin1_General_CI_AS
			, dblContractSize NUMERIC(24,10)
			, strFutureMarket NVARCHAR(100) COLLATE Latin1_General_CI_AS
			, strFutureMonth NVARCHAR(100) COLLATE Latin1_General_CI_AS
			, strOptionMonth NVARCHAR(100) COLLATE Latin1_General_CI_AS
			, dblStrike NUMERIC(24,10)
			, strOptionType NVARCHAR(100) COLLATE Latin1_General_CI_AS
			, strInstrumentType NVARCHAR(100) COLLATE Latin1_General_CI_AS
			, strBrokerAccount NVARCHAR(100) COLLATE Latin1_General_CI_AS
			, strBroker NVARCHAR(100) COLLATE Latin1_General_CI_AS
			, strNewBuySell NVARCHAR(100) COLLATE Latin1_General_CI_AS
			, intFutOptTransactionHeaderId INT
			, ysnPreCrush BIT
			, strNotes NVARCHAR(MAX) COLLATE Latin1_General_CI_AS
			, strBrokerTradeNo NVARCHAR(100) COLLATE Latin1_General_CI_AS)

		INSERT INTO @tblGetOpenFutureByDate (intFutOptTransactionId
			, intOpenContract
			, strCommodityCode
			, strInternalTradeNo
			, strLocationName
			, dblContractSize
			, strFutureMarket
			, strFutureMonth
			, strOptionMonth
			, dblStrike
			, strOptionType
			, strInstrumentType
			, strBrokerAccount
			, strBroker
			, strNewBuySell
			, intFutOptTransactionHeaderId
			, ysnPreCrush
			, strNotes
			, strBrokerTradeNo)
		EXEC uspRKGetOpenContractByDate @intCommodityId, @dtmToDate

		
		INSERT INTO @List (strCommodityCode
			, intCommodityId
			, intContractHeaderId
			, strContractNumber
			, strType
			, strLocationName
			, strContractEndMonth
			, strContractEndMonthNearBy
			, dblTotal
			, intFromCommodityUnitMeasureId
			, strEntityName
			, intItemId
			, strItemNo
			, intCategoryId
			, strCategory
			, intFutureMarketId
			, strFutMarketName
			, intFutureMonthId
			, strFutureMonth
			, dtmDeliveryDate)
		SELECT strCommodityCode
			, CD.intCommodityId
			, intContractHeaderId
			, strContractNumber
			, CD.strType
			, strLocationName
			, RIGHT(CONVERT(VARCHAR(11),dtmEndDate,106),8) strContractEndMonth,RIGHT(CONVERT(VARCHAR(11),dtmEndDate,106),8)
			, dblTotal = (CASE WHEN intContractTypeId = 1 THEN dbo.fnCTConvertQuantityToTargetCommodityUOM(ium.intCommodityUnitMeasureId, @intCommodityUnitMeasureId, ISNULL((CD.dblBalance), 0))
							ELSE - dbo.fnCTConvertQuantityToTargetCommodityUOM(ium.intCommodityUnitMeasureId, @intCommodityUnitMeasureId, ISNULL((CD.dblBalance), 0)) END)
			, CD.intUnitMeasureId
			, CD.strEntityName
			, intItemId
			, strItemNo
			, intCategoryId
			, strCategory
			, intFutureMarketId
			, strFutMarketName
			, intFutureMonthId
			, strFutureMonth
			, CD.dtmDeliveryDate
		FROM @tblGetOpenContractDetail CD
		JOIN tblICCommodityUnitMeasure ium ON ium.intCommodityId = CD.intCommodityId AND CD.intUnitMeasureId = ium.intUnitMeasureId AND CD.intContractStatusId <> 3
			AND intCompanyLocationId IN (SELECT intCompanyLocationId FROM tblSMCompanyLocation
										WHERE ISNULL(ysnLicensed, 0) = CASE WHEN @strPositionIncludes = 'licensed storage' THEN 1
																			WHEN @strPositionIncludes = 'Non-licensed storage' THEN 0
																			ELSE ISNULL(ysnLicensed, 0) END)
		WHERE intContractTypeId IN (1,2) AND CD.intCommodityId = @intCommodityId
			AND intCompanyLocationId = CASE WHEN ISNULL(@intLocationId, 0) = 0 THEN intCompanyLocationId ELSE @intLocationId END
			AND  CD.intEntityId = CASE WHEN ISNULL(@intVendorId, 0) = 0 THEN CD.intEntityId ELSE @intVendorId END
			
		INSERT INTO @List (strCommodityCode
			, intCommodityId
			, strInternalTradeNo
			, intFutOptTransactionHeaderId
			, strType
			, strLocationName
			, strContractEndMonth
			, strContractEndMonthNearBy
			, dblTotal
			, intFromCommodityUnitMeasureId
			, strAccountNumber
			, strTranType
			, intBrokerageAccountId
			, strInstrumentType
			, dblNoOfLot
			, ysnPreCrush
			, strNotes
			, strBrokerTradeNo
			, strFutMarketName)
		SELECT strCommodityCode
			, intCommodityId
			, strInternalTradeNo
			, intFutOptTransactionHeaderId
			, 'Net Hedge'
			, strLocationName
			, strFutureMonth = RIGHT(CONVERT(VARCHAR(11), strFutureMonth, 106), 8)
			, dtmFutureMonthsDate = RIGHT(CONVERT(VARCHAR(11), dtmFutureMonthsDate, 106), 8)
			, HedgedQty
			, intUnitMeasureId
			, strAccountNumber
			, strTranType
			, intBrokerageAccountId
			, strInstrumentType
			, dblNoOfLot
			, ysnPreCrush
			, strNotes
			, strBrokerTradeNo
			, t.strFutureMarket
		FROM (
			SELECT DISTINCT t.strCommodityCode
				, strInternalTradeNo
				, intFutOptTransactionHeaderId
				, th.intCommodityId
				, dtmFutureMonthsDate
				, HedgedQty = dbo.fnCTConvertQuantityToTargetCommodityUOM(cuc1.intCommodityUnitMeasureId, @intCommodityUnitMeasureId, ISNULL(intOpenContract, 0) * t.dblContractSize)
				, l.strLocationName
				, strFutureMonth = LEFT(t.strFutureMonth, 4) + '20' + CONVERT(NVARCHAR(2),intYear)
				, m.intUnitMeasureId
				, strAccountNumber = e.strName + '-' + ba.strAccountNumber
				, strTranType = strNewBuySell
				, ba.intBrokerageAccountId
				, t.strInstrumentType as strInstrumentType
				, dblNoOfLot = ISNULL(intOpenContract, 0)
				, ysnPreCrush
				, t.strNotes
				, strBrokerTradeNo
				, t.strFutureMarket
			FROM @tblGetOpenFutureByDate t
			JOIN tblICCommodity th ON th.strCommodityCode = t.strCommodityCode
			JOIN tblSMCompanyLocation l ON l.strLocationName = t.strLocationName
			JOIN tblRKFutureMarket m ON m.strFutMarketName = t.strFutureMarket
			LEFT JOIN tblRKBrokerageAccount ba ON ba.strAccountNumber = t.strBrokerAccount
			INNER JOIN tblEMEntity e ON e.strName = t.strBroker AND t.strInstrumentType = 'Futures'
			JOIN tblICCommodityUnitMeasure cuc1 ON cuc1.intCommodityId = @intCommodityId AND m.intUnitMeasureId = cuc1.intUnitMeasureId
			INNER JOIN tblRKFuturesMonth fm ON fm.strFutureMonth = t.strFutureMonth AND fm.intFutureMarketId = m.intFutureMarketId AND fm.ysnExpired = 0
			WHERE th.intCommodityId IN (SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCommodityId, ','))
				AND intCompanyLocationId = ISNULL(@intLocationId, intCompanyLocationId)
				AND e.intEntityId = ISNULL(@intVendorId, e.intEntityId)
				AND intCompanyLocationId IN (SELECT intCompanyLocationId FROM tblSMCompanyLocation
											WHERE ISNULL(ysnLicensed, 0) = CASE WHEN @strPositionIncludes = 'licensed storage' THEN 1
																				WHEN @strPositionIncludes = 'Non-licensed storage' THEN 0
																				ELSE isnull(ysnLicensed, 0) END)
		) t

		--Option NetHEdge
		INSERT INTO @List (strCommodityCode
			, intCommodityId
			, strInternalTradeNo
			, intFutOptTransactionHeaderId
			, strType
			, strLocationName
			, strContractEndMonth
			, strContractEndMonthNearBy
			, dblTotal
			, intFromCommodityUnitMeasureId
			, strAccountNumber
			, strTranType
			, dblNoOfLot
			, dblDelta
			, intBrokerageAccountId
			, strInstrumentType
			, ysnPreCrush
			, strNotes
			, strBrokerTradeNo
			, strFutMarketName)
		SELECT DISTINCT t.strCommodityCode
			, th.intCommodityId
			, t.strInternalTradeNo
			, intFutOptTransactionHeaderId
			, 'Net Hedge'
			, t.strLocationName
			, strFutureMonth = LEFT(t.strFutureMonth, 4) + '20' + CONVERT(NVARCHAR(2), fm.intYear)
			, dtmFutureMonthsDate = LEFT(t.strFutureMonth, 4) + '20' + CONVERT(NVARCHAR(2), fm.intYear)
			, dblTotal = (intOpenContract * ISNULL((SELECT TOP 1 dblDelta
													FROM tblRKFuturesSettlementPrice sp
													INNER JOIN tblRKOptSettlementPriceMarketMap mm ON sp.intFutureSettlementPriceId = mm.intFutureSettlementPriceId
													WHERE intFutureMarketId = m.intFutureMarketId AND mm.intOptionMonthId = om.intOptionMonthId 
														AND mm.intTypeId = CASE WHEN t.strOptionType = 'Put' THEN 1 ELSE 2 END
														AND t.dblStrike = mm.dblStrike
													ORDER BY dtmPriceDate DESC), 0) * m.dblContractSize)
			, m.intUnitMeasureId
			, strAccountNumber = e.strName + '-' + strAccountNumber
			, TranType = strNewBuySell
			, dblNoOfLot = intOpenContract
			, dblDelta = ISNULL((SELECT TOP 1 dblDelta
										FROM tblRKFuturesSettlementPrice sp
										INNER JOIN tblRKOptSettlementPriceMarketMap mm ON sp.intFutureSettlementPriceId = mm.intFutureSettlementPriceId
										WHERE intFutureMarketId = m.intFutureMarketId AND mm.intOptionMonthId = om.intOptionMonthId
											AND mm.intTypeId = CASE WHEN t.strOptionType = 'Put' THEN 1 ELSE 2 END
											AND t.dblStrike = mm.dblStrike
										ORDER BY dtmPriceDate DESC), 0)
			, ba.intBrokerageAccountId
			, strInstrumentType = 'Options'
			, ysnPreCrush
			, t.strNotes
			, strBrokerTradeNo
			, t.strFutureMarket
		FROM @tblGetOpenFutureByDate t
		JOIN tblICCommodity th ON th.strCommodityCode = t.strCommodityCode
		JOIN tblSMCompanyLocation l ON l.strLocationName = t.strLocationName
		JOIN tblRKFutureMarket m ON m.strFutMarketName = t.strFutureMarket
		JOIN tblRKOptionsMonth om ON om.strOptionMonth = t.strOptionMonth
		INNER JOIN tblRKBrokerageAccount ba ON t.strBrokerAccount = ba.strAccountNumber
		INNER JOIN tblEMEntity e ON e.strName = t.strBroker AND t.strInstrumentType = 'Options'
		INNER JOIN tblRKFuturesMonth fm ON fm.strFutureMonth = t.strFutureMonth AND fm.intFutureMarketId = m.intFutureMarketId AND fm.ysnExpired = 0
		WHERE th.intCommodityId = @intCommodityId AND intCompanyLocationId = ISNULL(@intLocationId, intCompanyLocationId)
			AND t.intFutOptTransactionId NOT IN (SELECT intFutOptTransactionId FROM tblRKOptionsPnSExercisedAssigned)
			AND t.intFutOptTransactionId NOT IN (SELECT intFutOptTransactionId FROM tblRKOptionsPnSExpired)
			AND e.intEntityId = ISNULL(@intVendorId, e.intEntityId)
			AND intCompanyLocationId IN (SELECT intCompanyLocationId FROM tblSMCompanyLocation
										WHERE ISNULL(ysnLicensed, 0) = CASE WHEN @strPositionIncludes = 'licensed storage' THEN 1
																			WHEN @strPositionIncludes = 'Non-licensed storage' THEN 0
																			ELSE isnull(ysnLicensed, 0) END)
			
		--Net Hedge option end
		DECLARE @intUnitMeasureId int
		DECLARE @strUnitMeasure NVARCHAR(50)
		SELECT TOP 1 @intUnitMeasureId = intUnitMeasureId FROM tblRKCompanyPreference
		SELECT @strUnitMeasure = strUnitMeasure FROM tblICUnitMeasure WHERE intUnitMeasureId = @intUnitMeasureId
			
		INSERT INTO @FinalList (strCommodityCode
			, strContractNumber
			, intContractHeaderId
			, strInternalTradeNo
			, intFutOptTransactionHeaderId
			, strType
			, strLocationName
			, strContractEndMonth
			, strContractEndMonthNearBy
			, dblTotal
			, strUnitMeasure
			, strAccountNumber
			, strTranType
			, dblNoOfLot
			, dblDelta
			, intBrokerageAccountId
			, strInstrumentType
			, strEntityName
			, intItemId
			, strItemNo
			, intCategoryId
			, strCategory
			, intFutureMarketId
			, strFutMarketName
			, intFutureMonthId
			, strFutureMonth
			, dtmDeliveryDate
			, strBrokerTradeNo
			, strNotes
			, ysnPreCrush)
		SELECT strCommodityCode
			, strContractNumber
			, intContractHeaderId
			, strInternalTradeNo
			, intFutOptTransactionHeaderId
			, strType
			, strLocationName
			, strContractEndMonth
			, strContractEndMonthNearBy
			, dblTotal = CONVERT(DECIMAL(24,10), dbo.fnCTConvertQuantityToTargetCommodityUOM(cuc.intCommodityUnitMeasureId, CASE WHEN ISNULL(@intUnitMeasureId,0) = 0 THEN cuc.intCommodityUnitMeasureId ELSE cuc1.intCommodityUnitMeasureId END, dblTotal))
			, strUnitMeasure = ISNULL(@strUnitMeasure, um.strUnitMeasure)
			, strAccountNumber
			, strTranType
			, dblNoOfLot
			, dblDelta
			, intBrokerageAccountId
			, strInstrumentType
			, strEntityName
			, intItemId
			, strItemNo
			, intCategoryId
			, strCategory
			, intFutureMarketId
			, strFutMarketName
			, intFutureMonthId
			, strFutureMonth
			, dtmDeliveryDate
			, strBrokerTradeNo
			, strNotes
			, ysnPreCrush
		FROM @List t
		JOIN tblICCommodityUnitMeasure cuc ON t.intCommodityId = cuc.intCommodityId AND cuc.ysnDefault = 1
		JOIN tblICUnitMeasure um ON um.intUnitMeasureId = cuc.intUnitMeasureId
		LEFT JOIN tblICCommodityUnitMeasure cuc1 ON t.intCommodityId = cuc1.intCommodityId AND @intUnitMeasureId = cuc1.intUnitMeasureId
		WHERE t.intCommodityId = @intCommodityId
		END

		SELECT @mRowNumber = MIN(intCommodityIdentity)	FROM @Commodity	WHERE intCommodityIdentity > @mRowNumber	
	END
END

	UPDATE @FinalList set strContractEndMonth = 'Near By' where CONVERT(DATETIME,'01 '+ strContractEndMonth) < CONVERT(DATETIME,getdate())
	DELETE FROM @List

	INSERT INTO @List (strCommodityCode
		, strContractNumber
		, intContractHeaderId
		, strInternalTradeNo
		, intFutOptTransactionHeaderId
		, strType
		, strLocationName
		, strContractEndMonth
		, strContractEndMonthNearBy
		, dblTotal
		, strUnitMeasure
		, strAccountNumber
		, strTranType
		, dblNoOfLot
		, dblDelta
		, intBrokerageAccountId
		, strInstrumentType
		, strEntityName
		, intItemId
		, strItemNo
		, intCategoryId
		, strCategory
		, intFutureMarketId
		, strFutMarketName
		, intFutureMonthId
		, strFutureMonth
		, dtmDeliveryDate
		, strBrokerTradeNo
		, strNotes
		, ysnPreCrush)
	SELECT strCommodityCode
		, strContractNumber
		, intContractHeaderId
		, strInternalTradeNo
		, intFutOptTransactionHeaderId
		, strType
		, strLocationName
		, strContractEndMonth
		, strContractEndMonthNearBy
		, dblTotal =  isnull(dblTotal, 0)
		, strUnitMeasure
		, strAccountNumber
		, strTranType
		, dblNoOfLot
		, dblDelta
		, intBrokerageAccountId
		, strInstrumentType
		, strEntityName
		, intItemId
		, strItemNo
		, intCategoryId
		, strCategory
		, intFutureMarketId
		, strFutMarketName
		, intFutureMonthId
		, strFutureMonth
		, dtmDeliveryDate
		, strBrokerTradeNo
		, strNotes
		, ysnPreCrush
	FROM @FinalList
	WHERE strContractEndMonth = 'Near By'

	INSERT INTO @List (strCommodityCode
		, strContractNumber
		, intContractHeaderId
		, strInternalTradeNo
		, intFutOptTransactionHeaderId
		, strType
		, strLocationName
		, strContractEndMonth
		, strContractEndMonthNearBy
		, dblTotal
		, strUnitMeasure
		, strAccountNumber
		, strTranType
		, dblNoOfLot
		, dblDelta
		, intBrokerageAccountId
		, strInstrumentType
		, strEntityName
		, intItemId
		, strItemNo
		, intCategoryId
		, strCategory
		, intFutureMarketId
		, strFutMarketName
		, intFutureMonthId
		, strFutureMonth
		, dtmDeliveryDate
		, strBrokerTradeNo
		, strNotes
		, ysnPreCrush)
	SELECT strCommodityCode
		, strContractNumber
		, intContractHeaderId
		, strInternalTradeNo
		, intFutOptTransactionHeaderId
		, strType
		, strLocationName
		, strContractEndMonth
		, strContractEndMonthNearBy
		, dblTotal = isnull(dblTotal,0)
		, strUnitMeasure
		, strAccountNumber
		, strTranType
		, dblNoOfLot
		, dblDelta
		, intBrokerageAccountId
		, strInstrumentType
		, strEntityName
		, intItemId
		, strItemNo
		, intCategoryId
		, strCategory
		, intFutureMarketId
		, strFutMarketName
		, intFutureMonthId
		, strFutureMonth
		, dtmDeliveryDate
		, strBrokerTradeNo
		, strNotes
		, ysnPreCrush
	FROM @FinalList
	WHERE strContractEndMonth <> 'Near By'
	ORDER BY CONVERT(DATETIME, '01 ' + strContractEndMonth) ASC

	IF isnull(@intVendorId,0) = 0
	BEGIN
		INSERT INTO @List (strCommodityCode
			, strContractNumber
			, intContractHeaderId
			, strInternalTradeNo
			, intFutOptTransactionHeaderId
			, strType
			, strLocationName
			, strContractEndMonth
			, strContractEndMonthNearBy
			, dblTotal
			, strUnitMeasure
			, strAccountNumber
			, strTranType
			, dblNoOfLot
			, dblDelta
			, intBrokerageAccountId
			, strInstrumentType
			, strEntityName
			, intItemId
			, strItemNo
			, intCategoryId
			, strCategory
			, intFutureMarketId
			, strFutMarketName
			, intFutureMonthId
			, strFutureMonth
			, dtmDeliveryDate
			, strBrokerTradeNo
			, strNotes
			, ysnPreCrush)
		SELECT strCommodityCode
			, strContractNumber
			, intContractHeaderId
			, strInternalTradeNo
			, intFutOptTransactionHeaderId
			, 'Position'
			, strLocationName
			, strContractEndMonth
			, strContractEndMonthNearBy
			, dblTotal = ISNULL(dblTotal,0)
			, strUnitMeasure
			, strAccountNumber
			, strTranType
			, dblNoOfLot
			, dblDelta
			, intBrokerageAccountId
			, strInstrumentType
			, strEntityName
			, intItemId
			, strItemNo
			, intCategoryId
			, strCategory
			, intFutureMarketId
			, strFutMarketName
			, intFutureMonthId
			, strFutureMonth
			, dtmDeliveryDate
			, strBrokerTradeNo
			, strNotes
			, ysnPreCrush
		FROM @List
	END
	ELSE
	BEGIN
		INSERT INTO @List (strCommodityCode
			, strContractNumber
			, intContractHeaderId
			, strInternalTradeNo
			, intFutOptTransactionHeaderId
			, strType
			, strLocationName
			, strContractEndMonth
			, strContractEndMonthNearBy
			, dblTotal
			, strUnitMeasure
			, strAccountNumber
			, strTranType
			, dblNoOfLot
			, dblDelta
			, intBrokerageAccountId
			, strInstrumentType
			, strEntityName
			, intItemId
			, strItemNo
			, intCategoryId
			, strCategory
			, intFutureMarketId
			, strFutMarketName
			, intFutureMonthId
			, strFutureMonth
			, dtmDeliveryDate
			, strBrokerTradeNo
			, strNotes
			, ysnPreCrush)
		SELECT strCommodityCode
			, strContractNumber
			, intContractHeaderId
			, strInternalTradeNo
			, intFutOptTransactionHeaderId
			, 'Position'
			, strLocationName
			, strContractEndMonth
			, strContractEndMonthNearBy
			, dblTotal = ISNULL(dblTotal,0)
			, strUnitMeasure
			, strAccountNumber
			, strTranType
			, dblNoOfLot
			, dblDelta
			, intBrokerageAccountId
			, strInstrumentType
			, strEntityName
			, intItemId
			, strItemNo
			, intCategoryId
			, strCategory
			, intFutureMarketId
			, strFutMarketName
			, intFutureMonthId
			, strFutureMonth
			, dtmDeliveryDate
			, strBrokerTradeNo
			, strNotes
			, ysnPreCrush
		FROM @List
		WHERE strType NOT LIKE '%'+@strPurchaseSales+'%' AND  strType<>'Net Hedge'
	END

	--This is used to insert strType so that it will be displayed properly on Position Report Detail by Month (RM-1902)
	INSERT INTO @List (strCommodityCode
		, strContractNumber
		, intContractHeaderId
		, strInternalTradeNo
		, intFutOptTransactionHeaderId
		, strType
		, strContractEndMonth
		, dblTotal
		, intItemId
		, strItemNo
		, intCategoryId
		, strCategory
		, intFutureMarketId
		, strFutMarketName
		, intFutureMonthId
		, strFutureMonth
		, dtmDeliveryDate
		, strBrokerTradeNo
		, strNotes
		, ysnPreCrush)
	SELECT DISTINCT strCommodityCode
		, strContractNumber = NULL
		, intContractHeaderId = NULL
		, strInternalTradeNo = NULL
		, intFutOptTransactionHeaderId = NULL
		, strType
		, strContractEndMonth = 'Near By'
		, NULL
		, intItemId
		, strItemNo
		, intCategoryId
		, strCategory
		, intFutureMarketId
		, strFutMarketName
		, intFutureMonthId
		, strFutureMonth
		, dtmDeliveryDate
		, strBrokerTradeNo
		, strNotes
		, ysnPreCrush
	FROM @List

	UPDATE @List set intSeqNo = 1 where strType like 'Purchase%'
	UPDATE @List set intSeqNo = 2 where strType like 'Sale%'
	UPDATE @List set intSeqNo = 3 where strType='Net Hedge'
	UPDATE @List set intSeqNo = 4 where strType='Position'

	DECLARE @strType NVARCHAR(MAX)
	DECLARE @strContractEndMonth NVARCHAR(MAX)
	SELECT TOP 1 @strType = strType
		, @strContractEndMonth = strContractEndMonth
	FROM @List
	ORDER BY intRowNumber ASC

	DECLARE @ctr as int
	SELECT @ctr = COUNT(intRowNumber) FROM @List 

	IF OBJECT_ID('tempdb..#tmpList') IS NOT NULL
	DROP TABLE  #tmpList
	IF OBJECT_ID('tempdb..##tmpTry') IS NOT NULL
	DROP TABLE  ##tmpTry
	IF OBJECT_ID('tempdb..##tmpTry2') IS NOT NULL
	DROP TABLE  ##tmpTry2


	IF @ctr > 0 
	BEGIN

		select * into #tmpList
		from @List 
		where strType <> CASE WHEN isnull(@intVendorId,0) = 0 THEN '' ELSE 'Net Hedge' END


		DECLARE @cols AS NVARCHAR(MAX),
				@colstry AS NVARCHAR(MAX) = '',
				@query  AS NVARCHAR(MAX),
				@intColCount AS INT,
				@colCtr as int = 2


		DECLARE  @tmpColList TABLE(
			strType nvarchar(max),
			intSeqNo int
		)

		select @cols = STUFF((select ',' + QUOTENAME(strType) 
							from @List
							where strType not in('Position') and strType <> CASE WHEN isnull(@intVendorId,0) = 0 THEN '' ELSE 'Net Hedge' END
							group by strType, intSeqNo
							order by intSeqNo, strType
					FOR XML PATH(''), TYPE
					).value('.', 'NVARCHAR(MAX)') 
				,1,1,'')

		insert into @tmpColList (strType,intSeqNo)
		SELECT DISTINCT strType,intSeqNo
					from @List
					where strType not in('Position') and strType <> CASE WHEN isnull(@intVendorId,0) = 0 THEN '' ELSE 'Net Hedge' END
					order by intSeqNo, strType
					--group by strType


				WHILE EXISTS (SELECT TOP 1 strType FROM @tmpColList)
				BEGIN
					DECLARE @strCol AS NVARCHAR(max)
					SET @colCtr = @colCtr + 1;

					SELECT TOP 1 @strCol = strType FROM @tmpColList ORDER BY intSeqNo, strType
			

					SET @colstry = @colstry + '''' + @strCol + ''' as col' + cast(@colCtr as nvarchar(20)) + ','
			
					DELETE FROM @tmpColList WHERE strType = @strCol 

				END
			
				SET @colstry = @colstry + '''Position''as col' +  cast(@colCtr + 1 as nvarchar(20)) +' '

	
			set @query = N'

					SELECT 1 as col1 ,strContractEndMonth,' + @cols + N',Position into ##tmpTry from 
					 (
               			select * from (
							select strCommodityCode, strType, sum(dblTotal) as dblTotal, strContractEndMonth
							from #tmpList
							group by strContractEndMonth,strCommodityCode,strType
						) t
					) x
					pivot 
					(
						sum(dblTotal)
						for strType in (' + @cols + N',Position)
					) p  order by CASE WHEN  strContractEndMonth not in(''Near By'',''Total'') THEN CONVERT(DATETIME,''01 ''+strContractEndMonth) END
			 

					'

		exec (@query)


		exec ('select 0 as col1,''Year'' as col2, '+ @colstry +'into ##tmpTry2')


		 DECLARE @colCAST AS NVARCHAR(MAX)

		 select @colCAST = STUFF((SELECT ',CAST(CONVERT(varchar,cast(round(' + QUOTENAME([name]) + ',2)as money),1) as nvarchar(max))'
							from tempdb.sys.columns where object_id = (SELECT object_id FROM tempdb.sys.objects WHERE name = '##tmpTry') and [name] not in ('col1','strContractEndMonth')
					FOR XML PATH(''), TYPE
					).value('.', 'NVARCHAR(MAX)') 
				,1,1,'')

		 DECLARE @colSUM AS NVARCHAR(MAX)

		 select @colSUM = STUFF((SELECT ',CAST(CONVERT(varchar,cast(sum(' + QUOTENAME([name]) + ')as money),1) as nvarchar(max))'
							from tempdb.sys.columns where object_id = (SELECT object_id FROM tempdb.sys.objects WHERE name = '##tmpTry') and [name] not in ('col1','strContractEndMonth')
					FOR XML PATH(''), TYPE
					).value('.', 'NVARCHAR(MAX)') 
				,1,1,'')

		exec (N' SELECT *, '''+ @xmlParam +''' AS xmlParam , '''+ @strCommodityCode +''' AS strCommodityCode, '''+ @dtmToDate +''' AS dtmToDate FROM (
			select * from ##tmpTry2
		union all
		select col1,strContractEndMonth,
			' + @colCAST +'
		from ##tmpTry
		union all
		select 2 as col1,''Total'' strContractEndMonth,
			' + @colSUM +'
		from ##tmpTry
		) t ORDER BY col1 , CASE WHEN  col2 not in(''Near By'',''Year'',''Total'') THEN CONVERT(DATETIME,''01 ''+col2) END'
		)


	END
	ELSE
	BEGIN
		SELECT 
			'' as col1,
			'' as col2,
			'' as col3,
			'' as col4,
			'' as col5,
			'' as col6,
			'' as col7,
			'' as col8,
			'' as col9,
			'' as col10,
			'' as col11,
			'' as col12,
			@xmlParam as xmlParam,
			@strCommodityCode as strCommodityCode,
			@dtmToDate as dtmToDate

	END
