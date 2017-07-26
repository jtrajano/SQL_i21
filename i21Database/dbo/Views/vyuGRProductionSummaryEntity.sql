CREATE VIEW [dbo].[vyuGRProductionSummaryEntity]
AS
SELECT DISTINCT
 ST.intStorageScheduleTypeId
,CS.intEntityId
,E.strName
FROM tblGRCustomerStorage CS
JOIN tblGRStorageType ST ON ST.intStorageScheduleTypeId=CS.intStorageTypeId
JOIN tblEMEntity E ON E.intEntityId = CS.intEntityId
WHERE  ISNULL(CS.strStorageType,'') <> 'ITR' AND ST.ysnCustomerStorage=0
