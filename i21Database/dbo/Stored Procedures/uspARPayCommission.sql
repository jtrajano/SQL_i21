CREATE PROCEDURE [dbo].[uspARPayCommission]
	@strCommissionIds		NVARCHAR(MAX),
	@intCompanyLocationId	INT,
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
DECLARE @intAPAccountId				INT = (SELECT TOP 1 intAPAccount FROM dbo.tblSMCompanyLocation WHERE intCompanyLocationId = @intCompanyLocationId)
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

IF ISNULL(@intCompanyLocationId, 0) = 0
	BEGIN
		RAISERROR('Company Location is required when paying Commissions.', 16, 1)
		RETURN;
	END

IF ISNULL(@intUserId, 0) = 0
	BEGIN
		RAISERROR('User is required when paying Commissions.', 16, 1)
		RETURN;
	END

IF ISNULL(@intAPAccountId, 0) = 0
	BEGIN
		RAISERROR('AP Account was not set in Company Location setup.', 16, 1)
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
		--CREATE PAY VOUCHER
		WHILE EXISTS (SELECT TOP 1 NULL FROM @tblCommissions WHERE ysnPayables = 1)
			BEGIN
				DECLARE @intCommissionPayableId INT = NULL
					  , @intNewPaymentId		INT = NULL
					  , @intVendorId			INT = NULL
					  , @strCommissionNumber	NVARCHAR(25) = ''
					  , @dblTotalAmount			NUMERIC(18, 6) = 0
					  , @dtmDatePaid			DATETIME = GETDATE()
					  , @tblPaymentDetail		PaymentDetailStaging

				SELECT TOP 1 @intCommissionPayableId = intCommissionId
						   , @intVendorId			 = intEntityId
						   , @strCommissionNumber	 = strCommissionNumber
						   , @dblTotalAmount		 = dblTotalAmount
				FROM @tblCommissions 
				WHERE ysnPayables = 1 ORDER BY intCommissionId ASC

				INSERT INTO @tblPaymentDetail (
					  intAccountId
					, dblDiscount
					, dblAmountDue
					, dblPayment
					, dblInterest
					, dblTotal
					, dblWithheld
				)
				SELECT intAccountId	= @intAPAccountId
					, dblDiscount	= 0.00000
					, dblAmountDue	= 0.00000
					, dblPayment	= @dblTotalAmount
					, dblInterest	= 0.00000
					, dblTotal		= @dblTotalAmount
					, dblWithheld	= 0.00000

				--CREATE AND POST PAYMENT
				EXEC [dbo].[uspAPCreatePaymentData] @userId				= @intUserId
												  , @notes				= @strCommissionNumber
												  , @payment			= @dblTotalAmount
												  , @datePaid			= @dtmDatePaid
												  , @paymentDetail		= @tblPaymentDetail
												  , @createdPaymentId	= @intNewPaymentId OUT

				IF ISNULL(@intNewPaymentId, 0) <> 0
					BEGIN
						UPDATE dbo.tblARCommission
						SET ysnPaid			= 1
						  , intPaymentId	= @intNewPaymentId
						WHERE intCommissionId = @intCommissionPayableId
					END				

				DELETE FROM @tblCommissions WHERE intCommissionId = @intCommissionPayableId AND ysnPayables = 1
			END		

		--CREATE PAYCHECK
		WHILE EXISTS (SELECT TOP 1 NULL FROM @tblCommissions WHERE ysnPayroll = 1)
			BEGIN
				DECLARE @intCommissionPayrollId INT = NULL
					  , @ysnSuccessPayroll		BIT = 0

				SELECT TOP 1 @intCommissionPayrollId = intCommissionId 
				FROM @tblCommissions 
				WHERE ysnPayroll = 1 ORDER BY intCommissionId ASC

				EXEC dbo.uspPRProcessCommissionsToPayGroup @intCommissionId = @intCommissionPayrollId
													     , @intUserId = @intUserId
														 , @isSuccessful = @ysnSuccessPayroll OUT

				IF @ysnSuccessPayroll = 1
					BEGIN
						UPDATE dbo.tblARCommission
						SET ysnPaid			= 1
						WHERE intCommissionId = @intCommissionPayrollId
					END

				DELETE FROM @tblCommissions WHERE intCommissionId = @intCommissionPayrollId AND ysnPayroll = 1
			END				
	END