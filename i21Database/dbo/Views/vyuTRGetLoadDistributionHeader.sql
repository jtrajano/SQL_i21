CREATE VIEW [dbo].[vyuTRGetLoadDistributionHeader]
	AS

SELECT DistHeader.intLoadDistributionHeaderId
	, DistHeader.intLoadHeaderId
	, Header.strTransaction
	, DistHeader.strDestination
	, DistHeader.intEntityCustomerId
	, Customer.strCustomerNumber
	, strCustomerName = Customer.strName
	, DistHeader.intShipToLocationId
	, strShipTo = ShipTo.strLocationName
	, strShipToAddress = ShipTo.strAddress
	, ShipTo.intTaxGroupId
	, TaxGroup.strTaxGroup
	, DistHeader.intCompanyLocationId
	, CompanyLocation.strLocationName
	, strLocationAddress = CompanyLocation.strAddress
	, DistHeader.intEntitySalespersonId
	, Salesperson.strSalespersonName
	, Salesperson.strSalespersonId
	, DistHeader.strPurchaseOrder
	, DistHeader.strComments
	, DistHeader.dtmInvoiceDateTime
	, DistHeader.intInvoiceId
	, Invoice.strInvoiceNumber
FROM tblTRLoadDistributionHeader DistHeader
LEFT JOIN tblTRLoadHeader Header ON Header.intLoadHeaderId = DistHeader.intLoadHeaderId
LEFT JOIN vyuARCustomer Customer ON Customer.intEntityId = DistHeader.intEntityCustomerId
LEFT JOIN tblEMEntityLocation ShipTo ON ShipTo.intEntityLocationId = DistHeader.intShipToLocationId
LEFT JOIN tblSMTaxGroup TaxGroup ON TaxGroup.intTaxGroupId = ShipTo.intTaxGroupId
LEFT JOIN tblSMCompanyLocation CompanyLocation ON CompanyLocation.intCompanyLocationId = DistHeader.intCompanyLocationId
LEFT JOIN vyuEMSalesperson Salesperson ON Salesperson.intEntityId = DistHeader.intEntitySalespersonId
LEFT JOIN tblARInvoice Invoice ON Invoice.intInvoiceId = DistHeader.intInvoiceId