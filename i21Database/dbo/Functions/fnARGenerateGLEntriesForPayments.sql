CREATE FUNCTION [dbo].[fnARGenerateGLEntriesForPayments]
(
      @Payments	        [dbo].[ReceivePaymentPostingTable] Readonly
     ,@AROverpayment    [dbo].[Id] Readonly
     ,@ARPrepayment     [dbo].[Id] Readonly
)
RETURNS @returntable TABLE
(
     [dtmDate]                      DATETIME        NOT NULL
    ,[strBatchId]                   NVARCHAR(40)    COLLATE Latin1_General_CI_AS NULL
    ,[intAccountId]                 INT             NULL
    ,[dblDebit]                     NUMERIC(18,6)   NULL
    ,[dblCredit]                    NUMERIC(18,6)   NULL
    ,[dblDebitUnit]                 NUMERIC(18,6)   NULL
    ,[dblCreditUnit]                NUMERIC(18,6)   NULL
    ,[strDescription]               NVARCHAR(255)   COLLATE Latin1_General_CI_AS NULL
    ,[strCode]                      NVARCHAR(40)    COLLATE Latin1_General_CI_AS NULL
    ,[strReference]                 NVARCHAR(255)   COLLATE Latin1_General_CI_AS NULL
    ,[intCurrencyId]                INT             NULL
    ,[dblExchangeRate]              NUMERIC(38,20)  DEFAULT 1 NOT NULL
    ,[dtmDateEntered]               DATETIME        NOT NULL
    ,[dtmTransactionDate]           DATETIME        NULL
    ,[strJournalLineDescription]    NVARCHAR(250)   COLLATE Latin1_General_CI_AS NULL
    ,[intJournalLineNo]             INT             NULL
    ,[ysnIsUnposted]                BIT             NOT NULL
    ,[intUserId]                    INT             NULL
    ,[intEntityId]                  INT             NULL
    ,[strTransactionId]             NVARCHAR(40)    COLLATE Latin1_General_CI_AS NULL
    ,[intTransactionId]             INT             NULL
    ,[strTransactionType]           NVARCHAR(255)   COLLATE Latin1_General_CI_AS NOT NULL
    ,[strTransactionForm]           NVARCHAR(255)   COLLATE Latin1_General_CI_AS NOT NULL
    ,[strModuleName]                NVARCHAR(255)   COLLATE Latin1_General_CI_AS NOT NULL
    ,[intConcurrencyId]             INT             DEFAULT 1 NOT NULL
    ,[dblDebitForeign]              NUMERIC(18,9)   NULL
    ,[dblDebitReport]               NUMERIC(18,9)   NULL
    ,[dblCreditForeign]             NUMERIC(18,9)   NULL
    ,[dblCreditReport]              NUMERIC(18,9)   NULL
    ,[dblReportingRate]             NUMERIC(18,9)   NULL
    ,[dblForeignRate]               NUMERIC(18,9)   NULL
    ,[strRateType]                  NVARCHAR(50)    COLLATE Latin1_General_CI_AS
    ,[strDocument]                  NVARCHAR(255)   COLLATE Latin1_General_CI_AS NULL
    ,[strComments]                  NVARCHAR(255)   COLLATE Latin1_General_CI_AS NULL
    ,[strSourceDocumentId]          NVARCHAR(50)    COLLATE Latin1_General_CI_AS
    ,[intSourceLocationId]          INT             NULL
    ,[intSourceUOMId]		        INT             NULL
    ,[dblSourceUnitDebit]           NUMERIC(18,6)   NULL
    ,[dblSourceUnitCredit]          NUMERIC(18,6)    NULL
    ,[intCommodityId]               INT        NULL
    ,[intSourceEntityId]            INT        NULL
    ,[ysnRebuild]                   BIT        NULL

)
AS
BEGIN

DECLARE @ZeroDecimal    DECIMAL(18,6)
SET @ZeroDecimal = 0.000000

DECLARE @MODULE_NAME NVARCHAR(25) = 'Accounts Receivable'
DECLARE @SCREEN_NAME NVARCHAR(25) = 'Receive Payments'
DECLARE @CODE NVARCHAR(25) = 'AR'
DECLARE @POSTDESC NVARCHAR(10) = 'Posted '

INSERT @returntable
    ([dtmDate]
    ,[strBatchId]
    ,[intAccountId]
    ,[dblDebit]
    ,[dblCredit]
    ,[dblDebitUnit]
    ,[dblCreditUnit]
    ,[strDescription]
    ,[strCode]
    ,[strReference]
    ,[intCurrencyId]
    ,[dblExchangeRate]
    ,[dtmDateEntered]
    ,[dtmTransactionDate]
    ,[strJournalLineDescription]
    ,[intJournalLineNo]
    ,[ysnIsUnposted]
    ,[intUserId]
    ,[intEntityId]
    ,[strTransactionId]
    ,[intTransactionId]
    ,[strTransactionType]
    ,[strTransactionForm]
    ,[strModuleName]
    ,[intConcurrencyId]
    ,[dblDebitForeign]
    ,[dblDebitReport]
    ,[dblCreditForeign]
    ,[dblCreditReport]
    ,[dblReportingRate]
    ,[dblForeignRate]
    ,[strRateType]
    ,[strDocument]
    ,[strComments]
    ,[strSourceDocumentId]
    ,[intSourceLocationId]
    ,[intSourceUOMId]
    ,[dblSourceUnitDebit]
    ,[dblSourceUnitCredit]
    ,[intCommodityId]
    ,[intSourceEntityId]
    ,[ysnRebuild])

