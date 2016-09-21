CREATE VIEW [dbo].[vyuGRGetDiscountIdByLocation]
AS     
SELECT 
 DId.intDiscountId
,DId.strDiscountId
,DId.strDiscountDescription
,DId.ysnDiscountIdActive
,DId.intCurrencyId
,Cur.strCurrency
,LC.intCompanyLocationId
,L.strLocationName
,LC.ysnDiscountLocationActive
FROM tblGRDiscountId DId
JOIN tblSMCurrency Cur ON Cur.intCurrencyID = DId.intCurrencyId
JOIN tblGRDiscountLocationUse LC ON LC.intDiscountId=DId.intDiscountId
JOIN tblSMCompanyLocation L ON L.intCompanyLocationId = LC.intCompanyLocationId 
