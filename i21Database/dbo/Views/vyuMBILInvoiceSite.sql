CREATE VIEW [dbo].[vyuMBILInvoiceSite]
	AS

SELECT Invoice.*
	, InvoiceSite.intInvoiceSiteId
	, InvoiceSite.intSiteId
	, Site.intSiteNumber
	, strSiteDescription = Site.strDescription
	, Site.strSiteAddress
	, Site.strCity
	, Site.strState
	, Site.strZipCode
	, Site.strCountry
FROM tblMBILInvoiceSite InvoiceSite
LEFT JOIN tblTMSite Site ON Site.intSiteID = InvoiceSite.intSiteId
LEFT JOIN vyuMBILInvoice Invoice ON Invoice.intInvoiceId = InvoiceSite.intInvoiceId