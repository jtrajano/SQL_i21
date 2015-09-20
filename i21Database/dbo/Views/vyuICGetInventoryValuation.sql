CREATE VIEW [dbo].[vyuICGetInventoryValuation]
	AS

SELECT TOP 100 PERCENT
	intInventoryValuationKeyId = CAST(ROW_NUMBER() OVER(ORDER BY [Transaction].intItemId, [Transaction].dtmDate DESC, [Transaction].intTransactionId DESC) AS INT),
	[Transaction].intItemId,
	strItemNo = Item.strItemNo,
	strItemDescription = Item.strDescription,
	Item.intCategoryId,
	strCategroy = Category.strCategoryCode,
	[Transaction].intItemLocationId,
	Location.strLocationName,
	[Transaction].intSubLocationId,
	SubLocation.strSubLocationName,
	[Transaction].intStorageLocationId,
	strStorageLocationName = StorageLocation.strName,
	[Transaction].dtmDate,
	[Transaction].strTransactionForm,
	[Transaction].strTransactionId,
	dblQuantity = [Transaction].dblQty * [Transaction].dblUOMQty,
	dblCost = [Transaction].dblCost,
	dblValue = [Transaction].dblQty * [Transaction].dblUOMQty * [Transaction].dblCost,
	strBatchId
FROM tblICInventoryTransaction [Transaction]
LEFT JOIN tblICItem Item ON Item.intItemId = [Transaction].intItemId
LEFT JOIN tblICCategory Category ON Category.intCategoryId = Item.intCategoryId
LEFT JOIN tblICItemLocation ItemLocation ON ItemLocation.intItemLocationId = [Transaction].intItemLocationId
LEFT JOIN tblSMCompanyLocation Location ON Location.intCompanyLocationId = ItemLocation.intLocationId
LEFT JOIN tblSMCompanyLocationSubLocation SubLocation ON SubLocation.intCompanyLocationSubLocationId = [Transaction].intSubLocationId
LEFT JOIN tblICStorageLocation StorageLocation ON StorageLocation.intStorageLocationId = [Transaction].intStorageLocationId
ORDER BY [Transaction].intItemId, [Transaction].dtmDate DESC, [Transaction].intTransactionId DESC