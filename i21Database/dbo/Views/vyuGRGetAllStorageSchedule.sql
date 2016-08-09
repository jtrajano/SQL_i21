CREATE VIEW [dbo].[vyuGRGetAllStorageSchedule]
AS
SELECT 
 S.intStorageScheduleRuleId
,S.strScheduleId
,S.strScheduleDescription
,S.intStorageType
,ST.strStorageTypeDescription
,S.intCommodity
,Com.strCommodityCode  
,S.strFeeType
,S.intCurrencyID
,Cur.strCurrency  
FROM tblGRStorageScheduleRule S
JOIN tblGRStorageType ST ON ST.intStorageScheduleTypeId=S.intStorageType
JOIN tblSMCurrency Cur ON Cur.intCurrencyID = S.intCurrencyID  
JOIN tblICCommodity Com ON Com.intCommodityId=S.intCommodity