--DEBIT
SELECT
	--	dtmDate					= CAST(A.dtmDatePaid AS DATE)
	--,strBatchID					= @batchId			
	--,intAccountId				= CASE WHEN UPPER(RTRIM(LTRIM(A.strPaymentMethod))) = UPPER('Write Off') THEN A.intWriteOffAccountId
	--								WHEN UPPER(RTRIM(LTRIM(A.strPaymentMethod))) = UPPER('CF Invoice') THEN ISNULL(A.intWriteOffAccountId, @intCFAccount)
	--								ELSE A.intAccountId
	--								END
	--,dblDebit					= (CASE WHEN (B.dblBaseAmountDue = (B.dblBasePayment - B.dblBaseInterest) + B.dblBaseDiscount)
	--									THEN (B.dblBasePayment - B.dblBaseInterest)  + B.dblBaseDiscount
	--									ELSE B.dblBasePayment END)
	--								* (CASE WHEN ISNULL(A.ysnInvoicePrepayment,0) = 1 THEN -1 ELSE 1 END)
	--,dblCredit					= 0
	--,dblDebitUnit				= 0
	--,dblCreditUnit				= 0
	--,strDescription				= A.strNotes 
	--,strCode					= @CODE
	--,strReference				= C.strCustomerNumber
	--,intCurrencyId				= A.intCurrencyId 
	--,dblExchangeRate			= 1
	--,dtmDateEntered				= @PostDate
	--,dtmTransactionDate			= A.dtmDatePaid
	--,strJournalLineDescription	= @POSTDESC + @SCREEN_NAME 
	--,intJournalLineNo			= A.intPaymentId
	--,ysnIsUnposted				= 0
	--,intUserId					= @userId
	--,intEntityId				= @UserEntityID				
	--,strTransactionId			= A.strRecordNumber
	--,intTransactionId			= A.intPaymentId
	--,strTransactionType			= @SCREEN_NAME
	--,strTransactionForm			= @SCREEN_NAME
	--,strModuleName				= @MODULE_NAME
	--,intConcurrencyId			= 1
	--,[dblDebitForeign]			= A.dblAmountPaid * (CASE WHEN ISNULL(A.ysnInvoicePrepayment,0) = 1 THEN -1 ELSE 1 END)
	--,[dblDebitReport]			= A.dblBaseAmountPaid * (CASE WHEN ISNULL(A.ysnInvoicePrepayment,0) = 1 THEN -1 ELSE 1 END)
	--,[dblCreditForeign]			= 0
	--,[dblCreditReport]			= 0
	--,[dblReportingRate]			= 0
	--,[dblForeignRate]			= 0
	--,[strRateType]				= ''			 
	--FROM
	--tblARPayment A		
	--INNER JOIN
	--tblARPaymentDetail B
	--	ON A.intPaymentId = B.intPaymentId and B.dblBasePayment <> 0
	--INNER JOIN
	--tblSMPaymentMethod PM
	--	ON A.intPaymentMethodId = PM.intPaymentMethodID
	--INNER JOIN
	--tblARCustomer C
	--	ON A.[intEntityCustomerId] = C.[intEntityId]
	--INNER JOIN
	--@ARReceivablePostData P
	--	ON A.intPaymentId = P.intPaymentId
     [dtmDate]                      = P.[dtmDatePaid]
    ,[strBatchId]                   = P.[strBatchId]
    ,[intAccountId]                 = (CASE WHEN UPPER(RTRIM(LTRIM(P.[strPaymentMethod]))) = UPPER('Write Off') THEN P.[intWriteOffAccountId]
                                            WHEN UPPER(RTRIM(LTRIM(P.[strPaymentMethod]))) = UPPER('CF Invoice') THEN ISNULL(P.[intWriteOffAccountId], P.[intCFAccountId])
                                            ELSE P.[intAccountId]
                                      END)
    --,[dblDebit]                     = (CASE WHEN (P.[dblBaseAmountDue] = (P.[dblBasePayment] - P.[dblBaseInterest]) + P.[dblBaseDiscount])
    --                                        THEN (P.[dblBasePayment] - P.[dblBaseInterest])  + P.[dblBaseDiscount]
    --                                        ELSE P.[dblBasePayment]
    --                                   END)
    --                                        * (CASE WHEN ISNULL(P.[ysnInvoicePrepayment],0) = 1 THEN -1 ELSE 1 END)
    ,[dblDebit]                     = P.[dblBaseAmountPaid] * (CASE WHEN ISNULL(P.[ysnInvoicePrepayment],0) = 1 THEN -1 ELSE 1 END)
    ,[dblCredit]                    = @ZeroDecimal
    ,[dblDebitUnit]                 = @ZeroDecimal
    ,[dblCreditUnit]                = @ZeroDecimal
    ,[strDescription]               = P.[strNotes]
    ,[strCode]                      = @CODE
    ,[strReference]                 = P.[strCustomerNumber]
    ,[intCurrencyId]                = P.[intCurrencyId]
    ,[dblExchangeRate]              = ISNULL(NULLIF(P.dblBaseAmountPaid, 0), 1)/ISNULL(NULLIF(P.dblAmountPaid, 0), 1)
    ,[dtmDateEntered]               = P.[dtmPostDate]
    ,[dtmTransactionDate]           = P.[dtmDatePaid]
    ,[strJournalLineDescription]    = @POSTDESC + @SCREEN_NAME 
    ,[intJournalLineNo]             = P.[intTransactionId]
    ,[ysnIsUnposted]                = 0
    ,[intUserId]                    = P.[intUserId]
    ,[intEntityId]                  = P.[intEntityId]
    ,[strTransactionId]             = P.[strTransactionId]
    ,[intTransactionId]             = P.[intTransactionId]
    ,[strTransactionType]           = @SCREEN_NAME
    ,[strTransactionForm]           = @SCREEN_NAME
    ,[strModuleName]                = @SCREEN_NAME
    ,[intConcurrencyId]             = 1
    ,[dblDebitForeign]              = P.[dblAmountPaid] * (CASE WHEN ISNULL(P.[ysnInvoicePrepayment],0) = 1 THEN -1 ELSE 1 END)
    ,[dblDebitReport]               = P.[dblBaseAmountPaid] * (CASE WHEN ISNULL(P.[ysnInvoicePrepayment],0) = 1 THEN -1 ELSE 1 END)
    ,[dblCreditForeign]             = @ZeroDecimal
    ,[dblCreditReport]              = @ZeroDecimal
    ,[dblReportingRate]             = (P.[dblBaseAmountPaid] / P.[dblAmountPaid])
    ,[dblForeignRate]               = (P.[dblBaseAmountPaid] / P.[dblAmountPaid])
    ,[strRateType]                  = P.[strRateType]
    ,[strDocument]                  = NULL
    ,[strComments]                  = NULL
    ,[strSourceDocumentId]          = NULL
    ,[intSourceLocationId]          = NULL
    ,[intSourceUOMId]               = NULL
    ,[dblSourceUnitDebit]           = NULL
    ,[dblSourceUnitCredit]          = NULL
    ,[intCommodityId]               = NULL
    ,[intSourceEntityId]            = NULL
    ,[ysnRebuild]                   = NULL
FROM
    @Payments P
WHERE
    P.[intTransactionDetailId] IS NULL

UNION ALL
--CREDIT Overpayment
	--SELECT
	--dtmDate					= CAST(A.dtmDatePaid AS DATE)
	--,strBatchID					= @batchId
	--,intAccountId				= @ARAccount
	--,dblDebit					= 0
	--,dblCredit					= A.dblBaseUnappliedAmount
	--,dblDebitUnit				= 0
	--,dblCreditUnit				= 0	
	--,strDescription				= (SELECT strDescription FROM tblGLAccount WHERE intAccountId = @ARAccount)  
	--,strCode					= @CODE
	--,strReference				= C.strCustomerNumber
	--,intCurrencyId				= A.intCurrencyId 
	--,dblExchangeRate			= 1
	--,dtmDateEntered				= @PostDate
	--,dtmTransactionDate			= A.dtmDatePaid
	--,strJournalLineDescription	= @POSTDESC + @SCREEN_NAME 
	--,intJournalLineNo			= A.intPaymentId
	--,ysnIsUnposted				= 0
	--,intUserId					= @userId
	--,intEntityId				= @UserEntityID				
	--,strTransactionId			= A.strRecordNumber
	--,intTransactionId			= A.intPaymentId
	--,strTransactionType			= @SCREEN_NAME
	--,strTransactionForm			= @SCREEN_NAME
	--,strModuleName				= @MODULE_NAME
	--,intConcurrencyId			= 1
	--,[dblDebitForeign]			= 0
	--,[dblDebitReport]			= 0
	--,[dblCreditForeign]			= A.dblUnappliedAmount
	--,[dblCreditReport]			= A.dblBaseUnappliedAmount
	--,[dblReportingRate]			= 0
	--,[dblForeignRate]			= 0
	--,[strRateType]				= ''	 
	--FROM
	--tblARPayment A 
	--INNER JOIN
	--tblARCustomer C
	--ON A.[intEntityCustomerId] = C.[intEntityId]
	--INNER JOIN
	--@AROverpayment P
	--ON A.intPaymentId = P.intPaymentId
	--WHERE
	--A.dblBaseUnappliedAmount <> @ZeroDecimal
	--OR A.dblUnappliedAmount <> @ZeroDecimal
SELECT
     [dtmDate]                      = P.[dtmDatePaid]
    ,[strBatchId]                   = P.[strBatchId]
    ,[intAccountId]                 = P.[intARAccountId]
    ,[dblDebit]                     = @ZeroDecimal
    ,[dblCredit]                    = P.[dblBaseUnappliedAmount]
    ,[dblDebitUnit]                 = @ZeroDecimal
    ,[dblCreditUnit]                = @ZeroDecimal
    ,[strDescription]               = (SELECT strDescription FROM tblGLAccount WHERE intAccountId = P.[intARAccountId])  
    ,[strCode]                      = @CODE
    ,[strReference]                 = P.[strCustomerNumber]
    ,[intCurrencyId]                = P.[intCurrencyId]
    ,[dblExchangeRate]              = ISNULL(NULLIF(P.dblBaseUnappliedAmount, 0), 1)/ISNULL(NULLIF(P.dblUnappliedAmount, 0), 1)
    ,[dtmDateEntered]               = P.[dtmPostDate]
    ,[dtmTransactionDate]           = P.[dtmDatePaid]
    ,[strJournalLineDescription]    = @POSTDESC + @SCREEN_NAME 
    ,[intJournalLineNo]             = P.[intTransactionId]
    ,[ysnIsUnposted]                = 0
    ,[intUserId]                    = P.[intUserId]
    ,[intEntityId]                  = P.[intEntityId]
    ,[strTransactionId]             = P.[strTransactionId]
    ,[intTransactionId]             = P.[intTransactionId]
    ,[strTransactionType]           = @SCREEN_NAME
    ,[strTransactionForm]           = @SCREEN_NAME
    ,[strModuleName]                = @SCREEN_NAME
    ,[intConcurrencyId]             = 1
    ,[dblDebitForeign]              = @ZeroDecimal
    ,[dblDebitReport]               = @ZeroDecimal
    ,[dblCreditForeign]             = P.[dblUnappliedAmount]
    ,[dblCreditReport]              = P.[dblBaseUnappliedAmount]
    ,[dblReportingRate]             = (P.[dblBaseUnappliedAmount] / P.[dblUnappliedAmount])
    ,[dblForeignRate]               = (P.[dblBaseUnappliedAmount] / P.[dblUnappliedAmount])
    ,[strRateType]                  = P.[strRateType]
    ,[strDocument]                  = NULL
    ,[strComments]                  = NULL
    ,[strSourceDocumentId]          = NULL
    ,[intSourceLocationId]          = NULL
    ,[intSourceUOMId]               = NULL
    ,[dblSourceUnitDebit]           = NULL
    ,[dblSourceUnitCredit]          = NULL
    ,[intCommodityId]               = NULL
    ,[intSourceEntityId]            = NULL
    ,[ysnRebuild]                   = NULL
FROM
    @Payments P
INNER JOIN @AROverpayment OP
    ON P.[intTransactionId] = OP.[intId]
WHERE
        P.[intTransactionDetailId] IS NULL
    AND (P.[dblBaseUnappliedAmount] <> @ZeroDecimal OR P.[dblUnappliedAmount] <> @ZeroDecimal)

UNION ALL
	--SELECT
	--dtmDate					= CAST(A.dtmDatePaid AS DATE)
	--,strBatchID					= @batchId
	--,intAccountId				= SMCL.intSalesAdvAcct 
	--,dblDebit					= 0
	--,dblCredit					= A.dblBaseAmountPaid
	--,dblDebitUnit				= 0
	--,dblCreditUnit				= 0		
	--,strDescription				= (SELECT strDescription FROM tblGLAccount WHERE intAccountId = SMCL.intSalesAdvAcct) 
	--,strCode					= @CODE
	--,strReference				= C.strCustomerNumber
	--,intCurrencyId				= A.intCurrencyId 
	--,dblExchangeRate			= 1
	--,dtmDateEntered				= @PostDate
	--,dtmTransactionDate			= A.dtmDatePaid
	--,strJournalLineDescription	= @POSTDESC + @SCREEN_NAME 
	--,intJournalLineNo			= A.intPaymentId
	--,ysnIsUnposted				= 0
	--,intUserId					= @userId
	--,intEntityId				= @UserEntityID				
	--,strTransactionId			= A.strRecordNumber
	--,intTransactionId			= A.intPaymentId
	--,strTransactionType			= @SCREEN_NAME
	--,strTransactionForm			= @SCREEN_NAME
	--,strModuleName				= @MODULE_NAME
	--,intConcurrencyId			= 1
	--,[dblDebitForeign]			= 0
	--,[dblDebitReport]			= 0
	--,[dblCreditForeign]			= A.dblAmountPaid
	--,[dblCreditReport]			= A.dblBaseAmountPaid
	--,[dblReportingRate]			= 0
	--,[dblForeignRate]			= 0
	--,[strRateType]				= ''	 
	--FROM
	--tblARPayment A
	--INNER JOIN
	--tblARCustomer C
	--ON A.[intEntityCustomerId] = C.[intEntityId]
	--INNER JOIN
	--tblSMCompanyLocation SMCL
	--ON A.intLocationId = SMCL.intCompanyLocationId 
	--INNER JOIN
	--@ARPrepayment P
	--ON A.intPaymentId = P.intPaymentId
	--WHERE
	--A.dblAmountPaid <> @ZeroDecimal
	--OR A.dblBaseAmountPaid <> @ZeroDecimal
SELECT
     [dtmDate]                      = P.[dtmDatePaid]
    ,[strBatchId]                   = P.[strBatchId]
    ,[intAccountId]                 = P.[intSalesAdvAcct]
    ,[dblDebit]                     = @ZeroDecimal
    ,[dblCredit]                    = P.[dblBaseAmountPaid]
    ,[dblDebitUnit]                 = @ZeroDecimal
    ,[dblCreditUnit]                = @ZeroDecimal
    ,[strDescription]               = (SELECT strDescription FROM tblGLAccount WHERE intAccountId = P.[intSalesAdvAcct])  
    ,[strCode]                      = @CODE
    ,[strReference]                 = P.[strCustomerNumber]
    ,[intCurrencyId]                = P.[intCurrencyId]
    ,[dblExchangeRate]              = ISNULL(NULLIF(P.dblBaseAmountPaid, 0), 1)/ISNULL(NULLIF(P.dblBaseAmountPaid, 0), 1)
    ,[dtmDateEntered]               = P.[dtmPostDate]
    ,[dtmTransactionDate]           = P.[dtmDatePaid]
    ,[strJournalLineDescription]    = @POSTDESC + @SCREEN_NAME 
    ,[intJournalLineNo]             = P.[intTransactionId]
    ,[ysnIsUnposted]                = 0
    ,[intUserId]                    = P.[intUserId]
    ,[intEntityId]                  = P.[intEntityId]
    ,[strTransactionId]             = P.[strTransactionId]
    ,[intTransactionId]             = P.[intTransactionId]
    ,[strTransactionType]           = @SCREEN_NAME
    ,[strTransactionForm]           = @SCREEN_NAME
    ,[strModuleName]                = @SCREEN_NAME
    ,[intConcurrencyId]             = 1
    ,[dblDebitForeign]              = @ZeroDecimal
    ,[dblDebitReport]               = @ZeroDecimal
    ,[dblCreditForeign]             = P.[dblAmountPaid]
    ,[dblCreditReport]              = P.[dblBaseAmountPaid]
    ,[dblReportingRate]             = (P.[dblBaseAmountPaid] / P.[dblAmountPaid])
    ,[dblForeignRate]               = (P.[dblBaseAmountPaid] / P.[dblAmountPaid])
    ,[strRateType]                  = P.[strRateType]
    ,[strDocument]                  = NULL
    ,[strComments]                  = NULL
    ,[strSourceDocumentId]          = NULL
    ,[intSourceLocationId]          = NULL
    ,[intSourceUOMId]               = NULL
    ,[dblSourceUnitDebit]           = NULL
    ,[dblSourceUnitCredit]          = NULL
    ,[intCommodityId]               = NULL
    ,[intSourceEntityId]            = NULL
    ,[ysnRebuild]                   = NULL
FROM
    @Payments P
INNER JOIN @ARPrepayment OP
    ON P.[intTransactionId] = OP.[intId]
WHERE
        P.[intTransactionDetailId] IS NULL
    AND (P.[dblAmountPaid] <> @ZeroDecimal OR P.[dblBaseAmountPaid] <> @ZeroDecimal)

UNION ALL
--DEBIT Discount
	--SELECT
	--	dtmDate					= CAST(A.dtmDatePaid AS DATE)
	--,strBatchID					= @batchId
	--,intAccountId				= ISNULL(P.intSalesDiscounts, @DiscountAccount)
	--,dblDebit					= B.dblBaseDiscount
	--,dblCredit					= 0 
	--,dblDebitUnit				= 0
	--,dblCreditUnit				= 0		
	--,strDescription				= (SELECT strDescription FROM tblGLAccount WHERE intAccountId = ISNULL(P.intSalesDiscounts, @DiscountAccount)) 
	--,strCode					= @CODE
	--,strReference				= C.strCustomerNumber
	--,intCurrencyId				= A.intCurrencyId  
	--,dblExchangeRate			= 1
	--,dtmDateEntered				= @PostDate
	--,dtmTransactionDate			= A.dtmDatePaid
	--,strJournalLineDescription	= @POSTDESC + @SCREEN_NAME 
	--,intJournalLineNo			= B.intPaymentDetailId
	--,ysnIsUnposted				= 0
	--,intUserId					= @userId
	--,intEntityId				= @UserEntityID				
	--,strTransactionId			= A.strRecordNumber
	--,intTransactionId			= A.intPaymentId
	--,strTransactionType			= @SCREEN_NAME
	--,strTransactionForm			= @SCREEN_NAME
	--,strModuleName				= @MODULE_NAME
	--,intConcurrencyId			= 1
	--,[dblDebitForeign]			= B.dblDiscount
	--,[dblDebitReport]			= B.dblBaseDiscount
	--,[dblCreditForeign]			= 0
	--,[dblCreditReport]			= 0
	--,[dblReportingRate]			= B.dblCurrencyExchangeRate
	--,[dblForeignRate]			= B.dblCurrencyExchangeRate
	--,[strRateType]				= SMCERT.strCurrencyExchangeRateType 	 
	--FROM
	--tblARPayment A 
	--INNER JOIN
	--tblARPaymentDetail B
	--	ON A.intPaymentId = B.intPaymentId
	--INNER JOIN
	--tblARCustomer C
	--	ON A.[intEntityCustomerId] = C.[intEntityId]
	--INNER JOIN
	--@ARReceivablePostData P
	--	ON A.intPaymentId = P.intPaymentId
	--LEFT OUTER JOIN
	--	(
	--		SELECT
	--			intCurrencyExchangeRateTypeId 
	--			,strCurrencyExchangeRateType 
	--		FROM
	--			tblSMCurrencyExchangeRateType
	--	)	SMCERT
	--		ON B.intCurrencyExchangeRateTypeId = SMCERT.intCurrencyExchangeRateTypeId
	--WHERE
	--(B.dblDiscount <> @ZeroDecimal
	--AND B.dblAmountDue = @ZeroDecimal)
	--OR
	--(B.dblBaseDiscount <> @ZeroDecimal
	--AND B.dblBaseAmountDue = @ZeroDecimal)
