CREATE PROCEDURE [dbo].[uspARPayOutCreditBalance]
     @CustomerIds                   NVARCHAR(MAX)   = ''
    ,@AsOfDate                      DATETIME		= NULL
    ,@PayBalance                    BIT				= 0
	,@Preview                       BIT             = 0
    ,@OpenARBalance                 NUMERIC(18,6)   = 0.000000
	,@GenerateIdOnly                BIT             = 0
	,@UserId                        INT
	,@CreditBalancePayOutId			INT             = NULL      OUTPUT 	
AS

BEGIN

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

DECLARE @ZeroDecimal    NUMERIC(18, 6)
       ,@DateOnly       DATETIME
       ,@DateNow        DATETIME			

SET @ZeroDecimal = 0.000000	
SET @DateOnly = CAST(GETDATE() AS DATE)
SET @DateNow = GETDATE()


DECLARE  @InitTranCount	INT
SET @InitTranCount = @@TRANCOUNT

IF @AsOfDate IS NULL
	SET @AsOfDate = @DateOnly
ELSE
	SET @AsOfDate = CAST(@AsOfDate AS DATE)

SET @OpenARBalance = ISNULL(@OpenARBalance, @ZeroDecimal)
	

INSERT INTO[tblARCreditBalancePayOut]
    ([dtmAsOfDate]
    ,[ysnPayBalance]
    ,[ysnPreview]
    ,[dblOpenARBalance]
    ,[intEntityId]
    ,[dtmDate]
    ,[intConcurrencyId])
VALUES
    (@AsOfDate          --[dtmAsOfDate]
    ,@PayBalance        --[ysnPayBalance]
    ,@Preview           --[ysnPreview]
    ,@OpenARBalance     --[dblOpenARBalance]
    ,@UserId            --[intEntityId]
    ,GETDATE()          --[dtmDate]
    ,0)                 --[intConcurrencyId])


SET @CreditBalancePayOutId = SCOPE_IDENTITY()

IF ISNULL(@GenerateIdOnly,0) = 1 RETURN @CreditBalancePayOutId;

DECLARE @Customers AS TABLE([intEntityId] INT UNIQUE)

--GET SELECTED CUSTOMERS
IF (ISNULL(@CustomerIds,'') = '')
	BEGIN
		INSERT INTO @Customers([intEntityId]) 
		SELECT 
			[intEntityId]
		FROM
			tblARCustomer
		WHERE
			[ysnActive] = 1
	END
ELSE
	BEGIN
		INSERT INTO @Customers([intEntityId])
		SELECT
			[intEntityId]
		FROM
			tblARCustomer
		WHERE
			[intEntityId] IN (SELECT intID FROM [dbo].[fnGetRowsFromDelimitedValues](@CustomerIds))
	END
	
EXEC [dbo].[uspARCustomerAgingDetailAsOfDateReport] @dtmDateTo = @AsOfDate
												  , @ysnInclude120Days = 0
												  , @intEntityUserId = @UserId


IF (DATEPART(dd, @AsOfDate) = 31)
	DELETE FROM tblARCustomerAgingStagingTable WHERE dtmDueDate = @AsOfDate AND intEntityUserId = @UserId AND strAgingType = 'Detail'

DELETE FROM tblARCustomerAgingStagingTable
WHERE intEntityUserId = @UserId AND strAgingType = 'Detail'
  AND strInvoiceNumber IN (SELECT strInvoiceNumber FROM tblARInvoice WHERE strTransactionType NOT IN ('Invoice', 'Cash'))

DELETE FROM tblARCustomerAgingStagingTable
WHERE intEntityUserId = @UserId AND strAgingType = 'Detail'
  AND intEntityCustomerId NOT IN (SELECT [intEntityId] FROM @Customers)

DELETE STAGING
FROM tblARCustomerAgingStagingTable STAGING
INNER JOIN (
	SELECT [intEntityCustomerId] 
	FROM  tblARCustomerAgingStagingTable 
	WHERE intEntityUserId = @UserId AND strAgingType = 'Detail'
	GROUP BY [intEntityCustomerId] 
	HAVING SUM([dbl0Days] + [dbl10Days] + [dbl30Days] + [dbl60Days] + [dbl90Days] + [dbl120Days] + [dbl121Days]) >= @OpenARBalance
) ENTITY ON STAGING.intEntityCustomerId = ENTITY.intEntityCustomerId
WHERE STAGING.intEntityUserId = @UserId AND STAGING.strAgingType = 'Detail'
					
