CREATE PROCEDURE [dbo].[uspSTGridUpdateCostAndPrice]
    @intEntityId INT,
    @ysnRecap BIT,
	@UDTItemGridToUpdate StoreItemGridToUpdate	READONLY,
    @ysnSuccess AS BIT OUTPUT,
    @strResultMsg NVARCHAR(1000) OUTPUT
AS
	
	BEGIN TRY
    BEGIN TRANSACTION 

	IF NOT EXISTS(SELECT TOP 1 1 FROM @UDTItemGridToUpdate)
	BEGIN
		SET @ysnSuccess = 'false'
		SET @strResultMsg = 'There are no records to update'

		GOTO ExitWithRollback;
	END
	
	
	IF EXISTS(SELECT TOP 1 1 FROM @UDTItemGridToUpdate WHERE ISNULL(dtmEndDate, '') = '')
		BEGIN
		
			DECLARE @tblGridCostAndPriceToUpdate TABLE (
				[intItemId]		[int] NULL,
				[intItemLocationId]	[int] NULL,
				[dblNewCost]	[numeric](38, 2) NULL,
				[dblNewPrice]	[numeric](38, 2) NULL,
				[dtmStartDate]	[datetime] NULL,
				[dtmEndDate]	[datetime] NULL
			)

			INSERT INTO @tblGridCostAndPriceToUpdate
			(
				[intItemId]		
				, [intItemLocationId]	
				, [dblNewCost]	
				, [dblNewPrice]	
				, [dtmStartDate]	
				, [dtmEndDate]	
			)
			SELECT DISTINCT
				[intItemId]				= udt.intItemId
				, [intItemLocationId]	= il.intItemLocationId
				, [dblNewCost]			= udt.dblNewCost
				, [dblNewPrice]			= udt.dblNewPrice
				, [dtmStartDate]		= udt.dtmStartDate
				, [dtmEndDate]			= udt.dtmEndDate
			FROM @UDTItemGridToUpdate udt 
				INNER JOIN tblSTStore st
					ON udt.intStoreNo = st.intStoreNo
				INNER JOIN tblICItemLocation il
					ON il.intLocationId = st.intCompanyLocationId 
					AND il.intItemId = udt.intItemId

	
			DECLARE @intLoopItemId					AS INT
					, @intLoopItemLocationId		AS INT
					, @dblLoopNewCost				AS NUMERIC(38,2)
					, @dblLoopNewPrice				AS NUMERIC(38,2)
					, @dtmLoopStartDate				AS DATETIME
					, @dtmLoopEndDate				AS DATETIME

			WHILE EXISTS(SELECT TOP 1 1 FROM @tblGridCostAndPriceToUpdate)
				BEGIN
						
					SELECT TOP 1
						@intLoopItemId					= temp.[intItemId]
						, @intLoopItemLocationId		= temp.[intItemLocationId]
						, @dblLoopNewCost				= temp.[dblNewCost]
						, @dblLoopNewPrice				= temp.[dblNewPrice]
						, @dtmLoopStartDate				= temp.[dtmStartDate]
						, @dtmLoopEndDate				= temp.[dtmEndDate]
					FROM @tblGridCostAndPriceToUpdate temp

					BEGIN TRY

						EXEC [uspICUpdateItemWithEffectiveDatePricingForCStore]
							@intItemId					= @intLoopItemId		,
							@intItemLocationId 			= @intLoopItemLocationId,
							@dblStandardCost 			= @dblLoopNewCost		,
							@dblRetailPrice				= @dblLoopNewPrice		,
							@dtmEffectiveDate 			= @dtmLoopStartDate		,
							@intEntityUserSecurityId	= @intEntityId

					END TRY
					BEGIN CATCH
						SET @ysnSuccess = 'false'
						SET @strResultMsg = 'Error encountered while updating pricing with effective date on item: ' + ERROR_MESSAGE()

						GOTO ExitWithRollback;
					END CATCH

					DELETE FROM @tblGridCostAndPriceToUpdate
					WHERE  
						[intItemId]				  = @intLoopItemId
						AND [intItemLocationId]	  = @intLoopItemLocationId
						AND [dblNewCost]		  = @dblLoopNewCost		
						AND [dblNewPrice]		  = @dblLoopNewPrice		
						AND [dtmStartDate]		  = @dtmLoopStartDate		
						AND [dtmEndDate]		  = @dtmLoopEndDate		
				END
		END 
	ELSE
		BEGIN

			-- Create the temp table 
			IF OBJECT_ID('tempdb..#tmpUpdateItemPricingForCStore_Location') IS NULL  
				CREATE TABLE #tmpUpdateItemPricingForCStore_Location (
					intLocationId INT 
				)

			DECLARE @tblGridCostAndPriceToUpdatePromotional TABLE (
				[strUpcCode]			[varchar](250) NULL,
				[intItemId]				[int] NULL,
				[intLocationId]				[int] NULL,
				[intCompanyLocationId]	[int] NULL,
				[dblNewCost]			[numeric](38, 2) NULL,
				[dblNewPrice]			[numeric](38, 2) NULL,
				[dtmStartDate]			[datetime] NULL,
				[dtmEndDate]			[datetime] NULL
			)

			INSERT INTO @tblGridCostAndPriceToUpdatePromotional
			(
				[strUpcCode]	
				, [intItemId]	
				, [intLocationId]
				, [intCompanyLocationId]	--This will be the company location for this table
				, [dblNewCost]	
				, [dblNewPrice]	
				, [dtmStartDate]	
				, [dtmEndDate]	
			)
			SELECT DISTINCT
				[strUpcCode]				= uom.strLongUPCCode
				, [intItemId]				= udt.intItemId
				, [intLocationId]			= il.intItemLocationId
				, [intCompanyLocationId]	= st.intCompanyLocationId
				, [dblNewCost]				= udt.dblNewCost
				, [dblNewPrice]				= udt.dblNewPrice
				, [dtmStartDate]			= udt.dtmStartDate
				, [dtmEndDate]				= udt.dtmEndDate
			FROM @UDTItemGridToUpdate udt 
				INNER JOIN tblSTStore st
					ON udt.intStoreNo = st.intStoreNo
				INNER JOIN tblICItemLocation il
					ON il.intLocationId = st.intCompanyLocationId 
					AND il.intItemId = udt.intItemId
				INNER JOIN tblICItemUOM uom
					ON uom.intItemId = udt.intItemId 
					AND uom.ysnStockUnit = 1

	
			DECLARE @strPromoLoopUpcCode				AS VARCHAR(250)
					, @strTESTResult  					AS VARCHAR(250)
					, @intPromoLoopItemId				AS INT
					, @intPromoLoopItemLocationId		AS INT
					, @intPromoLoopCompanyLocationId	AS INT
					, @dblPromoLoopNewCost				AS NUMERIC(38,6)
					, @dblPromoLoopNewPrice				AS NUMERIC(38,6)
					, @dtmPromoLoopStartDate			AS DATETIME
					, @dtmPromoLoopEndDate				AS DATETIME

			WHILE EXISTS(SELECT TOP 1 1 FROM @tblGridCostAndPriceToUpdatePromotional)
				BEGIN
					SELECT TOP 1
						@strPromoLoopUpcCode				= temp.[strUpcCode]
						, @intPromoLoopItemId				= temp.[intItemId]
						, @intPromoLoopItemLocationId		= temp.[intLocationId]
						, @intPromoLoopCompanyLocationId	= temp.[intCompanyLocationId]
						, @dblLoopNewCost					= temp.[dblNewCost]
						, @dblLoopNewPrice					= temp.[dblNewPrice]
						, @dtmLoopStartDate					= CONVERT(DATETIME, CONVERT(DATE, temp.[dtmStartDate])) --Get the Date only
						, @dtmLoopEndDate					= CONVERT(DATETIME, CONVERT(DATE, temp.[dtmEndDate])) --Get the Date only
					FROM @tblGridCostAndPriceToUpdatePromotional temp

					DELETE FROM #tmpUpdateItemPricingForCStore_Location


					--This will apply a filtering of location based per item in Updating Promotional Cost and Price
					--To prevent mass update for all locations if existing functionality is used

					IF(@intPromoLoopCompanyLocationId IS NOT NULL AND @intPromoLoopCompanyLocationId != '')
						BEGIN
							INSERT INTO #tmpUpdateItemPricingForCStore_Location (
								intLocationId
							)
							SELECT @intPromoLoopCompanyLocationId AS intLocationId
						END

					BEGIN TRY
					
						-- ITEM SPECIAL PRICING
						EXEC [dbo].[uspICUpdateItemPromotionalPricingForCStore]
							@dblPromotionalSalesPrice		= @dblLoopNewPrice 
							,@dblPromotionalCost			= @dblLoopNewCost 
							,@dtmBeginDate					= @dtmLoopStartDate
							,@dtmEndDate					= @dtmLoopEndDate 
							,@strUpcCode					= @strPromoLoopUpcCode
							,@intItemId						= @intPromoLoopItemId
							,@intItemLocationId				= @intPromoLoopItemLocationId
							,@intEntityUserSecurityId		= @intEntityId
						
						
					END TRY
					BEGIN CATCH
						SET @ysnSuccess = 'false'
						SET @strResultMsg = 'Error encountered while updating promotion on item: ' + ERROR_MESSAGE()

						GOTO ExitWithRollback;
					END CATCH

					
					SELECT TOP 1
						@strPromoLoopUpcCode				= temp.[strUpcCode]
						, @intPromoLoopItemId				= temp.[intItemId]
						, @intPromoLoopItemLocationId		= temp.[intLocationId]
						, @intPromoLoopCompanyLocationId	= temp.[intCompanyLocationId]
						, @dblLoopNewCost					= temp.[dblNewCost]
						, @dblLoopNewPrice					= temp.[dblNewPrice]
						, @dtmLoopStartDate					= temp.[dtmStartDate]
						, @dtmLoopEndDate					= temp.[dtmEndDate]
					FROM @tblGridCostAndPriceToUpdatePromotional temp
					

					DELETE FROM @tblGridCostAndPriceToUpdatePromotional
					WHERE  
						ISNULL([strUpcCode], '')						= ISNULL(@strPromoLoopUpcCode, '')
						AND [intItemId]									= @intPromoLoopItemId
						AND [intLocationId]								= @intPromoLoopItemLocationId
						AND [intCompanyLocationId]						= @intPromoLoopCompanyLocationId
						AND CAST([dblNewCost] AS NUMERIC(18,6))			= CAST(@dblLoopNewCost AS NUMERIC(18,2))		
						AND CAST([dblNewPrice] AS NUMERIC(18,6))		= CAST(@dblLoopNewPrice	 AS NUMERIC(18,2))	
						AND [dtmStartDate]								= @dtmLoopStartDate		
						AND [dtmEndDate]								= @dtmLoopEndDate	

						
						
				END
				
				IF OBJECT_ID('tempdb..#tmpUpdateItemPricingForCStore_Location') IS NOT NULL  
					DROP TABLE #tmpUpdateItemPricingForCStore_Location 
		END 
		
		
	END TRY
	BEGIN CATCH
		SET @ysnSuccess = 'false'
		SET @strResultMsg = 'Error encountered while updating pricebook item' + ERROR_MESSAGE()

		GOTO ExitWithRollback;
	END CATCH
				
SET @ysnSuccess = 'true'
SET @strResultMsg = 'Success'

ExitWithCommit:
	COMMIT TRANSACTION
	GOTO ExitPost


ExitWithRollback:
	IF @@TRANCOUNT > 0
	BEGIN
		ROLLBACK TRANSACTION
	END


ExitPost: