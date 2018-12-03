CREATE VIEW [dbo].[vyuGLTrialBalance] AS
SELECT 
ISNULL(B.MTDBalance,0)MTDBalance,
ISNULL(B.YTDBalance,0)YTDBalance,
A.intAccountId,
ISNULL(Cat.strAccountCategory, '') strAccountCategory,
ISNULL(strAccountGroup,'') strAccountGroup,
ISNULL( A.strAccountId,'') strAccountId,
ISNULL(G.strAccountType,'')strAccountType ,
ISNULL(A.strCashFlow,'')strCashFlow,
SUBSTRING(A.strAccountId, 1, P.intLength) strCode ,
ISNULL(A.strComments,'') strComments,
ISNULL(strCurrency,'') strCurrency,
ISNULL(coa.strCurrentExternalId,'') strCurrentExternalId,
ISNULL(A.strDescription,'') strDescription,
ISNULL(coa.strExternalId,'')strExternalId,
ISNULL(A.strNote,'')strNote,
ISNULL(U.strUOMCode,'')strUOMCode,
ISNULL(A.ysnActive,0) ysnActive,
period.dtmStartDate dtmDateFrom,
period.dtmEndDate dtmDateTo,
B.intGLFiscalYearPeriodId
FROM tblGLAccount A
LEFT JOIN tblGLCOACrossReference coa ON A.intAccountId =coa.inti21Id 
LEFT JOIN tblGLTrialBalance B ON A.intAccountId = B.intAccountId
LEFT JOIN tblGLFiscalYearPeriod period on period.intGLFiscalYearPeriodId = B.intGLFiscalYearPeriodId
LEFT JOIN tblSMCurrency C on C.intCurrencyID = A.intCurrencyID
LEFT JOIN tblGLAccountGroup G ON G.intAccountGroupId = A.intAccountGroupId
LEFT JOIN tblGLAccountUnit U on U.intAccountUnitId = A.intAccountUnitId
CROSS APPLY(
	SELECT top 1 intLength, intAccountStructureId FROM tblGLAccountStructure WHERE strType = 'Primary'
)P
OUTER APPLY(
	SELECT TOP 1 C.strAccountCategory FROM tblGLAccountSegmentMapping M 
	JOIN tblGLAccountSegment S on S.intAccountSegmentId = M.intAccountSegmentId
	JOIN tblGLAccountCategory C on C.intAccountCategoryId = S.intAccountCategoryId
	WHERE M.intAccountId = A.intAccountId and S.intAccountStructureId = P.intAccountStructureId
)Cat
GO

