CREATE VIEW [dbo].[vyuGRStorageStmtSchedule]
AS 
SELECT DISTINCT
	CS.intEntityId    
	,CS.intItemId
	,ST.intStorageScheduleTypeId
	,SR.intStorageScheduleRuleId
	,SR.strScheduleId
	,SR.strScheduleDescription
FROM tblGRCustomerStorage CS
JOIN tblICItem Item 
	ON Item.intItemId = CS.intItemId
JOIN tblGRStorageType ST 
	ON ST.intStorageScheduleTypeId = CS.intStorageTypeId
JOIN tblGRStorageScheduleRule SR
	ON SR.intStorageScheduleRuleId = CS.intStorageScheduleId
LEFT JOIN tblGRStorageStatement SS 
	ON SS.intCustomerStorageId = CS.intCustomerStorageId
WHERE ST.ysnCustomerStorage = 0  
	AND CS.dblOpenBalance > 0
	AND SS.intCustomerStorageId IS NULL