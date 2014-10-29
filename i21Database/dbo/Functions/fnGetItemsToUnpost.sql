
/**
* This function retrieves all the items it will to unpost. 
* 
* Sample usage: 
*
*	SELECT	B.*
*	FROM	[Module Transaction Table] A CROSS APPLY dbo.fnGetItemsToUnpost(A.inTransactionId, A.intTransactionType) B
* 
*/
CREATE FUNCTION fnGetItemsToUnpost (@intTransactionId AS INT, @intTransactionTypeId AS INT)
RETURNS TABLE  
AS
RETURN 
	SELECT	intItemId
			,intItemLocationId
			,dtmDate
			,dblUnitQty
			,dblUOMQty
			,dblCost
			,dblSalesPrice
			,intCurrencyId
			,dblExchangeRate
			,intTransactionId
			,strTransactionId
			,intTransactionTypeId
			,intLotId 
	FROM	tblICInventoryTransaction
	WHERE	intTransactionId = @intTransactionId
			AND intTransactionTypeId = @intTransactionTypeId
GO
