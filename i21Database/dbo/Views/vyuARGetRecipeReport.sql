CREATE VIEW [dbo].[vyuARGetRecipeReport]
AS
SELECT intOneLinePrintId = ISNULL(R.intOneLinePrintId, 1)
     , R.strName	 
	 , SOD.intRecipeId
	 , SOD.intSalesOrderId
	 , dblTotalShipped   = SUM(SOD.dblQtyShipped)
	 , dblTotalOrdered   = SUM(SOD.dblQtyOrdered)
	 , dblTotalPrice	 = SUM(SOD.dblTotal)
FROM tblSOSalesOrderDetail SOD
	INNER JOIN tblMFRecipe R ON SOD.intRecipeId = R.intRecipeId
WHERE ISNULL(SOD.intRecipeId, 0) <> 0
GROUP BY intOneLinePrintId, strName, intSalesOrderId, SOD.intRecipeId