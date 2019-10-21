CREATE VIEW [dbo].[vyuGRGetAllStorageSchedule]
AS
SELECT 
 SR.intStorageScheduleRuleId
,SR.strScheduleId
,SR.strScheduleDescription
,SR.intStorageType
,ST.strStorageTypeDescription
,SR.intCommodity
,COM.strCommodityCode
,SR.strAllowancePeriod
,SR.intAllowanceDays
,SR.dtmAllowancePeriodFrom
,SR.dtmAllowancePeriodTo
,SR.dtmEffectiveDate
,SR.dtmTerminationDate
,SR.strStorageRate  
,SR.intCurrencyID
,CUR.strCurrency  
FROM tblGRStorageScheduleRule SR
JOIN tblGRStorageType ST ON ST.intStorageScheduleTypeId=SR.intStorageType
JOIN tblSMCurrency CUR ON CUR.intCurrencyID = SR.intCurrencyID  
JOIN tblICCommodity COM ON COM.intCommodityId=SR.intCommodity