DECLARE @CustomerBalances AS TABLE
(
    [intId]                     INT IDENTITY,
    [intInvoiceId]				INT NULL,
	[intAccountId]				INT NULL,	
	[intCurrencyId]				INT NULL,
    [intEntityCustomerId]		INT NULL,
    [intCompanyLocationId]		INT NULL,
	[intWriteOffAccountId]		INT NULL,
    [dblTotalAR]				NUMERIC(18, 6) NULL,
	[ysnProcessed]              BIT
)
DELETE FROM @CustomerBalances

INSERT INTO @CustomerBalances
(
     [intInvoiceId]
    ,[intCurrencyId]
    ,[intEntityCustomerId]
    ,[intCompanyLocationId]
    ,[dblTotalAR]
	,[ysnProcessed]
)
SELECT
     [intInvoiceId]         = A.[intInvoiceId]
    ,[intCurrencyId]        = ARI.[intCurrencyId]
    ,[intEntityCustomerId]  = A.[intEntityCustomerId]
    ,[intCompanyLocationId] = A.[intCompanyLocationId]
    ,[dblTotalAR]           = SUM([dbl0Days] + [dbl10Days] + [dbl30Days] + [dbl60Days] + [dbl90Days] + [dbl120Days] + [dbl121Days])
	,[ysnProcessed]         = 0
FROM tblARCustomerAgingStagingTable A
INNER JOIN (
	SELECT intInvoiceId
		 , intCurrencyId 
	FROM tblARInvoice 
	WHERE ysnPosted = 1
) ARI ON A.intInvoiceId = ARI.intInvoiceId
WHERE A.intEntityUserId = @UserId AND A.strAgingType = 'Detail'
GROUP BY A.intEntityCustomerId
       , A.intInvoiceId
       , ARI.intCurrencyId
       , A.intCompanyLocationId

DECLARE @VendorId AS INT
        ,@InvoiceId AS INT
		,@BillId AS INT
		,@AccountId AS INT
		,@CurrencyId AS INT
        ,@CompanyLocationId AS INT
        ,@TotalAR AS NUMERIC(18,6)
		,@Id AS INT
        ,@IdList AS NVARCHAR(MAX)
		,@PaymentMethodId AS INT
        ,@PaymentMethod AS NVARCHAR(100)
        ,@PostingSuccessful AS BIT
		,@ErrorMessage AS NVARCHAR(250)


/*SELECT '#Remove Checking the customer aging table'	
SELECT * FROM @ARCustomerAgingStagingTable*/
DECLARE @TransName NVARCHAR(100)
SELECT @TransName = 'Payout' + CAST(NEWID() AS NVARCHAR(40))

IF ISNULL(@Preview,0) = 1
BEGIN
	IF @InitTranCount = 0
		BEGIN TRANSACTION
	ELSE
		SAVE TRANSACTION @TransName

	-- BEGIN TRANSACTION @TransName
	-- SAVE TRAN @TransName
END

