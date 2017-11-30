﻿CREATE VIEW  vyuRKBasisTransactionNotMapping

AS 

SELECT intM2MBasisTransactionId
		,mb.dtmM2MBasisDate
		,bd.intM2MBasisId
		,bd.intFutureMarketId
		,bd.intCommodityId
		,bd.intItemId
		,bd.intCurrencyId
		,bd.dblBasis
		,bd.intUnitMeasureId
		,strCommodityCode
		,strFutMarketName
		,strCurrency
		,strItemNo
		,strUnitMeasure
 FROM tblRKM2MBasisTransaction bd
JOIN tblRKM2MBasis mb on mb.intM2MBasisId=bd.intM2MBasisId
JOIN tblICCommodity c on c.intCommodityId=bd.intCommodityId
JOIN tblICItem i on i.intItemId=bd.intItemId
JOIN tblRKFutureMarket m on m.intFutureMarketId=bd.intFutureMarketId
JOIN tblSMCurrency cur on cur.intCurrencyID=bd.intCurrencyId
JOIN tblICUnitMeasure um on um.intUnitMeasureId=bd.intUnitMeasureId