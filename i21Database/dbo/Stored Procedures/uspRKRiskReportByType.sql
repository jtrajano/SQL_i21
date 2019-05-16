CREATE PROCEDURE [dbo].[uspRKRiskReportByType]
	@intFutureMarketId NVARCHAR(250) = null
	, @intCompanyLocationId NVARCHAR(250) = null
	, @intCommodityAttributeId NVARCHAR(250) = null
	, @intUnitMeasureId int
	, @intDecimals int

AS

BEGIN
	DECLARE @Market AS TABLE (intMarketId INT IDENTITY(1,1) PRIMARY KEY
		, intFutureMarketId INT)
	
	DECLARE @Location AS TABLE (intLocationId INT IDENTITY(1,1) PRIMARY KEY
		, intCompanyLocationId INT)
	
	DECLARE @CommodityAttribute AS TABLE (intAttributeId INT IDENTITY(1,1) PRIMARY KEY
		, intCommodityAttributeId INT)
	
	INSERT INTO @Market(intFutureMarketId)
	SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intFutureMarketId, ',')	
	DELETE FROM @Market WHERE intFutureMarketId = 0
	
	INSERT INTO @Location(intCompanyLocationId)
	SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCompanyLocationId, ',')	
	DELETE FROM @Location WHERE intCompanyLocationId = 0
	
	INSERT INTO @CommodityAttribute(intCommodityAttributeId)
	SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCommodityAttributeId, ',')
	DELETE FROM @CommodityAttribute WHERE intCommodityAttributeId = 0

	DECLARE @BrokerageAttribute AS TABLE (intAttributeId INT IDENTITY(1,1) PRIMARY KEY
		, intFutureMarketId INT
		, intBrokerageCommissionId INT
		, strCommodityAttributeId NVARCHAR(MAX)
		, intBrokerageAccountId INT)
	
	DECLARE @BrokerageAttributeFinal AS TABLE (intAttributeId INT IDENTITY(1,1) PRIMARY KEY
		, intFutureMarketId INT
		, intBrokerageAccountId INT
		, strCommodityAttributeId NVARCHAR(MAX))

	INSERT INTO @BrokerageAttribute
	SELECT mm.intFutureMarketId
		, intBrokerageCommissionId
		, strProductType
		, intBrokerageAccountId
	FROM @Market m
	JOIN [tblRKBrokerageCommission] mm ON mm.intFutureMarketId = m.intFutureMarketId AND ISNULL(strProductType ,'') <> ''

	DECLARE @intAttributeId INT
		, @intFutureMarketId1 INT
		, @intBrokerageAccountId INT
		, @strCommodityAttributeId NVARCHAR(MAX)

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
	
	SELECT * INTO #ContractTransaction
	FROM (
		SELECT fm.intFutureMonthId
			, cv.strFutureMonth
			, strFutMarketName
			, strContractType + ' - ' + ISNULL(ca.strDescription, '') strAccountNumber
			, dbo.fnCTConvertQuantityToTargetCommodityUOM(um.intCommodityUnitMeasureId
														, um1.intCommodityUnitMeasureId
														, ISNULL(cv.dblDetailQuantity, 0)) AS dblNoOfContract
			, LEFT(strContractType, 1) + ' - ' + strContractNumber + ' - ' + CONVERT(NVARCHAR, intContractSeq) AS strTradeNo
			, dtmStartDate AS TransactionDate
			, strContractType AS TranType
			, strEntityName AS CustVendor
			, dblNoOfLots AS dblNoOfLot
			, dbo.fnCTConvertQuantityToTargetCommodityUOM(um.intCommodityUnitMeasureId
														, um1.intCommodityUnitMeasureId
														, ISNULL(cv.dblDetailQuantity, 0)) AS dblQuantity
			, cv.intContractHeaderId
			, null AS intFutOptTransactionHeaderId
			, intPricingTypeId
			, cv.strContractType
			, cv.intCommodityId
			, cv.intCompanyLocationId
			, cv.intFutureMarketId
			, dtmFutureMonthsDate
			, ysnExpired
			, 'Priced' strPricingType
			, ca.intCommodityAttributeId
			, ca.strDescription
		FROM vyuRKRiskPositionContractDetail cv
		JOIN tblRKFutureMarket ffm ON ffm.intFutureMarketId = cv.intFutureMarketId
		JOIN tblRKFuturesMonth fm ON cv.intFutureMarketId = fm.intFutureMarketId AND cv.intFutureMonthId = fm.intFutureMonthId
		JOIN tblICItemUOM u ON cv.intItemUOMId = u.intItemUOMId
		JOIN tblICItem ic ON ic.intItemId = cv.intItemId AND cv.intItemId NOT IN (SELECT intItemId FROM tblICItem ici
																				JOIN tblICCommodityProductLine pl ON ici.intCommodityId = pl.intCommodityId
																					AND ici.intProductLineId = pl.intCommodityProductLineId)
		LEFT JOIN vyuRKGetInvoicedQty iq ON cv.intContractDetailId = iq.intPContractDetailId
		LEFT JOIN vyuRKGetInvoicedQty iq1 ON cv.intContractDetailId = iq1.intSContractDetailId
		LEFT JOIN tblICCommodityAttribute ca ON ca.intCommodityAttributeId = ic.intProductTypeId
		LEFT JOIN tblICCommodityUnitMeasure um ON um.intCommodityId = cv.intCommodityId AND um.intUnitMeasureId = cv.intUnitMeasureId
		LEFT JOIN tblICCommodityUnitMeasure um1 ON um1.intCommodityId = cv.intCommodityId AND um1.intUnitMeasureId = @intUnitMeasureId
		WHERE cv.intFutureMarketId IN (SELECT intFutureMarketId FROM @Market)
			AND cv.intContractStatusId <> 3
			AND cv.intPricingTypeId = 1
			AND cv.intCompanyLocationId IN (SELECT intCompanyLocationId FROM @Location)
			AND ca.intCommodityAttributeId IN ((SELECT intCommodityAttributeId FROM @CommodityAttribute))
		
		--Parcial Priced
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
			, intCommodityAttributeId
			, strDescription
		FROM (
			SELECT cv.strFutureMonth
				, strFutMarketName
				, fm.intFutureMonthId
				, strContractType + ' - ' + ISNULL(ca.strDescription, '') AS strAccountNumber
				, 0 AS dblNoOfContract
				, LEFT(strContractType, 1) + ' - ' + strContractNumber + ' - ' + CONVERT(NVARCHAR,intContractSeq) AS strTradeNo
				, dtmStartDate AS TransactionDate
				, strContractType AS TranType
				, strEntityName AS CustVendor
				, dblNoOfLots AS dblNoOfLot
				, dbo.fnCTConvertQuantityToTargetCommodityUOM(um.intCommodityUnitMeasureId,um1.intCommodityUnitMeasureId,ISNULL(dblDetailQuantity,0)) AS dblQuantity
				, cv.intContractHeaderId
				, null AS intFutOptTransactionHeaderId
				, 1 intPricingTypeId
				, cv.strContractType
				, cv.intCommodityId
				, cv.intCompanyLocationId
				, cv.intFutureMarketId
				, dtmFutureMonthsDate
				, ysnExpired
				, ISNULL((SELECT SUM(dblLotsFixed) dblNoOfLots
						FROM tblCTPriceFixation pf
						WHERE pf.intContractHeaderId = cv.intContractHeaderId
							AND pf.intContractDetailId = cv.intContractDetailId), 0) dblFixedLots
				, ISNULL((SELECT dbo.fnCTConvertQuantityToTargetCommodityUOM(um.intCommodityUnitMeasureId, um1.intCommodityUnitMeasureId, SUM(dblQuantity)) dblQuantity
						FROM tblCTPriceFixation pf
						JOIN tblCTPriceFixationDetail pd ON pf.intPriceFixationId = pd.intPriceFixationId
						WHERE pf.intContractHeaderId = cv.intContractHeaderId AND pf.intContractDetailId = cv.intContractDetailId), 0) dblFixedQty
				, ca.intCommodityAttributeId
				, ca.strDescription
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
			WHERE cv.intFutureMarketId IN (SELECT intFutureMarketId FROM @Market) AND cv.intContractStatusId <> 3 AND intPricingTypeId <> 1
				AND cv.intCompanyLocationId IN (SELECT intCompanyLocationId FROM @Location)
				AND ca.intCommodityAttributeId IN ((SELECT intCommodityAttributeId FROM @CommodityAttribute))
		) t WHERE ISNULL(dblNoOfLot,0) - ISNULL(dblFixedLots,0) <> 0
	
		--Parcial UnPriced
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
			, intCommodityAttributeId
			, strDescription
		FROM (
			SELECT cv.strFutureMonth
				, strFutMarketName
				, intContractDetailId
				, fm.intFutureMonthId
				, strContractType + ' - ' + ISNULL(ca.strDescription, '') AS strAccountNumber
				, 0 AS dblNoOfContract
				, LEFT(strContractType,1) + ' - ' + strContractNumber + ' - ' +CONVERT(NVARCHAR,intContractSeq) AS strTradeNo
				, dtmStartDate AS TransactionDate
				, strContractType AS TranType
				, strEntityName AS CustVendor
				, dblNoOfLots AS dblNoOfLot
				, dbo.fnCTConvertQuantityToTargetCommodityUOM(um.intCommodityUnitMeasureId,um1.intCommodityUnitMeasureId,ISNULL(dblDetailQuantity,0)) AS dblQuantity
				, cv.intContractHeaderId
				, NULL AS intFutOptTransactionHeaderId
				, 2 AS intPricingTypeId
				, cv.strContractType
				, cv.intCommodityId
				, cv.intCompanyLocationId
				, cv.intFutureMarketId
				, dtmFutureMonthsDate
				, ysnExpired
				, ISNULL((SELECT SUM(dblLotsFixed) dblNoOfLots FROM tblCTPriceFixation pf WHERE pf.intContractHeaderId = cv.intContractHeaderId AND pf.intContractDetailId = cv.intContractDetailId),0) dblFixedLots
				, ISNULL((SELECT dbo.fnCTConvertQuantityToTargetCommodityUOM(um.intCommodityUnitMeasureId, um1.intCommodityUnitMeasureId, SUM(pd.dblQuantity)) dblQuantity
						FROM tblCTPriceFixation pf
						JOIN tblCTPriceFixationDetail pd ON pf.intPriceFixationId=pd.intPriceFixationId
						WHERE pf.intContractHeaderId = cv.intContractHeaderId AND pf.intContractDetailId = cv.intContractDetailId), 0) dblFixedQty
				, ca.intCommodityAttributeId
				, ca.strDescription
			FROM vyuRKRiskPositionContractDetail cv
			JOIN tblRKFutureMarket ffm ON ffm.intFutureMarketId = cv.intFutureMarketId
			JOIN tblRKFuturesMonth fm ON cv.intFutureMarketId = fm.intFutureMarketId AND cv.intFutureMonthId = fm.intFutureMonthId
			JOIN tblICItemUOM u ON cv.intItemUOMId = u.intItemUOMId
			JOIN tblICItem ic ON ic.intItemId = cv.intItemId
				AND cv.intItemId NOT IN (SELECT intItemId FROM tblICItem ici
										JOIN tblICCommodityProductLine pl ON ici.intCommodityId = pl.intCommodityId AND ici.intProductLineId = pl.intCommodityProductLineId)
			LEFT JOIN tblICCommodityAttribute ca ON ca.intCommodityAttributeId = ic.intProductTypeId
			LEFT JOIN tblARProductType pt ON pt.intProductTypeId = ic.intProductTypeId
			LEFT JOIN tblICCommodityUnitMeasure um ON um.intCommodityId = cv.intCommodityId AND um.intUnitMeasureId = cv.intUnitMeasureId
			LEFT JOIN tblICCommodityUnitMeasure um1 ON um1.intCommodityId = cv.intCommodityId AND um1.intUnitMeasureId = @intUnitMeasureId
			WHERE cv.intFutureMarketId IN (SELECT intFutureMarketId FROM @Market) AND cv.intContractStatusId <> 3 AND intPricingTypeId <> 1
				AND cv.intCompanyLocationId IN (SELECT intCompanyLocationId FROM @Location)
				AND ca.intCommodityAttributeId IN((SELECT intCommodityAttributeId FROM @CommodityAttribute))
		) t
		WHERE ISNULL(dblNoOfLot, 0) - ISNULL(dblFixedLots, 0) <> 0
	) t1 WHERE dblNoOfContract <> 0
	
	SELECT t.strFutMarketName
		, t.strFutureMonth
		, t.intFutureMarketId
		, t.intFutureMonthId
		, dblBuy
		, dblSell
		, t.dblContractSize
		, dtmFutureMonthsDate
		, (SELECT TOP 1 strCommodityAttributeId FROM @BrokerageAttributeFinal b WHERE b.intBrokerageAccountId = t.intBrokerageAccountId) intCommodityAttributeId
	INTO #FutTranTemp
	FROM vyuRKGetBuySellTransaction t
	WHERE t.intFutureMarketId IN (SELECT intFutureMarketId FROM @Market)
		AND t.intLocationId IN (SELECT intCompanyLocationId FROM @Location)
		AND strFutureMonth NOT IN(SELECT strFutureMonth FROM #ContractTransaction ct
								WHERE ct.intFutureMarketId = t.intFutureMarketId AND ct.strFutureMonth = t.strFutureMonth)
									AND t.intBrokerageAccountId IN (SELECT intBrokerageAccountId FROM @BrokerageAttributeFinal)
	
	DECLARE @FinalResult AS TABLE (intRowNum INT IDENTITY(1,1) PRIMARY KEY
		, strFutMarketName NVARCHAR(100)
		, strFutMarketNameH NVARCHAR(100)
		, strFutureMonth NVARCHAR(100)
		, dblTotalPurchase NUMERIC(24,10)
		, dblTotalSales NUMERIC(24,10)
		, dblUnfixedPurchase NUMERIC(24,10)
		, dblUnfixedSales NUMERIC(24,10)
		, dblFutures NUMERIC(24,10)
		, dblTotal NUMERIC(24,10)
		, intFutureMarketId INT
		, intFutureMonthId INT
		, intCAttributeId INT
		, strProductType NVARCHAR(100)
		, strProductTypeH NVARCHAR(100)
		, strColor NVARCHAR(50)
		, intMarketSumDummyId INT)
	
	DECLARE @ContractTemp AS TABLE (strFutMarketName NVARCHAR(100)
		, strFutureMonth NVARCHAR(100)
		, dblTotalPurchase NUMERIC(24,10)
		, dblTotalSales NUMERIC(24,10)
		, dblUnfixedPurchase NUMERIC(24,10)
		, dblUnfixedSales NUMERIC(24,10)
		, dblFutures NUMERIC(24,10)
		, dblTotal NUMERIC(24,10)
		, intFutureMarketId INT
		, intFutureMonthId INT
		, intMarketSumDummyId INT)
	
	DECLARE @intLCommodityAttributeId INT = NULL
		, @strDescription NVARCHAR(100) = NULL
		, @intCMarketId INT = NULL
		, @strFutMarket NVARCHAR(50) = NULL
		, @intCAttributeId INT = NULL
	
	SELECT @intCAttributeId = MIN(intAttributeId) FROM @CommodityAttribute
	WHILE @intCAttributeId > 0
	BEGIN
		SELECT @intLCommodityAttributeId = a.intCommodityAttributeId
			, @strDescription = ca.strDescription
		FROM @CommodityAttribute a
		JOIN tblICCommodityAttribute ca ON ca.intCommodityAttributeId = a.intCommodityAttributeId
		WHERE intAttributeId = @intCAttributeId
		
		IF EXISTS((SELECT TOP 1 intCommodityAttributeId FROM #ContractTransaction WHERE intCommodityAttributeId = @intLCommodityAttributeId
					UNION SELECT TOP 1 intCommodityAttributeId FROM #FutTranTemp WHERE intCommodityAttributeId = @intLCommodityAttributeId))
		BEGIN
			INSERT INTO @FinalResult(strProductTypeH
				, strProductType
				, strColor
				, intMarketSumDummyId
				, intCAttributeId)
			SELECT UPPER(@strDescription)
				, @strDescription
				, 'Over all Total'
				, 1
				, @intLCommodityAttributeId
			
			DECLARE @intFMarketId INT = NULL
			SELECT @intFMarketId = MIN(intMarketId) FROM @Market

			WHILE @intFMarketId > 0
			BEGIN
				SELECT @intCMarketId = intFutureMarketId
				FROM @Market WHERE intMarketId = @intFMarketId
				
				SELECT @strFutMarket = strFutMarketName FROM tblRKFutureMarket WHERE intFutureMarketId=@intCMarketId
				
				DECLARE @intPreviousMonthId INT = NULL
				DECLARE @dtmFutureMonthsDate AS DATETIME = NULL
				SELECT TOP 1 @intPreviousMonthId = intFutureMonthId
				FROM tblRKFuturesMonth
				WHERE ysnExpired = 0
					AND dtmSpotDate <= GETDATE() AND intFutureMarketId = @intCMarketId
				ORDER BY intFutureMonthId DESC
				
				SELECT TOP 1 @dtmFutureMonthsDate = dtmFutureMonthsDate
				FROM tblRKFuturesMonth WHERE intFutureMonthId = @intPreviousMonthId
				
				DELETE FROM @ContractTemp
				
				--Physical
				INSERT INTO @ContractTemp(strFutMarketName
					, strFutureMonth
					, dblTotalPurchase
					, dblTotalSales
					, dblUnfixedPurchase
					, dblUnfixedSales
					, dblFutures
					, dblTotal
					, intFutureMarketId)
				SELECT strFutMarketName
					, strFutureMonth strFutureMonth
					, SUM(dblPurchase) dblTotalPurchase
					, SUM(dblSale) dblTotalSales
					, SUM(dblPurchaseUnpriced) dblUnfixedPurchase
					, SUM(dblSaleUnpriced) dblUnfixedSales
					, SUM(dblBuySell) dblFutures
					, SUM((dblPurchasePriced - dblSalePriced) + dblBuySell) AS dblTotal
					, t.intFutureMarketId
				FROM (
					SELECT t.strFutMarketName
						, 'Previous' AS strFutureMonth
						, t.intFutureMarketId
						, ISNULL((SELECT SUM(dblQuantity) FROM #ContractTransaction ct
								WHERE ct.strFutMarketName = t.strFutMarketName
									AND ct.strFutureMonth = t.strFutureMonth
									AND TranType = 'Purchase'
									AND intCommodityAttributeId = @intLCommodityAttributeId
									AND dtmFutureMonthsDate < @dtmFutureMonthsDate), 0) dblPurchase
						, ISNULL((SELECT SUM(dblQuantity) FROM #ContractTransaction ct
								WHERE ct.strFutMarketName = t.strFutMarketName
									AND ct.strFutureMonth = t.strFutureMonth
									AND TranType = 'Sale'
									AND intCommodityAttributeId = @intLCommodityAttributeId
									AND dtmFutureMonthsDate < @dtmFutureMonthsDate), 0) dblSale
						, ISNULL((SELECT SUM(dblQuantity) FROM #ContractTransaction ct
								WHERE ct.strFutMarketName = t.strFutMarketName
									AND ct.strFutureMonth = t.strFutureMonth
									AND TranType = 'Purchase'
									AND intCommodityAttributeId = @intLCommodityAttributeId
									AND strPricingType = 'UnPriced'
									AND dtmFutureMonthsDate < @dtmFutureMonthsDate), 0) dblPurchaseUnpriced
						, ISNULL((SELECT SUM(dblQuantity) FROM #ContractTransaction ct
								WHERE ct.strFutMarketName = t.strFutMarketName
									AND ct.strFutureMonth = t.strFutureMonth
									AND TranType = 'Sale'
									AND intCommodityAttributeId = @intLCommodityAttributeId
									AND strPricingType = 'UnPriced'
									AND dtmFutureMonthsDate < @dtmFutureMonthsDate), 0) dblSaleUnpriced
						, ISNULL((SELECT SUM(dblQuantity) FROM #ContractTransaction ct
								WHERE ct.strFutMarketName = t.strFutMarketName
									AND ct.strFutureMonth = t.strFutureMonth
									AND TranType = 'Purchase'
									AND intCommodityAttributeId = @intLCommodityAttributeId
									AND strPricingType = 'Priced'
									AND dtmFutureMonthsDate < @dtmFutureMonthsDate), 0) dblPurchasePriced
						, ISNULL((SELECT SUM(dblQuantity) FROM #ContractTransaction ct
								WHERE ct.strFutMarketName = t.strFutMarketName
									AND ct.strFutureMonth = t.strFutureMonth
									AND TranType = 'Sale'
									AND intCommodityAttributeId = @intLCommodityAttributeId
									AND strPricingType = 'Priced'
									AND dtmFutureMonthsDate < @dtmFutureMonthsDate), 0) dblSalePriced
						, 0.0 dblBuySell
					FROM #ContractTransaction t
					LEFT JOIN vyuRKGetBuySellTransaction ft ON ft.intFutureMarketId = t.intFutureMarketId AND t.dtmFutureMonthsDate < @dtmFutureMonthsDate
					LEFT JOIN tblRKFutureMarket m ON t.intFutureMarketId = m.intFutureMarketId
					WHERE t.intFutureMarketId = @intCMarketId AND intCommodityAttributeId = @intLCommodityAttributeId
						AND t.intCompanyLocationId IN (SELECT intCompanyLocationId FROM @Location)
					GROUP BY t.strFutMarketName
						, t.strFutureMonth
						, t.intFutureMarketId
						, m.dblContractSize
						, t.intFutureMarketId
					
					UNION ALL SELECT t.strFutMarketName
						, t.strFutureMonth
						, t.intFutureMarketId
						, ISNULL((SELECT SUM(dblQuantity) FROM #ContractTransaction ct
								WHERE ct.strFutMarketName = t.strFutMarketName
									AND ct.strFutureMonth = t.strFutureMonth
									AND TranType = 'Purchase'
									AND intCommodityAttributeId = @intLCommodityAttributeId
									AND dtmFutureMonthsDate >= @dtmFutureMonthsDate), 0) dblPurchase
						, ISNULL((SELECT SUM(dblQuantity) FROM #ContractTransaction ct
								WHERE ct.strFutMarketName = t.strFutMarketName
									AND ct.strFutureMonth = t.strFutureMonth
									AND TranType = 'Sale'
									AND intCommodityAttributeId = @intLCommodityAttributeId
									AND dtmFutureMonthsDate >= @dtmFutureMonthsDate), 0) dblSale
						, ISNULL((SELECT SUM(dblQuantity) FROM #ContractTransaction ct
								WHERE ct.strFutMarketName = t.strFutMarketName
									AND ct.strFutureMonth = t.strFutureMonth
									AND TranType = 'Purchase'
									AND intCommodityAttributeId = @intLCommodityAttributeId
									AND strPricingType = 'UnPriced'
									AND dtmFutureMonthsDate >= @dtmFutureMonthsDate), 0) dblPurchaseUnpriced
						, ISNULL((SELECT SUM(dblQuantity) FROM #ContractTransaction ct
								WHERE ct.strFutMarketName = t.strFutMarketName
									AND ct.strFutureMonth = t.strFutureMonth
									AND TranType = 'Sale'
									AND intCommodityAttributeId = @intLCommodityAttributeId
									AND strPricingType = 'UnPriced'
									AND dtmFutureMonthsDate >= @dtmFutureMonthsDate), 0) dblSaleUnpriced
						, ISNULL((SELECT SUM(dblQuantity) FROM #ContractTransaction ct
								WHERE ct.strFutMarketName = t.strFutMarketName 
									AND ct.strFutureMonth = t.strFutureMonth
									AND TranType = 'Purchase'
									AND intCommodityAttributeId = @intLCommodityAttributeId
									AND strPricingType = 'Priced'
									AND dtmFutureMonthsDate >= @dtmFutureMonthsDate), 0) dblPurchasePriced
						, ISNULL((SELECT SUM(dblQuantity) FROM #ContractTransaction ct
								WHERE ct.strFutMarketName = t.strFutMarketName
									AND ct.strFutureMonth = t.strFutureMonth
									AND TranType = 'Sale'
									AND intCommodityAttributeId = @intLCommodityAttributeId
									AND strPricingType = 'Priced'
									AND dtmFutureMonthsDate >= @dtmFutureMonthsDate), 0) dblSalePriced
						, 0.0 dblBuySell
					FROM #ContractTransaction t
					LEFT JOIN vyuRKGetBuySellTransaction ft ON ft.intFutureMarketId = t.intFutureMarketId AND t.dtmFutureMonthsDate >= @dtmFutureMonthsDate
					LEFT JOIN tblRKFutureMarket m ON t.intFutureMarketId = m.intFutureMarketId
					WHERE t.intFutureMarketId = @intCMarketId AND intCommodityAttributeId = @intLCommodityAttributeId
						AND t.intCompanyLocationId IN (SELECT intCompanyLocationId FROM @Location)
					GROUP BY t.strFutMarketName
						, t.strFutureMonth
						, t.intFutureMarketId
						, m.dblContractSize
						, t.intFutureMarketId
					
					--Futures
					UNION ALL SELECT strFutMarketName
						, strFutureMonth
						, intFutureMarketId
						, 0.0 dblPurchase
						, 0.0 dblSale
						, 0.0 dblPurchaseUnpriced
						, 0.0 dblSaleUnpriced
						, 0.0 dblPurchasePriced
						, 0.0 dblSalePriced
						, SUM(dblBuy - dblSell) * MAX(dblContractSize) dblBuySell
					FROM (
						SELECT t.strFutMarketName
							, 'Previous' strFutureMonth
							, t.intFutureMarketId
							, ISNULL(dblBuy, 0) dblBuy
							, ISNULL(dblSell, 0) dblSell
							, dblContractSize
						FROM vyuRKGetBuySellTransaction t
						WHERE t.intFutureMarketId = @intCMarketId
							AND t.intLocationId IN (SELECT intCompanyLocationId FROM @Location)
							AND t.intBrokerageAccountId IN (SELECT intBrokerageAccountId FROM @BrokerageAttributeFinal
															WHERE strCommodityAttributeId = @intLCommodityAttributeId)
							AND t.dtmFutureMonthsDate < @dtmFutureMonthsDate
					) t
					GROUP BY strFutMarketName
						, strFutureMonth
						, intFutureMarketId
					
					UNION ALL SELECT strFutMarketName
						, strFutureMonth
						, intFutureMarketId
						, 0.0 dblPurchase
						, 0.0 dblSale
						, 0.0 dblPurchaseUnpriced
						, 0.0 dblSaleUnpriced
						, 0.0 dblPurchasePriced
						, 0.0 dblSalePriced
						, SUM(dblBuy - dblSell) * MAX(dblContractSize) dblBuySell
					FROM (
						SELECT t.strFutMarketName
							, t.strFutureMonth
							, t.intFutureMarketId
							, ISNULL(dblBuy, 0) dblBuy
							, ISNULL(dblSell, 0) dblSell
							, dblContractSize
						FROM vyuRKGetBuySellTransaction t
						WHERE t.intFutureMarketId = @intCMarketId
							AND t.intLocationId IN (SELECT intCompanyLocationId FROM @Location)
							AND t.intBrokerageAccountId IN (SELECT intBrokerageAccountId FROM @BrokerageAttributeFinal
															WHERE strCommodityAttributeId = @intLCommodityAttributeId)
							AND t.dtmFutureMonthsDate >= @dtmFutureMonthsDate
					) t
					GROUP BY strFutMarketName
						, strFutureMonth
						, intFutureMarketId
				) t
				GROUP BY strFutMarketName
					, strFutureMonth
					, t.intFutureMarketId
				ORDER BY strFutMarketName
					, CASE WHEN strFutureMonth = 'Previous' THEN '01/01/1900'
						WHEN strFutureMonth ='TOTAL' THEN '01/01/9999'
						ELSE CONVERT(DATETIME,'01 '+strFutureMonth) END ASC
				
				IF EXISTS(SELECT * FROM @ContractTemp)
				BEGIN
					INSERT INTO @FinalResult (strFutMarketNameH, strColor)
					SELECT UPPER(@strFutMarket),'TOTAL'
					
					INSERT INTO @FinalResult (strFutureMonth
						, dblTotalPurchase
						, dblTotalSales
						, dblUnfixedPurchase
						, dblUnfixedSales
						, dblFutures
						, dblTotal
						, intFutureMarketId
						, intCAttributeId)
					SELECT strFutureMonth strFutureMonth
						, dblTotalPurchase
						, dblTotalSales
						, dblUnfixedPurchase
						, dblUnfixedSales
						, dblFutures
						, dblTotal
						, intFutureMarketId
						, @intLCommodityAttributeId
					FROM @ContractTemp
					ORDER BY strFutMarketName
						, CASE WHEN strFutureMonth = 'Previous' THEN '01/01/1900'
								WHEN strFutureMonth ='TOTAL' THEN '01/01/9999'
								ELSE CONVERT(DATETIME, '01 ' + strFutureMonth) END ASC
					
					INSERT INTO @FinalResult (strFutMarketNameH
						, dblTotalPurchase
						, dblTotalSales
						, dblUnfixedPurchase
						, dblUnfixedSales
						, dblFutures
						, dblTotal
						, strColor)
					SELECT 'TOTAL'
						, SUM(dblTotalPurchase)
						, SUM(dblTotalSales)
						, SUM(dblUnfixedPurchase)
						, SUM(dblUnfixedSales)
						, SUM(dblFutures)
						, SUM(dblTotal)
						, 'Total'
					FROM @FinalResult
					WHERE intFutureMarketId = @intCMarketId
						AND intCAttributeId = @intLCommodityAttributeId
				END
				
				SELECT @intFMarketId = MIN(intMarketId) FROM @Market WHERE intMarketId > @intFMarketId
			END
			
			INSERT INTO @FinalResult (strProductTypeH
				, dblTotalPurchase
				, dblTotalSales
				, dblUnfixedPurchase
				, dblUnfixedSales
				, dblFutures
				, dblTotal
				, strColor)
			SELECT 'TOTAL'
				, SUM(dblTotalPurchase)
				, SUM(dblTotalSales)
				, SUM(dblUnfixedPurchase)
				, SUM(dblUnfixedSales)
				, SUM(dblFutures)
				, SUM(dblTotal)
				, 'Total'
			FROM @FinalResult
			WHERE intCAttributeId = @intLCommodityAttributeId
		END
		
		SELECT @intCAttributeId = MIN(intAttributeId) FROM @CommodityAttribute WHERE intAttributeId > @intCAttributeId
	END
	
	-------------------------------By Market ----------------------

	INSERT INTO @FinalResult(strProductTypeH, strColor, intMarketSumDummyId)
	VALUES (UPPER('OVER ALL AGAINST MARKET'), 'TOTAL - OVER All', 1)
	
	DECLARE @intFMarketId1 INT = NULL
		, @intPreviousMonthId1 INT = NULL
		, @dtmFutureMonthsDate1 DATETIME = NULL
	
	SELECT @intFMarketId1 = NULL
	SELECT @intFMarketId1 = MIN(intMarketId) FROM @Market
	
	WHILE @intFMarketId1 > 0
	BEGIN
		SELECT @intCMarketId = NULL
			, @strFutMarket = NULL
		
		SELECT @intCMarketId = m.intFutureMarketId
			, @strFutMarket = strFutMarketName
		FROM @Market m
		JOIN tblRKFutureMarket fm ON fm.intFutureMarketId = m.intFutureMarketId
		WHERE m.intMarketId = @intFMarketId1
		
		SELECT @intPreviousMonthId1 = NULL
			, @dtmFutureMonthsDate1 = NULL
			
		SELECT TOP 1 @intPreviousMonthId1 = intFutureMonthId
		FROM tblRKFuturesMonth
		WHERE ysnExpired = 0
			AND dtmSpotDate <= GETDATE() AND intFutureMarketId = @intCMarketId
		ORDER BY intFutureMonthId DESC
		
		SELECT TOP 1 @dtmFutureMonthsDate1 = dtmFutureMonthsDate FROM tblRKFuturesMonth WHERE intFutureMonthId = @intPreviousMonthId1
		
		DELETE FROM @ContractTemp
		
		INSERT INTO @ContractTemp (strFutMarketName
			, strFutureMonth
			, dblTotalPurchase
			, dblTotalSales
			, dblUnfixedPurchase
			, dblUnfixedSales
			, dblFutures
			, dblTotal
			, intFutureMarketId
			, intMarketSumDummyId)
		SELECT strFutMarketName
			, strFutureMonth strFutureMonth
			, SUM(dblPurchase) dblTotalPurchase
			, SUM(dblSale) dblTotalSales
			, SUM(dblPurchaseUnpriced) dblUnfixedPurchase
			, SUM(dblSaleUnpriced) dblUnfixedSales
			, SUM(dblBuySell) dblFutures
			, SUM((dblPurchasePriced - dblSalePriced) + dblBuySell) AS dblTotal
			, t.intFutureMarketId
			, -1
		FROM (
			SELECT ft.strFutMarketName
				, 'Previous' AS strFutureMonth
				, t.intFutureMarketId
				, ISNULL((SELECT SUM(dblQuantity) FROM #ContractTransaction ct WHERE ct.strFutMarketName=ft.strFutMarketName AND ct.strFutureMonth=t.strFutureMonth AND ct.TranType='Purchase' AND intCommodityAttributeId in(SELECT intCommodityAttributeId FROM @CommodityAttribute) AND dtmFutureMonthsDate < @dtmFutureMonthsDate1),0) dblPurchase
				, ISNULL((SELECT SUM(dblQuantity) FROM #ContractTransaction ct WHERE ct.strFutMarketName=ft.strFutMarketName AND ct.strFutureMonth=t.strFutureMonth AND TranType='Sale' AND intCommodityAttributeId in(SELECT intCommodityAttributeId FROM @CommodityAttribute) AND dtmFutureMonthsDate < @dtmFutureMonthsDate1),0) dblSale
				, ISNULL((SELECT SUM(dblQuantity) FROM #ContractTransaction ct WHERE ct.strFutMarketName=ft.strFutMarketName AND ct.strFutureMonth=t.strFutureMonth AND TranType='Purchase' AND intCommodityAttributeId in(SELECT intCommodityAttributeId FROM @CommodityAttribute) AND strPricingType='UnPriced' AND dtmFutureMonthsDate < @dtmFutureMonthsDate1),0) dblPurchaseUnpriced
				, ISNULL((SELECT SUM(dblQuantity) FROM #ContractTransaction ct WHERE ct.strFutMarketName=ft.strFutMarketName AND ct.strFutureMonth=t.strFutureMonth AND TranType='Sale' AND intCommodityAttributeId in(SELECT intCommodityAttributeId FROM @CommodityAttribute)and strPricingType='UnPriced' AND dtmFutureMonthsDate < @dtmFutureMonthsDate1),0) dblSaleUnpriced
				, ISNULL((SELECT SUM(dblQuantity) FROM #ContractTransaction ct WHERE ct.strFutMarketName=ft.strFutMarketName AND ct.strFutureMonth=t.strFutureMonth AND TranType='Purchase' AND intCommodityAttributeId in(SELECT intCommodityAttributeId FROM @CommodityAttribute) AND strPricingType='Priced' AND dtmFutureMonthsDate < @dtmFutureMonthsDate1),0) dblPurchasePriced
				, ISNULL((SELECT SUM(dblQuantity) FROM #ContractTransaction ct WHERE ct.strFutMarketName=ft.strFutMarketName AND ct.strFutureMonth=t.strFutureMonth AND TranType='Sale' AND intCommodityAttributeId in(SELECT intCommodityAttributeId FROM @CommodityAttribute) AND strPricingType='Priced' AND dtmFutureMonthsDate < @dtmFutureMonthsDate1),0) dblSalePriced
				, 0.0 dblBuySell
			FROM #ContractTransaction t
			JOIN vyuRKGetBuySellTransaction ft ON ft.intFutureMarketId = t.intFutureMarketId AND t.dtmFutureMonthsDate < @dtmFutureMonthsDate1
			WHERE ft.intFutureMarketId = @intCMarketId AND intCommodityAttributeId IN (SELECT intCommodityAttributeId FROM @CommodityAttribute)
				AND t.intCompanyLocationId IN (SELECT intCompanyLocationId FROM @Location)
			GROUP BY ft.strFutMarketName
				, t.strFutureMonth
				, t.intFutureMarketId
				, ft.dblContractSize
				, t.intFutureMarketId
			
			UNION ALL SELECT ft.strFutMarketName
				, t.strFutureMonth
				, t.intFutureMarketId
				, ISNULL((SELECT SUM(dblQuantity) FROM #ContractTransaction ct WHERE ct.strFutMarketName=ft.strFutMarketName AND ct.strFutureMonth=t.strFutureMonth AND ct.TranType='Purchase' AND intCommodityAttributeId in(SELECT intCommodityAttributeId FROM @CommodityAttribute) AND dtmFutureMonthsDate >= @dtmFutureMonthsDate1),0) dblPurchase
				, ISNULL((SELECT SUM(dblQuantity) FROM #ContractTransaction ct WHERE ct.strFutMarketName=ft.strFutMarketName AND ct.strFutureMonth=t.strFutureMonth AND TranType='Sale' AND intCommodityAttributeId in(SELECT intCommodityAttributeId FROM @CommodityAttribute) AND dtmFutureMonthsDate >= @dtmFutureMonthsDate1),0) dblSale
				, ISNULL((SELECT SUM(dblQuantity) FROM #ContractTransaction ct WHERE ct.strFutMarketName=ft.strFutMarketName AND ct.strFutureMonth=t.strFutureMonth AND TranType='Purchase' AND intCommodityAttributeId in(SELECT intCommodityAttributeId FROM @CommodityAttribute) AND strPricingType='UnPriced' AND dtmFutureMonthsDate >= @dtmFutureMonthsDate1),0) dblPurchaseUnpriced
				, ISNULL((SELECT SUM(dblQuantity) FROM #ContractTransaction ct WHERE ct.strFutMarketName=ft.strFutMarketName AND ct.strFutureMonth=t.strFutureMonth AND TranType='Sale' AND intCommodityAttributeId in(SELECT intCommodityAttributeId FROM @CommodityAttribute) AND strPricingType='UnPriced' AND dtmFutureMonthsDate >= @dtmFutureMonthsDate1),0) dblSaleUnpriced
				, ISNULL((SELECT SUM(dblQuantity) FROM #ContractTransaction ct WHERE ct.strFutMarketName=ft.strFutMarketName AND ct.strFutureMonth=t.strFutureMonth AND TranType='Purchase' AND intCommodityAttributeId in(SELECT intCommodityAttributeId FROM @CommodityAttribute) AND strPricingType='Priced' AND dtmFutureMonthsDate >= @dtmFutureMonthsDate1),0) dblPurchasePriced
				, ISNULL((SELECT SUM(dblQuantity) FROM #ContractTransaction ct WHERE ct.strFutMarketName=ft.strFutMarketName AND ct.strFutureMonth=t.strFutureMonth AND TranType='Sale' AND intCommodityAttributeId in(SELECT intCommodityAttributeId FROM @CommodityAttribute) AND strPricingType='Priced' AND dtmFutureMonthsDate >= @dtmFutureMonthsDate1),0) dblSalePriced
				, 0.0 dblBuySell
			FROM #ContractTransaction t
			JOIN vyuRKGetBuySellTransaction ft ON ft.intFutureMarketId = t.intFutureMarketId AND t.dtmFutureMonthsDate >= @dtmFutureMonthsDate1
			WHERE ft.intFutureMarketId = @intCMarketId
				AND intCommodityAttributeId IN (SELECT intCommodityAttributeId FROM @CommodityAttribute)
				AND t.intCompanyLocationId IN (SELECT intCompanyLocationId FROM @Location)
			GROUP BY ft.strFutMarketName
				, t.strFutureMonth
				, t.intFutureMarketId
				, ft.dblContractSize
				, t.intFutureMarketId
			
			UNION ALL SELECT strFutMarketName
				, strFutureMonth
				, intFutureMarketId
				, 0.0 dblPurchase
				, 0.0 dblSale
				, 0.0 dblPurchaseUnpriced
				, 0.0 dblSaleUnpriced
				, 0.0 dblPurchasePriced
				, 0.0 dblSalePriced
				, SUM(dblBuy - dblSell) * MAX(dblContractSize) dblBuySell
			FROM (
				SELECT t.strFutMarketName
					, 'Previous' strFutureMonth
					, t.intFutureMarketId
					, ISNULL(dblBuy, 0) dblBuy
					, ISNULL(dblSell, 0) dblSell
					, dblContractSize
				FROM vyuRKGetBuySellTransaction t
				WHERE t.intFutureMarketId = @intCMarketId
					AND t.intLocationId IN (SELECT intCompanyLocationId FROM @Location)
					AND t.intBrokerageAccountId IN (SELECT intBrokerageAccountId FROM @BrokerageAttributeFinal
													WHERE strCommodityAttributeId IN (SELECT intCommodityAttributeId FROM @CommodityAttribute))
					AND t.dtmFutureMonthsDate < @dtmFutureMonthsDate1
			) t
			GROUP BY strFutMarketName
				, strFutureMonth
				, intFutureMarketId
				
			UNION ALL SELECT strFutMarketName
				, strFutureMonth
				, intFutureMarketId
				, 0.0 dblPurchase
				, 0.0 dblSale
				, 0.0 dblPurchaseUnpriced
				, 0.0 dblSaleUnpriced
				, 0.0 dblPurchasePriced
				, 0.0 dblSalePriced
				, SUM(dblBuy - dblSell) * MAX(dblContractSize) dblBuySell
			FROM (
				SELECT t.strFutMarketName
					, t.strFutureMonth
					, t.intFutureMarketId
					, ISNULL(dblBuy, 0) dblBuy
					, ISNULL(dblSell, 0) dblSell
					, dblContractSize
				FROM vyuRKGetBuySellTransaction t
				WHERE t.intFutureMarketId = @intCMarketId
					AND t.intLocationId IN (SELECT intCompanyLocationId FROM @Location)
					AND t.intBrokerageAccountId IN (SELECT intBrokerageAccountId FROM @BrokerageAttributeFinal
													WHERE strCommodityAttributeId IN (SELECT intCommodityAttributeId FROM @CommodityAttribute))
					AND t.dtmFutureMonthsDate >= @dtmFutureMonthsDate1
			) t
			GROUP BY strFutMarketName
				, strFutureMonth
				, intFutureMarketId
		) t
		GROUP BY strFutMarketName
			, strFutureMonth
			, intFutureMarketId
		ORDER BY strFutMarketName
			, CASE WHEN strFutureMonth = 'Previous' THEN '01/01/1900'
					WHEN strFutureMonth = 'TOTAL' THEN '01/01/9999'
					ELSE CONVERT(DATETIME, '01 ' + strFutureMonth) END ASC

		IF EXISTS (SELECT TOP 1 1 FROM @ContractTemp)
		BEGIN
			INSERT INTO @FinalResult (strFutMarketNameH, strColor)
			SELECT UPPER(@strFutMarket), 'TOTAL'
			
			INSERT INTO @FinalResult (strFutureMonth
				, dblTotalPurchase
				, dblTotalSales
				, dblUnfixedPurchase
				, dblUnfixedSales
				, dblFutures
				, dblTotal
				, intFutureMarketId
				, intCAttributeId
				, intMarketSumDummyId)
			SELECT strFutureMonth strFutureMonth
				, dblTotalPurchase
				, dblTotalSales
				, dblUnfixedPurchase
				, dblUnfixedSales
				, dblFutures
				, dblTotal
				, intFutureMarketId
				, 0
				, -1
			FROM @ContractTemp
			ORDER BY strFutMarketName
				, CASE WHEN strFutureMonth = 'Previous' THEN '01/01/1900'
						WHEN strFutureMonth = 'TOTAL' THEN '01/01/9999'
						ELSE CONVERT(DATETIME, '01 ' + strFutureMonth) END ASC
			
			INSERT INTO @FinalResult (strFutMarketNameH
				, dblTotalPurchase
				, dblTotalSales
				, dblUnfixedPurchase
				, dblUnfixedSales
				, dblFutures
				, dblTotal
				, strColor
				, intMarketSumDummyId)
			SELECT 'TOTAL'
				, SUM(dblTotalPurchase)
				, SUM(dblTotalSales)
				, SUM(dblUnfixedPurchase)
				, SUM(dblUnfixedSales)
				, SUM(dblFutures)
				, SUM(dblTotal)
				, 'TOTAL'
				, -2
			FROM @FinalResult
			WHERE intFutureMarketId = @intCMarketId AND intMarketSumDummyId = -1
		END
		
		SELECT @intFMarketId1 = MIN(intMarketId) FROM @Market WHERE intMarketId > @intFMarketId1
	END
	
	------------------------- END
	
	INSERT INTO @FinalResult (strProductTypeH
		, dblTotalPurchase
		, dblTotalSales
		, dblUnfixedPurchase
		, dblUnfixedSales
		, dblFutures
		, dblTotal
		, strColor)
	SELECT 'TOTAL'
		, SUM(dblTotalPurchase)
		, SUM(dblTotalSales)
		, SUM(dblUnfixedPurchase)
		, SUM(dblUnfixedSales)
		, SUM(dblFutures)
		, SUM(dblTotal)
		, 'Total'
	FROM @FinalResult
	WHERE intMarketSumDummyId = -2
	
	SELECT intRowNum
		, strProductTypeH strProductType
		, strFutMarketNameH strFutMarketName
		, strFutureMonth
		, ROUND(dblTotalPurchase, @intDecimals) AS dblTotalPurchase
		, ROUND(dblTotalSales, @intDecimals) dblTotalSales
		, ROUND(dblUnfixedPurchase, @intDecimals) dblUnfixedPurchase
		, ROUND(dblUnfixedSales, @intDecimals) dblUnfixedSales
		, ROUND(dblFutures, @intDecimals) dblFutures
		, ROUND(dblTotal, @intDecimals) dblTotal
		, intFutureMarketId
		, intCAttributeId intCommodityAttributeId
		, strColor
		, intMarketSumDummyId
		, NULL AS intFutureMonthId
	FROM @FinalResult
	ORDER BY intRowNum
END