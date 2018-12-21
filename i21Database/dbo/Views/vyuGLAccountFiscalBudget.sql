CREATE VIEW vyuGLAccountFiscalBudget
AS
SELECT A.intBudgetId,
B.strBudgetCode,
B.strBudgetEnglishDescription, 
B.ysnDefault,
B.intConcurrencyId, 
B.intFiscalYearId, 
A.intBudgetCode, 
A.intAccountId,
dblBudget1,
dblBudget2,
dblBudget3,
dblBudget4,
dblBudget5,
dblBudget6,
dblBudget7,
dblBudget8,
dblBudget9,
dblBudget10,
dblBudget11,
dblBudget12,
dblBudget13
FROM 
tblFRBudget A 
join tblFRBudgetCode B ON A.intBudgetCode = B.intBudgetCode 

