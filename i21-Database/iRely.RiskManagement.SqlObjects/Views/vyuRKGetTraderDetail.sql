CREATE VIEW vyuRKGetTraderDetail
AS

SELECT DISTINCT convert(int,row_number() OVER(ORDER BY amm.intEntitySalespersonId)) intRowNum,
 e.intEntityId intEntitySalespersonId,e.strName strSalesperson,
ba.intBrokerageAccountId
FROM tblRKBrokerageAccount ba
JOIN tblRKTradersbyBrokersAccountMapping amm on amm.intBrokerageAccountId=ba.intBrokerageAccountId
JOIN tblEMEntity e on e.intEntityId=amm.intEntitySalespersonId