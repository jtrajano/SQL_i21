CREATE PROCEDURE [dbo].[uspSTCopyPriceItemPricing]
	@intItemId							INT		
	, @intPrimaryId						INT	
	, @strType							NVARCHAR(10)
	, @strCopyToItemLocationIdList		NVARCHAR(MAX)
	, @intEntityId						INT
	, @ysnDebug							BIT
	, @ysnResultSuccess					BIT				OUTPUT
	, @strResultMessage					NVARCHAR(1000)	OUTPUT
AS
BEGIN
	
	SET ANSI_WARNINGS OFF;
	SET NOCOUNT ON;

    DECLARE @InitTranCount INT;
    SET @InitTranCount = @@TRANCOUNT

	DECLARE @Savepoint NVARCHAR(32) = SUBSTRING(('uspSTCopyPriceItemPricing' + CONVERT(VARCHAR, @InitTranCount)), 1, 32)

	BEGIN TRY
		
		BEGIN TRANSACTION 
		


		SET @ysnResultSuccess = CAST(1 AS BIT)
		SET @strResultMessage = ''

		--@strType = P/R
		--@strType = P - Promotional Pricing
		--@strType = R - Regular with Effective Date Pricing

		
		-- [TO] Create temp tablefrom
		BEGIN
			DECLARE @tblItemPricing_TO TABLE (
				intItemId_TO				INT
				, intItemLocationIdId_TO	INT
				, dblStandardCost_TO		NUMERIC(38,20)
			);
		END

		IF @strType = 'R'
		BEGIN

			DECLARE @dtmEffectiveDate DATETIME = (SELECT TOP 1 dtmEffectiveRetailPriceDate FROM tblICEffectiveItemPrice WHERE intEffectiveItemPriceId = @intPrimaryId)
			DECLARE @intUnitMeasureId INT = (SELECT TOP 1 intUnitMeasureId 
												FROM tblICEffectiveItemPrice eip
													JOIN tblICItemUOM uom
														ON eip.intItemUOMId = uom.intItemUOMId
												WHERE intEffectiveItemPriceId = @intPrimaryId)

			-- ITEM PRICING AuditLog temp table
			BEGIN
				IF OBJECT_ID('tempdb..#tmpUpdateItemPricingForCStore_ItemPricingAuditLog') IS NULL  
					CREATE TABLE #tmpUpdateItemPricingForCStore_ItemPricingAuditLog (
						intItemId INT
						,intItemPricingId INT 
						,dblOldStandardCost NUMERIC(38, 20) NULL
						,dblOldSalePrice NUMERIC(38, 20) NULL
						,dblOldLastCost NUMERIC(38, 20) NULL
						,dblNewStandardCost NUMERIC(38, 20) NULL
						,dblNewSalePrice NUMERIC(38, 20) NULL
						,dblNewLastCost NUMERIC(38, 20) NULL
					);
			END 
		
			BEGIN
				-- Create the temp table 
				IF OBJECT_ID('tempdb..#tmpUpdateItemPricingForCStore_Location') IS NULL  
					CREATE TABLE #tmpUpdateItemPricingForCStore_Location (
						intLocationId INT 
					)
			END

		
			IF(@strCopyToItemLocationIdList IS NOT NULL AND @strCopyToItemLocationIdList != '')
				BEGIN
					INSERT INTO #tmpUpdateItemPricingForCStore_Location (
						intLocationId
					)
					SELECT [intID] FROM [dbo].[fnGetRowsFromDelimitedValues](@strCopyToItemLocationIdList)
				END
		

			DECLARE @dblRetailPrice_FROM NUMERIC(38,20)

			-- INSERT [FROM]
			SET @dblRetailPrice_FROM = (SELECT TOP 1 dblRetailPrice FROM tblICEffectiveItemPrice WHERE intEffectiveItemPriceId = @intPrimaryId)


			-- ===============================================
			-- [START] - PREVIEW IF DEBUG (Temp Table FROM)
			-- ===============================================
			BEGIN
				IF(@ysnDebug = 1)
					BEGIN
						SELECT 'Item Pricing Copy From' + @dblRetailPrice_FROM
					END
			END
			-- ===============================================
			-- [END] - PREVIEW IF DEBUG (Temp Table FROM)
			-- ===============================================


			-- INSERT [TO]
			INSERT INTO @tblItemPricing_TO
			(
				intItemId_TO
				, intItemLocationIdId_TO
			)
			SELECT
				intItemId_TO				= i.intItemId
				, intItemLocationId_TO		= il.intItemLocationId
			FROM tblICItem i
			JOIN tblICItemLocation il
				ON i.intItemId = il.intItemId 
			WHERE il.intLocationId IN (SELECT [intID] FROM [dbo].[fnGetRowsFromDelimitedValues](@strCopyToItemLocationIdList))
				AND i.intItemId = @intItemId

			-- ===============================================
			-- [START] - PREVIEW IF DEBUG (Temp Table TO)
			-- ===============================================
			BEGIN
				IF(@ysnDebug = 1)
					BEGIN
						SELECT 'Item Pricing Copy To', * FROM @tblItemPricing_TO
					END
			END
			-- ===============================================
			-- [END] - PREVIEW IF DEBUG (Temp Table TO)
			-- ===============================================




			IF EXISTS(SELECT TOP 1 1 FROM tblICEffectiveItemPrice WHERE dblRetailPrice = @dblRetailPrice_FROM)
				BEGIN
				
					IF EXISTS(SELECT TOP 1 1 FROM @tblItemPricing_TO)
						BEGIN
						
							DECLARE @intLoopItemLocationId_TO	AS INT
								  , @intLoopItemId_TO			AS INT




							WHILE EXISTS(SELECT TOP 1 1 FROM @tblItemPricing_TO)
								BEGIN
								
									SELECT TOP 1
											@intLoopItemLocationId_TO	= temp.intItemLocationIdId_TO
											, @intLoopItemId_TO			= temp.intItemId_TO
									FROM @tblItemPricing_TO temp




									BEGIN TRY
										EXEC [uspICUpdateEffectivePricingForCStore]
											-- filter params
											@intItemId					= @intLoopItemId_TO 
											, @intItemLocationId		= @intLoopItemLocationId_TO 
											, @dtmEffectiveDate			= @dtmEffectiveDate
											, @intUOM					= @intUnitMeasureId

											-- update params
											, @dblRetailPrice			= @dblRetailPrice_FROM 
											, @intEntityUserSecurityId	= @intEntityId
									END TRY
									BEGIN CATCH
										SET @ysnResultSuccess = 0
										SET @strResultMessage = 'Error updating Item Pricing: ' + ERROR_MESSAGE()  

										GOTO ExitWithRollback
									END CATCH



									-- Remove
									DELETE FROM @tblItemPricing_TO WHERE intItemLocationIdId_TO = @intLoopItemLocationId_TO AND intItemId_TO = @intLoopItemId_TO
								END

						END
					ELSE
						BEGIN
							SET @ysnResultSuccess = CAST(0 AS BIT)
							SET @strResultMessage = 'There are no records to copy to.'

							GOTO ExitWithRollback
						END

				END
			ELSE
				BEGIN

					SET @ysnResultSuccess = CAST(0 AS BIT)
					SET @strResultMessage = 'There are no records to copy from.'

					GOTO ExitWithRollback

				END
			END
			
		IF @strType = 'P'
		BEGIN

			-- ITEM PRICING AuditLog temp table
			BEGIN
				-- Create the temp table for the audit log. 
				IF OBJECT_ID('tempdb..#tmpUpdateItemPricingForCStore_ItemSpecialPricingAuditLog') IS NULL  
					CREATE TABLE #tmpUpdateItemPricingForCStore_ItemSpecialPricingAuditLog (
						intItemId INT 
						,intItemSpecialPricingId INT 
						,dblOldUnitAfterDiscount NUMERIC(38, 20) NULL 
						,dblOldCost NUMERIC(38, 20) NULL 
						,dtmOldBeginDate DATETIME NULL 
						,dtmOldEndDate DATETIME NULL 
						,dblNewUnitAfterDiscount NUMERIC(38, 20) NULL 
						,dblNewCost NUMERIC(38, 20) NULL 
						,dtmNewBeginDate DATETIME NULL
						,dtmNewEndDate DATETIME NULL 		
					)
				;
			END 
		
			DECLARE  @tblLocationIds TABLE (
				intLocationId INT 
			)

		
			IF(@strCopyToItemLocationIdList IS NOT NULL AND @strCopyToItemLocationIdList != '')
				BEGIN
					INSERT INTO @tblLocationIds (
						intLocationId
					)
					SELECT [intID] FROM [dbo].[fnGetRowsFromDelimitedValues](@strCopyToItemLocationIdList)
				END

			-- [TO] Create temp tablefrom
			BEGIN
				DECLARE @tblItemPromotionPricing_TO TABLE (
					intItemId_TO				INT
					, intItemLocationIdId_TO	INT
				);
			END

			-- INSERT [FROM]
			DECLARE @intSpecialPricingId AS INT = @intPrimaryId


			-- INSERT [TO]
			INSERT INTO @tblItemPricing_TO
			(
				intItemId_TO
				, intItemLocationIdId_TO
			)
			SELECT
				intItemId_TO				= i.intItemId
				, intItemLocationId_TO		= il.intItemLocationId
			FROM tblICItem i
			JOIN tblICItemLocation il
				ON i.intItemId = il.intItemId 
			WHERE il.intLocationId IN (SELECT [intID] FROM [dbo].[fnGetRowsFromDelimitedValues](@strCopyToItemLocationIdList))
				AND i.intItemId = @intItemId


			IF EXISTS(SELECT TOP 1 1 FROM tblICItemSpecialPricing WHERE intItemSpecialPricingId = @intSpecialPricingId)
				BEGIN
				
					IF EXISTS(SELECT TOP 1 1 FROM @tblItemPricing_TO)
						BEGIN
						
							DECLARE @intLoopSpecialItemLocationId_TO	AS INT
								  , @intLoopSpecialItemId_TO			AS INT

							WHILE EXISTS(SELECT TOP 1 1 FROM @tblItemPricing_TO)
								BEGIN
								
									SELECT TOP 1
											@intLoopItemLocationId_TO	= temp.intItemLocationIdId_TO
											, @intLoopItemId_TO			= temp.intItemId_TO
									FROM @tblItemPricing_TO temp



									
									BEGIN TRY
										EXEC [uspICMassAddPromotionForCStore]
											-- filter params
											@intItemSpecialPricingId		= @intSpecialPricingId 

											-- update params
											, @intItemLocationToUpdateId	= @intLoopItemLocationId_TO 
											, @intEntityUserSecurityId		= @intEntityId
									END TRY
									BEGIN CATCH
										SET @ysnResultSuccess = 0
										SET @strResultMessage = 'Error updating Promotional Item Pricing: ' + ERROR_MESSAGE()  

										GOTO ExitWithRollback
									END CATCH



									-- Remove
									DELETE FROM @tblItemPricing_TO WHERE intItemLocationIdId_TO = @intLoopItemLocationId_TO AND intItemId_TO = @intLoopItemId_TO
								END

						END
					ELSE
						BEGIN
							SET @ysnResultSuccess = CAST(0 AS BIT)
							SET @strResultMessage = 'There are no records to copy to.'

							GOTO ExitWithRollback
						END

				END
			ELSE
				BEGIN

					SET @ysnResultSuccess = CAST(0 AS BIT)
					SET @strResultMessage = 'There are no records to copy from.'

					GOTO ExitWithRollback

				END
			END

		



		IF(@ysnDebug = CAST(1 AS BIT))
			BEGIN
				GOTO ExitWithRollback
			END
		ELSE IF(@ysnDebug = 0)
			BEGIN
				GOTO ExitWithCommit
			END

	END TRY
	BEGIN CATCH
		SET @ysnResultSuccess = CAST(0 AS BIT)
		SET @strResultMessage = ERROR_MESSAGE()  

		GOTO ExitWithRollback
	END CATCH
END




ExitWithCommit:
	IF @InitTranCount = 0
		BEGIN
			COMMIT TRANSACTION
		END

	GOTO ExitPost
	




ExitWithRollback:
		IF @InitTranCount = 0
			BEGIN
				IF ((XACT_STATE()) <> 0)
				BEGIN
					ROLLBACK TRANSACTION
				END
			END
			
		ELSE
			BEGIN
				IF ((XACT_STATE()) <> 0)
					BEGIN
						ROLLBACK TRANSACTION @Savepoint
					END
			END
			
				

		
ExitPost: