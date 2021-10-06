CREATE PROCEDURE [uspICPopulateRetailValuationByDate]
	@dtmDateFrom AS DATETIME
	,@dtmDateTo AS DATETIME 
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS ON

DECLARE @dtmCreated AS DATETIME = GETDATE()

-- Clean the contents of retail valuation table. 
BEGIN 
	TRUNCATE TABLE [tblICRetailValuation]
END 

-- Do nothing if date range is invalid. 
IF @dtmDateFrom IS NULL OR @dtmDateTo IS NULL 
	RETURN; 

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
		,dtmDateFrom				= dateRange.dtmDate
		,dtmDateTo					= dateRange.dtmDate
		,dtmCreated					= @dtmCreated
FROM 	dbo.fnDateRange(@dtmDateFrom, @dtmDateTo, 'DD', 1) dateRange LEFT JOIN tblICCategory category 
			ON 1 = 1
		LEFT JOIN tblICCategoryLocation categoryLocation
			ON category.intCategoryId = categoryLocation.intCategoryId
		LEFT JOIN tblSMCompanyLocation companyLocation
			ON categoryLocation.intLocationId = companyLocation.intCompanyLocationId
WHERE	category.ysnRetailValuation = 1
ORDER BY
	category.strCategoryCode ASC
	,companyLocation.strLocationName ASC	
	,dateRange.dtmDate ASC 

IF OBJECT_ID('tempdb..#tmpRetailValuationBeginBalance') IS NOT NULL  
	DROP TABLE #tmpRetailValuationBeginBalance

IF OBJECT_ID('tempdb..#tmpRetailValuationDetail') IS NOT NULL  
	DROP TABLE #tmpRetailValuationDetail

-- Intialize #tmpRetailValuationBeginBalance
CREATE TABLE #tmpRetailValuationBeginBalance (
	[intId] INT NOT NULL IDENTITY 
	,[intCategoryId] INT NOT NULL
	,[intLocationId] INT NOT NULL
	,[dblRetail] NUMERIC(38, 20) NOT NULL DEFAULT 0
	,[dblCost] NUMERIC(38, 20) NOT NULL DEFAULT 0
)
CREATE NONCLUSTERED INDEX [IX_tmpRetailValuationBeginBalance]
	ON #tmpRetailValuationBeginBalance([intCategoryId] ASC, [intLocationId] ASC);

CREATE TABLE #tmpRetailValuationDetail (
	[intId] INT NOT NULL IDENTITY 
	,[intCategoryId] INT NOT NULL
	,[intLocationId] INT NOT NULL
	,[strTransactionType] NVARCHAR(200) COLLATE Latin1_General_CI_AS NOT NULL
	,[dtmDate] DATETIME NOT NULL 		
	,[dblRetail] NUMERIC(38, 20) NOT NULL DEFAULT 0
	,[dblCost] NUMERIC(38, 20) NOT NULL DEFAULT 0
)
CREATE NONCLUSTERED INDEX [IX_tmpRetailValuationDetail]
	ON #tmpRetailValuationDetail([intCategoryId] ASC, [intLocationId] ASC, [strTransactionType] ASC, [dtmDate] ASC);

---------------------------------------------
-- Populate the beginning balance
---------------------------------------------
INSERT INTO #tmpRetailValuationBeginBalance (
	[intCategoryId] 
	,[intLocationId] 
	,[dblRetail]
	,[dblCost] 	
)
SELECT	
	i.intCategoryId
	,il.intLocationId
	,dblRetail = SUM(
		ISNULL(t.dblCategoryRetailValue, (ISNULL(t.dblQty, 0) * ISNULL(t.dblUnitRetail, 0)))
	)
	,dblCost = SUM(
		ISNULL(t.dblCategoryCostValue, (ISNULL(t.dblQty, 0) * ISNULL(t.dblCost, 0)))
	)
FROM	
	tblICInventoryTransaction t INNER JOIN tblICItem i 
		ON t.intItemId = i.intItemId
	INNER JOIN tblICItemLocation il 
		ON t.intItemLocationId = il.intItemLocationId
WHERE
	dbo.fnDateLessThan(t.dtmDate, @dtmDateFrom) = 1
GROUP BY
	i.intCategoryId
	,il.intLocationId
