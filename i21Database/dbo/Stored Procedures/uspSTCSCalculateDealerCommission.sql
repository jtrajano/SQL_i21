﻿CREATE PROCEDURE [dbo].[uspSTCSCalculateDealerCommission] (
    @intCheckoutId INT
)
AS
BEGIN
	SET QUOTED_IDENTIFIER OFF
	SET ANSI_NULLS ON
	SET NOCOUNT ON
	SET XACT_ABORT ON
	SET ANSI_WARNINGS ON

	BEGIN TRY
		DECLARE @Cost DECIMAL(18,6)
		DECLARE @dblMargin DECIMAL(18,6)
		DECLARE @dblCommission DECIMAL(18,6)
		DECLARE @dblQty DECIMAL(18,6)
		DECLARE @dblPrice DECIMAL(18,6)
		DECLARE @dblMarkUp DECIMAL(18,6)
		DECLARE @dblDealerPercentage DECIMAL(18,6)
		DECLARE @intItemId INT
		DECLARE @intCompanyLocationId INT
		DECLARE @intItemUOMId INT
		DECLARE @intStoreId INT
		DECLARE @dblTotalCommission DECIMAL (18,6) = 0

		--BEGIN TRANSACTION
			DECLARE @intPumpTotalsId int

			DECLARE MY_CURSOR CURSOR 
			  LOCAL STATIC READ_ONLY FORWARD_ONLY
			FOR

			SELECT intPumpTotalsId
			FROM
			dbo.tblSTCheckoutPumpTotals CPT
			WHERE CPT.intCheckoutId = @intCheckoutId

			SELECT @intStoreId = CH.intStoreId
			FROM
			dbo.tblSTCheckoutHeader CH
			WHERE CH.intCheckoutId = @intCheckoutId

			SELECT 
			@dblMarkUp = ST.dblConsCommissionRawMarkup
			, @dblDealerPercentage = ST.dblConsCommissionDealerPercentage
			FROM tblSTStore ST
			WHERE ST.intStoreId = @intStoreId

			OPEN MY_CURSOR
			FETCH NEXT FROM MY_CURSOR INTO @intPumpTotalsId
			WHILE @@FETCH_STATUS = 0
			BEGIN 
				SELECT DISTINCT TOP 1
				@intItemId = Item.intItemId
				, @intCompanyLocationId = ST.intCompanyLocationId
				, @dblQty = CPT.dblQuantity
				, @dblPrice = CPT.dblPrice
				, @intItemUOMId = UOM.intItemUOMId	
				FROM
				dbo.tblSTCheckoutPumpTotals CPT
				INNER JOIN tblSTCheckoutHeader CH
					ON CPT.intCheckoutId = CH.intCheckoutId
				INNER JOIN tblSTStore ST
					ON CH.intStoreId = ST.intStoreId
				INNER JOIN tblICItemUOM UOM
					ON CPT.intPumpCardCouponId = UOM.intItemUOMId
				INNER JOIN tblICItem Item
					ON UOM.intItemId = Item.intItemId
				INNER JOIN dbo.tblICItemLocation IL 
					ON Item.intItemId = IL.intItemId
					AND ST.intCompanyLocationId = IL.intLocationId
				INNER JOIN tblSTCheckoutFuelTotalSold Chk
					ON ISNULL(CAST(Chk.intProductNumber AS NVARCHAR(10)), '') COLLATE Latin1_General_CI_AS IN (ISNULL(IL.strPassportFuelId1, ''), ISNULL(IL.strPassportFuelId2, ''), ISNULL(IL.strPassportFuelId3, ''))
				WHERE CPT.intPumpTotalsId = @intPumpTotalsId

	--- START INSERT FORMULA FOR CALCULATING DEALER COMMISSION HERE....  
	-- MARGIN = ((Qty Sold) * (Unit Price)) - (Cost in Inventory)  - ((Qty Sold) * (Consignor Markup/dblConsCommissionRawMarkup))  
	-- COMMISSION = (MARGIN) * (Commission Rate/dblConsCommissionDealerPercentage)      
	--BEGIN TRAN  
	EXEC [dbo].[uspICCalculateCost] @intItemId, @intCompanyLocationId, @dblQty, NULL, @Cost OUT, @intItemUOMId  
	--ROLLBACK
	SET @dblMargin = (@dblQty * @dblPrice) - (ISNULL(@Cost,0) * @dblQty) - (@dblQty * @dblMarkUp)  
	SET @dblCommission = @dblMargin * @dblDealerPercentage  
	SET @dblTotalCommission += @dblCommission  
  
	--- END INSERT FORMULA FOR CALCULATING DEALER COMMISSION HERE....  
	FETCH NEXT FROM MY_CURSOR INTO @intPumpTotalsId  
END  
CLOSE MY_CURSOR  
DEALLOCATE MY_CURSOR  
  
UPDATE tblSTCheckoutHeader			 SET dblDealerCommission = @dblTotalCommission WHERE intCheckoutId = @intCheckoutId  
UPDATE tblSTCheckoutDealerCommission SET dblCommissionAmount = @dblTotalCommission WHERE intCheckoutId = @intCheckoutId 

			--SET @dblDealersCommission = @dblTotalCommission;

		-- COMMIT
		--GOTO ExitWithCommit
		PRINT('S')
	END TRY
	BEGIN CATCH
		--SET @dblDealersCommission = 0
		-- ROLLBACK
		--GOTO ExitWithRollback
		PRINT('F')
	END CATCH
END
--ExitWithCommit:
--	-- Commit Transaction
--	COMMIT TRANSACTION --@TransactionName
--	GOTO ExitPost
	

--ExitWithRollback:
--    -- Rollback Transaction here
--	IF @@TRANCOUNT > 0
--		BEGIN
--			ROLLBACK TRANSACTION --@TransactionName
--		END		
--ExitPost:
