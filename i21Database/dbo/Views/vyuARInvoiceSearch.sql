CREATE VIEW dbo.vyuARInvoiceSearch
AS
SELECT     
Inv.intInvoiceId, 
Inv.strInvoiceNumber,
NTT.strName AS strCustomerName, 
Cus.strCustomerNumber, 
Cus.[intEntityCustomerId], 
Inv.strTransactionType, 
Term.strTerm,
Inv.intTermId, 
Inv.intAccountId,
Inv.dtmDate,
Inv.dtmDueDate, 
Inv.ysnPosted, 
Inv.ysnPaid, 
Inv.dblInvoiceTotal, 
ISNULL(Inv.dblDiscount,0) AS dblDiscount, 
ISNULL(Inv.dblAmountDue,0) AS dblAmountDue, 
ISNULL(Inv.dblPayment, 0) AS dblPayment,
Inv.intPaymentMethodId, 
Inv.intCompanyLocationId, 
Inv.strComments,
Inv.intCurrencyId,
CompLoc.strLocationName,
PayMthd.strPaymentMethod,
0.000000 AS dblPaymentAmount
FROM         
dbo.tblARInvoice AS Inv INNER JOIN
dbo.tblARCustomer AS Cus ON Inv.intCustomerId = Cus.[intEntityCustomerId] INNER JOIN
dbo.tblEntity AS NTT ON Cus.[intEntityCustomerId] = NTT.intEntityId LEFT OUTER JOIN
dbo.tblSMTerm AS Term ON Inv.intTermId = Term.intTermID LEFT OUTER JOIN
dbo.tblSMCompanyLocation AS CompLoc ON Inv.intCompanyLocationId  = CompLoc.intCompanyLocationId LEFT OUTER JOIN
dbo.tblSMPaymentMethod AS PayMthd ON Inv.intPaymentMethodId = PayMthd.intPaymentMethodID


