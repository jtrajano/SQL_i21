CREATE VIEW [dbo].[vyuGRProductionSummaryEntity]
AS
SELECT DISTINCT
 ST.intStorageScheduleTypeId
,CS.intItemId
, 0  intEntityId
,'_ALL' AS strName 
FROM tblGRCustomerStorage CS
JOIN tblGRStorageType ST ON ST.intStorageScheduleTypeId=CS.intStorageTypeId
JOIN tblEMEntity E ON E.intEntityId = CS.intEntityId
WHERE  ISNULL(CS.strStorageType,'') <> 'ITR' AND ST.ysnCustomerStorage=0
UNION
SELECT DISTINCT
 ST.intStorageScheduleTypeId
,CS.intItemId
,CS.intEntityId
,E.strName
FROM tblGRCustomerStorage CS
JOIN tblGRStorageType ST ON ST.intStorageScheduleTypeId=CS.intStorageTypeId
JOIN tblEMEntity E ON E.intEntityId = CS.intEntityId
WHERE  ISNULL(CS.strStorageType,'') <> 'ITR' AND ST.ysnCustomerStorage=0
