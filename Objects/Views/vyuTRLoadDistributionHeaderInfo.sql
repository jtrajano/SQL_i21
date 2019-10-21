CREATE VIEW [dbo].[vyuTRLoadDistributionHeaderInfo]
	AS 

SELECT DH.intLoadDistributionHeaderId
	, DH.intLoadHeaderId
	, DH.intEntityCustomerId
	, C.strCustomerNumber
	, strCustomerName = C.strName
	, DH.intShipToLocationId
	, strShipTo = EL.strLocationName
	, EL.intTaxGroupId
	, TG.strTaxGroup
	, DH.intCompanyLocationId
	, CL.strLocationName
	, DH.intEntitySalespersonId
	, SP.strSalespersonName
	, SP.strSalespersonId
	, DH.intInvoiceId
	, I.strInvoiceNumber
	, I.dblAmountDue
FROM tblTRLoadDistributionHeader DH
LEFT JOIN vyuARCustomer C ON C.intEntityId = DH.intEntityCustomerId
LEFT JOIN tblEMEntityLocation EL ON EL.intEntityLocationId = DH.intShipToLocationId
LEFT JOIN tblSMTaxGroup TG ON TG.intTaxGroupId = EL.intTaxGroupId
LEFT JOIN tblSMCompanyLocation CL ON CL.intCompanyLocationId = DH.intCompanyLocationId
LEFT JOIN vyuEMSalesperson SP ON SP.intEntityId = DH.intEntitySalespersonId
LEFT JOIN tblARInvoice I ON I.intInvoiceId = DH.intInvoiceId
