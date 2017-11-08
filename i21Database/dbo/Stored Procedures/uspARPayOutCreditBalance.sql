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


DECLARE @ARCustomerAgingStagingTable AS TABLE
(
	[intInvoiceId]				INT NULL, 
    [intEntityCustomerId]		INT NULL, 
    [intCompanyLocationId]		INT NULL, 
    [dtmDate]					DATETIME NULL, 
    [dtmDueDate]				DATETIME NULL, 
    [dtmAsOfDate]				DATETIME NULL, 
    [strCustomerName]			NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL, 
    [strCustomerNumber]			NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL, 
	[strCustomerInfo]			NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL,
    [strInvoiceNumber]			NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL, 
    [strRecordNumber]			NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL, 
    [strBOLNumber]				NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL, 
    [strSalespersonName]		NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL, 
    [strSourceTransaction]		NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL,
	[strType]					NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL,
	[strCompanyName]            NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL,
    [strCompanyAddress]         NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL,
    [dblCreditLimit]			NUMERIC(18, 6) NULL, 
    [dblTotalAR]				NUMERIC(18, 6) NULL, 
    [dblFuture]					NUMERIC(18, 6) NULL, 
    [dbl0Days]					NUMERIC(18, 6) NULL, 
    [dbl10Days]					NUMERIC(18, 6) NULL, 
    [dbl30Days]					NUMERIC(18, 6) NULL, 
    [dbl60Days]					NUMERIC(18, 6) NULL, 
    [dbl90Days]					NUMERIC(18, 6) NULL,
	[dbl91Days]					NUMERIC(18, 6) NULL,
	[dbl120Days]				NUMERIC(18, 6) NULL,
	[dbl121Days]				NUMERIC(18, 6) NULL,
    [dblTotalDue]				NUMERIC(18, 6) NULL, 
    [dblAmountPaid]				NUMERIC(18, 6) NULL, 
    [dblInvoiceTotal]			NUMERIC(18, 6) NULL, 
    [dblCredits]				NUMERIC(18, 6) NULL, 
    [dblPrepayments]			NUMERIC(18, 6) NULL, 
    [dblPrepaids]				NUMERIC(18, 6) NULL
)

DELETE FROM @ARCustomerAgingStagingTable

INSERT INTO @ARCustomerAgingStagingTable
	(
	 [strCustomerName]
	,[strCustomerNumber]
	,[strCustomerInfo]
	,[strInvoiceNumber]
	,[strRecordNumber]
	,[intInvoiceId]
	,[strBOLNumber]
	,[intEntityCustomerId]
	,[dblCreditLimit]
	,[dblTotalAR]
	,[dblFuture]
	,[dbl0Days]
	,[dbl10Days]
	,[dbl30Days]
	,[dbl60Days]
	,[dbl90Days]
	,[dbl120Days]
	,[dbl121Days]
	,[dblTotalDue]
	,[dblAmountPaid]
	,[dblInvoiceTotal]
	,[dblCredits]
	,[dblPrepayments]
	,[dblPrepaids]
	,[dtmDate]
	,[dtmDueDate]
	,[dtmAsOfDate]
	,[strSalespersonName]
	,[intCompanyLocationId]
	,[strSourceTransaction]
	,[strType]
	,[strCompanyName]
	,[strCompanyAddress]
)
EXEC [dbo].[uspARCustomerAgingDetailAsOfDateReport] @dtmDateTo = @AsOfDate, @ysnInclude120Days = 0


IF (DATEPART(dd, @AsOfDate) = 31)
	DELETE FROM @ARCustomerAgingStagingTable WHERE dtmDueDate = @AsOfDate

DELETE FROM @ARCustomerAgingStagingTable
WHERE
	[strInvoiceNumber] IN (SELECT strInvoiceNumber FROM tblARInvoice WHERE strType IN ('CF Tran'))

DELETE FROM @ARCustomerAgingStagingTable
WHERE
	[intEntityCustomerId] NOT IN (SELECT [intEntityId] FROM @Customers)

DELETE FROM @ARCustomerAgingStagingTable
WHERE
	[intEntityCustomerId] IN (SELECT [intEntityCustomerId] FROM  @ARCustomerAgingStagingTable  GROUP BY [intEntityCustomerId] HAVING SUM([dblTotalAR]) > @OpenARBalance)



DECLARE @CustomerBalances AS TABLE
(
    [intId]                     INT IDENTITY,
    [intInvoiceId]				INT NULL, 
    [intEntityCustomerId]		INT NULL, 
    [intCompanyLocationId]		INT NULL, 
    [dblTotalAR]				NUMERIC(18, 6) NULL,
	[ysnProcessed]              BIT
)
DELETE FROM @CustomerBalances

