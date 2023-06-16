CREATE PROCEDURE [dbo].[uspSTCSCalculateDealerCommission] (
    @intCheckoutId INT,
	@intCheckoutProcessId INT
)
AS
SET NOCOUNT ON;
DECLARE @strMessageCatch NVARCHAR(MAX)
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
	DECLARE @strItemNo NVARCHAR(250)  
	DECLARE @strItemDescription NVARCHAR(500) 
	DECLARE @strMessage NVARCHAR(MAX)  
	
	DECLARE @intPumpTotalsId INT
	DECLARE @ysnAutoBlend BIT 

	DECLARE @dblPriceMargin DECIMAL(18,6)
	DECLARE @ysnStopProcessing BIT = 0
	DECLARE @ysnStopProcessingFinal BIT = 0
	DECLARE @intLatestWarningId INT = (SELECT DISTINCT TOP 1 intCheckoutProcessErrorWarningId FROM tblSTCheckoutProcessErrorWarning WHERE intCheckoutProcessId = @intCheckoutProcessId ORDER BY intCheckoutProcessErrorWarningId DESC)
	DECLARE @intSubLocationId INT
  
	DECLARE MY_CURSOR CURSOR LOCAL STATIC READ_ONLY FORWARD_ONLY
	FOR  
	SELECT		a.intPumpTotalsId, 
				c.ysnAutoBlend 
	FROM		tblSTCheckoutPumpTotals a
	INNER JOIN	tblICItemUOM b
	ON			a.intPumpCardCouponId = b.intItemUOMId
	INNER JOIN	tblICItem c
	ON			b.intItemId = c.intItemId
	WHERE		a.intCheckoutId = @intCheckoutId
	AND a.dblPrice <> 0 AND a.dblQuantity <> 0 AND a.dblAmount <> 0
  
	SELECT		@intStoreId = CH.intStoreId  
	FROM		dbo.tblSTCheckoutHeader CH  
	WHERE		CH.intCheckoutId = @intCheckoutId  
  
	SELECT		@dblMarkUp = ST.dblConsCommissionRawMarkup  
				, @dblDealerPercentage = ST.dblConsCommissionDealerPercentage  
	FROM		tblSTStore ST  
	WHERE		ST.intStoreId = @intStoreId  
  
	OPEN MY_CURSOR  
	FETCH NEXT FROM MY_CURSOR INTO @intPumpTotalsId, @ysnAutoBlend
	WHILE @@FETCH_STATUS = 0  
	BEGIN   
		SELECT		@intItemId = Item.intItemId  
					, @strItemNo = Item.strItemNo
					, @strItemDescription = Item.strDescription
					, @intCompanyLocationId = ST.intCompanyLocationId  
					, @dblQty = CPT.dblQuantity  
					, @dblPrice = CPT.dblPrice  
					, @intItemUOMId = UOM.intItemUOMId 
		FROM		dbo.tblSTCheckoutPumpTotals CPT
		INNER JOIN	tblSTCheckoutHeader CH
		ON			CPT.intCheckoutId = CH.intCheckoutId
		INNER JOIN	tblSTStore ST
		ON			CH.intStoreId = ST.intStoreId
		INNER JOIN	tblICItemUOM UOM
		ON			CPT.intPumpCardCouponId = UOM.intItemUOMId
		INNER JOIN	tblICItem Item
		ON			UOM.intItemId = Item.intItemId
		WHERE		CPT.intPumpTotalsId = @intPumpTotalsId  
		AND CPT.dblPrice <> 0 AND CPT.dblQuantity <> 0 AND CPT.dblAmount <> 0
	
		SET @Cost = NULL

		IF @ysnAutoBlend = 0
		BEGIN
			BEGIN TRY
				SET @intSubLocationId = (SELECT intCompanyLocationSubLocationId FROM tblTMSite WHERE intLocationId = @intCompanyLocationId AND intProduct = @intItemId);
				EXEC [dbo].[uspICCalculateCost] @intItemId, @intCompanyLocationId, @dblQty, NULL, @Cost OUT, @intItemUOMId, NULL, NULL, @intSubLocationId, NULL
			END TRY
			BEGIN CATCH
				SET @strMessageCatch = ERROR_MESSAGE()
				SET @ysnStopProcessing = 1;
				BREAK 
			END CATCH
		END
		--ROLLBACK

		IF @Cost IS NULL
		BEGIN
			IF @ysnAutoBlend = 1
			BEGIN
				--Based on discussion fuel blending will only involve a maximum of two fuel items.
				DECLARE @intMFGItemId INT 
				DECLARE @intMFGItemUOMId INT  
				DECLARE @dblMFGQty DECIMAL(18,6) 
				DECLARE @MFGCost DECIMAL(18,6)
				DECLARE @CostFirstInputItem DECIMAL(18,6)
				DECLARE @CostSecondInputItem DECIMAL(18,6)
				DECLARE @dblQtyFirstInputItem DECIMAL(18,6)
				DECLARE @dblQtySecondInputItem DECIMAL(18,6)  
				DECLARE @ysnInitialIteration BIT = 1

				DECLARE		RECIPE_CURSOR CURSOR LOCAL STATIC READ_ONLY FORWARD_ONLY
				FOR  
				SELECT		b.intItemId,
							b.intItemUOMId,
							b.dblQuantity
				FROM		tblMFRecipe a
				INNER JOIN	tblMFRecipeItem b
				ON			a.intRecipeId = b.intRecipeId
				WHERE		a.intLocationId = @intCompanyLocationId AND
							a.intItemUOMId = @intItemUOMId AND
							b.intRecipeItemTypeId = 1 AND --means input
							a.ysnActive = 1

				OPEN RECIPE_CURSOR  
				FETCH NEXT FROM RECIPE_CURSOR INTO @intMFGItemId, @intMFGItemUOMId, @dblMFGQty
				WHILE @@FETCH_STATUS = 0
				BEGIN
					SET @MFGCost = NULL

					BEGIN TRY
						SET @intSubLocationId = (SELECT intCompanyLocationSubLocationId FROM tblTMSite WHERE intLocationId = @intCompanyLocationId AND intProduct = @intMFGItemId);
						EXEC [dbo].[uspICCalculateCost] @intMFGItemId, @intCompanyLocationId, @dblQty, NULL, @MFGCost OUT, @intMFGItemUOMId, NULL, NULL, @intSubLocationId, NULL
					END TRY
					BEGIN CATCH
						SET @strMessageCatch = ERROR_MESSAGE()
						SET @ysnStopProcessing = 1;
						BREAK
					END CATCH				

					IF (@ysnInitialIteration = 1)
					BEGIN
						SET @CostFirstInputItem = @MFGCost
						SET @dblQtyFirstInputItem = @dblMFGQty
					END
					ELSE
					BEGIN
						SET @CostSecondInputItem = @MFGCost
						SET @dblQtySecondInputItem = @dblMFGQty
					END

					SET @ysnInitialIteration = 0
					FETCH NEXT FROM RECIPE_CURSOR INTO @intMFGItemId, @intMFGItemUOMId, @dblMFGQty
				END
				CLOSE RECIPE_CURSOR  
				DEALLOCATE RECIPE_CURSOR

				SET @Cost = (@CostFirstInputItem * @dblQtyFirstInputItem) + (@CostSecondInputItem * @dblQtySecondInputItem)
			END
		END

		--- START INSERT FORMULA FOR CALCULATING DEALER COMMISSION HERE....  
		-- MARGIN = ((Qty Sold) * (Unit Price)) - (Cost in Inventory)  - ((Qty Sold) * (Consignor Markup/dblConsCommissionRawMarkup))  
		-- COMMISSION = (MARGIN) * (Commission Rate/dblConsCommissionDealerPercentage)      
		--BEGIN TRAN	

		SET @dblMargin = (@dblQty * @dblPrice) - (ISNULL(@Cost,0) * @dblQty) - (@dblQty * @dblMarkUp)  
		SET @dblCommission = @dblMargin * @dblDealerPercentage  
		SET @dblTotalCommission += @dblCommission 	
		SET @dblPriceMargin = 0.5 * @dblPrice;

		IF @dblCommission < 0
		BEGIN
			--CS-559
			DECLARE @strPrice NVARCHAR(20)
			DECLARE @strCost NVARCHAR(20)
			DECLARE @strCommission NVARCHAR(20)

			SET @strPrice = (SELECT FORMAT(@dblPrice, 'N', 'en-us'));
			SET @strCost = (SELECT FORMAT(@Cost, 'N', 'en-us'));
			SET @strCommission = (SELECT FORMAT(@dblCommission, 'N', 'en-us'));

			SET @strMessage = 'Negative Dealer commissions have been calculated for fuel grade ' + @strItemNo + '-' + @strItemDescription + ' (Price: ' + @strPrice + ', Cost: ' + @strCost + ', Commission for this Item: ' + @strCommission + ') ' +
								' which is an indication that this fuel''s cost basis isn''t correctly set. Please correct the cost basis before processing this day.'

			INSERT tblSTCheckoutProcessErrorWarning (intCheckoutProcessId, intCheckoutId, strMessageType, strMessage, intConcurrencyId)
			VALUES (@intCheckoutProcessId, @intCheckoutId, 'F', @strMessage, 1) 
		END

		IF ISNULL(@Cost, 0) = 0 OR ISNULL(@Cost, 0) < @dblPriceMargin
		BEGIN
			SET @ysnStopProcessing = 1;
			SET @ysnStopProcessingFinal = 1;
			BREAK
		END
  
		--- END INSERT FORMULA FOR CALCULATING DEALER COMMISSION HERE....  
		FETCH NEXT FROM MY_CURSOR INTO @intPumpTotalsId, @ysnAutoBlend
	END  
	CLOSE MY_CURSOR  
	DEALLOCATE MY_CURSOR  

	IF @ysnStopProcessing = 1
	BEGIN
		IF @ysnStopProcessingFinal = 0
		BEGIN
			ROLLBACK
			SET @strMessage = '[A] There was an error when calculating Dealer Commissions. The Cost Basis for fuel was not received from the Inventory Module. With error message: ' + @strMessageCatch;
			DELETE FROM tblSTCheckoutProcessErrorWarning WHERE intCheckoutId = @intCheckoutId AND intCheckoutProcessId = @intCheckoutProcessId AND intCheckoutProcessErrorWarningId > @intLatestWarningId

			IF EXISTS (SELECT TOP 1 1 FROM tblSTCheckoutProcessErrorWarning WHERE intCheckoutId = @intCheckoutId AND intCheckoutProcessId = @intCheckoutProcessId AND strMessage = @strMessage)
			BEGIN
				DELETE FROM tblSTCheckoutProcessErrorWarning WHERE intCheckoutId = @intCheckoutId AND intCheckoutProcessId = @intCheckoutProcessId AND strMessage = @strMessage
			END

			INSERT tblSTCheckoutProcessErrorWarning (intCheckoutProcessId, intCheckoutId, strMessageType, strMessage, intConcurrencyId)
			VALUES (@intCheckoutProcessId, @intCheckoutId, 'F', @strMessage, 1) 

			SET @dblTotalCommission = 0;
		END
		ELSE
		BEGIN
			SET @strMessage = '[B] There was an error when calculating Dealer Commissions. The Cost Basis for fuel was not received from the Inventory Module. With error message: ' + @strMessageCatch;

			IF EXISTS (SELECT TOP 1 1 FROM tblSTCheckoutProcessErrorWarning WHERE intCheckoutId = @intCheckoutId AND intCheckoutProcessId = @intCheckoutProcessId AND (strMessage = @strMessage OR strMessage LIKE 'Negative Dealer commissions have been calculated for fuel grade%'))
			BEGIN
				DELETE FROM tblSTCheckoutProcessErrorWarning WHERE intCheckoutId = @intCheckoutId AND intCheckoutProcessId = @intCheckoutProcessId  AND (strMessage = @strMessage OR strMessage LIKE 'Negative Dealer commissions have been calculated for fuel grade%')
			END

			INSERT tblSTCheckoutProcessErrorWarning (intCheckoutProcessId, intCheckoutId, strMessageType, strMessage, intConcurrencyId)
			VALUES (@intCheckoutProcessId, @intCheckoutId, 'F', @strMessage, 1) 
		END
	END
	ELSE
	BEGIN
		SET @strMessage = '[C] There was an error when calculating Dealer Commissions. The Cost Basis for fuel was not received from the Inventory Module. With error message: ' + @strMessageCatch;

		IF EXISTS (SELECT TOP 1 1 FROM tblSTCheckoutProcessErrorWarning WHERE intCheckoutId = @intCheckoutId AND intCheckoutProcessId = @intCheckoutProcessId AND strMessage = @strMessage)
		BEGIN
			DELETE FROM tblSTCheckoutProcessErrorWarning WHERE intCheckoutId = @intCheckoutId AND intCheckoutProcessId = @intCheckoutProcessId AND strMessage = @strMessage
		END
	END
  
	UPDATE tblSTCheckoutHeader			 SET dblDealerCommission = @dblTotalCommission WHERE intCheckoutId = @intCheckoutId  
	UPDATE tblSTCheckoutDealerCommission SET dblCommissionAmount = @dblTotalCommission WHERE intCheckoutId = @intCheckoutId 
END TRY
BEGIN CATCH
	SET @strMessageCatch = ERROR_MESSAGE()
	IF @ysnStopProcessing = 1
	BEGIN
		IF @ysnStopProcessingFinal = 0
		BEGIN
			ROLLBACK
			SET @strMessage = '[D] There was an error when calculating Dealer Commissions. The Cost Basis for fuel was not received from the Inventory Module. With error message: ' + @strMessageCatch;
			DELETE FROM tblSTCheckoutProcessErrorWarning WHERE intCheckoutId = @intCheckoutId AND intCheckoutProcessId = @intCheckoutProcessId AND intCheckoutProcessErrorWarningId > @intLatestWarningId

			IF EXISTS (SELECT TOP 1 1 FROM tblSTCheckoutProcessErrorWarning WHERE intCheckoutId = @intCheckoutId AND intCheckoutProcessId = @intCheckoutProcessId AND strMessage = @strMessage)
			BEGIN
				DELETE FROM tblSTCheckoutProcessErrorWarning WHERE intCheckoutId = @intCheckoutId AND intCheckoutProcessId = @intCheckoutProcessId AND strMessage = @strMessage
			END

			INSERT tblSTCheckoutProcessErrorWarning (intCheckoutProcessId, intCheckoutId, strMessageType, strMessage, intConcurrencyId)
			VALUES (@intCheckoutProcessId, @intCheckoutId, 'F', @strMessage, 1) 

			SET @dblTotalCommission = 0;
		END
		ELSE
		BEGIN
			SET @strMessage = '[E] There was an error when calculating Dealer Commissions. The Cost Basis for fuel was not received from the Inventory Module. With error message: ' + @strMessageCatch;

			IF EXISTS (SELECT TOP 1 1 FROM tblSTCheckoutProcessErrorWarning WHERE intCheckoutId = @intCheckoutId AND intCheckoutProcessId = @intCheckoutProcessId AND (strMessage = @strMessage OR strMessage LIKE 'Negative Dealer commissions have been calculated for fuel grade%'))
			BEGIN
				DELETE FROM tblSTCheckoutProcessErrorWarning WHERE intCheckoutId = @intCheckoutId AND intCheckoutProcessId = @intCheckoutProcessId  AND (strMessage = @strMessage OR strMessage LIKE 'Negative Dealer commissions have been calculated for fuel grade%')
			END

			INSERT tblSTCheckoutProcessErrorWarning (intCheckoutProcessId, intCheckoutId, strMessageType, strMessage, intConcurrencyId)
			VALUES (@intCheckoutProcessId, @intCheckoutId, 'F', @strMessage, 1) 
		END
	END
	ELSE
	BEGIN
		SET @strMessage = '[F] There was an error when calculating Dealer Commissions. The Cost Basis for fuel was not received from the Inventory Module. With error message: ' + @strMessageCatch;

		IF EXISTS (SELECT TOP 1 1 FROM tblSTCheckoutProcessErrorWarning WHERE intCheckoutId = @intCheckoutId AND intCheckoutProcessId = @intCheckoutProcessId AND strMessage = @strMessage)
		BEGIN
			DELETE FROM tblSTCheckoutProcessErrorWarning WHERE intCheckoutId = @intCheckoutId AND intCheckoutProcessId = @intCheckoutProcessId  AND strMessage = @strMessage
		END
	END

	UPDATE tblSTCheckoutHeader			 SET dblDealerCommission = @dblTotalCommission WHERE intCheckoutId = @intCheckoutId  
	UPDATE tblSTCheckoutDealerCommission SET dblCommissionAmount = @dblTotalCommission WHERE intCheckoutId = @intCheckoutId 
END CATCH

--ROLLBACK