IF ISNULL(@PayBalance,0) = 1
    BEGIN
		SET @IdList = NULL
		SET @PostingSuccessful = 0
		DECLARE @EntityIds AS [Id]
		INSERT INTO @EntityIds([intId])
		SELECT DISTINCT CB.[intEntityCustomerId] FROM @CustomerBalances CB WHERE NOT EXISTS(SELECT NULL FROM tblAPVendor APV WHERE CB.[intEntityCustomerId] = APV.[intEntityId])

        EXEC [dbo].[uspEMConvertCustomerToVendor] @CustomerIds = @EntityIds, @UserId = @UserId


		WHILE EXISTS(SELECT TOP 1 NULL FROM @CustomerBalances WHERE [ysnProcessed] = 0)
		BEGIN
			SELECT @VendorId = NULL, @InvoiceId = NULL, @AccountId = NULL, @CurrencyId= NULL, @BillId = NULL, @CompanyLocationId = NULL, @TotalAR = @ZeroDecimal
			SELECT TOP 1
				 @VendorId          = CB.[intEntityCustomerId]
				,@InvoiceId         = ARI.[intInvoiceId]
				,@AccountId         = ARI.[intAccountId]
				,@CurrencyId        = CB.[intCurrencyId]
				,@CompanyLocationId = CB.[intCompanyLocationId]
				,@TotalAR           = CB.[dblTotalAR]
				,@Id                = CB.[intId]
			FROM
				@CustomerBalances CB
			INNER JOIN
				(SELECT [intInvoiceId], [intAccountId] FROM tblARInvoice) ARI
					ON CB.[intInvoiceId] = ARI.[intInvoiceId]				
			WHERE [ysnProcessed] = 0
			
            DECLARE @VoucherDetailNonInventory AS VoucherDetailNonInventory
            DELETE FROM @VoucherDetailNonInventory

            INSERT INTO @VoucherDetailNonInventory
                ([intAccountId]
                ,[intItemId]
                ,[strMiscDescription]
                ,[dblQtyReceived]
                ,[dblDiscount]
                ,[dblCost]
                ,[intTaxGroupId]
				,[intInvoiceId])
			SELECT
                 [intAccountId]         = @AccountId
                ,[intItemId]            = NULL
                ,[strMiscDescription]   = ''
                ,[dblQtyReceived]       = 1.000000
                ,[dblDiscount]          = @ZeroDecimal
                ,[dblCost]              = @TotalAR
                ,[intTaxGroupId]        = NULL
				,[intInvoiceId]         = @InvoiceId


            EXEC [dbo].[uspAPCreateBillData]
                 @userId                = @UserId
                ,@vendorId              = @VendorId
                ,@type                  = 3
                ,@voucherNonInvDetails  = @VoucherDetailNonInventory
                ,@voucherDate           = @DateNow
				,@billId                = @BillId OUTPUT


			IF ISNULL(@BillId,0) <> 0
				BEGIN
					UPDATE tblAPBill SET [intCurrencyId] = @CurrencyId WHERE [intBillId] = @BillId;
					UPDATE tblAPBillDetail SET [intCurrencyId] = @CurrencyId WHERE [intBillId] = @BillId;
				END
			


            SET @IdList = ISNULL(@IdList,'') + ISNULL(CAST(@BillId AS NVARCHAR(100)) + ',','')

            UPDATE @CustomerBalances SET [ysnProcessed] = 1 WHERE [intId] = @Id				
		END

		IF LEN(LTRIM(RTRIM(ISNULL(@IdList,'')))) > 1
			BEGIN
				EXEC [dbo].[uspAPPostBill]
                     @batchId   = NULL
                    ,@post      = 1
                    ,@recap     = 0
                    ,@isBatch   = 1
                    ,@param     = @IdList
                    ,@userId    = @UserId
                    ,@success   = @PostingSuccessful OUTPUT;
            END

        IF ISNULL(@PostingSuccessful,0) = 1
		BEGIN
			INSERT INTO tblARCreditBalancePayOutDetail
				([intCreditBalancePayOutId]
				,[intEntityCustomerId]
				,[intPaymentId]
				,[intBillId]
				,[intInvoiceId]
				,[ysnProcess]
				,[ysnSuccess]
				,[strMessage]
				,[intConcurrencyId])
			SELECT
				 [intCreditBalancePayOutId]	= @CreditBalancePayOutId
				,[intEntityCustomerId]		= APB.intEntityVendorId 
				,[intPaymentId]				= NULL
				,[intBillId]				= APB.[intBillId]
				,[intInvoiceId]             = APBD.[intInvoiceId]
				,[ysnProcess]				= 1
				,[ysnSuccess]				= 1				
				,[strMessage]				= ''
				,[intConcurrencyId]			= 0
			FROM
				tblAPBill APB
			INNER JOIN
				tblAPBillDetail APBD
					ON APB.[intBillId] = APBD.[intBillId]
			WHERE
				APB.[intBillId] IN (SELECT intID FROM [dbo].[fnGetRowsFromDelimitedValues](@IdList))
		END


        RETURN @CreditBalancePayOutId;
	END
