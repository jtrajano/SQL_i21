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
    LEFT JOIN [dbo].[tblCMUndepositedFund] UF
		ON UF.intSourceTransactionId = ARP.intPaymentId AND UF.strSourceTransactionId = ARP.strRecordNumber
    WHERE 
        ARP.intBankAccountId = @intBankAccountId
        AND ARP.ysnPosted = 1
        AND 
        (CASE WHEN @dtmFrom IS NOT NULL
            THEN CASE WHEN (ARP.dtmDatePaid BETWEEN @dtmFrom AND @dtmTo) THEN 1 ELSE 0 END
            ELSE CASE WHEN (ARP.dtmDatePaid <= @dtmTo) THEN 1 ELSE 0 END
            END
        ) = 1
		AND UF.intBankDepositId IS NULL

    RETURN
END