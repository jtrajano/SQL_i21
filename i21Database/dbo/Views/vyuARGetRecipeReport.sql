CREATE VIEW [dbo].[vyuARGetRecipeReport]
AS
SELECT RECIPEITEMS.strTransactionType
	 , RECIPEITEMS.intTransactionId
	 , RECIPEITEMS.intRecipeId
	 , intOneLinePrintId = ISNULL(R.intOneLinePrintId, 1)
	 , strName			 = R.strName	 
	 , dblTotalShipped   = SUM(RECIPEITEMS.dblQtyShipped)
	 , dblTotalOrdered   = SUM(RECIPEITEMS.dblQtyOrdered)
	 , dblDiscount		 = SUM(RECIPEITEMS.dblDiscount)
	 , dblTotalTax		 = SUM(RECIPEITEMS.dblTotalTax)
	 , dblTotalPrice	 = SUM(RECIPEITEMS.dblTotal)
	 , strUnitMeasure	 = ISNULL(UOM.strUnitMeasure, RUOM.strUnitMeasure)
FROM
(SELECT strTransactionType		= 'Sales Order'
	 , intTransactionId			= intSalesOrderId	 
	 , intRecipeId
	 , dblQtyOrdered
	 , dblQtyShipped	 
	 , dblDiscount
	 , dblTotalTax
	 , dblPrice
	 , dblTotal
FROM tblSOSalesOrderDetail
	WHERE ISNULL(intRecipeId, 0) <> 0

UNION ALL

SELECT strTransactionType		= 'Invoice'
	 , intTransactionId			= intInvoiceId
	 , intRecipeId
	 , dblQtyOrdered
	 , dblQtyShipped	 
	 , dblDiscount
	 , dblTotalTax
	 , dblPrice
	 , dblTotal	 
FROM tblARInvoiceDetail
	WHERE ISNULL(intRecipeId, 0) <> 0) AS RECIPEITEMS
INNER JOIN 
	tblMFRecipe R 
		ON RECIPEITEMS.intRecipeId = R.intRecipeId
LEFT JOIN
	vyuARItemUOM UOM
		ON R.intItemUOMId = UOM.intItemUOMId
		AND R.intItemId = UOM.intItemId
LEFT JOIN
	tblICUnitMeasure RUOM
		ON R.intMarginUOMId = RUOM.intUnitMeasureId
GROUP BY RECIPEITEMS.strTransactionType
	   , RECIPEITEMS.intTransactionId
	   , RECIPEITEMS.intRecipeId
	   , R.intOneLinePrintId
	   , R.strName
	   , UOM.strUnitMeasure
	   , RUOM.strUnitMeasure