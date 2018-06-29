CREATE VIEW [dbo].[vyuGRStorageStmtSchedule]
AS 
SELECT DISTINCT
 Cs.intEntityId    
,Cs.intItemId
,ST.intStorageScheduleTypeId
,SR.intStorageScheduleRuleId
,SR.strScheduleId
,SR.strScheduleDescription
FROM tblGRCustomerStorage Cs
JOIN tblICItem Item ON Item.intItemId = Cs.intItemId
JOIN tblGRStorageType ST ON ST.intStorageScheduleTypeId=Cs.intStorageTypeId
JOIN tblGRStorageScheduleRule SR ON SR.intStorageScheduleRuleId=Cs.intStorageScheduleId
WHERE  ISNULL(Cs.strStorageType,'') <> 'ITR' AND ST.ysnCustomerStorage=0  