HAVING 
	SUM(ISNULL(t.dblCategoryRetailValue, (ISNULL(t.dblQty, 0) * ISNULL(t.dblUnitRetail, 0)))) <> 0 

---------------------------------------------
-- Populate the Detail 
---------------------------------------------
INSERT INTO #tmpRetailValuationDetail (
	[intCategoryId] 
	,[intLocationId] 
	,[strTransactionType] 
	,[dtmDate] 
	,[dblRetail] 
	,[dblCost]
)
SELECT	
	i.intCategoryId
	,il.intLocationId
	,ty.strName
	,dtmDate = dbo.fnRemoveTimeOnDate(t.dtmDate)
	,dblRetail = SUM(
		ISNULL(t.dblCategoryRetailValue, (ISNULL(t.dblQty, 0) * ISNULL(t.dblUnitRetail, 0)))
	)
	,dblCost = SUM(
		ISNULL(t.dblCategoryCostValue, (ISNULL(t.dblQty, 0) * ISNULL(t.dblCost, 0)))
	)
FROM	
	tblICInventoryTransaction t INNER JOIN tblICItem i 
		ON t.intItemId = i.intItemId
	INNER JOIN tblICItemLocation il 
		ON t.intItemLocationId = il.intItemLocationId
	INNER JOIN tblICInventoryTransactionType ty
		ON ty.intTransactionTypeId = t.intTransactionTypeId
WHERE
	dbo.fnDateGreaterThanEquals(t.dtmDate, @dtmDateFrom) = 1
	AND dbo.fnDateLessThanEquals(t.dtmDate, @dtmDateTo) = 1
GROUP BY
	i.intCategoryId
	,il.intLocationId
	,ty.strName
	,dbo.fnRemoveTimeOnDate(t.dtmDate)
HAVING 
	SUM(ISNULL(t.dblCategoryRetailValue, (ISNULL(t.dblQty, 0) * ISNULL(t.dblUnitRetail, 0)))) <> 0 

-- Populate the beginning retail 
UPDATE	rv
SET		rv.dblBeginningRetail = ISNULL(beginTrans.dblRetail, 0) + ISNULL(detailTrans.dblRetail, 0) 
FROM	tblICRetailValuation rv 
		OUTER APPLY (
			SELECT	b.dblRetail
			FROM	#tmpRetailValuationBeginBalance b
			WHERE	b.intCategoryId = rv.intCategoryId 
					AND b.intLocationId = rv.intLocationId							
		) beginTrans
		OUTER APPLY (
			SELECT	dblRetail = SUM(d.dblRetail)
			FROM	#tmpRetailValuationDetail d 
			WHERE	d.intCategoryId = rv.intCategoryId 
					AND d.intLocationId = rv.intLocationId
					AND dbo.fnDateLessThan(d.dtmDate, rv.dtmDateFrom) = 1 
		) detailTrans

-- Populate the receipt total
UPDATE	rv
SET		rv.dblReceipts = ISNULL(detailTrans.dblRetail, 0)
FROM	tblICRetailValuation rv 		
		OUTER APPLY (
			SELECT	dblRetail = SUM(d.dblRetail)
			FROM	#tmpRetailValuationDetail d 
			WHERE	d.intCategoryId = rv.intCategoryId 
					AND d.intLocationId = rv.intLocationId
					AND d.strTransactionType = 'Inventory Receipt'
					AND dbo.fnDateGreaterThanEquals(d.dtmDate, ISNULL(rv.dtmDateFrom, 0)) = 1
					AND dbo.fnDateLessThanEquals(d.dtmDate, ISNULL(rv.dtmDateTo, ISNULL(rv.dtmDateFrom, 0))) = 1
		) detailTrans

-- Populate the sales total
UPDATE	rv
SET		rv.dblSales = ISNULL(detailTrans.dblRetail, 0)
FROM	tblICRetailValuation rv 
		OUTER APPLY (
			SELECT	dblRetail = SUM(-d.dblRetail)
			FROM	#tmpRetailValuationDetail d 
			WHERE	d.intCategoryId = rv.intCategoryId 
					AND d.intLocationId = rv.intLocationId
					AND d.strTransactionType = 'Invoice'
					AND dbo.fnDateGreaterThanEquals(d.dtmDate, ISNULL(rv.dtmDateFrom, 0)) = 1
					AND dbo.fnDateLessThanEquals(d.dtmDate, ISNULL(rv.dtmDateTo, ISNULL(rv.dtmDateFrom, 0))) = 1
		) detailTrans

		
