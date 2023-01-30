CREATE PROCEDURE [dbo].[uspRKCurrencyExposureForStock]
	@intCommodityId INT
	, @dtmClosingPrice DATETIME = NULL
	, @intCurrencyId INT

AS

BEGIN
	SET @dtmClosingPrice = CONVERT(DATETIME, CONVERT(VARCHAR(10), @dtmClosingPrice, 110), 110)

	SELECT intRowNum = CONVERT(INT, ROW_NUMBER() OVER(ORDER BY strContractNumber))
		, dblMarketPrice = (ISNULL(dblSettlementPrice, 0) + ISNULL(dblMarketPremium, 0))
		, dblValue = dblQty * (ISNULL(dblSettlementPrice, 0) + ISNULL(dblMarketPremium, 0))
		, *
	FROM (
		SELECT strContractNumber = (ch.strContractNumber + '-' + CONVERT(NVARCHAR, cd.intContractSeq)) COLLATE Latin1_General_CI_AS
			, l.strLotNumber
			, sl.strName
			, item.strItemNo
			, fm.strFutMarketName
			, strSpotMonth = (SELECT TOP 1 REPLACE(strFutureMonth, ' ', '(' + strSymbol + ') ') COLLATE Latin1_General_CI_AS strFutureMonth
							FROM tblRKFuturesMonth mon
							WHERE ysnExpired = 0
								AND dtmSpotDate <= GETDATE()
								AND mon.intFutureMarketId = fm.intFutureMarketId
							ORDER BY 1 DESC)
			, dblSettlementPrice = [dbo].[fnRKGetCurrencyConvertion](fm.intCurrencyId, @intCurrencyId, DEFAULT)
									* dbo.fnRKGetLatestClosingPrice(fm.intFutureMarketId, (SELECT TOP 1 intFutureMonthId FROM tblRKFuturesMonth mon
																							WHERE ysnExpired = 0 AND  dtmSpotDate <= GETDATE() AND mon.intFutureMarketId = fm.intFutureMarketId
																							ORDER BY 1 DESC), @dtmClosingPrice)
			, dblMarketPremium = [dbo].[fnRKGetCurrencyConvertion](fm.intCurrencyId, @intCurrencyId, DEFAULT)
								* dbo.[fnCTConvertQuantityToTargetItemUOM](cd.intItemId, um.intUnitMeasureId, fm.intUnitMeasureId, dblBasis)
			, strMarketPremiumUOM = (c.strCurrency + '/' + um.strUnitMeasure) COLLATE Latin1_General_CI_AS
			, strMarketPriceUOM = cur.strCurrency
			, l.dblQty
			, strCompanyName
			, intConcurrencyId = 1
			, cd.intContractDetailId
			, sl.intStorageLocationId
			, intMarketPremiumUOMId = um.intUnitMeasureId
			, intMarketPriceCurrencyId = cur.intCurrencyID
			, l.intItemId
			, cd.intFutureMarketId
			, ch.intCompanyId
		FROM tblCTContractHeader ch
		JOIN tblCTContractDetail cd ON ch.intContractHeaderId = cd.intContractHeaderId
		JOIN tblRKFutureMarket fm ON cd.intFutureMarketId = fm.intFutureMarketId
		JOIN tblICInventoryReceiptItem ri ON cd.intContractDetailId = ri.intLineNo
		JOIN tblICInventoryReceiptItemLot rl ON ri.intInventoryReceiptItemId = rl.intInventoryReceiptItemId
		JOIN tblICStorageLocation sl ON sl.intStorageLocationId = rl.intStorageLocationId
		JOIN tblICLot l ON rl.intLotId = l.intLotId
		JOIN tblICItem item ON item.intItemId = l.intItemId
		JOIN tblSMCurrency c ON c.intCurrencyID = cd.intBasisCurrencyId
		JOIN tblICItemUOM iu ON iu.intItemUOMId = cd.intBasisUOMId
		JOIN tblICUnitMeasure um ON um.intUnitMeasureId = iu.intUnitMeasureId
		JOIN tblSMCurrency cur ON cur.intCurrencyID = fm.intCurrencyId
		LEFT JOIN tblSMMultiCompany mc ON mc.intMultiCompanyId = ch.intCompanyId
		WHERE ch.intCommodityId=@intCommodityId AND dblQty <> 0
	) t
END