CREATE VIEW vyuARInvoiceSalesDWM
AS
SELECT 
dblTotal,
B.intItemId,
dtmDate,
ISNULL (I.strItemNo,'No Item')strItemNo,
DATENAME(dw,  A.dtmDate) DayString,
DATENAME(WEEK, A.dtmDate) WeekString,
DATENAME(MONTH, A.dtmDate) MonthString
FROM tblARInvoice A 
JOIN tblARInvoiceDetail B ON
A.intInvoiceId = B.intInvoiceId
LEFT join tblICItem I
ON I.intItemId = B.intItemId
WHERE ysnPosted = 1 and ysnPaid = 1

