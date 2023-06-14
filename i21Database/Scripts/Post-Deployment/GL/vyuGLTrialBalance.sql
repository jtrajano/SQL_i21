--ADD LOB IF COLUMN / SEGMENT IS EXISTING IN THE STRUCTURE

IF COL_LENGTH('tblGLTempCOASegment','LOB') IS NOT NULL 
EXEC(
'ALTER VIEW [dbo].[vyuGLTrialBalance] AS
SELECT 
TBSum.MTDBalance,
TBSum.YTDBalance,
A.intAccountId,
ISNULL(strAccountCategory,'''') COLLATE Latin1_General_CI_AS strAccountCategory,
ISNULL(strAccountGroup,'''') COLLATE Latin1_General_CI_AS strAccountGroup,
ISNULL( A.strAccountId,'''')  COLLATE Latin1_General_CI_AS strAccountId,
ISNULL(strAccountType,'''') COLLATE Latin1_General_CI_AS strAccountType ,
ISNULL(A.strCashFlow,'''') COLLATE Latin1_General_CI_AS strCashFlow,
Segment.[Primary Account] COLLATE Latin1_General_CI_AS strPrimaryCode ,
Segment.[Location] COLLATE Latin1_General_CI_AS strLocationCode ,
Segment.[LOB] COLLATE Latin1_General_CI_AS strLOBCode ,
ISNULL(A.strComments,'''') COLLATE Latin1_General_CI_AS strComments,
ISNULL(strCurrency,'''') COLLATE Latin1_General_CI_AS strCurrency,
ISNULL(coa.strCurrentExternalId,'''') COLLATE Latin1_General_CI_AS  strCurrentExternalId,
ISNULL(A.strDescription,'''') COLLATE Latin1_General_CI_AS strDescription,
ISNULL(coa.strExternalId,'''') COLLATE Latin1_General_CI_AS strExternalId,
ISNULL(A.strNote,'''') COLLATE Latin1_General_CI_AS strNote,
ISNULL(strUOMCode,'''') COLLATE Latin1_General_CI_AS strUOMCode,
ISNULL(A.ysnActive,0) ysnActive,
TBSum.dtmDateFrom,
TBSum.dtmDateTo,
TBSum.intGLFiscalYearPeriodId,
TBSum.strPeriod
FROM vyuGLAccountDetail A
LEFT JOIN tblGLCOACrossReference coa ON A.intAccountId =coa.inti21Id 
OUTER APPLY(
	SELECT TOP 1 [Primary Account],[Location],[LOB] FROM tblGLTempCOASegment WHERE intAccountId = A.intAccountId
)Segment
OUTER APPLY (

	SELECT SUM(ISNULL(MTDBalance,0))MTDBalance, 
	SUM(ISNULL(YTDBalance,0))YTDBalance,
	dtmStartDate dtmDateFrom, 
	dtmEndDate dtmDateTo,
	TB.intGLFiscalYearPeriodId,
	FYP.strPeriod
	FROM tblGLTrialBalance TB
	JOIN tblGLFiscalYearPeriod FYP ON FYP.intGLFiscalYearPeriodId = TB.intGLFiscalYearPeriodId
	WHERE intAccountId = A.intAccountId
	GROUP BY intAccountId, TB.intGLFiscalYearPeriodId,dtmStartDate,dtmEndDate, FYP.strPeriod
)TBSum')
GO