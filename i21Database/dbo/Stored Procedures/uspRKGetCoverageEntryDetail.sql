CREATE PROCEDURE [dbo].[uspRKGetCoverageEntryDetail]
	@Date DATETIME
	, @CommodityId INT
	, @UOMType NVARCHAR(50)
	, @UOMId INT
	, @BookId INT = NULL
	, @SubBookId INT = NULL
	, @Decimal INT = 2

AS

BEGIN

--DECLARE @Date DATETIME = '2020-04-14'
--	, @CommodityId INT = 1
--	, @UOMType NVARCHAR(50) = 'By Quantity'
--	, @UOMId INT = 4
--	, @BookId INT = 2
--	, @SubBookId INT = 0
--	, @Decimal INT = 0

	DECLARE @intUnitMeasureId INT
	SET @Date = CAST(FLOOR(CAST(@Date AS FLOAT)) AS DATETIME)
	IF (@BookId = 0)
		SET @BookId = NULL
	IF (@SubBookId = 0)
		SET @SubBookId = NULL

	DECLARE @strUnitMeasure NVARCHAR(100)

	DECLARE @Balances AS TABLE (intBookId INT NULL
		, intSubBookId INT NULL
		, intCommodityId INT NULL
		, intProductTypeId INT NULL
		, dblContracts NUMERIC(24, 10)
		, dblInTransit NUMERIC(24, 10)
		, dblStock NUMERIC(24, 10)
		, dblFutures NUMERIC(24, 10)) 

	IF (ISNULL(@UOMId, 0) = 0)
	BEGIN
		SELECT TOP 1 @intUnitMeasureId = c.intUnitMeasureId
		FROM tblICCommodityUnitMeasure c
		WHERE intCommodityId = @CommodityId
			AND ysnStockUnit = 1
	END
	ELSE
	BEGIN
		SET @intUnitMeasureId = @UOMId
	END

	SELECT intBookId, intSubBookId, intCommodityId, intProductTypeId, dblContracts = ISNULL([Contracts], 0), dblInTransit = ISNULL([In-Transit], 0), dblStock = ISNULL([Stock], 0), dblFutures = ISNULL([Futures], 0)
	INTO #tmpTempBalances
	FROM (
		SELECT strType = 'Contracts'
			, Detail.intBookId
			, Detail.intSubBookId
			, dblBalance = SUM(dbo.[fnCTConvertQuantityToTargetItemUOM](Detail.intItemId, ItemUOM.intUnitMeasureId, @intUnitMeasureId, (ISNULL(Detail.dblBalance, 0) - ISNULL(Detail.dblScheduleQty, 0))))
			, Header.intCommodityId
			, Item.intProductTypeId
		FROM tblCTContractDetail Detail
		JOIN tblCTContractHeader Header ON Header.intContractHeaderId = Detail.intContractHeaderId
		JOIN tblICItem Item ON Item.intItemId = Detail.intItemId
		JOIN tblICItemUOM ItemUOM ON ItemUOM.intItemUOMId = Detail.intItemUOMId
		WHERE Detail.intContractStatusId = 1
			AND Detail.intPricingTypeId = 1
			AND Detail.dblBalance <> 0
			AND Header.intContractTypeId = 1
			AND ISNULL(Header.intCommodityId, 0) = ISNULL(@CommodityId, 0)
			--AND CAST(FLOOR(CAST(Detail.dtmEndDate AS FLOAT)) AS DATETIME) <= @Date
			AND ISNULL(Detail.intBookId, 0) = ISNULL(@BookId, ISNULL(Detail.intBookId, 0))
			AND ISNULL(Detail.intSubBookId, 0) = ISNULL(@SubBookId, ISNULL(Detail.intSubBookId, 0))
		GROUP BY Detail.intBookId
			, Detail.intSubBookId
			, Header.intCommodityId
			, Item.intProductTypeId

		UNION ALL SELECT strType = 'In-Transit'
			, L.intBookId
			, L.intSubBookId
			, dblBalance = SUM(ISNULL(dbo.[fnCTConvertQuantityToTargetItemUOM](LD.intItemId, ItemUOM.intUnitMeasureId, @intUnitMeasureId, LD.dblQuantity), 0))
			, CH.intCommodityId
			, Item.intProductTypeId
		FROM tblLGLoad L
		JOIN tblLGLoadDetail LD ON L.intLoadId = LD.intLoadId AND L.intPurchaseSale = 1
		JOIN tblICItemUOM ItemUOM ON ItemUOM.intItemUOMId = LD.intItemUOMId
		JOIN tblCTContractDetail CD ON CD.intContractDetailId = LD.intPContractDetailId
		JOIN tblCTContractHeader CH ON CH.intContractHeaderId = CD.intContractHeaderId
		JOIN tblICItem Item ON Item.intItemId = LD.intItemId
		WHERE L.ysnPosted = 1
			AND L.intShipmentStatus = 3
			AND L.intShipmentType = 1
			AND ISNULL(CH.intCommodityId, 0) = ISNULL(@CommodityId, 0)
			--AND CAST(FLOOR(CAST(L.dtmDispatchedDate AS FLOAT)) AS DATETIME) <= @Date
			AND ISNULL(L.intBookId, 0) = ISNULL(@BookId, ISNULL(L.intBookId, 0))
			AND ISNULL(L.intSubBookId, 0) = ISNULL(@SubBookId, ISNULL(L.intSubBookId, 0))
		GROUP BY L.intBookId
			, L.intSubBookId
			, CH.intCommodityId
			, Item.intProductTypeId

		UNION ALL SELECT strType = 'Stock'
			, Lots.intBookId
			, Lots.intSubBookId
			, dblBalance = SUM(ISNULL(dbo.[fnCTConvertQuantityToTargetItemUOM](Lots.intItemId, ItemUOM.intUnitMeasureId, @intUnitMeasureId, Lots.dblQty), 0))
			, Lots.intCommodityId
			, Item.intProductTypeId
		FROM vyuLGPickOpenInventoryLots Lots
		JOIN tblICItemUOM ItemUOM ON ItemUOM.intItemUOMId = Lots.intItemUOMId
		JOIN tblICItem Item ON Item.intItemId = Lots.intItemId
		WHERE ISNULL(Lots.intCommodityId, 0) = ISNULL(@CommodityId, 0)
			--AND CAST(FLOOR(CAST(dtmEndDate AS FLOAT)) AS DATETIME) <= @Date
			AND ISNULL(Lots.intBookId, 0) = ISNULL(@BookId, ISNULL(Lots.intBookId, 0))
			AND ISNULL(Lots.intSubBookId, 0) = ISNULL(@SubBookId, ISNULL(Lots.intSubBookId, 0))
		GROUP BY Lots.intBookId
			, Lots.intSubBookId
			, Lots.intCommodityId
			, Item.intProductTypeId
		
		UNION ALL SELECT strType = 'Futures'
			, DAP.intBookId
			, DAP.intSubBookId
			, dblBalance = SUM(DAP.dblNoOfLots * dbo.fnCTConvertQtyToTargetCommodityUOM(DAP.intCommodityId, FM.intUnitMeasureId, @intUnitMeasureId, FM.dblContractSize))
			, DAP.intCommodityId
			, MAT.strCommodityAttributeId
		FROM vyuRKGetDailyAveragePriceDetail DAP
		JOIN tblRKFutureMarket FM ON FM.intFutureMarketId = DAP.intFutureMarketId
		JOIN tblRKCommodityMarketMapping MAT ON MAT.intFutureMarketId = FM.intFutureMarketId
		JOIN tblICCommodityUnitMeasure CUOM ON CUOM.intUnitMeasureId = FM.intUnitMeasureId AND CUOM.intCommodityId = MAT.intCommodityId
		WHERE intDailyAveragePriceId = (SELECT TOP 1 intDailyAveragePriceId
										FROM tblRKDailyAveragePrice
										WHERE ISNULL(intBookId, 0) = ISNULL(@BookId, ISNULL(intBookId, 0))
											AND ISNULL(intSubBookId, 0) = ISNULL(@SubBookId, ISNULL(intSubBookId, 0))
											AND CAST(FLOOR(CAST(dtmDate AS FLOAT)) AS DATETIME) <= @Date
											AND ISNULL(ysnPosted, 0) = 1
										ORDER BY dtmDate DESC)
			AND ISNULL(DAP.intCommodityId, 0) = ISNULL(@CommodityId, 0)
			AND ISNULL(DAP.intBookId, 0) = ISNULL(@BookId, ISNULL(DAP.intBookId, 0))
			AND ISNULL(DAP.intSubBookId, 0) = ISNULL(@SubBookId, ISNULL(DAP.intSubBookId, 0))
		GROUP BY DAP.intBookId
			, DAP.intSubBookId
			, DAP.intCommodityId
			, MAT.strCommodityAttributeId
	) t
	PIVOT (
		SUM(dblBalance)
		FOR strType IN ([Contracts], [In-Transit], [Stock], [Futures])
	) tblPivot

	IF (ISNULL(@BookId, '') = '' AND ISNULL(@SubBookId, '') = '')
	BEGIN
		INSERT INTO @Balances
		SELECT intBookId = NULL
			, intSubBookId = NULL
			, intCommodityId
			, intProductTypeId
			, dblContracts = SUM(ISNULL(dblContracts, 0.00))
			, dblInTransit = SUM(ISNULL(dblInTransit, 0.00))
			, dblStock = SUM(ISNULL(dblStock, 0.00))
			, dblFutures = SUM(ISNULL(dblFutures, 0.00))
		FROM #tmpTempBalances
		GROUP BY intCommodityId
			, intProductTypeId
	END
	ELSE IF (ISNULL(@BookId, '') <> '' AND ISNULL(@SubBookId, '') = '')
	BEGIN
		INSERT INTO @Balances
		SELECT intBookId
			, intSubBookId = NULL
			, intCommodityId
			, intProductTypeId
			, dblContracts = SUM(ISNULL(dblContracts, 0.00))
			, dblInTransit = SUM(ISNULL(dblInTransit, 0.00))
			, dblStock = SUM(ISNULL(dblStock, 0.00))
			, dblFutures = SUM(ISNULL(dblFutures, 0.00))
		FROM #tmpTempBalances
		GROUP BY intCommodityId
			, intProductTypeId
			, intBookId
	END
	ELSE
	BEGIN
		INSERT INTO @Balances
		SELECT intBookId
			, intSubBookId
			, intCommodityId
			, intProductTypeId
			, dblContracts
			, dblInTransit
			, dblStock
			, dblFutures
		FROM #tmpTempBalances
	END

	SELECT intCommodityId
		, intProductTypeId
		, dblFuturesM2M = SUM(dblFuturesM2M)
		, dblFuturesM2MPlus = SUM(dblFuturesM2MPlus)
		, dblFuturesM2MMinus = SUM(dblFuturesM2MMinus)
	INTO #DapSettlement
	FROM (
			SELECT dap.intCommodityId
				, intProductTypeId = MAT.strCommodityAttributeId
				, dap.intFutureMarketId
				, dap.intFutureMonthId
				, dap.dblNoOfLots
				, dap.dblNetLongAvg
				, dblSettlementPrice = ISNULL(dap.dblSettlementPrice, 0)
				, dblFuturesM2M = dap.dblM2M
				, dblFuturesM2MPlus = (((dap.dblSettlementPrice + (dap.dblSettlementPrice * Market.dblM2MSimulationPercent/100)) - dap.dblNetLongAvg) * dap.dblNoOfLots * Market.dblContractSize) / CASE WHEN ISNULL(Cur.ysnSubCurrency, 0) = 1 THEN 100 ELSE 1 END  
				, dblFuturesM2MMinus = (((dap.dblSettlementPrice - (dap.dblSettlementPrice * Market.dblM2MSimulationPercent/100)) - dap.dblNetLongAvg) * dap.dblNoOfLots * Market.dblContractSize) / CASE WHEN ISNULL(Cur.ysnSubCurrency, 0) = 1 THEN 100 ELSE 1 END  
			FROM vyuRKGetDailyAveragePriceDetail dap
			JOIN tblRKFutureMarket Market ON Market.intFutureMarketId = dap.intFutureMarketId  
			JOIN tblRKCommodityMarketMapping MAT ON MAT.intFutureMarketId = dap.intFutureMarketId
			LEFT JOIN tblSMCurrency Cur ON Cur.intCurrencyID = Market.intCurrencyId  
			WHERE dap.intDailyAveragePriceId = (SELECT TOP 1 intDailyAveragePriceId
												FROM tblRKDailyAveragePrice
												WHERE ysnPosted = 1 AND CAST(FLOOR(CAST(dtmDate AS FLOAT)) AS DATETIME) <= @Date
													AND ISNULL(tblRKDailyAveragePrice.intBookId, 0) = ISNULL(@BookId, ISNULL(tblRKDailyAveragePrice.intBookId, 0))
													AND ISNULL(tblRKDailyAveragePrice.intSubBookId, 0) = ISNULL(@SubBookId, ISNULL(tblRKDailyAveragePrice.intSubBookId, 0))
												ORDER BY dtmDate DESC)
	) t
	GROUP BY intCommodityId, intProductTypeId

	SELECT DER.intCommodityId
		, dblQty = SUM(dbo.fnCTConvertQtyToTargetCommodityUOM(DER.intCommodityId, FM.intUnitMeasureId, @intUnitMeasureId, 
						CASE WHEN strOptionType = 'Put' THEN DER.dblOpenContract * -1 ELSE DER.dblOpenContract END
						* DER.dblContractSize))
		, MAT.strCommodityAttributeId
	INTO #OptionsTotal
	FROM vyuRKFutOptTransaction DER
	JOIN tblRKFutureMarket FM ON FM.intFutureMarketId = DER.intFutureMarketId
	JOIN tblRKCommodityMarketMapping MAT ON MAT.intFutureMarketId = DER.intFutureMarketId
	LEFT JOIN (
		SELECT * FROM (
			SELECT intRowNo = ROW_NUMBER() OVER(PARTITION BY SP.intFutureMarketId, SPD.intFutureMonthId, CMM.intCommodityId ORDER BY SP.dtmPriceDate DESC)
				, SPD.intFutSettlementPriceMonthId
				, SPD.intFutureSettlementPriceId
				, SP.intFutureMarketId
				, SPD.intFutureMonthId
				, CMM.intCommodityId
				, dblLastSettle
				, SP.dtmPriceDate
			FROM tblRKFutSettlementPriceMarketMap SPD
			JOIN tblRKFuturesSettlementPrice SP ON SP.intFutureSettlementPriceId = SPD.intFutureSettlementPriceId
			JOIN tblRKCommodityMarketMapping CMM ON CMM.intCommodityMarketId = SP.intCommodityMarketId
		) t WHERE intRowNo = 1
	) sp ON sp.intFutureMarketId = DER.intFutureMarketId
		AND sp.intFutureMonthId = DER.intFutureMonthId
		AND sp.intCommodityId = DER.intCommodityId
	WHERE strInstrumentType = 'Options'
		AND dblOpenContract <> 0
		AND ((strOptionType = 'Call' AND dblLastSettle > dblStrike) OR
			(strOptionType = 'Put' AND dblLastSettle < dblStrike))
		AND ISNULL(DER.intBookId, 0) = ISNULL(@BookId, ISNULL(DER.intBookId, 0))
		AND ISNULL(DER.intSubBookId, 0) = ISNULL(@SubBookId, ISNULL(DER.intSubBookId, 0))
	GROUP BY DER.intCommodityId, MAT.strCommodityAttributeId

	DECLARE @FinalTable AS TABLE(intRowId INT
		, intProductTypeId INT
		, strProductType NVARCHAR(100)
		, intCommodityId INT
		, intBookId INT
		, strBook NVARCHAR(100)
		, intSubBookId INT
		, strSubBook NVARCHAR(100)
		, dblOpenContract NUMERIC(24, 10)
		, dblInTransit NUMERIC(24, 10)
		, dblStock NUMERIC(24, 10)
		, dblTotalPhysical NUMERIC(24, 10)
		, dblOpenFutures NUMERIC(24, 10)
		, dblTotalPosition NUMERIC(24, 10)
		, dblMonthsCovered NUMERIC(24, 10)
		, dblAveragePrice NUMERIC(24, 10)
		, dblTotalOption NUMERIC(24, 10)
		, dblOptionsCovered NUMERIC(24, 10)
		, dblFuturesM2M NUMERIC(24, 10)
		, dblM2MPlus10 NUMERIC(24, 10)
		, dblM2MMinus10 NUMERIC(24, 10))
	
	INSERT INTO @FinalTable
	SELECT intRowId = ROW_NUMBER() OVER(ORDER BY ComAtt.intCommodityAttributeId, ISNULL(Book.intBookId, 0), ISNULL(SubBook.intSubBookId, 0))
		, intProductTypeId = ComAtt.intCommodityAttributeId
		, strProductType = ComAtt.strDescription
		, ComAtt.intCommodityId
		, Book.intBookId
		, Book.strBook
		, SubBook.intSubBookId
		, SubBook.strSubBook
		, dblOpenContract = Balance.dblContracts
		, Balance.dblInTransit
		, Balance.dblStock
		, dblTotalPhysical = Balance.dblContracts + Balance.dblInTransit + Balance.dblStock
		, dblOpenFutures = Balance.dblFutures
		, dblTotalPosition = Balance.dblContracts + Balance.dblInTransit + Balance.dblStock + Balance.dblFutures
		, dblMonthsCovered = 0.00
		, dblAveragePrice = dap.dblWeightedAvePrice
		, dblTotalOption = ot.dblQty
		, dblOptionsCovered = 0.00
		, dblFuturesM2M = ds.dblFuturesM2M
		, dblM2MPlus10 = ds.dblFuturesM2MPlus
		, dblM2MMinus10 = ds.dblFuturesM2MMinus
	FROM tblICCommodityAttribute ComAtt
	LEFT JOIN @Balances Balance ON Balance.intCommodityId = ComAtt.intCommodityId AND ComAtt.intCommodityAttributeId = Balance.intProductTypeId
	LEFT JOIN tblCTBook Book ON Book.intBookId = Balance.intBookId
	LEFT JOIN tblCTSubBook SubBook ON SubBook.intSubBookId = Balance.intSubBookId
	LEFT JOIN (
		SELECT dapD.intCommodityId
			, intBookId
			, intSubBookId
			, dblWeightedAvePrice = SUM((dblNoOfLots * dblAverageLongPrice)) / SUM(dblNoOfLots)
			, intProdTypeId = MAT.strCommodityAttributeId
		FROM tblRKDailyAveragePriceDetail dapD
		JOIN tblRKCommodityMarketMapping MAT ON MAT.intFutureMarketId = dapD.intFutureMarketId
		JOIN tblRKDailyAveragePrice dap ON dap.intDailyAveragePriceId = dapD.intDailyAveragePriceId
		WHERE dap.intDailyAveragePriceId = (SELECT TOP 1 intDailyAveragePriceId FROM tblRKDailyAveragePrice WHERE ysnPosted = 1 AND CAST(FLOOR(CAST(dtmDate AS FLOAT)) AS DATETIME) <= @Date ORDER BY dtmDate DESC)
			AND ISNULL(dblNoOfLots, 0) <> 0
		GROUP BY dapD.intCommodityId
			, intBookId
			, intSubBookId
			, MAT.strCommodityAttributeId
	) dap ON dap.intCommodityId = Balance.intCommodityId AND dap.intProdTypeId = ComAtt.intCommodityAttributeId AND
			ISNULL(dap.intBookId, 0) = ISNULL(Balance.intBookId, 0) AND ISNULL(dap.intSubBookId, 0) = ISNULL(Balance.intSubBookId, 0) 
	LEFT JOIN #DapSettlement ds ON ds.intCommodityId = Balance.intCommodityId AND ds.intProductTypeId = ComAtt.intCommodityAttributeId
	LEFT JOIN #OptionsTotal ot ON ot.intCommodityId = Balance.intCommodityId AND ot.strCommodityAttributeId = ComAtt.intCommodityAttributeId
	WHERE ISNULL(ComAtt.intCommodityId, 0) = ISNULL(@CommodityId, 0)
		AND strType = 'ProductType'
		AND (Balance.dblContracts IS NOT NULL AND Balance.dblInTransit IS NOT NULL AND Balance.dblStock IS NOT NULL AND Balance.dblFutures IS NOT NULL)
	
	SELECT intRowNum = ROW_NUMBER() OVER(ORDER BY intProductTypeId, dtmDemandDate)
		, intCommodityId
		, dtmDemandDate
		, intProductTypeId
		, dblQuantity
	INTO #DemandDetail
	FROM (
		SELECT i.intCommodityId
			, DD.dtmDemandDate
			, dblQuantity = dbo.fnCTConvertQuantityToTargetItemUOM (i.intItemId, iUOM.intUnitMeasureId, @intUnitMeasureId, DD.dblQuantity)
			, i.intProductTypeId	
		FROM tblMFDemandDetail DD
		JOIN tblICItem i ON i.intItemId = DD.intItemId
		JOIN tblICItemUOM iUOM ON iUOM.intItemUOMId = DD.intItemUOMId
		WHERE DD.intDemandHeaderId = (
			SELECT TOP 1 intDemandHeaderId FROM tblMFDemandHeader DH
			WHERE ISNULL(DH.intBookId, 0) = ISNULL(@BookId, ISNULL(DH.intBookId, 0))
				AND ISNULL(DH.intSubBookId, 0) = ISNULL(@SubBookId, ISNULL(DH.intSubBookId, 0))
				AND CAST(FLOOR(CAST(DH.dtmDate AS FLOAT)) AS DATETIME) <= CAST(FLOOR(CAST(@Date AS FLOAT)) AS DATETIME)
			ORDER BY DH.dtmDate DESC
		) 
	) tbl

	SELECT tbl.*
		, dblRunningTotal
		, intProductTypeIndex = ROW_NUMBER() OVER (PARTITION BY tbl.intProductTypeId ORDER BY intRowNum)
	INTO #Demand
	FROM #DemandDetail tbl
	CROSS APPLY (
		SELECT dblRunningTotal = ISNULL(SUM(ddSum.dblQuantity), 0)
		FROM (
			SELECT dd.dblQuantity
			FROM #DemandDetail dd
			WHERE dd.intRowNum <= tbl.intRowNum
				AND dd.intProductTypeId = tbl.intProductTypeId
		) ddSum
	) RT

	SELECT *
	INTO #iterateTable
	FROM @FinalTable

	DECLARE @rowId INT
		, @dblPosition NUMERIC(24, 10)
		, @dblOption NUMERIC(24, 10)
		, @ysnNegativeOptions BIT
		, @intProductType INT
		, @dblRunningBalance NUMERIC(24, 10)
		, @startOption INT
		, @endOption INT
		, @monthsCovered NUMERIC(24,10)
		, @optionsCovered NUMERIC(24, 10)
		, @dblDemand NUMERIC(24,10)
		, @dblDifference NUMERIC(24,10) = 0
		
	WHILE EXISTS(SELECT TOP 1 1 FROM #iterateTable)
	BEGIN
		SELECT TOP 1 @rowId = intRowId
			, @dblPosition = dblTotalPosition
			, @dblOption = ABS(dblTotalOption)
			, @ysnNegativeOptions = CASE WHEN dblTotalOption < 0 THEN 1 ELSE 0 END
			, @intProductType = intProductTypeId
		FROM #iterateTable i
		
		SELECT @dblRunningBalance = 0
			, @startOption = 0
			, @dblDemand = 0

		SELECT  @monthsCovered = COUNT(intProductTypeId)
		FROM #Demand
		WHERE intProductTypeId = @intProductType
		
		SELECT TOP 1 @dblRunningBalance = dblRunningTotal
			, @monthsCovered = intProductTypeIndex
			, @startOption = intProductTypeIndex
			, @dblDemand = dblQuantity
		FROM #Demand
		WHERE dblRunningTotal >= @dblPosition
			AND intProductTypeId = @intProductType
		ORDER BY intRowNum

		IF (ISNULL(@dblRunningBalance, 0) <> 0)
		BEGIN
			IF (@dblRunningBalance > @dblPosition)
			BEGIN
				SET @monthsCovered -= 1
				SET @dblDifference = @dblPosition - (@dblRunningBalance - @dblDemand)
				SET @monthsCovered += @dblDifference / @dblDemand
				SET @dblDifference = @dblDemand - @dblDifference
			END
			
			IF (@dblDifference > @dblOption)
			BEGIN
				SET @optionsCovered = @dblOption / @dblDemand
			END
			ELSE IF (@dblOption >= @dblDifference)
			BEGIN
				SET @optionsCovered = @dblDifference / @dblDemand
				SET @dblDifference = @dblOption - @dblDifference
			END
			
			IF (@dblDifference <> 0)
			BEGIN
				SELECT TOP 1 @dblRunningBalance = dblRunningTotal, @endOption = intProductTypeIndex, @dblDemand = dblQuantity FROM #Demand
				WHERE dblRunningTotal >= (@dblPosition + @dblOption)
					AND intProductTypeId = @intProductType
				ORDER BY intRowNum
				
				IF (@startOption <> @endOption) AND (@dblRunningBalance > (@dblPosition + @dblOption))
				BEGIN
					SET @endOption -= 1
					SET @endOption -= @startOption

					SET @dblDifference = (@dblPosition + @dblOption) - (@dblRunningBalance - @dblDemand)
					SET @optionsCovered += @dblDifference / @dblDemand
					SET @dblDifference = 0
					SET @optionsCovered += @endOption
				END
			END
		END
		ELSE
		BEGIN
			SET @optionsCovered = 0
		END

		UPDATE @FinalTable
		SET dblMonthsCovered = @monthsCovered
			, dblOptionsCovered = CASE WHEN @ysnNegativeOptions = 1 THEN @optionsCovered * -1 ELSE @optionsCovered END
		WHERE intRowId = @rowId

		DELETE FROM #iterateTable WHERE intRowId = @rowId
	END

	SELECT intProductTypeId
		, strProductType
		, intBookId
		, strBook
		, intSubBookId
		, strSubBook
		, dblOpenContract
		, dblInTransit
		, dblStock
		, dblTotalPhysical
		, dblOpenFutures
		, dblTotalPosition
		, dblMonthsCovered
		, dblAveragePrice
		, dblTotalOption
		, dblOptionsCovered
		, dblFuturesM2M
		, dblM2MPlus10
		, dblM2MMinus10
	FROM @FinalTable

	DROP TABLE #OptionsTotal
	DROP TABLE #DapSettlement
	DROP TABLE #iterateTable
	DROP TABLE #Demand
	DROP TABLE #DemandDetail
	DROP TABLE #tmpTempBalances
END