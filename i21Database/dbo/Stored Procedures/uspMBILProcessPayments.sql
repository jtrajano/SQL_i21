CREATE PROCEDURE [dbo].[uspMBILProcessPayments]
	@Param				AS NVARCHAR(MAX)	= '',	
	@ysnPost			AS BIT				=  0,
	@ysnRecap			AS BIT				=  0,
	@UserId				AS INT					,	
	@BatchId			NVARCHAR(MAX)		= NULL,
	@SuccessfulCount	INT					= 0		 OUTPUT,
	@ErrorMessage		NVARCHAR(250)		= NULL	 OUTPUT,
	@CreatedInvoices	NVARCHAR(MAX)		= NULL	 OUTPUT,
	@UpdatedInvoices	NVARCHAR(MAX)		= NULL	 OUTPUT
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

BEGIN

	DECLARE @ErrorSeverity INT
	DECLARE @ErrorState INT

	---------------VARIABLES--------------
	DECLARE @EntriesForPayment		AS PaymentIntegrationStagingTable
	--------------------------------------

	CREATE TABLE #TempMBILPayment (
		[intPaymentId]		INT
	);

	CREATE TABLE #tblMBILPaymentResult (
		[intPaymentId]		INT,
		[intSourceId]		INT
	);

	--=====================================================================================================================================
	-- 	POPULATE INVOICE TO POST TEMPORARY TABLE
	---------------------------------------------------------------------------------------------------------------------------------------
	IF (ISNULL(@Param, '') <> '') 
		INSERT INTO #TempMBILPayment EXEC (@Param)
	ELSE
		INSERT INTO #TempMBILPayment SELECT [intPaymentId] FROM vyuMBILPayment WHERE ysnPosted = 0

	-------------------------------------------------------------
	------------------- Validate Invoices -----------------------
	-------------------------------------------------------------
	IF EXISTS(SELECT TOP 1 1 FROM vyuMBILPayment WHERE intPaymentId IN (SELECT intPaymentId FROM #TempMBILPayment) AND inti21PaymentId IS NOT NULL)
	BEGIN
		SET @ErrorMessage = 'Record already posted.'
		RETURN
	END
	-------------------------------------------------------------
	------------------- End of Validations ----------------------
	-------------------------------------------------------------
	
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
		,strPaymentMethod				
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
		,strSourceTransaction
		,strSourceId
		,intSourceId
	)
	SELECT 
		intEntityCustomerId
		,intLocationId
		,(SELECT TOP 1 intDefaultCurrencyId FROM tblSMCompanyPreference)
		,dtmDatePaid
		,NULL
		,NULL
		,dblPayment
		,(SELECT TOP 1 intPaymentMethodID FROM tblSMPaymentMethod WHERE strPaymentMethod = vyuMBILPayment.strMethod)
		,strMethod
		,strCheckNumber
		,0
		,0
		,strComments
		,@UserId
		,0
		,0
		,intPaymentId
		,dblPayment
		,0
		,0.000000
		,0.000000
		,0.000000
		,1
		,'Mobile Billing'
		,strPaymentNo
		,intPaymentId

	FROM vyuMBILPayment
	WHERE inti21PaymentId IS NULL and intPaymentId IN (select intPaymentId from #TempMBILPayment)


	DECLARE @PaymentEntries	PaymentIntegrationStagingTable
	INSERT INTO @PaymentEntries
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
		 ,strPaymentMethod			
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
		 ,strSourceTransaction
		 ,strSourceId
		 ,intSourceId
		)
	SELECT 		
		ROW_NUMBER() OVER(ORDER BY intEntityCustomerId ASC) as intId
		,intEntityCustomerId		
		,intCompanyLocationId								
		,intCurrencyId				
		,dtmDatePaid					
		,intWriteOffAccountId			
		,intBankAccountId				
		,dblAmountPaid					
		,intPaymentMethodId			
		,strPaymentMethod
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
		,strSourceTransaction
		,strSourceId
		,intSourceId

	FROM @EntriesForPayment


	DECLARE @LogId INT

	EXEC [dbo].[uspARProcessPayments]
		 @PaymentEntries	= @PaymentEntries
		,@UserId			= @UserId
		,@GroupingOption	= 1
		,@RaiseError		= 1
		,@ErrorMessage		= @ErrorMessage OUTPUT
		,@LogId				= @LogId OUTPUT

	SET @SuccessfulCount = 0;
	INSERT INTO #tblMBILPaymentResult
	(
		intPaymentId,
		intSourceId
	)
	SELECT intPaymentId, intSourceId FROM tblARPaymentIntegrationLogDetail WHERE intIntegrationLogId = @LogId AND ISNULL(ysnSuccess,0) = 1 AND ysnHeader = 1 
	SELECT @SuccessfulCount = Count(*) FROM #tblMBILPaymentResult

	DECLARE @intPaymentResultId		INT
	DECLARE @strPaymentNumber		NVARCHAR(500)
	DECLARE @intEntityCustomerId	INT
	DECLARE @dblAmountPaid			NUMERIC(18,6)

	IF (ISNULL(@ysnRecap,0) = 0 AND (@ysnPost = 1))
	BEGIN
		WHILE EXISTS(SELECT 1 FROM #tblMBILPaymentResult)
		BEGIN
			DECLARE @intPaymentId INT
			DECLARE @intSourceId INT

			SELECT TOP 1 @intPaymentId = intPaymentId, @intSourceId = intSourceId FROM #tblMBILPaymentResult

			UPDATE Payment
			SET 
				 Payment.ysnPosted	     = (SELECT TOP 1 ysnPosted FROM tblARPayment WHERE intPaymentId = @intPaymentId)
				,Payment.inti21PaymentId = @intPaymentId
			FROM
			tblMBILPayment Payment
			WHERE Payment.intPaymentId = @intSourceId

			DELETE FROM #tblMBILPaymentResult WHERE intPaymentId = @intPaymentId
		END

	END

END



--EXEC [uspMBILProcessPayments] 'select intPaymentId from tblMBILPayment where intPaymentId = 29', 1, 0, 1
--select * from tblMBILPayment
