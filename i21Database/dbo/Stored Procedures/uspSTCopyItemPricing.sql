CREATE PROCEDURE [dbo].[uspSTCopyItemPricing]
	@intItemId							INT		
	, @intItemPricingId					INT	
	, @strCopyToItemPricingIdList		NVARCHAR(MAX)
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

	DECLARE @Savepoint NVARCHAR(32) = SUBSTRING(('uspSTCopyItemPricing' + CONVERT(VARCHAR, @InitTranCount)), 1, 32)

	BEGIN TRY
		
		BEGIN TRANSACTION 



		SET @ysnResultSuccess = CAST(1 AS BIT)
		SET @strResultMessage = ''




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


		-- [FROM] Create temp tablefrom
		BEGIN
			DECLARE @tblItemPricing_FROM TABLE (
				intItemPricingId_FROM		INT
				, intItemId_FROM			INT
				, dblStandardCost_FROM		NUMERIC(38,20)
				, dblLastCost_FROM			NUMERIC(38,20)
				, dblSalePrice_FROM		NUMERIC(18,6)
			);
		END

		-- [TO] Create temp tablefrom
		BEGIN
			DECLARE @tblItemPricing_TO TABLE (
				intItemPricingId_TO		INT
				, intItemId_TO			INT
				, dblStandardCost_TO	NUMERIC(38,20)
				, dblLastCost_TO		NUMERIC(38,20)
				, dblSalePrice_TO		NUMERIC(18,6)
			);
		END

		-- INSERT [FROM]
		INSERT INTO @tblItemPricing_FROM
		(
			intItemPricingId_FROM
			, intItemId_FROM
			, dblStandardCost_FROM
			, dblLastCost_FROM
			, dblSalePrice_FROM
		)
		SELECT
			intItemPricingId_FROM	= itemPricing.intItemPricingId
			, intItemId_FROM		= itemPricing.intItemId
			, dblStandardCost_FROM	= itemPricing.dblStandardCost
			, dblLastCost_FROM		= itemPricing.dblLastCost
			, dblSalePrice_FROM		= itemPricing.dblSalePrice
		FROM tblICItemPricing itemPricing
		WHERE itemPricing.intItemPricingId = @intItemPricingId


		-- ===============================================
		-- [START] - PREVIEW IF DEBUG (Temp Table FROM)
		-- ===============================================
		BEGIN
			IF(@ysnDebug = 1)
				BEGIN
					SELECT 'Item Pricing Copy From', * FROM @tblItemPricing_FROM
				END
		END
		-- ===============================================
		-- [END] - PREVIEW IF DEBUG (Temp Table FROM)
		-- ===============================================


		-- INSERT [TO]
		INSERT INTO @tblItemPricing_TO
		(
			intItemPricingId_TO
			, intItemId_TO
			, dblStandardCost_TO
			, dblLastCost_TO
			, dblSalePrice_TO
		)
		SELECT
			intItemPricingId_TO		= itemPricing.intItemPricingId
			, intItemId_TO			= itemPricing.intItemId
			, dblStandardCost_TO	= itemPricing.dblStandardCost
			, dblLastCost_TO		= itemPricing.dblLastCost
			, dblSalePrice_TO		= itemPricing.dblSalePrice
		FROM tblICItemPricing itemPricing
		WHERE itemPricing.intItemPricingId IN (SELECT [intID] FROM [dbo].[fnGetRowsFromDelimitedValues](@strCopyToItemPricingIdList))
			AND itemPricing.intItemPricingId != @intItemPricingId

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




		IF EXISTS(SELECT TOP 1 1 FROM @tblItemPricing_FROM)
			BEGIN
				
				IF EXISTS(SELECT TOP 1 1 FROM @tblItemPricing_TO)
					BEGIN
						
						DECLARE @intLoopItemPricingId_TO	AS INT
							  , @intLoopItemId_TO			AS INT

						DECLARE @intItemPricingId_FROM		AS INT
							  , @intItemId_FROM				AS INT
							  , @dblStandardCost_FROM		AS NUMERIC(38,20)
							  , @dblLastCost_FROM			AS NUMERIC(38,20)
							  , @dblSalePrice_FROM			AS NUMERIC(18,6)
						

						SELECT TOP 1
								@intItemPricingId_FROM	= temp.intItemPricingId_FROM
							  , @intItemId_FROM			= temp.intItemId_FROM
							  , @dblStandardCost_FROM	= CAST(temp.dblStandardCost_FROM AS NUMERIC(38, 20))
							  , @dblLastCost_FROM		= CAST(temp.dblLastCost_FROM AS NUMERIC(38, 20))
							  , @dblSalePrice_FROM		= CAST(temp.dblSalePrice_FROM AS NUMERIC(18,6))
						FROM @tblItemPricing_FROM temp



						WHILE EXISTS(SELECT TOP 1 1 FROM @tblItemPricing_TO)
							BEGIN
								
								SELECT TOP 1
										@intLoopItemPricingId_TO	= temp.intItemPricingId_TO
										, @intLoopItemId_TO			= temp.intItemId_TO
								FROM @tblItemPricing_TO temp




								BEGIN TRY
									EXEC [uspICUpdateItemPricingForCStore]
												-- filter params
												@strUpcCode					= NULL 
												, @strDescription			= NULL 
												, @intItemId				= @intLoopItemId_TO 
												, @intItemPricingId			= @intLoopItemPricingId_TO 

												-- update params
												, @dblStandardCost			= @dblStandardCost_FROM 
												, @dblRetailPrice			= @dblSalePrice_FROM
												, @dblLastCost				= @dblLastCost_FROM
												, @intEntityUserSecurityId	= @intEntityId
								END TRY
								BEGIN CATCH
									SET @ysnResultSuccess = 0
									SET @strResultMessage = 'Error updating Item Pricing: ' + ERROR_MESSAGE()  

									GOTO ExitWithRollback
								END CATCH



								-- Remove
								DELETE FROM @tblItemPricing_TO WHERE intItemPricingId_TO = @intLoopItemPricingId_TO
							END


						-- ===============================================
						-- [START] - PREVIEW UPDATE RECORDS
						-- ===============================================
						BEGIN
							IF(@ysnDebug = 1)
								BEGIN
									SELECT 'Preview Updated Item Pricing records'
										, itemPricing.intItemPricingId
										, itemPricing.intItemId
										, itemPricing.dblStandardCost
										, itemPricing.dblLastCost
										, itemPricing.dblSalePrice
									FROM tblICItemPricing itemPricing
									WHERE itemPricing.intItemPricingId != @intItemPricingId
										AND itemPricing.intItemPricingId IN (SELECT [intID] FROM [dbo].[fnGetRowsFromDelimitedValues](@strCopyToItemPricingIdList))
										
								END
						END
						-- ===============================================
						-- [END] - PREVIEW UPDATE RECORDS
						-- ===============================================

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