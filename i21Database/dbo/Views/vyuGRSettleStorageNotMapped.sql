CREATE VIEW [dbo].[vyuGRSettleStorageNotMapped]
AS
SELECT    
 S.intSettleStorageId
,S.intEntityId  
,E.strName AS strEntityName  
,S.intItemId
,Item.strItemNo  
FROM tblGRSettleStorage S
JOIN tblEMEntity E ON E.intEntityId = S.intEntityId  
JOIN tblICItem Item ON Item.intItemId = S.intItemId
