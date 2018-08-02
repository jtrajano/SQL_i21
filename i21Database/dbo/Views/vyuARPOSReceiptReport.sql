CREATE VIEW [dbo].[vyuARPOSReceiptReport]
AS 
SELECT intPOSId				= POS.intPOSId
	 , strItemNo			= POSD.strItemNo
	 , strCustomerName		= CUSTOMER.strName
	 , strItemDescription	= POSD.strItemDescription
	 , strInvoiceNumber		= INVOICE.strInvoiceNumber
	 , dblQuantity			= POSD.dblQuantity
     , dblPrice				= POSD.dblPrice
	 , dblExtendedPrice		= POSD.dblExtendedPrice
	 , intItemCount			= POS.intItemCount
     , dblSubTotal			= POS.dblSubTotal
	 , dblShipping			= POS.dblShipping
	 , dblTax				= POS.dblTax
	 , dblDiscountPercent	= POS.dblDiscountPercent
	 , dblDiscount			= POS.dblDiscount
	 , dblTotal				= POS.dblTotal
     , strCompanyName		= COMPANY.strCompanyName
     , strCompanyAddress	= COMPANY.strFullAddress
	 , strReceiptNumber		= POS.strReceiptNumber
	 , strUserName			= USERNAME.strUserName
	 , strLocation			= LOCATION.strLocationName
	 , strStore				= ISNULL(STORE.strDescription, '') 
FROM dbo.tblARPOS POS WITH (NOLOCK)
INNER JOIN dbo.tblARPOSDetail POSD ON POS.intPOSId = POSD.intPOSId
INNER JOIN (
	SELECT intPOSLogId
		 , intEntityUserId
		 , intCompanyLocationId
		 , intStoreId
	FROM dbo.tblARPOSLog WITH (NOLOCK)
) POSLOG ON POS.intPOSLogId = POSLOG.intPOSLogId
LEFT JOIN (
	SELECT intInvoiceId
		 , strInvoiceNumber
	FROM dbo.tblARInvoice WITH (NOLOCK)
) INVOICE ON INVOICE.intInvoiceId = POS.intInvoiceId
LEFT JOIN (
	SELECT intEntityId
		 , strUserName 
	FROM dbo.tblEMEntityCredential WITH (NOLOCK)
) USERNAME ON USERNAME.intEntityId = POSLOG.intEntityUserId
LEFT JOIN (
	SELECT intCompanyLocationId
		 , strLocationName 
	FROM dbo.tblSMCompanyLocation WITH (NOLOCK) 
) LOCATION ON LOCATION.intCompanyLocationId = POSLOG.intCompanyLocationId
LEFT JOIN (
	SELECT intStoreId
		 , strDescription 
	FROM dbo.tblSTStore WITH (NOLOCK)
) STORE ON STORE.intStoreId = POSLOG.intStoreId
LEFT JOIN (
	SELECT intEntityId
		 , strName
	FROM dbo.tblEMEntity WITH (NOLOCK)
) CUSTOMER ON POS.intEntityCustomerId = CUSTOMER.intEntityId 
OUTER APPLY (
	SELECT TOP 1 strCompanyName 
			   , strFullAddress = dbo.fnConvertToFullAddress(strAddress, strCity, strState, strZip), strPhone, strFax = strFax + ' Fax'
	FROM dbo.tblSMCompanySetup WITH (NOLOCK)
) COMPANY