ELSE
	BEGIN
		SELECT TOP 1
				@PaymentMethodId	= [intPaymentMethodID]
			,@PaymentMethod		= [strPaymentMethod]
		FROM
			vyuARPaymentMethodForReceivePayments
		WHERE
			UPPER(LTRIM(RTRIM(ISNULL([strPaymentMethod],'')))) = UPPER('Write Off')
			AND [ysnActive] = 1

		UPDATE CB
		SET
				CB.[intAccountId]         = ARI.[intAccountId] 
			,CB.[intWriteOffAccountId] = SMCL.[intWriteOff] 
		FROM
			@CustomerBalances CB
		INNER JOIN
			(SELECT [intInvoiceId], [intAccountId] FROM tblARInvoice) ARI
				ON CB.[intInvoiceId] = ARI.[intInvoiceId]
		INNER JOIN
			(SELECT [intCompanyLocationId], [intWriteOff] FROM tblSMCompanyLocation) SMCL
				ON CB.[intCompanyLocationId] = SMCL.[intCompanyLocationId]

		INSERT INTO tblARCreditBalancePayOutDetail
			([intCreditBalancePayOutId]
			,[intEntityCustomerId]
			,[intPaymentId]
			,[intBillId]
			,[ysnProcess]
			,[ysnSuccess]
			,[strMessage]
			,[intConcurrencyId])
		SELECT
				[intCreditBalancePayOutId] = @CreditBalancePayOutId
			,[intEntityCustomerId]      = CB.[intEntityCustomerId] 
			,[intPaymentId]             = NULL
			,[intBillId]                = NULL
			,[ysnProcess]               = 1
			,[ysnSuccess]               = 0
			,[strMessage]				= 'Invoice(' + ARI.[strInvoiceNumber]  + ') was not processed because Location(' + SMCL.[strLocationNumber] + ') has not Write Off account setup.'
			,[intConcurrencyId]         = 0
		FROM
			@CustomerBalances CB
		INNER JOIN
			(SELECT [intInvoiceId], [strInvoiceNumber] FROM tblARInvoice) ARI
				ON CB.[intInvoiceId] = ARI.[intInvoiceId]
		INNER JOIN
			(SELECT [intCompanyLocationId], [strLocationNumber] FROM tblSMCompanyLocation) SMCL
				ON CB.[intCompanyLocationId] = SMCL.[intCompanyLocationId]
		WHERE
			CB.[intWriteOffAccountId] IS NULL

		UNION 

		SELECT
			 [intCreditBalancePayOutId] = @CreditBalancePayOutId
			,[intEntityCustomerId]      = CB.[intEntityCustomerId] 
			,[intPaymentId]             = NULL
			,[intBillId]                = NULL
			,[ysnProcess]               = 1
			,[ysnSuccess]               = 0
			,[strMessage]				= 'There''s no active ''Write Off'' payment method.'
			,[intConcurrencyId]         = 0
		FROM
			@CustomerBalances CB
		WHERE
			ISNULL(@PaymentMethodId,0) = 0

		DELETE FROM @CustomerBalances WHERE [intWriteOffAccountId] IS NULL OR ISNULL(@PaymentMethodId,0) = 0

		IF EXISTS(SELECT TOP 1 NULL FROM @CustomerBalances)
		BEGIN
			DECLARE @EntriesForPayment AS PaymentIntegrationStagingTable
			DECLARE @LogId INT

			INSERT INTO @EntriesForPayment(
					[intId]
				,[strSourceTransaction]
				,[intSourceId]
				,[strSourceId]
				,[intPaymentId]
				,[intEntityCustomerId]
				,[intCompanyLocationId]
				,[intCurrencyId]
				,[dtmDatePaid]
				,[intPaymentMethodId]
				,[strPaymentMethod]
				,[strPaymentInfo]
				,[strNotes]
				,[intAccountId]
				,[intBankAccountId]
				,[intWriteOffAccountId]
				,[dblAmountPaid]
				,[strPaymentOriginalId]
				,[ysnUseOriginalIdAsPaymentNumber]
				,[ysnApplytoBudget]
				,[ysnApplyOnAccount]
				,[ysnInvoicePrepayment]
				,[ysnImportedFromOrigin]
				,[ysnImportedAsPosted]
				,[ysnAllowPrepayment]
				,[ysnPost]
				,[ysnRecap]
				,[ysnUnPostAndUpdate]
				,[intEntityId]
				,[intPaymentDetailId]
				,[intInvoiceId]
				,[strTransactionType]
				,[intBillId]
				,[strTransactionNumber]
				,[intTermId]
				,[intInvoiceAccountId]
				,[dblInvoiceTotal]
				,[dblBaseInvoiceTotal]
				,[ysnApplyTermDiscount]
				,[dblDiscount]
				,[dblDiscountAvailable]
				,[dblInterest]
				,[dblPayment]
				,[dblAmountDue]
				,[dblBaseAmountDue]
				,[strInvoiceReportNumber]
				,[intCurrencyExchangeRateTypeId]
				,[intCurrencyExchangeRateId]
				,[dblCurrencyExchangeRate]
				,[ysnAllowOverpayment]
				,[ysnFromAP])
			SELECT
					[intId]                            = CB.[intInvoiceId]
				,[strSourceTransaction]             = 'Direct'
				,[intSourceId]                      = CB.[intInvoiceId]
				,[strSourceId]                      = IFP.[strInvoiceNumber]
				,[intPaymentId]                     = NULL
				,[intEntityCustomerId]              = CB.[intEntityCustomerId]
				,[intCompanyLocationId]             = CB.[intCompanyLocationId]
				,[intCurrencyId]                    = CB.[intCurrencyId]
				,[dtmDatePaid]                      = GETDATE()
				,[intPaymentMethodId]               = @PaymentMethodId
				,[strPaymentMethod]                 = @PaymentMethod
				,[strPaymentInfo]                   = ''
				,[strNotes]                         = ''
				,[intAccountId]                     = NULL
				,[intBankAccountId]                 = NULL
				,[intWriteOffAccountId]             = CB.[intWriteOffAccountId]
				,[dblAmountPaid]                    = IFP.[dblAmountDue]
				,[strPaymentOriginalId]             = NULL
				,[ysnUseOriginalIdAsPaymentNumber]  = 0 
				,[ysnApplytoBudget]                 = 0
				,[ysnApplyOnAccount]                = 0
				,[ysnInvoicePrepayment]             = 0
				,[ysnImportedFromOrigin]            = 0
				,[ysnImportedAsPosted]              = 0
				,[ysnAllowPrepayment]               = 0
				,[ysnPost]                          = 1
				,[ysnRecap]                         = 0
				,[ysnUnPostAndUpdate]               = 0
				,[intEntityId]                      = @UserId
				,[intPaymentDetailId]               = NULL
				,[intInvoiceId]                     = CB.[intInvoiceId]
				,[strTransactionType]               = IFP.[strTransactionType]
				,[intBillId]                        = NULL
				,[strTransactionNumber]             = IFP.[strInvoiceNumber]
				,[intTermId]                        = IFP.[intTermId]
				,[intInvoiceAccountId]              = IFP.[intAccountId]
				,[dblInvoiceTotal]                  = IFP.[dblInvoiceTotal]
				,[dblBaseInvoiceTotal]              = IFP.[dblBaseInvoiceTotal]
				,[ysnApplyTermDiscount]             = 0
				,[dblDiscount]                      = @ZeroDecimal 
				,[dblDiscountAvailable]             = @ZeroDecimal
				,[dblInterest]                      = @ZeroDecimal
				,[dblPayment]                       = IFP.[dblAmountDue]
				,[dblAmountDue]                     = @ZeroDecimal
				,[dblBaseAmountDue]                 = @ZeroDecimal
				,[strInvoiceReportNumber]           = ''
				,[intCurrencyExchangeRateTypeId]    = IFP.[intCurrencyExchangeRateTypeId]
				,[intCurrencyExchangeRateId]        = IFP.[intCurrencyExchangeRateId]
				,[dblCurrencyExchangeRate]          = IFP.[dblCurrencyExchangeRate]
				,[ysnAllowOverpayment]              = 0
				,[ysnFromAP]                        = 0
			FROM
				@CustomerBalances CB
			INNER JOIN
				vyuARInvoicesForPayment IFP
					ON CB.[intInvoiceId] = IFP.[intInvoiceId]



			EXEC [dbo].[uspARProcessPayments]
					@PaymentEntries	= @EntriesForPayment
				,@UserId			= 1
				,@GroupingOption	= 1
				,@RaiseError		= 0
				,@ErrorMessage		= @ErrorMessage OUTPUT
				,@LogId				= @LogId OUTPUT

			INSERT INTO tblARCreditBalancePayOutDetail
				([intCreditBalancePayOutId]
				,[intEntityCustomerId]
				,[intPaymentId]
				,[intBillId]
				,[ysnProcess]
				,[ysnSuccess]
				,[strMessage]
				,[intConcurrencyId])
			SELECT
					[intCreditBalancePayOutId] = @CreditBalancePayOutId
				,[intEntityCustomerId]      = ARP.[intEntityCustomerId] 
				,[intPaymentId]             = ARP.[intPaymentId]
				,[intBillId]                = NULL
				,[ysnProcess]               = 1
				,[ysnSuccess]               = PILD.[ysnPosted]
				,[strMessage]				= PILD.[strPostingMessage]
				,[intConcurrencyId]         = 0
			FROM
				tblARPaymentIntegrationLogDetail PILD
			INNER JOIN
				(SELECT [intPaymentId], [intEntityCustomerId] FROM tblARPayment) ARP
					ON PILD.[intPaymentId] = ARP.[intPaymentId] 
			WHERE
				[intIntegrationLogId] = @LogId
				AND [ysnHeader] = 1
		END	
	END

