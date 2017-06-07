CREATE  FUNCTION [dbo].[fnGLGetJournalExport](@intJournalId INT)
RETURNS  @tbl TABLE(
	strAccountId NVARCHAR(40),
	strDescription NVARCHAR(255),
	dtmDate VARCHAR(20),
	strDebitCredit VARCHAR(1),
	dblAmount NUMERIC(18,6),
	dblUnit NUMERIC(18,6),
	strCorrecting VARCHAR(1),
	intLineNo INT,
	strDocument NVARCHAR(100),
	strComments NVARCHAR(255),
	strReference NVARCHAR(100),
	strCurrencyExchangeRateType NVARCHAR(20)
)
as
BEGIN
	INSERT INTO @tbl
	SELECT 
		A.strAccountId 
		,RTRIM(D.strDescription) strDescription
		,CONVERT(VARCHAR(20),dtmDate,101) dtmDate
		,CASE WHEN	dblDebit > dblCredit THEN 'D' ELSE 'C'END strDebitCredit
		,CASE WHEN tsp.intDefaultCurrencyId = A.intCurrencyID 
			THEN dblDebit + dblCredit 
			ELSE D.dblDebitForeign + D.dblCreditForeign 
			END dblAmount
		,CASE WHEN dblDebit > dblCredit 
			THEN dblDebitUnit ELSE dblCreditUnit 
			END dblUnit
		,CASE WHEN strCorrecting is null OR LEN(RTRIM(strCorrecting)) = 0 
			THEN 'N' ELSE strCorrecting 
			END AS strCorrecting
		,ROW_NUMBER() OVER (ORDER BY dtmDate)as intLineNo
		,strDocument
		,D.strComments
		,strReference 
		,tsert.strCurrencyExchangeRateType
	FROM tblGLJournalDetail D 
		LEFT JOIN tblGLAccount A ON A.intAccountId = D.intAccountId 
		LEFT JOIN dbo.tblSMCurrencyExchangeRateType tsert ON tsert.intCurrencyExchangeRateTypeId = D.intCurrencyExchangeRateTypeId
		CROSS APPLY(SELECT intDefaultCurrencyId FROM dbo.tblSMCompanyPreference)tsp
	WHERE intJournalId = @intJournalId
	RETURN
END
