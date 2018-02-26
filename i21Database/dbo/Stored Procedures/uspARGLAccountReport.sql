CREATE PROCEDURE [dbo].[uspARGLAccountReport]
	@dtmAsOfDate			DATETIME = NULL
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

DECLARE @dtmAsOfDateLocal	DATETIME = @dtmAsOfDate

IF @dtmAsOfDateLocal IS NULL
    SET @dtmAsOfDateLocal = GETDATE()

TRUNCATE TABLE tblARGLSummaryStagingTable
INSERT INTO tblARGLSummaryStagingTable
SELECT intAccountId				= GL.intAccountId
	 , strAccountId				= GL.strAccountId
	 , strAccountCategory		= GL.strAccountCategory
	 , dblGLBalance				= ISNULL(GL.dblGLBalance, 0)
	 , dblTotalAR				= ISNULL(AGING.dblTotalAR, 0)
	 , dblTotalPrepayments		= ISNULL(AGING.dblTotalPrepayments, 0)
	 , dblTotalReportBalance	= ISNULL(AGING.dblTotalReportBalance, 0)
	 , dblGLReportBalance       = ISNULL(GL.dblGLReportBalance,0)
FROM (
	SELECT GLD.intAccountId
		 , strAccountId
		 , dblGLBalance         = SUM(dblDebit) - SUM(dblCredit)
		 , strAccountCategory
		 , dblGLReportBalance   = SUM(dblDebitReport) - SUM(dblCreditReport)
	FROM tblGLDetail GLD
		INNER JOIN vyuGLAccountDetail GLAD ON GLD.intAccountId = GLAD.intAccountId
			AND GLAD.strAccountCategory = 'AR Account'
	WHERE GLD.ysnIsUnposted = 0
	AND GLD.dtmDate <= @dtmAsOfDateLocal
	GROUP BY GLD.intAccountId, GLAD.strAccountId, strAccountCategory
	HAVING ISNULL(SUM(dblDebit) - SUM(dblCredit), 0) <> 0.00 OR 
			ISNULL(SUM(dblDebitReport) - SUM(dblCreditReport), 0) <> 0.00

	UNION ALL 

	SELECT GLD.intAccountId
		 , strAccountId
		 , dblGLBalance         = SUM(dblDebit) - SUM(dblCredit)
		 , strAccountCategory
		 , dblGLReportBalance   = SUM(dblDebitReport) - SUM(dblCreditReport)
	FROM tblGLDetail GLD
		INNER JOIN vyuGLAccountDetail GLAD ON GLD.intAccountId = GLAD.intAccountId
			AND GLAD.strAccountCategory = 'Customer Prepayments'
	WHERE GLD.ysnIsUnposted = 0
	AND GLD.dtmDate <= @dtmAsOfDateLocal
	GROUP BY GLD.intAccountId, GLAD.strAccountId, strAccountCategory
	HAVING ISNULL(SUM(dblDebit) - SUM(dblCredit), 0) <> 0.00 OR 
			ISNULL(SUM(dblDebitReport) - SUM(dblCreditReport), 0) <> 0.00
) GL
OUTER APPLY (
	SELECT dblTotalAR				= SUM(dblTotalAR) + ABS(SUM(dblPrepayments))
	     , dblTotalPrepayments		= SUM(dblPrepayments)
		 , dblTotalReportBalance    = SUM(dblTotalAR)
	FROM tblARCustomerAgingStagingTable
) AGING