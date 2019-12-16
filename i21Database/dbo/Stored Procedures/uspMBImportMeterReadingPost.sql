CREATE PROCEDURE [dbo].[uspMBImportMeterReadingPost]
	@intImportMeterReadingId INT,
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

		SET @return = 0
		
		DECLARE @intMeterCustomerId AS INT = NULL, 
			@dtmTransactionDate AS DATE = NULL,
			@intUserId INT = NULL,
			@intMeterAccountId INT = NULL

		DECLARE @CursorMeter AS CURSOR

		SET @CursorMeter = CURSOR FOR
		SELECT DISTINCT MRD.intMeterCustomerId
		   ,MRD.dtmTransactionDate
		   ,MR.intUserId
		   ,MAD.intMeterAccountId
		FROM tblMBImportMeterReadingDetail MRD
		INNER JOIN tblMBImportMeterReading MR ON MR.intImportMeterReadingId = MRD.intImportMeterReadingId
		INNER JOIN tblMBMeterAccountDetail MAD ON MAD.strMeterCustomerId = MRD.intMeterCustomerId AND MAD.strMeterFuelingPoint = MRD.intMeterNumber
		WHERE MR.intImportMeterReadingId = @intImportMeterReadingId and ysnValid = 1
		ORDER BY MRD.dtmTransactionDate, intMeterCustomerId

		BEGIN TRANSACTION
		OPEN @CursorMeter
		FETCH NEXT FROM @CursorMeter INTO @intMeterCustomerId, @dtmTransactionDate, @intUserId, @intMeterAccountId
		WHILE @@FETCH_STATUS = 0
		BEGIN

			DECLARE @strTransactionId NVARCHAR(100) = NULL,
				@intMeterReadingId INT = NULL

			-- METER READING DETAIL
			DECLARE @dblCurrentReading AS NUMERIC(18,6) = NULL,
				@dblCurrentAmount AS NUMERIC(18,6) = NULL,
				@dblSalePrice AS NUMERIC(18,6) = NULL,
				@intMeterAccountDetailId INT = NULL,
				@dblLastReading AS NUMERIC(18,6) = NULL,
				@dblLastAmount AS NUMERIC(18,6) = NULL


			DECLARE @CursorMeterDetail AS CURSOR
			SET @CursorMeterDetail = CURSOR FOR
			SELECT MRD.dblCurrentReading
				, MRD.dblCurrentAmount
				, ItemPrice.dblSalePrice
				, MAD.intMeterAccountDetailId
				, MAD.dblLastMeterReading
				, MAD.dblLastTotalSalesDollar
			FROM tblMBImportMeterReadingDetail MRD
			INNER JOIN tblMBImportMeterReading MR ON MR.intImportMeterReadingId = MRD.intImportMeterReadingId
			LEFT JOIN tblMBMeterAccountDetail MAD ON MAD.strMeterCustomerId = MRD.intMeterCustomerId AND MAD.strMeterFuelingPoint = MRD.intMeterNumber
			LEFT JOIN tblMBMeterAccount MA ON MA.intMeterAccountId = MAD.intMeterAccountId
			LEFT JOIN tblICItem Item ON Item.intItemId = MAD.intItemId
			LEFT JOIN tblICItemLocation ItemLocation ON ItemLocation.intItemId = Item.intItemId AND ItemLocation.intLocationId = MA.intCompanyLocationId
			LEFT JOIN tblICItemPricing ItemPrice ON ItemPrice.intItemId = Item.intItemId AND ItemPrice.intItemLocationId = ItemLocation.intItemLocationId
			WHERE MR.intImportMeterReadingId = @intImportMeterReadingId and ysnValid = 1
				AND MRD.intMeterCustomerId = @intMeterCustomerId
				AND MRD.dtmTransactionDate = @dtmTransactionDate
				AND MAD.intMeterAccountDetailId IS NOT NULL
				AND MRD.dblCurrentReading > MAD.dblLastMeterReading 
				AND MAD.intMeterAccountId = @intMeterAccountId
			ORDER BY MAD.intMeterAccountDetailId

			OPEN @CursorMeterDetail
			FETCH NEXT FROM @CursorMeterDetail INTO @dblCurrentReading, @dblCurrentAmount, @dblSalePrice, @intMeterAccountDetailId, @dblLastReading, @dblLastAmount
			WHILE @@FETCH_STATUS = 0
			BEGIN

				IF(@intMeterReadingId IS NULL)
				BEGIN

					-- GET STARTING NUMBER
					EXEC uspSMGetStartingNumber @intStartingNumberId = 95, @strID = @strTransactionId OUTPUT 				

					-- METER READING HEADER
					INSERT INTO [tblMBMeterReading]
						([strTransactionId]
						,[intMeterAccountId]
						,[dtmTransaction]
						,[ysnPosted]
						,[intEntityId]
						,[intConcurrencyId])
					VALUES 
						(@strTransactionId
						,@intMeterAccountId
						,@dtmTransactionDate
						,0
						,@intUserId
						,1)

					SELECT @intMeterReadingId = SCOPE_IDENTITY()

					SET @return = @return + 1
				END
			
				-- CREATE METER READING DETAIL TRANSACTION
				INSERT INTO [dbo].[tblMBMeterReadingDetail]
				   ([intMeterReadingId]
				   ,[intMeterAccountDetailId]
				   ,[dblGrossPrice]
				   ,[dblNetPrice]
				   ,[dblLastReading]
				   ,[dblCurrentReading]
				   ,[dblLastDollars]
				   ,[dblCurrentDollars]
				   ,[intConcurrencyId])
				 VALUES
					(@intMeterReadingId
					,@intMeterAccountDetailId
					,@dblSalePrice
					,@dblSalePrice
					,@dblLastReading
					,@dblCurrentReading
					,@dblLastAmount
					,@dblCurrentAmount
					,0)

				FETCH NEXT FROM @CursorMeterDetail INTO @dblCurrentReading, @dblCurrentAmount, @dblSalePrice, @intMeterAccountDetailId, @dblLastReading, @dblLastAmount
			END
			CLOSE @CursorMeterDetail
			DEALLOCATE @CursorMeterDetail

			FETCH NEXT FROM @CursorMeter INTO @intMeterCustomerId, @dtmTransactionDate, @intUserId, @intMeterAccountId
		END
		CLOSE @CursorMeter
		DEALLOCATE @CursorMeter

		DELETE FROM tblMBImportMeterReading WHERE intImportMeterReadingId = @intImportMeterReadingId 

		COMMIT

	END TRY
	BEGIN CATCH
		ROLLBACK
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