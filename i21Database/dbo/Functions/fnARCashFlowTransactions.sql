﻿CREATE FUNCTION [dbo].[fnARCashFlowTransactions]
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

	SELECT TOP 1 @intEntityUserId = S.intEntityId
	FROM tblSMUserSecurity S
	WHERE S.ysnAdmin = 1 
	ORDER BY S.intEntityId ASC

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
	FROM [dbo].[fnARCustomerAgingDetail](NULL, @dtmDateTo, NULL, NULL, NULL, NULL, NULL NULL, @intEntityUserId, NULL, 0, 0, 0, 1) ARCAST
	LEFT JOIN tblCMUndepositedFund CMUF ON strInvoiceNumber = CMUF.strSourceTransactionId AND strSourceSystem = 'AR'
	WHERE intEntityUserId = @intEntityUserId
	AND (@dtmDateFrom IS NULL OR ARCAST.dtmDueDate >= @dtmDateFrom)
	AND (@dtmDateTo IS NULL OR ARCAST.dtmDueDate <= @dtmDateTo)
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