CREATE VIEW dbo.vyuSCGradeReadingReport
AS SELECT 
GR.intDiscountScheduleCodeId
, GR.intItemId
, IC.strShortName AS strDiscountCode
, IC.strItemNo AS strDiscountCodeDescription
, GR.intDiscountCalculationOptionId
, GR.strDiscountChargeType
, QM.dblGradeReading
, QM.dblDiscountAmount
, QM.dblShrinkPercent
, QM.strShrinkWhat
, QM.intTicketId
, GR.ysnDryingDiscount
, SCTF.intTicketFormatId
, SCTF.intSuppressDiscountOptionId
, (SELECT intCurrencyDecimal FROM tblSMCompanyPreference) AS intDecimalPrecision
FROM tblGRDiscountScheduleCode GR 
LEFT JOIN tblICItem IC on GR.intItemId = IC.intItemId 
LEFT JOIN tblQMTicketDiscount QM on QM.intDiscountScheduleCodeId = GR.intDiscountScheduleCodeId
LEFT JOIN tblSCTicket SC ON SC.intTicketId = QM.intTicketId
LEFT JOIN tblSCTicketPrintOption SCP ON SCP.intScaleSetupId = SC.intScaleSetupId AND SCP.ysnPrintCustomerCopy = 1
LEFT JOIN tblSCTicketFormat SCTF ON SCTF.intTicketFormatId = SCP.intTicketFormatId
