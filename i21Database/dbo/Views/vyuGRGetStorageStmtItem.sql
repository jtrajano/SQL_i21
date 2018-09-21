CREATE VIEW [dbo].[vyuGRGetStorageStmtItem]
AS 
SELECT 
DISTINCT
 Cs.intEntityId    
,Cs.intItemId  
,Item.strItemNo
FROM tblGRCustomerStorage Cs
JOIN tblICItem			  Item ON Item.intItemId			  = Cs.intItemId
JOIN tblGRStorageType     ST   ON ST.intStorageScheduleTypeId = Cs.intStorageTypeId
LEFT JOIN tblGRStorageStatement    SS ON SS.intCustomerStorageId     = Cs.intCustomerStorageId
WHERE  ISNULL(Cs.strStorageType,'') <> 'ITR' 
AND ST.ysnCustomerStorage = 0 
AND   Cs.dblOpenBalance > 0
AND   SS.intCustomerStorageId IS NULL