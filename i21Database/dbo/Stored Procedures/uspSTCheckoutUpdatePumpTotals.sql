CREATE PROCEDURE [dbo].[uspSTCheckoutUpdatePumpTotals]
	@intCheckoutId							INT,
	@ysnSuccess								BIT				OUTPUT,
	@strMessage								NVARCHAR(1000)	OUTPUT
AS
BEGIN
	--SET NOCOUNT ON
    SET XACT_ABORT ON
	BEGIN TRY
		BEGIN TRANSACTION
		
		DELETE FROM		tblSTCheckoutPumpTotals
		WHERE			intCheckoutId = @intCheckoutId AND 
						intPumpCardCouponId NOT IN (SELECT intItemUOMId FROM tblSTCheckoutFuelSalesByGradeAndPricePoint WHERE intCheckoutId = @intCheckoutId)
						
		UPDATE			CPT
		SET				CPT.dblQuantity = Chk.dblSumGallonsSold, 
						CPT.dblAmount = Chk.dblSumDollarsSold, 
						CPT.dblPrice = CASE WHEN ISNULL(CAST(Chk.dblSumGallonsSold as decimal(18,6)),1) = 0
										THEN 0
										ELSE CAST((ISNULL(CAST(Chk.dblSumDollarsSold as decimal(18,6)),0) / ISNULL(CAST(Chk.dblSumGallonsSold as decimal(18,6)),1)) AS DECIMAL(18,6))
										END
		FROM			dbo.tblSTCheckoutPumpTotals CPT
		INNER JOIN		(	SELECT		intCheckoutId, 
										intItemUOMId, 
										SUM(dblDollarsSold - dblPumpTestDollars) as dblSumDollarsSold, 
										SUM(dblGallonsSold - dblPumpTestGallons) as dblSumGallonsSold 
							FROM		tblSTCheckoutFuelSalesByGradeAndPricePoint
							WHERE		intCheckoutId = @intCheckoutId
							GROUP BY	intCheckoutId, 
										intItemUOMId) Chk
		ON				CPT.intPumpCardCouponId = Chk.intItemUOMId AND
						CPT.intCheckoutId = Chk.intCheckoutId
		WHERE			CPT.intCheckoutId = @intCheckoutId
		
		INSERT INTO dbo.tblSTCheckoutPumpTotals(intCheckoutId, intPumpCardCouponId, intCategoryId, strDescription, dblPrice , dblQuantity, dblAmount, intConcurrencyId)
		SELECT		@intCheckoutId , Chk.intItemUOMId , I.intCategoryId , I.strDescription,  
					CASE WHEN ISNULL(CAST(Chk.dblSumGallonsSold as decimal(18,6)),1) = 0
					THEN 0
					ELSE CAST((ISNULL(CAST(Chk.dblSumDollarsSold as decimal(18,6)),0) / ISNULL(CAST(Chk.dblSumGallonsSold as decimal(18,6)),1)) AS DECIMAL(18,6))
					END, 
					ISNULL(CAST(Chk.dblSumGallonsSold as decimal(18,6)), 0), 
					ISNULL(CAST(Chk.dblSumDollarsSold as decimal(18,6)),0),  
					0
		FROM		(	SELECT		intCheckoutId, 
									intItemUOMId, 
									SUM(dblDollarsSold - dblPumpTestDollars) as dblSumDollarsSold, 
									SUM(dblGallonsSold - dblPumpTestGallons) as dblSumGallonsSold 
						FROM		tblSTCheckoutFuelSalesByGradeAndPricePoint
						WHERE		intCheckoutId = @intCheckoutId AND 
									intItemUOMId NOT IN (	SELECT		intPumpCardCouponId 
															FROM		tblSTCheckoutPumpTotals 
															WHERE		intCheckoutId = @intCheckoutId)
						GROUP BY intCheckoutId, intItemUOMId) Chk
		JOIN		tblICItemUOM UOM
		ON			Chk.intItemUOMId = UOM.intItemUOMId
		JOIN		tblICItem I
		ON			I.intItemId = UOM.intItemId

		SET @strMessage = 'Success'
		SET @ysnSuccess = 1

		-- COMMIT
		GOTO ExitWithCommit
	END TRY

	BEGIN CATCH
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