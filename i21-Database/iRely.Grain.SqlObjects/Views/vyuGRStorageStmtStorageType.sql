CREATE VIEW [dbo].[vyuGRStorageStmtStorageType]
AS 
SELECT DISTINCT
Cs.intEntityId    
,Cs.intItemId
,ST.intStorageScheduleTypeId
,ST.strStorageTypeCode
,ST.strStorageTypeDescription 
FROM tblGRCustomerStorage Cs
JOIN tblICItem Item ON Item.intItemId = Cs.intItemId
JOIN tblGRStorageType ST ON ST.intStorageScheduleTypeId=Cs.intStorageTypeId
Where  ISNULL(Cs.strStorageType,'') <> 'ITR' AND ST.ysnCustomerStorage=0 
