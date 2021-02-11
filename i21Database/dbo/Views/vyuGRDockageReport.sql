CREATE VIEW [dbo].[vyuGRDockageReport]
AS
SELECT
	TW.strReadingRange
	,TW.intCommodityId
	,TW.strCommodityCode
	,TW.intCompanyLocationId
	,TW.strLocationName
	,dblTotalAmount = SUM(TW.dblOriginalBalance)
	,TW.strDeliveryYear
FROM (
	SELECT DISTINCT
		RR.strReadingRange
		,DS.intCommodityId
		,CO.strCommodityCode
		,CS.intCompanyLocationId
		,CL.strLocationName
		,CS.intCustomerStorageId
		,CS.dblOriginalBalance
		,strDeliveryYear = YEAR(CS.dtmDeliveryDate)
	FROM tblQMTicketDiscount QM
	INNER JOIN tblGRDiscountScheduleCode DSC
		ON DSC.intDiscountScheduleCodeId = QM.intDiscountScheduleCodeId
	INNER JOIN tblGRCustomerStorage CS
		ON CS.intCustomerStorageId = QM.intTicketFileId
	INNER JOIN tblICItem IM
		ON IM.intItemId = DSC.intItemId			
	INNER JOIN tblGRDiscountSchedule DS
		ON DS.intDiscountScheduleId = DSC.intDiscountScheduleId
	INNER JOIN tblICCommodity CO
		ON CO.intCommodityId = DS.intCommodityId
	INNER JOIN tblSMCompanyLocation CL
		ON CL.intCompanyLocationId = CS.intCompanyLocationId		
	LEFT JOIN tblGRReadingRanges RR
		ON QM.dblGradeReading BETWEEN RR.intMinValue AND RR.intMaxValue
			AND RR.intReadingType = 2
	WHERE IM.strDescription LIKE '%DOCKAGE%' AND IM.strDescription LIKE '%DISCOUNT%'
		AND QM.strSourceType = 'Storage'
) TW
GROUP BY TW.strReadingRange
		,TW.intCommodityId
		,TW.strCommodityCode
		,TW.intCompanyLocationId
		,TW.strLocationName
		,TW.strDeliveryYear