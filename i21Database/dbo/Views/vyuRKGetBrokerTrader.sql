CREATE VIEW [dbo].[vyuRKGetBrokerTrader]
AS  
SELECT 
	e.intEntityId intEntitySalespersonId
	,strName strSalespersonId
	,strName strSalespersonName 
	,bt.intBrokerageAccountId
from tblEMEntity e 
JOIN tblEMEntityType et on e.intEntityId=et.intEntityId
JOIN tblRKTradersbyBrokersAccountMapping bt on e.intEntityId = bt.intEntitySalespersonId
 where strType='Salesperson'
