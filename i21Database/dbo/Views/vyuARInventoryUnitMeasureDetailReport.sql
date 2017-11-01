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
	 , DETAIL.dblQtyShipped
	 , DETAIL.dblTotal
	 , ITEM.strItemNo
	 , ITEM.strItemDescription
	 , UOM.strUnitMeasure
FROM dbo.tblARInvoice INVOICE WITH (NOLOCK)
INNER JOIN (
	SELECT intEntityId			= C.intEntityId
		 , strCustomerNumber	= C.strCustomerNumber
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
		 , dblTotal
	FROM dbo.tblARInvoiceDetail WITH (NOLOCK)
	WHERE ISNULL(intItemUOMId, 0) <> 0
) DETAIL ON INVOICE.intInvoiceId = DETAIL.intInvoiceId
INNER JOIN (
	SELECT intItemId
		 , strItemNo
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
WHERE INVOICE.ysnPosted = 1