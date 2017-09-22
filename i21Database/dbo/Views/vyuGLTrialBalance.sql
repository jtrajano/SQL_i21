CREATE VIEW [dbo].[vyuGLTrialBalance]
AS
WITH BeginningBalance AS(
	SELECT intAccountId, intGLFiscalYearPeriodId, YTD,MTD  FROM vyuGLTrialBalance_NonRE 
	UNION ALL
	SELECT intAccountId, intGLFiscalYearPeriodId, YTD,MTD FROM  vyuGLTrialBalance_RE 
)
SELECT 
ISNULL(B.MTD,0)MTDBalance,
ISNULL(B.YTD,0)YTDBalance,
A.intAccountId,
Cat.strAccountCategory,
strAccountGroup,
A.strAccountId,
G.strAccountType,
A.strCashFlow,
SUBSTRING(A.strAccountId, 1, P.intLength)strCode,
A.strComments,
strCurrency,
coa.strCurrentExternalId,
A.strDescription,
coa.strExternalId,
A.strNote,
U.strUOMCode,
A.ysnActive,
period.dtmStartDate dtmDateFrom,
period.dtmEndDate dtmDateTo,
B.intGLFiscalYearPeriodId
FROM tblGLAccount A
LEFT JOIN tblGLCOACrossReference coa ON A.intAccountId =coa.inti21Id 
LEFT JOIN BeginningBalance B ON A.intAccountId = B.intAccountId
LEFT JOIN tblGLFiscalYearPeriod period on period.intGLFiscalYearPeriodId = B.intGLFiscalYearPeriodId
LEFT JOIN tblSMCurrency C on C.intCurrencyID = A.intCurrencyID
LEFT JOIN tblGLAccountGroup G ON G.intAccountGroupId = A.intAccountGroupId
LEFT JOIN tblGLAccountUnit U on U.intAccountUnitId = A.intAccountUnitId
CROSS APPLY(
	SELECT top 1 intLength, intAccountStructureId FROM tblGLAccountStructure WHERE strType = 'Primary'
)P
CROSS APPLY(
	SELECT TOP 1 C.strAccountCategory FROM tblGLAccountSegmentMapping M 
	JOIN tblGLAccountSegment S on S.intAccountSegmentId = M.intAccountSegmentId
	JOIN tblGLAccountCategory C on C.intAccountCategoryId = S.intAccountCategoryId
	WHERE M.intAccountId = A.intAccountId and S.intAccountStructureId = P.intAccountStructureId
)Cat