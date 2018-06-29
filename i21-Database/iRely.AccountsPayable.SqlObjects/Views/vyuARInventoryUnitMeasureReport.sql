CREATE VIEW [dbo].[vyuARInventoryUnitMeasureReport]
AS 
SELECT DETAIL.intItemId
	 , DETAIL.intItemUOMId	 
	, dblTotalQtyShipped	= SUM([dbo].[fnARGetInvoiceAmountMultiplier](INV.strTransactionType) * ISNULL(DETAIL.dblQtyShipped, 0))
	, dblTotal				= SUM([dbo].[fnARGetInvoiceAmountMultiplier](INV.strTransactionType) * ISNULL(DETAIL.dblQtyShipped, 0)) * SUM(ISNULL(DETAIL.dblPrice, 0))
	
	 , ITEM.strItemNo
	 , ITEM.strItemDescription
	 , UOM.strUnitMeasure
	 , COMPANY.strCompanyName
	 , COMPANY.strCompanyAddress
FROM dbo.tblARInvoiceDetail DETAIL WITH (NOLOCK)
INNER JOIN (
	SELECT 
		intInvoiceId,
		strTransactionType
	FROM tblARInvoice WITH (NOLOCK)
) INV ON DETAIL.intInvoiceId = INV.intInvoiceId
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
OUTER APPLY (
	SELECT TOP 1 strCompanyName
			   , strCompanyAddress = dbo.[fnARFormatCustomerAddress](NULL, NULL, NULL, strAddress, strCity, strState, strZip, strCountry, NULL, 0) 
	FROM dbo.tblSMCompanySetup WITH (NOLOCK)
) COMPANY
WHERE ISNULL(DETAIL.intItemUOMId, 0) <> 0
GROUP BY DETAIL.intItemId, DETAIL.intItemUOMId, ITEM.strItemNo, ITEM.strItemDescription, UOM.strUnitMeasure, COMPANY.strCompanyName, COMPANY.strCompanyAddress