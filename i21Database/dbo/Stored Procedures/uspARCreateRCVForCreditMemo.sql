CREATE PROCEDURE [dbo].[uspARCreateRCVForCreditMemo]
	  @intInvoiceId		INT
	, @intUserId 		INT
AS

SET QUOTED_IDENTIFIER OFF  
SET ANSI_NULLS ON  
SET NOCOUNT ON  
SET XACT_ABORT OFF  
SET ANSI_WARNINGS OFF  

DECLARE @tblPrepaids			TABLE(intPrepaymentId INT, dblAppliedAmount NUMERIC(18, 6))
DECLARE @InvoicesDetail			TABLE(intInvoiceId INT, dblPayment NUMERIC(18, 6))
DECLARE @intPaymentId			INT
	  , @intPaymentMethodId		INT
	  , @intCurrentInvoiceId	INT 
	  , @strPaymentMethod		NVARCHAR(100) = 'Cash'
	  , @dblTotalAppliedAmount	NUMERIC(18,6) = 0
	  , @dblCurrentPayment		NUMERIC(18, 6)

SELECT @intPaymentMethodId = intPaymentMethodID 
FROM dbo.tblSMPaymentMethod WITH (NOLOCK)
WHERE LOWER(strPaymentMethod) = LOWER(@strPaymentMethod)

--GET PREPAID/CREDIT AMOUNTS
INSERT @tblPrepaids(intPrepaymentId, dblAppliedAmount)
SELECT intPrepaymentId			= intPrepaymentId
	 , dblAppliedInvoiceAmount	= ISNULL(dblAppliedInvoiceDetailAmount, 0)
FROM dbo.tblARPrepaidAndCredit WITH (NOLOCK)
WHERE intInvoiceId = @intInvoiceId 
  AND ysnApplied = 1
  AND ISNULL(dblAppliedInvoiceDetailAmount, 0) > 0

IF NOT EXISTS(SELECT TOP 1 1 FROM @tblPrepaids)
BEGIN
	RETURN 0;
END

--CREATE PAYMENT HEADER
INSERT INTO tblARPayment (
     intEntityCustomerId
   , intCurrencyId
   , intPaymentMethodId
   , intLocationId
   , intBankAccountId
   , intEntityId
   , dtmDatePaid
   , strReceivePaymentType
   , strPaymentMethod
   , dblAmountPaid
   , dblBaseAmountPaid
   , dblUnappliedAmount
   , dblBaseUnappliedAmount
   , dblOverpayment
   , dblBaseOverpayment
   , intCurrencyExchangeRateTypeId
   , dblExchangeRate
   , ysnApplytoBudget
)
SELECT TOP 1 
     intEntityCustomerId	  = I.intEntityCustomerId
   , intCurrencyId			    = I.intCurrencyId
   , intPaymentMethodId		  = @intPaymentMethodId
   , intLocationId			    = I.intCompanyLocationId
   , intBankAccountId				= BA.intBankAccountId
   , intEntityId            = ISNULL(@intUserId, I.intEntityId)
   , dtmDatePaid			      = I.dtmPostDate
   , strReceivePaymentType	= 'Cash Receipts'
   , strPaymentMethod		    = @strPaymentMethod
   , dblAmountPaid			    = 0.00
   , dblBaseAmountPaid		  = 0.00
   , dblUnappliedAmount		  = 0.00
   , dblBaseUnappliedAmount	= 0.00
   , dblOverpayment			    = 0.00
   , dblBaseOverpayment		  = 0.00
   , intCurrencyExchangeRateTypeId = CER.intCurrencyExchangeRateTypeId 
   , dblExchangeRate		    = CER.[dblCurrencyExchangeRate]
   , ysnApplytoBudget		    = 0
FROM dbo.tblARInvoice I WITH (NOLOCK)
INNER JOIN tblSMCompanyLocation CL ON I.intCompanyLocationId = CL.intCompanyLocationId
LEFT JOIN tblCMBankAccount BA ON CL.intCashAccount = BA.intGLAccountId
CROSS APPLY dbo.[fnARGetDefaultForexRate](I.dtmPostDate, I.intCurrencyId, NULL) CER
WHERE intInvoiceId = @intInvoiceId

SET @intPaymentId = SCOPE_IDENTITY()

--GET TOTAL AMOUNT TO APPLY IN INVOICE
SELECT @dblTotalAppliedAmount = SUM(dblAppliedAmount)	 
FROM @tblPrepaids

--INSERT CREDITS TO PAYMENT DETAIL
INSERT INTO @InvoicesDetail(intInvoiceId, dblPayment)
SELECT intInvoiceId = intPrepaymentId
	 , dblPayment	= dblAppliedAmount * -1
FROM @tblPrepaids

--INSERT INVOICE TO PAYMENT DETAIL
INSERT INTO @InvoicesDetail(intInvoiceId, dblPayment)
SELECT intInvoiceId = @intInvoiceId
	 , dblPayment	= @dblTotalAppliedAmount

--INSERT ALL TO PAYMENT DETAIL
WHILE EXISTS (SELECT TOP 1 1 FROM @InvoicesDetail)
BEGIN
	SET @intCurrentInvoiceId	= NULL
	SET @dblCurrentPayment		= 0.00

	SELECT TOP 1 @intCurrentInvoiceId = intInvoiceId
			   , @dblCurrentPayment = dblPayment
	FROM @InvoicesDetail

	EXEC uspARAddInvoiceToPayment @PaymentId		= @intPaymentId
								, @InvoiceId		= @intCurrentInvoiceId
								, @Payment			= @dblCurrentPayment
								, @ApplyTermDiscount = 0
								, @Discount			= 0
								, @RaiseError		= 1

	DELETE FROM @InvoicesDetail WHERE intInvoiceId = @intCurrentInvoiceId
END

EXEC uspARPostPayment @post = 1, @param = @intPaymentId, @userId = @intUserId, @raiseError = 1

RETURN 0