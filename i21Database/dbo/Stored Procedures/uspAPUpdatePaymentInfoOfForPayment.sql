CREATE PROCEDURE [dbo].[uspAPUpdatePaymentInfoOfForPayment]
	@voucherIds NVARCHAR(MAX),
	@paymentInfo NVARCHAR(50) = NULL,
	@newPaymentInfo NVARCHAR(50) OUT
AS

BEGIN

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

BEGIN TRY

	DECLARE @ids AS Id;
	DECLARE @transCount INT = @@TRANCOUNT;
	DECLARE @startNumber INT;
	DECLARE @prefix NVARCHAR(50);

	INSERT INTO @ids
	SELECT [intID] FROM [dbo].fnGetRowsFromDelimitedValues(@voucherIds)

	IF @transCount = 0 BEGIN TRANSACTION

	IF NULLIF(@paymentInfo,'') IS NULL
	BEGIN
		SELECT TOP 1
			@startNumber = payMethod.intNumber
			,@prefix = payMethod.strPrefix
		FROM tblSMPaymentMethod payMethod
		WHERE LOWER(payMethod.strPaymentMethod) = 'echeck'

		SET @paymentInfo = @prefix + '-' + CAST(@startNumber AS NVARCHAR);

		UPDATE payMethod
			SET payMethod.intNumber = payMethod.intNumber + 1
		FROM tblSMPaymentMethod payMethod
		WHERE LOWER(payMethod.strPaymentMethod) = 'echeck'

		SET @newPaymentInfo = @paymentInfo
	END
	ELSE
	BEGIN
		SET @newPaymentInfo = @paymentInfo
	END

	UPDATE A
		SET A.strTempPaymentInfo = @paymentInfo
	FROM tblAPBill A
	INNER JOIN @ids ids ON A.intBillId = ids.intId

	IF @transCount = 0 COMMIT TRANSACTION
	END TRY
	BEGIN CATCH
		DECLARE @ErrorSeverity INT,
				@ErrorNumber   INT,
				@ErrorMessage nvarchar(4000),
				@ErrorState INT,
				@ErrorLine  INT,
				@ErrorProc nvarchar(200);
		-- Grab error information from SQL functions
		SET @ErrorSeverity = ERROR_SEVERITY()
		SET @ErrorNumber   = ERROR_NUMBER()
		SET @ErrorMessage  = ERROR_MESSAGE()
		SET @ErrorState    = ERROR_STATE()
		SET @ErrorLine     = ERROR_LINE()
		IF @transCount = 0 AND XACT_STATE() <> 0 ROLLBACK TRANSACTION
		RAISERROR (@ErrorMessage , @ErrorSeverity, @ErrorState, @ErrorNumber)
	END CATCH
END