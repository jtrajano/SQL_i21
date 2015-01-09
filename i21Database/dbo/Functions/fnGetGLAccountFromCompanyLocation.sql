
/*
 fnGetGLAccountFromCompanyLocation is a function that returns the GL account id from a company location 
 
 Parameters: 
	 @intItemId: The item id where the g/l account may have an override. 
	 @intLocationId: The location is where "default" g/l account id is defined. If nothing is found in the item level and category level, this is the g/l account id used. 
	 @strAccountDescription: The specific account description to retrieve. For example: "Inventory", "Cost of Goods"
 
 Sample usage: 
 DECLARE @intCompanyLocationId AS INT = 1

 SELECT	Inventory = dbo.fnGetGLAccountFromCompanyLocation(intCompanyLocationId, 'Inventory')
		,COGS = dbo.fnGetGLAccountFromCompanyLocation(intCompanyLocationId, 'Cost of Goods')
 
*/

CREATE FUNCTION [dbo].[fnGetGLAccountFromCompanyLocation] (
	@intCompanyLocationId INT 
	,@strAccountDescription NVARCHAR(255)
)
RETURNS INT
AS 
BEGIN 
	DECLARE @intGLAccountId AS INT

	SELECT	@intGLAccountId = 
				CASE	WHEN @strAccountDescription = 'Cash Account' THEN intCashAccount
						WHEN @strAccountDescription = 'Deposit Account' THEN intDepositAccount
						WHEN @strAccountDescription = 'AR Account' THEN intARAccount
						WHEN @strAccountDescription = 'AP Account' THEN intAPAccount
						WHEN @strAccountDescription = 'Sales Adv Account' THEN intSalesAdvAcct
						WHEN @strAccountDescription = 'Purchase Adv Account' THEN intPurchaseAdvAccount
						WHEN @strAccountDescription = 'Freight AP Account' THEN intFreightAPAccount
						WHEN @strAccountDescription = 'Freight Expenses' THEN intFreightExpenses
						WHEN @strAccountDescription = 'Freight Income' THEN intFreightIncome
						WHEN @strAccountDescription = 'Service Charges' THEN intServiceCharges
						WHEN @strAccountDescription = 'Sales Discount' THEN intSalesDiscounts
						WHEN @strAccountDescription = 'Cash Over/Short' THEN intCashOverShort
						WHEN @strAccountDescription = 'Write Off' THEN intWriteOff
						WHEN @strAccountDescription = 'Credit Card Fee' THEN intCreditCardFee
						WHEN @strAccountDescription = 'Sales Account' THEN intSalesAccount
						WHEN @strAccountDescription = 'Cost of Goods' THEN intCostofGoodsSold
						WHEN @strAccountDescription = 'Inventory' THEN intInventory
						WHEN @strAccountDescription = 'Write-Off Sold' THEN intWriteOffSold
						WHEN @strAccountDescription = 'Revalue Sold' THEN intRevalueSold
						WHEN @strAccountDescription = 'Auto-Negative' THEN intAutoNegativeSold
						WHEN @strAccountDescription = 'AP Clearing' THEN intAPClearing
						WHEN @strAccountDescription = 'Inventory In-Transit' THEN intInventoryInTransit
				END
	FROM	dbo.tblSMCompanyLocation
	WHERE	intCompanyLocationId = @intCompanyLocationId
	
	RETURN @intGLAccountId
END 
