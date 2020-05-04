﻿CREATE FUNCTION fnGetItemCostingOnPostErrors (
	@intItemId AS INT
	, @intItemLocationId AS INT
	, @intItemUOMId AS INT
	, @intSubLocationId AS INT
	, @intStorageLocationId AS INT
	, @dblQty AS NUMERIC(38,20) = 0
	, @intLotId AS INT
	, @strActualCostId AS NVARCHAR(50)
	, @intTransactionTypeId AS INT  
	, @strTransactionId AS NVARCHAR(50) 
	, @intCurrencyId AS INT 
	, @dblForexRate AS NUMERIC(18, 6) = 0.00 
	, @dblCost AS NUMERIC(38, 20) = 0.00 
)
RETURNS TABLE 
AS
/**
* This function will centralize the validation for each items. This is used prior to posting a transaction. 
* 
* Sample usage: 
*
*	SELECT	B.*
*	FROM	tblICItemLocation A CROSS APPLY dbo.fnGetItemCostingOnPostErrors(A.intItemId, A.intLocationId, A.intItemUOMId, A.dblQty) B
* 
*/
RETURN (
	
	SELECT DISTINCT * 
	FROM (
		-- Check for any invalid item.
		SELECT	intItemId = @intItemId
				,intItemLocationId = @intItemLocationId
				,strText = dbo.fnICGetErrorMessage(80001) -- 'Item id is invalid or missing.'
				,intErrorCode = 80001
		WHERE	NOT EXISTS (
					SELECT TOP 1 1 
					FROM	tblICItem 
					WHERE	intItemId = @intItemId
				)

		-- Check for any invalid item location 
		UNION ALL 
		SELECT	intItemId = @intItemId
				,intItemLocationId = @intItemLocationId
				,strText = dbo.fnICGetErrorMessage(80002) -- 'Item Location is invalid or missing for %s.'
				,intErrorCode = 80002
		WHERE	NOT EXISTS (
					SELECT TOP 1 1 
					FROM	dbo.tblICItemLocation
					WHERE	intItemLocationId = @intItemLocationId
							AND intItemId = @intItemId
				)
				AND @intItemId IS NOT NULL 	
	
		-- Check for invalid item UOM Id
		UNION ALL 
		SELECT	intItemId = @intItemId
				,intItemLocationId = @intItemLocationId
				,strText = 'Item UOM is invalid or missing for <b>' + (SELECT ISNULL(strItemNo, '') FROM tblICItem WHERE intItemId = @intItemId) + '</b>.'
					+ ISNULL((SELECT TOP 1 ' Make sure the UOM of this item is also properly set up in <b>"' + strBundleItemNo + '"</b> bundle.' FROM vyuICGetInvalidBundleItemUom WHERE intBundleItemId = @intItemId), '')
				,intErrorCode = 80048
		WHERE	NOT EXISTS (
					SELECT TOP 1 1 
					FROM	dbo.tblICItemUOM 
					WHERE	intItemId = @intItemId
							AND intItemUOMId = @intItemUOMId
				)
				AND @intItemId IS NOT NULL 	
				AND @intItemUOMId IS NOT NULL


		UNION ALL
		SELECT
			intItemId = @intItemId
			,intItemLocationId = @intItemLocationId
			,strText = dbo.fnICGetErrorMessage(80231)
			,intErrorCode = 80231
		FROM tblICItemUOM u
		WHERE u.intItemId = @intItemId
			AND u.ysnStockUnit = 1
			AND u.dblUnitQty = 1
		HAVING COUNT(u.intItemUOMId) > 1

		-- Check for missing costing method. 
		UNION ALL 
		SELECT	intItemId = @intItemId
				,intItemLocationId = @intItemLocationId
				,strText = dbo.fnFormatMessage(
							dbo.fnICGetErrorMessage(80023)
							, Item.strItemNo
							, DEFAULT
							, DEFAULT
							, DEFAULT
							, DEFAULT
							, DEFAULT
							, DEFAULT
							, DEFAULT
							, DEFAULT
							, DEFAULT
						) 
				,intErrorCode = 80023
		FROM	dbo.tblICItem Item INNER JOIN dbo.tblICItemLocation ItemLocation 
					ON Item.intItemId = ItemLocation.intItemId
		WHERE	ISNULL(dbo.fnGetCostingMethod(ItemLocation.intItemId, ItemLocation.intItemLocationId), 0) = 0 
				AND ItemLocation.intItemId = @intItemId 
				AND ItemLocation.intItemLocationId = @intItemLocationId

		-- Check for "Discontinued" status. Do not allow use of that item even if there are stocks on it. 
		UNION ALL 
		SELECT	intItemId = @intItemId
				,intItemLocationId = @intItemLocationId
				,strText = dbo.fnFormatMessage(
							dbo.fnICGetErrorMessage(80022)
							, Item.strItemNo
							, DEFAULT
							, DEFAULT
							, DEFAULT
							, DEFAULT
							, DEFAULT
							, DEFAULT
							, DEFAULT
							, DEFAULT
							, DEFAULT
						) 
				,intErrorCode = 80022				
		FROM	tblICItem Item
		WHERE	Item.intItemId = @intItemId
				AND Item.strStatus = 'Discontinued'

		-- Check for negative stock and if negative stock is NOT allowed. 
		-- and do not allow negative stock on items being phased-out. 
		-- 'Negative stock quantity is not allowed for {Item Name} on {Location Name}, {Storage Location Name}, and {Storage Unit Name}.'
		UNION ALL 
		SELECT	intItemId = @intItemId
				,intItemLocationId = @intItemLocationId
				,strText = dbo.fnFormatMessage(
								dbo.fnICGetErrorMessage(80003)
								,(SELECT strItemNo FROM dbo.tblICItem WHERE intItemId = @intItemId)
								,dbo.fnFormatMsg80003(
									@intItemLocationId
									,@intSubLocationId
									,@intStorageLocationId
								)
								, DEFAULT
								, DEFAULT
								, DEFAULT
								, DEFAULT
								, DEFAULT
								, DEFAULT
								, DEFAULT
								, DEFAULT
							)
				,intErrorCode = 80003
		WHERE	EXISTS (
					SELECT	TOP 1 1
					FROM	dbo.tblICItem Item INNER JOIN dbo.tblICItemLocation Location
								ON Item.intItemId = @intItemId
								AND Location.intItemLocationId = @intItemLocationId
							LEFT JOIN dbo.tblICItemStockUOM StockUOM
								ON StockUOM.intItemId = Item.intItemId
								AND StockUOM.intItemUOMId = @intItemUOMId
								AND StockUOM.intItemLocationId = Location.intItemLocationId
								AND ISNULL(StockUOM.intSubLocationId, 0) = ISNULL(@intSubLocationId, 0)
								AND ISNULL(StockUOM.intStorageLocationId, 0) = ISNULL(@intStorageLocationId, 0)
					WHERE	ROUND(ISNULL(@dblQty, 0) + ISNULL(StockUOM.dblOnHand, 0) - ISNULL(StockUOM.dblUnitReserved, 0), 4) < 0
							AND (							
								Location.intAllowNegativeInventory = 3 -- Value 3 means "NO", Negative stock is NOT allowed. 
								OR Item.strStatus = 'Phased Out'
							)
							AND @dblQty < 0							
				)

		-- Check for negative stocks at the lot table. 
		-- and do not allow negative stock on items being phased-out. 
		-- 'Negative stock quantity is not allowed for {Item Name} on {Location Name}, {Sub Location Name}, and {Storage Location Name}.'
		UNION ALL 
		SELECT	intItemId = @intItemId
				,intItemLocationId = @intItemLocationId
				,strText =	dbo.fnFormatMessage(
								dbo.fnICGetErrorMessage(80003)
								,(SELECT strItemNo FROM dbo.tblICItem WHERE intItemId = @intItemId)
								,dbo.fnFormatMsg80003(
									@intItemLocationId
									,@intSubLocationId
									,@intStorageLocationId
								)
								, DEFAULT
								, DEFAULT
								, DEFAULT
								, DEFAULT
								, DEFAULT
								, DEFAULT
								, DEFAULT
								, DEFAULT
							)
				,intErrorCode = 80003
		WHERE	EXISTS (
					SELECT	TOP 1 1
					FROM	dbo.tblICItem Item INNER JOIN dbo.tblICItemLocation Location
								ON Item.intItemId = @intItemId
								AND Location.intItemLocationId = @intItemLocationId
							LEFT JOIN dbo.tblICLot Lot
								ON Lot.intItemLocationId = Location.intItemLocationId 
								AND ISNULL(Lot.intLotId, 0) = ISNULL(@intLotId, 0)								
								AND Lot.intItemUOMId = @intItemUOMId
					WHERE	Item.intItemId = @intItemId
							AND Lot.intLotId IS NOT NULL
							AND ROUND(ISNULL(@dblQty, 0) + ISNULL(Lot.dblQty, 0), 4) < 0
							AND (							
								Location.intAllowNegativeInventory = 3 -- Value 3 means "NO", Negative stock is NOT allowed. 
								OR Item.strStatus = 'Phased Out'
							)		
				)

		-- Check for negative stocks at the lot table. 
		-- and do not allow negative stock on items being phased-out. 
		-- 'Negative stock quantity is not allowed for {Item Name} on {Location Name}, {Storage Location Name}, and {Storage Unit Name}.'
		UNION ALL 
		SELECT	intItemId = @intItemId
				,intItemLocationId = @intItemLocationId
				,strText =	dbo.fnFormatMessage(
								dbo.fnICGetErrorMessage(80003)
								,(SELECT strItemNo FROM dbo.tblICItem WHERE intItemId = @intItemId)
								,dbo.fnFormatMsg80003(
									@intItemLocationId
									,@intSubLocationId
									,@intStorageLocationId
								)
								, DEFAULT
								, DEFAULT
								, DEFAULT
								, DEFAULT
								, DEFAULT
								, DEFAULT
								, DEFAULT
								, DEFAULT
							)
				,intErrorCode = 80003
		WHERE	EXISTS (
					SELECT	TOP 1 1
					FROM	dbo.tblICItem Item INNER JOIN dbo.tblICItemLocation Location
								ON Item.intItemId = @intItemId
								AND Location.intItemLocationId = @intItemLocationId
							LEFT JOIN dbo.tblICLot Lot
								ON Lot.intItemLocationId = Location.intItemLocationId 
								AND ISNULL(Lot.intLotId, 0) = ISNULL(@intLotId, 0)								
								AND Lot.intWeightUOMId = @intItemUOMId
					WHERE	Item.intItemId = @intItemId
							AND Lot.intLotId IS NOT NULL
							AND ROUND(ISNULL(@dblQty, 0) + ISNULL(Lot.dblWeight, 0), 4) < 0
							AND (							
								Location.intAllowNegativeInventory = 3 -- Value 3 means "NO", Negative stock is NOT allowed. 
								OR Item.strStatus = 'Phased Out'
							)		
				)

		-- Check for the missing Stock Unit UOM 
		UNION ALL 
		SELECT	intItemId = @intItemId
				,intItemLocationId = @intItemLocationId
				,strText = dbo.fnFormatMessage(dbo.fnICGetErrorMessage(80049), i.strItemNo, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT)
				,intErrorCode = 80049
		FROM	tblICItem i 
		WHERE	i.intItemId = @intItemId
				AND dbo.fnGetItemStockUOM(@intItemId) IS NULL 
				AND @intItemId IS NOT NULL
				AND i.strType <> 'Non-Inventory'

		-- Check for locked inventory. 
		-- Inventory count ongoing. 
		UNION ALL 
		SELECT	intItemId = @intItemId
				,intItemLocationId = @intItemLocationId
				,strText = dbo.fnFormatMessage(
								dbo.fnICGetErrorMessage(locked.intError)
								,locked.strItemNo
								,locked.strText
								, DEFAULT
								, DEFAULT
								, DEFAULT
								, DEFAULT
								, DEFAULT
								, DEFAULT
								, DEFAULT
								, DEFAULT
							)
				,intErrorCode = locked.intError
		FROM (
					-- Validate Locked Company Locations
					SELECT	TOP 1
						intError = 80066
						,i.strItemNo
						,strText = cl.strLocationName
					FROM	
						dbo.tblICItem i INNER JOIN dbo.tblICItemLocation il
							ON i.intItemId = il.intItemId
						INNER JOIN tblSMCompanyLocation cl 
							ON cl.intCompanyLocationId = il.intLocationId
					WHERE	
						ysnLockedInventory = 1
						AND i.intItemId = @intItemId
						AND il.intItemLocationId = @intItemLocationId					

					-- Validate Locked Sub Locations
					UNION ALL 
					SELECT	TOP 1 
						intError = 80239
						,i.strItemNo
						,strText = csl.strSubLocationName
					FROM	
						tblICItem i INNER JOIN (
							tblICLockedSubLocation ll INNER JOIN tblSMCompanyLocationSubLocation csl 
								ON csl.intCompanyLocationSubLocationId = ll.intSubLocationId
						)
							ON i.intItemId = ll.intItemId 
					WHERE 
						i.intItemId = @intItemId
						AND ll.intSubLocationId = @intSubLocationId
											
					-- Validate Locked Storage Locations
					UNION ALL 
					SELECT TOP 1 
						intError = 80240
						,i.strItemNo
						,strText = sl.strName
					FROM 
						tblICItem i INNER JOIN (
							tblICLockedStorageLocation ll INNER JOIN tblICStorageLocation sl 
								ON sl.intStorageLocationId = ll.intStorageLocationId
						)
							ON i.intItemId = ll.intItemId
					WHERE 
						i.intItemId = @intItemId
						AND sl.intSubLocationId = @intSubLocationId
						AND sl.intStorageLocationId = @intStorageLocationId
					
					-- Validate Locked Lots
					UNION ALL 
					SELECT TOP 1 
						intError = 80241
						,i.strItemNo
						,strText = l.strLotNumber
					FROM 
						tblICLot l INNER JOIN tblICItem i 
							ON l.intItemId = i.intItemId
					WHERE 
						l.intLotId = @intLotId
						AND l.ysnLockedInventory = 1
		) locked


		/*
			Check if the item is using Average Costing and the transaction is Actual Costing 

			Exception: 
				Allow it to happen Inventory Transfer. It will reduce the stock first using AVG and transfer it to the new location for ACTUAL COSTING. It will be reduced by the Sale Invoice 
				using Actual Costing. It will not mess up the inventory valuation because the actual cost is the same average cost. 
	
				To illustrate: 

				strTransactionId                         dblQty                                  dblCost                                 intCostingMethod strName             
				---------------------------------------- --------------------------------------- --------------------------------------- ---------------- --------------------
				INVTRN-3101                              -9829.00000000000000000000              1.01616662017389385428                  1                Inventory Transfer  
				INVTRN-3101                              9829.00000000000000000000               1.01616662017389385428                  5                Inventory Transfer  
				SI-34906                                 -9829.00000000000000000000              1.01616662017389385428                  5                Invoice

				The Average Cost of the item will remain as 1.01616662017389385428. 
		*/
		-- '{Item No} is set to use AVG Costing and it will be received in {Receipt Id} as Actual costing. Average cost computation will be messed up. Try receiving the stocks using Inventory Receipt instead of Transport Load.'
		UNION ALL 
		SELECT	intItemId = @intItemId
				,intItemLocationId = @intItemLocationId
				,strText = dbo.fnFormatMessage(
								dbo.fnICGetErrorMessage(80094)
								, i.strItemNo
								, @strTransactionId 
								, DEFAULT
								, DEFAULT
								, DEFAULT
								, DEFAULT
								, DEFAULT
								, DEFAULT
								, DEFAULT
								, DEFAULT
							)
				,intErrorCode = 80094
		FROM	tblICItem i 
				CROSS APPLY dbo.fnGetCostingMethodAsTable(i.intItemId, @intItemLocationId) icm
				INNER JOIN tblICCostingMethod cm ON cm.intCostingMethodId = icm.CostingMethod
				INNER JOIN tblICInventoryTransactionType ty ON ty.intTransactionTypeId = @intTransactionTypeId
		WHERE	i.intItemId = @intItemId 
				AND @strActualCostId IS NOT NULL 
				AND cm.strCostingMethod = 'AVERAGE COST'
				AND @dblQty > 0 
				AND ty.strName NOT IN ('Inventory Transfer') 

		/*
			Check if the transaction is using a foreign currency and it has a missing forex rate. 
		*/
		-- '{Transaction Id} is using a foreign currency. Please check if {Item No} has a forex rate. You may also need to review the Currency Exchange Rates and check if there is a valid forex rate from {Trans Currency} to {Functional Currency}.'
		UNION ALL
		SELECT	intItemId = @intItemId
				,intItemLocationId = @intItemLocationId
				,strText = dbo.fnFormatMessage(
								dbo.fnICGetErrorMessage(80162)
								, @strTransactionId
								, i.strItemNo 
								, c.strCurrency
								, fc.strCurrency
								, DEFAULT
								, DEFAULT
								, DEFAULT
								, DEFAULT
								, DEFAULT
								, DEFAULT
							)
				,intErrorCode = 80162
		FROM	tblICItem i 					
				LEFT JOIN tblSMCurrency c
					ON c.intCurrencyID = @intCurrencyId
				LEFT JOIN tblSMCurrency fc
					ON fc.intCurrencyID = dbo.fnSMGetDefaultCurrency('FUNCTIONAL') 
		WHERE	i.intItemId = @intItemId
				AND ISNULL(@dblForexRate, 0) = 0 
				AND @intCurrencyId IS NOT NULL 
				AND @intCurrencyId <> dbo.fnSMGetDefaultCurrency('FUNCTIONAL') 
				AND @intCurrencyId NOT IN (SELECT intCurrencyID FROM tblSMCurrency WHERE ysnSubCurrency = 1 AND intMainCurrencyId = dbo.fnSMGetDefaultCurrency('FUNCTIONAL'))

		-- '{Item} will have a negative cost. Negative cost is not allowed.'
		UNION ALL 
		SELECT	intItemId = @intItemId
				,intItemLocationId = @intItemLocationId
				,strText = dbo.fnFormatMessage(
							dbo.fnICGetErrorMessage(80196)
							, Item.strItemNo
							, DEFAULT
							, DEFAULT
							, DEFAULT
							, DEFAULT
							, DEFAULT
							, DEFAULT
							, DEFAULT
							, DEFAULT
							, DEFAULT
						) 
				,intErrorCode = 80196				
		FROM	tblICItem Item
		WHERE	Item.intItemId = @intItemId
				AND ISNULL(@dblCost, 0) < 0

		-- '{Item} is a bundle type and it is not allowed to receive nor reduce stocks.'
		UNION ALL 
		SELECT	intItemId = @intItemId
				,intItemLocationId = @intItemLocationId
				,strText = dbo.fnFormatMessage(
							dbo.fnICGetErrorMessage(80202)
							, Item.strItemNo
							, DEFAULT
							, DEFAULT
							, DEFAULT
							, DEFAULT
							, DEFAULT
							, DEFAULT
							, DEFAULT
							, DEFAULT
							, DEFAULT
						) 
				,intErrorCode = 80202				
		FROM	tblICItem Item
		WHERE	Item.intItemId = @intItemId
				AND Item.strType = 'Bundle'

		-- Should not allow posting when AllowZeroCost is not enabled and the cost of the item is zero
		UNION ALL

		SELECT	intItemId = @intItemId
				,intItemLocationId = @intItemLocationId
				,strText = dbo.fnFormatMessage(
							dbo.fnICGetErrorMessage(80229)
							, Item.strItemNo
							, Location.strLocationName
							, DEFAULT
							, DEFAULT
							, DEFAULT
							, DEFAULT
							, DEFAULT
							, DEFAULT
							, DEFAULT
							, DEFAULT
						) 
				,intErrorCode = 80229				
		FROM tblICItem Item
			INNER JOIN tblICItemLocation IL ON IL.intItemId = @intItemId
				AND IL.intItemLocationId = @intItemLocationId
			INNER JOIN tblSMCompanyLocation Location ON Location.intCompanyLocationId = IL.intLocationId
		WHERE Item.intItemId = @intItemId
			AND ISNULL(IL.intAllowZeroCostTypeId, 1) = 1
			AND CASE WHEN @intTransactionTypeId = 33 THEN ABS(ISNULL(@dblQty, 0)) ELSE ISNULL(@dblQty, 0) END > 0
			AND ISNULL(@dblCost, 0) = 0

	) AS Query		
)
