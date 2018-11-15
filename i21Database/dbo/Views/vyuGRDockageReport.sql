CREATE VIEW [dbo].[vyuGRDockageReport]
AS
SELECT TOP 100 PERCENT
	TW.strReadingRange
	,TW.intCommodityId
	,TW.strCommodityCode
	,TW.intCompanyLocationId
	,TW.strLocationName
	,dblSubTotalByLocation = SUM(TW.dblSubTotal) 
FROM (
	SELECT 
		RR.strReadingRange
		,QM.*
		,DS.intCommodityId
		,CO.strCommodityCode
		,CS.intCompanyLocationId
		,CL.strLocationName
		,dblSubTotal = (QM.dblDiscountAmount * CS.dblOriginalBalance)
		,CS.dtmDeliveryDate
	FROM tblQMTicketDiscount QM
	INNER JOIN tblGRDiscountScheduleCode DSC
		ON DSC.intDiscountScheduleCodeId = QM.intDiscountScheduleCodeId
	INNER JOIN tblGRCustomerStorage CS
		ON CS.intCustomerStorageId = QM.intTicketFileId
	INNER JOIN tblICItem IM
		ON DSC.intItemId = IM.intItemId
	INNER JOIN tblGRDiscountSchedule DS
		ON DS.intDiscountScheduleId = DSC.intDiscountScheduleId
	INNER JOIN tblICCommodity CO
		ON CO.intCommodityId = DS.intCommodityId
	INNER JOIN tblSMCompanyLocation CL
		ON CL.intCompanyLocationId = CS.intCompanyLocationId		
	LEFT JOIN tblGRReadingRanges RR
		ON (QM.dblGradeReading BETWEEN RR.intMinValue AND RR.intMaxValue)
			OR (QM.dblGradeReading > 2.64)
			AND RR.intReadingType = 2
	WHERE IM.strDescription LIKE '%DOCKAGE%' 
		AND QM.strSourceType = 'Storage'
		--AND dbo.fnRemoveTimeOnDate(CS.dtmDeliveryDate) BETWEEN CONVERT(DATETIME,'01/01/2016') AND CONVERT(DATETIME,'12/31/2016')
) TW
GROUP BY TW.strReadingRange
		,TW.intCommodityId
		,TW.strCommodityCode
		,TW.intCompanyLocationId
		,TW.strLocationName
ORDER BY TW.intCommodityId
		,TW.strReadingRange DESC