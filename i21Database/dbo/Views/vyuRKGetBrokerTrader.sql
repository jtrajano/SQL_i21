CREATE VIEW [dbo].[vyuRKGetBrokerTrader]
AS  
SELECT intTradersbyBrokersAccountId,amm.intEntitySalespersonId,ba.intEntityId,ba.intBrokerageAccountId,strName strSalespersonId 
FROM tblRKBrokerageAccount ba
JOIN tblRKTradersbyBrokersAccountMapping amm on amm.intBrokerageAccountId=ba.intBrokerageAccountId
JOIN tblEMEntity fm on amm.intEntitySalespersonId=fm.intEntityId 
