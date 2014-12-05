CREATE VIEW dbo.vyuARInvoiceSearch
AS
SELECT     
Inv.intInvoiceId, 
Inv.strInvoiceNumber,
NTT.strName AS strCustomerName, 
Cus.strCustomerNumber, 
Cus.intCustomerId, 
Inv.strTransactionType, 
Term.strTerm,
Inv.intTermId, 
Inv.dtmDate,
Inv.dtmDueDate, 
Inv.ysnPosted, 
Inv.ysnPaid, 
Inv.dblInvoiceTotal, 
Inv.dblDiscount, 
Inv.dblAmountDue, 
Inv.dblPayment, 
Inv.intPaymentMethodId, 
Inv.intCompanyLocationId, 
Inv.strComments,
Inv.intCurrencyId,
CompLoc.strLocationName,
PayMthd.strPaymentMethod
FROM         
dbo.tblARInvoice AS Inv INNER JOIN
dbo.tblARCustomer AS Cus ON Inv.intCustomerId = Cus.intCustomerId INNER JOIN
dbo.tblEntity AS NTT ON Cus.intEntityId = NTT.intEntityId LEFT OUTER JOIN
dbo.tblSMTerm AS Term ON Inv.intTermId = Term.intTermID LEFT OUTER JOIN
dbo.tblSMCompanyLocation AS CompLoc ON Inv.intCompanyLocationId  = CompLoc.intCompanyLocationId LEFT OUTER JOIN
dbo.tblSMPaymentMethod AS PayMthd ON Inv.intPaymentMethodId = PayMthd.intPaymentMethodID


