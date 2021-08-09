﻿CREATE VIEW [dbo].[vyuARSearchPOS]
AS 
SELECT intPOSId							= POS.intPOSId
	 , intEntityCustomerId				= POS.intEntityCustomerId
	 , intBillToId						= CUSTOMER.intBillToId
	 , intShipToId						= CUSTOMER.intShipToId
	 , intCompanyLocationId				= POS.intCompanyLocationId
	 , dtmDate							= POS.dtmDate
	 , strCreditCode					= CUSTOMER.strCreditCode
	 , strReceiptNumber					= POS.strReceiptNumber
	 , strCustomerName					= CUSTOMER.strName
	 , strUserName						= USERNAME.strName
	 , strPONumber						= POS.strPONumber
	 , strInvoiceNumber					= POS.strInvoiceNumber
	 , strCreditMemoNumber 				= POS.strCreditMemoNumber
	 , strComment						= POS.strComment
	 , strBillToLocationName			= CUSTOMER.strBillToLocationName
	 , strBillToAddress					= CUSTOMER.strBillToAddress
	 , strBillToCity					= CUSTOMER.strBillToCity
	 , strBillToCountry					= CUSTOMER.strBillToCountry
	 , strBillToState					= CUSTOMER.strBillToState
	 , strBillToZipCode					= CUSTOMER.strBillToZipCode
	 , dblTotal							= POS.dblTotal
	 , dblCreditLimit					= CUSTOMER.dblCreditLimit
	 , dblARBalance						= CUSTOMER.dblARBalance
	 , ysnHold							= POS.ysnHold
	 , ysnReturn						= POS.ysnReturn
	 , ysnPaid							= POS.ysnPaid
	 , ysnMixed							= POS.ysnMixed
	 , ysnTaxExempt						= ISNULL(POS.ysnTaxExempt,0)
	 , intPOSEndOfDayId					= EOD.intPOSEndOfDayId
	 , intCompanyLocationPOSDrawerId	= EOD.intCompanyLocationPOSDrawerId
	 , strEODNo							= EOD.strEODNo
	 , strPOSDrawerName					= PD.strPOSDrawerName
FROM dbo.tblARPOS POS WITH (NOLOCK)
INNER JOIN tblARPOSLog PLOG ON POS.intPOSLogId = PLOG.intPOSLogId
INNER JOIN tblARPOSEndOfDay EOD ON PLOG.intPOSEndOfDayId = EOD.intPOSEndOfDayId
LEFT JOIN tblSMCompanyLocationPOSDrawer PD ON PD.intCompanyLocationPOSDrawerId = EOD.intCompanyLocationPOSDrawerId
INNER JOIN (
	SELECT intEntityCustomerId
		 , intBillToId
		 , intShipToId
		 , dblCreditLimit
		 , dblARBalance
		 , strCreditCode
		 , strName
		 , strBillToLocationName
		 , strBillToAddress
		 , strBillToCity
		 , strBillToCountry
		 , strBillToState
		 , strBillToZipCode
	FROM dbo.vyuARCustomerSearch WITH (NOLOCK)
) CUSTOMER ON POS.intEntityCustomerId = CUSTOMER.intEntityCustomerId
INNER JOIN (
	SELECT intEntityId
		 , strName
	FROM dbo.tblEMEntity WITH (NOLOCK)
) USERNAME ON POS.intEntityUserId = USERNAME.intEntityId