CREATE VIEW [dbo].[vyuICGetInventoryValuation]
AS

SELECT       
			  CASE 
				WHEN [Transaction].intInventoryTransactionId IS NULL
				THEN CAST(ROW_NUMBER() OVER (ORDER BY [Transaction].intInventoryTransactionId) AS INT)
				ELSE [Transaction].intInventoryTransactionId
			  END 
			  AS intInventoryValuationKeyId,
			  CASE 
				WHEN [Transaction].intInventoryTransactionId IS NULL
				THEN CAST(ROW_NUMBER() OVER (ORDER BY [Transaction].intInventoryTransactionId) AS INT)
				ELSE [Transaction].intInventoryTransactionId
			  END 
			  AS intInventoryTransactionId,
			  ISNULL([Transaction].intItemId, 0) AS intItemId,
			  Item.strItemNo, 
			  Item.strDescription AS strItemDescription, 
              Item.intCategoryId, 
			  Category.strCategoryCode AS strCategory, 
			  ISNULL([Transaction].intItemLocationId, 0) AS intItemLocationId, 
			  ISNULL(Location.strLocationName, ' ') AS strLocationName, 
			  ISNULL([Transaction].intSubLocationId, 0) AS intSubLocationId, 
			  ISNULL(SubLocation.strSubLocationName, ' ') AS strSubLocationName, 
              ISNULL([Transaction].intStorageLocationId, 0) AS intStorageLocationId, 
			  ISNULL(StorageLocation.strName, ' ') AS strStorageLocationName, 
			  dbo.fnRemoveTimeOnDate([Transaction].dtmDate) AS dtmDate, 
			  ISNULL(TransactionType.strName, ' ') AS strTransactionType, 
              ISNULL([Transaction].strTransactionForm, ' ') AS strTransactionForm, 
			  ISNULL([Transaction].strTransactionId, ' ') AS strTransactionId, 
			  CAST(0 AS NUMERIC(38, 20)) AS dblBeginningQtyBalance, 
			  ISNULL([Transaction].dblQty, 0) AS dblQuantity, 
			  CAST(0 AS NUMERIC(38, 20)) AS dblRunningQtyBalance, 
			  ISNULL([Transaction].dblCost, 0) AS dblCost, 
			  CAST(0 AS NUMERIC(38, 20)) AS dblBeginningBalance, 
			  ISNULL([Transaction].dblQty, 0) * ISNULL([Transaction].dblCost, 0) + ISNULL([Transaction].dblValue, 0) AS dblValue, 
			  CAST(0 AS NUMERIC(38, 20)) AS dblRunningBalance, 
			  ISNULL([Transaction].strBatchId, ' ') AS strBatchId

FROM					 
			   dbo.tblICItem AS Item  LEFT OUTER JOIN
			   dbo.tblICInventoryTransaction AS [Transaction] ON [Transaction].intItemId = Item.intItemId LEFT OUTER JOIN
			   dbo.tblICCategory AS Category ON Category.intCategoryId = Item.intCategoryId LEFT OUTER JOIN
               dbo.tblICItemLocation AS ItemLocation ON ItemLocation.intItemLocationId = [Transaction].intItemLocationId LEFT OUTER JOIN
               dbo.tblSMCompanyLocation AS Location ON Location.intCompanyLocationId = ItemLocation.intLocationId LEFT OUTER JOIN
               dbo.tblSMCompanyLocationSubLocation AS SubLocation ON SubLocation.intCompanyLocationSubLocationId = [Transaction].intSubLocationId LEFT OUTER JOIN
               dbo.tblICStorageLocation AS StorageLocation ON StorageLocation.intStorageLocationId = [Transaction].intStorageLocationId LEFT OUTER JOIN
               dbo.tblICInventoryTransactionType AS TransactionType ON TransactionType.intTransactionTypeId = [Transaction].intTransactionTypeId