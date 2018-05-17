CREATE PROCEDURE [uspICPopulateRetailValuation]
	@dtmDateFrom AS DATETIME
	,@dtmDateTo AS DATETIME 
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

DECLARE @dtmCreated AS DATETIME = GETDATE()

-- Clean the contents of retail valuation table. 
BEGIN 
	TRUNCATE TABLE [tblICRetailValuation]
END 

INSERT INTO tblICRetailValuation (
		intCategoryId
		,intCategoryLocationId
		,intLocationId
		,intRegisterDepartmentId
		,strLocationName
		,strCategoryCode	
		,strCategoryDescription
		,dblBeginningRetail
		,dblReceipts
		,dblSales
		,dblMarkUpsDowns
		,dblWriteOffs
		,dblEndingRetail
		,dblGrossMarginPct
		,dblTargetGrossMarginPct
		,dblEndingCost
		,dtmDateFrom
		,dtmDateTo
		,dtmCreated
)
SELECT	category.intCategoryId
		,categoryLocation.intCategoryLocationId
		,intLocationId = categoryLocation.intLocationId 
		,categoryLocation.intRegisterDepartmentId
		,companyLocation.strLocationName
		,category.strCategoryCode	
		,strCategoryDescription		= category.strDescription	
		,dblBeginningRetail			= CAST(0 AS NUMERIC(18, 6)) 
		,dblReceipts				= CAST(0 AS NUMERIC(18, 6))
		,dblSales					= CAST(0 AS NUMERIC(18, 6))
		,dblMarkUpsDowns			= CAST(0 AS NUMERIC(18, 6))
		,dblWriteOffs				= CAST(0 AS NUMERIC(18, 6))
		,dblEndingRetail			= CAST(0 AS NUMERIC(18, 6)) 
		,dblGrossMarginPct			= CAST(0 AS NUMERIC(18, 6)) 
		,dblTargetGrossMarginPct	= categoryLocation.dblTargetGrossProfit 
		,dblEndingCost				= CAST(0 AS NUMERIC(18, 6)) 
		,dtmDateFrom				= @dtmDateFrom
		,dtmDateTo					= @dtmDateTo
		,dtmCreated					= @dtmCreated
FROM 	tblICCategory category LEFT JOIN tblICCategoryLocation categoryLocation
			ON category.intCategoryId = categoryLocation.intCategoryId
		LEFT JOIN tblSMCompanyLocation companyLocation
			ON categoryLocation.intLocationId = companyLocation.intCompanyLocationId
WHERE	category.ysnRetailValuation = 1

-- Populate the beginning retail 
UPDATE	rv
SET		rv.dblBeginningRetail = transactions.total 
FROM	tblICRetailValuation rv OUTER APPLY (
			SELECT	total = SUM(
						ISNULL(t.dblCategoryRetailValue, (ISNULL(t.dblQty, 0) * ISNULL(t.dblUnitRetail, 0)))
					)
			FROM	tblICInventoryTransaction t INNER JOIN tblICItem i 
						ON t.intItemId = i.intItemId
					INNER JOIN tblICItemLocation il 
						ON t.intItemLocationId = il.intItemLocationId
			WHERE	rv.intCategoryId = i.intCategoryId 					
					AND il.intLocationId = rv.intLocationId		
					AND dbo.fnDateLessThan(t.dtmDate, ISNULL(@dtmDateFrom, 0)) = 1
		) transactions
		
-- Populate the receipt total
UPDATE	rv
SET		rv.dblReceipts = transactions.total 
FROM	tblICRetailValuation rv OUTER APPLY (
			SELECT	total = SUM(
						ISNULL(t.dblCategoryRetailValue, (ISNULL(t.dblQty, 0) * ISNULL(t.dblUnitRetail, 0)))
					)
			FROM	tblICInventoryTransaction t INNER JOIN tblICItem i 
						ON t.intItemId = i.intItemId
					INNER JOIN tblICItemLocation il 
						ON t.intItemLocationId = il.intItemLocationId
					INNER JOIN tblICInventoryTransactionType ty
						ON ty.intTransactionTypeId = t.intTransactionTypeId
			WHERE	rv.intCategoryId = i.intCategoryId 					
					AND il.intLocationId = rv.intLocationId		
					AND ty.strName = 'Inventory Receipt'
					AND dbo.fnDateGreaterThanEquals(t.dtmDate, ISNULL(@dtmDateFrom, 0)) = 1
					AND dbo.fnDateLessThanEquals(t.dtmDate, ISNULL(@dtmDateTo, ISNULL(@dtmDateFrom, 0))) = 1
		) transactions

-- Populate the sales total
UPDATE	rv
SET		rv.dblSales = transactions.total 
FROM	tblICRetailValuation rv OUTER APPLY (
			SELECT	total = SUM(
						-ISNULL(t.dblCategoryRetailValue, (ISNULL(t.dblQty, 0) * ISNULL(t.dblUnitRetail, 0)))
					)
			FROM	tblICInventoryTransaction t INNER JOIN tblICItem i 
						ON t.intItemId = i.intItemId
					INNER JOIN tblICItemLocation il 
						ON t.intItemLocationId = il.intItemLocationId
					INNER JOIN tblICInventoryTransactionType ty
						ON ty.intTransactionTypeId = t.intTransactionTypeId
			WHERE	rv.intCategoryId = i.intCategoryId 					
					AND il.intLocationId = rv.intLocationId		
					AND ty.strName = 'Invoice'
					AND dbo.fnDateGreaterThanEquals(t.dtmDate, ISNULL(@dtmDateFrom, 0)) = 1
					AND dbo.fnDateLessThanEquals(t.dtmDate, ISNULL(@dtmDateTo, ISNULL(@dtmDateFrom, 0))) = 1
		) transactions
		
