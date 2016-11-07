CREATE VIEW [dbo].[vyuGRDiscountScheduleNotMapped]
AS
SELECT
 S.intDiscountScheduleId
,S.intCurrencyId
,ST.strCurrency
,S.intCommodityId
,Com.strCommodityCode	
FROM tblGRDiscountSchedule S
JOIN tblSMCurrency ST ON ST.intCurrencyID = S.intCurrencyId
JOIN tblICCommodity Com ON Com.intCommodityId=S.intCommodityId