IF ISNULL(@Preview,0) = 1
	BEGIN
		DECLARE @ARCreditBalancePayOutDetail AS TABLE(
			[intCreditBalancePayOutDetailId] [int] IDENTITY(1,1) NOT NULL,
			[intCreditBalancePayOutId] [int] NOT NULL,
			[intEntityCustomerId] [int] NULL,
			[intPaymentId] [int] NULL,
			[intBillId] [int] NULL,
			[ysnProcess] [bit] NOT NULL,
			[ysnSuccess] [bit] NOT NULL,
			[strMessage] [nvarchar](500) NULL,
			[intConcurrencyId] [int] NOT NULL)

		DELETE FROM @ARCreditBalancePayOutDetail
		
		DECLARE @ARCreditBalancePayOut AS TABLE(
			[intCreditBalancePayOutId]      INT                 IDENTITY (1, 1) NOT NULL,
			[dtmAsOfDate]                   DATETIME            NULL,
			[ysnPayBalance]                 BIT                 NOT NULL,
			[ysnPreview]                    BIT                 NOT NULL,
			[dblOpenARBalance]              NUMERIC (18, 6)     NULL,
			[intEntityId]                   INT                 NOT NULL,
			[dtmDate]                       DATETIME            NOT NULL
		)

		/*INSERT INTO @ARCreditBalancePayOut (
			dtmAsOfDate,
			ysnPayBalance,
			ysnPreview,
			dblOpenARBalance,
			intEntityId,
			dtmDate
		)
		SELECT 
			dtmAsOfDate,
			ysnPayBalance,
			ysnPreview,
			dblOpenARBalance,
			intEntityId,
			dtmDate
		FROM 
			tblARCreditBalancePayOut			
		WHERE
			[intCreditBalancePayOutId] = @CreditBalancePayOutId*/

		INSERT INTO @ARCreditBalancePayOutDetail
			([intCreditBalancePayOutId]
			,[intEntityCustomerId]
			,[intPaymentId]
			,[intBillId]
			,[ysnProcess]
			,[ysnSuccess]
			,[strMessage]
			,[intConcurrencyId])
		SELECT
			 [intCreditBalancePayOutId]
			,[intEntityCustomerId]
			,[intPaymentId]
			,[intBillId]
			,[ysnProcess]
			,[ysnSuccess]
			,[strMessage]
			,[intConcurrencyId]
		FROM
			tblARCreditBalancePayOutDetail
		WHERE
			[intCreditBalancePayOutId] = @CreditBalancePayOutId
		ORDER BY
			[intCreditBalancePayOutDetailId]
				
		--ROLLBACK TRANSACTION @TransName
		IF @InitTranCount = 0
			BEGIN
				IF (XACT_STATE()) = -1
					ROLLBACK TRANSACTION
				IF (XACT_STATE()) = 1
					COMMIT TRANSACTION
			END		
		ELSE
			BEGIN
				IF (XACT_STATE()) = -1
					ROLLBACK TRANSACTION  @TransName
				--IF (XACT_STATE()) = 1
				--	COMMIT TRANSACTION  @Savepoint
			END	
		/*
		DECLARE @PayOutId INT
		INSERT INTO tblARCreditBalancePayOut(
			dtmAsOfDate,
			ysnPayBalance,
			ysnPreview,
			dblOpenARBalance,
			intEntityId,
			dtmDate
		)
		SELECT TOP 1
			dtmAsOfDate,
			ysnPayBalance,
			ysnPreview,
			dblOpenARBalance,
			intEntityId,
			dtmDate
		FROM 
			@ARCreditBalancePayOut
		
		SET @PayOutId = @@IDENTITY
		
		INSERT INTO tblARCreditBalancePayOutDetail
			([intCreditBalancePayOutId]
			,[intEntityCustomerId]
			,[intPaymentId]
			,[intBillId]
			,[ysnProcess]
			,[ysnSuccess]
			,[strMessage]
			,[intConcurrencyId])
		SELECT
			 [intCreditBalancePayOutId]
			,[intEntityCustomerId]
			,null
			,[intBillId]
			,[ysnProcess]
			,[ysnSuccess]
			,[strMessage]
			,[intConcurrencyId]
		FROM
			@ARCreditBalancePayOutDetail
		ORDER BY
			[intCreditBalancePayOutDetailId]*/
	END
	

RETURN @CreditBalancePayOutId;
	
END