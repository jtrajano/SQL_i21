CREATE VIEW [dbo].[vyuARInvoiceScaleDetailReport]
AS
SELECT intTicketId					= TICKET.intTicketId
	 , intInvoiceId					= DETAIL.intInvoiceId
	 , strTicketNumber				= TICKET.strTicketNumber
	 , intDiscountSchedule			= READING.intDiscountScheduleCodeId
	 , strDiscountCode				= READING.strDiscountCode
	 , strDiscountCodeDescription	= READING.strDiscountCodeDescription
	 , dblTestWeight				= READING.dblGradeReading
	 , dblDockage					= READING.dblShrinkPercent
	 , dblDiscountAmount			= READING.dblDiscountAmount
	 , dblNetWeight					= ISNULL(TICKET.dblGrossWeight, 0) - ISNULL(TICKET.dblTareWeight, 0)
	 , dblGrossUnits				= TICKET.dblGrossUnits
	 , dblDockedUnits				= TICKET.dblShrink
	 , dblNetUnits					= TICKET.dblNetUnits
	 , dblTotalDeffects				= SUM(DETAIL.dblQtyShipped)
	 , dblTotalDiscount				= SUM(DETAIL.dblTotal)
FROM dbo.tblARInvoiceDetail DETAIL
INNER JOIN dbo.tblSCTicket TICKET ON DETAIL.intTicketId = TICKET.intTicketId
LEFT JOIN dbo.vyuSCGradeReadingReport READING ON READING.intTicketId = TICKET.intTicketId AND DETAIL.intItemId = READING.intItemId
GROUP BY TICKET.intTicketId
	   , DETAIL.intInvoiceId
	   , TICKET.strTicketNumber
       , READING.intDiscountScheduleCodeId
	   , READING.strDiscountCode
	   , READING.strDiscountCodeDescription
	   , READING.dblGradeReading
	   , READING.dblShrinkPercent
	   , READING.dblDiscountAmount
	   , TICKET.dblGrossWeight
	   , TICKET.dblGrossUnits
	   , TICKET.dblShrink
	   , TICKET.dblNetUnits
	   , TICKET.dblTareWeight