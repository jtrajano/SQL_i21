﻿/**
* This function retrieves all the items it will to unpost. 
* 
* Sample usage: 
*
*	SELECT	B.*
*	FROM	[Module Transaction Table] A CROSS APPLY dbo.fnGetItemsToUnpost(A.inTransactionId, A.intTransactionType) B
*
* This is going to be used in uspICUnpostCosting. Records in the ItemCostingTableType will cross apply in this function to 
* get the actual items to unpost.  
* 
*/
CREATE FUNCTION fnGetItemsToUnpost (@intTransactionId AS INT, @intTransactionTypeId AS INT)
RETURNS TABLE  
AS
RETURN 
	SELECT	intItemId
			,intItemLocationId
			,intItemUOMId
			,dtmDate
			,dblQty
			,dblUOMQty
			,dblCost
			,dblValue 
			,dblSalesPrice
			,intCurrencyId
			,dblExchangeRate
			,intTransactionId
			,intTransactionDetailId
			,strTransactionId
			,intTransactionTypeId
			,intLotId 
			,intSubLocationId
			,intStorageLocationId
	FROM	tblICInventoryTransaction
	WHERE	intTransactionId = @intTransactionId
			AND intTransactionTypeId = @intTransactionTypeId
GO
