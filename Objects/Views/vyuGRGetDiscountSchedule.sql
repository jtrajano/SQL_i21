CREATE VIEW [dbo].[vyuGRGetDiscountSchedule]
AS       
SELECT   
 DSch.intDiscountScheduleId  
,DSch.intCurrencyId  
,Cur.strCurrency  
,DSch.intCommodityId  
,Com.strCommodityCode  
,DSch.strDiscountDescription  
FROM tblGRDiscountSchedule DSch  
JOIN tblSMCurrency Cur ON Cur.intCurrencyID = DSch.intCurrencyId  
JOIN tblICCommodity Com ON Com.intCommodityId=DSch.intCommodityId  
