﻿CREATE VIEW vyuRKGetFutureSettlementPriceHeader
AS 
SELECT fsp.intFutureSettlementPriceId,m.strFutMarketName,fsp.dtmPriceDate FROM tblRKFuturesSettlementPrice fsp
JOIN tblRKFutureMarket m on fsp.intFutureMarketId=m.intFutureMarketId