SELECT
     [dtmDate]                      = P.[dtmDatePaid]
    ,[strBatchId]                   = P.[strBatchId]
    ,[intAccountId]                 = P.[intDiscountAccount]
    ,[dblDebit]                     = P.[dblBaseDiscount]
    ,[dblCredit]                    = @ZeroDecimal
    ,[dblDebitUnit]                 = @ZeroDecimal
    ,[dblCreditUnit]                = @ZeroDecimal
    ,[strDescription]               = (SELECT strDescription FROM tblGLAccount WHERE intAccountId =  P.[intDiscountAccount]) 
    ,[strCode]                      = @CODE
    ,[strReference]                 = P.[strCustomerNumber]
    ,[intCurrencyId]                = P.[intCurrencyId]
    ,[dblExchangeRate]              = ISNULL(P.[dblCurrencyExchangeRate], 1)
    ,[dtmDateEntered]               = P.[dtmPostDate]
    ,[dtmTransactionDate]           = P.[dtmDatePaid]
    ,[strJournalLineDescription]    = @POSTDESC + @SCREEN_NAME 
    ,[intJournalLineNo]             = P.[intTransactionDetailId]
    ,[ysnIsUnposted]                = 0
    ,[intUserId]                    = P.[intUserId]
    ,[intEntityId]                  = P.[intEntityId]
    ,[strTransactionId]             = P.[strTransactionId]
    ,[intTransactionId]             = P.[intTransactionId]
    ,[strTransactionType]           = @SCREEN_NAME
    ,[strTransactionForm]           = @SCREEN_NAME
    ,[strModuleName]                = @SCREEN_NAME
    ,[intConcurrencyId]             = 1
    ,[dblDebitForeign]              = P.[dblDiscount]
    ,[dblDebitReport]               = P.[dblBaseDiscount]
    ,[dblCreditForeign]             = @ZeroDecimal
    ,[dblCreditReport]              = @ZeroDecimal
    ,[dblReportingRate]             = P.[dblCurrencyExchangeRate]
    ,[dblForeignRate]               = P.[dblCurrencyExchangeRate]
    ,[strRateType]                  = P.[strRateType]
    ,[strDocument]                  = NULL
    ,[strComments]                  = NULL
    ,[strSourceDocumentId]          = NULL
    ,[intSourceLocationId]          = NULL
    ,[intSourceUOMId]               = NULL
    ,[dblSourceUnitDebit]           = NULL
    ,[dblSourceUnitCredit]          = NULL
    ,[intCommodityId]               = NULL
    ,[intSourceEntityId]            = NULL
    ,[ysnRebuild]                   = NULL
FROM
    @Payments P
WHERE
        P.[intTransactionDetailId] IS NOT NULL
    AND ((P.[dblDiscount] <> @ZeroDecimal AND P.[dblAmountDue] = @ZeroDecimal)
		OR
        (P.[dblBaseDiscount] <> @ZeroDecimal AND P.[dblBaseAmountDue] = @ZeroDecimal))

UNION ALL
--DEBIT Interest
	--SELECT
	--	dtmDate					= CAST(A.dtmDatePaid AS DATE)
	--,strBatchID					= @batchId
	--,intAccountId				= @ARAccount 
	--,dblDebit					= B.dblBaseInterest
	--,dblCredit					= 0 
	--,dblDebitUnit				= 0
	--,dblCreditUnit				= 0	
	--,strDescription				= (SELECT strDescription FROM tblGLAccount WHERE intAccountId = @ARAccount) 
	--,strCode					= @CODE
	--,strReference				= C.strCustomerNumber
	--,intCurrencyId				= A.intCurrencyId  
	--,dblExchangeRate			= 1
	--,dtmDateEntered				= @PostDate
	--,dtmTransactionDate			= A.dtmDatePaid
	--,strJournalLineDescription	= @POSTDESC + @SCREEN_NAME 
	--,intJournalLineNo			= B.intPaymentDetailId
	--,ysnIsUnposted				= 0
	--,intUserId					= @userId
	--,intEntityId				= @UserEntityID				
	--,strTransactionId			= A.strRecordNumber
	--,intTransactionId			= A.intPaymentId
	--,strTransactionType			= @SCREEN_NAME
	--,strTransactionForm			= @SCREEN_NAME
	--,strModuleName				= @MODULE_NAME
	--,intConcurrencyId			= 1
	--,[dblDebitForeign]			= B.dblInterest
	--,[dblDebitReport]			= B.dblBaseInterest
	--,[dblCreditForeign]			= 0
	--,[dblCreditReport]			= 0
	--,[dblReportingRate]			= B.dblCurrencyExchangeRate
	--,[dblForeignRate]			= B.dblCurrencyExchangeRate
	--,[strRateType]				= SMCERT.strCurrencyExchangeRateType	 			 
	--FROM
	--tblARPayment A 
	--INNER JOIN
	--tblARPaymentDetail B
	--	ON A.intPaymentId = B.intPaymentId
	--INNER JOIN
	--tblARCustomer C
	--	ON A.[intEntityCustomerId] = C.[intEntityId]
	--INNER JOIN
	--@ARReceivablePostData P
	--	ON A.intPaymentId = P.intPaymentId
	--LEFT OUTER JOIN
	--	(
	--		SELECT
	--			intCurrencyExchangeRateTypeId 
	--			,strCurrencyExchangeRateType 
	--		FROM
	--			tblSMCurrencyExchangeRateType
	--	)	SMCERT
	--		ON B.intCurrencyExchangeRateTypeId = SMCERT.intCurrencyExchangeRateTypeId
	--WHERE
	--(B.dblInterest <> @ZeroDecimal
	--AND B.dblPayment <> @ZeroDecimal
	--AND B.dblAmountDue = @ZeroDecimal)
	--OR
	--(B.dblBaseInterest <> @ZeroDecimal
	--AND B.dblBasePayment <> @ZeroDecimal
	--AND B.dblBaseAmountDue = @ZeroDecimal)
	----GROUP BY
	----	A.intPaymentId
	----	,A.strRecordNumber
	----	,C.strCustomerNumber
	----	,A.dtmDatePaid
	----	,A.intCurrencyId	
SELECT
     [dtmDate]                      = P.[dtmDatePaid]
    ,[strBatchId]                   = P.[strBatchId]
    ,[intAccountId]                 = P.[intARAccountId]
    ,[dblDebit]                     = P.[dblBaseInterest]
    ,[dblCredit]                    = @ZeroDecimal
    ,[dblDebitUnit]                 = @ZeroDecimal
    ,[dblCreditUnit]                = @ZeroDecimal
    ,[strDescription]               = (SELECT strDescription FROM tblGLAccount WHERE intAccountId = P.[intARAccountId]) 
    ,[strCode]                      = @CODE
    ,[strReference]                 = P.[strCustomerNumber]
    ,[intCurrencyId]                = P.[intCurrencyId]
    ,[dblExchangeRate]              = ISNULL(P.[dblCurrencyExchangeRate], 1)
    ,[dtmDateEntered]               = P.[dtmPostDate]
    ,[dtmTransactionDate]           = P.[dtmDatePaid]
    ,[strJournalLineDescription]    = @POSTDESC + @SCREEN_NAME 
    ,[intJournalLineNo]             = P.[intTransactionDetailId]
    ,[ysnIsUnposted]                = 0
    ,[intUserId]                    = P.[intUserId]
    ,[intEntityId]                  = P.[intEntityId]
    ,[strTransactionId]             = P.[strTransactionId]
    ,[intTransactionId]             = P.[intTransactionId]
    ,[strTransactionType]           = @SCREEN_NAME
    ,[strTransactionForm]           = @SCREEN_NAME
    ,[strModuleName]                = @SCREEN_NAME
    ,[intConcurrencyId]             = 1
    ,[dblDebitForeign]              = P.[dblInterest]
    ,[dblDebitReport]               = P.[dblBaseInterest]
    ,[dblCreditForeign]             = @ZeroDecimal
    ,[dblCreditReport]              = @ZeroDecimal
    ,[dblReportingRate]             = P.[dblCurrencyExchangeRate]
    ,[dblForeignRate]               = P.[dblCurrencyExchangeRate]
    ,[strRateType]                  = P.[strRateType]
    ,[strDocument]                  = NULL
    ,[strComments]                  = NULL
    ,[strSourceDocumentId]          = NULL
    ,[intSourceLocationId]          = NULL
    ,[intSourceUOMId]               = NULL
    ,[dblSourceUnitDebit]           = NULL
    ,[dblSourceUnitCredit]          = NULL
    ,[intCommodityId]               = NULL
    ,[intSourceEntityId]            = NULL
    ,[ysnRebuild]                   = NULL
FROM
    @Payments P
WHERE
        P.[intTransactionDetailId] IS NOT NULL
    AND ((P.[dblInterest] <> @ZeroDecimal AND P.[dblPayment] = @ZeroDecimal AND P.[dblAmountDue] = @ZeroDecimal)
		OR
        (P.[dblBaseInterest] <> @ZeroDecimal AND P.[dblBasePayment] = @ZeroDecimal AND P.[dblBaseAmountDue] = @ZeroDecimal))

