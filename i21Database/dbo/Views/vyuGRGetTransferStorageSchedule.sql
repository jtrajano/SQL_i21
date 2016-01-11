CREATE VIEW [dbo].[vyuGRGetTransferStorageSchedule]
AS
SELECT  0 AS intStorageScheduleRuleId,-1 AS intStorageType,'Keep As Is' AS strScheduleId,-1 AS intCompanyLocationId FROM tblGRStorageScheduleRule     
UNION    
SELECT S.intStorageScheduleRuleId,S.intStorageType,S.strScheduleId,SL.intCompanyLocationId 
FROM tblGRStorageScheduleRule S
JOIN tblGRStorageScheduleLocationUse SL ON SL.intStorageScheduleId=S.intStorageScheduleRuleId AND SL.ysnStorageScheduleLocationActive=1 