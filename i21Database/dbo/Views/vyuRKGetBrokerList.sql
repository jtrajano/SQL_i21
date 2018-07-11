CREATE VIEW vyuRKGetBrokerList
AS
SELECT  S.intEntityId, S.strName, V.ysnPymtCtrlActive as ysnActive FROM  tblEMEntity S
JOIN tblAPVendor V ON S.intEntityId = V.intEntityId 
JOIN tblEMEntityType SE ON S.intEntityId = SE.intEntityId and SE.strType = 'Futures Broker'