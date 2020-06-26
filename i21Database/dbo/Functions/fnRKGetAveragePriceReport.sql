CREATE FUNCTION [dbo].[fnRKGetAveragePriceReport]
(
	@Date DATETIME
)
RETURNS @FinalTable TABLE
(
	intBookId INT
	, strBook NVARCHAR(100) COLLATE Latin1_General_CI_AS
	, intSubBookId INT
	, strSubBook NVARCHAR(100) COLLATE Latin1_General_CI_AS
	, intProductTypeId INT
	, strProductType NVARCHAR(100) COLLATE Latin1_General_CI_AS
	, strTransactionType NVARCHAR(100) COLLATE Latin1_General_CI_AS
	, strTransactionStatus NVARCHAR(100) COLLATE Latin1_General_CI_AS
	, strTransactionNo NVARCHAR(100) COLLATE Latin1_General_CI_AS
	, intBundleItemId INT
	, strBundle NVARCHAR(100) COLLATE Latin1_General_CI_AS
	, intItemId INT
	, strItemNo NVARCHAR(100) COLLATE Latin1_General_CI_AS
	, dtmAvailability DATETIME
	, intFutureMarketId INT
	, strFutureMarket NVARCHAR(100) COLLATE Latin1_General_CI_AS
	, intFutureMonthId INT
	, strFutureMonth NVARCHAR(100) COLLATE Latin1_General_CI_AS
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
		, intItemId
	) AS (
		SELECT intCommodityId
			, intUnitMeasureId
			, intItemUOMId
			, intItemId
		FROM (
			SELECT intRowId = ROW_NUMBER() OVER (PARTITION BY intCommodityId, Item.intItemId ORDER BY ItemUOM.intUnitMeasureId DESC)
				, intCommodityId
				, ItemUOM.intUnitMeasureId
				, ItemUOM.intItemUOMId
				, Item.intItemId
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
		, intBundleItemId = intBundleItemId
		, strBundleItem = strBundleItem
		, t.intItemId
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
			, dblQty = ISNULL(dbo.fnCTConvertQuantityToTargetItemUOM(Detail.intItemId, Detail.intUnitMeasureId, TonUOM.intUnitMeasureId,(Detail.dblBalance - ISNULL(Detail.dblScheduleQty, 0))), 0)
			, dblTransactionPrice = ISNULL(dbo.fnRKConvertUOMCurrency('ItemUOM', Detail.intPriceItemUOMId, TonUOM.intItemUOMId, 1, Detail.intCurrencyId, @intCurrencyId, Detail.dblCashPrice, Detail.intContractDetailId), 0)
			, dblContractDifferential = ISNULL(dbo.fnRKConvertUOMCurrency('ItemUOM', Detail.intBasisUOMId, TonUOM.intItemUOMId, 1, Detail.intBasisCurrencyId, @intCurrencyId, Detail.dblBasis, Detail.intContractDetailId), 0) 
			, dblFreight = ISNULL(CC.dblAmount, 0.00)
			, intBundleItemId = Detail.intItemBundleId
			, strBundleItem = IB.strItemNo
		FROM tblCTContractDetail Detail
		JOIN tblCTContractHeader Header ON Header.intContractHeaderId = Detail.intContractHeaderId
		JOIN tblICItem Item ON Item.intItemId = Detail.intItemId
		JOIN TonUOM ON TonUOM.intCommodityId = Header.intCommodityId AND TonUOM.intItemId = Detail.intItemId
		LEFT JOIN tblICItem IB ON IB.intItemId = Detail.intItemBundleId
		LEFT JOIN (
			SELECT CC.intContractDetailId
				, dblAmount = SUM(dbo.fnRKConvertUOMCurrency('ItemUOM', CC.intItemUOMId, CCUOM.intItemUOMId, 1, CC.intCurrencyId, @intCurrencyId, dblAmount, CC.intContractDetailId))
			FROM vyuCTContractCostView CC
			JOIN tblCTContractHeader CH ON CH.intContractHeaderId = CC.intContractHeaderId
			JOIN TonUOM CCUOM ON CCUOM.intCommodityId = CH.intCommodityId AND CCUOM.intItemId = CC.intItemId
			WHERE UPPER(strItemDescription) LIKE '%FREIGHT%'
			GROUP BY CC.intContractDetailId
		) CC ON CC.intContractDetailId = Detail.intContractDetailId
		WHERE Detail.intContractStatusId = 1
			--AND Detail.intPricingTypeId = 1
			AND Detail.dblBalance <> 0
			AND (Detail.dblBalance - ISNULL(Detail.dblScheduleQty, 0)) > 0
			AND Header.intContractTypeId = 1
	
		UNION ALL SELECT DISTINCT CH.intCommodityId
			, L.intBookId
			, L.intSubBookId
			, Item.intProductTypeId
			, strTransactionType = 'Physical' COLLATE Latin1_General_CI_AS
			, strTransactionStatus = 'In-Transit' COLLATE Latin1_General_CI_AS
			, strTransactionNo = CH.strContractNumber + ' - ' + CAST(CD.intContractSeq AS NVARCHAR(10)) COLLATE Latin1_General_CI_AS
			, Item.intItemId
			, strItemDescription = Item.strDescription
			, dtmAvailability = CD.dtmUpdatedAvailabilityDate
			, CD.intFutureMarketId
			, CD.intFutureMonthId
			, dblQty = ISNULL(dbo.[fnCTConvertQuantityToTargetItemUOM](LD.intItemId, ItemUOM.intUnitMeasureId, TonUOM.intUnitMeasureId, LD.dblQuantity), 0)
			, dblTransactionPrice = ISNULL(dbo.fnRKConvertUOMCurrency('ItemUOM', CD.intPriceItemUOMId, TonUOM.intItemUOMId, 1, CD.intCurrencyId, @intCurrencyId, CD.dblCashPrice, CD.intContractDetailId), 0)
			, dblContractDifferential = ISNULL(dbo.fnRKConvertUOMCurrency('ItemUOM', CD.intBasisUOMId, TonUOM.intItemUOMId, 1, CD.intBasisCurrencyId, @intCurrencyId, CD.dblBasis, CD.intContractDetailId), 0)
			, dblFreight = ISNULL(CC.dblAmount, 0.00)
			, intBundleItemId = CD.intItemBundleId
			, strBundleItem = IB.strItemNo
		FROM tblLGLoad L
		JOIN tblLGLoadDetail LD ON L.intLoadId = LD.intLoadId AND L.intPurchaseSale = 1
		JOIN tblICItemUOM ItemUOM ON ItemUOM.intItemUOMId = LD.intItemUOMId
		JOIN tblCTContractDetail CD ON CD.intContractDetailId = LD.intPContractDetailId
		JOIN tblCTContractHeader CH ON CH.intContractHeaderId = CD.intContractHeaderId
		JOIN TonUOM ON TonUOM.intCommodityId = CH.intCommodityId AND TonUOM.intItemId = LD.intItemId
		JOIN tblICItem Item ON Item.intItemId = LD.intItemId
		LEFT JOIN tblICItem IB ON IB.intItemId = CD.intItemBundleId
		LEFT JOIN (
			SELECT CC.intContractDetailId
				, dblAmount = SUM(dbo.fnRKConvertUOMCurrency('ItemUOM', CC.intItemUOMId, CCUOM.intItemUOMId, 1, CC.intCurrencyId, @intCurrencyId, dblAmount, CC.intContractDetailId))
			FROM vyuCTContractCostView CC
			JOIN tblCTContractHeader CH ON CH.intContractHeaderId = CC.intContractHeaderId
			JOIN TonUOM CCUOM ON CCUOM.intCommodityId = CH.intCommodityId AND CCUOM.intItemId = CC.intItemId
			WHERE UPPER(strItemDescription) LIKE '%FREIGHT%'
			GROUP BY CC.intContractDetailId
		) CC ON CC.intContractDetailId = CD.intContractDetailId
		WHERE L.ysnPosted = 1
			AND L.intShipmentStatus = 3
			AND L.intShipmentType = 1

		UNION ALL SELECT DISTINCT Item.intCommodityId
			, Lots.intBookId
			, Lots.intSubBookId
			, Item.intProductTypeId
			, strTransactionType = 'Physical' COLLATE Latin1_General_CI_AS
			, strTransactionStatus = 'Stock' COLLATE Latin1_General_CI_AS
			, strTransactionNo = Header.strContractNumber + ' - ' + CAST(Detail.intContractSeq AS NVARCHAR(10)) COLLATE Latin1_General_CI_AS
			, Item.intItemId
			, strItemDescription = Item.strDescription
			, dtmAvailability = CASE WHEN ISNULL(Detail.intContractDetailId, 0) <> 0 THEN Detail.dtmUpdatedAvailabilityDate ELSE GETDATE() END
			, intFutureMarketId = CASE WHEN ISNULL(Detail.intContractDetailId, 0) <> 0 THEN
											Detail.intFutureMarketId
										ELSE
											(SELECT Top(1) F.intFutureMarketId FROM tblRKCommodityMarketMapping F WHERE F.strCommodityAttributeId = Item.intProductTypeId)
										END
			, Detail.intFutureMonthId
			, dblQty = ISNULL(dbo.[fnCTConvertQuantityToTargetItemUOM](Lots.intItemId, ItemUOM.intUnitMeasureId, TonUOM.intUnitMeasureId, Lots.dblQty), 0)
			, dblTransactionPrice = CASE WHEN ISNULL(Detail.intContractDetailId, 0) <> 0 THEN
										ISNULL(dbo.fnRKConvertUOMCurrency('ItemUOM', Detail.intPriceItemUOMId, TonUOM.intItemUOMId, 1, Detail.intCurrencyId, @intCurrencyId, Detail.dblCashPrice, Detail.intContractDetailId), 0)
									ELSE
										ISNULL(dbo.fnRKConvertUOMCurrency('ItemUOM', (select intItemUOMId from tblICItemUOM where intItemId=Item.intItemId and ysnStockUOM=1), TonUOM.intItemUOMId, 1, @intCurrencyId, @intCurrencyId, Lots.dblLastCost, NULL), 0)
									END
			, dblContractDifferential = CASE WHEN ISNULL(Detail.intContractDetailId, 0) <> 0 THEN
											ISNULL(dbo.fnRKConvertUOMCurrency('ItemUOM', Detail.intBasisUOMId, TonUOM.intItemUOMId, 1, Detail.intBasisCurrencyId, @intCurrencyId, Detail.dblBasis, Detail.intContractDetailId), 0)
										ELSE
											0.0
										END
			, dblFreight = ISNULL(CC.dblAmount, 0.00)
			, intBundleItemId = CASE WHEN ISNULL(Detail.intContractDetailId, 0) <> 0 THEN 
									Detail.intItemBundleId
								ELSE
									(SELECT B.intItemId FROM tblICItemBundle B WHERE B.intBundleItemId = Item.intItemId)
								END
			, strBundleItem = CASE WHEN ISNULL(Detail.intContractDetailId, 0) <> 0 THEN 
								 IB.strItemNo
							ELSE
								(SELECT IT.strItemNo FROM tblICItem IT JOIN tblICItemBundle ICB ON ICB.intItemId = IT.intItemId WHERE ICB.intBundleItemId = Item.intItemId)
							END
		FROM vyuLGPickOpenInventoryLots Lots
		JOIN tblICItemUOM ItemUOM ON ItemUOM.intItemUOMId = Lots.intItemUOMId
		JOIN tblICItem Item ON Item.intItemId = Lots.intItemId
		LEFT JOIN tblCTContractDetail Detail ON Detail.intContractDetailId = Lots.intContractDetailId
		LEFT JOIN tblCTContractHeader Header ON Header.intContractHeaderId = Detail.intContractHeaderId
		JOIN TonUOM ON TonUOM.intCommodityId = Lots.intCommodityId AND TonUOM.intItemId = Item.intItemId
		LEFT JOIN tblICItem IB ON IB.intItemId = Detail.intItemBundleId
		LEFT JOIN (
			SELECT CC.intContractDetailId
				, dblAmount = SUM(dbo.fnRKConvertUOMCurrency('ItemUOM', CC.intItemUOMId, CCUOM.intItemUOMId, 1, CC.intCurrencyId, @intCurrencyId, dblAmount, CC.intContractDetailId))
			FROM vyuCTContractCostView CC
			JOIN tblCTContractHeader CH ON CH.intContractHeaderId = CC.intContractHeaderId
			JOIN TonUOM CCUOM ON CCUOM.intCommodityId = CH.intCommodityId AND CCUOM.intItemId = CC.intItemId
			WHERE UPPER(strItemDescription) LIKE '%FREIGHT%'
			GROUP BY CC.intContractDetailId
		) CC ON CC.intContractDetailId = Detail.intContractDetailId
		
		UNION ALL  SELECT DISTINCT DAP.intCommodityId
			, DAP.intBookId
			, DAP.intSubBookId
			, intProductTypeId = NULL
			, strTransactionType = 'Futures' COLLATE Latin1_General_CI_AS
			, strTransactionStatus = '' COLLATE Latin1_General_CI_AS
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
			, intBundleItemId = NULL
			, strBundleItem = NULL
		FROM vyuRKGetDailyAveragePriceDetail DAP
		JOIN tblRKFutureMarket FM ON FM.intFutureMarketId = DAP.intFutureMarketId
		CROSS APPLY (SELECT TOP 1 intCommodityId
						, intUnitMeasureId
						, intItemUOMId
					FROM TonUOM
					WHERE TonUOM.intCommodityId = DAP.intCommodityId) TonUOM
		JOIN tblICCommodityUnitMeasure cUOM ON cUOM.intCommodityId = DAP.intCommodityId
			AND cUOM.intUnitMeasureId = FM.intUnitMeasureId
		JOIN tblICCommodityUnitMeasure mtUOM ON mtUOM.intCommodityId = DAP.intCommodityId
			AND mtUOM.intUnitMeasureId = TonUOM.intUnitMeasureId
		WHERE intDailyAveragePriceId = (SELECT TOP 1 intDailyAveragePriceId
										FROM tblRKDailyAveragePrice
										WHERE CAST(FLOOR(CAST(dtmDate AS FLOAT)) AS DATETIME) <= @dtmDate
										ORDER BY dtmDate DESC)

		UNION ALL SELECT DISTINCT i.intCommodityId
			, DH.intBookId
			, DH.intSubBookId
			, intProductTypeId = i.intProductTypeId
			, strTransactionType = 'Demand' COLLATE Latin1_General_CI_AS
			, strTransactionStatus = '' COLLATE Latin1_General_CI_AS
			, strTransactionNo = DH.strDemandNo
			, intItemId = i.intItemId
			, strItemDescription = i.strDescription
			, dtmAvailability = DD.dtmDemandDate
			, intFutureMarketId = NULL
			, intFutureMonthId = NULL
			, dblQty = ISNULL(dbo.fnCTConvertQuantityToTargetCommodityUOM(cUOM.intCommodityUnitMeasureId, mtUOM.intCommodityUnitMeasureId, DD.dblQuantity), 0)
			, dblTransactionPrice = NULL
			, dblContractDifferential = NULL
			, dblFreight = NULL
			, intBundleItemId = i.intItemId
			, strBundleItem = IB.strItemNo
		FROM tblMFDemandDetail DD
		JOIN tblMFDemandHeader DH ON DH.intDemandHeaderId = DD.intDemandHeaderId
		JOIN tblICItemUOM iUOM ON iUOM.intItemUOMId = DD.intItemUOMId
		JOIN tblICItem i ON i.intItemId = DD.intItemId
		JOIN TonUOM ON TonUOM.intCommodityId = i.intCommodityId AND TonUOM.intItemId = DD.intItemId
		JOIN tblICCommodityUnitMeasure cUOM ON cUOM.intCommodityId = i.intCommodityId
			AND cUOM.intUnitMeasureId = iUOM.intUnitMeasureId
		JOIN tblICCommodityUnitMeasure mtUOM ON mtUOM.intCommodityId = i.intCommodityId
			AND mtUOM.intUnitMeasureId = TonUOM.intUnitMeasureId
		JOIN tblICItem IB ON IB.intItemId = DD.intItemId
		WHERE DH.intDemandHeaderId = (SELECT TOP 1 intDemandHeaderId
										FROM tblMFDemandHeader
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
		CROSS APPLY (SELECT TOP 1 intCommodityId
						, intUnitMeasureId
						, intItemUOMId
					FROM TonUOM
					WHERE TonUOM.intCommodityId = CMM.intCommodityId) TonUOM
		JOIN tblICCommodityUnitMeasure cUOM ON cUOM.intCommodityId = CMM.intCommodityId
			AND cUOM.intUnitMeasureId = FM.intUnitMeasureId
		JOIN tblICCommodityUnitMeasure mtUOM ON mtUOM.intCommodityId = CMM.intCommodityId
			AND mtUOM.intUnitMeasureId = TonUOM.intUnitMeasureId
		WHERE CAST(FLOOR(CAST(SP.dtmPriceDate AS FLOAT)) AS DATETIME) <= @Date
	) LastSettle ON LastSettle.intFutureMarketId = t.intFutureMarketId
		AND LastSettle.intFutureMonthId = t.intFutureMonthId
		AND LastSettle.intCommodityId = t.intCommodityId
		AND LastSettle.intRowNo = 1
	LEFT JOIN (
		SELECT intRowNo = ROW_NUMBER() OVER(PARTITION BY BD.intFutureMarketId, BD.intItemId, BD.intCommodityId ORDER BY B.dtmM2MBasisDate DESC)
			, BD.intM2MBasisId
			, BD.intM2MBasisDetailId
			, BD.intFutureMarketId
			, BD.intItemId
			, BD.intCommodityId
			, dblBasisOrDiscount = ISNULL(dbo.fnRKConvertUOMCurrency('CommodityUOM', cUOM.intCommodityUnitMeasureId, mtUOM.intCommodityUnitMeasureId, 1, BD.intCurrencyId, @intCurrencyId, BD.dblBasisOrDiscount, NULL), 0)
			, B.dtmM2MBasisDate
		FROM tblRKM2MBasisDetail BD
		JOIN tblRKM2MBasis B ON B.intM2MBasisId = BD.intM2MBasisId
		CROSS APPLY (SELECT TOP 1 intCommodityId
						, intUnitMeasureId
						, intItemUOMId
					FROM TonUOM
					WHERE TonUOM.intCommodityId = BD.intCommodityId) TonUOM
		JOIN tblICCommodityUnitMeasure cUOM ON cUOM.intCommodityId = BD.intCommodityId
			AND cUOM.intUnitMeasureId = BD.intUnitMeasureId
		JOIN tblICCommodityUnitMeasure mtUOM ON mtUOM.intCommodityId = BD.intCommodityId
			AND mtUOM.intUnitMeasureId = TonUOM.intUnitMeasureId
		WHERE B.strPricingType = 'Forecast' AND CAST(FLOOR(CAST(B.dtmM2MBasisDate AS FLOAT)) AS DATETIME) <= @Date
	) BasisEntry ON BasisEntry.intFutureMarketId = t.intFutureMarketId
		AND BasisEntry.intItemId = t.intItemId
		AND BasisEntry.intCommodityId = t.intCommodityId
		AND BasisEntry.intRowNo = 1

	RETURN
END
