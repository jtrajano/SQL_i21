CREATE VIEW [dbo].[vyuARPOSReceiptReport]
AS 
SELECT intPOSId				= POS.intPOSId
	 , strItemNo			= POSD.strItemNo
	 , strCustomerName		= CUSTOMER.strName
	 , strCustomerNumber	= CUSTOMER.strCustomerNumber
	 , strCustomerAddress   = [dbo].fnARFormatCustomerAddress(NULL, NULL, NULL, CUSTOMER.strAddress, CUSTOMER.strCity, CUSTOMER.strState, CUSTOMER.strZipCode, NULL, NULL, NULL)
	 , strItemDescription	= POSD.strItemDescription
	 , strItemUOM			= POSD.strItemUOM
	 , strInvoiceNumber		= INVOICE.strInvoiceNumber
	 , dblQuantity			= CASE WHEN POS.ysnReturn = 1 AND POSD.dblPrice < 0 THEN POSD.dblQuantity * -1 ELSE POSD.dblQuantity END
     , dblPrice				= POSD.dblPrice
	 , dblExtendedPrice		= POSD.dblExtendedPrice
	 , intItemUOMId			= POSD.intItemUOMId
	 , intItemCount			= POS.intItemCount
     , dblSubTotal			= POS.dblSubTotal
	 , dblShipping			= POS.dblShipping
	 , dblTax				= CASE WHEN POS.ysnReturn = 1 AND POSD.dblPrice < 0 THEN POS.dblTax * -1 ELSE POS.dblTax END
	 , dblItemDiscountPercent = POSD.dblDiscountPercent
	 , dblDiscountPercent	= POS.dblDiscountPercent
	 , dblDiscount			= CASE WHEN POS.ysnReturn = 1 AND POSD.dblPrice < 0 THEN POS.dblDiscount * -1 ELSE POS.dblDiscount END
	 , dblTotal				= POS.dblTotal
     , strCompanyName		= COMPANY.strCompanyName
     , strCompanyAddress	= COMPANY.strFullAddress
	 , strReceiptNumber		= POS.strReceiptNumber
	 , strUserName			= USERNAME.strName
	 , strLocation			= LOCATION.strLocationName
	 , strLocationAddress	= LOCATION.strLocationAddress
	 , strStore				= ISNULL(STORE.strDescription, '')
	 , strPONumber			= POS.strPONumber
	 , strComment			= POS.strComment
	 , ysnReturn			= POS.ysnReturn
	 , dtmDate				= POS.dtmDate
	 , ysnTaxExempt			= POS.ysnTaxExempt
FROM dbo.tblARPOS POS WITH (NOLOCK)
INNER JOIN dbo.tblARPOSDetail POSD ON POS.intPOSId = POSD.intPOSId
INNER JOIN (
	SELECT intPOSLogId
		 , intEntityId
		 , intPOSEndOfDayId
	FROM dbo.tblARPOSLog WITH (NOLOCK)
) POSLOG ON POS.intPOSLogId = POSLOG.intPOSLogId
INNER JOIN (
	SELECT
		intPOSEndOfDayId
		, intEntityId
		, intStoreId
		, intCompanyLocationPOSDrawerId
		, intBankDepositId
		, ysnClosed
		, strEODNo
		, dblOpeningBalance
		, dblFinalEndingBalance
	FROM tblARPOSEndOfDay
) EOD ON POSLOG.intPOSEndOfDayId = EOD.intPOSEndOfDayId
LEFT JOIN (
	SELECT intInvoiceId
		 , strInvoiceNumber
	FROM dbo.tblARInvoice WITH (NOLOCK)
) INVOICE ON INVOICE.intInvoiceId = POS.intInvoiceId
LEFT JOIN (
	SELECT intEntityId
		 , strName 
	FROM dbo.tblEMEntity WITH (NOLOCK)
) USERNAME ON USERNAME.intEntityId = POS.intEntityUserId
INNER JOIN (
	SELECT
		intCompanyLocationPOSDrawerId
		, intCompanyLocationId
	FROM tblSMCompanyLocationPOSDrawer
) DRAWER ON EOD.intCompanyLocationPOSDrawerId = DRAWER.intCompanyLocationPOSDrawerId
LEFT JOIN (
	SELECT intCompanyLocationId
		 , strLocationName
		 , strLocationAddress = [dbo].fnARFormatCustomerAddress(NULL, NULL, NULL, strAddress, strCity, strStateProvince, strZipPostalCode, NULL, NULL, NULL), strPhone, strFax = strFax + ' Fax'
	FROM dbo.tblSMCompanyLocation WITH (NOLOCK) 
) LOCATION ON LOCATION.intCompanyLocationId = DRAWER.intCompanyLocationId
LEFT JOIN (
	SELECT intStoreId
		 , strDescription 
	FROM dbo.tblSTStore WITH (NOLOCK)
) STORE ON STORE.intStoreId = EOD.intStoreId
LEFT JOIN (
	SELECT intEntityId
		 , strName
		 , strCustomerNumber
		 , strAddress
		 , strCity
		 , strState
		 , strZipCode
	FROM dbo.vyuARCustomerSearch WITH (NOLOCK)
) CUSTOMER ON POS.intEntityCustomerId = CUSTOMER.intEntityId 
OUTER APPLY (
	SELECT TOP 1 strCompanyName 
			   , strFullAddress = dbo.fnConvertToFullAddress(strAddress, strCity, strState, strZip), strPhone, strFax = strFax + ' Fax'
	FROM dbo.tblSMCompanySetup WITH (NOLOCK)
) COMPANY