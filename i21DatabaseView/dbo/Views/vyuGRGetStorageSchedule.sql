CREATE VIEW [dbo].[vyuGRGetStorageSchedule]
AS
SELECT 
 SR.intStorageScheduleRuleId
,SR.strScheduleId
,SR.strScheduleDescription
,SR.intStorageType
,SR.intCommodity
,SR.intAllowanceDays
,SR.dtmEffectiveDate
,SR.dtmTerminationDate
,SR.intCurrencyID
,SR.strStorageRate
,SR.strFirstMonth
,SR.strLastMonth
,ST.ysnDPOwnedType
,SLU.intCompanyLocationId 
FROM tblGRStorageScheduleRule SR
JOIN tblGRStorageScheduleLocationUse SLU ON SLU.intStorageScheduleId=SR.intStorageScheduleRuleId
JOIN tblGRStorageType ST ON ST.intStorageScheduleTypeId=SR.intStorageType 
WHERE SLU.ysnStorageScheduleLocationActive=1 
AND ISNULL(dbo.fnRemoveTimeOnDate(SR.dtmEffectiveDate), dbo.fnRemoveTimeOnDate(GETDATE()))<=dbo.fnRemoveTimeOnDate(GETDATE())
AND ISNULL(dbo.fnRemoveTimeOnDate(SR.dtmTerminationDate), dbo.fnRemoveTimeOnDate(GETDATE()))>=dbo.fnRemoveTimeOnDate(GETDATE())