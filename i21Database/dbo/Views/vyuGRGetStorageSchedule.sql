CREATE VIEW [dbo].[vyuGRGetStorageSchedule]
AS
SELECT 
 S.intStorageScheduleRuleId
,S.strScheduleId
,S.strScheduleDescription
,S.intStorageType
,S.intCommodity
,S.intAllowanceDays
,S.dtmEffectiveDate
,S.dtmTerminationDate
,S.intCurrencyID
,S.strStorageRate
,S.strFirstMonth
,S.strLastMonth
,ST.ysnDPOwnedType
,SL.intCompanyLocationId 
FROM tblGRStorageScheduleRule S
JOIN tblGRStorageScheduleLocationUse SL ON SL.intStorageScheduleId=S.intStorageScheduleRuleId
JOIN tblGRStorageType ST ON ST.intStorageScheduleTypeId=S.intStorageType 
Where SL.ysnStorageScheduleLocationActive=1 
AND ISNULL(dbo.fnRemoveTimeOnDate(S.dtmEffectiveDate), dbo.fnRemoveTimeOnDate(GETDATE()))<=dbo.fnRemoveTimeOnDate(GETDATE())
AND ISNULL(dbo.fnRemoveTimeOnDate(S.dtmTerminationDate), dbo.fnRemoveTimeOnDate(GETDATE()))>=dbo.fnRemoveTimeOnDate(GETDATE())