CREATE FUNCTION [dbo].[fnCMGetUndepositedFundsForCashFlowReport]
(
	@intBankAccountId INT,
    @dtmFrom DATETIME,
    @dtmTo DATETIME
)
RETURNS @returntable TABLE (
	 intTransactionId		INT NOT NULL
	,strTransactionId		NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL
	,intBankAccountId		INT NULL
	,intCurrencyId			INT NULL
	,dtmDate				DATETIME NOT NULL
	,dblAmount				DECIMAL(18, 6)
	,intGLAccountId			INT NULL
	,intCompanyLocationId	INT NULL
	,strTransactionType		NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
)
AS
BEGIN

    DECLARE @tblUndepositedFunds TABLE (
	     intTransactionId		INT NOT NULL
	    ,strTransactionId		NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL
	    ,intBankAccountId		INT NULL
	    ,intCurrencyId			INT NULL
	    ,dtmDate				DATETIME NOT NULL
	    ,dblAmount				DECIMAL(18, 6)
	    ,intGLAccountId			INT NULL
	    ,intCompanyLocationId	INT NULL
	    ,strTransactionType		NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
    )

    INSERT INTO @tblUndepositedFunds
    SELECT 
        intTransactionId = UF.intSourceTransactionId,
        strTransactionId = UF.strSourceTransactionId,
        intBankAccountId = UF.intBankAccountId,
        intCurrencyId = UF.intCurrencyId,
        dtmDate = UF.dtmDate,
        dblAmount = ISNULL(UF.dblAmount, 0),
        intGLAccountId = BA.intGLAccountId,
		intCompanyLocationId = UF.intLocationId,
        strTransactionType = UF.strPaymentMethod
    FROM [dbo].[tblCMUndepositedFund] UF
    JOIN [dbo].[tblCMBankAccount] BA
        ON BA.intBankAccountId = UF.intBankAccountId
    WHERE 
        UF.intBankAccountId = @intBankAccountId
        AND intBankDepositId IS NULL
        AND 
        (CASE WHEN @dtmFrom IS NOT NULL
            THEN CASE WHEN (UF.dtmDate BETWEEN @dtmFrom AND @dtmTo) THEN 1 ELSE 0 END
            ELSE CASE WHEN (UF.dtmDate <= @dtmTo) THEN 1 ELSE 0 END
            END
        ) = 1

    INSERT INTO @returntable
    SELECT
        intTransactionId = ARP.intPaymentId,
        strTransactionId = ARP.strRecordNumber,
        intBankAccountId = ARP.intBankAccountId,
        intCurrencyId = ARP.intCurrencyId,
        dtmDate = ARP.dtmDatePaid,
        dblAmount = ISNULL(ARP.dblAmountPaid, 0),
        intGLAccountId = BA.intGLAccountId,
		intCompanyLocationId = ARP.intLocationId,
        strTransactionType = ARP.strPaymentMethod
    FROM [dbo].[tblARPayment] ARP
    JOIN [dbo].[tblCMBankAccount] BA
        ON BA.intBankAccountId = ARP.intBankAccountId
    WHERE 
        ARP.intBankAccountId = @intBankAccountId
        AND ARP.ysnPosted = 1
        AND 
        (CASE WHEN @dtmFrom IS NOT NULL
            THEN CASE WHEN (ARP.dtmDatePaid BETWEEN @dtmFrom AND @dtmTo) THEN 1 ELSE 0 END
            ELSE CASE WHEN (ARP.dtmDatePaid <= @dtmTo) THEN 1 ELSE 0 END
            END
        ) = 1
        AND ARP.strRecordNumber NOT IN (SELECT strTransactionId FROM @tblUndepositedFunds)
    UNION ALL
    SELECT 
        intTransactionId,
        strTransactionId,
        intBankAccountId,
        intCurrencyId,
        dtmDate,
        dblAmount,
        intGLAccountId,
		intCompanyLocationId,
        strTransactionType
    FROM @tblUndepositedFunds

    RETURN
END