CREATE PROCEDURE uspSMCreateInvoicePayment
	@strInvoiceNumber AS NVARCHAR(MAX)
	,@dblPayment AS NUMERIC(18,6) 
	,@strCreditCardNumber AS NVARCHAR(50)
	,@intUserId INT
	,@strAction NVARCHAR(50)
	,@intPaymentId INT = NULL
	,@strPaymentIdNew NVARCHAR(50) OUTPUT
	,@intPaymentIdNew INT OUTPUT
	,@ErrorMessage NVARCHAR(250)  = NULL	OUTPUT
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

DECLARE @EntriesForPayment		AS PaymentIntegrationStagingTable
DECLARE @LogId INT

--================================================================
--   Add
--================================================================
IF @strAction = 'Add'
BEGIN
	insert into @EntriesForPayment
	(
	intId
	,strSourceTransaction
	,intSourceId
	,strSourceId
	,intPaymentId
	,intEntityCustomerId
	,intCompanyLocationId
	,intCurrencyId
	,dtmDatePaid
	,intPaymentMethodId
	,strPaymentMethod
	,strPaymentInfo
	,strNotes
	,intAccountId
	,intBankAccountId
	,dblAmountPaid
	,ysnPost
	,intEntityId
	,intInvoiceId
	,strTransactionType
	,strTransactionNumber
	,intTermId
	,intInvoiceAccountId
	,dblInvoiceTotal
	,dblBaseInvoiceTotal
	,ysnApplyTermDiscount
	,dblDiscount
	,dblDiscountAvailable
	,dblInterest
	,dblPayment
	,dblAmountDue
	,dblBaseAmountDue
	,strInvoiceReportNumber
	,intCurrencyExchangeRateTypeId
	,intCurrencyExchangeRateId
	,dblCurrencyExchangeRate
	,ysnAllowOverpayment
	,ysnFromAP
	)
	select  
	Inv.intInvoiceId
	,strTransactionType
	,Inv.intInvoiceId
	,Inv.strInvoiceNumber
	,intPaymentId
	,intEntityCustomerId
	,intCompanyLocationId
	,intCurrencyId
	,GETDATE()
	,11 --For Credit Card
	,@strCreditCardNumber --Payment Method
	,@strCreditCardNumber --Check weather we can use the payment method cc number
	,'' --Notes
	,Inv.intAccountId
	,NULL --Bank Account
	,dblAmountDue
	,NULL --Set NULL to Create
	,intEntityCustomerId
	,Inv.intInvoiceId
	,Inv.strTransactionType
	,Inv.strTransactionNumber
	,Inv.intTermId
	,Inv.intAccountId
	,Inv.dblInvoiceTotal
	,Inv.dblBaseInvoiceTotal
	,0
	,Inv.dblDiscount
	,Inv.dblDiscountAvailable
	,Inv.dblInterest
	,Inv.dblAmountDue
	,Inv.dblAmountDue
	,Inv.dblBaseAmountDue
	,Inv.strInvoiceReportNumber
	,Inv.intCurrencyExchangeRateTypeId
	,Inv.intCurrencyExchangeRateId
	,Inv.dblCurrencyExchangeRate
	,0
	,0
	from vyuARInvoicesForPayment Inv
	where strInvoiceNumber IN (SELECT strValues COLLATE Latin1_General_CI_AS FROM dbo.fnARGetRowsFromDelimitedValues(@strInvoiceNumber))

	EXEC [dbo].[uspARProcessPayments]
			 @PaymentEntries	= @EntriesForPayment
			,@UserId			= 1
			,@GroupingOption	= 3
			,@RaiseError		= 1
			,@ErrorMessage		= @ErrorMessage OUTPUT
			,@LogId				= @LogId OUTPUT

	SELECT @intPaymentIdNew = ISNULL(intPaymentId,0) FROM tblARPaymentIntegrationLogDetail WHERE intIntegrationLogId = @LogId AND ISNULL(ysnSuccess,0) = 1 AND ysnHeader = 1
	SELECT @strPaymentIdNew = strRecordNumber FROM tblARPayment WHERE intPaymentId = @intPaymentIdNew

	GOTO Exit_Routine
END
--================================================================
--   POST
--================================================================
IF @strAction = 'Post'
BEGIN
	

	EXEC [dbo].[uspARPostPayment]
			@batchId = NULL,
			@post = 1,
			@recap = 0,
			@param = @intPaymentId,
			@userId = @intUserId,
			@beginDate = NULL,
			@endDate = NULL,
			@beginTransaction = NULL,
			@endTransaction = NULL,
			@exclude = NULL,
			@raiseError = 1,
			@bankAccountId = NULL

	SET @intPaymentIdNew = @intPaymentId
	SELECT @strPaymentIdNew = strRecordNumber FROM tblARPayment WHERE intPaymentId = @intPaymentId
	--Set the Card Info Id and Process Credit Card
	UPDATE tblARPayment SET intEntityCardInfoId = @intEntityCardInfoId, ysnProcessCreditCard = 1 WHERE intPaymentId = @intPaymentId

	GOTO Exit_Routine
END

--================================================================
--   DELETE
--================================================================
IF @strAction = 'Delete'
BEGIN
	DELETE FROM tblARPayment WHERE intPaymentId = @intPaymentId
	SET @intPaymentIdNew = @intPaymentId

	GOTO Exit_Routine
END



Exit_Routine:
