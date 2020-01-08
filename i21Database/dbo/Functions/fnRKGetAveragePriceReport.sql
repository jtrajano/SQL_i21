CREATE FUNCTION [dbo].[fnRKGetAveragePriceReport]
(
	@Date DATETIME
)
RETURNS @FinalTable TABLE
(
	intBookId INT
	, strBook NVARCHAR(100)
	, intSubBookId INT
	, strSubBook NVARCHAR(100)
	, intProductTypeId INT
	, strProductType NVARCHAR(100)
	, strTransactionType NVARCHAR(100)
	, strTransactionStatus NVARCHAR(100)
	, strTransactionNo NVARCHAR(100)
	, intBundleItemId INT
	, strBundle NVARCHAR(100)
	, intItemId INT
	, strItemNo NVARCHAR(100)
	, dtmAvailability DATETIME
	, intFutureMarketId INT
	, strFutureMarket NVARCHAR(100)
	, intFutureMonthId INT
	, strFutureMonth NVARCHAR(100)
	, dblQty NUMERIC(24, 10)
	, dblTransactionPrice NUMERIC(24, 10)
	, dblContractDifferential NUMERIC(24, 10)
	, dblSettlementPrice NUMERIC(24, 10)
	, dblForecastTerminal NUMERIC(24, 10)
	, dblForecastDifferential NUMERIC(24, 10)
	, dblFreight NUMERIC(24, 10)
)
AS
BEGIN
	DECLARE @intCurrencyId INT
		, @dtmDate DATETIME = ISNULL(@Date, GETDATE())

	SELECT TOP 1 @intCurrencyId = intCurrencyID FROM tblSMCurrency WHERE strCurrency LIKE '%USD%'

	; WITH TonUOM (
		intCommodityId
		, intUnitMeasureId
		, intItemUOMId
	) AS (
		SELECT intCommodityId
			, intUnitMeasureId
			, intItemUOMId
		FROM (
			SELECT intRowId = ROW_NUMBER() OVER (PARTITION BY intCommodityId ORDER BY ItemUOM.intUnitMeasureId DESC)
				, intCommodityId
				, ItemUOM.intUnitMeasureId
				, ItemUOM.intItemUOMId
			FROM tblICItemUOM ItemUOM
			JOIN tblICUnitMeasure UOM ON UOM.intUnitMeasureId = ItemUOM.intUnitMeasureId
			JOIN tblICItem Item ON Item.intItemId = ItemUOM.intItemId
			WHERE UOM.strUnitMeasure LIKE '%MT%'
				OR UOM.strUnitMeasure LIKE '%Ton%'
		) t WHERE intRowId = 1
	)

	INSERT @FinalTable
	SELECT t.intBookId
		, book.strBook
		, t.intSubBookId
		, subBook.strSubBook
		, intProductTypeId
		, strProductType = att.strDescription
		, strTransactionType
		, strTransactionStatus
		, strTransactionNo
		, intBundleItemId = NULL
		, strBundleItem = NULL
		, intItemId
		, strItemDescription
		, dtmAvailability
		, t.intFutureMarketId
		, strFutureMarket = fMar.strFutMarketName
		, t.intFutureMonthId
		, fMon.strFutureMonth
		, dblQty
		, dblTransactionPrice
		, dblContractDifferential
		, dblSettlementPrice = LastSettle.dblLastSettle
		, dblForecastTerminal = fMar.dblForecastPrice
		, dblForecastDifferential = BasisEntry.dblBasisOrDiscount
		, dblFreight
	FROM (
		SELECT DISTINCT Header.intCommodityId
			, Detail.intBookId
			, Detail.intSubBookId
			, Item.intProductTypeId
			, strTransactionType = 'Physical'
			, strTransactionStatus = 'Open'
			, strTransactionNo = Header.strContractNumber + ' - ' + CAST(Detail.intContractSeq AS NVARCHAR(10)) COLLATE Latin1_General_CI_AS
			, Item.intItemId
			, strItemDescription = Item.strDescription
			, dtmAvailability = Detail.dtmUpdatedAvailabilityDate
			, Detail.intFutureMarketId
			, Detail.intFutureMonthId
			, dblQty = ISNULL(dbo.fnCTConvertQuantityToTargetItemUOM(Detail.intItemId, Detail.intUnitMeasureId, CC.intUnitMeasureId, Detail.dblBalance), 0)
			, dblTransactionPrice = ISNULL(dbo.fnRKConvertUOMCurrency('ItemUOM', Detail.intItemUOMId, CC.intItemUOMId, 1, Detail.intCurrencyId, @intCurrencyId, Detail.dblCashPrice, Detail.intContractDetailId), 0)
			, dblContractDifferential = ISNULL(dbo.fnRKConvertUOMCurrency('ItemUOM', Detail.intBasisUOMId, CC.intItemUOMId, 1, Detail.intCurrencyId, @intCurrencyId, Detail.dblBasis, Detail.intContractDetailId), 0) 
			, dblFreight = ISNULL(CC.dblAmount, 0.00)
		FROM tblCTContractDetail Detail
		JOIN tblCTContractHeader Header ON Header.intContractHeaderId = Detail.intContractHeaderId
		JOIN tblICItem Item ON Item.intItemId = Detail.intItemId
		JOIN TonUOM ON TonUOM.intCommodityId = Header.intCommodityId
		LEFT JOIN (
			SELECT CC.intContractDetailId
				, dblAmount = SUM(dbo.fnRKConvertUOMCurrency('ItemUOM', CC.intItemUOMId, TonUOM.intItemUOMId, 1, CC.intCurrencyId, @intCurrencyId, dblAmount, CC.intContractDetailId))
			FROM vyuCTContractCostView CC
			JOIN tblCTContractHeader CH ON CH.intContractHeaderId = CC.intContractHeaderId
			WHERE UPPER(strItemDescription) LIKE '%FREIGHT%'
			GROUP BY CC.intContractDetailId
		) CC ON CC.intContractDetailId = Detail.intContractDetailId
		WHERE Detail.intContractStatusId = 1
			AND Detail.intPricingTypeId = 1
			AND Detail.dblBalance <> 0
			AND Header.intContractTypeId = 1
			AND CAST(FLOOR(CAST(Detail.dtmEndDate AS FLOAT)) AS DATETIME) <= @dtmDate
	
		UNION ALL SELECT DISTINCT CH.intCommodityId
			, L.intBookId
			, L.intSubBookId
			, Item.intProductTypeId
			, strTransactionType = 'Physical'
			, strTransactionStatus = 'In-Transit'
			, strTransactionNo = CH.strContractNumber + ' - ' + CAST(CD.intContractSeq AS NVARCHAR(10)) COLLATE Latin1_General_CI_AS
			, Item.intItemId
			, strItemDescription = Item.strDescription
			, dtmAvailability = CD.dtmUpdatedAvailabilityDate
			, CD.intFutureMarketId
			, CD.intFutureMonthId
			, dblQty = ISNULL(dbo.[fnCTConvertQuantityToTargetItemUOM](LD.intItemId, ItemUOM.intUnitMeasureId, CC.intUnitMeasureId, LD.dblQuantity), 0)
			, dblTransactionPrice = ISNULL(dbo.fnRKConvertUOMCurrency('ItemUOM', LD.intItemUOMId, CC.intItemUOMId, 1, L.intCurrencyId, @intCurrencyId, LD.dblQuantity, CD.intContractDetailId), 0)
			, dblContractDifferential = ISNULL(dbo.fnRKConvertUOMCurrency('ItemUOM', LD.intItemUOMId, CC.intItemUOMId, 1, L.intCurrencyId, @intCurrencyId, CD.dblBasis, CD.intContractDetailId), 0)
			, dblFreight = ISNULL(CC.dblAmount, 0.00)
		FROM tblLGLoad L
		JOIN tblLGLoadDetail LD ON L.intLoadId = LD.intLoadId AND L.intPurchaseSale = 1
		JOIN tblICItemUOM ItemUOM ON ItemUOM.intItemUOMId = LD.intItemUOMId
		JOIN tblCTContractDetail CD ON CD.intContractDetailId = LD.intPContractDetailId
		JOIN tblCTContractHeader CH ON CH.intContractHeaderId = CD.intContractHeaderId
		JOIN tblICItem Item ON Item.intItemId = LD.intItemId
		LEFT JOIN (
			SELECT CC.intContractDetailId
				, dblAmount = SUM(dbo.fnRKConvertUOMCurrency('ItemUOM', CC.intItemUOMId, TonUOM.intItemUOMId, 1, CC.intCurrencyId, @intCurrencyId, dblAmount, CC.intContractDetailId))
			FROM vyuCTContractCostView CC
			JOIN tblCTContractHeader CH ON CH.intContractHeaderId = CC.intContractHeaderId
			WHERE UPPER(strItemDescription) LIKE '%FREIGHT%'
			GROUP BY CC.intContractDetailId
		) CC ON CC.intContractDetailId = CD.intContractDetailId
		WHERE L.ysnPosted = 1
			AND L.intShipmentStatus <> 10
			AND L.intShipmentType = 1
			AND CAST(FLOOR(CAST(L.dtmDispatchedDate AS FLOAT)) AS DATETIME) <= @dtmDate

		UNION ALL SELECT DISTINCT Header.intCommodityId
			, Lots.intBookId
			, Lots.intSubBookId
			, Item.intProductTypeId
			, strTransactionType = 'Physical'
			, strTransactionStatus = 'Stock'
			, strTransactionNo = Header.strContractNumber + ' - ' + CAST(Detail.intContractSeq AS NVARCHAR(10)) COLLATE Latin1_General_CI_AS
			, Item.intItemId
			, strItemDescription = Item.strDescription
			, dtmAvailability = Detail.dtmUpdatedAvailabilityDate
			, Detail.intFutureMarketId
			, Detail.intFutureMonthId
			, dblQty = ISNULL(dbo.[fnCTConvertQuantityToTargetItemUOM](Lots.intItemId, ItemUOM.intUnitMeasureId, CC.intUnitMeasureId, Lots.dblBalance), 0)
			, dblTransactionPrice = ISNULL(dbo.fnRKConvertUOMCurrency('ItemUOM', Lots.intItemUOMId, TonUOM.intItemUOMId, 1, Lots.intDefaultCurrencyId, @intCurrencyId, Lots.dblCashPrice, Detail.intContractDetailId), 0)
			, dblContractDifferential = ISNULL(dbo.fnRKConvertUOMCurrency('ItemUOM', Lots.intItemUOMId, TonUOM.intItemUOMId, 1, Lots.intDefaultCurrencyId, @intCurrencyId, Lots.dblBasis, Detail.intContractDetailId), 0)
			, dblFreight = ISNULL(CC.dblAmount, 0.00)
		FROM vyuLGPickOpenInventoryLots Lots
		JOIN tblICItemUOM ItemUOM ON ItemUOM.intItemUOMId = Lots.intItemUOMId
		JOIN tblICItem Item ON Item.intItemId = Lots.intItemId
		LEFT JOIN tblCTContractDetail Detail ON Detail.intContractDetailId = Lots.intContractDetailId
		LEFT JOIN tblCTContractHeader Header ON Header.intContractHeaderId = Detail.intContractHeaderId
		JOIN TonUOM ON TonUOM.intCommodityId = Lots.intCommodityId
		LEFT JOIN (
			SELECT CC.intContractDetailId
				, dblAmount = SUM(dbo.fnRKConvertUOMCurrency('ItemUOM', CC.intItemUOMId, TonUOM.intItemUOMId, 1, CC.intCurrencyId, @intCurrencyId, dblAmount, CC.intContractDetailId))
			FROM vyuCTContractCostView CC
			JOIN tblCTContractHeader CH ON CH.intContractHeaderId = CC.intContractHeaderId
			WHERE UPPER(strItemDescription) LIKE '%FREIGHT%'
			GROUP BY CC.intContractDetailId
		) CC ON CC.intContractDetailId = Detail.intContractDetailId
		WHERE CAST(FLOOR(CAST(Lots.dtmEndDate AS FLOAT)) AS DATETIME) <= @dtmDate
		
		UNION ALL  SELECT DISTINCT DAP.intCommodityId
			, DAP.intBookId
			, DAP.intSubBookId
			, intProductTypeId = NULL
			, strTransactionType = 'Futures'
			, strTransactionStatus = ''
			, strTransactionNo = DAP.strAverageNo
			, intItemId = NULL
			, strItemDescription = NULL
			, dtmAvailability = NULL
			, DAP.intFutureMarketId
			, DAP.intFutureMonthId
			, dblQty = ISNULL(dbo.fnCTConvertQuantityToTargetCommodityUOM(cUOM.intCommodityUnitMeasureId, mtUOM.intCommodityUnitMeasureId, DAP.dblNoOfLots * FM.dblContractSize), 0)
			, dblTransactionPrice = ISNULL(dbo.fnRKConvertUOMCurrency('CommodityUOM', cUOM.intCommodityUnitMeasureId, mtUOM.intCommodityUnitMeasureId, 1, FM.intCurrencyId, @intCurrencyId, DAP.dblNetLongAvg, NULL), 0) 
			, dblContractDifferential = NULL
			, dblFreight = NULL
		FROM vyuRKGetDailyAveragePriceDetail DAP
		JOIN tblRKFutureMarket FM ON FM.intFutureMarketId = DAP.intFutureMarketId
		JOIN TonUOM ON TonUOM.intCommodityId = DAP.intCommodityId
		JOIN tblICCommodityUnitMeasure cUOM ON cUOM.intCommodityId = DAP.intCommodityId
			AND cUOM.intUnitMeasureId = FM.intUnitMeasureId
		JOIN tblICCommodityUnitMeasure mtUOM ON mtUOM.intCommodityId = DAP.intCommodityId
			AND cUOM.intUnitMeasureId = TonUOM.intUnitMeasureId
		WHERE intDailyAveragePriceId = (SELECT TOP 1 intDailyAveragePriceId
										FROM tblRKDailyAveragePrice
										WHERE CAST(FLOOR(CAST(dtmDate AS FLOAT)) AS DATETIME) <= @dtmDate
										ORDER BY dtmDate DESC)
	) t
	LEFT JOIN tblCTBook book ON book.intBookId = t.intBookId
	LEFT JOIN tblCTSubBook subBook ON subBook.intSubBookId = t.intSubBookId
	LEFT JOIN tblICCommodityAttribute att ON att.intCommodityAttributeId = t.intProductTypeId
	LEFT JOIN tblRKFutureMarket fMar ON fMar.intFutureMarketId = t.intFutureMarketId
	LEFT JOIN tblRKFuturesMonth fMon ON fMon.intFutureMonthId = t.intFutureMonthId
	LEFT JOIN (
		SELECT intRowNo = ROW_NUMBER() OVER(PARTITION BY SP.intFutureMarketId, SPD.intFutureMonthId, CMM.intCommodityId ORDER BY SP.dtmPriceDate DESC)
			, SPD.intFutSettlementPriceMonthId
			, SPD.intFutureSettlementPriceId
			, SP.intFutureMarketId
			, SPD.intFutureMonthId
			, CMM.intCommodityId
			, dblLastSettle = ISNULL(dbo.fnRKConvertUOMCurrency('CommodityUOM', cUOM.intCommodityUnitMeasureId, mtUOM.intCommodityUnitMeasureId, 1, FM.intCurrencyId, @intCurrencyId, dblLastSettle, NULL), 0) 
			, SP.dtmPriceDate
		FROM tblRKFutSettlementPriceMarketMap SPD
		JOIN tblRKFuturesSettlementPrice SP ON SP.intFutureSettlementPriceId = SPD.intFutureSettlementPriceId
		JOIN tblRKCommodityMarketMapping CMM ON CMM.intCommodityMarketId = SP.intCommodityMarketId
		JOIN tblRKFutureMarket FM ON FM.intFutureMarketId = SP.intFutureMarketId
		JOIN TonUOM ON TonUOM.intCommodityId = CMM.intCommodityId
		JOIN tblICCommodityUnitMeasure cUOM ON cUOM.intCommodityId = CMM.intCommodityId
			AND cUOM.intUnitMeasureId = FM.intUnitMeasureId
		JOIN tblICCommodityUnitMeasure mtUOM ON mtUOM.intCommodityId = CMM.intCommodityId
			AND cUOM.intUnitMeasureId = TonUOM.intUnitMeasureId
		WHERE CAST(FLOOR(CAST(SP.dtmPriceDate AS FLOAT)) AS DATETIME) <= @Date
	) LastSettle ON LastSettle.intFutureMarketId = t.intFutureMarketId
		AND LastSettle.intFutureMonthId = t.intFutureMonthId
		AND LastSettle.intCommodityId = t.intCommodityId
		AND LastSettle.intRowNo = 1
	LEFT JOIN (
		SELECT intRowNo = ROW_NUMBER() OVER(PARTITION BY BD.intFutureMarketId, BD.intFutureMonthId, BD.intCommodityId ORDER BY B.dtmM2MBasisDate DESC)
			, BD.intM2MBasisId
			, BD.intM2MBasisDetailId
			, BD.intFutureMarketId
			, BD.intFutureMonthId
			, BD.intCommodityId
			, dblBasisOrDiscount = ISNULL(dbo.fnRKConvertUOMCurrency('CommodityUOM', cUOM.intCommodityUnitMeasureId, mtUOM.intCommodityUnitMeasureId, 1, BD.intCurrencyId, @intCurrencyId, BD.dblBasisOrDiscount, NULL), 0)
			, B.dtmM2MBasisDate
		FROM tblRKM2MBasisDetail BD
		JOIN tblRKM2MBasis B ON B.intM2MBasisId = BD.intM2MBasisId
		JOIN TonUOM ON TonUOM.intCommodityId = BD.intCommodityId
		JOIN tblICCommodityUnitMeasure cUOM ON cUOM.intCommodityId = BD.intCommodityId
			AND cUOM.intUnitMeasureId = BD.intUnitMeasureId
		JOIN tblICCommodityUnitMeasure mtUOM ON mtUOM.intCommodityId = BD.intCommodityId
			AND cUOM.intUnitMeasureId = TonUOM.intUnitMeasureId
		WHERE CAST(FLOOR(CAST(B.dtmM2MBasisDate AS FLOAT)) AS DATETIME) <= @Date
	) BasisEntry ON BasisEntry.intFutureMarketId = t.intFutureMarketId
		AND BasisEntry.intFutureMonthId = t.intFutureMonthId
		AND BasisEntry.intCommodityId = t.intCommodityId
		AND BasisEntry.intRowNo = 1

	RETURN
END
