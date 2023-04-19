CREATE PROCEDURE [dbo].[uspAPUpdatePaymentInfoOfForPayment]
	@voucherIds NVARCHAR(MAX),
	@paymentInfo NVARCHAR(50) = NULL,
	@userId INT = NULL,
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
	DECLARE @invoiceIds AS Id;
	DECLARE @transCount INT = @@TRANCOUNT;
	DECLARE @startNumber INT;
	DECLARE @prefix NVARCHAR(50);
	DECLARE @partitionNumber INT = 1;

	INSERT INTO @ids
	SELECT [intID] FROM [dbo].fnGetRowsFromDelimitedValues(@voucherIds)

	IF @transCount = 0 BEGIN TRANSACTION

	IF OBJECT_ID('tempdb..#tmpPartitionedVouchers') IS NOT NULL DROP TABLE  #tmpPartitionedVouchers
	SELECT partitioned.*
	INTO #tmpPartitionedVouchers 
	FROM dbo.fnAPPartitonPaymentOfVouchers(@ids, @invoiceIds) partitioned

	SELECT * FROM #tmpPartitionedVouchers 

	WHILE (EXISTS(SELECT TOP 1 1 FROM #tmpPartitionedVouchers WHERE intPartitionId = @partitionNumber))
	BEGIN
		IF NULLIF(@paymentInfo,'') IS NULL
		BEGIN
			SELECT TOP 1 @paymentInfo = B.strTempPaymentInfo
			FROM tblAPBill B
			INNER JOIN #tmpPartitionedVouchers PV ON PV.intBillId = B.intBillId AND PV.intPartitionId = @partitionNumber
			WHERE B.strTempPaymentInfo IS NOT NULL
		END

		IF NULLIF(@paymentInfo,'') IS NULL
		BEGIN
			SELECT TOP 1
				@startNumber = payMethod.intNumber
				,@prefix = payMethod.strPrefix
			FROM tblSMPaymentMethod payMethod
			WHERE LOWER(payMethod.strPaymentMethod) = 'echeck'

			IF(@prefix = '' OR @prefix IS NULL)
			BEGIN 
				SET @paymentInfo = CAST(@startNumber AS NVARCHAR);
			END
			ELSE 
			SET @paymentInfo = @prefix + '-' + CAST(@startNumber AS NVARCHAR);

			UPDATE payMethod
				SET payMethod.intNumber = payMethod.intNumber + 1
			FROM tblSMPaymentMethod payMethod
			WHERE LOWER(payMethod.strPaymentMethod) = 'echeck'

			SET @newPaymentInfo = CASE WHEN @partitionNumber = 1 THEN @paymentInfo ELSE @newPaymentInfo END
		END
		ELSE
		BEGIN
			SET @newPaymentInfo = CASE WHEN @partitionNumber = 1 THEN @paymentInfo ELSE @newPaymentInfo END
		END

		UPDATE B
		SET B.strTempPaymentInfo = @paymentInfo
		FROM tblAPBill B
		INNER JOIN #tmpPartitionedVouchers PV ON PV.intBillId = B.intBillId AND PV.intPartitionId = @partitionNumber
		WHERE B.intSelectedByUserId = @userId

		SET @paymentInfo = ''
		SET @partitionNumber = @partitionNumber + 1
	END

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