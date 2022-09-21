CREATE FUNCTION [dbo].[fnGLGetJournalSubledgerExport]
(
	@intJournalId INT
)
RETURNS  @tbl TABLE(
	strAccountId NVARCHAR(40)COLLATE Latin1_General_CI_AS,
	strDescription NVARCHAR(255) COLLATE Latin1_General_CI_AS,
	dtmDate VARCHAR(20),
	dblRate NUMERIC(18,6),
	strDebitCredit VARCHAR(1) COLLATE Latin1_General_CI_AS,
	dblAmount NUMERIC(18,6),
	strForeignDebitCredit VARCHAR(1) COLLATE Latin1_General_CI_AS,
	dblAmountForeign NUMERIC(18,6),
	dblUnit NUMERIC(18,6),
	strCorrecting VARCHAR(1) COLLATE Latin1_General_CI_AS,
	intLineNo INT,
	strDocument NVARCHAR(100) COLLATE Latin1_General_CI_AS,
	strComments NVARCHAR(255) COLLATE Latin1_General_CI_AS,
	strReference NVARCHAR(100) COLLATE Latin1_General_CI_AS,
	strCurrencyExchangeRateType NVARCHAR(20) COLLATE Latin1_General_CI_AS,
	strLedgerName NVARCHAR (255) COLLATE Latin1_General_CI_AS,
	strSubledgerName NVARCHAR (255) COLLATE Latin1_General_CI_AS 
)
as
BEGIN
	INSERT INTO @tbl
	SELECT 
		A.strAccountId 
		,RTRIM(D.strDescription) strDescription
		,CONVERT(VARCHAR(20),dtmDate,101) dtmDate
		,ISNULL((CASE WHEN (D.dblCreditRate > 0) THEN D.dblCreditRate ELSE D.dblDebitRate END), 1) dblRate
		,CASE WHEN	dblDebit > dblCredit THEN 'D' ELSE 'C'END strDebitCredit
		,(D.dblDebit + D.dblCredit) dblAmount
		,CASE WHEN	dblDebitForeign > dblCreditForeign THEN 'D' ELSE 'C'END strForeignDebitCredit
		,(D.dblDebitForeign + D.dblCreditForeign) dblAmountForeign
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
		,L.strLedgerName strLedgerName
		,LD.strLedgerName strSubledgerName
	FROM tblGLJournalDetail D 
		LEFT JOIN tblGLAccount A ON A.intAccountId = D.intAccountId 
		LEFT JOIN dbo.tblSMCurrencyExchangeRateType tsert ON tsert.intCurrencyExchangeRateTypeId = D.intCurrencyExchangeRateTypeId
		LEFT JOIN dbo.tblGLLedger L ON L.intLedgerId = D.intLedgerId
		LEFT JOIN dbo.tblGLLedgerDetail LD ON LD.intLedgerDetailId = D.intSubledgerId
		CROSS APPLY(SELECT intDefaultCurrencyId FROM dbo.tblSMCompanyPreference)tsp
	WHERE intJournalId = @intJournalId
	RETURN
END