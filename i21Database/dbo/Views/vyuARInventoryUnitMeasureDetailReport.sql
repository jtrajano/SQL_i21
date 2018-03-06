CREATE VIEW [dbo].[vyuARInventoryUnitMeasureDetailReport]
AS 
SELECT INVOICE.intInvoiceId
	 , INVOICE.intEntityCustomerId
	 , INVOICE.strInvoiceNumber
	 , INVOICE.dtmDate
	 , INVOICE.dtmPostDate
	 , CUSTOMER.strCustomerName
	 , CUSTOMER.strCustomerNumber 
	 , DETAIL.intItemId
	 , DETAIL.intItemUOMId	 
	 , dblQtyShipped = [dbo].[fnARGetInvoiceAmountMultiplier](INVOICE.strTransactionType) * DETAIL.dblQtyShipped
	 , dblTotal = [dbo].[fnARGetInvoiceAmountMultiplier](INVOICE.strTransactionType) * DETAIL.dblTotal
	 , ITEM.strItemNo
	 , ITEM.strItemDescription
	 , UOM.strUnitMeasure
	 , COMPANY.strCompanyName
	 , COMPANY.strCompanyAddress
FROM dbo.tblARInvoice INVOICE WITH (NOLOCK)
INNER JOIN (
	SELECT intEntityId			= C.intEntityId
		 , strCustomerNumber	= ISNULL(C.strCustomerNumber, '') + ' - ' + ISNULL(E.strName , '')
		 , strCustomerName		= E.strName
	FROM dbo.tblARCustomer C WITH (NOLOCK)
	INNER JOIN (
		SELECT intEntityId
		     , strName
		FROM dbo.tblEMEntity WITH (NOLOCK)
	) E ON C.intEntityId = E.intEntityId
) CUSTOMER ON INVOICE.intEntityCustomerId = CUSTOMER.intEntityId
INNER JOIN (
	SELECT intInvoiceId
		 , intInvoiceDetailId
		 , intItemId
		 , intItemUOMId
		 , dblQtyShipped
		 , dblPrice
		 , dblTotal		= ISNULL(dblQtyShipped, 0) * ISNULL(dblPrice, 0)
	FROM dbo.tblARInvoiceDetail WITH (NOLOCK)
	WHERE ISNULL(intItemUOMId, 0) <> 0
) DETAIL ON INVOICE.intInvoiceId = DETAIL.intInvoiceId
INNER JOIN (
	SELECT intItemId
		 , strItemNo		  = ISNULL(strItemNo, '') + ' - ' + ISNULL(strDescription, '')
		 , strItemDescription = strDescription
	FROM dbo.tblICItem WITH (NOLOCK)
) ITEM ON DETAIL.intItemId = ITEM.intItemId
INNER JOIN (
	SELECT intItemId
		 , intItemUOMId
		 , intUnitMeasureId
	FROM dbo.tblICItemUOM WITH (NOLOCK)
) ITEMUOM ON DETAIL.intItemUOMId = ITEMUOM.intItemUOMId
	     AND DETAIL.intItemId = ITEMUOM.intItemId
INNER JOIN (
	SELECT intUnitMeasureId
		 , strUnitMeasure
	FROM dbo.tblICUnitMeasure WITH (NOLOCK)
) UOM ON ITEMUOM.intUnitMeasureId = UOM.intUnitMeasureId
OUTER APPLY (
	SELECT TOP 1 strCompanyName
			   , strCompanyAddress = dbo.[fnARFormatCustomerAddress](NULL, NULL, NULL, strAddress, strCity, strState, strZip, strCountry, NULL, 0) 
	FROM dbo.tblSMCompanySetup WITH (NOLOCK)
) COMPANY
WHERE INVOICE.ysnPosted = 1