--ADD LOB IF COLUMN / SEGMENT IS EXISTING IN THE STRUCTURE

DECLARE @Lob NVARCHAR(10) ='', @Company  NVARCHAR(10) = '',
@LobQuery NVARCHAR(100), @CompanyQuery NVARCHAR(100)

SET @Lob = ''
SET @LobQuery = ''''' COLLATE Latin1_General_CI_AS strLOBCode ,'

SET @Company = ''
SET @CompanyQuery = ''''' COLLATE Latin1_General_CI_AS strCompanySegment ,'

IF COL_LENGTH('tblGLTempCOASegment','LOB') IS NOT NULL 
BEGIN
	SET @Lob = ',[LOB]'
	SET @LobQuery = 'Segment.[LOB] COLLATE Latin1_General_CI_AS strLOBCode ,'
END

IF COL_LENGTH('tblGLTempCOASegment','Company') IS NOT NULL 
BEGIN
	SET @Company = ',[Company]'
	SET @CompanyQuery = 'Segment.[Company] COLLATE Latin1_General_CI_AS strCompanySegment ,'
END

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
Segment.[Location] COLLATE Latin1_General_CI_AS strLocationCode ,' +
@LobQuery + @CompanyQuery +
'ISNULL(A.strComments,'''') COLLATE Latin1_General_CI_AS strComments,
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
	SELECT TOP 1 [Primary Account],[Location]' + @Lob +  @Company +'FROM tblGLTempCOASegment WHERE intAccountId = A.intAccountId
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