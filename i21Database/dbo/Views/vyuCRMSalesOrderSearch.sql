CREATE VIEW [dbo].[vyuCRMSalesOrderSearch]
AS

SELECT 
	SOS.intSalesOrderId
	,SOS.strSalesOrderNumber
	,SOS.strCustomerName
	,SOS.strCustomerNumber
	,SOS.intEntityCustomerId
	,SOS.strTransactionType
	,SOS.strType
	,SOS.strOrderStatus
	,SOS.strTerm
	,SOS.intTermId
	,SOS.intAccountId
	,SOS.dtmDate
	,SOS.dtmDueDate
	,SOS.ysnProcessed
	,SOS.dblSalesOrderTotal
	,SOS.dblDiscount
	,SOS.dblAmountDue
	,SOS.dblPayment
	,SOS.intCompanyLocationId
	,SOS.intCurrencyId
	,SOS.strLocationName
	,SOS.dblPaymentAmount
	,SOS.intQuoteTemplateId
	,SOS.strTemplateName
	,SOS.ysnPreliminaryQuote
	,SOS.intOrderedById
	,SOS.strOrderedByName
	,SOS.intSplitId
	,SOS.strSplitNumber
	,SOS.intEntitySalespersonId
	,SOS.strSalespersonId
	,SOS.strSalespersonName
	,SOS.strLostQuoteCompetitor
	,SOS.strLostQuoteReason
	,SOS.strLostQuoteComment
	,SOS.ysnRecurring
	,SOS.intEntityContactId
	,SOS.strContactName
	,SOS.ysnHasEmailSetup
	,SOS.strCurrency
	,SOS.strCurrencyDescription
	,SOS.strComments COLLATE Latin1_General_CI_AS AS strComments
	,SOS.strStatus COLLATE Latin1_General_CI_AS AS strStatus
	,SOS.strSalesOrderOriginId
	,SOS.strBillToLocationName
FROM vyuSOSalesOrderSearch SOS 
WHERE SOS.intSalesOrderId NOT IN (SELECT OQ.intSalesOrderId FROM tblCRMOpportunityQuote OQ)

GO