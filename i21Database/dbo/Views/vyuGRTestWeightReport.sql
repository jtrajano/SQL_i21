CREATE VIEW [dbo].[vyuGRTestWeightReport]
AS
SELECT
	TW.strReadingRange
	,TW.intCommodityId
	,TW.strCommodityCode
	,TW.intCompanyLocationId
	,TW.strLocationName
	,dblTotal = SUM(TW.dblOriginalBalance) 
	,TW.strDeliveryYear
FROM (
	SELECT 
		RR.strReadingRange
		,DS.intCommodityId
		,CO.strCommodityCode
		,CS.intCompanyLocationId
		,CL.strLocationName
		,CS.dblOriginalBalance
		,strDeliveryYear = YEAR(CS.dtmDeliveryDate)
	FROM tblQMTicketDiscount QM
	LEFT JOIN [tblGRTicketDiscountItemInfo] QMII
		on QM.intTicketDiscountId = QMII.intTicketDiscountId
	INNER JOIN tblGRDiscountScheduleCode DSC
		ON DSC.intDiscountScheduleCodeId = QM.intDiscountScheduleCodeId
	INNER JOIN tblGRCustomerStorage CS
		ON CS.intCustomerStorageId = QM.intTicketFileId
	INNER JOIN tblICItem IM
		ON ISNULL(QMII.intItemId, DSC.intItemId) = IM.intItemId
	INNER JOIN tblGRDiscountSchedule DS
		ON DS.intDiscountScheduleId = DSC.intDiscountScheduleId
	INNER JOIN tblICCommodity CO
		ON CO.intCommodityId = DS.intCommodityId
	INNER JOIN tblSMCompanyLocation CL
		ON CL.intCompanyLocationId = CS.intCompanyLocationId		
	LEFT JOIN tblGRReadingRanges RR
		ON QM.dblGradeReading BETWEEN RR.intMinValue AND RR.intMaxValue
			AND RR.intReadingType = 1
	WHERE IM.strDescription = 'TEST WEIGHT' 
		AND QM.strSourceType = 'Storage'
) TW
GROUP BY TW.strReadingRange
		,TW.intCommodityId
		,TW.strCommodityCode
		,TW.intCompanyLocationId
		,TW.strLocationName
		,TW.strDeliveryYear