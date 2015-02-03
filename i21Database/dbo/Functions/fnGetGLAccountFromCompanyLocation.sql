
/*
 fnGetGLAccountFromCompanyLocation is a function that returns the GL account id from a company location 
 
 Parameters: 
	 @intItemId: The item id where the g/l account may have an override. 
	 @intLocationId: The location is where "default" g/l account id is defined. If nothing is found in the item level and category level, this is the g/l account id used. 
	 @strAccountCategory: The specific account description to retrieve. For example: "Inventory", "Cost of Goods"
 
 Sample usage: 
 DECLARE @intCompanyLocationId AS INT = 1

 SELECT	Inventory = dbo.fnGetGLAccountFromCompanyLocation(intCompanyLocationId, 'Inventory')
		,COGS = dbo.fnGetGLAccountFromCompanyLocation(intCompanyLocationId, 'Cost of Goods')
 
*/

CREATE FUNCTION [dbo].[fnGetGLAccountFromCompanyLocation] (
	@intCompanyLocationId INT 
	,@strAccountCategory NVARCHAR(255)
)
RETURNS INT
AS 
BEGIN 
	DECLARE @intGLAccountId AS INT

	SELECT	@intGLAccountId = 
				CASE	WHEN @strAccountCategory = 'Cash Account' THEN intCashAccount
						WHEN @strAccountCategory = 'Deposit Account' THEN intDepositAccount
						WHEN @strAccountCategory = 'AR Account' THEN intARAccount
						WHEN @strAccountCategory = 'AP Account' THEN intAPAccount
						WHEN @strAccountCategory = 'Sales Adv Account' THEN intSalesAdvAcct
						WHEN @strAccountCategory = 'Purchase Adv Account' THEN intPurchaseAdvAccount
						WHEN @strAccountCategory = 'Freight AP Account' THEN intFreightAPAccount
						WHEN @strAccountCategory = 'Freight Expenses' THEN intFreightExpenses
						WHEN @strAccountCategory = 'Freight Income' THEN intFreightIncome
						WHEN @strAccountCategory = 'Service Charges' THEN intServiceCharges
						WHEN @strAccountCategory = 'Sales Discount' THEN intSalesDiscounts
						WHEN @strAccountCategory = 'Cash Over/Short' THEN intCashOverShort
						WHEN @strAccountCategory = 'Write Off' THEN intWriteOff
						WHEN @strAccountCategory = 'Credit Card Fee' THEN intCreditCardFee
						WHEN @strAccountCategory = 'Sales Account' THEN intSalesAccount
						WHEN @strAccountCategory = 'Cost of Goods' THEN intCostofGoodsSold
						WHEN @strAccountCategory = 'Inventory' THEN intInventory
						WHEN @strAccountCategory = 'Write-Off Sold' THEN intWriteOffSold
						WHEN @strAccountCategory = 'Revalue Sold' THEN intRevalueSold
						WHEN @strAccountCategory = 'Auto-Negative' THEN intAutoNegativeSold
						WHEN @strAccountCategory = 'AP Clearing' THEN intAPClearing
						WHEN @strAccountCategory = 'Inventory In-Transit' THEN intInventoryInTransit
				END
	FROM	dbo.tblSMCompanyLocation
	WHERE	intCompanyLocationId = @intCompanyLocationId
	
	RETURN @intGLAccountId
END 
