CREATE VIEW [dbo].[vyuGRGetQualityDiscountCode]
 AS 
 SELECT TOP 100 PERCENT 
 Dcode.intDiscountScheduleCodeId
,Dcode.intItemId
,Dcode.intDiscountScheduleId
,DSch.strDiscountDescription
,Item.strShortName
,Item.strItemNo AS strDiscountCodeDescription
,Dcode.intDiscountCalculationOptionId
,Dcode.strDiscountChargeType
,Dcode.dblDefaultValue 
FROM tblGRDiscountScheduleCode Dcode  
JOIN tblICItem Item on Dcode.intItemId=Item.intItemId  
JOIN tblGRDiscountSchedule DSch on DSch.intDiscountScheduleId=Dcode.intDiscountScheduleId 
ORDER BY 4