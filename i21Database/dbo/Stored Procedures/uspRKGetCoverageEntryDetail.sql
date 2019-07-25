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

	SELECT *
	FROM (
		SELECT DISTINCT strType = 'Contracts'
			, Detail.intBookId
			, Detail.intSubBookId
			, dblBalance = SUM(dbo.[fnCTConvertQuantityToTargetItemUOM](cd.intItemId, cd.intUnitMeasureId, @intUnitMeasureId, Detail.dblBalance))
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
			, dblBalance = SUM(dbo.[fnCTConvertQuantityToTargetItemUOM](LD.intItemId, ItemUOM.intUnitMeasureId, @intUnitMeasureId, LD.dblQuantity))
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
			AND ISNULL(Detail.intBookId, 0) = ISNULL(@BookId, 0)
			AND ISNULL(Detail.intSubBookId, 0) = ISNULL(@SubBookId, 0)
		GROUP BY L.intBookId
			, L.intSubBookId
			, CH.intCommodityId

		UNION ALL SELECT DISTINCT strType = 'Stock'
			, Lots.intBookId
			, Lots.intSubBookId
			, dblBalance = SUM(dbo.[fnCTConvertQuantityToTargetItemUOM](Lots.intItemId, ItemUOM.intUnitMeasureId, @intUnitMeasureId, Lots.dblBalance))
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
			, dblBalance = SUM(DAP.dblNoOfLots * FM.dblContractSize)
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

	

END