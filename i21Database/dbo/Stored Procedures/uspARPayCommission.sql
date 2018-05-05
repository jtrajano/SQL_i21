CREATE PROCEDURE [dbo].[uspARPayCommission]
	@strCommissionIds		NVARCHAR(MAX),
	@intUserId				INT
AS

SET QUOTED_IDENTIFIER OFF  
SET ANSI_NULLS ON  
SET NOCOUNT ON  
SET XACT_ABORT ON  
SET ANSI_WARNINGS ON  

DECLARE @tblCommissions TABLE (
	  intCommissionId		INT
	, strCommissionNumber	NVARCHAR(25) COLLATE Latin1_General_CI_AS
	, intEntityId			INT
	, ysnPayroll			BIT
	, ysnPayables			BIT
	, dblTotalAmount		NUMERIC(18, 6)
)
DECLARE @intAPClearingAccountId		INT = (SELECT TOP 1 intAPClearingAccountId FROM dbo.tblARCompanyPreference)
DECLARE @intDefaultCurrencyId		INT = (SELECT TOP 1 intDefaultCurrencyId FROM tblSMCompanyPreference)

INSERT INTO @tblCommissions (
	  intCommissionId
	, strCommissionNumber
	, intEntityId
    , ysnPayroll
	, ysnPayables
	, dblTotalAmount
)
SELECT intCommissionId		= COMM.intCommissionId
	 , strCommissionNumber	= COMM.strCommissionNumber
	 , intEntityId			= COMM.intEntityId
	 , ysnPayroll			= COMM.ysnPayroll
	 , ysnPayables			= COMM.ysnPayables
	 , dblTotalAmount		= COMM.dblTotalAmount
FROM dbo.tblARCommission COMM WITH (NOLOCK)
INNER JOIN (
	SELECT intID 
	FROM dbo.fnGetRowsFromDelimitedValues(@strCommissionIds) 
	WHERE ISNULL(intID, 0) <> 0
) PCD ON COMM.intCommissionId = PCD.intID
WHERE COMM.ysnPosted = 1
	AND COMM.ysnPaid = 0
	AND COMM.dblTotalAmount <> 0.00
	AND (COMM.ysnConditional = 0 OR (COMM.ysnConditional = 1 AND COMM.ysnApproved = 1))
	--AND (COMM.ysnPayroll = 1 AND COMM.ysnPayables = 1)

IF ISNULL(@intUserId, 0) = 0
	BEGIN
		RAISERROR('User is required when paying Commissions.', 16, 1)
		RETURN;
	END

IF ISNULL(@intAPClearingAccountId, 0) = 0
	BEGIN
		RAISERROR('AP Clearing Account was not set in Company Configuration.', 16, 1)
		RETURN;
	END

IF ISNULL(@intDefaultCurrencyId, 0) = 0
	BEGIN
		RAISERROR('Default Currency was not set in Company Configuration.', 16, 1)
		RETURN;
	END

IF NOT EXISTS (SELECT TOP 1 NULL FROM @tblCommissions)
	BEGIN
		RAISERROR('There are no valid Commissions to pay!', 16, 1)
		RETURN;
	END
ELSE
	BEGIN
		--CREATE VOUCHER AND PAY VOUCHER
		WHILE EXISTS (SELECT TOP 1 NULL FROM @tblCommissions WHERE ysnPayables = 1)
			BEGIN
				DECLARE @intCommissionPayableId INT = NULL
					  , @intNewBillId			INT = NULL
					  , @intNewPaymentId		INT = NULL
					  , @intVendorId			INT = NULL
					  , @strCommissionNumber	NVARCHAR(25) = ''
					  , @dblTotalAmount			NUMERIC(18, 6) = 0
					  , @ysnSuccess				BIT = 0
					  , @tblVoucherDetail		VoucherDetailNonInventory

				SELECT TOP 1 @intCommissionPayableId = intCommissionId
						   , @intVendorId			 = intEntityId
						   , @strCommissionNumber	 = strCommissionNumber
						   , @dblTotalAmount		 = dblTotalAmount
				FROM @tblCommissions 
				WHERE ysnPayables = 1 ORDER BY intCommissionId ASC

				INSERT INTO @tblVoucherDetail (
					  [intAccountId]
					, [intItemId]
					, [strMiscDescription]
					, [dblQtyReceived]
					, [dblDiscount]
					, [dblCost]
					, [intTaxGroupId]
					, [intInvoiceId]
				)
				SELECT [intAccountId]		= @intAPClearingAccountId
					 , [intItemId]			= NULL
					 , [strMiscDescription] = @strCommissionNumber
					 , [dblQtyReceived]		= 1.00
					 , [dblDiscount]		= 0.00
					 , [dblCost]			= @dblTotalAmount
					 , [intTaxGroupId]		= NULL
					 , [intInvoiceId]		= NULL

				--CREATE VOUCHER
				EXEC dbo.[uspAPCreateBillData] @userId					= @intUserId
											 , @vendorId				= @intVendorId
											 , @type					= 1
											 , @currencyId				= @intDefaultCurrencyId
											 , @vendorOrderNumber		= @strCommissionNumber
											 , @voucherNonInvDetails	= @tblVoucherDetail
											 , @billId					= @intNewBillId OUT
				
				IF ISNULL(@intNewBillId, 0) > 0
					BEGIN
						DECLARE @strNewBillId NVARCHAR(MAX) = CONVERT(NVARCHAR(50), @intNewBillId)

						--POST VOUCHER
						EXEC dbo.[uspAPPostBill] @param		= @strNewBillId
											   , @post		= 1
											   , @recap		= 0
											   , @userId	= @intUserId
											   , @success	= @ysnSuccess OUT

						IF @ysnSuccess = 1
							BEGIN
								--CREATE AND POST PAYMENT
								EXEC [dbo].[uspAPCreatePayment] @userId				= @intUserId
															  , @payment			= @dblTotalAmount
															  , @post				= 1
															  , @billId				= @strNewBillId
															  , @createdPaymentId	= @intNewPaymentId OUT
							END

						UPDATE dbo.tblARCommission
						SET ysnPaid			= 1
						  , intBillId		 = @intNewBillId
						  , intPaymentId	= @intNewPaymentId
						WHERE intCommissionId = @intCommissionPayableId
					END

				DELETE FROM @tblCommissions WHERE intCommissionId = @intCommissionPayableId AND ysnPayables = 1
			END		

		--TODO: CREATE PAYCHECK
		WHILE EXISTS (SELECT TOP 1 NULL FROM @tblCommissions WHERE ysnPayroll = 1)
			BEGIN
				DECLARE @intCommissionPayrollId INT = NULL
					  , @intNewPaygroupId		INT = NULL
					  , @ysnSuccessPayroll		BIT = 0

				SELECT TOP 1 @intCommissionPayrollId = intCommissionId 
				FROM @tblCommissions 
				WHERE ysnPayroll = 1 ORDER BY intCommissionId ASC

				EXEC dbo.uspPRProcessCommissionsToPayGroup @intCommissionId = @intCommissionPayrollId
													     , @intUserId = @intUserId
														 , @isSuccessful = @ysnSuccessPayroll OUT

				IF @ysnSuccessPayroll = 1 --AND @intNewPaygroupId IS NOT NULL
					BEGIN
						UPDATE dbo.tblARCommission
						SET ysnPaid			= 1
						  , intPaycheckId	= @intNewPaygroupId
						WHERE intCommissionId = @intCommissionPayrollId
					END

				DELETE FROM @tblCommissions WHERE intCommissionId = @intCommissionPayrollId AND ysnPayroll = 1
			END				
	END