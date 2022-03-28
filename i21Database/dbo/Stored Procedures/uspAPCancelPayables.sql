CREATE PROCEDURE [dbo].[uspAPCancelPayables]
	@payableIds NVARCHAR(4000),
	@userId AS INT,
	@billsCreated NVARCHAR(4000) OUTPUT
AS

BEGIN  
	SET QUOTED_IDENTIFIER OFF  
	SET ANSI_NULLS ON  
	SET NOCOUNT ON  
	SET ANSI_WARNINGS OFF  
	
	BEGIN TRY
		DECLARE @transCount INT = @@TRANCOUNT; 
		IF @transCount = 0 BEGIN TRANSACTION;

		IF NULLIF(@payableIds, '') IS NULL
		BEGIN
			RAISERROR('No payable/s to cancel.', 16, 1);
			RETURN;
		END

		DECLARE @payableId Id
		INSERT INTO @payableId
		SELECT intID FROM dbo.fnGetRowsFromDelimitedValues(@payableIds)
		DECLARE @cancelledPayable Id

		IF EXISTS(SELECT TOP 1 1 FROM tblAPVoucherPayable VP INNER JOIN @payableId P ON P.intId = VP.intVoucherPayableId WHERE dblQuantityToBill < 0)
		BEGIN
			RAISERROR('Cancelling negative quantity to bill is not supported.', 16, 1);
			RETURN;
		END

		DECLARE @postingResult BIT;
		DECLARE @postingBatchId NVARCHAR(1000);
		DECLARE @postingError NVARCHAR(1000);

		WHILE EXISTS(SELECT TOP 1 1 FROM @payableId)
		BEGIN
			DECLARE @stringId NVARCHAR(10);
			DECLARE @createdBillId INT;
			DECLARE @createdDebitMemoId INT;
			DECLARE @debitMemoId Id;

			--GET FIRST PAYABLE
			DECLARE @voucherPayableId INT
			SELECT TOP 1 @voucherPayableId = intId FROM @payableId

			--CREATE VOUCHER
			EXEC uspAPCreateVoucherForPendingPayable @payableId = @voucherPayableId, @userId = @userId, @billCreated = @stringId OUT
			SELECT TOP 1 @createdBillId = intID FROM dbo.fnGetRowsFromDelimitedValues(@stringId)
			UPDATE tblAPBill SET strVendorOrderNumber = strBillId WHERE intBillId = @createdBillId

			--CREATE DEBIT MEMO
			EXEC uspAPDuplicateBill @billId = @createdBillId, @userId = @userId, @reset = 0, @type = 3, @billCreatedId = @createdDebitMemoId OUT
			INSERT INTO @debitMemoId VALUES(@createdDebitMemoId)

			--POST DEBIT MEMO
			EXEC uspAPPostBill @post = 1, @recap = 0, @isBatch = 0, @param = @createdDebitMemoId, @userId = @userId, @success = @postingResult OUT, @batchIdUsed = @postingBatchId OUT
			-- IF @postingResult = 0
			-- BEGIN
			-- 	SELECT TOP 1 @postingError = strMessage FROM tblAPPostResult WHERE strBatchNumber = @postingBatchId
			-- 	RAISERROR(@postingError, 16, 1);
			-- END
			
			IF  @postingResult = 1
			BEGIN
				--APPLY DEBIT MEMO
				EXEC uspAPApplyPrepaid @billId = @createdBillId, @prepaidIds = @debitMemoId	

				--POST VOUCHER
				EXEC uspAPPostBill @post = 1, @recap = 0, @isBatch = 0, @param = @createdBillId, @userId = @userId, @success = @postingResult OUT, @batchIdUsed = @postingBatchId OUT
				-- IF @postingResult = 0
				-- BEGIN
				-- 	SELECT TOP 1 @postingError = strMessage FROM tblAPPostResult WHERE strBatchNumber = @postingBatchId
				-- 	RAISERROR(@postingError, 16, 1);
				-- END
			END

			--RECORD THE CANCELLED PAYABLE
			INSERT INTO @cancelledPayable VALUES(@createdBillId)

			--DELETE FIRST PAYABLE
			DELETE FROM @payableId WHERE intId = @voucherPayableId
		END

		SELECT @billsCreated = COALESCE(@billsCreated + '|^|', '') + CONVERT(NVARCHAR(10), intId) FROM @cancelledPayable ORDER BY intId
		IF @transCount = 0 COMMIT TRANSACTION;
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
		SET @ErrorProc     = ERROR_PROCEDURE()  

		-- SET @ErrorMessage  = 'Error creating voucher.' + CHAR(13) +   
		-- 'SQL Server Error Message is: ' + CAST(@ErrorNumber AS VARCHAR(10)) +   
		-- ' in procedure: ' + @ErrorProc + ' Line: ' + CAST(@ErrorLine AS VARCHAR(10)) + ' Error text: ' + @ErrorMessage  

		IF (XACT_STATE()) = -1  
		BEGIN  
			ROLLBACK TRANSACTION  
		END  
		ELSE IF (XACT_STATE()) = 1 AND @transCount = 0  
		BEGIN  
			ROLLBACK TRANSACTION  
		END  

		RAISERROR (@ErrorMessage , @ErrorSeverity, @ErrorState, @ErrorNumber)  
	END CATCH 
	
	RETURN 0  
END 