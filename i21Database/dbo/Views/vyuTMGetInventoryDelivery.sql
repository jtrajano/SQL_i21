CREATE VIEW [dbo].[vyuTMGetInventoryDelivery]
AS

SELECT 
	A.intInventoryTransactionId
	,A.strTransactionId
	,B.strItemNo
	,A.dtmDate
	,strItemDescription = B.strDescription
	,strTransactionType	= E.strName
	,A.intTransactionId
	,intLocationId = A.intCompanyLocationId
	,A.intSubLocationId
	,A.intItemId
	,dblQuantity = A.dblQty
	,A.intStorageLocationId
	,A.strTransactionForm
FROM tblICInventoryTransaction A
INNER JOIN tblICItem B 
	ON A.intItemId = B.intItemId
INNER JOIN tblICItemUOM C 		
	ON C.intItemId = B.intItemId
	AND C.ysnStockUnit = 1 
INNER JOIN tblICUnitMeasure D
	ON D.intUnitMeasureId = C.intUnitMeasureId 
LEFT JOIN tblICInventoryTransactionType E 
			ON E.intTransactionTypeId = A.intTransactionTypeId
WHERE (A.ysnIsUnposted = 0 OR A.ysnIsUnposted IS NULL)

GO