INSERT INTO @CustomerBalances
(
     [intInvoiceId]
    ,[intEntityCustomerId]
    ,[intCompanyLocationId]
    ,[dblTotalAR]
	,[ysnProcessed]
)
SELECT
     [intInvoiceId]         = [intInvoiceId]
    ,[intEntityCustomerId]  = [intEntityCustomerId]
    ,[intCompanyLocationId] = [intCompanyLocationId]
    ,[dblTotalAR]           = SUM([dblTotalAR])
	,[ysnProcessed]         = 0
FROM
	@ARCustomerAgingStagingTable
GROUP BY
     [intEntityCustomerId]
    ,[intInvoiceId]
    ,[intCompanyLocationId]

DECLARE @VendorId AS INT
        ,@InvoiceId AS INT
		,@BillId AS INT
		,@AccountId AS INT
        ,@CompanyLocationId AS INT
        ,@TotalAR AS NUMERIC(18,6)
		,@Id AS INT
        ,@IdList AS NVARCHAR(MAX)
        ,@PostingSuccessful AS BIT

	
IF ISNULL(@Preview,0) = 1
BEGIN
    IF ISNULL(@PayBalance,0) = 1
        BEGIN
			
            RETURN @CreditBalancePayOutId;
        END
    ELSE
	    BEGIN
            RETURN @CreditBalancePayOutId;
	    END
END


IF ISNULL(@Preview,0) = 0
BEGIN
    IF ISNULL(@PayBalance,0) = 1
        BEGIN
			SET @IdList = NULL
			SET @PostingSuccessful = 0
		    DECLARE @EntityIds AS [Id]
			INSERT INTO @EntityIds([intId])
			SELECT CB.[intEntityCustomerId] FROM @CustomerBalances CB WHERE NOT EXISTS(SELECT NULL FROM tblAPVendor APV WHERE CB.[intEntityCustomerId] = APV.[intEntityId])

            EXEC [dbo].[uspEMConvertCustomerToVendor] @CustomerIds = @EntityIds, @UserId = @UserId


			WHILE EXISTS(SELECT TOP 1 NULL FROM @CustomerBalances WHERE [ysnProcessed] = 0)
			BEGIN
			    SELECT @VendorId = NULL, @InvoiceId = NULL, @AccountId = NULL, @BillId = NULL, @CompanyLocationId = NULL, @TotalAR = @ZeroDecimal
				SELECT TOP 1
				     @VendorId          = CB.[intEntityCustomerId]
					,@InvoiceId         = ARI.[intInvoiceId]
					,@AccountId         = ARI.[intAccountId]
					,@CompanyLocationId = CB.[intCompanyLocationId]
					,@TotalAR           = CB.[dblTotalAR]
					,@Id                = CB.[intId]
				FROM
					@CustomerBalances CB
				INNER JOIN
					(SELECT [intInvoiceId], [intAccountId] FROM tblARInvoice) ARI
					    ON CB.[intInvoiceId] = ARI.[intInvoiceId]

                DECLARE @VoucherDetailNonInventory AS VoucherDetailNonInventory
                DELETE FROM @VoucherDetailNonInventory

                INSERT INTO @VoucherDetailNonInventory
                    ([intAccountId]
                    ,[intItemId]
                    ,[strMiscDescription]
                    ,[dblQtyReceived]
                    ,[dblDiscount]
                    ,[dblCost]
                    ,[intTaxGroupId])
				SELECT
                     [intAccountId]         = @AccountId
                    ,[intItemId]            = NULL
                    ,[strMiscDescription]   = ''
                    ,[dblQtyReceived]       = 1.000000
                    ,[dblDiscount]          = @ZeroDecimal
                    ,[dblCost]              = @TotalAR
                    ,[intTaxGroupId]        = NULL


                EXEC [dbo].[uspAPCreateBillData]
                     @userId                = @UserId
                    ,@vendorId              = @VendorId
                    ,@type                  = 1
                    ,@voucherNonInvDetails  = @VoucherDetailNonInventory
                    ,@voucherDate           = @DateNow
					,@billId                = @BillId OUTPUT


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
					,[ysnProcess]
					,[ysnSuccess]
					,[strMessage]
					,[intConcurrencyId])
				SELECT
					 [intCreditBalancePayOutId]	= @CreditBalancePayOutId
					,[intEntityCustomerId]		= APB.intEntityId 
					,[intPaymentId]				= NULL
					,[intBillId]				= APB.[intBillId]
					,[ysnProcess]				= 1
					,[ysnSuccess]				= 1				
					,[strMessage]				= ''
					,[intConcurrencyId]			= 0
				FROM
					tblAPBill APB
				WHERE
					APB.[intEntityId] IN (SELECT intID FROM [dbo].[fnGetRowsFromDelimitedValues](@IdList))
			END


            RETURN @CreditBalancePayOutId;
	    END
    ELSE
	    BEGIN
			
            RETURN @CreditBalancePayOutId;
	    END
END



RETURN 1;
	
END
