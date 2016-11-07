CREATE VIEW [dbo].[vyuGRStorageScheduleRuleNotMapped]
AS
SELECT
S.intStorageScheduleRuleId
,S.intCommodity
,Com.strCommodityCode	
,S.intCurrencyID
,Cur.strCurrency
,ST.ysnDPOwnedType
FROM tblGRStorageScheduleRule S
JOIN tblGRStorageType ST ON ST.intStorageScheduleTypeId=S.intStorageType
JOIN tblICCommodity Com ON Com.intCommodityId=S.intCommodity
JOIN tblSMCurrency Cur ON Cur.intCurrencyID = S.intCurrencyID