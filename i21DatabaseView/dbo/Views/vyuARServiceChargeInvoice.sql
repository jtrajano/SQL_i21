CREATE VIEW [dbo].[vyuARServiceChargeInvoice]
AS
SELECT intInvoiceId			= INV.intInvoiceId
	 , intEntityCustomerId	= INV.intEntityCustomerId
	 , strInvoiceNumber		= INV.strInvoiceNumber
	 , strCustomerName		= EM.strName
	 , dblInvoiceTotal		= INV.dblInvoiceTotal
	 , ysnPosted			= INV.ysnPosted
	 , ysnForgiven			= INV.ysnForgiven
	 , ysnPaid				= INV.ysnPaid
	 , dtmDate				= INV.dtmDate
	 , dtmForgiveDate		= INV.dtmForgiveDate
FROM tblARInvoice INV 
INNER JOIN tblEMEntity EM ON INV.intEntityCustomerId = EM.intEntityId
WHERE strType = 'Service Charge'