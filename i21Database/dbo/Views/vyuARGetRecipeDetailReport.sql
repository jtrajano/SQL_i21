CREATE VIEW [dbo].[vyuARGetRecipeDetailReport]
AS 
SELECT RECIPEITEMS.* 
	 , intOneLinePrintId = ISNULL(R.intOneLinePrintId, 1)
	 , R.strName
	 , R.ysnActive
	 , I.strItemNo
	 , UOM.strUnitMeasure 
FROM
	(SELECT strTransactionType		= 'Sales Order'
		  , intTransactionId		= intSalesOrderId
		  , intTransactionDetailId	= intSalesOrderDetailId
		  , intRecipeId
		  , intItemId
		  , intItemUOMId
		  , strItemDescription
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
		 , intTransactionDetailId	= intInvoiceDetailId
		 , intRecipeId
		 , intItemId
		 , intItemUOMId
		 , strItemDescription
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
	tblICItem I 
		ON RECIPEITEMS.intItemId = I.intItemId
LEFT JOIN 
	vyuARItemUOM UOM 
		ON RECIPEITEMS.intItemUOMId = UOM.intItemUOMId 
		AND RECIPEITEMS.intItemId = UOM.intItemId