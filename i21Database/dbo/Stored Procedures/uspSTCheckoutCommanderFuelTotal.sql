CREATE PROCEDURE [dbo].[uspSTCheckoutCommanderFuelTotal]
	@intCheckoutId							INT,
	@UDT_FuelTotal							StagingCommanderFuelTotal		READONLY,
	@ysnSuccess								BIT				OUTPUT,
	@strMessage								NVARCHAR(1000)	OUTPUT,
	@intCountRows							INT				OUTPUT
AS
BEGIN
	--SET NOCOUNT ON
    SET XACT_ABORT ON
	BEGIN TRY
		
		DECLARE @intStoreId INT
		DECLARE @dtmCheckoutDate DATETIME
		DECLARE @intPreviousCheckoutId INT
		DECLARE @ysnConsStopAutoProcessIfValuesDontMatch BIT
        DECLARE @ysnConsMeterReadingsForDollars BIT
		DECLARE @ysnConsignmentStore BIT

		SELECT	@intStoreId = intStoreId,
				@dtmCheckoutDate = dtmCheckoutDate
		FROM	dbo.tblSTCheckoutHeader 
		WHERE	intCheckoutId = @intCheckoutId

		SELECT	@intPreviousCheckoutId = MAX(intCheckoutId)
		FROM	dbo.tblSTCheckoutHeader
		WHERE	intStoreId = @intStoreId AND
				strCheckoutType = 'Automatic' AND
				dtmCheckoutDate < @dtmCheckoutDate

		SELECT	@ysnConsStopAutoProcessIfValuesDontMatch = ysnConsStopAutoProcessIfValuesDontMatch, 
				@ysnConsMeterReadingsForDollars = ysnConsAddOutsideFuelDiscounts,
				@ysnConsignmentStore = ysnConsignmentStore
		FROM	tblSTStore
		WHERE	intStoreId = @intStoreId

		DECLARE @UDT_FuelTotal2  AS StagingCommanderFuelTotal

		INSERT INTO @UDT_FuelTotal2
		(
			 [intRowCount] 								
			,[intFuelingPositionId]			
			,[intProductNumber]                        
			,[dblFuelVolume]                         
			,[dblFuelMoney]                       
		)
		SELECT 
			[intRowCount] 								
			,[intFuelingPositionId] 			
			,[intProductNumber]                         
			,[dblFuelVolume]                          
			,[dblFuelMoney]     
		FROM 
		@UDT_FuelTotal

		BEGIN TRANSACTION

		-- ==================================================================================================================  
		-- Start Validate if FuelTotal xml file matches the Mapping from i21 
		-- ------------------------------------------------------------------------------------------------------------------
		IF NOT EXISTS(SELECT TOP 1 1 FROM @UDT_FuelTotal2)
			BEGIN
					-- Add to error logging
					INSERT INTO tblSTCheckoutErrorLogs 
					(
						strErrorType
						, strErrorMessage 
						, strRegisterTag
						, strRegisterTagValue
						, intCheckoutId
						, intConcurrencyId
					)
					VALUES
					(
						'XML LAYOUT MAPPING'
						, 'Commander FuelTotal XML file did not match the layout mapping'
						, ''
						, ''
						, @intCheckoutId
						, 1
					)

					SET @intCountRows = 0
					SET @strMessage = 'Commander FuelTotal XML file did not match the layout mapping'
					SET @ysnSuccess = 0

					-- ROLLBACK
					GOTO ExitWithCommit
			END
		-- ------------------------------------------------------------------------------------------------------------------
		-- End Validate if FuelTotal xml file matches the Mapping from i21   
		-- ==================================================================================================================  

		DECLARE @SQL NVARCHAR(MAX) = ''

		IF NOT EXISTS (SELECT '' FROM dbo.tblSTCheckoutFuelTotals Where intCheckoutId = @intCheckoutId)
			BEGIN

				INSERT INTO dbo.tblSTCheckoutFuelTotals(
					 [intCheckoutId]
					 , [intFuelingPositionId]
					 , [intProductNumber]
					 , [dblFuelVolume]
					 , [dblFuelMoney]
					 , [intConcurrencyId]
				)
				 SELECT 
					  [intCheckoutId]			    = @intCheckoutId
					, [intFuelingPositionId]		= Chk.intFuelingPositionId
					, [intProductNumber]		    = Chk.intProductNumber
					, [dblFuelVolume]				= Chk.dblFuelVolume
					, [dblFuelMoney]			    = Chk.dblFuelMoney
					, [intConcurrencyId]			= 0
				 FROM @UDT_FuelTotal2 Chk
			END
		ELSE
			BEGIN

					UPDATE CFT
					SET CFT.[intFuelingPositionId] = Chk.intFuelingPositionId
						, CFT.[intProductNumber] = Chk.intProductNumber
						, CFT.[dblFuelVolume] = Chk.dblFuelVolume
						, CFT.[dblFuelMoney] = Chk.dblFuelMoney
					FROM dbo.tblSTCheckoutFuelTotals CFT
					INNER JOIN @UDT_FuelTotal2 Chk
						ON CFT.intFuelingPositionId = Chk.intFuelingPositionId AND
							CFT.intProductNumber = Chk.intProductNumber
					WHERE CFT.intCheckoutId = @intCheckoutId
			END
		;

		IF OBJECT_ID(N'dbo.tmpCSPreviousDayPumpTotalData') IS NOT NULL 
		BEGIN
			DROP TABLE tmpCSPreviousDayPumpTotalData
		END
		
		IF OBJECT_ID(N'dbo.tmpCSCurrentDayPumpTotalData') IS NOT NULL 
		BEGIN
			DROP TABLE tmpCSCurrentDayPumpTotalData
		END
		
		SELECT * INTO tmpCSPreviousDayPumpTotalData
		FROM tblSTCheckoutFuelTotals 
		WHERE intCheckoutId = @intPreviousCheckoutId
		
		SELECT * INTO tmpCSCurrentDayPumpTotalData
		FROM tblSTCheckoutFuelTotals 
		WHERE intCheckoutId = @intCheckoutId

		--did we receive dispenser readings for all the same dispensers reported on the prior day?
		IF ((SELECT COUNT('') FROM tmpCSPreviousDayPumpTotalData) = 
			(SELECT COUNT('') FROM tmpCSCurrentDayPumpTotalData))
		BEGIN
			--true
			--are any of today's dispenser readings smaller that the prior day's reading?
			IF EXISTS (SELECT		'' 
						FROM		tmpCSPreviousDayPumpTotalData a
						INNER JOIN	tmpCSCurrentDayPumpTotalData b
						ON			a.intFuelingPositionId = b.intFuelingPositionId AND
									a.intProductNumber = b.intProductNumber
						WHERE		a.dblFuelVolume > b.dblFuelVolume OR
									a.dblFuelMoney > b.dblFuelMoney)
			BEGIN
				--true
				INSERT INTO tblSTCheckoutProcessErrorWarning (intCheckoutProcessId, intCheckoutId, strMessageType, strMessage, intConcurrencyId)
				VALUES (dbo.fnSTGetLatestProcessId(@intStoreId), @intCheckoutId, 'W', 'Fuel Dispencer Rollover Encountered and Compensated for', 1)

				--LOGIC OF ADDING 1M TO THE METERS THAT ROLLEDBACK
				--FOR FUEL VOLUME
				UPDATE	tmpCSCurrentDayPumpTotalData
				SET		dblFuelVolume = dblFuelVolume + 1000000
				WHERE	intFuelTotalsId IN (SELECT		b.intFuelTotalsId
											FROM		tmpCSPreviousDayPumpTotalData a
											INNER JOIN	tmpCSCurrentDayPumpTotalData b
											ON			a.intFuelingPositionId = b.intFuelingPositionId AND
														a.intProductNumber = b.intProductNumber
											WHERE		a.dblFuelVolume > b.dblFuelVolume)

				--FOR FUEL MONEY
				UPDATE	tmpCSCurrentDayPumpTotalData
				SET		dblFuelMoney = dblFuelMoney + 1000000
				WHERE	intFuelTotalsId IN (SELECT		b.intFuelTotalsId
											FROM		tmpCSPreviousDayPumpTotalData a
											INNER JOIN	tmpCSCurrentDayPumpTotalData b
											ON			a.intFuelingPositionId = b.intFuelingPositionId AND
														a.intProductNumber = b.intProductNumber
											WHERE		a.dblFuelMoney > b.dblFuelMoney)

			END;

			WITH previous_day_reading (intProductNumber, sumDblFuelVolume, sumDblFuelMoney)  
			AS  
			(  
			    SELECT intProductNumber, SUM(dblFuelVolume), SUM(dblFuelMoney) FROM tmpCSPreviousDayPumpTotalData
				WHERE intCheckoutId = @intPreviousCheckoutId
				GROUP BY intProductNumber
			)  
			,
			current_day_reading (intProductNumber, sumDblFuelVolume, sumDblFuelMoney)  
			AS  
			(  
			    SELECT intProductNumber, SUM(dblFuelVolume), SUM(dblFuelMoney) FROM tmpCSCurrentDayPumpTotalData
				WHERE intCheckoutId = @intCheckoutId
				GROUP BY intProductNumber
			)

			--use tblSTCheckoutFuelTotalSold as temp table
			INSERT INTO dbo.tblSTCheckoutFuelTotalSold(
						 [intCheckoutId]
						 , [intProductNumber]
						 , [dblDollarsSold]
						 , [dblGallonsSold]
						 , [intConcurrencyId])
			SELECT		@intCheckoutId,
						b.intProductNumber ,
						ISNULL(b.sumDblFuelMoney, 0) - ISNULL(a.sumDblFuelMoney, 0),
						ISNULL(b.sumDblFuelVolume, 0) - ISNULL(a.sumDblFuelVolume, 0),
						0
			FROM		current_day_reading b
			LEFT JOIN	previous_day_reading a
			ON			a.intProductNumber = b.intProductNumber

			IF NOT EXISTS (SELECT '' FROM dbo.tblSTCheckoutPumpTotals Where intCheckoutId = @intCheckoutId)
			BEGIN
				INSERT INTO dbo.tblSTCheckoutPumpTotals(
					 [intCheckoutId]
					 , [intPumpCardCouponId]
					 , [intCategoryId]
					 , [strDescription]
					 , [dblPrice]
					 , [dblQuantity]
					 , [dblAmount]
					 , [intConcurrencyId]
				)
				 SELECT 
					  [intCheckoutId]			    = @intCheckoutId
					, [intPumpCardCouponId]			= UOM.intItemUOMId
					, [intCategoryId]			    = I.intCategoryId
					, [strDescription]				= I.strDescription
					, [dblPrice]					= CASE WHEN ISNULL(CAST(Chk.dblGallonsSold as decimal(18,6)),1) = 0
														THEN 0
														ELSE
														CAST((ISNULL(CAST(Chk.dblDollarsSold as decimal(18,6)),0) / ISNULL(CAST(Chk.dblGallonsSold as decimal(18,6)),1)) AS DECIMAL(18,6))
														END
					, [dblQuantity]					= ISNULL(CAST(Chk.dblGallonsSold as decimal(18,6)), 0)
					, [dblAmount]					= ISNULL(CAST(Chk.dblDollarsSold as decimal(18,6)),0) --just based the readings on the meter readings
					, [intConcurrencyId]			= 0
				 FROM tblSTCheckoutFuelTotalSold Chk
				 JOIN dbo.tblSTPumpItem SPI 
					ON ISNULL(CAST(Chk.intProductNumber as NVARCHAR(10)), '') COLLATE Latin1_General_CI_AS IN (ISNULL(SPI.strRegisterFuelId1, ''), ISNULL(SPI.strRegisterFuelId2, '')) AND Chk.intCheckoutId = @intCheckoutId
				 JOIN dbo.tblICItemUOM UOM 
					ON UOM.intItemUOMId = SPI.intItemUOMId
				 JOIN dbo.tblICItem I 
					ON I.intItemId = UOM.intItemId
				 JOIN dbo.tblSTStore S 
					ON S.intStoreId = SPI.intStoreId
				 WHERE S.intStoreId = @intStoreId
			END
			ELSE
			BEGIN
				UPDATE CPT
					SET CPT.[dblPrice] = CASE WHEN NULLIF(CAST(Chk.dblGallonsSold AS DECIMAL(18,6)),0) = 0
											THEN 0
											ELSE
											ISNULL(NULLIF(CAST(Chk.dblDollarsSold AS DECIMAL(18,6)), 0) / NULLIF(CAST(Chk.dblGallonsSold AS DECIMAL(18,6)),0),0)
											END
						, CPT.[dblQuantity] = CAST(ISNULL(Chk.dblGallonsSold, 0) AS DECIMAL(18,6))
						, CPT.[dblAmount] = CAST(ISNULL(Chk.dblDollarsSold, 0) AS DECIMAL(18,6)) --just based the readings on the meter readings
					FROM dbo.tblSTCheckoutPumpTotals CPT
					INNER JOIN tblSTCheckoutHeader CH
						ON CPT.intCheckoutId = CH.intCheckoutId
					INNER JOIN tblSTStore ST
						ON CH.intStoreId = ST.intStoreId
					INNER JOIN tblICItemUOM UOM
						ON CPT.intPumpCardCouponId = UOM.intItemUOMId
					INNER JOIN tblICItem Item
						ON UOM.intItemId = Item.intItemId
					INNER JOIN dbo.tblSTPumpItem SPI 
						ON ST.intStoreId = SPI.intStoreId AND
						UOM.intItemUOMId = SPI.intItemUOMId
					INNER JOIN tblSTCheckoutFuelTotalSold Chk
						ON ISNULL(CAST(Chk.intProductNumber AS NVARCHAR(10)), '') COLLATE Latin1_General_CI_AS IN (ISNULL(SPI.strRegisterFuelId1, ''), ISNULL(SPI.strRegisterFuelId2, ''))
						AND Chk.intCheckoutId = @intCheckoutId
					WHERE CPT.intCheckoutId = @intCheckoutId
			END

			UPDATE		tblSTCheckoutHeader
			SET			dblEditableAggregateMeterReadingsForDollars = (	SELECT		ISNULL(SUM(dblDollarsSold),0)
																		FROM		tblSTCheckoutFuelTotalSold 
																		WHERE		intCheckoutId = @intCheckoutId)
			WHERE intCheckoutId = @intCheckoutId

			IF (@ysnConsignmentStore = 1)
			BEGIN
				INSERT INTO tblSTCheckoutDealerCommission (intCheckoutId, dblCommissionAmount, intConcurrencyId)
				SELECT		@intCheckoutId,
							SUM(dblGallonsSold) * (SELECT dblConsCommissionRawMarkup FROM tblSTStore WHERE intStoreId = @intStoreId),
							1
				FROM		tblSTCheckoutFuelTotalSold a
			END
		END
		ELSE
		BEGIN
			--false
			INSERT INTO tblSTCheckoutProcessErrorWarning (intCheckoutProcessId, intCheckoutId, strMessageType, strMessage, intConcurrencyId)
			VALUES (dbo.fnSTGetLatestProcessId(@intStoreId), @intCheckoutId, 'S', 'Missing Dispenser Data', 1)
		END

		--CS-105 - First Day Setup for a Consignment Store does not show any values for Summary Totals or Aggregate Meter Readings by Fuel Grade
		IF ((SELECT COUNT('') FROM tblSTCheckoutHeader WHERE intStoreId = @intStoreId AND strCheckoutType = 'Automatic') = 1)
		BEGIN
			DECLARE @ysnFromEdit BIT
			SET @ysnFromEdit = 0

			EXEC uspSTCheckoutUpdatePumpTotals @intCheckoutId, @ysnFromEdit, @ysnSuccess OUT, @strMessage OUT

			UPDATE		tblSTCheckoutHeader
			SET			dblEditableAggregateMeterReadingsForDollars = (	SELECT		ISNULL(SUM(dblAmount),0)
																		FROM		tblSTCheckoutPumpTotals 
																		WHERE		intCheckoutId = @intCheckoutId)
			WHERE intCheckoutId = @intCheckoutId
		END

		--delete stored temp data in tblSTCheckoutFuelTotalSold
		DELETE tblSTCheckoutFuelTotalSold WHERE intCheckoutId = @intCheckoutId
		
		SET @intCountRows = 1
		SET @strMessage = 'Success'
		SET @ysnSuccess = 1

		-- COMMIT
		GOTO ExitWithCommit
	END TRY

	BEGIN CATCH
		SET @intCountRows = 0
		SET @strMessage = ERROR_MESSAGE()
		SET @ysnSuccess = 0

		-- ROLLBACK
		GOTO ExitWithRollback
	END CATCH
END


ExitWithCommit:
	-- Commit Transaction
	COMMIT TRANSACTION --@TransactionName
	GOTO ExitPost
	

ExitWithRollback:
    -- Rollback Transaction here
	IF @@TRANCOUNT > 0
		BEGIN
			ROLLBACK TRANSACTION --@TransactionName
		END
		
ExitPost: