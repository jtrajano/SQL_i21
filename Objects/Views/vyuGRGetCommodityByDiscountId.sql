CREATE VIEW [dbo].[vyuGRGetCommodityByDiscountId]
AS     
SELECT CONVERT(INT, DENSE_RANK() OVER (
			ORDER BY Dcr2.intDiscountScheduleId
				,DSch.intCommodityId
				,Dcr2.intDiscountId
			)) AS intDiscountIdCommodityKey
	,Dcr2.intDiscountId
	,Dcr2.intDiscountScheduleId
	,DSch.strDiscountDescription
	,COM.strCommodityCode
	,DSch.intCommodityId
FROM tblGRDiscountCrossReference Dcr1
JOIN tblGRDiscountCrossReference Dcr2 ON Dcr2.intDiscountId = Dcr1.intDiscountId
JOIN tblGRDiscountSchedule DSch ON DSch.intDiscountScheduleId = Dcr1.intDiscountScheduleId
JOIN tblICCommodity COM ON COM.intCommodityId = DSch.intCommodityId