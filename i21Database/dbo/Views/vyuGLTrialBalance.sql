CREATE VIEW [dbo].[vyuGLTrialBalance] AS
SELECT 
TBSum.MTDBalance,
TBSum.YTDBalance,
A.intAccountId,
ISNULL(strAccountCategory,'') COLLATE Latin1_General_CI_AS strAccountCategory,
ISNULL(strAccountGroup,'') COLLATE Latin1_General_CI_AS strAccountGroup,
ISNULL( A.strAccountId,'')  COLLATE Latin1_General_CI_AS strAccountId,
ISNULL(strAccountType,'') COLLATE Latin1_General_CI_AS strAccountType ,
ISNULL(A.strCashFlow,'') COLLATE Latin1_General_CI_AS strCashFlow,
SUBSTRING(A.strAccountId, 1, P1.intLength)COLLATE Latin1_General_CI_AS strPrimaryCode ,
SUBSTRING(A.strAccountId, P1.intLength+ 2, P2.intLength)COLLATE Latin1_General_CI_AS strLocationCode ,
SUBSTRING(A.strAccountId, P1.intLength + P3.intLength + 4, P3.intLength)COLLATE Latin1_General_CI_AS strLOBCode ,
ISNULL(A.strComments,'') COLLATE Latin1_General_CI_AS strComments,
ISNULL(strCurrency,'') COLLATE Latin1_General_CI_AS strCurrency,
ISNULL(coa.strCurrentExternalId,'') COLLATE Latin1_General_CI_AS  strCurrentExternalId,
ISNULL(A.strDescription,'') COLLATE Latin1_General_CI_AS strDescription,
ISNULL(coa.strExternalId,'') COLLATE Latin1_General_CI_AS strExternalId,
ISNULL(A.strNote,'') COLLATE Latin1_General_CI_AS strNote,
ISNULL(strUOMCode,'') COLLATE Latin1_General_CI_AS strUOMCode,
ISNULL(A.ysnActive,0) ysnActive,
TBSum.dtmDateFrom,
TBSum.dtmDateTo,
TBSum.intGLFiscalYearPeriodId,
TBSum.strPeriod
FROM vyuGLAccountDetail A
LEFT JOIN tblGLCOACrossReference coa ON A.intAccountId =coa.inti21Id 
outer APPLY(
	SELECT top 1 intLength, intAccountStructureId FROM tblGLAccountStructure WHERE strType = 'Primary'
)P1 
outer APPLY(
	SELECT top 1 intLength, intAccountStructureId FROM tblGLAccountStructure WHERE strStructureName = 'Location'
)P2 
outer APPLY(
	SELECT top 1 intLength, intAccountStructureId FROM tblGLAccountStructure WHERE strStructureName = 'LOB'
)P3
OUTER APPLY (

	SELECT SUM(ISNULL(MTDBalance,0))MTDBalance, 
	SUM(ISNULL(YTDBalance,0))YTDBalance,
	dtmStartDate dtmDateFrom, 
	dtmEndDate dtmDateTo,
	TB.intGLFiscalYearPeriodId,
	TB.strPeriod
	FROM tblGLTrialBalance TB
	JOIN tblGLFiscalYearPeriod FYP ON FYP.intGLFiscalYearPeriodId = TB.intGLFiscalYearPeriodId
	WHERE intAccountId = A.intAccountId
	GROUP BY intAccountId, TB.intGLFiscalYearPeriodId,dtmStartDate,dtmEndDate, TB.strPeriod
)TBSum