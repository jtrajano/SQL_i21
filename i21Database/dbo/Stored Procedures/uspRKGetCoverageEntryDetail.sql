﻿CREATE PROCEDURE [dbo].[uspRKGetCoverageEntryDetail]
	@Date DATETIME
	, @CommodityId INT
	, @UOMType NVARCHAR(50)
	, @UOMId INT
	, @BookId INT = NULL
	, @SubBookId INT = NULL
	, @Decimal INT = 2

AS

BEGIN
--DECLARE @Date DATETIME = GETDATE()
--	, @CommodityId INT = 7
--	, @UOMType NVARCHAR(50) = 'By Lot'
--	, @UOMId INT
--	, @BookId INT = NULL
--	, @SubBookId INT = NULL
--	, @Decimal INT = 2

	DECLARE @intUnitMeasureId INT
	SET @Date = CAST(FLOOR(CAST(@Date AS FLOAT)) AS DATETIME)

	DECLARE @strUnitMeasure NVARCHAR(100)

	IF (ISNULL(@UOMId, 0) = 0)
	BEGIN
		SELECT TOP 1 @intUnitMeasureId = c.intUnitMeasureId
		FROM tblICCommodityUnitMeasure c
		WHERE intCommodityId = @CommodityId
			AND ysnStockUnit = 1
	END
	ELSE
	BEGIN
		SELECT TOP 1 @intUnitMeasureId = c.intUnitMeasureId
		FROM tblICCommodityUnitMeasure c
		WHERE c.intCommodityUnitMeasureId = @UOMId
	END
	
	SELECT intBookId, intSubBookId, intCommodityId, intProductTypeId, dblContracts = ISNULL([Contracts], 0), dblInTransit = ISNULL([In-Transit], 0), dblStock = ISNULL([Stock], 0), dblFutures = ISNULL([Futures], 0)
	INTO #tmpBalances
	FROM (
		SELECT DISTINCT strType = 'Contracts'
			, Detail.intBookId
			, Detail.intSubBookId
			, dblBalance = SUM(ISNULL(dbo.[fnCTConvertQuantityToTargetItemUOM](Detail.intItemId, Detail.intUnitMeasureId, @intUnitMeasureId, Detail.dblBalance), 0))
			, Header.intCommodityId
			, Item.intProductTypeId
		FROM tblCTContractDetail Detail
		JOIN tblCTContractHeader Header ON Header.intContractHeaderId = Detail.intContractHeaderId
		JOIN tblICItem Item ON Item.intItemId = Detail.intItemId
		WHERE Detail.intContractStatusId = 1
			AND Detail.intPricingTypeId = 1
			AND Detail.dblBalance <> 0
			AND Header.intContractTypeId = 1
			AND ISNULL(Header.intCommodityId, 0) = ISNULL(@CommodityId, 0)
			AND CAST(FLOOR(CAST(Detail.dtmEndDate AS FLOAT)) AS DATETIME) <= @Date
			AND ISNULL(Detail.intBookId, 0) = ISNULL(@BookId, 0)
			AND ISNULL(Detail.intSubBookId, 0) = ISNULL(@SubBookId, 0)
		GROUP BY Detail.intBookId
			, Detail.intSubBookId
			, Header.intCommodityId
			, Item.intProductTypeId

		UNION ALL SELECT DISTINCT strType = 'In-Transit'
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
			AND L.intShipmentStatus <> 10
			AND L.intShipmentType = 1
			AND ISNULL(CH.intCommodityId, 0) = ISNULL(@CommodityId, 0)
			AND CAST(FLOOR(CAST(L.dtmDispatchedDate AS FLOAT)) AS DATETIME) <= @Date
			AND ISNULL(L.intBookId, 0) = ISNULL(@BookId, 0)
			AND ISNULL(L.intSubBookId, 0) = ISNULL(@SubBookId, 0)
		GROUP BY L.intBookId
			, L.intSubBookId
			, CH.intCommodityId
			, Item.intProductTypeId

		UNION ALL SELECT DISTINCT strType = 'Stock'
			, Lots.intBookId
			, Lots.intSubBookId
			, dblBalance = SUM(ISNULL(dbo.[fnCTConvertQuantityToTargetItemUOM](Lots.intItemId, ItemUOM.intUnitMeasureId, @intUnitMeasureId, Lots.dblBalance), 0))
			, Lots.intCommodityId
			, Item.intProductTypeId
		FROM vyuLGPickOpenInventoryLots Lots
		JOIN tblICItemUOM ItemUOM ON ItemUOM.intItemUOMId = Lots.intItemUOMId
		JOIN tblICItem Item ON Item.intItemId = Lots.intItemId
		WHERE ISNULL(Lots.intCommodityId, 0) = ISNULL(@CommodityId, 0)
			AND CAST(FLOOR(CAST(dtmEndDate AS FLOAT)) AS DATETIME) <= @Date
			AND ISNULL(Lots.intBookId, 0) = ISNULL(@BookId, 0)
			AND ISNULL(Lots.intSubBookId, 0) = ISNULL(@SubBookId, 0)
		GROUP BY Lots.intBookId
			, Lots.intSubBookId
			, Lots.intCommodityId
			, Item.intProductTypeId
		
		UNION ALL SELECT DISTINCT strType = 'Futures'
			, DAP.intBookId
			, DAP.intSubBookId
			, dblBalance = SUM(ISNULL(DAP.dblNoOfLots * FM.dblContractSize, 0))
			, DAP.intCommodityId
			, NULL
		FROM vyuRKGetDailyAveragePriceDetail DAP
		JOIN tblRKFutureMarket FM ON FM.intFutureMarketId = DAP.intFutureMarketId
		WHERE intDailyAveragePriceId = (SELECT TOP 1 intDailyAveragePriceId
										FROM tblRKDailyAveragePrice
										WHERE intBookId = @BookId AND intSubBookId = @SubBookId
											AND CAST(FLOOR(CAST(dtmDate AS FLOAT)) AS DATETIME) <= @Date
										ORDER BY dtmDate DESC)
			AND ISNULL(intCommodityId, 0) = ISNULL(@CommodityId, 0)
			AND ISNULL(DAP.intBookId, 0) = ISNULL(@BookId, 0)
			AND ISNULL(DAP.intSubBookId, 0) = ISNULL(@SubBookId, 0)
		GROUP BY DAP.intBookId
			, DAP.intSubBookId
			, DAP.intCommodityId
	) t
	PIVOT (
		SUM(dblBalance)
		FOR strType IN ([Contracts], [In-Transit], [Stock], [Futures])
	) tblPivot

	SELECT intCommodityId
		, dblFuturesM2M = SUM(dblFuturesM2M) / SUM(dblNoOfLots)
		, dblFuturesM2MPlus = SUM(dblFuturesM2MPlus) / SUM(dblNoOfLots)
		, dblFuturesM2MMinus = SUM(dblFuturesM2MMinus) / SUM(dblNoOfLots)
	INTO #DapSettlement
	FROM (
		SELECT t.*
			, dblM2MSimulationPercent = dblM2MSimulationPercent / 100
			, dblFuturesM2MPlus = dblFuturesM2M + (dblFuturesM2M * (dblM2MSimulationPercent / 100))
			, dblFuturesM2MMinus = dblFuturesM2M - (dblFuturesM2M * (dblM2MSimulationPercent / 100))
		FROM
		(
			SELECT dap.intCommodityId
				, dap.intFutureMarketId
				, dap.intFutureMonthId
				, dap.dblNoOfLots
				, dap.dblNetLongAvg
				, dblSettlementPrice = ISNULL(sp.dblLastSettle, 0)
				, dblFuturesM2M = (dblNetLongAvg - ISNULL(sp.dblLastSettle, 0)) * dblNoOfLots
			FROM tblRKDailyAveragePriceDetail dap
			JOIN (
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
					WHERE CAST(FLOOR(CAST(SP.dtmPriceDate AS FLOAT)) AS DATETIME) <= @Date
				) t WHERE intRowNo = 1
			) sp ON sp.intFutureMarketId = dap.intFutureMarketId
				AND sp.intFutureMonthId = dap.intFutureMonthId
				AND sp.intCommodityId = dap.intCommodityId
			WHERE dap.intDailyAveragePriceId = (SELECT TOP 1 intDailyAveragePriceId FROM tblRKDailyAveragePrice WHERE ysnPosted = 1 AND CAST(FLOOR(CAST(dtmDate AS FLOAT)) AS DATETIME) <= @Date ORDER BY dtmDate DESC)
		) t
		JOIN tblRKFutureMarket FM ON FM.intFutureMarketId = t.intFutureMarketId
	) t
	GROUP BY intCommodityId

	SELECT DER.intCommodityId
		, dblQty = SUM(dbo.fnCTConvertQtyToTargetCommodityUOM(DER.intCommodityId, FM.intUnitMeasureId, @intUnitMeasureId, DER.dblOpenContract * DER.dblContractSize))
	INTO #OptionsTotal
	FROM dbo.fnRKGetOpenFutureByDate(NULL, '1/1/1900', GETDATE(), 1) DER
	JOIN tblRKFutureMarket FM ON FM.intFutureMarketId = DER.intFutureMarketId
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
	GROUP BY DER.intCommodityId

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
	SELECT intRowId = ROW_NUMBER() OVER(ORDER BY intProductTypeId, Book.intBookId, SubBook.intSubBookId)
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
	LEFT JOIN #tmpBalances Balance ON Balance.intCommodityId = ComAtt.intCommodityId AND ComAtt.intCommodityAttributeId = Balance.intProductTypeId
	LEFT JOIN tblCTBook Book ON Book.intBookId = Balance.intBookId
	LEFT JOIN tblCTSubBook SubBook ON SubBook.intSubBookId = Balance.intSubBookId
	LEFT JOIN (
		SELECT intCommodityId
			, intBookId
			, intSubBookId
			, dblWeightedAvePrice = SUM((dblNoOfLots * dblAverageLongPrice)) / SUM(dblNoOfLots)
		FROM tblRKDailyAveragePriceDetail dapD
		JOIN tblRKDailyAveragePrice dap ON dap.intDailyAveragePriceId = dapD.intDailyAveragePriceId
		WHERE dap.intDailyAveragePriceId = (SELECT TOP 1 intDailyAveragePriceId FROM tblRKDailyAveragePrice WHERE ysnPosted = 1 AND CAST(FLOOR(CAST(dtmDate AS FLOAT)) AS DATETIME) <= @Date ORDER BY dtmDate DESC)
			AND ISNULL(dblNoOfLots, 0) <> 0
		GROUP BY intCommodityId
			, intBookId
			, intSubBookId
	) dap ON dap.intCommodityId = Balance.intCommodityId AND dap.intBookId = Balance.intBookId AND dap.intSubBookId = Balance.intSubBookId
	LEFT JOIN #DapSettlement ds ON ds.intCommodityId = Balance.intCommodityId
	LEFT JOIN #OptionsTotal ot ON ot.intCommodityId = Balance.intCommodityId
	WHERE ISNULL(ComAtt.intCommodityId, 0) = ISNULL(@CommodityId, 0)
		AND strType = 'ProductType'
		AND (Balance.dblContracts IS NOT NULL AND Balance.dblInTransit IS NOT NULL AND Balance.dblStock IS NOT NULL AND Balance.dblFutures IS NOT NULL)


	SELECT intRowNum = ROW_NUMBER() OVER(ORDER BY dtmDemandDate)
		, intCommodityId
		, dtmDemandDate
		, intProductTypeId
		, dblQuantity
		, dblRunningTotal = SUM(dblQuantity) OVER (ORDER BY dtmDemandDate)
	INTO #Demand
	FROM (
		SELECT i.intCommodityId
			, DD.dtmDemandDate
			, dblQuantity = dbo.fnCTConvertQuantityToTargetItemUOM (i.intItemId, iUOM.intUnitMeasureId, @intUnitMeasureId, DD.dblQuantity)
			, intProductTypeId = (SELECT DISTINCT TOP 1 intProductTypeId
								FROM tblICItemBundle bundle
								JOIN tblICItem bundleItem ON bundleItem.intItemId = bundle.intBundleItemId
								WHERE bundle.intItemId = DD.intItemId)
	
		FROM tblMFDemandDetail DD
		JOIN tblICItem i ON i.intItemId = DD.intItemId
		JOIN tblICItemUOM iUOM ON iUOM.intItemUOMId = DD.intItemUOMId
	) tbl

	SELECT *
	INTO #iterateTable
	FROM @FinalTable

	DECLARE @rowId INT
		, @dblPosition NUMERIC(24, 10)
		, @dblOption NUMERIC(24, 10)
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
			, @dblOption = dblTotalOption
		FROM #iterateTable

		SELECT TOP 1 @dblRunningBalance = dblRunningTotal
			, @monthsCovered = intRowNum
			, @startOption = intRowNum
			, @dblDemand = dblQuantity
		FROM #Demand
		WHERE dblRunningTotal >= @dblPosition
		ORDER BY dtmDemandDate

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
			SELECT TOP 1 @dblRunningBalance = dblRunningTotal, @endOption = intRowNum, @dblDemand = dblQuantity FROM #Demand
			WHERE dblRunningTotal >= (@dblPosition + @dblOption)
			ORDER BY dtmDemandDate

			IF (@dblRunningBalance > (@dblPosition + @dblOption))
			BEGIN
				SET @endOption -= 1
				SET @endOption -= @startOption

				SET @dblDifference = (@dblPosition + @dblOption) - (@dblRunningBalance - @dblDemand)
				SET @optionsCovered += @dblDifference / @dblDemand
				SET @dblDifference = 0
			END

			SET @optionsCovered += @endOption
		END

		UPDATE @FinalTable
		SET dblMonthsCovered = @monthsCovered
			, dblOptionsCovered = @optionsCovered
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
	DROP TABLE #tmpBalances
END