-- Populate the mark ups/downs
UPDATE	rv
SET		rv.dblMarkUpsDowns = ISNULL(detailTrans.dblRetail, 0)
FROM	tblICRetailValuation rv 
		OUTER APPLY (
			SELECT	dblRetail = SUM(d.dblRetail)
			FROM	#tmpRetailValuationDetail d 
			WHERE	d.intCategoryId = rv.intCategoryId 
					AND d.intLocationId = rv.intLocationId
					AND d.strTransactionType IN ('Retail Mark Ups/Downs', 'Inventory Count By Category') 
					AND dbo.fnDateGreaterThanEquals(d.dtmDate, ISNULL(rv.dtmDateFrom, 0)) = 1
					AND dbo.fnDateLessThanEquals(d.dtmDate, ISNULL(rv.dtmDateTo, ISNULL(rv.dtmDateFrom, 0))) = 1
		) detailTrans

-- Populate the write offs
UPDATE	rv
SET		rv.dblWriteOffs = ISNULL(detailTrans.dblRetail, 0)
FROM	tblICRetailValuation rv 
		OUTER APPLY (
			SELECT	dblRetail = SUM(-d.dblRetail)
			FROM	#tmpRetailValuationDetail d 
			WHERE	d.intCategoryId = rv.intCategoryId 
					AND d.intLocationId = rv.intLocationId
					AND d.strTransactionType = 'Retail Write Offs'
					AND dbo.fnDateGreaterThanEquals(d.dtmDate, ISNULL(rv.dtmDateFrom, 0)) = 1
					AND dbo.fnDateLessThanEquals(d.dtmDate, ISNULL(rv.dtmDateTo, ISNULL(rv.dtmDateFrom, 0))) = 1
		) detailTrans

-- Populate the ending retail
UPDATE	rv
SET		rv.dblEndingRetail = ISNULL(beginTrans.dblRetail, 0) + ISNULL(detailTrans.dblRetail, 0)
FROM	tblICRetailValuation rv 
		OUTER APPLY (
			SELECT	b.dblRetail
			FROM	#tmpRetailValuationBeginBalance b
			WHERE	b.intCategoryId = rv.intCategoryId 
					AND b.intLocationId = rv.intLocationId							
		) beginTrans
		OUTER APPLY (
			SELECT	dblRetail = SUM(d.dblRetail)
			FROM	#tmpRetailValuationDetail d 
			WHERE	d.intCategoryId = rv.intCategoryId 
					AND d.intLocationId = rv.intLocationId
					AND dbo.fnDateLessThanEquals(d.dtmDate, ISNULL(rv.dtmDateTo, ISNULL(rv.dtmDateFrom, 0))) = 1
		) detailTrans

-- Populate the ending cost 
UPDATE	rv
SET		rv.dblEndingCost = ISNULL(beginTrans.dblCost, 0) + ISNULL(detailTrans.dblCost, 0) 
FROM	tblICRetailValuation rv 
		OUTER APPLY (
			SELECT	b.dblCost
			FROM	#tmpRetailValuationBeginBalance b
			WHERE	b.intCategoryId = rv.intCategoryId 
					AND b.intLocationId = rv.intLocationId							
		) beginTrans
		OUTER APPLY (
			SELECT	dblCost = SUM(d.dblCost)
			FROM	#tmpRetailValuationDetail d 
			WHERE	d.intCategoryId = rv.intCategoryId 
					AND d.intLocationId = rv.intLocationId
					AND dbo.fnDateLessThanEquals(d.dtmDate, ISNULL(rv.dtmDateTo, ISNULL(rv.dtmDateFrom, 0))) = 1
		) detailTrans

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

IF OBJECT_ID('tempdb..#tmpRetailValuationBeginBalance') IS NOT NULL  
	DROP TABLE #tmpRetailValuationBeginBalance

IF OBJECT_ID('tempdb..#tmpRetailValuationDetail') IS NOT NULL  
	DROP TABLE #tmpRetailValuationDetail