CREATE PROCEDURE [dbo].[uspARImportPaymentCSV]
	 @ImportLogId			INT
	,@IsRecap				BIT = 0
	,@UserEntityId			INT	= NULL
	,@PaymentFrom			INT = NULL OUTPUT
	,@PaymentTo				INT = NULL OUTPUT	
AS

BEGIN

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET ANSI_WARNINGS ON
	
DECLARE @DateNow			DATETIME
	  , @DefaultCurrencyId	INT
	  , @TotalPayments		INT

SET @DateNow = CAST(GETDATE() AS DATE)
SET @DefaultCurrencyId = (SELECT TOP 1 intDefaultCurrencyId FROM tblSMCompanyPreference)
SET @PaymentFrom = 0
SET @PaymentTo = 0

DECLARE @PaymentsForImport AS TABLE(intImportLogDetailId INT UNIQUE)

INSERT INTO @PaymentsForImport
SELECT intImportLogDetailId FROM tblARImportLogDetail
WHERE intImportLogId = @ImportLogId
	AND ISNULL(ysnSuccess,0) = 1
	AND ISNULL(ysnImported,0) = 0
ORDER BY intImportLogDetailId

SELECT @TotalPayments = COUNT(*) FROM @PaymentsForImport

WHILE EXISTS(SELECT NULL FROM @PaymentsForImport)
	BEGIN
		DECLARE @intImportLogDetailId		INT
			  , @intEntityCustomerId		INT
		      , @intCompanyLocationId		INT
			  , @intUndepositedAccountId	INT
			  , @intBankAccountId			INT
			  , @intPaymentMethodId			INT
			  , @intPaymentId				INT
			  , @dtmDatePaid				DATETIME
			  , @dblAmountPaid				DECIMAL(18, 6)
			  , @strPaymentInfo				NVARCHAR(50)
			  , @ErrorMessage				NVARCHAR(250) = ''	  
			  , @intCurrentPaymentCount     INT
			  		
		SELECT TOP 1 @intImportLogDetailId	= intImportLogDetailId FROM @PaymentsForImport ORDER BY intImportLogDetailId
		SELECT @intCurrentPaymentCount		= COUNT(*) FROM @PaymentsForImport     
		SELECT  @intEntityCustomerId		= (SELECT TOP 1 intEntityId FROM tblEMEntity WHERE strEntityNo = ILD.strCustomerNumber)
			  , @intCompanyLocationId		= (SELECT TOP 1 intCompanyLocationId FROM tblSMCompanyLocation WHERE strLocationName = ILD.strLocationName)
			  , @intUndepositedAccountId	= (SELECT TOP 1 intUndepositedFundsId FROM tblSMCompanyLocation WHERE strLocationName = ILD.strLocationName)
			  , @intBankAccountId			= (SELECT TOP 1 intBankAccountId FROM vyuCMBankAccount WHERE RTRIM(LTRIM(strBankAccountNo)) = RTRIM(LTRIM(ILD.strBankAccountNo)))
			  , @intPaymentMethodId			= (SELECT TOP 1 intPaymentMethodID FROM tblSMPaymentMethod WHERE strPaymentMethod = (CASE WHEN ILD.strPaymentMethod = 'C' THEN 'Check' ELSE NULL END))
			  , @strPaymentInfo				= ILD.strCheckNumber
			  , @dtmDatePaid				= ILD.dtmDatePaid
			  , @dblAmountPaid				= ISNULL(ILD.dblAmountPaid, 0)
		FROM 
			tblARImportLogDetail ILD
		WHERE ILD.intImportLogDetailId = @intImportLogDetailId

		SET @ErrorMessage = ''

		--VALIDATIONS
		IF ISNULL(@intEntityCustomerId, 0) = 0
			SET @ErrorMessage = (SELECT TOP 1 'Failed: Customer ' + strCustomerNumber + ' does not exist. ' FROM tblARImportLogDetail WHERE intImportLogDetailId = @intImportLogDetailId)

		IF ISNULL(@intCompanyLocationId, 0) = 0
			SET @ErrorMessage = ISNULL(@ErrorMessage, '') + (SELECT TOP 1 'Failed: Location ' + strLocationName + ' does not exist. ' FROM tblARImportLogDetail WHERE intImportLogDetailId = @intImportLogDetailId)
		
		IF ISNULL(@intBankAccountId, 0) = 0
			SET @ErrorMessage = ISNULL(@ErrorMessage, '') + (SELECT TOP 1 'Failed: Bank Account # ' + strBankAccountNo + ' does not exist. ' FROM tblARImportLogDetail WHERE intImportLogDetailId = @intImportLogDetailId)

		IF ISNULL(@intPaymentMethodId, 0) = 0
			SET @ErrorMessage = ISNULL(@ErrorMessage, '') + (SELECT TOP 1 'Failed: Payment Method ' + strPaymentMethod + ' does not exist. ' FROM tblARImportLogDetail WHERE intImportLogDetailId = @intImportLogDetailId)

		IF LEN(RTRIM(LTRIM(ISNULL(@ErrorMessage,'')))) < 1 AND @IsRecap = 0
			BEGIN TRY
				EXEC dbo.uspARCreateCustomerPayment
					 @EntityCustomerId		= @intEntityCustomerId
					,@CompanyLocationId		= @intCompanyLocationId
					,@CurrencyId			= @DefaultCurrencyId
					,@DatePaid				= @dtmDatePaid
					,@AccountId				= @intUndepositedAccountId
					,@BankAccountId			= @intBankAccountId
					,@AmountPaid			= @dblAmountPaid
					,@PaymentMethodId		= @intPaymentMethodId
					,@PaymentInfo			= @strPaymentInfo
					,@EntityId				= @UserEntityId	
					,@AllowPrepayment		= 1		
					,@RaiseError			= 1
					,@ErrorMessage			= @ErrorMessage OUT
					,@NewPaymentId			= @intPaymentId OUT
			END TRY	
			BEGIN CATCH
				SET @ErrorMessage = ERROR_MESSAGE();
			END CATCH

		IF LEN(RTRIM(LTRIM(ISNULL(@ErrorMessage,'')))) > 0
			BEGIN
				UPDATE tblARImportLogDetail
				SET ysnImported		= 0
				   ,ysnSuccess      = 0
				   ,strEventResult	= @ErrorMessage
				WHERE [intImportLogDetailId] = @intImportLogDetailId

				UPDATE tblARImportLog 
				SET intSuccessCount	= intSuccessCount - 1
				  , intFailedCount	= intFailedCount + 1
				WHERE intImportLogId  = @ImportLogId
			END
		ELSE IF(ISNULL(@intPaymentId,0) <> 0) AND @IsRecap = 0
			BEGIN
				UPDATE tblARImportLogDetail
				SET ysnImported			= 1
				   ,ysnSuccess			= 1
				   ,strEventResult		= (SELECT 'Payment #:' + strRecordNumber FROM tblARPayment WHERE intPaymentId = @intPaymentId) + ' Imported.'
				WHERE intImportLogDetailId = @intImportLogDetailId

				IF @TotalPayments = @intCurrentPaymentCount
					SET @PaymentFrom = @intPaymentId

				IF @TotalPayments > 1 AND @intCurrentPaymentCount = 1
					SET @PaymentTo = @intPaymentId
			END
		ELSE IF (LEN(RTRIM(LTRIM(ISNULL(@ErrorMessage,'')))) < 1) AND @IsRecap = 1
			BEGIN
				UPDATE tblARImportLogDetail
				SET ysnImported			= 0
				   ,ysnSuccess			= 1
				   ,ysnRecap			= 1
				   ,strEventResult		= 'Success!'
				WHERE intImportLogDetailId = @intImportLogDetailId
			END

		DELETE FROM @PaymentsForImport WHERE intImportLogDetailId = @intImportLogDetailId
	END

IF @IsRecap = 0
	UPDATE tblARImportLog SET ysnRecap = 0

END