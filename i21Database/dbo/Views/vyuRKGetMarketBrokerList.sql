CREATE VIEW [dbo].[vyuRKGetMarketBrokerList]
AS  
SELECT distinct ba.intEntityId,amm.intFutureMarketId,strName from tblRKBrokerageAccount ba
JOIN tblRKBrokersAccountMarketMapping amm on amm.intBrokerageAccountId=ba.intBrokerageAccountId
JOIN tblRKFutureMarket fm on amm.intFutureMarketId=fm.intFutureMarketId
JOIN tblEMEntity e on e.intEntityId=ba.intEntityId