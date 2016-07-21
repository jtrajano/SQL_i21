CREATE VIEW [dbo].[vyuGRGetQualityDiscountCode]
 AS 
 SELECT TOP 100 PERCENT 
 a.intDiscountScheduleCodeId
,a.intItemId
,a.intDiscountScheduleId
,c.strDiscountDescription
,b.strShortName
,b.strItemNo AS strDiscountCodeDescription
,a.intDiscountCalculationOptionId
,a.strDiscountChargeType 
FROM tblGRDiscountScheduleCode a  
JOIN tblICItem b on a.intItemId=b.intItemId  
JOIN tblGRDiscountSchedule c on c.intDiscountScheduleId=a.intDiscountScheduleId 
ORDER BY 4