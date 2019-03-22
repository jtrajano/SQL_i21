CREATE VIEW [dbo].[vyuGRGetDiscountId]
AS     
 SELECT 
 DId.intDiscountId
,DId.intCurrencyId
,Cur.strCurrency
,DId.strDiscountId
,DId.strDiscountDescription
,DId.ysnDiscountIdActive
FROM tblGRDiscountId DId
JOIN tblSMCurrency Cur ON Cur.intCurrencyID = DId.intCurrencyId
