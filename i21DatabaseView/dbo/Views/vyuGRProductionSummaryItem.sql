CREATE VIEW [dbo].[vyuGRProductionSummaryItem]
AS
SELECT DISTINCT
ST.intStorageScheduleTypeId
,CS.intItemId
,Item.strItemNo
,Item.strDescription
FROM tblGRCustomerStorage CS
JOIN tblGRStorageType ST ON ST.intStorageScheduleTypeId=CS.intStorageTypeId
JOIN tblICItem Item ON Item.intItemId = CS.intItemId
WHERE  ISNULL(CS.strStorageType,'') <> 'ITR' AND ST.ysnCustomerStorage=0 
