CREATE FUNCTION [dbo].[fnARCashFlowTransactions]
(
	 @dtmDateFrom	DATETIME = NULL
	,@dtmDateTo		DATETIME = NULL
)
RETURNS @returntable TABLE (
	 intTransactionId		INT NOT NULL
	,strTransactionId		NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL
	,strTransactionType		NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL
	,intCurrencyId			INT NOT NULL
	,dtmDate				DATETIME NOT NULL
	,dblAmount				DECIMAL(18, 6)
	,intBankAccountId		INT NULL
	,intGLAccountId			INT NOT NULL
	,intCompanyLocationId	INT NOT NULL
	,ysnPosted				BIT NOT NULL
)
AS
BEGIN
	DECLARE	 @intEntityUserId	INT = 1

	SELECT @intEntityUserId = intEntityId
	FROM tblEMEntityCredential
	WHERE strUserName = 'irelyadmin'

	INSERT INTO @returntable
	SELECT
		 intTransactionId		= ARCAST.intInvoiceId
		,strTransactionId		= ARCAST.strInvoiceNumber
		,strTransactionType		= ARCAST.strTransactionType
		,intCurrencyId			= ARCAST.intCurrencyId
		,dtmDate				= ARCAST.dtmDueDate
		,dblAmount				= SUM(dblTotalAR)
		,intBankAccountId		= CMUF.intBankAccountId
		,intGLAccountId			= ARCAST.intAccountId
		,intCompanyLocationId	= ARCAST.intCompanyLocationId
		,ysnPosted				= 1
	FROM [dbo].[fnARCustomerAgingDetail](@dtmDateFrom, @dtmDateTo, NULL, NULL, NULL, NULL, NULL, @intEntityUserId, NULL, 0, 0, 0, 0) ARCAST
	LEFT JOIN tblCMUndepositedFund CMUF ON strInvoiceNumber = CMUF.strSourceTransactionId AND strSourceSystem = 'AR'
	WHERE intEntityUserId = @intEntityUserId
	GROUP BY
		 ARCAST.intInvoiceId
		,ARCAST.strInvoiceNumber
		,ARCAST.strTransactionType
		,ARCAST.intCurrencyId
		,ARCAST.dtmDueDate
		,CMUF.intBankAccountId
		,ARCAST.intAccountId
		,ARCAST.intCompanyLocationId

	RETURN
END

GO