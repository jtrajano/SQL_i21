CREATE VIEW [dbo].[vyuARInventoryUnitMeasureReport]
AS 
SELECT DETAIL.intItemId
	 , DETAIL.intItemUOMId	 
	 , dblTotalQtyShipped	= SUM(ISNULL(DETAIL.dblQtyShipped, 0))
	 , dblTotal				= SUM(ISNULL(DETAIL.dblTotal, 0))
	 , ITEM.strItemNo
	 , ITEM.strItemDescription
	 , UOM.strUnitMeasure
FROM dbo.tblARInvoiceDetail DETAIL WITH (NOLOCK)
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
WHERE ISNULL(DETAIL.intItemUOMId, 0) <> 0
GROUP BY DETAIL.intItemId, DETAIL.intItemUOMId, ITEM.strItemNo, ITEM.strItemDescription, UOM.strUnitMeasure