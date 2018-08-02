CREATE VIEW [dbo].[vyuARSearchPOSDetail]
AS 
SELECT intPOSId					= POS.intPOSId
	 , intEntityCustomerId		= POS.intEntityCustomerId
	 , intBillToId				= CUSTOMER.intBillToId
	 , intShipToId				= CUSTOMER.intShipToId
	 , dtmDate					= POS.dtmDate
	 , strReceiptNumber			= POS.strReceiptNumber
	 , strCustomerName			= CUSTOMER.strName
	 , strUserName				= USERNAME.strName
	 , strBillToLocationName	= CUSTOMER.strBillToLocationName
	 , strBillToAddress			= CUSTOMER.strBillToAddress
	 , strBillToCity			= CUSTOMER.strBillToCity
	 , strBillToCountry			= CUSTOMER.strBillToCountry
	 , strBillToState			= CUSTOMER.strBillToState
	 , strBillToZipCode			= CUSTOMER.strBillToZipCode
	 , dblTotal					= POS.dblTotal
	 , dblCreditLimit			= CUSTOMER.dblCreditLimit
	 , dblARBalance				= CUSTOMER.dblARBalance
	 , ysnHold					= POS.ysnHold
	 , ysnReturn				= POS.ysnReturn
	 , intPOSDetailId			= POSDetail.intPOSDetailId
	 , intItemId				= POSDetail.intItemId
	 , strItemNo				= POSDetail.strItemNo
	 , strItemDescription		= POSDetail.strItemDescription
	 , dblQuantity				= POSDetail.dblQuantity
	 , intItemUOMId				= POSDetail.intItemUOMId
	 , strItemUOM				= POSDetail.strItemUOM
	 , dblDiscount				= POSDetail.dblDiscount
	 , dblDiscountPercent		= POSDetail.dblDiscountPercent
	 , dblPrice					= POSDetail.dblPrice
	 , dblTax					= POSDetail.dblTax
	 , dblExtendedPrice			= POSDetail.dblExtendedPrice
	 , ysnPaid					= CASE WHEN POS.intInvoiceId IS NOT NULL THEN CAST(1 AS BIT) ELSE CAST(0 AS BIT) END
FROM dbo.tblARPOS POS WITH (NOLOCK)
INNER JOIN (
	SELECT intEntityCustomerId
		 , intBillToId
		 , intShipToId
		 , dblCreditLimit
		 , dblARBalance
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
INNER JOIN (
	SELECT intPOSDetailId,
			intPOSId,
			intItemId,
			strItemNo,
			strItemDescription,
			dblQuantity,
			intItemUOMId,
			strItemUOM,
			dblDiscount,
			dblDiscountPercent,
			dblPrice,
			dblTax,
			dblExtendedPrice
	FROM dbo.tblARPOSDetail
) POSDetail ON POS.intPOSId = POSDetail.intPOSId