CREATE VIEW [dbo].[vyuRKGetBrokerTrader]
AS  
SELECT e.intEntityId intEntitySalespersonId,strName strSalespersonId,strName strSalespersonName from tblEMEntity e 
JOIN tblEMEntityType et on e.intEntityId=et.intEntityId where strType='Salesperson'
