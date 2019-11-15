CREATE VIEW vyuFRBudgetExport
AS
SELECT
[PrimaryAccount] = SUBSTRING(strCurrentExternalId,0,9) 
,[SegmentAccount] = SUBSTRING(strCurrentExternalId,10,20)
,AccountType =
	CASE
		WHEN vyuGLAccountView.strAccountType = 'Asset' THEN 'A'
		WHEN vyuGLAccountView.strAccountGroup = 'Cost of Goods Sold' AND vyuGLAccountView.strAccountType ='Expense' THEN 'C'
		WHEN vyuGLAccountView.strAccountGroup = 'Sales' and vyuGLAccountView.strAccountType = 'Revenue' THEN 'I'
		WHEN vyuGLAccountView.strAccountType = 'Expense' THEN 'E'
		WHEN vyuGLAccountView.strAccountType = 'Liability' THEN 'L'
		WHEN vyuGLAccountView.strAccountType = 'Equity' THEN 'Q'
	ELSE ''
	END	
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
FROM  tblFRBudget Budget LEFT JOIN  tblGLCOACrossReference COA ON inti21Id = Budget.intAccountId
OUTER APPLY (
	SELECT  strAccountType,strAccountGroup FROM vyuGLAccountView WHERE intAccountId = Budget.intAccountId
) vyuGLAccountView
 