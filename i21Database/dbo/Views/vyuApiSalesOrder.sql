CREATE VIEW [dbo].[vyuApiSalesOrder]
AS

SELECT
	  vso.strType
    , so.intSalesOrderId
	, vso.ysnRecurring
	, vso.strCustomerName
	, vso.dtmDate
	, vso.strCurrency
	, vso.strLocationName
	, vso.strBillToLocationName
	, so.strShipToLocationName
	, vso.strOrderedByName
	, via.strShipVia
	, applicator.strName strApplicator
	, so.strPONumber
	, so.strBOLNumber
	, so.strOrderStatus
	, ft.strFreightTerm
	, so.dtmExpirationDate
	, so.strSalesOrderNumber
	, vso.strSalespersonName
	, vso.strContactName
    , so.intDocumentMaintenanceId
	, so.dblSalesOrderSubtotal
    , so.dblSalesOrderTotal
    , so.dblTax
    , so.dblTotalDiscount
	, so.dblShipping
	, lb.strLineOfBusiness
	, tr.strTerm
	, so.strTransactionType
	, so.ysnPreliminaryQuote
	, op.strName strOpportunityName
	, CAST(CASE WHEN so.strQuoteType = 'Price Only' THEN 1 ELSE 0 END AS BIT) ysnPriceOnly
	, CAST(CASE WHEN so.strQuoteType = 'Price Quantity' THEN 1 ELSE 0 END AS BIT) ysnPriceAndQuantity
	, created.dtmDate dtmDateCreated
	, COALESCE(updated.dtmDate, created.dtmDate) dtmDateLastUpdated
FROM vyuSOSalesOrderSearch vso
LEFT JOIN tblSOSalesOrder so ON so.intSalesOrderId = vso.intSalesOrderId
LEFT JOIN tblCRMOpportunity op ON op.intOpportunityId = so.intOpportunityId
LEFT JOIN tblSMShipVia via ON via.intEntityId = so.intShipViaId
LEFT JOIN tblEMEntity applicator ON applicator.intEntityId = so.intEntityApplicatorId
LEFT JOIN tblSMFreightTerms ft ON ft.intFreightTermId = so.intFreightTermId
LEFT JOIN tblSMLineOfBusiness lb ON lb.intLineOfBusinessId = so.intLineOfBusinessId
LEFT JOIN tblSMTerm tr ON tr.intTermID = so.intTermId
OUTER APPLY (
	SELECT TOP 1 au.dtmDate
	FROM vyuApiRecordAudit au
	WHERE au.intRecordId = so.intSalesOrderId
		AND au.strNamespace IN ('AccountsReceivable.view.SalesOrder', 'AccountsReceivable.view.Quote')
) created
OUTER APPLY (
	SELECT TOP 1 au.dtmDate
	FROM vyuApiRecordAudit au
	WHERE au.intRecordId = so.intSalesOrderId
		AND au.strNamespace IN ('AccountsReceivable.view.SalesOrder', 'AccountsReceivable.view.Quote')
) updated