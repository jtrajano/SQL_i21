﻿CREATE VIEW vyuRKGetFutureSettlementPriceHeader
AS 
SELECT fsp.intFutureSettlementPriceId,m.strFutMarketName,fsp.dtmPriceDate,fsp.strPricingType FROM tblRKFuturesSettlementPrice fsp
JOIN tblRKFutureMarket m on fsp.intFutureMarketId=m.intFutureMarketId
