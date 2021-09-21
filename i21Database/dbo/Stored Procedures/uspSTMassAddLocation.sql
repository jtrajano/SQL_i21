CREATE PROCEDURE [dbo].[uspSTMassAddLocation]
	@intItemLocationId					INT	
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

	DECLARE @Savepoint NVARCHAR(32) = SUBSTRING(('uspSTMassAddLocation' + CONVERT(VARCHAR, @InitTranCount)), 1, 32)

	BEGIN TRY
		
		BEGIN TRANSACTION 

		SET @ysnResultSuccess = CAST(1 AS BIT)
		SET @strResultMessage = ''
		
		DECLARE @ysnTaxFlag1				AS BIT 
		DECLARE @ysnTaxFlag2				AS BIT 
		DECLARE @ysnTaxFlag3				AS BIT
		DECLARE @ysnTaxFlag4				AS BIT
		DECLARE @ysnDepositRequired			AS BIT
		DECLARE @ysnQuantityRequired		AS BIT
		DECLARE @ysnScaleItem				AS BIT
		DECLARE @ysnFoodStampable			AS BIT
		DECLARE @dblTransactionQtyLimit		DECIMAL(18,6)
		DECLARE @ysnReturnable				AS BIT
		DECLARE @ysnSaleable				AS BIT 
		DECLARE @ysnIdRequiredCigarette		AS BIT
		DECLARE @ysnIdRequiredLiquor		AS BIT 
		DECLARE @ysnPromotionalItem			AS BIT 
		DECLARE @ysnPrePriced				AS BIT 
		DECLARE @ysnApplyBlueLaw1			AS BIT 
		DECLARE @ysnApplyBlueLaw2			AS BIT 
		DECLARE @ysnCountedDaily			AS BIT 
		DECLARE @ysnCountBySINo				AS BIT 
		DECLARE @intFamilyId				AS INT 
		DECLARE @intClassId					AS INT 
		DECLARE @intVendorId				AS INT 
		DECLARE	@intDepositPLU				INT
		DECLARE	@dblNewMinVendorOrderQty	DECIMAL(18,6)
		DECLARE	@dblNewVendorSuggestedQty	DECIMAL(18,6)
		DECLARE	@dblNewMinQtyOnHand			DECIMAL(18,6)

		BEGIN
			-- Create the temp table 
			IF OBJECT_ID('tempdb..#tmpUpdateItemLocationForCStore_Location') IS NULL  
				CREATE TABLE #tmpUpdateItemLocationForCStore_Location (
					intLocationId INT 
				)
		END

		
		IF(@strCopyToItemLocationIdList IS NOT NULL AND @strCopyToItemLocationIdList != '')
			BEGIN
				INSERT INTO #tmpUpdateItemLocationForCStore_Location (
					intLocationId
				)
				SELECT [intID] FROM [dbo].[fnGetRowsFromDelimitedValues](@strCopyToItemLocationIdList)
			END

		IF EXISTS(SELECT TOP 1 1 FROM tblICItemLocation WHERE intItemLocationId = @intItemLocationId)
			BEGIN
				
				IF EXISTS(SELECT TOP 1 1 FROM #tmpUpdateItemLocationForCStore_Location)
					BEGIN
						
						DECLARE @intLocation_TO	AS INT

						WHILE EXISTS(SELECT TOP 1 1 FROM #tmpUpdateItemLocationForCStore_Location)
							BEGIN
								
								SELECT TOP 1
										@intLocation_TO	= temp.intLocationId
								FROM #tmpUpdateItemLocationForCStore_Location temp

								BEGIN TRY
									EXEC [uspICMassAddItemLocationForCStore]
												-- filter params
												@intItemLocationId		= @intItemLocationId 
												-- update params
												, @intLocationToUpdateId	= @intLocation_TO 
												, @intEntityUserSecurityId	= @intEntityId
								END TRY
								BEGIN CATCH
									SET @ysnResultSuccess = 0
									SET @strResultMessage = 'Error updating Item Location: ' + ERROR_MESSAGE()  

									GOTO ExitWithRollback
								END CATCH



								-- Remove
								DELETE FROM #tmpUpdateItemLocationForCStore_Location WHERE intLocationId = @intLocation_TO
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