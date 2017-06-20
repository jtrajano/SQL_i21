CREATE PROCEDURE [dbo].[uspCFCreateInvoicePayment](
	 @entityId					INT			   = NULL
	,@ErrorMessage				NVARCHAR(250)  = NULL	OUTPUT
	,@CreatedIvoices			NVARCHAR(MAX)  = NULL	OUTPUT
	,@UpdatedIvoices			NVARCHAR(MAX)  = NULL	OUTPUT
	,@SuccessfulPostCount		INT			   = 0		OUTPUT
	,@InvalidPostCount			INT			   = 0		OUTPUT
	,@ysnDevMode				BIT = 0
)
AS
BEGIN

	BEGIN TRY 
   
		
		---------------VARIABLES--------------
		DECLARE @EntriesForPayment		AS PaymentIntegrationStagingTable
		DECLARE @companyLocationId		INT = 0
		DECLARE @accountId				INT = 0
		DECLARE @executedLine			INT = 0 
		DECLARE @ysnAddPayment			BIT = 0
		--------------------------------------

		------------TEMPORARY TABLE-------------
		SET @executedLine = 1
		CREATE TABLE #tblCFPaymentResult	
		(
			intPaymentId				INT
		)

		
		--CREATE TABLE #tblCFDisctinctCustomerInvoice	
		--(
		--	 intAccountId					INT
		--	,intCustomerId					INT
		--)

		--SET @executedLine = 2
		--CREATE TABLE #tblCFInvoices	
		--(
		--	 intAccountId					INT
		--	,intSalesPersonId				INT
		--	,dtmInvoiceDate					DATETIME
		--	,intCustomerId					INT
		--	,intInvoiceId					INT
		--	,intTransactionId				INT
		--	,intCustomerGroupId				INT
		--	,intTermID						INT
		--	,intBalanceDue					INT
		--	,intDiscountDay					INT	
		--	,intDayofMonthDue				INT
		--	,intDueNextMonth				INT
		--	,intSort						INT
		--	,ysnAllowEFT					BIT
		--	,ysnActive						BIT
		--	,ysnEnergyTrac					BIT
		--	,dblQuantity					NUMERIC(18,6)
		--	,dblTotalQuantity				NUMERIC(18,6)
		--	,dblDiscountRate				NUMERIC(18,6)
		--	,dblDiscount					NUMERIC(18,6)
		--	,dblTotalAmount					NUMERIC(18,6)
		--	,dblAccountTotalAmount			NUMERIC(18,6)
		--	,dblAccountTotalDiscount		NUMERIC(18,6)
		--	,dblAccountTotalLessDiscount	NUMERIC(18,6)
		--	,dblDiscountEP					NUMERIC(18,6)
		--	,dblAPR							NUMERIC(18,6)	
		--	,strTerm						NVARCHAR(MAX)
		--	,strType						NVARCHAR(MAX)
		--	,strTermCode					NVARCHAR(MAX)	
		--	,strNetwork						NVARCHAR(MAX)	
		--	,strCustomerName				NVARCHAR(MAX)
		--	,strInvoiceCycle				NVARCHAR(MAX)
		--	,strGroupName					NVARCHAR(MAX)
		--	,strInvoiceNumber				NVARCHAR(MAX)
		--	,strInvoiceReportNumber			NVARCHAR(MAX)
		--	,dtmDiscountDate				DATETIME
		--	,dtmDueDate						DATETIME
		--	,dtmTransactionDate				DATETIME
		--	,dtmPostedDate					DATETIME
		--)
		----------------------------------------


		----------COMPANY PREFERENCE----------
		SET @executedLine = 2
		SELECT TOP 1 
			@companyLocationId = intARLocationId ,
			@accountId = intGLAccountId
		FROM tblCFCompanyPreference
		--------------------------------------
	
		-------------INVOICE LIST-------------
		SET @executedLine = 3
		INSERT INTO @EntriesForPayment
		(
		  intEntityCustomerId		
		 ,intCompanyLocationId								
		 ,intCurrencyId				
		 ,dtmDatePaid					
		 ,intWriteOffAccountId			
		 ,intBankAccountId				
		 ,dblAmountPaid					
		 ,intPaymentMethodId			
		 ,strPaymentInfo				
		 ,ysnApplytoBudget				
		 ,ysnApplyOnAccount				
		 ,strNotes					
		 ,intEntityId				
		 ,ysnAllowPrepayment		
		 ,ysnAllowOverpayment		
		 ,intInvoiceId				
		 ,dblPayment				
		 ,ysnApplyTermDiscount		
		 ,dblDiscount				
		 ,dblInterest				
		 ,ysnInvoicePrepayment	
		 ,ysnPost	
		)
		SELECT 
		 intCustomerId
		,@companyLocationId
		,NULL
		,dtmInvoiceDate
		,@accountId
		,NULL
		,dblTotalAmount
		,(SELECT TOP 1 intPaymentMethodID FROM tblSMPaymentMethod WHERE strPaymentMethod = 'CF Invoice')
		,strInvoiceReportNumber
		,0
		,0
		,''
		,@entityId
		,0
		,0
		,intInvoiceId
		,dblTotalAmount
		,0
		,0.000000
		,0.000000
		,0.000000
		,1
		FROM tblCFInvoiceStagingTable
		--------------------------------------

		SET @executedLine = 4
		DECLARE @PaymentEntriesTEMP	PaymentIntegrationStagingTable
		INSERT INTO @PaymentEntriesTEMP
		(
		  intId
		 ,intEntityCustomerId		
		 ,intCompanyLocationId								
		 ,intCurrencyId				
		 ,dtmDatePaid					
		 ,intWriteOffAccountId			
		 ,intBankAccountId				
		 ,dblAmountPaid					
		 ,intPaymentMethodId			
		 ,strPaymentInfo				
		 ,ysnApplytoBudget				
		 ,ysnApplyOnAccount				
		 ,strNotes					
		 ,intEntityId				
		 ,ysnAllowPrepayment		
		 ,ysnAllowOverpayment		
		 ,intInvoiceId				
		 ,dblPayment				
		 ,ysnApplyTermDiscount		
		 ,dblDiscount				
		 ,dblInterest				
		 ,ysnInvoicePrepayment	
		 ,ysnPost			
		)
		SELECT 
		ROW_NUMBER() OVER(ORDER BY intEntityCustomerId ASC)
		,intEntityCustomerId		
		,intCompanyLocationId								
		,intCurrencyId				
		,dtmDatePaid					
		,intWriteOffAccountId			
		,intBankAccountId				
		,dblAmountPaid					
		,intPaymentMethodId			
		,strPaymentInfo				
		,ysnApplytoBudget				
		,ysnApplyOnAccount				
		,strNotes					
		,intEntityId				
		,ysnAllowPrepayment		
		,ysnAllowOverpayment		
		,intInvoiceId				
		,dblPayment				
		,ysnApplyTermDiscount		
		,dblDiscount				
		,dblInterest				
		,ysnInvoicePrepayment	
		,ysnPost			
		FROM @EntriesForPayment

		------------GROUP BY CUSTOMER-----------
		--SET @executedLine = 5
		--INSERT INTO #tblCFDisctinctCustomerInvoice(
		--	 intAccountId	
		--	,intCustomerId	
		--)
		--SELECT 
		--	 intAccountId	
		--	,intCustomerId	
		--FROM #tblCFInvoices
		--GROUP BY intAccountId,intCustomerId	
		----------------------------------------

		--------------LOOP VARIABLES------------
		--SET @executedLine = 6
		--DECLARE @id							INT
		--DECLARE @loopAccountId				INT
		--DECLARE @loopCustomerId				INT
		--DECLARE @newPaymentId				INT				= NULL	
		--DECLARE @newPaymentDetailId			INT				= NULL	
		----------------------------------------

		------------PAYMENT PARAMETERS-----------
		--SET @executedLine = 7
		--DECLARE @EntityCustomerId		INT										--QUERY
		--DECLARE @CurrencyId				INT				= NULL					--NULL
		--DECLARE @DatePaid				DATETIME								--QUERY
		--DECLARE @BankAccountId			INT				= NULL					--NULL
		--DECLARE @AmountPaid				NUMERIC(18,6)	= 0.000000				--QUERY
		--DECLARE @PaymentMethodId		INT										--1 AS TEMP (SHOULD BE CF INVOICE)
		--DECLARE @PaymentInfo			NVARCHAR(50)	= NULL					--NULL
		--DECLARE @ApplytoBudget			BIT				= 0						--0
		--DECLARE @ApplyOnAccount			BIT				= 0						--0
		--DECLARE @Notes					NVARCHAR(250)	= ''					--''
		--DECLARE @AllowPrepayment		BIT				= 0						--0
		--DECLARE @AllowOverpayment		BIT				= 0						--0
		--DECLARE @RaiseError				BIT				= 0						--0
		--DECLARE @InvoiceId				INT				= NULL					--QUERY
		--DECLARE @Payment				NUMERIC(18,6)	= 0.000000				--SAME AS AMOUNT PAID?? 
		--DECLARE @ApplyTermDiscount		BIT				= 0						--0
		--DECLARE @Discount				NUMERIC(18,6)	= 0.000000				--0.000000
		--DECLARE @Interest				NUMERIC(18,6)	= 0.000000				--0.000000
		--DECLARE @InvoicePrepayment		BIT				= 0						--0
		--DECLARE @InvoiceReportNumber	NVARCHAR(250)	= NULL
		-----------------------------------------


		

		--------------LOOP CUST GROUP------------
		--SET @executedLine = 8
		--WHILE (EXISTS(SELECT 1 FROM #tblCFDisctinctCustomerInvoice))
		-----------------------------------------
		--BEGIN
			
		--	SET @executedLine = 9
		--	SELECT	@loopCustomerId = intCustomerId, 
		--			@loopAccountId = intAccountId 
		--	FROM #tblCFDisctinctCustomerInvoice

		--	------------LOOP INVOICE------------
		--	SET @executedLine = 10
		--	WHILE (EXISTS(SELECT 1 FROM #tblCFInvoices WHERE intCustomerId = @loopCustomerId AND intAccountId = @loopAccountId))
		--	---------------------------------------
		--	BEGIN

		--		SET @executedLine = 11
		--		SELECT	TOP 1 @id = intTransactionId
		--		FROM #tblCFInvoices
		--		WHERE intCustomerId = @loopCustomerId AND intAccountId = @loopAccountId

		--		SET @executedLine = 12
		--		SELECT TOP 1
		--		 @EntityCustomerId		= intCustomerId
		--		,@AmountPaid			= dblTotalAmount
		--		,@InvoiceId				= intInvoiceId
		--		,@Payment				= dblTotalAmount
		--		,@DatePaid				= dtmInvoiceDate
		--		,@PaymentMethodId		= (SELECT TOP 1 intPaymentMethodID FROM tblSMPaymentMethod WHERE strPaymentMethod = 'CF Invoice')
		--		,@InvoiceReportNumber	= strInvoiceReportNumber 
		--		,@PaymentInfo			= strInvoiceReportNumber
		--		FROM #tblCFInvoices
		--		WHERE intTransactionId = @id
		--		AND (intCustomerId = @loopCustomerId AND intAccountId = @loopAccountId)


		--		IF (@ysnAddPayment = 0)
		--		BEGIN

		--			SET @executedLine = 13
		--			PRINT 'CREATE PAYMENT'
		--			EXEC [dbo].[uspARCreateCustomerPayment]
		--			@EntityCustomerId						= @EntityCustomerId,
		--			@CompanyLocationId						= @companyLocationId,
		--			@CurrencyId								= @CurrencyId,
		--			@DatePaid								= @DatePaid,
		--			@WriteOffAccountId						= @accountId,
		--			@BankAccountId							= @BankAccountId,
		--			@AmountPaid								= @AmountPaid,
		--			@PaymentMethodId						= @PaymentMethodId,
		--			@PaymentInfo							= @PaymentInfo,
		--			@ApplytoBudget							= @ApplytoBudget,
		--			@ApplyOnAccount							= @ApplyOnAccount, 
		--			@Notes									= @Notes,
		--			@EntityId								= @entityId,
		--			@AllowPrepayment						= @AllowPrepayment,
		--			@AllowOverpayment						= @AllowOverpayment,
		--			@RaiseError								= 1,
		--			@ErrorMessage							= @ErrorMessage OUTPUT,
		--			@NewPaymentId							= @newPaymentId OUTPUT,
		--			@InvoiceId								= @InvoiceId,
		--			@Payment								= @Payment,
		--			@ApplyTermDiscount						= @ApplyTermDiscount,
		--			@Discount								= @Discount,
		--			@Interest								= @Interest,
		--			@InvoicePrepayment						= @InvoicePrepayment
		--			SET @ysnAddPayment = 1

		--			SET @executedLine = 14
		--			IF (@CreatedIvoices IS NOT NULL)
		--			BEGIN
		--				SET @CreatedIvoices =  @CreatedIvoices + ',' + CONVERT(varchar(10), @newPaymentId)
		--			END
		--			ELSE
		--			BEGIN
		--				SET @CreatedIvoices = CONVERT(varchar(10), @newPaymentId)
		--			END

		--			SET @executedLine = 15
		--			INSERT INTO tblCFInvoiceProcessResult(
		--				 strPaymentId
		--				,intPaymentId
		--				,ysnStatus
		--				,strRunProcessId
		--				,intCustomerId
		--				,strInvoiceReportNumber
		--				,dblPayment
		--			)

		--			SELECT TOP 1 
		--			(SELECT TOP 1 strRecordNumber FROM tblARPayment WHERE intPaymentId = @newPaymentId)
		--			,@newPaymentId
		--			,1
		--			,''
		--			,@EntityCustomerId
		--			,@InvoiceReportNumber
		--			,(SELECT SUM(ISNULL(dblTotalAmount,0)) FROM #tblCFInvoices WHERE intCustomerId = @loopCustomerId AND intAccountId = @loopAccountId)

					

		--		END
		--		ELSE
		--		BEGIN
		--			SET @executedLine = 16
		--			PRINT 'ADD PAYMENT'
		--			EXEC [dbo].[uspARAddInvoiceToPayment]
		--			 @PaymentId								= @newPaymentId
		--			,@InvoiceId								= @InvoiceId
		--			,@Payment								= @Payment
		--			,@ApplyTermDiscount						= @ApplyTermDiscount
		--			,@Discount								= @Discount
		--			,@Interest								= @Interest
		--			,@AllowOverpayment						= @AllowOverpayment
		--			,@RaiseError							= 1
		--			,@ErrorMessage							= @ErrorMessage		  OUTPUT
		--			,@NewPaymentDetailId					= @newPaymentDetailId OUTPUT

		--		END

		--		SET @executedLine = 17
		--		DELETE FROM #tblCFInvoices 
		--		WHERE intTransactionId = @id
		--		AND (intCustomerId = @loopCustomerId AND intAccountId = @loopAccountId)

		--	END
	
		--	SET @executedLine = 18
		--	SET @ysnAddPayment = 0
		--	DELETE FROM #tblCFDisctinctCustomerInvoice WHERE intAccountId = @loopAccountId AND intCustomerId = @loopCustomerId

		--END

		-------------------POST PAYMENT--------------
		--SET @executedLine = 19
		--EXEC dbo.uspARPostPayment
		--@post = 1,
		--@recap = 0,
		--@param = @CreatedIvoices,
		--@successfulCount = @SuccessfulPostCount OUTPUT,
		--@invalidCount = @InvalidPostCount OUTPUT
		----------------------------------------------

		--SET @executedLine = 20
		--DROP TABLE #tblCFInvoices
		--DROP TABLE #tblCFDisctinctCustomerInvoice

		SET @executedLine = 5
		DECLARE @LogId INT
		EXEC [dbo].[uspARProcessPayments]
		 @PaymentEntries	= @PaymentEntriesTEMP
		,@UserId			= 1
		,@GroupingOption	= 0
		,@RaiseError		= 1
		,@ErrorMessage		= @ErrorMessage OUTPUT
		,@LogId				= @LogId OUTPUT

		SET @executedLine = 6
		DECLARE @SuccessfulCount INT
		SET @SuccessfulCount = 0;
		INSERT INTO #tblCFPaymentResult
		(
			intPaymentId
		)
		SELECT intPaymentId FROM tblARPaymentIntegrationLogDetail WHERE intIntegrationLogId = @LogId AND ISNULL(ysnSuccess,0) = 1 AND ysnHeader = 1 
		SELECT @SuccessfulCount = Count(*) FROM #tblCFPaymentResult

		DECLARE @intPaymentResultId		INT
		DECLARE @strPaymentNumber		NVARCHAR(500)
		DECLARE @intEntityCustomerId	INT
		DECLARE @dblAmountPaid			NUMERIC(18,6)

		------------LOOP CUST GROUP------------
		SET @executedLine = 7
		WHILE (EXISTS(SELECT 1 FROM #tblCFPaymentResult))
		---------------------------------------
		BEGIN
			
			SET @executedLine = 8
			SELECT	TOP 1 
			@intPaymentResultId = intPaymentId
			FROM #tblCFPaymentResult

			SET @executedLine = 9
			SELECT TOP 1 
			 @strPaymentNumber		= strPaymentInfo
			,@intEntityCustomerId	= intEntityCustomerId	
			,@dblAmountPaid			= dblAmountPaid
			FROM tblARPayment 
			WHERE intPaymentId = @intPaymentResultId

			--select * FROM tblCFInvoiceProcessResult
			SET @executedLine = 10
			INSERT INTO tblCFInvoiceProcessResult(
				 strPaymentId
				,intPaymentId
				,ysnStatus
				,strRunProcessId
				,intCustomerId
				--,strInvoiceReportNumber
				,dblPayment
			)
			SELECT
			 @strPaymentNumber
			,@intPaymentResultId
			,1
			,''
			,@intEntityCustomerId
			--,''
			,@dblAmountPaid

			SET @executedLine = 11
			DELETE FROM #tblCFPaymentResult 
			WHERE intPaymentId = @intPaymentResultId
		END

	END TRY
	BEGIN CATCH

		------------SET ERROR MESSAGE-----------
		DECLARE @CatchErrorMessage NVARCHAR(4000);  
		DECLARE @CatchErrorSeverity INT;  
		DECLARE @CatchErrorState INT;  
  
		SELECT   
			@CatchErrorMessage = 'Line:' + (LTRIM(RTRIM(STR(@executedLine)))) + ' Process Payment  > ' + ERROR_MESSAGE(),  
			@CatchErrorSeverity = ERROR_SEVERITY(),  
			@CatchErrorState = ERROR_STATE();  
  
		RAISERROR (
			@CatchErrorMessage, 
			@CatchErrorSeverity, 
			@CatchErrorState   
		);  
		----------------------------------------

		----------DROP TEMPORARY TABLE----------
		--DROP TABLE #tblCFInvoices
		--DROP TABLE #tblCFDisctinctCustomerInvoice
		----------------------------------------

	END CATCH


END