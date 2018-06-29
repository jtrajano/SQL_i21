CREATE VIEW [dbo].[vyuGRGetDiscountScheduleWithCrossReference]
AS SELECT 
	GRDS.intDiscountScheduleId
	,GRDS.strDiscountDescription
	,GRDS.intCurrencyId
	,GRDS.intCommodityId
	,ICC.strCommodityCode
	,SMC.strCurrency
FROM tblGRDiscountSchedule GRDS
INNER JOIN tblICCommodity ICC ON ICC.intCommodityId = GRDS.intCommodityId
INNER JOIN tblGRDiscountCrossReference GRCR ON GRCR.intDiscountScheduleId = GRDS.intDiscountScheduleId
INNER JOIN tblSMCurrency SMC ON SMC.intCurrencyID = GRDS.intCurrencyId

