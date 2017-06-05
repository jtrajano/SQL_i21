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
, (SELECT intCurrencyDecimal FROM tblSMCompanyPreference) AS intDecimalPrecision
FROM tblGRDiscountScheduleCode GR 
INNER JOIN tblICItem IC on GR.intItemId = IC.intItemId 
INNER JOIN tblQMTicketDiscount QM on QM.intDiscountScheduleCodeId = GR.intDiscountScheduleCodeId AND QM.strSourceType='Scale'