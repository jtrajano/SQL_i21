CREATE VIEW [dbo].[vyuGRGetTransferStorageSchedule]
AS
SELECT 
    intStorageScheduleRuleId    = 0
    ,intStorageType             = -1
    ,strScheduleDescription     = 'Keep As Is'
    ,intCompanyLocationId       = -1
    ,intCommodity               = 0
FROM tblGRStorageScheduleRule     
UNION    
SELECT 
    S.intStorageScheduleRuleId
    ,S.intStorageType
    ,S.strScheduleDescription
    ,SL.intCompanyLocationId
    ,S.intCommodity
FROM tblGRStorageScheduleRule S
JOIN tblGRStorageScheduleLocationUse SL 
    ON SL.intStorageScheduleId = S.intStorageScheduleRuleId 
WHERE SL.ysnStorageScheduleLocationActive = 1 
    AND ISNULL(dbo.fnRemoveTimeOnDate(S.dtmEffectiveDate), dbo.fnRemoveTimeOnDate(GETDATE()))<=dbo.fnRemoveTimeOnDate(GETDATE())
    AND ISNULL(dbo.fnRemoveTimeOnDate(S.dtmTerminationDate), dbo.fnRemoveTimeOnDate(GETDATE()))>=dbo.fnRemoveTimeOnDate(GETDATE())