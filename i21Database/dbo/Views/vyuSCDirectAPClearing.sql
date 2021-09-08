CREATE VIEW [dbo].[vyuSCDirectAPClearing]
AS 
SELECT
	'1' as strMark,
	-- original select
    intEntityVendorId = SC.intEntityId
    ,dtmDate = SC.dtmTicketDateTime
    ,SC.strTicketNumber
    ,SC.intTicketId
    ,bill.intBillId
    ,bill.strBillId
    ,billDetail.intBillDetailId
    ,intScalTicketId = SC.intTicketId
    ,SC.intItemId
    ,intItemUOMId = SC.intItemUOMIdTo
    ,strUOM = ICUnitOfMeasure.strUnitMeasure
    ,dblVoucherTotal = ROUND((dblNetUnits * (ISNULL(dblUnitBasis,0) + ISNULL(dblUnitPrice,0))),2)	
    ,dblVoucherQty = SC.dblNetUnits
    ,0 AS dblReceiptTotal
    ,0 AS dblReceiptQty
    ,intLocationId = SC.intProcessingLocationId
    ,compLoc.strLocationName
    ,CAST(1 AS BIT) ysnAllowVoucher
    ,APClearing.intAccountId
	,APClearing.strAccountId
FROM tblSCTicket SC
INNER JOIN tblAPBillDetail billDetail
	ON  billDetail.intItemId = SC.intItemId
		and billDetail.intScaleTicketId = SC.intTicketId
INNER JOIN tblAPBill bill ON billDetail.intBillId = bill.intBillId
INNER JOIN tblSMCompanyLocation compLoc
    ON SC.intProcessingLocationId = compLoc.intCompanyLocationId
INNER JOIN vyuGLAccountDetail APClearing
    ON APClearing.intAccountId = billDetail.intAccountId AND APClearing.intAccountCategoryId = 45
INNER JOIN tblICItemUOM ICUOM
	ON SC.intItemUOMIdTo = ICUOM.intItemUOMId
INNER JOIN tblICUnitMeasure ICUnitOfMeasure
	ON ICUOM.intUnitMeasureId = ICUnitOfMeasure.intUnitMeasureId
WHERE SC.intTicketType = 6
	AND SC.intTicketTypeId = 8
	AND SC.strTicketStatus = 'C'
GO
