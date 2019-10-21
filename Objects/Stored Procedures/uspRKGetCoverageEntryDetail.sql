CREATE PROCEDURE [dbo].[uspRKGetCoverageEntryDetail]
	@BatchName NVARCHAR(50)
	, @Date DATETIME
	, @CommodityId INT
	, @UOMType NVARCHAR(50)
	, @UOMId INT
	, @BookId INT = NULL
	, @SubBookId INT = NULL
	, @Decimal INT = 2

AS

BEGIN
	DECLARE @intUnitMeasureId INT
	SET @Date = CAST(FLOOR(CAST(@Date AS FLOAT)) AS DATETIME)

	DECLARE @strUnitMeasure NVARCHAR(100)

	SELECT @intUnitMeasureId = c.intUnitMeasureId
	FROM tblICCommodityUnitMeasure c
	WHERE c.intCommodityUnitMeasureId = @UOMId	

	SELECT intCommodityAttributeId
		, strProductType = strDescription
	FROM tblICCommodityAttribute
	WHERE ISNULL(intCommodityId, 0) = ISNULL(@CommodityId, 0)
		AND strType = 'ProductType'

	SELECT intBookId, intSubBookId, intCommodityId, dblContracts = ISNULL([Contracts], 0), dblInTransit = ISNULL([In-Transit], 0), dblStock = ISNULL([Stock], 0), dblFutures = ISNULL([Futures], 0)
	INTO #tmpBalances
	FROM (
		SELECT DISTINCT strType = 'Contracts'
			, Detail.intBookId
			, Detail.intSubBookId
			, dblBalance = SUM(ISNULL(dbo.[fnCTConvertQuantityToTargetItemUOM](Detail.intItemId, Detail.intUnitMeasureId, @intUnitMeasureId, Detail.dblBalance), 0))
			, Header.intCommodityId
		FROM tblCTContractDetail Detail
		JOIN tblCTContractHeader Header ON Header.intContractHeaderId = Detail.intContractHeaderId
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

		UNION ALL SELECT DISTINCT strType = 'In-Transit'
			, L.intBookId
			, L.intSubBookId
			, dblBalance = SUM(ISNULL(dbo.[fnCTConvertQuantityToTargetItemUOM](LD.intItemId, ItemUOM.intUnitMeasureId, @intUnitMeasureId, LD.dblQuantity), 0))
			, CH.intCommodityId
		FROM tblLGLoad L
		JOIN tblLGLoadDetail LD ON L.intLoadId = LD.intLoadId AND L.intPurchaseSale = 1
		JOIN tblICItemUOM ItemUOM ON ItemUOM.intItemUOMId = LD.intItemUOMId
		JOIN tblCTContractDetail CD ON CD.intContractDetailId = LD.intPContractDetailId
		JOIN tblCTContractHeader CH ON CH.intContractHeaderId = CD.intContractHeaderId
		WHERE L.ysnPosted = 1
			AND L.intShipmentStatus = 3
			AND ISNULL(CH.intCommodityId, 0) = ISNULL(@CommodityId, 0)
			AND CAST(FLOOR(CAST(L.dtmDispatchedDate AS FLOAT)) AS DATETIME) <= @Date
			AND ISNULL(L.intBookId, 0) = ISNULL(@BookId, 0)
			AND ISNULL(L.intSubBookId, 0) = ISNULL(@SubBookId, 0)
		GROUP BY L.intBookId
			, L.intSubBookId
			, CH.intCommodityId

		UNION ALL SELECT DISTINCT strType = 'Stock'
			, Lots.intBookId
			, Lots.intSubBookId
			, dblBalance = SUM(ISNULL(dbo.[fnCTConvertQuantityToTargetItemUOM](Lots.intItemId, ItemUOM.intUnitMeasureId, @intUnitMeasureId, Lots.dblBalance), 0))
			, Lots.intCommodityId
		FROM vyuLGPickOpenInventoryLots Lots
		JOIN tblICItemUOM ItemUOM ON ItemUOM.intItemUOMId = Lots.intItemUOMId
		WHERE ISNULL(intCommodityId, 0) = ISNULL(@CommodityId, 0)
			AND CAST(FLOOR(CAST(dtmEndDate AS FLOAT)) AS DATETIME) <= @Date
			AND ISNULL(Lots.intBookId, 0) = ISNULL(@BookId, 0)
			AND ISNULL(Lots.intSubBookId, 0) = ISNULL(@SubBookId, 0)
		GROUP BY Lots.intBookId
			, Lots.intSubBookId
			, Lots.intCommodityId
		
		UNION ALL SELECT DISTINCT strType = 'Futures'
			, DAP.intBookId
			, DAP.intSubBookId
			, dblBalance = SUM(ISNULL(DAP.dblNoOfLots * FM.dblContractSize, 0))
			, DAP.intCommodityId
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

	SELECT ComAtt.intCommodityAttributeId
		, strProductType = ComAtt.strDescription
		, Book.intBookId
		, Book.strBook
		, SubBook.intSubBookId
		, SubBook.strSubBook
		, Balance.dblContracts
		, Balance.dblInTransit
		, Balance.dblStock
		, dblTotalPhysical = Balance.dblContracts + Balance.dblInTransit + Balance.dblStock
		, Balance.dblFutures
		, dblTotalPosition = Balance.dblContracts + Balance.dblInTransit + Balance.dblStock + Balance.dblFutures

	FROM tblICCommodityAttribute ComAtt
	LEFT JOIN #tmpBalances Balance ON Balance.intCommodityId = ComAtt.intCommodityId
	LEFT JOIN tblCTBook Book ON Book.intBookId = Balance.intBookId
	LEFT JOIN tblCTSubBook SubBook ON SubBook.intSubBookId = Balance.intSubBookId
	WHERE ISNULL(ComAtt.intCommodityId, 0) = ISNULL(@CommodityId, 0)
		AND strType = 'ProductType'

	DROP TABLE #tmpBalances

	

END