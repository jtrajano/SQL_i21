CREATE VIEW [dbo].[vyuGRDiscountScheduleNotMapped]
AS
SELECT
 DSch.intDiscountScheduleId
,DSch.intCurrencyId
,ST.strCurrency
,DSch.intCommodityId
,COM.strCommodityCode	
FROM tblGRDiscountSchedule DSch
JOIN tblSMCurrency ST ON ST.intCurrencyID = DSch.intCurrencyId
JOIN tblICCommodity COM ON COM.intCommodityId=DSch.intCommodityId