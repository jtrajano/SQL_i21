CREATE VIEW [dbo].[vyuRKGetFutureMarketName]
AS  
SELECT intBrokersAccountMarketMapId,ba.intBrokerageAccountId,ba.intBrokerId,amm.intFutureMarketId,strFutMarketName from tblRKBrokerageAccount ba
JOIN tblRKBrokersAccountMarketMapping amm on amm.intBrokerageAccountId=ba.intBrokerageAccountId
JOIN tblRKFutureMarket fm on amm.intFutureMarketId=fm.intFutureMarketId
