CREATE PROCEDURE [dbo].[uspSTCheckoutCommanderFuelTotal]
	@intCheckoutId							INT,
	@UDT_FuelTotal							StagingCommanderFuelTotal		READONLY,
	@ysnSuccess								BIT				OUTPUT,
	@strMessage								NVARCHAR(1000)	OUTPUT,
	@intCountRows							INT				OUTPUT
AS
BEGIN
	BEGIN TRY
		
		DECLARE @intStoreId Int
		Select @intStoreId = intStoreId from dbo.tblSTCheckoutHeader Where intCheckoutId = @intCheckoutId

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