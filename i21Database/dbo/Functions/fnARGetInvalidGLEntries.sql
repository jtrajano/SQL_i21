CREATE FUNCTION [dbo].[fnARGetInvalidGLEntries] (
	  @GLEntries RecapTableType READONLY
	, @ysnPost	BIT = 0
)
RETURNS @tblInvalid TABLE (
	  strTransactionId	NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL
	, strText			nvarchar(150)  COLLATE Latin1_General_CI_AS NULL
	, intErrorCode		INT
	, strModuleName		NVARCHAR(100)  COLLATE Latin1_General_CI_AS NULL
)
AS
BEGIN 	
	INSERT INTO @tblInvalid (
		  strTransactionId
		, strText
		, intErrorCode
		, strModuleName
	)
	SELECT strTransactionId	= I.strInvoiceNumber
		 , strText			= I.strInvoiceNumber + ' has discrepancy on AR Account of ' + LTRIM(STR(ISNULL(I.dblBaseInvoiceTotal, 0) - (ISNULL(ENTRIES.dblAmount, 0) + ISNULL(GL.dblAmount, 0)), 16, 2))
		 , intErrorCode		= 1
		 , strModuleName	= ENTRIES.strModuleName
	FROM dbo.tblARInvoice I
	INNER JOIN (
		SELECT intTransactionId		= GLE.intTransactionId
			 , strTransactionId		= GLE.strTransactionId
			 , strModuleName		= GLE.strModuleName
			 , dblAmount			= SUM(dblDebit - dblCredit)
		FROM @GLEntries GLE
		INNER JOIN vyuGLAccountDetail GLAD ON GLE.intAccountId = GLAD.intAccountId	
		WHERE GLAD.strAccountCategory = 'AR Account'
		GROUP BY GLE.intTransactionId, GLE.strTransactionId, GLE.strModuleName
	) ENTRIES ON I.intInvoiceId = ENTRIES.intTransactionId AND I.strInvoiceNumber = ENTRIES.strTransactionId
	INNER JOIN (
		SELECT intTransactionId		= GL.intTransactionId
			 , strTransactionId		= GL.strTransactionId
			 , dblAmount			= SUM(dblDebit - dblCredit)
		FROM tblGLDetail GL
		INNER JOIN vyuGLAccountDetail GLAD ON GL.intAccountId = GLAD.intAccountId
		WHERE GL.ysnIsUnposted = 0
		  AND GLAD.strAccountCategory = 'AR Account'
		GROUP BY GL.intTransactionId, GL.strTransactionId, GL.strModuleName
	) GL ON GL.intTransactionId = ENTRIES.intTransactionId AND GL.strTransactionId = ENTRIES.strTransactionId
	WHERE ISNULL(I.dblBaseInvoiceTotal, 0) - (ISNULL(ENTRIES.dblAmount, 0) + ISNULL(GL.dblAmount, 0)) <> 0.000000
	  AND @ysnPost = 1
	ORDER BY strTransactionId

	RETURN
		
END