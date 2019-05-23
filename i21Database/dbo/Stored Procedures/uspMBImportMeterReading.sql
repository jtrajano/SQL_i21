CREATE PROCEDURE [dbo].[uspMBImportMeterReading]
	@guidImportIdentifier UNIQUEIDENTIFIER,
	@return INT OUTPUT
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

BEGIN

	DECLARE @ErrorMessage NVARCHAR(4000)
	DECLARE @ErrorSeverity INT
	DECLARE @ErrorState INT

	BEGIN TRY
		
		DECLARE @intImportMeterReadingId INT,
			@intImportMeterReadingDetailId AS INT = NULL, 
			@intMeterCustomerId AS INT = NULL, 
			@intMeterNumber AS INT = NULL,
			@dtmTransactionDate AS DATE = NULL,
			@dblCurrentReading AS NUMERIC(18,6) = NULL,
			@dblCurrentAmount AS NUMERIC(18,6) = NULL
		
		DECLARE @CursorTran AS CURSOR

		SET @CursorTran = CURSOR FOR
		SELECT MB.intImportMeterReadingId, MBD.intImportMeterReadingDetailId, MBD.intMeterCustomerId, MBD.intMeterNumber, MBD.dtmTransactionDate, MBD.dblCurrentReading, MBD.dblCurrentAmount
		FROM tblMBImportMeterReadingDetail MBD
		INNER JOIN tblMBImportMeterReading MB ON MB.intImportMeterReadingId = MBD.intImportMeterReadingId
		WHERE MB.guidImportIdentifier = @guidImportIdentifier AND MBD.ysnValid = 1 

		BEGIN TRANSACTION

		OPEN @CursorTran
		FETCH NEXT FROM @CursorTran INTO @intImportMeterReadingId, @intImportMeterReadingDetailId, @intMeterCustomerId, @intMeterNumber, @dtmTransactionDate, @dblCurrentReading, @dblCurrentAmount
		WHILE @@FETCH_STATUS = 0
		BEGIN
			
			DECLARE @intMeterAccountId INT = NULL
			-- CHECK IF HAS VALID METER ACCOUNT
			SELECT @intMeterAccountId = MAD.intMeterAccountId FROM tblMBMeterAccountDetail MAD
			INNER JOIN tblMBMeterAccount MA ON MA.intMeterAccountId = MAD.intMeterAccountId
			WHERE MAD.strMeterCustomerId = @intMeterCustomerId AND MAD.strMeterFuelingPoint = @intMeterNumber

			IF (@intMeterAccountId IS NULL)
				UPDATE tblMBImportMeterReadingDetail SET strMessage = 'Invalid Customer Id or Meter Number', ysnValid = 0 WHERE intImportMeterReadingDetailId = @intImportMeterReadingDetailId

			FETCH NEXT FROM @CursorTran INTO @intImportMeterReadingId, @intImportMeterReadingDetailId, @intMeterCustomerId, @intMeterNumber, @dtmTransactionDate, @dblCurrentReading, @dblCurrentAmount
		END
		CLOSE @CursorTran
		DEALLOCATE @CursorTran

		COMMIT TRANSACTION

		SELECT @return = intImportMeterReadingId FROM tblMBImportMeterReading WHERE guidImportIdentifier = @guidImportIdentifier

	END TRY
	BEGIN CATCH
		ROLLBACK TRANSACTION
		SELECT 
			@ErrorMessage = ERROR_MESSAGE(),
			@ErrorSeverity = ERROR_SEVERITY(),
			@ErrorState = ERROR_STATE();

		-- Use RAISERROR inside the CATCH block to return error
		-- information about the original error that caused
		-- execution to jump to the CATCH block.
		RAISERROR (
			@ErrorMessage, -- Message text.
			@ErrorSeverity, -- Severity.
			@ErrorState -- State.
		)
	END CATCH

END


