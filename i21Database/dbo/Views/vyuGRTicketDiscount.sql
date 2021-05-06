CREATE VIEW dbo.vyuGRTicketDiscount
AS
SELECT   
	TD.intTicketDiscountId
	,TD.dblGradeReading
	,TD.strCalcMethod
	,TD.strShrinkWhat
	,TD.dblShrinkPercent
	,TD.dblDiscountAmount
	,dblDiscountDue = ISNULL(TD.dblDiscountDue,0)
	,TD.dblDiscountPaid
	,TD.ysnGraderAutoEntry
	,TD.intDiscountScheduleCodeId
	,TD.dtmDiscountPaidDate
	,TD.intTicketId
	,TD.intTicketFileId
	,TD.strSourceType
	,TD.intSort
	,TD.intConcurrencyId
	,QD.dblDefaultValue
	,QD.intDiscountCalculationOptionId
	,QD.intDiscountScheduleId
	,ISNULL(TDII.intItemId, QD.intItemId)  as intItemId
	,QD.strDiscountChargeType
	,QD.strDiscountCodeDescription
	,QD.strDiscountDescription
	,strDiscountCode = ISNULL(Item.strShortName, QD.strShortName)
	,DCO.strDiscountCalculationOption
FROM tblQMTicketDiscount TD
LEFT JOIN [tblGRTicketDiscountItemInfo] TDII
	on TDII.intTicketDiscountId = TD.intTicketDiscountId
LEFT JOIN tblICItem Item
	on Item.intItemId = TDII.intItemId
INNER JOIN vyuGRGetQualityDiscountCode QD
	ON TD.intDiscountScheduleCodeId = QD.intDiscountScheduleCodeId 
INNER JOIN tblGRDiscountCalculationOption DCO
	ON DCO.intDiscountCalculationOptionId = QD.intDiscountCalculationOptionId
WHERE TD.strSourceType = 'Storage'