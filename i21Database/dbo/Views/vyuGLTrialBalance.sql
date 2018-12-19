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
ISNULL(Cat.strAccountCategory COLLATE Latin1_General_CI_AS, '') strAccountCategory,
ISNULL(strAccountGroup COLLATE Latin1_General_CI_AS,'') strAccountGroup,
ISNULL( A.strAccountId COLLATE Latin1_General_CI_AS,'') strAccountId,
ISNULL(G.strAccountType COLLATE Latin1_General_CI_AS,'')strAccountType ,
ISNULL(A.strCashFlow COLLATE Latin1_General_CI_AS,'')strCashFlow,
SUBSTRING(A.strAccountId COLLATE Latin1_General_CI_AS, 1, P.intLength) strCode ,
ISNULL(A.strComments COLLATE Latin1_General_CI_AS,'') strComments,
ISNULL(strCurrency COLLATE Latin1_General_CI_AS,'') strCurrency,
ISNULL(coa.strCurrentExternalId COLLATE Latin1_General_CI_AS,'') strCurrentExternalId,
ISNULL(A.strDescription COLLATE Latin1_General_CI_AS,'') strDescription,
ISNULL(coa.strExternalId COLLATE Latin1_General_CI_AS,'')strExternalId,
ISNULL(A.strNote COLLATE Latin1_General_CI_AS,'')strNote,
ISNULL(U.strUOMCode COLLATE Latin1_General_CI_AS,'')strUOMCode,
ISNULL(A.ysnActive,0) ysnActive,
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
OUTER APPLY(
	SELECT TOP 1 C.strAccountCategory FROM tblGLAccountSegmentMapping M 
	JOIN tblGLAccountSegment S on S.intAccountSegmentId = M.intAccountSegmentId
	JOIN tblGLAccountCategory C on C.intAccountCategoryId = S.intAccountCategoryId
	WHERE M.intAccountId = A.intAccountId and S.intAccountStructureId = P.intAccountStructureId
)Cat