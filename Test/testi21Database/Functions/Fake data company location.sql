CREATE PROCEDURE [testi21Database].[Fake data company location]
AS
BEGIN
	-- Create the fake table and data for the items
	EXEC tSQLt.FakeTable 'dbo.tblSMCompanyLocation', @Identity = 1;
	
	INSERT INTO tblSMCompanyLocation (
				strLocationName
				,intProfitCenter
				,intCashAccount
				,intDepositAccount
				,intARAccount
				,intAPAccount
				,intSalesAdvAcct
				,intPurchaseAdvAccount
				,intFreightAPAccount
				,intFreightExpenses
				,intFreightIncome
				,intServiceCharges
				,intSalesDiscounts
				,intCashOverShort
				,intWriteOff
				,intCreditCardFee
				,intSalesAccount
				,intCostofGoodsSold
				,intInventory
				,intWriteOffSold
				,intRevalueSold
				,intAutoNegativeSold
				,intAPClearing
				,intInventoryInTransit
	)
	SELECT 		strLocationName = 'Fake Warehouse'
				,intProfitCenter = 1
				,intCashAccount = 2
				,intDepositAccount = 3
				,intARAccount = 4
				,intAPAccount = 5
				,intSalesAdvAcct = 6
				,intPurchaseAdvAccount = 7
				,intFreightAPAccount = 8
				,intFreightExpenses = 9
				,intFreightIncome = 10
				,intServiceCharges = 11
				,intSalesDiscounts = 12
				,intCashOverShort = 13
				,intWriteOff = 14
				,intCreditCardFee = 15
				,intSalesAccount = 16
				,intCostofGoodsSold = 17 
				,intInventory = 18
				,intWriteOffSold = 19 
				,intRevalueSold = 20
				,intAutoNegativeSold = 21
				,intAPClearing = 22
				,intInventoryInTransit = 23
	
END 
