CREATE VIEW [dbo].[vyuGRGetDiscountIdByLocation]
AS     
SELECT DISTINCT
 DId.intDiscountId
,DId.strDiscountId
,DId.strDiscountDescription
,DId.ysnDiscountIdActive
,DId.intCurrencyId
,Cur.strCurrency
,LC.intCompanyLocationId
,L.strLocationName
,LC.ysnDiscountLocationActive
,DSch.intCommodityId
,Com.strCommodityCode
FROM tblGRDiscountId DId
JOIN tblSMCurrency Cur ON Cur.intCurrencyID = DId.intCurrencyId
JOIN tblGRDiscountLocationUse LC ON LC.intDiscountId=DId.intDiscountId
JOIN tblSMCompanyLocation L ON L.intCompanyLocationId = LC.intCompanyLocationId 
JOIN tblGRDiscountCrossReference DCR ON DCR.intDiscountId=DId.intDiscountId
JOIN tblGRDiscountSchedule DSch ON DSch.intDiscountScheduleId=DCR.intDiscountScheduleId
JOIN tblICCommodity Com ON Com.intCommodityId=DSch.intCommodityId