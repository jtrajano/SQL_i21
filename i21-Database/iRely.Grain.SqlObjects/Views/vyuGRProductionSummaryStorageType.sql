CREATE VIEW [dbo].[vyuGRProductionSummaryStorageType]
AS
SELECT DISTINCT
 ST.intStorageScheduleTypeId
,ST.strStorageTypeCode
,ST.strStorageTypeDescription 
FROM tblGRCustomerStorage CS
JOIN tblGRStorageType ST ON ST.intStorageScheduleTypeId=CS.intStorageTypeId
WHERE  ISNULL(CS.strStorageType,'') <> 'ITR' AND ST.ysnCustomerStorage=0 
