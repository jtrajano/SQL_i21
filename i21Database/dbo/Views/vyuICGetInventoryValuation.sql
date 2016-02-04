CREATE VIEW [dbo].[vyuICGetInventoryValuation]
	AS

SELECT TOP 100 PERCENT
	intInventoryValuationKeyId = CAST(ROW_NUMBER() OVER (ORDER BY [Transaction].intItemId, [Transaction].dtmDate DESC) AS INT)
	,[Transaction].intInventoryTransactionId
	,[Transaction].intItemId
	,strItemNo 
	,strItemDescription = Item.strDescription
	,Item.intCategoryId
	,strCategory = Category.strCategoryCode
	,[Transaction].intItemLocationId
	,Location.strLocationName
	,[Transaction].intSubLocationId
	,SubLocation.strSubLocationName
	,[Transaction].intStorageLocationId
	,strStorageLocationName = StorageLocation.strName
	,[Transaction].dtmDate
	,strTransactionType = TransactionType.strName
	,[Transaction].strTransactionForm
	,[Transaction].strTransactionId
	,dblBeginningQtyBalance = CAST(0 AS NUMERIC(38, 20))
	,dblQuantity = [Transaction].dblQty * [Transaction].dblUOMQty
	,dblRunningQtyBalance = CAST(0 AS NUMERIC(38, 20))
	,dblCost = [Transaction].dblCost
	,dblBeginningBalance = CAST(0 AS NUMERIC(38, 20)) 
	,dblValue = ISNULL([Transaction].dblQty, 0) * ISNULL([Transaction].dblCost, 0) + ISNULL([Transaction].dblValue, 0)
	,dblRunningBalance = CAST(0 AS NUMERIC(38, 20))
	,strBatchId
FROM tblICInventoryTransaction [Transaction] LEFT JOIN tblICItem Item 
		ON Item.intItemId = [Transaction].intItemId
	LEFT JOIN tblICCategory Category 
		ON Category.intCategoryId = Item.intCategoryId
	LEFT JOIN tblICItemLocation ItemLocation 
		ON ItemLocation.intItemLocationId = [Transaction].intItemLocationId
	LEFT JOIN tblSMCompanyLocation Location 
		ON Location.intCompanyLocationId = ItemLocation.intLocationId
	LEFT JOIN tblSMCompanyLocationSubLocation SubLocation 
		ON SubLocation.intCompanyLocationSubLocationId = [Transaction].intSubLocationId
	LEFT JOIN tblICStorageLocation StorageLocation 
		ON StorageLocation.intStorageLocationId = [Transaction].intStorageLocationId
	LEFT JOIN tblICInventoryTransactionType TransactionType 
		ON TransactionType.intTransactionTypeId = [Transaction].intTransactionTypeId