-- Populate the mark ups/downs
UPDATE	rv
SET		rv.dblMarkUpsDowns = transactions.total 
FROM	tblICRetailValuation rv OUTER APPLY (
			SELECT	total = SUM(
						ISNULL(t.dblCategoryRetailValue, (ISNULL(t.dblQty, 0) * ISNULL(t.dblUnitRetail, 0)))
					)
			FROM	tblICInventoryTransaction t INNER JOIN tblICItem i 
						ON t.intItemId = i.intItemId
					INNER JOIN tblICItemLocation il 
						ON t.intItemLocationId = il.intItemLocationId
					INNER JOIN tblICInventoryTransactionType ty
						ON ty.intTransactionTypeId = t.intTransactionTypeId
			WHERE	rv.intCategoryId = i.intCategoryId 					
					AND il.intLocationId = rv.intLocationId		
					AND ty.strName = 'Retail Mark Ups/Downs'
					AND dbo.fnDateGreaterThanEquals(t.dtmDate, ISNULL(@dtmDateFrom, 0)) = 1
					AND dbo.fnDateLessThanEquals(t.dtmDate, ISNULL(@dtmDateTo, ISNULL(@dtmDateFrom, 0))) = 1
		) transactions

-- Populate the write offs
UPDATE	rv
SET		rv.dblWriteOffs = transactions.total 
FROM	tblICRetailValuation rv OUTER APPLY (
			SELECT	total = SUM(
						-ISNULL(t.dblCategoryRetailValue, (ISNULL(t.dblQty, 0) * ISNULL(t.dblUnitRetail, 0)))
					)
			FROM	tblICInventoryTransaction t INNER JOIN tblICItem i 
						ON t.intItemId = i.intItemId
					INNER JOIN tblICItemLocation il 
						ON t.intItemLocationId = il.intItemLocationId
					INNER JOIN tblICInventoryTransactionType ty
						ON ty.intTransactionTypeId = t.intTransactionTypeId
			WHERE	rv.intCategoryId = i.intCategoryId 					
					AND il.intLocationId = rv.intLocationId		
					AND ty.strName = 'Retail Write Offs'
					AND dbo.fnDateGreaterThanEquals(t.dtmDate, ISNULL(@dtmDateFrom, 0)) = 1
					AND dbo.fnDateLessThanEquals(t.dtmDate, ISNULL(@dtmDateTo, ISNULL(@dtmDateFrom, 0))) = 1
		) transactions

-- Populate the ending retail
UPDATE	rv
SET		rv.dblEndingRetail = transactions.total 
FROM	tblICRetailValuation rv OUTER APPLY (
			SELECT	total = SUM(
						ISNULL(t.dblCategoryRetailValue, (ISNULL(t.dblQty, 0) * ISNULL(t.dblUnitRetail, 0)))
					)
			FROM	tblICInventoryTransaction t INNER JOIN tblICItem i 
						ON t.intItemId = i.intItemId
					INNER JOIN tblICItemLocation il 
						ON t.intItemLocationId = il.intItemLocationId
					INNER JOIN tblICInventoryTransactionType ty
						ON ty.intTransactionTypeId = t.intTransactionTypeId
			WHERE	rv.intCategoryId = i.intCategoryId 					
					AND il.intLocationId = rv.intLocationId		
					AND dbo.fnDateLessThanEquals(t.dtmDate, ISNULL(@dtmDateTo, ISNULL(@dtmDateFrom, 0))) = 1
		) transactions

-- Populate the ending cost 
UPDATE	rv
SET		rv.dblEndingCost = transactions.total 
FROM	tblICRetailValuation rv OUTER APPLY (
			SELECT	total = SUM(
						ISNULL(t.dblCategoryCostValue, (ISNULL(t.dblQty, 0) * ISNULL(t.dblCost, 0)))
					)
			FROM	tblICInventoryTransaction t INNER JOIN tblICItem i 
						ON t.intItemId = i.intItemId
					INNER JOIN tblICItemLocation il 
						ON t.intItemLocationId = il.intItemLocationId
					INNER JOIN tblICInventoryTransactionType ty
						ON ty.intTransactionTypeId = t.intTransactionTypeId
			WHERE	rv.intCategoryId = i.intCategoryId 					
					AND il.intLocationId = rv.intLocationId		
					AND dbo.fnDateLessThanEquals(t.dtmDate, ISNULL(@dtmDateTo, ISNULL(@dtmDateFrom, 0))) = 1
		) transactions

-- Update the Gross Margin %
UPDATE	rv
SET		rv.dblGrossMarginPct = 
				CASE 
					WHEN ISNULL(dblEndingRetail, 0) <> 0 THEN 
						(ISNULL(dblEndingRetail, 0) - ISNULL(dblEndingCost, 0)) 
						/ ISNULL(dblEndingRetail, 0)
					ELSE 0
				END 
				* 100
FROM	tblICRetailValuation rv