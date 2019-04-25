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
		
		DECLARE @intMeterCustomerId AS INT = NULL, 
			@intMeterNumber AS INT = NULL,
			@dtmTransactionDate AS DATE = NULL,
			@intUserId INT = NULL

		DECLARE @CursorMeter AS CURSOR

		SET @CursorMeter = CURSOR FOR
		SELECT DISTINCT MRD.intMeterCustomerId
		   ,MRD.intMeterNumber
		   ,MRD.dtmTransactionDate
		   ,MR.intUserId
		FROM tblMBImportMeterReadingDetail MRD
		INNER JOIN tblMBImportMeterReading MR ON MR.intImportMeterReadingId = MRD.intImportMeterReadingId
		WHERE MR.intImportMeterReadingId = @intImportMeterReadingId and ysnValid = 1
		ORDER BY MRD.dtmTransactionDate

		BEGIN TRANSACTION
		OPEN @CursorMeter
		FETCH NEXT FROM @CursorMeter INTO @intMeterCustomerId, @intMeterNumber, @dtmTransactionDate, @intUserId
		WHILE @@FETCH_STATUS = 0
		BEGIN
			
			SET @return = @intImportMeterReadingId

			DECLARE @intMeterAccountId INT = NULL, 
				@intMeterAccountDetailId INT = NULL,
				@strTransactionId NVARCHAR(100) = NULL,
				@intMeterReadingId INT = NULL

			IF((SELECT COUNT(intMeterAccountDetailId) FROM tblMBMeterAccountDetail MAD INNER JOIN tblMBMeterAccount MA ON MA.intMeterAccountId = MAD.intMeterAccountId) > 1)
			BEGIN		
				DECLARE @Msg NVARCHAR(MAX) = 'Invalid setup on meter account with meter customer id ' + CONVERT(NVARCHAR(20),@intMeterCustomerId) + ' and meter number ' + CONVERT(NVARCHAR(20),@intMeterNumber) 
				RAISERROR(@Msg, 2 ,16,1)
			END

			-- GET METER ACCOUNT
			SELECT @intMeterAccountId = MAD.intMeterAccountId, @intMeterAccountDetailId = MAD.intMeterAccountDetailId FROM tblMBMeterAccountDetail MAD
			INNER JOIN tblMBMeterAccount MA ON MA.intMeterAccountId = MAD.intMeterAccountId
			WHERE MAD.strMeterCustomerId = @intMeterCustomerId AND MAD.strMeterFuelingPoint = @intMeterNumber

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

			-- METER READING DETAIL
			DECLARE @dblCurrentReading AS NUMERIC(18,6) = NULL,
				@dblCurrentAmount AS NUMERIC(18,6) = NULL,
				@dblSalePrice AS NUMERIC(18,6) = NULL

			DECLARE @CursorMeterDetail AS CURSOR
			SET @CursorMeterDetail = CURSOR FOR
			SELECT MRD.dblCurrentReading
				, MRD.dblCurrentAmount
				, ItemPrice.dblSalePrice
			FROM tblMBImportMeterReadingDetail MRD
			INNER JOIN tblMBImportMeterReading MR ON MR.intImportMeterReadingId = MRD.intImportMeterReadingId
			LEFT JOIN tblMBMeterAccountDetail MAD ON MAD.strMeterCustomerId = MRD.intMeterCustomerId AND MAD.strMeterFuelingPoint = MRD.intMeterNumber
			LEFT JOIN tblMBMeterAccount MA ON MA.intMeterAccountId = MAD.intMeterAccountId
			LEFT JOIN tblICItem Item ON Item.intItemId = MAD.intItemId
			LEFT JOIN tblICItemLocation ItemLocation ON ItemLocation.intItemId = Item.intItemId AND ItemLocation.intLocationId = MA.intCompanyLocationId
			LEFT JOIN tblICItemPricing ItemPrice ON ItemPrice.intItemId = Item.intItemId AND ItemPrice.intItemLocationId = ItemLocation.intItemLocationId
			WHERE MR.intImportMeterReadingId = @intImportMeterReadingId and ysnValid = 1
				AND MRD.intMeterCustomerId = @intMeterCustomerId
				AND MRD.intMeterNumber = @intMeterNumber
				AND MRD.dtmTransactionDate = @dtmTransactionDate
			ORDER BY MRD.dtmTransactionDate, MRD.dblCurrentReading

			OPEN @CursorMeterDetail
			FETCH NEXT FROM @CursorMeterDetail INTO @dblCurrentReading, @dblCurrentAmount, @dblSalePrice
			WHILE @@FETCH_STATUS = 0
			BEGIN
				
				DECLARE @dblLastReading AS NUMERIC(18,6) = NULL,
					@dblLastAmount AS NUMERIC(18,6) = NULL

				-- GET METER READING ACCOUNT DETAILS
				SELECT @dblLastReading = dblLastMeterReading, @dblLastAmount = dblLastTotalSalesDollar FROM tblMBMeterAccountDetail MAD WHERE MAD.intMeterAccountDetailId = @intMeterAccountDetailId
				
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

				-- UPDATE METER READING ACCOUNT DETAILS
				UPDATE tblMBMeterAccountDetail SET dblLastMeterReading = @dblCurrentReading, dblLastTotalSalesDollar = @dblCurrentAmount WHERE intMeterAccountDetailId = @intMeterAccountDetailId

				FETCH NEXT FROM @CursorMeterDetail INTO @dblCurrentReading, @dblCurrentAmount, @dblSalePrice
			END
			CLOSE @CursorMeterDetail
			DEALLOCATE @CursorMeterDetail

			FETCH NEXT FROM @CursorMeter INTO @intMeterCustomerId, @intMeterNumber, @dtmTransactionDate, @intUserId
		END
		CLOSE @CursorMeter
		DEALLOCATE @CursorMeter

		DELETE FROM tblMBImportMeterReading WHERE intImportMeterReadingId = @intImportMeterReadingId 

		COMMIT

		SET @return = @intImportMeterReadingId

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