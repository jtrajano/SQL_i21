CREATE PROCEDURE [dbo].[uspAPCreateVendorRefund]
	@voucherIds INT,
	@paymentDate DATETIME
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

BEGIN TRY

DECLARE @transCount INT = @@TRANCOUNT;
DECLARE @paymentDetail PaymentIntegrationStagingTable;

IF @transCount = 0 BEGIN TRANSACTION

--INSERT INTO @paymentDetail(
--	[intId]
--	,[strSourceTransaction]
--	,[intSourceId]
--	,[strSourceId]
--	,[intPaymentId]
--	,[intEntityCustomerId]
--	,[intCompanyLocationId]
--	,[intCurrencyId]
--	,[dtmDatePaid]
--	,[intPaymentMethodId]
--	,[strPaymentMethod]
--	,[strPaymentInfo]
--	,[strNotes]
--	,[intAccountId]
--	,[intBankAccountId]
--	,[intWriteOffAccountId]
--	,[dblAmountPaid]
--	,[strPaymentOriginalId]
--	,[ysnUseOriginalIdAsPaymentNumber]
--	,[ysnApplytoBudget]
--	,[ysnApplyOnAccount]
--	,[ysnInvoicePrepayment]
--	,[ysnImportedFromOrigin]
--	,[ysnImportedAsPosted]
--	,[ysnAllowPrepayment]
--	,[ysnPost]
--	,[ysnRecap]
--	,[intEntityId]
--	,[intPaymentDetailId]
--	,[intInvoiceId]
--	,[intBillId]
--	,[strTransactionNumber]
--	,[intTermId]
--	,[ysnApplyTermDiscount]
--	,[dblDiscount]
--	,[dblDiscountAvailable]
--	,[dblInterest]
--	,[dblPayment]
--	,[strInvoiceReportNumber]
--	,[intCurrencyExchangeRateTypeId]
--	,[intCurrencyExchangeRateId]
--	,[dblCurrencyExchangeRate]
--	,[ysnAllowOverpayment]
--)
--SELECT
--	[intId]								=	1
--	,[strSourceTransaction]				=	'Voucher'
--	,[intSourceId]						=	A.intBillId
--	,[strSourceId]						=	A.strBillId
--	,[intPaymentId]						=	NULL
--	,[intEntityCustomerId]				=	A.intEntityVendorId
--	,[intCompanyLocationId]				=	A.intShipToId
--	,[intCurrencyId]					=	A.intCurrencyId
--	,[dtmDatePaid]						=	@paymentDate
--	,[intPaymentMethodId]				=	2
--	,[strPaymentMethod]					=	'ACH'
--	,[strPaymentInfo]					=	NULL
--	,[strNotes]							=	NULL
--	,[intAccountId]						=	
--	,[intBankAccountId]					=	
--	,[intWriteOffAccountId]				=	
--	,[dblAmountPaid]					=	
--	,[strPaymentOriginalId]				=	
--	,[ysnUseOriginalIdAsPaymentNumber]	=	
--	,[ysnApplytoBudget]					=	
--	,[ysnApplyOnAccount]				=	
--	,[ysnInvoicePrepayment]				=	
--	,[ysnImportedFromOrigin]			=	
--	,[ysnImportedAsPosted]				=	
--	,[ysnAllowPrepayment]				=	
--	,[ysnPost]							=	
--	,[ysnRecap]							=	
--	,[intEntityId]						=	
--	,[intPaymentDetailId]				=	
--	,[intInvoiceId]						=	
--	,[intBillId]						=	
--	,[strTransactionNumber]				=	
--	,[intTermId]						=	
--	,[ysnApplyTermDiscount]				=	
--	,[dblDiscount]						=	
--	,[dblDiscountAvailable]				=	
--	,[dblInterest]						=	
--	,[dblPayment]						=	
--	,[strInvoiceReportNumber]			=	
--	,[intCurrencyExchangeRateTypeId]	=	
--	,[intCurrencyExchangeRateId]		=	
--	,[dblCurrencyExchangeRate]			=	
--	,[ysnAllowOverpayment]				=	
--FROM tblAPBill A
--WHERE A.intBillId IN (1)

IF @transCount = 0 COMMIT TRANSACTION
END TRY
BEGIN CATCH

END CATCH