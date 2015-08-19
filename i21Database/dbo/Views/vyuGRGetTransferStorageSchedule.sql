CREATE VIEW [dbo].[vyuGRGetTransferStorageSchedule]
AS
SELECT  0 AS intStorageScheduleRuleId,-1 AS intStorageType,'Keep As Is' AS strScheduleId FROM tblGRStorageScheduleRule     
UNION    
SELECT intStorageScheduleRuleId,intStorageType,strScheduleId FROM tblGRStorageScheduleRule 