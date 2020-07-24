CREATE PROCEDURE [dbo].[uspSTCStoreSQLSchedulerDaily]
AS
BEGIN
	
	DECLARE @dtmDateNow		DATE = GETDATE()
		  , @ysnSuccess		BIT
	      , @strMessage		NVARCHAR(1000)


	-- ==============================================================================================================================
	-- [START] Retail Price Adjustments
	-- ==============================================================================================================================
	BEGIN
		
		IF EXISTS(SELECT TOP 1 1 FROM tblSTRetailPriceAdjustment WHERE CAST(dtmEffectiveDate AS DATE) = @dtmDateNow)
			BEGIN
				
				-- CREATE
				DECLARE @tempRetailPriceAdjustment TABLE 
				(
					intRetailPriceAdjustmentId INT,
					intModifiedByUserId INT
				)


				-- INSERT
				INSERT INTO @tempRetailPriceAdjustment
				(
					intRetailPriceAdjustmentId,
					intModifiedByUserId
				)
				SELECT DISTINCT
					intRetailPriceAdjustmentId = rpa.intRetailPriceAdjustmentId,
					intModifiedByUserId = rpad.intModifiedByUserId
				FROM tblSTRetailPriceAdjustment rpa 
					INNER JOIN tblSTRetailPriceAdjustmentDetail rpad 
						ON rpa.intRetailPriceAdjustmentId = rpad.intRetailPriceAdjustmentId
				WHERE CAST(rpa.dtmEffectiveDate AS DATE) = @dtmDateNow


				DECLARE @intRetailPriceAdjustmentId		INT 
				DECLARE @intModifiedByUserId		INT 


				WHILE EXISTS(SELECT TOP 1 1 FROM @tempRetailPriceAdjustment)
					BEGIN
						
						---- GET PRIMARY KEY
						SELECT TOP 1 
							@intRetailPriceAdjustmentId = intRetailPriceAdjustmentId,
							@intModifiedByUserId = intModifiedByUserId
						FROM @tempRetailPriceAdjustment

						EXEC [uspSTUpdateRetailPriceAdjustment]
							@intRetailPriceAdjustmentId		= @intRetailPriceAdjustmentId,
							@intCurrentUserId				= @intModifiedByUserId,
							@ysnHasPreviewReport			= 0,
							@ysnRecap						= 0,
							@ysnBatchPost					= 1,
							@ysnSuccess						= @ysnSuccess	OUTPUT,
							@strMessage						= @strMessage	OUTPUT

						--PRINT '@strMessage: ' + @strMessage

						--SELECT '@tempRetailPriceAdjustment', @intRetailPriceAdjustmentId

						DELETE FROM @tempRetailPriceAdjustment
						WHERE intRetailPriceAdjustmentId = @intRetailPriceAdjustmentId
					END

			END

	END
	-- ==============================================================================================================================
	-- [END] Retail Price Adjustments
	-- ==============================================================================================================================


END