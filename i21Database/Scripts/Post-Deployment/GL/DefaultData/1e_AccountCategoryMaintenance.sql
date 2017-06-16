--APPLIED on 17.2

DECLARE @tbl TABLE (cat NVARCHAR(100) COLLATE Latin1_General_CI_AS)
INSERT INTO @tbl 
SELECT 'Begin Inventory' UNION 
SELECT 'Broker Expense' UNION 
SELECT 'Cash Over/Short' UNION
SELECT 'Contract Equity' UNION
SELECT 'Contract Purchase Gain/Loss' UNION
SELECT 'Contract Sales Gain/Loss' UNION
SELECT 'Credit Card Fee' UNION
SELECT 'Currency Equity' UNION
SELECT 'Currency Purchase Gain/Loss' UNION
SELECT 'Currency Sales Gain/Loss' UNION
SELECT 'Deferred Payable' UNION
SELECT 'Deposit Account' UNION
SELECT 'End Inventory' UNION
SELECT 'Fee Income'UNION
SELECT 'Freight AP Account'UNION
SELECT 'Freight Expenses' UNION
SELECT 'Freight Income' UNION
SELECT 'Interest Expense' UNION 
SELECT 'Options Expense'UNION
SELECT 'Options Income' UNION
SELECT 'Purchase Account'UNION
SELECT 'Revalue Sold' UNION 
SELECT 'Storage Expense'UNION 
SELECT 'Storage Income'UNION 
SELECT 'Storage Receivable'UNION 
SELECT 'Variance Account'UNION 
SELECT 'Write-Off Sold'UNION 
SELECT 'Sales Adv Account'UNION 
SELECT 'Auto-Variance' UNION
SELECT 'Fee Expense'

DECLARE @intGeneralCategoryId INT
SELECT @intGeneralCategoryId = intAccountCategoryId FROM tblGLAccountCategory  WHERE strAccountCategory = 'General'
-- UPDATE tblCTCostType
UPDATE  a 
SET intAccountCategoryId = @intGeneralCategoryId
FROM tblCTCostType a JOIN 
tblGLAccountCategory b on a.intAccountCategoryId = b.intAccountCategoryId
JOIN @tbl c on c.cat =  b.strAccountCategory


DELETE g
FROM tblGLAccountCategoryGroup g
JOIN tblGLAccountCategory c ON g.intAccountCategoryId = c.intAccountCategoryId
JOIN @tbl t ON t.cat = c.strAccountCategory

-- UPDATE tblGLCOATemplateDetail
UPDATE d
SET intAccountCategoryId = @intGeneralCategoryId
FROM tblGLCOATemplateDetail d 
JOIN tblGLAccountCategory c ON d.intAccountCategoryId = c.intAccountCategoryId
JOIN @tbl t ON t.cat = c.strAccountCategory

--UPDATE tblGLAccountGroup
UPDATE d
SET intAccountCategoryId = @intGeneralCategoryId
FROM tblGLAccountGroup d 
JOIN tblGLAccountCategory c ON d.intAccountCategoryId = c.intAccountCategoryId
JOIN @tbl t ON t.cat = c.strAccountCategory


UPDATE d
SET intAccountCategoryId = @intGeneralCategoryId
FROM tblGLAccountSegment d 
JOIN tblGLAccountCategory c ON d.intAccountCategoryId = c.intAccountCategoryId
JOIN @tbl t ON t.cat = c.strAccountCategory

DELETE c
FROM tblGLAccountCategory c
JOIN @tbl t ON t.cat = c.strAccountCategory

GO




