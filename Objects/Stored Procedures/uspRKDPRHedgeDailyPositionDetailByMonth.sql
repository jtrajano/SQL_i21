﻿CREATE PROCEDURE [dbo].[uspRKDPRHedgeDailyPositionDetailByMonth]
	@intCommodityId NVARCHAR(MAX)
	, @intLocationId NVARCHAR(MAX) = NULL
	, @intVendorId INT = NULL
	, @strPurchaseSales NVARCHAR(50) = NULL
	, @strPositionIncludes NVARCHAR(100) = NULL
	, @dtmToDate DATETIME = NULL
	, @strByType NVARCHAR(50) = NULL

AS

BEGIN
	SET @dtmToDate = CONVERT(DATETIME, CONVERT(VARCHAR(10), @dtmToDate, 110), 110)

	IF ISNULL(@strPurchaseSales, '') <> '' AND @strPurchaseSales <> 'Both'
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


	IF ISNULL(@intLocationId, 0) = 0
	BEGIN
		SET @intLocationId = NULL
	END
	IF ISNULL(@intVendorId, 0) = 0
	BEGIN
		SET @intVendorId = NULL
	END

	SELECT intCompanyLocationId
	INTO #LicensedLocation
	FROM tblSMCompanyLocation
	WHERE ISNULL(ysnLicensed, 0) = CASE WHEN @strPositionIncludes = 'Licensed Storage' THEN 1
										WHEN @strPositionIncludes = 'Non-licensed Storage' THEN 0
										ELSE ISNULL(ysnLicensed, 0) END
	
	DECLARE @strCommodityCode NVARCHAR(50)

	DECLARE @Commodity AS TABLE(intCommodityIdentity int IDENTITY PRIMARY KEY
		, intCommodity INT)
	INSERT INTO @Commodity(intCommodity)
	SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCommodityId, ',')
	
	DECLARE @List AS TABLE (intRowNumber INT IDENTITY
		, intContractHeaderId INT
		, strContractNumber NVARCHAR(200) COLLATE Latin1_General_CI_AS
		, intFutOptTransactionHeaderId INT
		, strInternalTradeNo NVARCHAR(200) COLLATE Latin1_General_CI_AS
		, intCommodityId INT
		, strCommodityCode NVARCHAR(200) COLLATE Latin1_General_CI_AS
		, strType NVARCHAR(50) COLLATE Latin1_General_CI_AS
		, strLocationName NVARCHAR(100) COLLATE Latin1_General_CI_AS
		, strContractEndMonth NVARCHAR(50) COLLATE Latin1_General_CI_AS
		, strContractEndMonthNearBy NVARCHAR(50) COLLATE Latin1_General_CI_AS
		, dblTotal DECIMAL(24,10)
		, intSeqNo INT
		, strUnitMeasure NVARCHAR(50) COLLATE Latin1_General_CI_AS
		, intFromCommodityUnitMeasureId int
		, intToCommodityUnitMeasureId int
		, strAccountNumber NVARCHAR(100) COLLATE Latin1_General_CI_AS
		, strTranType NVARCHAR(20) COLLATE Latin1_General_CI_AS
		, dblNoOfLot NUMERIC(24, 10)
		, dblDelta NUMERIC(24, 10)
		, intBrokerageAccountId int
		, strInstrumentType NVARCHAR(50) COLLATE Latin1_General_CI_AS
		, strEntityName NVARCHAR(100) COLLATE Latin1_General_CI_AS
		, intItemId INT
		, strItemNo NVARCHAR(100) COLLATE Latin1_General_CI_AS
		, intCategoryId INT
		, strCategory NVARCHAR(100) COLLATE Latin1_General_CI_AS
		, intFutureMarketId INT
		, strFutMarketName NVARCHAR(100) COLLATE Latin1_General_CI_AS
		, intFutureMonthId INT
		, strFutureMonth NVARCHAR(100) COLLATE Latin1_General_CI_AS
		, strDeliveryDate NVARCHAR(50) COLLATE Latin1_General_CI_AS
		, strBrokerTradeNo NVARCHAR(100) COLLATE Latin1_General_CI_AS
		, strNotes NVARCHAR(100) COLLATE Latin1_General_CI_AS
		, ysnPreCrush BIT)
	
	DECLARE @FinalList AS TABLE (intRowNumber INT IDENTITY
		, intContractHeaderId INT
		, strContractNumber NVARCHAR(200) COLLATE Latin1_General_CI_AS
		, intFutOptTransactionHeaderId INT
		, strInternalTradeNo NVARCHAR(200) COLLATE Latin1_General_CI_AS
		, intCommodityId INT
		, strCommodityCode NVARCHAR(200) COLLATE Latin1_General_CI_AS
		, strType NVARCHAR(50) COLLATE Latin1_General_CI_AS
		, strLocationName NVARCHAR(100) COLLATE Latin1_General_CI_AS
		, strContractEndMonth NVARCHAR(50) COLLATE Latin1_General_CI_AS
		, strContractEndMonthNearBy NVARCHAR(50) COLLATE Latin1_General_CI_AS
		, dblTotal DECIMAL(24,10)
		, intSeqNo INT
		, strUnitMeasure NVARCHAR(50) COLLATE Latin1_General_CI_AS
		, intFromCommodityUnitMeasureId INT
		, intToCommodityUnitMeasureId INT
		, strAccountNumber NVARCHAR(100) COLLATE Latin1_General_CI_AS
		, strTranType NVARCHAR(20) COLLATE Latin1_General_CI_AS
		, dblNoOfLot NUMERIC(24, 10)
		, dblDelta NUMERIC(24, 10)
		, intBrokerageAccountId int
		, strInstrumentType NVARCHAR(50) COLLATE Latin1_General_CI_AS
		, strEntityName NVARCHAR(100) COLLATE Latin1_General_CI_AS
		, intItemId INT
		, strItemNo NVARCHAR(100) COLLATE Latin1_General_CI_AS
		, intCategoryId INT
		, strCategory NVARCHAR(100) COLLATE Latin1_General_CI_AS
		, intFutureMarketId INT
		, strFutMarketName NVARCHAR(100) COLLATE Latin1_General_CI_AS
		, intFutureMonthId INT
		, strFutureMonth NVARCHAR(100) COLLATE Latin1_General_CI_AS
		, strDeliveryDate NVARCHAR(50) COLLATE Latin1_General_CI_AS
		, strBrokerTradeNo NVARCHAR(100) COLLATE Latin1_General_CI_AS
		, strNotes NVARCHAR(100) COLLATE Latin1_General_CI_AS
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
				, strCommodityCode  NVARCHAR(100) COLLATE Latin1_General_CI_AS
				, intCommodityId INT
				, intContractHeaderId INT
				, strContractNumber  NVARCHAR(100) COLLATE Latin1_General_CI_AS
				, strLocationName  NVARCHAR(100) COLLATE Latin1_General_CI_AS
				, dtmEndDate DATETIME
				, strFutureMonth NVARCHAR(100) COLLATE Latin1_General_CI_AS
				, dblBalance DECIMAL(24,10)
				, intUnitMeasureId INT
				, intPricingTypeId INT
				, intContractTypeId INT
				, intCompanyLocationId INT
				, strContractType NVARCHAR(100) COLLATE Latin1_General_CI_AS
				, strPricingType NVARCHAR(100) COLLATE Latin1_General_CI_AS
				, intContractDetailId INT
				, intContractStatusId INT
				, intEntityId INT
				, intCurrencyId INT
				, strType NVARCHAR(100) COLLATE Latin1_General_CI_AS
				, intItemId INT
				, strItemNo NVARCHAR(100) COLLATE Latin1_General_CI_AS
				, dtmContractDate DATETIME
				, strEntityName NVARCHAR(100) COLLATE Latin1_General_CI_AS
				, intFutureMarketId INT
				, intFutureMonthId INT
				, strCategory NVARCHAR(100) COLLATE Latin1_General_CI_AS
				, strFutMarketName NVARCHAR(100) COLLATE Latin1_General_CI_AS
				, strDeliveryDate NVARCHAR(50) COLLATE Latin1_General_CI_AS)
			
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
				, strCommodityCode = CD.strCommodityCode
				, intCommodityId
				, intContractHeaderId
				, strContractNumber = CD.strContract
				, strLocationName
				, dtmEndDate = dtmSeqEndDate
				, strFutureMonth
				, dblBalance = CD.dblQtyinCommodityStockUOM
				, intUnitMeasureId
				, intPricingTypeId
				, intContractTypeId
				, intCompanyLocationId
				, strContractType
				, strPricingType = CD.strPricingTypeDesc
				, CD.intContractDetailId
				, intContractStatusId
				, intEntityId
				, intCurrencyId
				, strType = (CD.strContractType + ' ' + CD.strPricingTypeDesc) COLLATE Latin1_General_CI_AS
				, intItemId
				, strItemNo
				, dtmContractDate
				, strEntityName = CD.strCustomer
				, intFutureMarketId
				, intFutureMonthId
				, strCategory
				, strFutMarketName
				, strDeliveryDate = RIGHT(CONVERT(VARCHAR(11), CD.dtmSeqEndDate, 106), 8)
			FROM tblCTContractBalance CD
			WHERE CONVERT(DATETIME, CONVERT(VARCHAR(10), dtmContractDate, 110), 110) <= CONVERT(DATETIME, CONVERT(VARCHAR(10), @dtmToDate, 110), 110)
				AND intCommodityId = @intCommodityId
				AND CONVERT(DATETIME, CONVERT(VARCHAR(10), CD.dtmEndDate, 110), 110) = @dtmToDate
				AND CD.dblQuantity <> 0

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
				, strBrokerTradeNo NVARCHAR(100) COLLATE Latin1_General_CI_AS
				, strNotes NVARCHAR(100) COLLATE Latin1_General_CI_AS
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
						, dblOpenContract
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
						, dblOpenContract
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
						, dblOpenContract
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
						, dblOpenContract
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
					, strContractEndMonth = RIGHT(CONVERT(VARCHAR(11),dtmEndDate,106),8) COLLATE Latin1_General_CI_AS
					, strContractEndMonthNearBy = RIGHT(CONVERT(VARCHAR(11),dtmEndDate,106),8) COLLATE Latin1_General_CI_AS
					, dblTotal = (CASE WHEN intContractTypeId = 1 THEN  ISNULL(CD.dblBalance, 0)
									ELSE - ISNULL(CD.dblBalance, 0) END)
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
				WHERE intContractTypeId IN (1,2) AND CD.intCommodityId = @intCommodityId
					AND CD.intContractStatusId <> 3
					AND intCompanyLocationId IN (SELECT intCompanyLocationId FROM #LicensedLocation)
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
				, 'Net Hedge' COLLATE Latin1_General_CI_AS
				, strLocationName
				, strFutureMonth = RIGHT(CONVERT(VARCHAR(11), strFutureMonth, 106), 8) COLLATE Latin1_General_CI_AS
				, dtmFutureMonthsDate = RIGHT(CONVERT(VARCHAR(11), dtmFutureMonthsDate, 106), 8) COLLATE Latin1_General_CI_AS
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
					, strFutureMonth = LEFT(t.strFutureMonth, 4) + '20' + CONVERT(NVARCHAR(2),intYear) COLLATE Latin1_General_CI_AS
					, m.intUnitMeasureId
					, strAccountNumber = e.strName + '-' + ba.strAccountNumber COLLATE Latin1_General_CI_AS
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
				INNER JOIN tblRKFuturesMonth fm ON fm.strFutureMonth = t.strFutureMonth AND fm.intFutureMarketId = m.intFutureMarketId
				WHERE th.intCommodityId IN (SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCommodityId, ','))
					AND intCompanyLocationId = ISNULL(@intLocationId, intCompanyLocationId)
					AND e.intEntityId = ISNULL(@intVendorId, e.intEntityId)
					AND intCompanyLocationId IN (SELECT intCompanyLocationId FROM #LicensedLocation)
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
				, 'Net Hedge' COLLATE Latin1_General_CI_AS
				, t.strLocationName
				, strFutureMonth = LEFT(t.strFutureMonth, 4) + '20' + CONVERT(NVARCHAR(2), fm.intYear) COLLATE Latin1_General_CI_AS
				, dtmFutureMonthsDate = LEFT(t.strFutureMonth, 4) + '20' + CONVERT(NVARCHAR(2), fm.intYear) COLLATE Latin1_General_CI_AS
				, dblTotal = (intOpenContract * ISNULL((SELECT TOP 1 dblDelta
														FROM tblRKFuturesSettlementPrice sp
														INNER JOIN tblRKOptSettlementPriceMarketMap mm ON sp.intFutureSettlementPriceId = mm.intFutureSettlementPriceId
														WHERE intFutureMarketId = m.intFutureMarketId AND mm.intOptionMonthId = om.intOptionMonthId 
															AND mm.intTypeId = CASE WHEN t.strOptionType = 'Put' THEN 1 ELSE 2 END
															AND t.dblStrike = mm.dblStrike
														ORDER BY dtmPriceDate DESC), 0) * m.dblContractSize)
				, m.intUnitMeasureId 
				, strAccountNumber = e.strName + '-' + strAccountNumber COLLATE Latin1_General_CI_AS
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
				, strInstrumentType = 'Options' COLLATE Latin1_General_CI_AS
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
			INNER JOIN tblRKFuturesMonth fm ON fm.strFutureMonth = t.strFutureMonth AND fm.intFutureMarketId = m.intFutureMarketId
			WHERE th.intCommodityId = @intCommodityId AND intCompanyLocationId = ISNULL(@intLocationId, intCompanyLocationId)
				AND t.intFutOptTransactionId NOT IN (SELECT intFutOptTransactionId FROM tblRKOptionsPnSExercisedAssigned)
				AND t.intFutOptTransactionId NOT IN (SELECT intFutOptTransactionId FROM tblRKOptionsPnSExpired)
				AND e.intEntityId = ISNULL(@intVendorId, e.intEntityId)
				AND intCompanyLocationId IN (SELECT intCompanyLocationId FROM #LicensedLocation)
			
			--Net Hedge option end			
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
				, dblTotal
				, um.strUnitMeasure
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
			, 'Position' COLLATE Latin1_General_CI_AS
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
			, 'Position' COLLATE Latin1_General_CI_AS
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
		, strContractEndMonth = 'Near By' COLLATE Latin1_General_CI_AS
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
			, strContractEndMonth = RIGHT(CONVERT(VARCHAR(11), strContractEndMonth, 106), 8) COLLATE Latin1_General_CI_AS
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
			, strContractEndMonth = RIGHT(CONVERT(VARCHAR(11),strContractEndMonth,106),8) COLLATE Latin1_General_CI_AS
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
		WHERE (dblTotal IS NULL
			OR dblTotal <> 0)
			AND strType NOT LIKE '%' + @strPurchaseSales + '%'
			AND strType <> 'Net Hedge'
		ORDER BY  CASE WHEN strContractEndMonth NOT IN ('Near By','Total') THEN CONVERT(DATETIME,'01 ' + strContractEndMonth) END
			, intSeqNo
			, strType
	END
END