UNION ALL
--CREDIT
	--SELECT
	--	dtmDate					= CAST(A.dtmDatePaid AS DATE)
	--,strBatchID					= @batchId
	--,intAccountId				= B.intAccountId 
	--,dblDebit					= 0
	--,dblCredit					= (CASE WHEN ISNULL(A.ysnInvoicePrepayment,0) = 1 THEN -1 ELSE 1 END) * (A.dblBaseAmountPaid + ISNULL((SELECT SUM(ISNULL(((((ISNULL(C.dblBaseAmountDue, 0.00) + ISNULL(ARPD.dblBaseInterest,0.00)) - ISNULL(ARPD.dblBaseDiscount,0.00) * (CASE WHEN C.strTransactionType IN ('Invoice', 'Debit Memo') THEN 1 ELSE -1 END))) - ARPD.dblBasePayment),0)) FROM tblARPaymentDetail ARPD INNER JOIN tblARInvoice C ON ARPD.intInvoiceId = C.intInvoiceId  WHERE ARPD.intPaymentId = A.intPaymentId AND ((C.dblAmountDue + C.dblInterest) - C.dblDiscount) = ((ARPD.dblPayment - ARPD.dblInterest) + ARPD.dblDiscount)),0))
	--,dblDebitUnit				= 0
	--,dblCreditUnit				= 0
	--,strDescription				= (SELECT strDescription FROM tblGLAccount WHERE intAccountId = B.intAccountId) 
	--,strCode					= @CODE
	--,strReference				= C.strCustomerNumber
	--,intCurrencyId				= A.intCurrencyId 
	--,dblExchangeRate			= 1
	--,dtmDateEntered				= @PostDate
	--,dtmTransactionDate			= A.dtmDatePaid
	--,strJournalLineDescription	= @POSTDESC + @SCREEN_NAME 
	--,intJournalLineNo			= B.intPaymentDetailId
	--,ysnIsUnposted				= 0
	--,intUserId					= @userId
	--,intEntityId				= @UserEntityID				
	--,strTransactionId			= A.strRecordNumber
	--,intTransactionId			= A.intPaymentId
	--,strTransactionType			= @SCREEN_NAME
	--,strTransactionForm			= @SCREEN_NAME
	--,strModuleName				= @MODULE_NAME
	--,intConcurrencyId			= 1
	--,[dblDebitForeign]			= 0
	--,[dblDebitReport]			= 0
	--,[dblCreditForeign]			= (CASE WHEN (B.dblAmountDue = (B.dblPayment - B.dblInterest) + B.dblDiscount)
	--									THEN (B.dblPayment - B.dblInterest)  + B.dblDiscount
	--									ELSE B.dblPayment END)
	--								* (CASE WHEN ISNULL(A.ysnInvoicePrepayment,0) = 1 THEN -1 ELSE 1 END)
	--,[dblCreditReport]			= (CASE WHEN (B.dblBaseAmountDue = (B.dblBasePayment - B.dblBaseInterest) + B.dblBaseDiscount)
	--									THEN (B.dblBasePayment - B.dblBaseInterest)  + B.dblBaseDiscount
	--									ELSE B.dblBasePayment END)
	--								* (CASE WHEN ISNULL(A.ysnInvoicePrepayment,0) = 1 THEN -1 ELSE 1 END)
	--,[dblReportingRate]			= B.dblCurrencyExchangeRate
	--,[dblForeignRate]			= B.dblCurrencyExchangeRate
	--,[strRateType]				= SMCERT.strCurrencyExchangeRateType				 
	--FROM
	--tblARPayment A 
	--INNER JOIN 
	--tblARPaymentDetail B 
	--	ON A.intPaymentId = B.intPaymentId
	--INNER JOIN 
	--tblARCustomer C 
	--	ON A.[intEntityCustomerId] = C.[intEntityId]
	--INNER JOIN
	--@ARReceivablePostData P
	--	ON A.intPaymentId = P.intPaymentId
	--LEFT OUTER JOIN
	--	(
	--		SELECT
	--			intCurrencyExchangeRateTypeId 
	--			,strCurrencyExchangeRateType 
	--		FROM
	--			tblSMCurrencyExchangeRateType
	--	)	SMCERT
	--		ON B.intCurrencyExchangeRateTypeId = SMCERT.intCurrencyExchangeRateTypeId
	--WHERE
	--B.dblPayment <> @ZeroDecimal
	--OR B.dblBasePayment <> @ZeroDecimal
	----GROUP BY
	----	A.intPaymentId
	----	,A.strRecordNumber
	----	,B.intAccountId
	----	,C.strCustomerNumber
	----	,A.dtmDatePaid
	----	,A.intCurrencyId
	----	,A.ysnInvoicePrepayment
SELECT
     [dtmDate]                      = P.[dtmDatePaid]
    ,[strBatchId]                   = P.[strBatchId]
    ,[intAccountId]                 = P.[intTransactionAccountId]
    ,[dblDebit]                     = @ZeroDecimal
    --,[dblCredit]                    = (CASE WHEN ISNULL(P.[ysnInvoicePrepayment],0) = 1 THEN -1 ELSE 1 END) * (P.[dblBaseAmountPaid] + ISNULL((SELECT SUM(ISNULL(((((ISNULL(C.dblBaseAmountDue, 0.00) + ISNULL(ARPD.dblBaseInterest,0.00)) - ISNULL(ARPD.dblBaseDiscount,0.00) * (CASE WHEN C.strTransactionType IN ('Invoice', 'Debit Memo') THEN 1 ELSE -1 END))) - ARPD.dblBasePayment),0)) FROM tblARPaymentDetail ARPD INNER JOIN tblARInvoice C ON ARPD.intInvoiceId = C.intInvoiceId  WHERE ARPD.intPaymentId = A.intPaymentId AND ((C.dblAmountDue + C.dblInterest) - C.dblDiscount) = ((ARPD.dblPayment - ARPD.dblInterest) + ARPD.dblDiscount)),0))
    ,[dblCredit]                    = (CASE WHEN (P.[dblBaseAmountDue] = (P.[dblBasePayment] - P.[dblBaseInterest]) + P.[dblBaseDiscount])
												THEN (P.[dblBasePayment] - P.[dblBaseInterest])  + P.[dblBaseDiscount]
												ELSE P.[dblBasePayment] END)
										  * (CASE WHEN ISNULL(P.[ysnInvoicePrepayment],0) = 1 THEN -1 ELSE 1 END)
    ,[dblDebitUnit]                 = @ZeroDecimal
    ,[dblCreditUnit]                = @ZeroDecimal
    ,[strDescription]               = (SELECT strDescription FROM tblGLAccount WHERE intAccountId = P.[intTransactionAccountId]) 
    ,[strCode]                      = @CODE
    ,[strReference]                 = P.[strCustomerNumber]
    ,[intCurrencyId]                = P.[intCurrencyId]
    ,[dblExchangeRate]              = ISNULL(P.[dblCurrencyExchangeRate], 1)
    ,[dtmDateEntered]               = P.[dtmPostDate]
    ,[dtmTransactionDate]           = P.[dtmDatePaid]
    ,[strJournalLineDescription]    = @POSTDESC + @SCREEN_NAME 
    ,[intJournalLineNo]             = P.[intTransactionDetailId]
    ,[ysnIsUnposted]                = 0
    ,[intUserId]                    = P.[intUserId]
    ,[intEntityId]                  = P.[intEntityId]
    ,[strTransactionId]             = P.[strTransactionId]
    ,[intTransactionId]             = P.[intTransactionId]
    ,[strTransactionType]           = @SCREEN_NAME
    ,[strTransactionForm]           = @SCREEN_NAME
    ,[strModuleName]                = @SCREEN_NAME
    ,[intConcurrencyId]             = 1
    ,[dblDebitForeign]              = @ZeroDecimal
    ,[dblDebitReport]               = @ZeroDecimal
    ,[dblCreditForeign]             = (CASE WHEN (P.[dblAmountDue] = (P.[dblPayment] - P.[dblInterest]) + P.[dblDiscount])
												THEN (P.[dblPayment] - P.[dblInterest])  + P.[dblDiscount]
												ELSE P.[dblPayment] END)
										  * (CASE WHEN ISNULL(P.[ysnInvoicePrepayment],0) = 1 THEN -1 ELSE 1 END)
    ,[dblCreditReport]              = (CASE WHEN (P.[dblBaseAmountDue] = (P.[dblBasePayment] - P.[dblBaseInterest]) + P.[dblBaseDiscount])
												THEN (P.[dblBasePayment] - P.[dblBaseInterest])  + P.[dblBaseDiscount]
												ELSE P.[dblBasePayment] END)
										  * (CASE WHEN ISNULL(P.[ysnInvoicePrepayment],0) = 1 THEN -1 ELSE 1 END)
    ,[dblReportingRate]             = P.[dblCurrencyExchangeRate]
    ,[dblForeignRate]               = P.[dblCurrencyExchangeRate]
    ,[strRateType]                  = P.[strRateType]
    ,[strDocument]                  = NULL
    ,[strComments]                  = NULL
    ,[strSourceDocumentId]          = NULL
    ,[intSourceLocationId]          = NULL
    ,[intSourceUOMId]               = NULL
    ,[dblSourceUnitDebit]           = NULL
    ,[dblSourceUnitCredit]          = NULL
    ,[intCommodityId]               = NULL
    ,[intSourceEntityId]            = NULL
    ,[ysnRebuild]                   = NULL
