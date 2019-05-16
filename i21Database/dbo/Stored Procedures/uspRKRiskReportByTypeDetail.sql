CREATE PROCEDURE [dbo].[uspRKRiskReportByTypeDetail]
	@intProductTypeId INT = NULL
	, @intFutureMarketId INT = NULL
	, @intCompanyLocationId NVARCHAR(250) = NULL
	, @intCommodityAttributeId NVARCHAR(250) = NULL
	, @intUnitMeasureId INT
	, @intDecimals INT
	, @strDetailColumnName NVARCHAR(100)
	, @strFutureMonth NVARCHAR(10)

AS

BEGIN
	DECLARE @Location AS TABLE (intLocationId INT IDENTITY(1,1) PRIMARY KEY
		, intCompanyLocationId INT)
	
	INSERT INTO @Location(intCompanyLocationId)
	SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCompanyLocationId, ',')
	DELETE FROM @Location WHERE intCompanyLocationId = 0
	
	DECLARE @BrokerageAttribute AS TABLE (intAttributeId INT IDENTITY(1,1) PRIMARY KEY
		, intFutureMarketId INT
		, intBrokersAccountMarketMapId INT
		, strCommodityAttributeId NVARCHAR(MAX)
		, intBrokerageAccountId INT)

	DECLARE @BrokerageAttributeFinal AS TABLE (intAttributeId INT IDENTITY(1,1) PRIMARY KEY
		, intFutureMarketId INT
		, intBrokerageAccountId INT
		, strCommodityAttributeId NVARCHAR(MAX))

	INSERT INTO @BrokerageAttribute
	SELECT mm.intFutureMarketId
		, intBrokersAccountMarketMapId
		, strCommodityAttributeId
		, intBrokerageAccountId
	FROM tblRKFutureMarket m
	JOIN [tblRKBrokersAccountMarketMapping] mm ON mm.intFutureMarketId = m.intFutureMarketId
	WHERE m.intFutureMarketId = @intFutureMarketId
	
	DECLARE @intAttributeId INT
	DECLARE @intFutureMarketId1 INT
	DECLARE @intBrokerageAccountId INT
	DECLARE @strCommodityAttributeId NVARCHAR(MAX)

	SELECT @intAttributeId = MIN(intAttributeId) FROM @BrokerageAttribute
	WHILE @intAttributeId > 0
	BEGIN
		SELECT @intFutureMarketId1 = intFutureMarketId
			, @intBrokerageAccountId = intBrokerageAccountId
			, @strCommodityAttributeId = strCommodityAttributeId
		FROM @BrokerageAttribute
		WHERE intAttributeId = @intAttributeId
		
		IF @intAttributeId > 0
		BEGIN
			INSERT INTO @BrokerageAttributeFinal(strCommodityAttributeId)
			SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@strCommodityAttributeId, ',')
			
			UPDATE @BrokerageAttributeFinal
			SET intBrokerageAccountId = @intBrokerageAccountId
				, intFutureMarketId = @intFutureMarketId1
			WHERE intBrokerageAccountId IS NULL
		END
		
		SELECT @intAttributeId = MIN(intAttributeId) FROM @BrokerageAttribute WHERE intAttributeId > @intAttributeId
	END
	
	DECLARE @intPreviousMonthId INT
		, @dtmFutureMonthsDate DATETIME
	
	SELECT @intPreviousMonthId = NULL
	SELECT @dtmFutureMonthsDate = NULL
	SELECT TOP 1 @intPreviousMonthId = intFutureMonthId
	FROM tblRKFuturesMonth WHERE ysnExpired = 0
		AND dtmSpotDate <= GETDATE()
		AND intFutureMarketId = @intFutureMarketId
	ORDER BY intFutureMonthId DESC
	SELECT TOP 1 @dtmFutureMonthsDate = dtmFutureMonthsDate
	FROM tblRKFuturesMonth WHERE intFutureMonthId = @intPreviousMonthId
	
	--Contract Transaction
	SELECT DISTINCT *
	INTO #ContractTransaction
	FROM (
		SELECT DISTINCT fm.intFutureMonthId
			, cv.strFutureMonth
			, strFutMarketName
			, strContractType + ' - ' + ISNULL(ca.strDescription, '') AS strAccountNumber
			, dbo.fnCTConvertQuantityToTargetCommodityUOM(um.intCommodityUnitMeasureId, um1.intCommodityUnitMeasureId, ISNULL(cv.dblDetailQuantity, 0)) dblNoOfContract
			, LEFT(strContractType, 1) + ' - ' + strContractNumber + ' - ' + CONVERT(NVARCHAR, intContractSeq) AS strTradeNo
			, dtmStartDate AS TransactionDate
			, strContractType AS TranType
			, strEntityName AS CustVendor
			, dblNoOfLots AS dblNoOfLot
			, dbo.fnCTConvertQuantityToTargetCommodityUOM(um.intCommodityUnitMeasureId, um1.intCommodityUnitMeasureId, ISNULL(cv.dblDetailQuantity, 0)) dblQuantity
			, cv.intContractHeaderId
			, NULL AS intFutOptTransactionHeaderId
			, intPricingTypeId
			, cv.strContractType
			, cv.intCommodityId
			, cv.intCompanyLocationId
			, cv.intFutureMarketId
			, dtmFutureMonthsDate
			, ysnExpired
			, 'Priced' strPricingType
			, strLocationName
			, ca.intCommodityAttributeId intProductTypeId
		FROM vyuRKRiskPositionContractDetail cv
		JOIN tblRKFutureMarket ffm ON ffm.intFutureMarketId = cv.intFutureMarketId
		JOIN tblRKFuturesMonth fm ON cv.intFutureMarketId = fm.intFutureMarketId AND cv.intFutureMonthId = fm.intFutureMonthId
		JOIN tblICItemUOM u ON cv.intItemUOMId = u.intItemUOMId
		JOIN tblICItem ic ON ic.intItemId = cv.intItemId
			AND cv.intItemId NOT IN (SELECT intItemId FROM tblICItem ici
									JOIN tblICCommodityProductLine pl ON ici.intCommodityId = pl.intCommodityId
										AND ici.intProductLineId = pl.intCommodityProductLineId)
		LEFT JOIN vyuRKGetInvoicedQty iq ON cv.intContractDetailId = iq.intPContractDetailId
		LEFT JOIN vyuRKGetInvoicedQty iq1 ON cv.intContractDetailId = iq1.intSContractDetailId
		LEFT JOIN tblICCommodityAttribute ca ON ca.intCommodityAttributeId = ic.intProductTypeId
		LEFT JOIN tblICCommodityUnitMeasure um ON um.intCommodityId = cv.intCommodityId AND um.intUnitMeasureId = cv.intUnitMeasureId
		LEFT JOIN tblICCommodityUnitMeasure um1 ON um1.intCommodityId = cv.intCommodityId AND um1.intUnitMeasureId = @intUnitMeasureId
		WHERE cv.intFutureMarketId = @intFutureMarketId AND cv.intContractStatusId <> 3 AND cv.intPricingTypeId = 1
			AND cv.intCompanyLocationId IN (SELECT intCompanyLocationId FROM @Location)
			
		--Partial Priced
		UNION ALL SELECT intFutureMonthId
			, strFutureMonth
			, strFutMarketName
			, strAccountNumber
			, dblFixedQty AS dblNoOfContract
			, strTradeNo
			, TransactionDate
			, TranType
			, CustVendor
			, dblFixedLots dblNoOfLot
			, dblFixedQty
			, intContractHeaderId
			, intFutOptTransactionHeaderId
			, intPricingTypeId
			, strContractType
			, intCommodityId
			, intCompanyLocationId
			, intFutureMarketId
			, dtmFutureMonthsDate
			, ysnExpired
			, 'Priced' strPricingType
			, strLocationName
			, intCommodityAttributeId intProductTypeId
		FROM (
			SELECT cv.strFutureMonth
				, strFutMarketName
				, fm.intFutureMonthId
				, strContractType + ' - ' + ISNULL(ca.strDescription, '') AS strAccountNumber
				, 0 AS dblNoOfContract
				, LEFT(strContractType, 1) + ' - ' + strContractNumber + ' - ' + CONVERT(NVARCHAR, intContractSeq) AS strTradeNo
				, dtmStartDate AS TransactionDate
				, strContractType AS TranType
				, strEntityName AS CustVendor
				, dblNoOfLots AS dblNoOfLot
				, dbo.fnCTConvertQuantityToTargetCommodityUOM(um.intCommodityUnitMeasureId, um1.intCommodityUnitMeasureId, ISNULL(dblDetailQuantity, 0)) AS dblQuantity
				, cv.intContractHeaderId
				, NULL AS intFutOptTransactionHeaderId
				, 1 intPricingTypeId
				, cv.strContractType
				, cv.intCommodityId
				, cv.intCompanyLocationId
				, cv.intFutureMarketId
				, dtmFutureMonthsDate
				, ysnExpired
				, ISNULL((SELECT SUM(dblLotsFixed) dblNoOfLots
						FROM tblCTPriceFixation pf
						WHERE pf.intContractHeaderId = cv.intContractHeaderId AND pf.intContractDetailId = cv.intContractDetailId), 0) dblFixedLots
				, ISNULL((SELECT dbo.fnCTConvertQuantityToTargetCommodityUOM(um.intCommodityUnitMeasureId, um1.intCommodityUnitMeasureId, SUM(dblQuantity)) dblQuantity
						FROM tblCTPriceFixation pf
						JOIN tblCTPriceFixationDetail pd ON pf.intPriceFixationId = pd.intPriceFixationId
						WHERE pf.intContractHeaderId = cv.intContractHeaderId AND pf.intContractDetailId = cv.intContractDetailId), 0) dblFixedQty
				, strLocationName
				, ca.intCommodityAttributeId
			FROM vyuRKRiskPositionContractDetail cv
			JOIN tblRKFutureMarket ffm ON ffm.intFutureMarketId = cv.intFutureMarketId
			JOIN tblRKFuturesMonth fm ON cv.intFutureMarketId = fm.intFutureMarketId AND cv.intFutureMonthId = fm.intFutureMonthId
			JOIN tblICItemUOM u ON cv.intItemUOMId = u.intItemUOMId
			JOIN tblICItem ic ON ic.intItemId = cv.intItemId
				AND cv.intItemId NOT IN (SELECT intItemId FROM tblICItem ici
										JOIN tblICCommodityProductLine pl ON ici.intCommodityId = pl.intCommodityId
											AND ici.intProductLineId = pl.intCommodityProductLineId)
			LEFT JOIN tblICCommodityAttribute ca ON ca.intCommodityAttributeId = ic.intProductTypeId
			LEFT JOIN tblICCommodityUnitMeasure um ON um.intCommodityId = cv.intCommodityId AND um.intUnitMeasureId = cv.intUnitMeasureId
			LEFT JOIN tblICCommodityUnitMeasure um1 ON um1.intCommodityId = cv.intCommodityId AND um1.intUnitMeasureId = @intUnitMeasureId
			WHERE cv.intFutureMarketId = @intFutureMarketId AND cv.intContractStatusId <> 3 AND intPricingTypeId <> 1
				AND cv.intCompanyLocationId IN (SELECT intCompanyLocationId FROM @Location)
		) t
		WHERE ISNULL(dblNoOfLot, 0) - ISNULL(dblFixedLots, 0) <> 0
		
		--Partial UnPriced
		UNION ALL SELECT intFutureMonthId
			, strFutureMonth
			, strFutMarketName
			, strAccountNumber
			, dblQuantity - dblFixedQty AS dblNoOfContract
			, strTradeNo
			, TransactionDate
			, TranType
			, CustVendor
			, ISNULL(dblNoOfLot, 0) - ISNULL(dblFixedLots, 0) dblNoOfLot
			, dblQuantity - dblFixedQty dblQuantity
			, intContractHeaderId
			, intFutOptTransactionHeaderId
			, intPricingTypeId
			, strContractType
			, intCommodityId
			, intCompanyLocationId
			, intFutureMarketId
			, dtmFutureMonthsDate
			, ysnExpired
			, 'UnPriced' strPricingType
			, strLocationName
			, intCommodityAttributeId intProductTypeId
		FROM (
			SELECT cv.strFutureMonth
				, strFutMarketName
				, intContractDetailId
				, fm.intFutureMonthId
				, strContractType + ' - ' + ISNULL(ca.strDescription, '') AS strAccountNumber
				, 0 AS dblNoOfContract
				, LEFT(strContractType, 1) + ' - ' + strContractNumber + ' - ' + CONVERT(NVARCHAR, intContractSeq) AS strTradeNo
				, dtmStartDate AS TransactionDate
				, strContractType AS TranType
				, strEntityName AS CustVendor
				, dblNoOfLots AS dblNoOfLot
				, dbo.fnCTConvertQuantityToTargetCommodityUOM(um.intCommodityUnitMeasureId, um1.intCommodityUnitMeasureId, ISNULL(dblDetailQuantity, 0)) AS dblQuantity
				, cv.intContractHeaderId
				, NULL AS intFutOptTransactionHeaderId
				, 2 AS intPricingTypeId
				, cv.strContractType
				, cv.intCommodityId
				, cv.intCompanyLocationId
				, cv.intFutureMarketId
				, dtmFutureMonthsDate
				, ysnExpired
				, ISNULL((SELECT SUM(dblLotsFixed) dblNoOfLots FROM tblCTPriceFixation pf
						WHERE pf.intContractHeaderId = cv.intContractHeaderId AND pf.intContractDetailId = cv.intContractDetailId), 0) dblFixedLots
				, ISNULL((SELECT dbo.fnCTConvertQuantityToTargetCommodityUOM(um.intCommodityUnitMeasureId, um1.intCommodityUnitMeasureId, SUM(pd.dblQuantity)) dblQuantity
						FROM tblCTPriceFixation pf
						JOIN tblCTPriceFixationDetail pd ON pf.intPriceFixationId = pd.intPriceFixationId
						WHERE pf.intContractHeaderId = cv.intContractHeaderId AND pf.intContractDetailId = cv.intContractDetailId), 0) dblFixedQty
				, strLocationName
				, ca.intCommodityAttributeId
			FROM vyuRKRiskPositionContractDetail cv
			JOIN tblRKFutureMarket ffm ON ffm.intFutureMarketId = cv.intFutureMarketId
			JOIN tblRKFuturesMonth fm ON cv.intFutureMarketId = fm.intFutureMarketId AND cv.intFutureMonthId = fm.intFutureMonthId
			JOIN tblICItemUOM u ON cv.intItemUOMId = u.intItemUOMId
			JOIN tblICItem ic ON ic.intItemId = cv.intItemId
				AND cv.intItemId NOT IN (SELECT intItemId FROM tblICItem ici
										JOIN tblICCommodityProductLine pl ON ici.intCommodityId = pl.intCommodityId
											AND ici.intProductLineId = pl.intCommodityProductLineId)
			LEFT JOIN tblICCommodityAttribute ca ON ca.intCommodityAttributeId = ic.intProductTypeId
			LEFT JOIN tblARProductType pt ON pt.intProductTypeId = ic.intProductTypeId
			LEFT JOIN tblICCommodityUnitMeasure um ON um.intCommodityId = cv.intCommodityId AND um.intUnitMeasureId = cv.intUnitMeasureId
			LEFT JOIN tblICCommodityUnitMeasure um1 ON um1.intCommodityId = cv.intCommodityId AND um1.intUnitMeasureId = @intUnitMeasureId
			WHERE cv.intFutureMarketId = @intFutureMarketId AND cv.intContractStatusId <> 3 AND intPricingTypeId <> 1
				AND cv.intCompanyLocationId IN (SELECT intCompanyLocationId FROM @Location)
		) t
		WHERE ISNULL(dblNoOfLot, 0) - ISNULL(dblFixedLots, 0) <> 0
	) t1
	WHERE dblNoOfContract <> 0
	
	UPDATE #ContractTransaction SET strFutureMonth = 'Previous' WHERE dtmFutureMonthsDate < @dtmFutureMonthsDate
	
	IF (ISNULL(@intProductTypeId, 0) <> 0)
	BEGIN
		--Future Transaction with product Type
		SELECT CONVERT(INT, ROW_NUMBER() OVER(ORDER BY strFutMarketName)) AS intRowNum
			, strFutMarketName
			, strLocationName
			, strTradeNo
			, CustVendor
			, strFutureMonth AS strFutureMonth
			, ABS((ISNULL(strBuy, 0) - ISNULL(strSell, 0))) * dblContractSize dblQuantity
			, dtmFutureMonthsDate AS dtmTransactionDate
			, strBuySell
			, ABS((ISNULL(strBuy, 0) - ISNULL(strSell, 0))) dblNoOfContract
			, dblPrice dblPrice
			, strTradeNo strInternalTradeNo
			, intFutureMarketId
			, intFutOptTransactionHeaderId
		INTO #FutureTransaction
		FROM (
			SELECT strFutMarketName
				, strFutureMonth
				, t.intFutureMarketId
				, strName CustVendor
				, strBuySell
				, dtmFutureMonthsDate
				, dblPrice
				, (select dblNoOfContract FROM tblRKFutOptTransaction ot where ot.intFutOptTransactionId=t.intFutOptTransactionId AND strBuySell='Buy') strBuy
				, (select dblNoOfContract FROM tblRKFutOptTransaction ot where ot.intFutOptTransactionId=t.intFutOptTransactionId AND strBuySell='Sell') strSell
				, m.dblContractSize dblContractSize
				, strLocationName strLocationName
				, t.strInternalTradeNo strTradeNo
				, t.intFutOptTransactionHeaderId
			FROM tblRKFutOptTransaction t
			JOIN tblRKFutureMarket m ON m.intFutureMarketId = t.intFutureMarketId
			JOIN tblSMCompanyLocation cl ON cl.intCompanyLocationId = t.intLocationId AND intInstrumentTypeId = 1
			JOIN tblRKFuturesMonth fm ON t.intFutureMonthId = fm.intFutureMonthId
			JOIN tblEMEntity e ON t.intEntityId = e.intEntityId
			WHERE t.intFutureMarketId = @intFutureMarketId
				AND t.intLocationId IN (SELECT intCompanyLocationId FROM @Location)
				AND t.intBrokerageAccountId IN (SELECT intBrokerageAccountId FROM @BrokerageAttributeFinal
												WHERE strCommodityAttributeId = @intProductTypeId)
		) t
		
		UPDATE #FutureTransaction SET strFutureMonth = 'Previous' WHERE dtmTransactionDate < @dtmFutureMonthsDate
		
		IF (@strDetailColumnName = 'colTotalPurchase')
			SELECT CONVERT(INT, ROW_NUMBER() OVER(ORDER BY strFutMarketName)) AS intRowNum
				, strLocationName
				, strTradeNo
				, CustVendor
				, dblQuantity
				, dtmFutureMonthsDate dtmTransactionDate
				, TranType strBuySell
				, 0.0 dblNoOfContract
				, 0.0 dblPrice
				, '' strInternalTradeNo
				, 0 AS intFutOptTransactionHeaderId
				, intContractHeaderId
				, @intDecimals intDecimals
			FROM #ContractTransaction
			WHERE strFutureMonth = @strFutureMonth AND TranType = 'Purchase' AND intProductTypeId = @intProductTypeId AND intFutureMarketId = @intFutureMarketId
		ELSE IF (@strDetailColumnName = 'colTotalSales')
			SELECT CONVERT(INT, ROW_NUMBER() OVER(ORDER BY strFutMarketName)) AS intRowNum
				, strLocationName
				, strTradeNo
				, CustVendor
				, dblQuantity
				, dtmFutureMonthsDate dtmTransactionDate
				, TranType strBuySell
				, 0.0 dblNoOfContract
				, 0.0 dblPrice
				, '' strInternalTradeNo
				, 0 AS intFutOptTransactionHeaderId
				, intContractHeaderId
				, @intDecimals intDecimals
			FROM #ContractTransaction
			WHERE strFutureMonth = @strFutureMonth AND TranType = 'Sale' AND intProductTypeId = @intProductTypeId AND intFutureMarketId = @intFutureMarketId
		ELSE IF (@strDetailColumnName = 'colUnfixedPurchase')
			SELECT CONVERT(INT, ROW_NUMBER() OVER(ORDER BY strFutMarketName)) AS intRowNum
				, strLocationName
				, strTradeNo
				, CustVendor
				, dblQuantity
				, dtmFutureMonthsDate dtmTransactionDate
				, TranType strBuySell
				, 0.0 dblNoOfContract
				, 0.0 dblPrice
				, '' strInternalTradeNo
				, 0 AS intFutOptTransactionHeaderId
				, intContractHeaderId
				, @intDecimals intDecimals
			FROM #ContractTransaction
			WHERE strFutureMonth = @strFutureMonth AND TranType = 'Purchase' AND strPricingType = 'UnPriced' AND intProductTypeId = @intProductTypeId AND intFutureMarketId = @intFutureMarketId
		ELSE IF (@strDetailColumnName = 'colUnfixedSales')
			SELECT CONVERT(INT, ROW_NUMBER() OVER(ORDER BY strFutMarketName)) AS intRowNum
				, strLocationName
				, strTradeNo
				, CustVendor
				, dblQuantity
				, dtmFutureMonthsDate dtmTransactionDate
				, TranType strBuySell
				, 0.0 dblNoOfContract
				, 0.0 dblPrice
				, '' strInternalTradeNo
				, 0 AS intFutOptTransactionHeaderId
				, intContractHeaderId
				, @intDecimals intDecimals
			FROM #ContractTransaction
			WHERE strFutureMonth = @strFutureMonth AND TranType = 'Sale' AND strPricingType = 'UnPriced' AND intProductTypeId = @intProductTypeId AND intFutureMarketId = @intFutureMarketId
		ELSE IF (@strDetailColumnName = 'colPrevious')
			SELECT CONVERT(INT, ROW_NUMBER() OVER(ORDER BY strFutMarketName)) AS intRowNum
				, strLocationName
				, strTradeNo
				, CustVendor
				, dblQuantity
				, dtmFutureMonthsDate dtmTransactionDate
				, TranType strBuySell
				, 0.0 dblNoOfContract
				, 0.0 dblPrice
				, '' strInternalTradeNo
				, 0 AS intFutOptTransactionHeaderId
				, intContractHeaderId
				, @intDecimals intDecimals
			FROM #ContractTransaction
			WHERE strFutureMonth = @strFutureMonth AND TranType = 'Sale' AND intProductTypeId = @intProductTypeId AND intFutureMarketId = @intFutureMarketId
		ELSE IF (@strDetailColumnName = 'colFutures')
			SELECT CONVERT(INT, ROW_NUMBER() OVER(ORDER BY strFutMarketName)) AS intRowNum
				, strLocationName
				, strTradeNo
				, CustVendor
				, dblQuantity
				, dtmTransactionDate dtmTransactionDate
				, strBuySell
				, dblNoOfContract
				, dblPrice dblPrice
				, '' strInternalTradeNo
				, intFutOptTransactionHeaderId
				, 0 AS intContractHeaderId
				, @intDecimals intDecimals
			FROM #FutureTransaction
			WHERE strFutureMonth = @strFutureMonth AND intFutureMarketId = @intFutureMarketId
	END
	ELSE
	BEGIN
		--Futures Transaction With out product Type
		SELECT CONVERT(INT, ROW_NUMBER() OVER(ORDER BY strFutMarketName)) AS intRowNum
			, strFutMarketName
			, strLocationName
			, strTradeNo
			, CustVendor
			, strFutureMonth AS strFutureMonth
			, ABS((ISNULL(strBuy, 0) - ISNULL(strSell, 0))) * dblContractSize dblQuantity
			, dtmFutureMonthsDate AS dtmTransactionDate
			, strBuySell
			, ABS((ISNULL(strBuy, 0) - ISNULL(strSell, 0))) dblNoOfContract
			, dblPrice dblPrice
			, strTradeNo strInternalTradeNo
			, intFutureMarketId
			, intFutOptTransactionHeaderId
		INTO #FutureTransaction1
		FROM (
			SELECT strFutMarketName
				, strFutureMonth
				, t.intFutureMarketId
				, strName CustVendor
				, strBuySell
				, dtmFutureMonthsDate
				, dblPrice
				, (SELECT dblNoOfContract FROM tblRKFutOptTransaction ot WHERE ot.intFutOptTransactionId = t.intFutOptTransactionId AND strBuySell = 'Buy') strBuy
				, (SELECT dblNoOfContract FROM tblRKFutOptTransaction ot WHERE ot.intFutOptTransactionId = t.intFutOptTransactionId AND strBuySell = 'Sell') strSell
				, m.dblContractSize dblContractSize
				, strLocationName strLocationName
				, t.strInternalTradeNo strTradeNo
				, intFutOptTransactionHeaderId
			FROM tblRKFutOptTransaction t
			JOIN tblRKFutureMarket m ON m.intFutureMarketId = t.intFutureMarketId
			JOIN tblSMCompanyLocation cl ON cl.intCompanyLocationId = t.intLocationId AND intInstrumentTypeId = 1
			JOIN tblRKFuturesMonth fm ON t.intFutureMonthId = fm.intFutureMonthId
			JOIN tblEMEntity e ON t.intEntityId = e.intEntityId
			WHERE t.intFutureMarketId = @intFutureMarketId
				AND t.intLocationId IN (SELECT intCompanyLocationId FROM @Location)
		) t
		
		UPDATE #FutureTransaction1 SET strFutureMonth = 'Previous' WHERE dtmTransactionDate < @dtmFutureMonthsDate
		
		IF (@strDetailColumnName = 'colTotalPurchase')
			SELECT CONVERT(INT, ROW_NUMBER() OVER(ORDER BY strFutMarketName)) AS intRowNum
				, strLocationName
				, strTradeNo
				, CustVendor
				, dblQuantity
				, dtmFutureMonthsDate dtmTransactionDate
				, TranType strBuySell
				, intProductTypeId
				, intFutureMarketId
				, strFutureMonth
				, 0.0 dblNoOfContract
				, 0.0 dblPrice
				, '' strInternalTradeNo
				, 0 AS intFutOptTransactionHeaderId
				, intContractHeaderId
				, @intDecimals intDecimals
			FROM #ContractTransaction
			WHERE strFutureMonth = @strFutureMonth AND TranType = 'Purchase' AND intFutureMarketId = @intFutureMarketId AND strFutureMonth = @strFutureMonth
		ELSE IF (@strDetailColumnName = 'colTotalSales')
			SELECT CONVERT(INT, ROW_NUMBER() OVER(ORDER BY strFutMarketName)) AS intRowNum
				, strLocationName
				, strTradeNo
				, CustVendor
				, dblQuantity
				, dtmFutureMonthsDate dtmTransactionDate
				, TranType strBuySell
				, 0.0 dblNoOfContract
				, 0.0 dblPrice
				, '' strInternalTradeNo
				, 0 AS intFutOptTransactionHeaderId
				, intContractHeaderId
				, @intDecimals intDecimals
			FROM #ContractTransaction
			WHERE strFutureMonth = @strFutureMonth AND TranType = 'Sale' AND intFutureMarketId = @intFutureMarketId AND strFutureMonth = @strFutureMonth
		ELSE IF (@strDetailColumnName = 'colUnfixedPurchase')
			SELECT CONVERT(INT, ROW_NUMBER() OVER(ORDER BY strFutMarketName)) AS intRowNum
				, strLocationName
				, strTradeNo
				, CustVendor
				, dblQuantity
				, dtmFutureMonthsDate dtmTransactionDate
				, TranType strBuySell
				, 0.0 dblNoOfContract
				, 0.0 dblPrice
				, '' strInternalTradeNo
				, 0 AS intFutOptTransactionHeaderId
				, intContractHeaderId
				, @intDecimals intDecimals
			FROM #ContractTransaction
			WHERE strFutureMonth = @strFutureMonth AND TranType = 'Purchase' AND strPricingType = 'UnPriced' AND intFutureMarketId = @intFutureMarketId AND strFutureMonth = @strFutureMonth
		ELSE IF (@strDetailColumnName = 'colUnfixedSales')
			SELECT CONVERT(INT, ROW_NUMBER() OVER(ORDER BY strFutMarketName)) AS intRowNum
				, strLocationName
				, strTradeNo
				, CustVendor
				, dblQuantity
				, dtmFutureMonthsDate dtmTransactionDate
				, TranType strBuySell
				, 0.0 dblNoOfContract
				, 0.0 dblPrice
				, '' strInternalTradeNo
				, 0 AS intFutOptTransactionHeaderId
				, intContractHeaderId
				, @intDecimals intDecimals
			FROM #ContractTransaction
			WHERE strFutureMonth = @strFutureMonth AND TranType = 'Sale' AND strPricingType = 'UnPriced' AND intFutureMarketId = @intFutureMarketId AND strFutureMonth = @strFutureMonth
		ELSE IF (@strDetailColumnName = 'colPrevious')
			SELECT CONVERT(INT, ROW_NUMBER() OVER(ORDER BY strFutMarketName)) AS intRowNum
				, strLocationName
				, strTradeNo
				, CustVendor
				, dblQuantity
				, dtmFutureMonthsDate dtmTransactionDate
				, TranType strBuySell
				, 0.0 dblNoOfContract
				, 0.0 dblPrice
				, '' strInternalTradeNo
				, 0 AS intFutOptTransactionHeaderId
				, intContractHeaderId
				, @intDecimals intDecimals
			FROM #ContractTransaction
			WHERE strFutureMonth = @strFutureMonth AND TranType = 'Sale' AND intFutureMarketId = @intFutureMarketId AND strFutureMonth = @strFutureMonth
		ELSE IF (@strDetailColumnName = 'colFutures')
			SELECT CONVERT(INT, ROW_NUMBER() OVER(ORDER BY strFutMarketName)) AS intRowNum
				, strLocationName
				, strTradeNo
				, CustVendor
				, CASE WHEN strBuySell = 'Buy' THEN dblQuantity ELSE - ABS(dblQuantity) END dblQuantity
				, dtmTransactionDate dtmTransactionDate
				, strBuySell
				, CASE WHEN strBuySell = 'Buy' THEN dblNoOfContract ELSE - ABS(dblNoOfContract) END dblNoOfContract
				, dblPrice dblPrice
				, '' strInternalTradeNo
				, intFutOptTransactionHeaderId
				, 0 intContractHeaderId
				, @intDecimals intDecimals
			FROM #FutureTransaction1
			WHERE strFutureMonth = @strFutureMonth AND intFutureMarketId = @intFutureMarketId AND strFutureMonth = @strFutureMonth
	END
END