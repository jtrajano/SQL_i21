
CREATE PROCEDURE [dbo].[uspCFCreateInvoicePayment](
	 @xmlParam					NVARCHAR(MAX)  
	,@entityId					INT			   = NULL
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
		DECLARE @companyLocationId		INT = 0
		DECLARE @accountId				INT = 0
		DECLARE @ysnAddPayment			BIT = 0
		--------------------------------------

		----------TEMPORARY TABLE-------------
		CREATE TABLE #tblCFDisctinctCustomerInvoice	
	(
		 intAccountId					INT
		,intCustomerId					INT
	)
		CREATE TABLE #tblCFInvoiceDiscount	
(
		 intAccountId					INT
		,intSalesPersonId				INT
		,dtmInvoiceDate					DATETIME
		,intCustomerId					INT
		,intInvoiceId					INT
		,intTransactionId				INT
		,intCustomerGroupId				INT
		,intTermID						INT
		,intBalanceDue					INT
		,intDiscountDay					INT	
		,intDayofMonthDue				INT
		,intDueNextMonth				INT
		,intSort						INT
		,intConcurrencyId				INT
		,ysnAllowEFT					BIT
		,ysnActive						BIT
		,ysnEnergyTrac					BIT
		,dblQuantity					NUMERIC(18,6)
		,dblTotalQuantity				NUMERIC(18,6)
		,dblDiscountRate				NUMERIC(18,6)
		,dblDiscount					NUMERIC(18,6)
		,dblTotalAmount					NUMERIC(18,6)
		,dblAccountTotalAmount			NUMERIC(18,6)
		,dblAccountTotalDiscount		NUMERIC(18,6)
		,dblAccountTotalLessDiscount	NUMERIC(18,6)
		,dblDiscountEP					NUMERIC(18,6)
		,dblAPR							NUMERIC(18,6)	
		,strTerm						NVARCHAR(MAX)
		,strType						NVARCHAR(MAX)
		,strTermCode					NVARCHAR(MAX)	
		,strNetwork						NVARCHAR(MAX)	
		,strCustomerName				NVARCHAR(MAX)
		,strInvoiceCycle				NVARCHAR(MAX)
		,strGroupName					NVARCHAR(MAX)
		,strInvoiceNumber				NVARCHAR(MAX)
		,strInvoiceReportNumber			NVARCHAR(MAX)
		,dtmDiscountDate				DATETIME
		,dtmDueDate						DATETIME
		,dtmTransactionDate				DATETIME
		,dtmPostedDate					DATETIME
)
		--------------------------------------

		----------COMPANY PREFERENCE----------
		SELECT TOP 1 
	@companyLocationId = intARLocationId ,
	@accountId = intGLAccountId
	FROM tblCFCompanyPreference
		--------------------------------------
	
		-------------INVOICE LIST-------------
		INSERT INTO #tblCFInvoiceDiscount
	EXEC "dbo"."uspCFInvoiceReportDiscount" @xmlParam=@xmlParam
		--------------------------------------

		----------GROUP BY CUSTOMER-----------
		INSERT INTO #tblCFDisctinctCustomerInvoice(
		 intAccountId	
		,intCustomerId	
	)
	SELECT 
		 intAccountId	
		,intCustomerId	
	FROM #tblCFInvoiceDiscount
	GROUP BY intAccountId,intCustomerId	
		--------------------------------------

		------------LOOP VARIABLES------------
		DECLARE @id							INT
		DECLARE @loopAccountId				INT
		DECLARE @loopCustomerId				INT
		DECLARE @newPaymentId				INT				= NULL	
		DECLARE @newPaymentDetailId			INT				= NULL	
		--------------------------------------

		----------PAYMENT PARAMETERS-----------
		DECLARE @EntityCustomerId		INT										--QUERY
		DECLARE @CurrencyId				INT				= NULL					--NULL
		DECLARE @DatePaid				DATETIME								--QUERY
		DECLARE @BankAccountId			INT				= NULL					--NULL
		DECLARE @AmountPaid				NUMERIC(18,6)	= 0.000000				--QUERY
		DECLARE @PaymentMethodId		INT										--1 AS TEMP (SHOULD BE CF INVOICE)
		DECLARE @PaymentInfo			NVARCHAR(50)	= NULL					--NULL
		DECLARE @ApplytoBudget			BIT				= 0						--0
		DECLARE @ApplyOnAccount			BIT				= 0						--0
		DECLARE @Notes					NVARCHAR(250)	= ''					--''
		DECLARE @AllowPrepayment		BIT				= 0						--0
		DECLARE @AllowOverpayment		BIT				= 0						--0
		DECLARE @RaiseError				BIT				= 0						--0
		DECLARE @InvoiceId				INT				= NULL					--QUERY
		DECLARE @Payment				NUMERIC(18,6)	= 0.000000				--SAME AS AMOUNT PAID?? 
		DECLARE @ApplyTermDiscount		BIT				= 0						--0
		DECLARE @Discount				NUMERIC(18,6)	= 0.000000				--0.000000
		DECLARE @Interest				NUMERIC(18,6)	= 0.000000				--0.000000
		DECLARE @InvoicePrepayment		BIT				= 0						--0
		DECLARE @InvoiceReportNumber	NVARCHAR(250)	= NULL
		---------------------------------------

		------------LOOP CUST GROUP------------
		WHILE (EXISTS(SELECT 1 FROM #tblCFDisctinctCustomerInvoice))
		---------------------------------------
		BEGIN

			SELECT	@loopCustomerId = intCustomerId, 
					@loopAccountId = intAccountId 
			FROM #tblCFDisctinctCustomerInvoice

			------------LOOP INVOICE------------
			WHILE (EXISTS(SELECT 1 FROM #tblCFInvoiceDiscount WHERE intCustomerId = @loopCustomerId AND intAccountId = @loopAccountId))
			---------------------------------------
			BEGIN

				SELECT	TOP 1 @id = intTransactionId
				FROM #tblCFInvoiceDiscount
				WHERE intCustomerId = @loopCustomerId AND intAccountId = @loopAccountId

				SELECT TOP 1
				 @EntityCustomerId		= intCustomerId
				,@AmountPaid			= dblTotalAmount
				,@InvoiceId				= intInvoiceId
				,@Payment				= dblTotalAmount
				,@DatePaid				= dtmInvoiceDate
				,@PaymentMethodId		= (SELECT TOP 1 intPaymentMethodID FROM tblSMPaymentMethod WHERE strPaymentMethod = 'CF Invoice')
				,@InvoiceReportNumber	= strInvoiceReportNumber 
				FROM #tblCFInvoiceDiscount 
				WHERE intTransactionId = @id
				AND (intCustomerId = @loopCustomerId AND intAccountId = @loopAccountId)

				IF (@ysnAddPayment = 0)
				BEGIN

					PRINT 'CREATE PAYMENT'
					EXEC [dbo].[uspARCreateCustomerPayment]
					@EntityCustomerId						= @EntityCustomerId,
					@CompanyLocationId						= @companyLocationId,
					@CurrencyId								= @CurrencyId,
					@DatePaid								= @DatePaid,
					@AccountId								= @accountId,
					@BankAccountId							= @BankAccountId,
					@AmountPaid								= @AmountPaid,
					@PaymentMethodId						= @PaymentMethodId,
					@PaymentInfo							= @PaymentInfo,
					@ApplytoBudget							= @ApplytoBudget,
					@ApplyOnAccount							= @ApplyOnAccount, 
					@Notes									= @Notes,
					@EntityId								= @entityId,
					@AllowPrepayment						= @AllowPrepayment,
					@AllowOverpayment						= @AllowOverpayment,
					@RaiseError								= 1,
					@ErrorMessage							= @ErrorMessage OUTPUT,
					@NewPaymentId							= @newPaymentId OUTPUT,
					@InvoiceId								= @InvoiceId,
					@Payment								= @Payment,
					@ApplyTermDiscount						= @ApplyTermDiscount,
					@Discount								= @Discount,
					@Interest								= @Interest,
					@InvoicePrepayment						= @InvoicePrepayment
					SET @ysnAddPayment = 1

					IF (@CreatedIvoices IS NOT NULL)
					BEGIN
						SET @CreatedIvoices =  @CreatedIvoices + ',' + CONVERT(varchar(10), @newPaymentId)
					END
					ELSE
					BEGIN
						SET @CreatedIvoices = CONVERT(varchar(10), @newPaymentId)
					END

					INSERT INTO tblCFInvoiceProcessResult(
						 strInvoiceProcessResultId
						,intTransactionProcessId
						,ysnStatus
						,strRunProcessId
						,intCustomerId
						,strInvoiceReportNumber
					)

					SELECT TOP 1 
					(SELECT TOP 1 strRecordNumber FROM tblARPayment WHERE intPaymentId = @newPaymentId)
					,@newPaymentId
					,1
					,''
					,@EntityCustomerId
					,@InvoiceReportNumber
					

				END
				ELSE
				BEGIN
					PRINT 'ADD PAYMENT'
					EXEC [dbo].[uspARAddInvoiceToPayment]
					 @PaymentId								= @newPaymentId
					,@InvoiceId								= @InvoiceId
					,@Payment								= @Payment
					,@ApplyTermDiscount						= @ApplyTermDiscount
					,@Discount								= @Discount
					,@Interest								= @Interest
					,@AllowOverpayment						= @AllowOverpayment
					,@RaiseError							= 1
					,@ErrorMessage							= @ErrorMessage		  OUTPUT
					,@NewPaymentDetailId					= @newPaymentDetailId OUTPUT

				END

				DELETE FROM #tblCFInvoiceDiscount 
				WHERE intTransactionId = @id
				AND (intCustomerId = @loopCustomerId AND intAccountId = @loopAccountId)

			END
	
			SET @ysnAddPayment = 0
			DELETE FROM #tblCFDisctinctCustomerInvoice WHERE intAccountId = @loopAccountId AND intCustomerId = @loopCustomerId

		END

		-----------------POST PAYMENT--------------
		EXEC dbo.uspARPostPayment
		@post = 1,
		@recap = 0,
		@param = @CreatedIvoices,
		@successfulCount = @SuccessfulPostCount OUTPUT,
		@invalidCount = @InvalidPostCount OUTPUT
		--------------------------------------------

		DROP TABLE #tblCFInvoiceDiscount
		DROP TABLE #tblCFDisctinctCustomerInvoice

	END TRY
	BEGIN CATCH

		------------SET ERROR MESSAGE-----------
		SET @ErrorMessage = ERROR_MESSAGE ()  
		----------------------------------------

		----------DROP TEMPORARY TABLE----------
		DROP TABLE #tblCFInvoiceDiscount
		DROP TABLE #tblCFDisctinctCustomerInvoice
		----------------------------------------

	END CATCH


END














-----------------------------------
--			  NOTES				 --
-----------------------------------

--DECLARE @total					INT = 0
--DECLARE @counter				INT = 0
--DECLARE @customerId				INT

--Declare @ErrorMessage			NVARCHAR(250) 
--Declare @CreatedIvoices			NVARCHAR(MAX) 
--Declare @UpdatedIvoices			NVARCHAR(MAX) 


--SELECT @total = count(*) from #tblCFInvoiceDiscount
--SET @counter = 1 

--WHILE @counter <= @total 
--BEGIN
--	SELECT TOP 1 @customerId = intCustomerId FROM #tblCFInvoiceDiscount
	
	
--SET @counter = @counter + 1;
--DELETE FROM #tblCFInvoiceDiscount WHERE intCustomerId = @customerId

--SELECT 
-- intCustomerId 
--,strInvoiceReportNumber
--,dblAccountTotalAmount	AS dblTotalAmount
--,dblTotalQuantity		AS dblTotalQuantity
--,dblAccountTotalDiscount 
--,dblDiscountRate
--,'need to implement' AS intEntityId
--,intTermID
--,'need to implement' AS dtmInvoiceDate
--,'need to implement' AS intSalespersonId
--,'need to implement' AS intLocationId
--,'need to implement' AS intGLAccountId
--FROM #tblCFInvoiceDiscount
----WHERE strInvoiceReportNumber = 'CFSI-4805'
--GROUP BY 
--intCustomerId
--,strInvoiceReportNumber
--,dblAccountTotalAmount
--,dblTotalQuantity
--,dblAccountTotalDiscount
--,dblDiscountRate
--,intTermID