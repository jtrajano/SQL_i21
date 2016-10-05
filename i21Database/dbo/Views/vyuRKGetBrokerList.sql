CREATE VIEW vyuRKGetBrokerList
AS
SELECT  S.intEntityId, S.strName FROM  tblEMEntity S 
JOIN tblEMEntityType SE ON S.intEntityId = SE.intEntityId and SE.strType = 'Futures Broker'