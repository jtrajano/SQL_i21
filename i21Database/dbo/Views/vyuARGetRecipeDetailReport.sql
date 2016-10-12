CREATE VIEW [dbo].[vyuARGetRecipeDetailReport]
AS 
SELECT RECIPEITEMS.* 
	 , intOneLinePrintId			= ISNULL(R.intOneLinePrintId, 1)
	 , R.strName
	 , R.ysnActive
	 , strItem						= CASE WHEN ISNULL(RECIPEITEMS.intCommentTypeId, 0) = 0 THEN 
												CASE WHEN ISNULL(I.strItemNo, '') = '' THEN RECIPEITEMS.strItemDescription ELSE LTRIM(RTRIM(I.strItemNo)) + ' - ' + ISNULL(RECIPEITEMS.strItemDescription, '') END 
										   ELSE 
												RECIPEITEMS.strItemDescription 
									  END
	 , strItemNo					= CASE WHEN ISNULL(RECIPEITEMS.intCommentTypeId, 0) = 0 THEN I.strItemNo ELSE NULL END
	 , I.strInvoiceComments
	 , UOM.strUnitMeasure 
FROM
	(SELECT strTransactionType		= 'Sales Order'
		  , intTransactionId		= intSalesOrderId
		  , intTransactionDetailId	= intSalesOrderDetailId
		  , intCommentTypeId
		  , intRecipeId
		  , intItemId
		  , intItemUOMId
		  , strItemDescription
		  , dblQtyOrdered			= CASE WHEN ISNULL(intCommentTypeId, 0) = 0 THEN dblQtyOrdered ELSE NULL END
		  , dblQtyShipped			= CASE WHEN ISNULL(intCommentTypeId, 0) = 0 THEN dblQtyShipped ELSE NULL END
		  , dblDiscount				= CASE WHEN ISNULL(intCommentTypeId, 0) = 0 THEN ISNULL(dblDiscount, 0) / 100 ELSE NULL END
		  , dblTotalTax				= CASE WHEN ISNULL(intCommentTypeId, 0) = 0 THEN dblTotalTax ELSE NULL END
		  , dblPrice				= NULL
		  , dblTotal				= NULL
	FROM tblSOSalesOrderDetail
		WHERE ISNULL(intRecipeId, 0) <> 0

	UNION ALL

	SELECT strTransactionType		= 'Invoice'
		 , intTransactionId			= intInvoiceId
		 , intTransactionDetailId	= intInvoiceDetailId
		 , intCommentTypeId
		 , intRecipeId		 
		 , intItemId
		 , intItemUOMId
		 , strItemDescription
		 , dblQtyOrdered			= CASE WHEN ISNULL(intCommentTypeId, 0) = 0 THEN dblQtyOrdered ELSE NULL END
		 , dblQtyShipped			= CASE WHEN ISNULL(intCommentTypeId, 0) = 0 THEN dblQtyShipped ELSE NULL END
		 , dblDiscount				= CASE WHEN ISNULL(intCommentTypeId, 0) = 0 THEN ISNULL(dblDiscount, 0) / 100 ELSE NULL END
		 , dblTotalTax				= CASE WHEN ISNULL(intCommentTypeId, 0) = 0 THEN dblTotalTax ELSE NULL END
		 , dblPrice					= NULL
		 , dblTotal					= NULL
	FROM tblARInvoiceDetail
		WHERE ISNULL(intRecipeId, 0) <> 0 
		  AND intCommentTypeId <> 2) AS RECIPEITEMS
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