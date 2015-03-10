CREATE VIEW dbo.vyuSOSalesOrderSearch
AS
SELECT     
SO.intSalesOrderId, 
SO.strSalesOrderNumber,
NTT.strName AS strCustomerName, 
Cus.strCustomerNumber, 
Cus.[intEntityCustomerId], 
SO.strTransactionType,
SO.strOrderStatus, 
Term.strTerm,
SO.intTermId, 
SO.intAccountId,
SO.dtmDate,
SO.dtmDueDate, 
SO.ysnProcessed,
SO.dblSalesOrderTotal, 
ISNULL(SO.dblDiscount,0) AS dblDiscount, 
ISNULL(SO.dblAmountDue,0) AS dblAmountDue, 
ISNULL(SO.dblPayment, 0) AS dblPayment,
SO.intCompanyLocationId, 
SO.intCurrencyId,
CompLoc.strLocationName,
0.000000 AS dblPaymentAmount
FROM         
dbo.tblSOSalesOrder AS SO INNER JOIN
dbo.tblARCustomer AS Cus ON SO.intCustomerId = Cus.[intEntityCustomerId] INNER JOIN
dbo.tblEntity AS NTT ON Cus.[intEntityCustomerId] = NTT.intEntityId LEFT OUTER JOIN
dbo.tblSMTerm AS Term ON SO.intTermId = Term.intTermID LEFT OUTER JOIN
dbo.tblSMCompanyLocation AS CompLoc ON SO.intCompanyLocationId  = CompLoc.intCompanyLocationId