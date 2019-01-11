﻿CREATE PROC uspRKCurrencyExposureForStock
	@intWeightUOMId int = null
	, @intCompanyId int = null
	, @intCommodityId int
	, @dtmMarketPremium datetime = null
	, @dtmClosingPrice datetime = null
	, @intCurrencyId int

AS

SET @dtmClosingPrice = CONVERT(DATETIME, CONVERT(VARCHAR(10), @dtmClosingPrice, 110), 110)

SELECT CONVERT(INT, ROW_NUMBER() OVER(ORDER BY strContractNumber)) as intRowNum
	, (dblSettlementPrice+dblMarketPremium) dblMarketPrice
	, dblQty * (dblSettlementPrice+dblMarketPremium) dblValue
	, *
FROM (
	SELECT (ch.strContractNumber + '-' + convert(nvarchar, cd.intContractSeq)) COLLATE Latin1_General_CI_AS strContractNumber
		, l.strLotNumber
		, sl.strName
		, item.strItemNo
		, fm.strFutMarketName
		, (SELECT TOP 1 replace(strFutureMonth,' ','('+strSymbol+') ' ) COLLATE Latin1_General_CI_AS strFutureMonth
			FROM tblRKFuturesMonth mon
			WHERE ysnExpired = 0 AND dtmSpotDate <= GETDATE() AND mon.intFutureMarketId = fm.intFutureMarketId ORDER BY 1 DESC) strSpotMonth
		, dbo.fnRKGetLatestClosingPrice(fm.intFutureMarketId, (SELECT TOP 1 intFutureMonthId FROM tblRKFuturesMonth mon
																WHERE ysnExpired = 0 AND  dtmSpotDate <= GETDATE() AND mon.intFutureMarketId = fm.intFutureMarketId ORDER BY 1 DESC), @dtmClosingPrice) dblSettlementPrice
		, dblBasis dblMarketPremium
		, (c.strCurrency + '/' + um.strUnitMeasure) COLLATE Latin1_General_CI_AS strMarketPremiumUOM
		, cur.strCurrency strMarketPriceUOM
		, l.dblQty
		, strCompanyName
		, 1 as intConcurrencyId
	FROM tblCTContractHeader ch
	JOIN tblCTContractDetail cd on ch.intContractHeaderId=cd.intContractHeaderId
	join tblRKFutureMarket fm on cd.intFutureMarketId=fm.intFutureMarketId
	JOIN tblICInventoryReceiptItem ri on cd.intContractDetailId=ri.intLineNo
	JOIN tblICInventoryReceiptItemLot rl on ri.intInventoryReceiptItemId=rl.intInventoryReceiptItemId
	join tblICStorageLocation sl on sl.intStorageLocationId=rl.intStorageLocationId
	JOIN tblICLot l on rl.intLotId=l.intLotId
	JOIN tblICItem item on item.intItemId=l.intItemId
	join tblSMCurrency c on c.intCurrencyID=cd.intBasisCurrencyId
	join tblICUnitMeasure um on um.intUnitMeasureId=cd.intBasisUOMId
	join tblSMCurrency cur on cur.intCurrencyID=fm.intCurrencyId
	LEFT join tblSMMultiCompany mc on mc.intMultiCompanyId=ch.intCompanyId
	WHERE cd.intCurrencyId=@intCurrencyId and ch.intCommodityId=@intCommodityId
) t