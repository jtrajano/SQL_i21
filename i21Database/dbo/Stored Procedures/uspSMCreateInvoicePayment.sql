CREATE PROCEDURE uspSMCreateInvoicePayment
	@strInvoiceNumber AS NVARCHAR(MAX)
	,@dblPayment AS NUMERIC(18,6) 
	,@strInvoiceAndPayment AS NVARCHAR(MAX)
	,@strCreditCardNumber AS NVARCHAR(50)
	,@intUserId INT
	,@strAction NVARCHAR(50)
	,@intEntityCardInfoId INT = NULL
	,@intPaymentId INT = NULL
	,@strPaymentIdNew NVARCHAR(50) OUTPUT
	,@intPaymentIdNew INT OUTPUT
	,@ErrorMessage NVARCHAR(250)  = NULL	OUTPUT
AS

SET QUOTED_IDENTIFIER ON
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS ON

DECLARE @EntriesForPayment		AS PaymentIntegrationStagingTable
DECLARE @LogId INT

--================================================================
--   Add
--================================================================
IF @strAction = 'Add'
BEGIN

	--Create a temp table to store the ivoice number and corresponding amount
	SELECT  strValues as strRawValue INTO #RawValue  FROM dbo.fnARGetRowsFromDelimitedValues(@strInvoiceAndPayment)

	SELECT A.InvoiceNumber
		,CONVERT(NUMERIC(18,6),Split.a.value('.', 'VARCHAR(100)')) AS Payment
		INTO #InvoiceAndPayment
	FROM (
		SELECT left(strRawValue, charindex('|', strRawValue) - 1) AS InvoiceNumber
			,CAST('<M>' + REPLACE(substring(strRawValue, charindex('|', strRawValue) + 1, len(strRawValue) - charindex('|', strRawValue)), ',', '</M><M>') + '</M>' AS XML) AS String
		FROM #RawValue
		) AS A
	CROSS APPLY String.nodes('/M') AS Split(a);

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
	,(SELECT TOP 1 Payment FROM #InvoiceAndPayment WHERE InvoiceNumber COLLATE Latin1_General_CI_AS = Inv.strInvoiceNumber) --Get the amount from the temp table created above
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
	UPDATE tblARPayment 
	SET intEntityCardInfoId = @intEntityCardInfoId
	  , ysnProcessCreditCard = 1 
	  , intCurrentStatus = 5
	WHERE intPaymentId = @intPaymentId

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
