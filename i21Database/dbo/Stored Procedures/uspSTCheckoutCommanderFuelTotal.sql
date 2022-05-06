CREATE PROCEDURE [dbo].[uspSTCheckoutCommanderFuelTotal]
	@intCheckoutId							INT,
	@UDT_FuelTotal							StagingCommanderFuelTotal		READONLY,
	@ysnSuccess								BIT				OUTPUT,
	@strMessage								NVARCHAR(1000)	OUTPUT,
	@intCountRows							INT				OUTPUT
AS
BEGIN
	BEGIN TRY
		
		DECLARE @intStoreId INT
		DECLARE @dtmCheckoutDate DATETIME
		DECLARE @intPreviousCheckoutId INT
		DECLARE @ysnConsStopAutoProcessIfValuesDontMatch BIT
        DECLARE @ysnConsMeterReadingsForDollars BIT

		SELECT	@intStoreId = intStoreId,
				@dtmCheckoutDate = dtmCheckoutDate
		FROM	dbo.tblSTCheckoutHeader 
		WHERE	intCheckoutId = @intCheckoutId

		SELECT	@intPreviousCheckoutId = intCheckoutId
		FROM	dbo.tblSTCheckoutHeader
		WHERE	intStoreId = @intStoreId AND
				dtmCheckoutDate = DATEADD(day, -1, @dtmCheckoutDate)

		SELECT	@ysnConsStopAutoProcessIfValuesDontMatch = ysnConsStopAutoProcessIfValuesDontMatch, 
				@ysnConsMeterReadingsForDollars = ysnConsAddOutsideFuelDiscounts 
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
				INSERT INTO tblSTCheckoutErrorLogs (strErrorType, strErrorMessage , strRegisterTag, strRegisterTagValue, 
													intCheckoutId, intConcurrencyId)
				VALUES('Record', 'Fuel Dispencer Rollover Encountered and Compensated for', '', '', @intCheckoutId, 0)

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

			INSERT INTO dbo.tblSTCheckoutFuelTotalSold(
						 [intCheckoutId]
						 , [intProductNumber]
						 , [dblDollarsSold]
						 , [dblGallonsSold]
						 , [ysnImbalanceAccepted]
						 , [intConcurrencyId])
			SELECT		@intCheckoutId,
						b.intProductNumber ,
						b.sumDblFuelVolume - a.sumDblFuelVolume,
						b.sumDblFuelMoney - a.sumDblFuelMoney,
						0,
						0
			FROM		previous_day_reading a
			INNER JOIN	current_day_reading b
			ON			a.intProductNumber = b.intProductNumber
		END
		ELSE
		BEGIN
			--false
			INSERT INTO tblSTCheckoutErrorLogs (strErrorType, strErrorMessage , strRegisterTag, strRegisterTagValue, 
													intCheckoutId, intConcurrencyId)
			VALUES('Record', 'Missing Dispenser Data', '', '', @intCheckoutId, 0)

			IF @ysnConsStopAutoProcessIfValuesDontMatch = 1
			BEGIN
				--INSERT STOP CONDITION
				INSERT INTO tblSTCheckoutErrorLogs (strErrorType, strErrorMessage , strRegisterTag, strRegisterTagValue, intCheckoutId, intConcurrencyId)
					VALUES('Stop Condition', 'Missing Dispenser Data', '', '', @intCheckoutId, 0)
			END
			ELSE
			BEGIN
				IF @ysnConsMeterReadingsForDollars = 1
				BEGIN
					--INSERT STOP CONDITION
					INSERT INTO tblSTCheckoutErrorLogs (strErrorType, strErrorMessage , strRegisterTag, strRegisterTagValue, intCheckoutId, intConcurrencyId)
					VALUES('Stop Condition', 'Missing Dispenser Data', '', '', @intCheckoutId, 0)
				END
			END
		END
		
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