FROM
    @Payments P
WHERE
        P.[intTransactionDetailId] IS NOT NULL
     AND (P.[dblPayment] <> @ZeroDecimal OR P.[dblBasePayment] <> @ZeroDecimal)

UNION ALL
--GAIN LOSS
	--SELECT
	--	dtmDate					= CAST(A.dtmDatePaid AS DATE)
	--,strBatchID					= @batchId
	--,intAccountId				= @GainLossAccount
	--,dblDebit					= CASE WHEN (ISNULL((( B.dblBasePayment- ((ISNULL(I.dblBaseAmountDue, 0.00) + ISNULL(B.dblBaseInterest,0.00)) - ISNULL(B.dblBaseDiscount,0.00) * (CASE WHEN I.strTransactionType IN ('Invoice', 'Debit Memo') THEN 1 ELSE -1 END)))),0)) > 0 THEN 0 ELSE ABS((ISNULL((B.dblBasePayment - (((ISNULL(I.dblBaseAmountDue, 0.00) + ISNULL(B.dblBaseInterest,0.00)) - ISNULL(B.dblBaseDiscount,0.00) * (CASE WHEN I.strTransactionType IN ('Invoice', 'Debit Memo') THEN 1 ELSE -1 END)))),0))) END
	--,dblCredit					= CASE WHEN (ISNULL((B.dblBasePayment - (((ISNULL(I.dblBaseAmountDue, 0.00) + ISNULL(B.dblBaseInterest,0.00)) - ISNULL(B.dblBaseDiscount,0.00) * (CASE WHEN I.strTransactionType IN ('Invoice', 'Debit Memo') THEN 1 ELSE -1 END)))),0)) > 0 THEN ABS((ISNULL(( B.dblBasePayment - (((ISNULL(I.dblBaseAmountDue, 0.00) + ISNULL(B.dblBaseInterest,0.00)) - ISNULL(B.dblBaseDiscount,0.00) * (CASE WHEN I.strTransactionType IN ('Invoice', 'Debit Memo') THEN 1 ELSE -1 END)))),0))) ELSE 0 END
	--,dblDebitUnit				= 0
	--,dblCreditUnit				= 0
	--,strDescription				= (SELECT strDescription FROM tblGLAccount WHERE intAccountId = B.intAccountId) 
	--,strCode					= @CODE
	--,strReference				= C.strCustomerNumber
	--,intCurrencyId				= A.intCurrencyId 
	--,dblExchangeRate			= 0
	--,dtmDateEntered				= @PostDate
	--,dtmTransactionDate			= A.dtmDatePaid
	--,strJournalLineDescription	= @POSTDESC + @SCREEN_NAME 
	--,intJournalLineNo			= A.intPaymentId
	--,ysnIsUnposted				= 0
	--,intUserId					= @userId
	--,intEntityId				= @UserEntityID				
	--,strTransactionId			= A.strRecordNumber
	--,intTransactionId			= A.intPaymentId
	--,strTransactionType			= @SCREEN_NAME
	--,strTransactionForm			= @SCREEN_NAME
	--,strModuleName				= @MODULE_NAME
	--,intConcurrencyId			= 1
	--,[dblDebitForeign]			= 0
	--,[dblDebitReport]			= 0
	--,[dblCreditForeign]			= 0
	--,[dblCreditReport]			= 0
	--,[dblReportingRate]			= 0
	--,[dblForeignRate]			= 0
	--,[strRateType]				= SMCERT.strCurrencyExchangeRateType				 
	--FROM
	--tblARPaymentDetail B
	--INNER JOIN 
	--tblARPayment A  
	--	ON B.intPaymentId = A.intPaymentId
	--INNER JOIN 
	--tblARCustomer C 
	--	ON A.[intEntityCustomerId] = C.[intEntityId]
	--INNER JOIN
	--tblARInvoice I
	--	ON B.intInvoiceId = I.intInvoiceId
	--INNER JOIN
	--@ARReceivablePostData P
	--	ON A.intPaymentId = P.intPaymentId
	--LEFT OUTER JOIN
	--	(
	--		SELECT
	--			intCurrencyExchangeRateTypeId 
	--			,strCurrencyExchangeRateType 
	--		FROM
	--			tblSMCurrencyExchangeRateType
	--	)	SMCERT
	--		ON B.intCurrencyExchangeRateTypeId = SMCERT.intCurrencyExchangeRateTypeId
	--WHERE
	--((ISNULL(((((ISNULL(I.dblBaseAmountDue, 0.00) + ISNULL(B.dblBaseInterest,0.00)) - ISNULL(B.dblBaseDiscount,0.00) * (CASE WHEN I.strTransactionType IN ('Invoice', 'Debit Memo') THEN 1 ELSE -1 END))) - B.dblBasePayment),0)))  <> 0
	--AND ((I.dblAmountDue + I.dblInterest) - I.dblDiscount) = ((B.dblPayment - B.dblInterest) + B.dblDiscount)
	----GROUP BY
	----	A.intPaymentId
	----	,A.strRecordNumber
	----	,B.intAccountId
	----	,C.strCustomerNumber
	----	,A.dtmDatePaid
	----	,A.intCurrencyId
	----	,A.ysnInvoicePrepayment
