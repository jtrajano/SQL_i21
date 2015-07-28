CREATE VIEW dbo.vyuSOSalesOrderSearch
AS
SELECT     
SO.intSalesOrderId, 
SO.strSalesOrderNumber,
NTT.strName AS strCustomerName, 
Cus.strCustomerNumber, 
Cus.[intEntityCustomerId], 
SO.strTransactionType,
ISNULL(SO.strType, 'Standard') AS strType,
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
0.000000 AS dblPaymentAmount,
SO.intQuoteTemplateId,
QT.strTemplateName,
SO.ysnPreliminaryQuote,
SO.intOrderedById,
OE.strName AS strOrderedByName,
SO.intSplitId,
ES.strSplitNumber,
SO.intEntitySalespersonId,
CASE WHEN SP.strSalespersonId = '' THEN NTT.strEntityNo ELSE SP.strSalespersonId END AS strSalespersonId,
ESP.strName AS strSalespersonName,
SO.strLostQuoteCompetitor,
SO.strLostQuoteReason,
SO.strLostQuoteComment
FROM         
dbo.tblSOSalesOrder AS SO LEFT OUTER JOIN
dbo.tblARCustomer AS Cus ON SO.[intEntityCustomerId] = Cus.[intEntityCustomerId] LEFT OUTER JOIN
dbo.tblEntity AS NTT ON Cus.[intEntityCustomerId] = NTT.intEntityId LEFT OUTER JOIN
dbo.tblSMTerm AS Term ON SO.intTermId = Term.intTermID LEFT OUTER JOIN
dbo.tblSMCompanyLocation AS CompLoc ON SO.intCompanyLocationId  = CompLoc.intCompanyLocationId LEFT OUTER JOIN
dbo.tblARQuoteTemplate AS QT ON SO.intQuoteTemplateId = QT.intQuoteTemplateId LEFT OUTER JOIN
dbo.tblEntitySplit AS ES ON SO.intSplitId = ES.intSplitId LEFT OUTER JOIN
dbo.tblEntity AS OE ON SO.intOrderedById = OE.intEntityId LEFT OUTER JOIN
(dbo.tblARSalesperson AS SP INNER JOIN tblEntity ESP ON SP.intEntitySalespersonId = ESP.intEntityId) ON SO.intEntitySalespersonId = SP.intEntitySalespersonId