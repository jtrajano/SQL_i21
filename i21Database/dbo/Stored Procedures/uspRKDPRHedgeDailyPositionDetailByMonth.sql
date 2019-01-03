CREATE PROCEDURE [dbo].[uspRKDPRHedgeDailyPositionDetailByMonth]
	@intCommodityId NVARCHAR(MAX)
	, @intLocationId NVARCHAR(MAX) = NULL
	, @intVendorId INT = NULL
	, @strPurchaseSales NVARCHAR(50) = NULL
	, @strPositionIncludes NVARCHAR(100) = NULL
	, @dtmToDate DATETIME = NULL
	, @strByType NVARCHAR(50) = NULL

AS

BEGIN
	IF ISNULL(@strPurchaseSales, '') <> ''
	BEGIN
		IF @strPurchaseSales = 'Purchase'
		BEGIN
			SET @strPurchaseSales = 'Sale'
		END
		ELSE
		BEGIN
			SET @strPurchaseSales = 'Purchase'
		END
	END
	
	DECLARE @strCommodityCode NVARCHAR(50)

	DECLARE @Commodity AS TABLE(intCommodityIdentity int IDENTITY PRIMARY KEY
		, intCommodity INT)
	INSERT INTO @Commodity(intCommodity)
	SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCommodityId, ',')
	
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
		, strDeliveryDate NVARCHAR(50)
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
		, strDeliveryDate NVARCHAR(50)
		, strBrokerTradeNo NVARCHAR(100)
		, strNotes NVARCHAR(100)
		, ysnPreCrush BIT)
	
	DECLARE @mRowNumber INT
	DECLARE @intCommodityId1 INT
	DECLARE @strDescription NVARCHAR(50)
	DECLARE @intOneCommodityId INT
	DECLARE @intCommodityUnitMeasureId INT
	SELECT @mRowNumber = MIN(intCommodityIdentity) FROM @Commodity
	WHILE @mRowNumber > 0
	BEGIN
		SELECT @intCommodityId = intCommodity FROM @Commodity WHERE intCommodityIdentity = @mRowNumber
		SELECT @strDescription = strCommodityCode FROM tblICCommodity WHERE intCommodityId = @intCommodityId
		SELECT @intCommodityUnitMeasureId = intCommodityUnitMeasureId FROM tblICCommodityUnitMeasure WHERE intCommodityId = @intCommodityId AND ysnDefault = 1
		
		IF @intCommodityId > 0
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
				, intContractDetailId INT
				, intContractStatusId INT
				, intEntityId INT
				, intCurrencyId INT
				, strType NVARCHAR(100)
				, intItemId INT
				, strItemNo NVARCHAR(100)
				, dtmContractDate DATETIME
				, strEntityName NVARCHAR(100)
				, intFutureMarketId INT
				, intFutureMonthId INT
				, strCategory NVARCHAR(100)
				, strFutMarketName NVARCHAR(100)
				, strDeliveryDate NVARCHAR(50))
			
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
				, intContractDetailId
				, intContractStatusId
				, intEntityId
				, intCurrencyId
				, strType
				, intItemId
				, strItemNo
				, dtmContractDate
				, strEntityName
				, intFutureMarketId
				, intFutureMonthId
				, strCategory
				, strFutMarketName
				, strDeliveryDate)
			SELECT intRowNum = ROW_NUMBER() OVER (PARTITION BY CD.intContractDetailId ORDER BY dtmContractDate DESC)
				, strCommodityCode = CD.strCommodity
				, intCommodityId
				, intContractHeaderId
				, strContractNumber = CD.strContract
				, strLocationName
				, dtmEndDate
				, strFutureMonth
				, dblBalance = CD.dblQuantity
				, intUnitMeasureId
				, intPricingTypeId
				, intContractTypeId
				, intCompanyLocationId
				, strContractType
				, strPricingType
				, CD.intContractDetailId
				, intContractStatusId
				, intEntityId
				, intCurrencyId
				, strType = CD.strContractType + ' ' + CD.strPricingType
				, intItemId
				, strItemNo
				, dtmContractDate
				, strEntityName = CD.strCustomer
				, intFutureMarketId
				, intFutureMonthId
				, strCategory
				, strFutMarketName
				, strDeliveryDate = RIGHT(CONVERT(VARCHAR(11), CD.dtmEndDate, 106), 8)
			FROM dbo.fnCTGetContractBalance(null,null,null,'01-01-1900',@dtmToDate,NULL,NULL,NULL,NULL) CD
			WHERE CONVERT(DATETIME, CONVERT(VARCHAR(10), dtmContractDate, 110), 110) <= CONVERT(DATETIME, CONVERT(VARCHAR(10), @dtmToDate, 110), 110)
				AND intCommodityId = @intCommodityId

			DECLARE @tblGetOpenFutureByDate TABLE (intRowNum INT
				, dtmTransactionDate DATETIME
				, intFutOptTransactionId INT
				, intOpenContract INT
				, strCommodityCode NVARCHAR(200) COLLATE Latin1_General_CI_AS
				, strInternalTradeNo NVARCHAR(200) COLLATE Latin1_General_CI_AS
				, strLocationName NVARCHAR(200) COLLATE Latin1_General_CI_AS
				, dblContractSize NUMERIC(24,10)
				, strFutureMarket NVARCHAR(200) COLLATE Latin1_General_CI_AS
				, strFutureMonth NVARCHAR(200) COLLATE Latin1_General_CI_AS
				, strOptionMonth NVARCHAR(200) COLLATE Latin1_General_CI_AS
				, dblStrike NUMERIC(24,10)
				, strOptionType NVARCHAR(200) COLLATE Latin1_General_CI_AS
				, strInstrumentType NVARCHAR(200) COLLATE Latin1_General_CI_AS
				, strBrokerAccount NVARCHAR(200) COLLATE Latin1_General_CI_AS
				, strBroker NVARCHAR(200) COLLATE Latin1_General_CI_AS
				, strNewBuySell NVARCHAR(200) COLLATE Latin1_General_CI_AS
				, intFutOptTransactionHeaderId INT
				, intFutureMarketId INT
				, intFutureMonthId INT
				, strBrokerTradeNo NVARCHAR(100)
				, strNotes NVARCHAR(100)
				, ysnPreCrush BIT)
	
		INSERT INTO @tblGetOpenFutureByDate
		SELECT *
		FROM (
				SELECT intRowNum = ROW_NUMBER() OVER (PARTITION BY intFutOptTransactionId ORDER BY dtmTransactionDate DESC)
					, *
				FROM (
					--Futures Buy
					SELECT FOT.dtmTransactionDate
						, intFutOptTransactionId
						, intOpenContract
						, FOT.strCommodityCode
						, strInternalTradeNo
						, strLocationName
						, FOT.dblContractSize
						, FOT.strFutMarketName
						, FOT.strFutureMonth AS strFutureMonth
						, FOT.strOptionMonthYear AS strOptionMonth
						, dblStrike
						, strOptionType
						, FOT.strInstrumentType
						, FOT.strBrokerageAccount AS strBrokerAccount
						, FOT.strName AS strBroker
						, strBuySell
						, FOTH.intFutOptTransactionHeaderId
						, FOT.intFutureMarketId
						, FOT.intFutureMonthId
						, strBrokerTradeNo
						, strNotes
						, ysnPreCrush
					FROM tblRKFutOptTransactionHeader FOTH
					INNER JOIN vyuRKFutOptTransaction FOT ON FOTH.intFutOptTransactionHeaderId = FOT.intFutOptTransactionHeaderId
					WHERE FOT.strBuySell = 'Buy' AND FOT.strInstrumentType = 'Futures'
						AND CONVERT(DATETIME, CONVERT(VARCHAR(10), FOT.dtmTransactionDate, 110), 110) <= CONVERT(DATETIME, @dtmToDate)
						AND ISNULL(FOT.ysnPreCrush, 0) = 0
			
					UNION ALL
					--Futures Sell
					SELECT FOT.dtmTransactionDate
						, intFutOptTransactionId
						, intOpenContract
						, FOT.strCommodityCode
						, strInternalTradeNo
						, strLocationName
						, FOT.dblContractSize
						, FOT.strFutMarketName
						, FOT.strFutureMonth AS strFutureMonth
						, FOT.strOptionMonthYear AS strOptionMonth
						, dblStrike
						, strOptionType
						, FOT.strInstrumentType
						, FOT.strBrokerageAccount AS strBrokerAccount
						, FOT.strName AS strBroker
						, strBuySell
						, FOTH.intFutOptTransactionHeaderId
						, FOT.intFutureMarketId
						, FOT.intFutureMonthId
						, strBrokerTradeNo
						, strNotes
						, ysnPreCrush
					FROM tblRKFutOptTransactionHeader FOTH
					INNER JOIN vyuRKFutOptTransaction FOT ON FOTH.intFutOptTransactionHeaderId = FOT.intFutOptTransactionHeaderId
					WHERE FOT.strBuySell = 'Sell' AND FOT.strInstrumentType = 'Futures'
						AND CONVERT(DATETIME, CONVERT(VARCHAR(10), FOT.dtmTransactionDate, 110), 110) <= CONVERT(DATETIME, @dtmToDate)
						AND ISNULL(FOT.ysnPreCrush, 0) = 0
			
					UNION ALL
					--Options Buy
					SELECT FOT.dtmTransactionDate
						, intFutOptTransactionId
						, intOpenContract
						, FOT.strCommodityCode
						, strInternalTradeNo
						, strLocationName
						, FOT.dblContractSize
						, FOT.strFutMarketName
						, FOT.strFutureMonth AS strFutureMonth
						, FOT.strOptionMonthYear AS strOptionMonth
						, dblStrike
						, strOptionType
						, FOT.strInstrumentType
						, FOT.strBrokerageAccount AS strBrokerAccount
						, FOT.strName AS strBroker
						, strBuySell
						, FOTH.intFutOptTransactionHeaderId
						, FOT.intFutureMarketId
						, FOT.intFutureMonthId
						, strBrokerTradeNo
						, strNotes
						, ysnPreCrush
					FROM tblRKFutOptTransactionHeader FOTH
					INNER JOIN vyuRKFutOptTransaction FOT ON FOTH.intFutOptTransactionHeaderId = FOT.intFutOptTransactionHeaderId
					WHERE FOT.strBuySell = 'BUY' AND FOT.strInstrumentType = 'Options'
						AND CONVERT(DATETIME, CONVERT(VARCHAR(10), FOT.dtmTransactionDate, 110), 110) <= CONVERT(DATETIME, @dtmToDate)
						AND ISNULL(FOT.ysnPreCrush, 0) = 0
				
					UNION ALL
					--Options Sell
					SELECT FOT.dtmTransactionDate
						, intFutOptTransactionId
						, intOpenContract
						, FOT.strCommodityCode
						, strInternalTradeNo
						, strLocationName
						, FOT.dblContractSize
						, FOT.strFutMarketName
						, FOT.strFutureMonth AS strFutureMonth
						, FOT.strOptionMonthYear AS strOptionMonth
						, dblStrike
						, strOptionType
						, FOT.strInstrumentType
						, FOT.strBrokerageAccount AS strBrokerAccount
						, FOT.strName AS strBroker
						, strBuySell
						, FOTH.intFutOptTransactionHeaderId
						, FOT.intFutureMarketId
						, FOT.intFutureMonthId
						, strBrokerTradeNo
						, strNotes
						, ysnPreCrush
					FROM tblRKFutOptTransactionHeader FOTH
					INNER JOIN vyuRKFutOptTransaction FOT ON FOTH.intFutOptTransactionHeaderId = FOT.intFutOptTransactionHeaderId
					WHERE FOT.strBuySell = 'Sell' AND FOT.strInstrumentType = 'Options'
						AND CONVERT(DATETIME, CONVERT(VARCHAR(10), FOT.dtmTransactionDate, 110), 110) <= CONVERT(DATETIME, @dtmToDate)
						AND ISNULL(FOT.ysnPreCrush, 0) = 0
				)t2 
			)t3 WHERE t3.intRowNum = 1
			
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
				, strCategory
				, intFutureMarketId
				, strFutMarketName
				, intFutureMonthId
				, strFutureMonth
				, strDeliveryDate)
			SELECT strCommodityCode
				, intCommodityId
				, intContractHeaderId
				, strContractNumber
				, strType
				, strLocationName
				, strContractEndMonth
				, strContractEndMonthNearBy
				, dblTotal
				, intUnitMeasureId
				, strEntityName
				, intItemId
				, strItemNo
				, strCategory
				, intFutureMarketId
				, strFutMarketName
				, intFutureMonthId
				, strFutureMonth
				, strDeliveryDate
			FROM (
				SELECT DISTINCT strCommodityCode
					, CD.intCommodityId
					, intContractHeaderId
					, strContractNumber
					, CD.strType
					, strLocationName
					, strContractEndMonth = RIGHT(CONVERT(VARCHAR(11),dtmEndDate,106),8)
					, strContractEndMonthNearBy = RIGHT(CONVERT(VARCHAR(11),dtmEndDate,106),8)
					, dblTotal = (CASE WHEN intContractTypeId = 1 THEN dbo.fnCTConvertQuantityToTargetCommodityUOM(ium.intCommodityUnitMeasureId, @intCommodityUnitMeasureId, ISNULL((CD.dblBalance), 0))
									ELSE - dbo.fnCTConvertQuantityToTargetCommodityUOM(ium.intCommodityUnitMeasureId, @intCommodityUnitMeasureId, ISNULL((CD.dblBalance), 0)) END)
					, CD.intUnitMeasureId
					, CD.strEntityName
					, intItemId
					, strItemNo
					, strCategory
					, intFutureMarketId
					, strFutMarketName
					, intFutureMonthId
					, strFutureMonth
					, CD.strDeliveryDate
				FROM @tblGetOpenContractDetail CD
				JOIN tblICCommodityUnitMeasure ium ON ium.intCommodityId = CD.intCommodityId AND CD.intUnitMeasureId = ium.intUnitMeasureId AND CD.intContractStatusId <> 3
					AND intCompanyLocationId IN (SELECT intCompanyLocationId FROM tblSMCompanyLocation
												WHERE ISNULL(ysnLicensed, 0) = CASE WHEN @strPositionIncludes = 'licensed storage' THEN 1
																					WHEN @strPositionIncludes = 'Non-licensed storage' THEN 0
																					ELSE ISNULL(ysnLicensed, 0) END)
				WHERE intContractTypeId IN (1,2) AND CD.intCommodityId = @intCommodityId
					AND intCompanyLocationId = CASE WHEN ISNULL(@intLocationId, 0) = 0 THEN intCompanyLocationId ELSE @intLocationId END
					AND  CD.intEntityId = CASE WHEN ISNULL(@intVendorId, 0) = 0 THEN CD.intEntityId ELSE @intVendorId END
				) t
			
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
				, strDeliveryDate
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
				, strDeliveryDate
				, strBrokerTradeNo
				, strNotes
				, ysnPreCrush
			FROM @List t
			JOIN tblICCommodityUnitMeasure cuc ON t.intCommodityId = cuc.intCommodityId AND cuc.ysnDefault = 1
			JOIN tblICUnitMeasure um ON um.intUnitMeasureId = cuc.intUnitMeasureId
			LEFT JOIN tblICCommodityUnitMeasure cuc1 ON t.intCommodityId = cuc1.intCommodityId AND @intUnitMeasureId = cuc1.intUnitMeasureId
			WHERE t.intCommodityId = @intCommodityId
		END
		
		SELECT @mRowNumber = MIN(intCommodityIdentity) FROM @Commodity WHERE intCommodityIdentity > @mRowNumber
	END

	UPDATE @FinalList SET strContractEndMonth = 'Near By' WHERE CONVERT(DATETIME, '01 ' + strContractEndMonth) < CONVERT(DATETIME, GETDATE())
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
		, strDeliveryDate
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
		, strDeliveryDate
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
		, strDeliveryDate
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
		, strDeliveryDate
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
			, strDeliveryDate
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
			, strDeliveryDate
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
			, strDeliveryDate
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
			, strDeliveryDate
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
		, strDeliveryDate
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
		, strDeliveryDate
		, strBrokerTradeNo
		, strNotes
		, ysnPreCrush
	FROM @List

	UPDATE @List SET intSeqNo = 1 WHERE strType LIKE 'Purchase%'
	UPDATE @List SET intSeqNo = 2 WHERE strType LIKE 'Sale%'
	UPDATE @List SET intSeqNo = 3 WHERE strType = 'Net Hedge'
	UPDATE @List SET intSeqNo = 4 WHERE strType = 'Position'

	DECLARE @strType NVARCHAR(MAX)
	DECLARE @strContractEndMonth NVARCHAR(MAX)
	SELECT TOP 1 @strType = strType
		, @strContractEndMonth = strContractEndMonth
	FROM @List
	ORDER BY intRowNumber ASC

	IF (ISNULL(@intVendorId, 0) = 0)
	BEGIN
		SELECT intSeqNo
			, intRowNumber
			, strCommodityCode
			, strContractNumber
			, intContractHeaderId
			, strInternalTradeNo
			, intFutOptTransactionHeaderId
			, strType
			, strLocationName
			, strContractEndMonth = RIGHT(CONVERT(VARCHAR(11), strContractEndMonth, 106), 8)
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
			, strDeliveryDate
			, strBrokerTradeNo
			, strNotes
			, ysnPreCrush
		FROM @List
		WHERE dblTotal IS NULL OR dblTotal <> 0
		ORDER BY CASE WHEN strContractEndMonth NOT IN ('Near By','Total') THEN CONVERT(DATETIME,'01 ' + strContractEndMonth) END
			, intSeqNo
			, strType
	END
	ELSE
	BEGIN
		SELECT intSeqNo
			, intRowNumber
			, strCommodityCode
			, strContractNumber
			, intContractHeaderId
			, strInternalTradeNo
			, intFutOptTransactionHeaderId
			, strType
			, strLocationName
			, strContractEndMonth = RIGHT(CONVERT(VARCHAR(11),strContractEndMonth,106),8)
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
			, strDeliveryDate
			, strBrokerTradeNo
			, strNotes
			, ysnPreCrush
		FROM @List
		WHERE dblTotal IS NULL
			OR dblTotal <> 0
			AND strType NOT LIKE '%' + @strPurchaseSales + '%'
			AND strType <> 'Net Hedge'
		ORDER BY  CASE WHEN strContractEndMonth NOT IN ('Near By','Total') THEN CONVERT(DATETIME,'01 ' + strContractEndMonth) END
			, intSeqNo
			, strType
	END
END