SELECT
     [dtmDate]                      = P.[dtmDatePaid]
    ,[strBatchId]                   = P.[strBatchId]
    ,[intAccountId]                 = P.[intGainLossAccount]
    ,[dblDebit]                     = CASE WHEN (ISNULL((( P.[dblBasePayment] - ((ISNULL(P.[dblBaseTransactionAmountDue], @ZeroDecimal) + ISNULL(P.[dblBaseInterest], @ZeroDecimal)) - ISNULL(P.[dblBaseDiscount], @ZeroDecimal) * [dbo].[fnARGetInvoiceAmountMultiplier](P.[strTransactionType])))),@ZeroDecimal)) > @ZeroDecimal THEN @ZeroDecimal ELSE ABS((ISNULL((P.[dblBasePayment] - (((ISNULL(P.[dblBaseTransactionAmountDue], @ZeroDecimal) + ISNULL(P.[dblBaseInterest], @ZeroDecimal)) - ISNULL(P.[dblBaseDiscount], @ZeroDecimal) * [dbo].[fnARGetInvoiceAmountMultiplier](P.[strTransactionType])))), @ZeroDecimal))) END
    ,[dblCredit]                    = CASE WHEN (ISNULL(( P.[dblBasePayment] - (((ISNULL(P.[dblBaseTransactionAmountDue], @ZeroDecimal) + ISNULL(P.[dblBaseInterest], @ZeroDecimal)) - ISNULL(P.[dblBaseDiscount], @ZeroDecimal) * [dbo].[fnARGetInvoiceAmountMultiplier](P.[strTransactionType])))),@ZeroDecimal)) > @ZeroDecimal THEN ABS((ISNULL((P.[dblBasePayment] - (((ISNULL(P.[dblBaseTransactionAmountDue], @ZeroDecimal) + ISNULL(P.[dblBaseInterest], @ZeroDecimal)) - ISNULL(P.[dblBaseDiscount], @ZeroDecimal) * [dbo].[fnARGetInvoiceAmountMultiplier](P.[strTransactionType])))),@ZeroDecimal))) ELSE @ZeroDecimal END
    ,[dblDebitUnit]                 = @ZeroDecimal
    ,[dblCreditUnit]                = @ZeroDecimal
    ,[strDescription]               = (SELECT strDescription FROM tblGLAccount WHERE intAccountId = P.[intGainLossAccount]) 
    ,[strCode]                      = @CODE
    ,[strReference]                 = P.[strCustomerNumber]
    ,[intCurrencyId]                = P.[intCurrencyId]
    ,[dblExchangeRate]              = ISNULL(P.[dblCurrencyExchangeRate], 1)
    ,[dtmDateEntered]               = P.[dtmPostDate]
    ,[dtmTransactionDate]           = P.[dtmDatePaid]
    ,[strJournalLineDescription]    = @POSTDESC + @SCREEN_NAME 
    ,[intJournalLineNo]             = P.[intTransactionDetailId]
    ,[ysnIsUnposted]                = 0
    ,[intUserId]                    = P.[intUserId]
    ,[intEntityId]                  = P.[intEntityId]
    ,[strTransactionId]             = P.[strTransactionId]
    ,[intTransactionId]             = P.[intTransactionId]
    ,[strTransactionType]           = @SCREEN_NAME
    ,[strTransactionForm]           = @SCREEN_NAME
    ,[strModuleName]                = @SCREEN_NAME
    ,[intConcurrencyId]             = 1
    ,[dblDebitForeign]              = CASE WHEN (ISNULL((( P.[dblPayment] - ((ISNULL(P.[dblTransactionAmountDue], @ZeroDecimal) + ISNULL(P.[dblInterest], @ZeroDecimal)) - ISNULL(P.[dblDiscount], @ZeroDecimal) * [dbo].[fnARGetInvoiceAmountMultiplier](P.[strTransactionType])))),@ZeroDecimal)) > @ZeroDecimal THEN @ZeroDecimal ELSE ABS((ISNULL((P.[dblPayment] - (((ISNULL(P.[dblTransactionAmountDue], @ZeroDecimal) + ISNULL(P.[dblInterest], @ZeroDecimal)) - ISNULL(P.[dblDiscount], @ZeroDecimal) * [dbo].[fnARGetInvoiceAmountMultiplier](P.[strTransactionType])))), @ZeroDecimal))) END
    ,[dblDebitReport]               = CASE WHEN (ISNULL((( P.[dblBasePayment] - ((ISNULL(P.[dblBaseTransactionAmountDue], @ZeroDecimal) + ISNULL(P.[dblBaseInterest], @ZeroDecimal)) - ISNULL(P.[dblBaseDiscount], @ZeroDecimal) * [dbo].[fnARGetInvoiceAmountMultiplier](P.[strTransactionType])))),@ZeroDecimal)) > @ZeroDecimal THEN @ZeroDecimal ELSE ABS((ISNULL((P.[dblBasePayment] - (((ISNULL(P.[dblBaseTransactionAmountDue], @ZeroDecimal) + ISNULL(P.[dblBaseInterest], @ZeroDecimal)) - ISNULL(P.[dblBaseDiscount], @ZeroDecimal) * [dbo].[fnARGetInvoiceAmountMultiplier](P.[strTransactionType])))), @ZeroDecimal))) END
    ,[dblCreditForeign]             = CASE WHEN (ISNULL((( P.[dblPayment] - ((ISNULL(P.[dblTransactionAmountDue], @ZeroDecimal) + ISNULL(P.[dblInterest], @ZeroDecimal)) - ISNULL(P.[dblDiscount], @ZeroDecimal) * [dbo].[fnARGetInvoiceAmountMultiplier](P.[strTransactionType])))),@ZeroDecimal)) > @ZeroDecimal THEN @ZeroDecimal ELSE ABS((ISNULL((P.[dblPayment] - (((ISNULL(P.[dblTransactionAmountDue], @ZeroDecimal) + ISNULL(P.[dblInterest], @ZeroDecimal)) - ISNULL(P.[dblDiscount], @ZeroDecimal) * [dbo].[fnARGetInvoiceAmountMultiplier](P.[strTransactionType])))), @ZeroDecimal))) END
    ,[dblCreditReport]              = CASE WHEN (ISNULL(( P.[dblBasePayment] - (((ISNULL(P.[dblBaseTransactionAmountDue], @ZeroDecimal) + ISNULL(P.[dblBaseInterest], @ZeroDecimal)) - ISNULL(P.[dblBaseDiscount], @ZeroDecimal) * [dbo].[fnARGetInvoiceAmountMultiplier](P.[strTransactionType])))),@ZeroDecimal)) > @ZeroDecimal THEN ABS((ISNULL((P.[dblBasePayment] - (((ISNULL(P.[dblBaseTransactionAmountDue], @ZeroDecimal) + ISNULL(P.[dblBaseInterest], @ZeroDecimal)) - ISNULL(P.[dblBaseDiscount], @ZeroDecimal) * [dbo].[fnARGetInvoiceAmountMultiplier](P.[strTransactionType])))),@ZeroDecimal))) ELSE @ZeroDecimal END
    ,[dblReportingRate]             = P.[dblCurrencyExchangeRate]
    ,[dblForeignRate]               = P.[dblCurrencyExchangeRate]
    ,[strRateType]                  = P.[strRateType]
    ,[strDocument]                  = NULL
    ,[strComments]                  = NULL
    ,[strSourceDocumentId]          = NULL
    ,[intSourceLocationId]          = NULL
    ,[intSourceUOMId]               = NULL
    ,[dblSourceUnitDebit]           = NULL
    ,[dblSourceUnitCredit]          = NULL
    ,[intCommodityId]               = NULL
    ,[intSourceEntityId]            = NULL
    ,[ysnRebuild]                   = NULL
FROM
    @Payments P
WHERE
        P.[intTransactionDetailId] IS NOT NULL
    AND ((ISNULL(((((ISNULL(P.[dblBaseTransactionAmountDue], @ZeroDecimal) + ISNULL(P.[dblBaseInterest], @ZeroDecimal)) - ISNULL(P.[dblBaseDiscount], @ZeroDecimal) * [dbo].[fnARGetInvoiceAmountMultiplier](P.[strTransactionType]))) - P.[dblBasePayment]),0)))  <> @ZeroDecimal
			AND ((P.[dblTransactionAmountDue] + P.[dblInterest]) - P.[dblDiscount]) = ((P.[dblPayment] - P.[dblInterest]) + P.[dblDiscount])  

UNION ALL
--DEBIT Discount
	--SELECT
	--dtmDate					= CAST(A.dtmDatePaid AS DATE)
	--,strBatchID					= @batchId
	--,intAccountId				= @ARAccount
	--,dblDebit					= 0
	--,dblCredit					= B.dblBaseDiscount
	--,dblDebitUnit				= 0
	--,dblCreditUnit				= 0		
	--,strDescription				= (SELECT strDescription FROM tblGLAccount WHERE intAccountId = @ARAccount) 
	--,strCode					= @CODE
	--,strReference				= C.strCustomerNumber
	--,intCurrencyId				= A.intCurrencyId  
	--,dblExchangeRate			= 1
	--,dtmDateEntered				= @PostDate
	--,dtmTransactionDate			= A.dtmDatePaid
	--,strJournalLineDescription	= @POSTDESC + @SCREEN_NAME 
	--,intJournalLineNo			= B.intPaymentDetailId
	--,ysnIsUnposted				= 0
	--,intUserId					= @userId
	--,intEntityId				= @UserEntityID				
	--,strTransactionId			= A.strRecordNumber
	--,intTransactionId			= A.intPaymentId
	--,strTransactionType			= @SCREEN_NAME
	--,strTransactionForm			= @SCREEN_NAME
	--,strModuleName				= @MODULE_NAME
	--,intConcurrencyId			= 1
	--,[dblDebitForeign]			= 0
	--,[dblDebitReport]			= 0
	--,[dblCreditForeign]			= B.dblDiscount
	--,[dblCreditReport]			= B.dblBaseDiscount
	--,[dblReportingRate]			= B.dblCurrencyExchangeRate
	--,[dblForeignRate]			= B.dblCurrencyExchangeRate
	--,[strRateType]				= SMCERT.strCurrencyExchangeRateType		 
	--FROM
	--tblARPayment A 
	--INNER JOIN
	--tblARPaymentDetail B
	--ON A.intPaymentId = B.intPaymentId
	--INNER JOIN
	--tblARCustomer C
	--ON A.[intEntityCustomerId] = C.[intEntityId]
	--INNER JOIN
	--@ARReceivablePostData P
	--ON A.intPaymentId = P.intPaymentId
	--LEFT OUTER JOIN
	--(
	--	SELECT
	--		intCurrencyExchangeRateTypeId 
	--		,strCurrencyExchangeRateType 
	--	FROM
	--		tblSMCurrencyExchangeRateType
	--)	SMCERT
	--	ON B.intCurrencyExchangeRateTypeId = SMCERT.intCurrencyExchangeRateTypeId
	--WHERE
	--(B.dblDiscount <> @ZeroDecimal
	--AND B.dblAmountDue = @ZeroDecimal)
	--OR
	--(B.dblBaseDiscount <> @ZeroDecimal
	--AND B.dblBaseAmountDue = @ZeroDecimal)
	----GROUP BY
	----	A.intPaymentId
	----	,A.strRecordNumber
	----	,C.strCustomerNumber
	----	,A.dtmDatePaid
	----	,A.intCurrencyId
