CREATE PROCEDURE [dbo].[uspARGLAccountReport]
	  @dtmAsOfDate			DATETIME = NULL
	, @intEntityUserId		INT = NULL
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

DECLARE @dtmAsOfDateLocal	DATETIME = @dtmAsOfDate

IF @dtmAsOfDateLocal IS NULL
    SET @dtmAsOfDateLocal = CAST(FLOOR(CAST(GETDATE() AS FLOAT)) AS DATETIME)

DELETE FROM tblARGLSummaryStagingTable WHERE intEntityUserId = @intEntityUserId
INSERT INTO tblARGLSummaryStagingTable
SELECT intAccountId				= GL.intAccountId	 
	 , intEntityUserId			= @intEntityUserId
	 , strAccountId				= GL.strAccountId
	 , strAccountCategory		= GL.strAccountCategory
	 , dblGLBalance				= ISNULL(GL.dblGLBalance, 0)
	 , dblTotalAR				= ISNULL(AGING.dblTotalAR, 0)
	 , dblTotalPrepayments		= ISNULL(AGING.dblTotalPrepayments, 0)
	 , dblTotalReportBalance	= ISNULL(AGING.dblTotalReportBalance, 0)	 
FROM (
	SELECT GLD.intAccountId
		 , strAccountId
		 , dblGLBalance         = SUM(dblDebit) - SUM(dblCredit)
		 , strAccountCategory
	FROM tblGLDetail GLD
		INNER JOIN vyuGLAccountDetail GLAD ON GLD.intAccountId = GLAD.intAccountId
			AND GLAD.strAccountCategory = 'AR Account'
	WHERE GLD.ysnIsUnposted = 0
	AND CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), GLD.dtmDate))) <= @dtmAsOfDateLocal
	GROUP BY GLD.intAccountId, GLAD.strAccountId, strAccountCategory
	HAVING ISNULL(SUM(dblDebit) - SUM(dblCredit), 0) <> 0.00

	UNION ALL 

	SELECT GLD.intAccountId
		 , strAccountId
		 , dblGLBalance         = SUM(dblDebit) - SUM(dblCredit)
		 , strAccountCategory
	FROM tblGLDetail GLD
		INNER JOIN vyuGLAccountDetail GLAD ON GLD.intAccountId = GLAD.intAccountId
			AND GLAD.strAccountCategory = 'Customer Prepayments'
	WHERE GLD.ysnIsUnposted = 0
	AND CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), GLD.dtmDate))) <= @dtmAsOfDateLocal
	GROUP BY GLD.intAccountId, GLAD.strAccountId, strAccountCategory
	HAVING ISNULL(SUM(dblDebit) - SUM(dblCredit), 0) <> 0.00
) GL
OUTER APPLY (
	SELECT dblTotalAR				= SUM(dblTotalAR) + ABS(SUM(dblPrepayments))
	     , dblTotalPrepayments		= SUM(dblPrepayments)
		 , dblTotalReportBalance    = SUM(dblTotalAR)
	FROM tblARCustomerAgingStagingTable
	WHERE intEntityUserId = @intEntityUserId
	  AND strAgingType = 'Summary'
) AGING