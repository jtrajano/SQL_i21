CREATE VIEW [dbo].[vyuGRSettleStorageNotMapped]
AS
SELECT    
 S.intSettleStorageId
,S.intEntityId  
,E.strName AS strEntityName  
,S.intCompanyLocationId
,L.strLocationName
,S.intItemId
,Item.strItemNo  
FROM tblGRSettleStorage S
JOIN tblEMEntity E ON E.intEntityId = S.intEntityId
JOIN tblSMCompanyLocation L ON L.intCompanyLocationId = S.intCompanyLocationId  
JOIN tblICItem Item ON Item.intItemId = S.intItemId
