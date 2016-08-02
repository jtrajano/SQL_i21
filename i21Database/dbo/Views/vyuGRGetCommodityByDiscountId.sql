CREATE VIEW [dbo].[vyuGRGetCommodityByDiscountId]
AS     
SELECT CONVERT(INT, DENSE_RANK() OVER (
			ORDER BY cr2.intDiscountScheduleId
				,DSch.intCommodityId
				,cr2.intDiscountId
			)) AS intDiscountIdCommodityKey
	,cr2.intDiscountId
	,cr2.intDiscountScheduleId
	,DSch.strDiscountDescription
	,com.strCommodityCode
	,DSch.intCommodityId
FROM tblGRDiscountCrossReference cr1
JOIN tblGRDiscountCrossReference cr2 ON cr2.intDiscountId = cr1.intDiscountId
JOIN tblGRDiscountSchedule DSch ON DSch.intDiscountScheduleId = cr1.intDiscountScheduleId
JOIN tblICCommodity com ON com.intCommodityId = DSch.intCommodityId