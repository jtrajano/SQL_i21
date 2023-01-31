CREATE VIEW [dbo].[vyuCTRestApiTicketDiscount]
AS
SELECT i.strItemNo AS strDiscountCode,  t.*
FROM tblQMTicketDiscount t
LEFT OUTER JOIN tblGRDiscountScheduleCode d ON d.intDiscountScheduleCodeId = t.intDiscountScheduleCodeId
LEFT OUTER JOIN tblICItem i ON i.intItemId = d.intItemId