CREATE VIEW [dbo].[vyuRKGetBrokerTrader]
AS  
SELECT intTradersbyBrokersAccountId,amm.intEntitySalespersonId,ba.intBrokerId,ba.intBrokerageAccountId,strSalespersonId from tblRKBrokerageAccount ba
JOIN tblRKTradersbyBrokersAccountMapping amm on amm.intBrokerageAccountId=ba.intBrokerageAccountId
JOIN tblARSalesperson fm on amm.intEntitySalespersonId=fm.intEntitySalespersonId
