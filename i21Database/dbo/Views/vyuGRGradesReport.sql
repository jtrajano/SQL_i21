CREATE VIEW [dbo].[vyuGRGradesReport]
AS
SELECT 
	GD.intCompanyLocationId
	,GD.strLocationName
	,GD.intCommodityId
	,GD.strCommodityCode
	,GD.strGrade
	,dblTotalUnits = SUM(GD.dblOriginalBalance)
	,GD.intDeliveryYear
FROM (
	SELECT 
		CL.intCompanyLocationId
		,CL.strLocationName
		,CO.intCommodityId
		,CO.strCommodityCode
		,'#' + CAST(CAST(ISNULL(QM.dblGradeReading,0) AS INT) AS nvarchar(10)) COLLATE Latin1_General_CI_AS as strGrade
		,CS.dblOriginalBalance
		,intDeliveryYear = YEAR(CS.dtmDeliveryDate)
	FROM tblQMTicketDiscount QM	
	LEFT JOIN [tblGRTicketDiscountItemInfo] QMII
		on QM.intTicketDiscountId = QMII.intTicketDiscountId
	INNER JOIN tblGRDiscountScheduleCode DSC
		ON DSC.intDiscountScheduleCodeId = QM.intDiscountScheduleCodeId
	INNER JOIN tblICItem IM
		ON ISNULL(QMII.intItemId,DSC.intItemId) = IM.intItemId
	INNER JOIN tblGRDiscountSchedule DS
		ON DS.intDiscountScheduleId = DSC.intDiscountScheduleId
	INNER JOIN tblGRCustomerStorage CS
		ON CS.intCustomerStorageId = QM.intTicketFileId
			AND CS.intDiscountScheduleId = DS.intDiscountScheduleId
	INNER JOIN tblICCommodity CO
		ON CO.intCommodityId = DS.intCommodityId
	INNER JOIN tblSMCompanyLocation CL
		ON CL.intCompanyLocationId = CS.intCompanyLocationId
	WHERE QM.strSourceType = 'Storage'
		AND IM.strDescription = 'GRADE'
) GD
GROUP BY GD.intCompanyLocationId
	,GD.strLocationName
	,GD.intCommodityId
	,GD.strCommodityCode
	,GD.strGrade
	,GD.intDeliveryYear