SELECT
     [dtmDate]                      = P.[dtmDatePaid]
    ,[strBatchId]                   = P.[strBatchId]
    ,[intAccountId]                 = P.[intARAccountId]
    ,[dblDebit]                     = @ZeroDecimal
    ,[dblCredit]                    = P.[dblBaseDiscount]
    ,[dblDebitUnit]                 = @ZeroDecimal
    ,[dblCreditUnit]                = @ZeroDecimal
    ,[strDescription]               = (SELECT strDescription FROM tblGLAccount WHERE intAccountId =  P.[intARAccountId]) 
    ,[strCode]                      = @CODE
    ,[strReference]                 = P.[strCustomerNumber]
    ,[intCurrencyId]                = P.[intCurrencyId]
    ,[dblExchangeRate]              = ISNULL(P.[dblCurrencyExchangeRate], 1)
    ,[dtmDateEntered]               = P.[dtmPostDate]
    ,[dtmTransactionDate]           = P.[dtmDatePaid]
    ,[strJournalLineDescription]    = @POSTDESC + @SCREEN_NAME 
    ,[intJournalLineNo]             = P.[intTransactionDetailId]
    ,[ysnIsUnposted]                = 0
    ,[intUserId]                    = P.[intUserId]
    ,[intEntityId]                  = P.[intEntityId]
    ,[strTransactionId]             = P.[strTransactionId]
    ,[intTransactionId]             = P.[intTransactionId]
    ,[strTransactionType]           = @SCREEN_NAME
    ,[strTransactionForm]           = @SCREEN_NAME
    ,[strModuleName]                = @SCREEN_NAME
    ,[intConcurrencyId]             = 1
    ,[dblDebitForeign]              = @ZeroDecimal
    ,[dblDebitReport]               = @ZeroDecimal
    ,[dblCreditForeign]             = P.[dblDiscount]
    ,[dblCreditReport]              = P.[dblBaseDiscount]
    ,[dblReportingRate]             = P.[dblCurrencyExchangeRate]
    ,[dblForeignRate]               = P.[dblCurrencyExchangeRate]
    ,[strRateType]                  = P.[strRateType]
    ,[strDocument]                  = NULL
    ,[strComments]                  = NULL
    ,[strSourceDocumentId]          = NULL
    ,[intSourceLocationId]          = NULL
    ,[intSourceUOMId]               = NULL
    ,[dblSourceUnitDebit]           = NULL
    ,[dblSourceUnitCredit]          = NULL
    ,[intCommodityId]               = NULL
    ,[intSourceEntityId]            = NULL
    ,[ysnRebuild]                   = NULL
FROM
    @Payments P
WHERE
        P.[intTransactionDetailId] IS NOT NULL
    AND ((P.[dblDiscount] <> @ZeroDecimal AND P.[dblAmountDue] = @ZeroDecimal)
		OR
        (P.[dblBaseDiscount] <> @ZeroDecimal AND P.[dblBaseAmountDue] = @ZeroDecimal))

UNION ALL
--CREDIT Interest
	--SELECT
	--dtmDate					= CAST(A.dtmDatePaid AS DATE)
	--,strBatchID					= @batchId
	--,intAccountId				= ISNULL(P.intInterestAccountId, @IncomeInterestAccount)
	--,dblDebit					= 0
	--,dblCredit					= B.dblBaseInterest
	--,dblDebitUnit				= 0
	--,dblCreditUnit				= 0		
	--,strDescription				= (SELECT strDescription FROM tblGLAccount WHERE intAccountId = ISNULL(P.intInterestAccountId, @IncomeInterestAccount)) 
	--,strCode					= @CODE
	--,strReference				= C.strCustomerNumber
	--,intCurrencyId				= A.intCurrencyId  
	--,dblExchangeRate			= 1
	--,dtmDateEntered				= @PostDate
	--,dtmTransactionDate			= A.dtmDatePaid
	--,strJournalLineDescription	= @POSTDESC + @SCREEN_NAME 
	--,intJournalLineNo			= B.intPaymentDetailId
	--,ysnIsUnposted				= 0
	--,intUserId					= @userId
	--,intEntityId				= @UserEntityID				
	--,strTransactionId			= A.strRecordNumber
	--,intTransactionId			= A.intPaymentId
	--,strTransactionType			= @SCREEN_NAME
	--,strTransactionForm			= @SCREEN_NAME
	--,strModuleName				= @MODULE_NAME
	--,intConcurrencyId			= 1				
	--,[dblDebitForeign]			= 0
	--,[dblDebitReport]			= 0
	--,[dblCreditForeign]			= B.dblInterest
	--,[dblCreditReport]			= B.dblBaseInterest
	--,[dblReportingRate]			= B.dblCurrencyExchangeRate
	--,[dblForeignRate]			= B.dblCurrencyExchangeRate
	--,[strRateType]				= SMCERT.strCurrencyExchangeRateType		  
	--FROM
	--tblARPayment A 
	--INNER JOIN
	--tblARPaymentDetail B
	--ON A.intPaymentId = B.intPaymentId
	--INNER JOIN
	--tblARCustomer C
	--ON A.[intEntityCustomerId] = C.[intEntityId]
	--INNER JOIN
	--@ARReceivablePostData P
	--ON A.intPaymentId = P.intPaymentId
	--LEFT OUTER JOIN
	--(
	--	SELECT
	--		intCurrencyExchangeRateTypeId 
	--		,strCurrencyExchangeRateType 
	--	FROM
	--		tblSMCurrencyExchangeRateType
	--)	SMCERT
	--	ON B.intCurrencyExchangeRateTypeId = SMCERT.intCurrencyExchangeRateTypeId
	--WHERE
	--(B.dblInterest <> @ZeroDecimal
	--AND B.dblPayment <> @ZeroDecimal
	--AND B.dblAmountDue = @ZeroDecimal)
	--OR
	--(B.dblBaseInterest <> @ZeroDecimal
	--AND B.dblBasePayment <> @ZeroDecimal
	--AND B.dblBaseAmountDue = @ZeroDecimal)
	----GROUP BY
	----	A.intPaymentId
	----	,A.strRecordNumber
	----	,C.strCustomerNumber
	----	,A.dtmDatePaid
	----	,A.intCurrencyId
	----	,P.intInterestAccountId
SELECT
     [dtmDate]                      = P.[dtmDatePaid]
    ,[strBatchId]                   = P.[strBatchId]
    ,[intAccountId]                 = P.[intInterestAccount]
    ,[dblDebit]                     = @ZeroDecimal
    ,[dblCredit]                    = P.[dblBaseInterest]
    ,[dblDebitUnit]                 = @ZeroDecimal
    ,[dblCreditUnit]                = @ZeroDecimal
    ,[strDescription]               = (SELECT strDescription FROM tblGLAccount WHERE intAccountId = P.[intInterestAccount]) 
    ,[strCode]                      = @CODE
    ,[strReference]                 = P.[strCustomerNumber]
    ,[intCurrencyId]                = P.[intCurrencyId]
    ,[dblExchangeRate]              = ISNULL(P.[dblCurrencyExchangeRate], 1)
    ,[dtmDateEntered]               = P.[dtmPostDate]
    ,[dtmTransactionDate]           = P.[dtmDatePaid]
    ,[strJournalLineDescription]    = @POSTDESC + @SCREEN_NAME 
    ,[intJournalLineNo]             = P.[intTransactionDetailId]
    ,[ysnIsUnposted]                = 0
    ,[intUserId]                    = P.[intUserId]
    ,[intEntityId]                  = P.[intEntityId]
    ,[strTransactionId]             = P.[strTransactionId]
    ,[intTransactionId]             = P.[intTransactionId]
    ,[strTransactionType]           = @SCREEN_NAME
    ,[strTransactionForm]           = @SCREEN_NAME
    ,[strModuleName]                = @SCREEN_NAME
    ,[intConcurrencyId]             = 1
    ,[dblDebitForeign]              = @ZeroDecimal
    ,[dblDebitReport]               = @ZeroDecimal
    ,[dblCreditForeign]             = P.[dblInterest]
    ,[dblCreditReport]              = P.[dblBaseInterest]
    ,[dblReportingRate]             = P.[dblCurrencyExchangeRate]
    ,[dblForeignRate]               = P.[dblCurrencyExchangeRate]
    ,[strRateType]                  = P.[strRateType]
    ,[strDocument]                  = NULL
    ,[strComments]                  = NULL
    ,[strSourceDocumentId]          = NULL
    ,[intSourceLocationId]          = NULL
    ,[intSourceUOMId]               = NULL
    ,[dblSourceUnitDebit]           = NULL
    ,[dblSourceUnitCredit]          = NULL
    ,[intCommodityId]               = NULL
    ,[intSourceEntityId]            = NULL
    ,[ysnRebuild]                   = NULL
FROM
    @Payments P
WHERE
        P.[intTransactionDetailId] IS NOT NULL
    AND ((P.[dblInterest] <> @ZeroDecimal AND P.[dblPayment] = @ZeroDecimal AND P.[dblAmountDue] = @ZeroDecimal)
		OR
        (P.[dblBaseInterest] <> @ZeroDecimal AND P.[dblBasePayment] = @ZeroDecimal AND P.[dblBaseAmountDue] = @ZeroDecimal))


RETURN
END
