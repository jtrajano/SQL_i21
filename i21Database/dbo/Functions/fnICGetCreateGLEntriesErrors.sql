/*
* This function will validate the account ids it will use to generate the GL entries. 
* It is a helper function for uspICCreateGLEntries. 
*/
CREATE FUNCTION fnICGetCreateGLEntriesErrors (
	@strBatchId AS NVARCHAR(50) 
	, @AccountCategory_ContraInventory AS NVARCHAR(255) = 'Cost of Goods'
	, @strTransactionId AS NVARCHAR(50) = NULL 
)
RETURNS TABLE 
AS
RETURN (	
	SELECT DISTINCT * 
	FROM (
		-- {Item} in {Location} is missing a GL account setup for {Account Category} account category.
		SELECT	intItemId = Query.intItemId
				,intItemLocationId = Query.intItemLocationId
				,strText = 
					dbo.fnICFormatErrorMessage (
						80008
						,strItemNo  
						,strLocationName  
						,CASE 
							WHEN dbo.fnGetItemGLAccount(Query.intItemId, Query.intItemLocationId, 'Inventory') IS NULL THEN 'Inventory'
							WHEN dbo.fnGetItemGLAccount(Query.intItemId, Query.intItemLocationId, @AccountCategory_ContraInventory) IS NULL THEN @AccountCategory_ContraInventory
							WHEN dbo.fnGetItemGLAccount(Query.intItemId, Query.intItemLocationId, 'Inventory Adjustment') IS NULL THEN 'Inventory Adjustment'
						END  
						,DEFAULT 
						,DEFAULT 
						,DEFAULT 
						,DEFAULT 
						,DEFAULT 
						,DEFAULT 
						,DEFAULT 
					) 
				,intErrorCode = 80008
		FROM	(
			SELECT	DISTINCT 
					t.intItemId
					,il.intItemLocationId
					,t.intTransactionTypeId
					,i.strItemNo
					,cl.strLocationName  					
			FROM	dbo.tblICInventoryTransaction t LEFT JOIN tblICItemLocation il 
						ON il.intItemLocationId = ISNULL(t.intInTransitSourceLocationId, t.intItemLocationId) 
					LEFT JOIN tblICItem i 
						ON i.intItemId = t.intItemId 
					LEFT JOIN tblSMCompanyLocation cl
						ON cl.intCompanyLocationId = il.intLocationId
			WHERE	t.strBatchId = @strBatchId
					AND t.strTransactionId = ISNULL(@strTransactionId, t.strTransactionId) 
		) Query
		WHERE 
			dbo.fnGetItemGLAccount(Query.intItemId, Query.intItemLocationId, 'Inventory') IS NULL 
			OR dbo.fnGetItemGLAccount(Query.intItemId, Query.intItemLocationId, @AccountCategory_ContraInventory) IS NULL 
			OR (
				dbo.fnGetItemGLAccount(Query.intItemId, Query.intItemLocationId, 'Inventory Adjustment') IS NULL 
				AND Query.intTransactionTypeId IN (1, 35) -- (1) Auto Variance. (35) Auto Variance on Sold or Used Stock. 
			)
	) AS Query		
)
