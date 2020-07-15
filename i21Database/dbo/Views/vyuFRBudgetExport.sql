CREATE VIEW vyuFRBudgetExport
AS
SELECT
[PrimaryAccount] = SUBSTRING(strCurrentExternalId,0,9) 
,[SegmentAccount] = SUBSTRING(strCurrentExternalId,10,20)
,AccountType =
	CASE
		WHEN vyu.strAccountType = 'Asset' THEN 'A'
		WHEN vyu.strAccountGroup = 'Cost of Goods Sold' AND vyu.strAccountType ='Expense' THEN 'C'
		WHEN vyu.strAccountGroup = 'Sales' and vyu.strAccountType = 'Revenue' THEN 'I'
		WHEN vyu.strAccountType = 'Expense' THEN 'E'
		WHEN vyu.strAccountType = 'Liability' THEN 'L'
		WHEN vyu.strAccountType = 'Equity' THEN 'Q'
	ELSE ''
	END	COLLATE Latin1_General_CI_AS
,dblBudget1  = ISNULL(dblBudget1,0)
,dblBudget2  = ISNULL(dblBudget2,0)
,dblBudget3  = ISNULL(dblBudget3,0) 
,dblBudget4  = ISNULL(dblBudget4,0) 
,dblBudget5  = ISNULL(dblBudget5,0) 
,dblBudget6  = ISNULL(dblBudget6,0) 
,dblBudget7  = ISNULL(dblBudget7,0) 
,dblBudget8  = ISNULL(dblBudget8,0) 
,dblBudget9  = ISNULL(dblBudget9,0) 
,dblBudget10 = ISNULL(dblBudget10,0)
,dblBudget11 = ISNULL(dblBudget11,0)
,dblBudget12 = ISNULL(dblBudget12,0)
,dblBudget13 = ISNULL(dblBudget13,0)
,intAccountId
,intBudgetCode
FROM  tblFRBudget Budget LEFT JOIN  tblGLCOACrossReference COA ON inti21Id = Budget.intAccountId
OUTER APPLY (
	SELECT  strAccountType,strAccountGroup FROM vyuGLAccountDetail WHERE intAccountId = Budget.intAccountId
) vyu