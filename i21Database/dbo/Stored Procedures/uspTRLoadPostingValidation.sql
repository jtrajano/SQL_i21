CREATE PROCEDURE [dbo].[uspTRLoadPostingValidation]
	@intLoadHeaderId AS INT
	, @ysnPostOrUnPost AS BIT
	, @intUserId AS INT

AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

DECLARE @ErrorMessage NVARCHAR(4000)
DECLARE @ErrorSeverity INT
DECLARE @ErrorState INT

BEGIN TRY
	DECLARE @dtmLoadDateTime DATETIME
		, @intShipVia INT
		, @intSeller INT
		, @intLoadReceiptId INT
		, @intInventoryReceiptId INT
		, @intInventoryTransferId INT
		, @intLoadDistributionHeaderId INT
		, @intLoadDistributionDetailId INT
		, @intInvoiceId INT
		, @intEntityUserSecurityId INT
		, @intStockUOMId INT
		, @err NVARCHAR(150)
		, @strItem NVARCHAR(50)
		, @strItemLocation NVARCHAR(50)
		, @intDriver INT
		, @strOrigin NVARCHAR(50)
		, @strBOL NVARCHAR(50)
		, @intTerminal INT
		, @intSupplyPoint INT
		, @intCompanyLocation INT
		, @intItemId INT
		, @dblNet DECIMAL(18, 6) = 0
		, @dblGross DECIMAL(18, 6) = 0
		, @dblUnitCost DECIMAL(18, 6) = 0
		, @dblFreight DECIMAL(18, 6) = 0
		, @dblSurcharge DECIMAL(18, 6) = 0
		, @GrossorNet NVARCHAR(50)
		, @intDistributionItemId INT
		, @dblUnits DECIMAL(18, 6) = 0
		, @dblPrice DECIMAL(18, 6) = 0
		, @strDestination NVARCHAR(50)
		, @intEntityCustomerId INT
		, @intEntitySalespersonId INT
		, @intShipToLocationId INT
		, @intCompanyLocationId INT
		, @dtmInvoiceDateTime DATETIME
		, @strresult NVARCHAR(MAX)
		, @strDescription NVARCHAR(100)
		, @dblReceivedQuantity DECIMAL(18, 6) = 0
		, @dblDistributedQuantity DECIMAL(18, 6) = 0
		, @intFreightItemId INT
		, @intSurchargeItemId INT
		, @ysnItemizeSurcharge BIT
	
	SELECT @dtmLoadDateTime = TL.dtmLoadDateTime
		, @intShipVia = TL.intShipViaId
		, @intSeller = TL.intSellerId
		, @intDriver = TL.intDriverId
	FROM tblTRLoadHeader TL
	WHERE TL.intLoadHeaderId = @intLoadHeaderId

	IF (ISDATE(@dtmLoadDateTime) = 0 )
	BEGIN
		RAISERROR('Invalid Load Date/Time', 16, 1)
	END
	IF (@intShipVia IS NULL)
	BEGIN
		RAISERROR('Invalid Ship Via', 16, 1)
	END
	IF (@intSeller IS NULL)
	BEGIN
		RAISERROR('Invalid Seller', 16, 1)
	END
	IF (@intDriver IS NULL)
	BEGIN
		RAISERROR('Invalid Driver', 16, 1)
	END

	SELECT TOP 1 @intFreightItemId = intItemForFreightId
		, @ysnItemizeSurcharge = ISNULL(ysnItemizeSurcharge, 0)
	FROM tblTRCompanyPreference

	IF (@ysnItemizeSurcharge = 0)
		SELECT TOP 1 @intSurchargeItemId = intItemId FROM vyuICGetOtherCharges WHERE intOnCostTypeId = @intFreightItemId
	ELSE
		SELECT TOP 1 @intSurchargeItemId = intSurchargeItemId FROM tblTRCompanyPreference

	IF (ISNULL(@intSurchargeItemId, '') <> '')
	BEGIN
		IF NOT EXISTS(SELECT TOP 1 1 FROM vyuICGetOtherCharges WHERE intItemId = @intSurchargeItemId AND intOnCostTypeId = @intFreightItemId)
		BEGIN
			RAISERROR('Surcharge Item is not setup for the Freight Item specified from Company Configuration', 16, 1)
		END
	END

	SELECT TL.intLoadHeaderId
		, TR.intLoadReceiptId
		, TR.strOrigin
		, strBOL = TR.strBillOfLading
		, TR.intTerminalId
		, TR.intSupplyPointId
		, TR.intCompanyLocationId
		, TR.intItemId
		, TR.dblNet
		, TR.dblGross
		, TR.dblUnitCost
		, dblFreight = TR.dblFreightRate
		, dblSurcharge = TR.dblPurSurcharge
	INTO #ReceiptList
	FROM tblTRLoadHeader TL
	LEFT JOIN tblTRLoadReceipt TR ON TL.intLoadHeaderId = TR.intLoadHeaderId
	WHERE TL.intLoadHeaderId = @intLoadHeaderId
	  
	IF NOT EXISTS(SELECT TOP 1 1 FROM #ReceiptList)
	BEGIN
		RAISERROR('Receipt entries not present', 16, 1);
	END

	SET @intLoadReceiptId = NULL

	WHILE EXISTS (SELECT TOP 1 1 FROM #ReceiptList)
	BEGIN
		SELECT TOP 1 @intLoadReceiptId = RT.intLoadReceiptId
			, @strOrigin = RT.strOrigin
			, @strBOL = RT.strBOL
			, @intTerminal = RT.intTerminalId
			, @intSupplyPoint = RT.intSupplyPointId
			, @intCompanyLocation = RT.intCompanyLocationId
			, @intItemId = RT.intItemId
			, @dblNet = RT.dblNet
			, @dblGross = RT.dblGross
			, @dblUnitCost = RT.dblUnitCost
			, @dblFreight = RT.dblFreight
			, @dblSurcharge = RT.dblSurcharge
		FROM #ReceiptList RT

		SELECT TOP 1@intStockUOMId = intStockUOMId
			, @strItem = strItemNo
			, @strDescription = strDescription
		FROM vyuICGetItemStock
		WHERE intItemId = @intItemId
			AND intLocationId = @intCompanyLocation
		
		IF(@strOrigin = 'Terminal')
		BEGIN
			IF @ysnPostOrUnPost = 1 AND (@strBOL IS NULL OR LTRIM(RTRIM(@strBOL)) = '')
			BEGIN
				RAISERROR('Bill of Lading is required', 16, 1)
			END
			IF (@intTerminal IS NULL)
			BEGIN
				RAISERROR('Invalid Terminal', 16, 1)
			END
			IF (@intSupplyPoint IS NULL)
			BEGIN
				RAISERROR('Invalid Supply Point', 16, 1)
			END
			IF (@intCompanyLocation IS NULL)
			BEGIN
				RAISERROR('Invalid Bulk Location', 16, 1)
			END
			IF (@intItemId IS NULL)
			BEGIN
				RAISERROR('Invalid Purchase Item', 16, 1)
			END
			IF (ISNULL(@dblFreight, 0) > 0 AND ISNULL(@intFreightItemId, '') = '')
			BEGIN
				RAISERROR('Freight Item not found. Please setup in Company Configuration', 16, 1)
			END
			IF (ISNULL(@dblSurcharge, 0) > 0 AND ISNULL(@intSurchargeItemId, '') = '')
			BEGIN
				IF ISNULL(@intSurchargeItemId, '') = ''
					SET @err = ' Surcharge Item is null. Please setup in Company Configuration'
				ELSE
					SET @err = CAST(@intSurchargeItemId AS NVARCHAR(10)) + ' Surcharge Item not found. Please setup in Company Configuration'

				RAISERROR(@err, 16, 1)
			END
			
			IF (@intStockUOMId IS NULL)
			BEGIN
				SET @err = 'Stock UOM is not setup for item ' + @strItem
				RAISERROR(@err , 16, 1)
			END
			
			SELECT @GrossorNet = strGrossOrNet
			FROM tblTRSupplyPoint
			WHERE intSupplyPointId = @intSupplyPoint
			IF (@GrossorNet IS NULL)
			BEGIN
				RAISERROR('Gross or Net is not setup for Supply Point', 16, 1)
			END
			IF (ISNULL(@GrossorNet, 'Gross') = 'Gross')
			BEGIN
				IF(ISNULL(@dblGross, 0) = 0)
				BEGIN
					RAISERROR('Gross Quantity cannot be 0', 16, 1)
				END
			END
			ELSE
			BEGIN
				IF (ISNULL(@dblNet, 0) = 0)
				BEGIN
					RAISERROR('Net Quantity cannot be 0', 16, 1)
				END
			END
		END
		ELSE
		BEGIN
			IF (@intCompanyLocation IS NULL)
			BEGIN
				RAISERROR('Invalid Bulk Location', 16, 1)
			END
			IF (@intItemId IS NULL)
			BEGIN
				RAISERROR('Invalid Purchase Item', 16, 1)
			END
			
			IF (@intStockUOMId IS NULL)
			BEGIN
				SET @err = 'Stock UOM is not setup for item ' + @strItem
				RAISERROR(@err , 16, 1)
			END
			IF ((ISNULL(@dblGross, 0) = 0) AND (ISNULL(@dblNet, 0) = 0))
			BEGIN
				RAISERROR('Gross and Net Quantity cannot be 0', 16, 1)
			END
		END

		IF EXISTS (SELECT TOP 1 1 FROM tblTRLoadReceipt
		WHERE strBillOfLading = @strBOL
			AND intLoadHeaderId != @intLoadHeaderId)
		BEGIN
			SET @err = 'BOL ' + @strBOL + ' already exists on another Transport Load'
			RAISERROR(@err, 16, 1)
		END

		SELECT @dblReceivedQuantity = (CASE WHEN (@GrossorNet = 'Net') THEN SUM(TR.dblNet)
											ELSE SUM(TR.dblGross) END)
		FROM tblTRLoadReceipt TR
		WHERE TR.intLoadHeaderId = @intLoadHeaderId
			AND TR.intItemId = @intItemId
		GROUP BY TR.intItemId

		-- Blend Item Quantity Check
		SELECT BlendIngredient.intIngredientItemId
			, dblQuantity = SUM(BlendIngredient.dblQuantity)
		INTO #tmpBlendDistributionItems
		FROM vyuTRGetLoadBlendIngredient BlendIngredient
		LEFT JOIN tblMFRecipe Recipe ON Recipe.intRecipeId = BlendIngredient.intRecipeId
		LEFT JOIN tblTRLoadDistributionHeader HeaderDistItem ON HeaderDistItem.intLoadDistributionHeaderId = BlendIngredient.intLoadDistributionHeaderId
		WHERE HeaderDistItem.intLoadHeaderId = @intLoadHeaderId
			AND Recipe.ysnActive = 1
			AND BlendIngredient.intIngredientItemId = @intItemId
		GROUP BY BlendIngredient.intIngredientItemId

		IF EXISTS (SELECT TOP 1 1 FROM #tmpBlendDistributionItems)
		BEGIN
			SELECT @dblDistributedQuantity = SUM(dblQuantity) FROM #tmpBlendDistributionItems

			IF (@dblReceivedQuantity != @dblDistributedQuantity)
			BEGIN
				SET @strresult = 'Raw Materials ' + @strDescription + ' received quantity ' + LTRIM(@dblReceivedQuantity)  + ' does not match required quantity ' + LTRIM(@dblDistributedQuantity) + ' for blending'
				RAISERROR(@strresult, 16, 1)
			END
		END
		ELSE
		BEGIN
			SELECT @dblDistributedQuantity = SUM(DD.dblUnits)
			FROM tblTRLoadDistributionHeader DH
			JOIN tblTRLoadDistributionDetail DD ON DH.intLoadDistributionHeaderId = DD.intLoadDistributionHeaderId
			WHERE intLoadHeaderId = @intLoadHeaderId
				AND DD.intItemId = @intItemId
			GROUP BY DD.intItemId
		
			IF (@dblReceivedQuantity != @dblDistributedQuantity)
			BEGIN
				SET @strresult = @strDescription + ' received quantity ' + LTRIM(@dblReceivedQuantity)  + ' does not match distributed quantity ' + LTRIM(@dblDistributedQuantity)
				RAISERROR(@strresult, 16, 1)
			END
		END

		DROP TABLE #tmpBlendDistributionItems

		DELETE FROM #ReceiptList WHERE intLoadReceiptId = @intLoadReceiptId
	END

	SELECT TL.intLoadHeaderId
		, DH.intLoadDistributionHeaderId
		, DH.strDestination
		, DH.intEntityCustomerId
		, DH.intShipToLocationId
		, DH.intCompanyLocationId
		, DH.intEntitySalespersonId
		, DH.dtmInvoiceDateTime
	INTO #DistributionHeaderTable
	FROM tblTRLoadHeader TL
	LEFT JOIN tblTRLoadDistributionHeader DH ON DH.intLoadHeaderId = TL.intLoadHeaderId
	WHERE TL.intLoadHeaderId = @intLoadHeaderId
	
	SELECT TL.intLoadHeaderId
		, DD.intLoadDistributionDetailId
		, DD.intLoadDistributionHeaderId
		, DD.intItemId
		, DD.dblUnits
		, DD.dblPrice
		, dblFreight = DD.dblFreightRate
		, dblSurcharge = DD.dblDistSurcharge
	INTO #DistributionDetailTable
	FROM tblTRLoadHeader TL
	LEFT JOIN tblTRLoadDistributionHeader DH ON DH.intLoadHeaderId = TL.intLoadHeaderId
	LEFT JOIN tblTRLoadDistributionDetail DD ON DD.intLoadDistributionHeaderId = DH.intLoadDistributionHeaderId
	WHERE TL.intLoadHeaderId = @intLoadHeaderId

	WHILE EXISTS (SELECT TOP 1 1 FROM #DistributionDetailTable)
	BEGIN
		SELECT TOP 1 @intLoadDistributionHeaderId = DD.intLoadDistributionHeaderId
			, @intLoadDistributionDetailId = DD.intLoadDistributionDetailId
			, @intDistributionItemId = DD.intItemId
			, @dblUnits = DD.dblUnits
			, @dblPrice = DD.dblPrice
			, @dblFreight = DD.dblFreight
			, @dblSurcharge = DD.dblSurcharge
		FROM #DistributionDetailTable DD
		WHERE intLoadHeaderId = @intLoadHeaderId
		
		SELECT @strDestination = DH.strDestination
			, @intEntityCustomerId = DH.intEntityCustomerId
			, @intEntitySalespersonId = DH.intEntitySalespersonId
			, @intShipToLocationId = DH.intShipToLocationId
			, @intCompanyLocationId = DH.intCompanyLocationId
			, @dtmInvoiceDateTime = DH.dtmInvoiceDateTime
		FROM #DistributionHeaderTable DH
		WHERE DH.intLoadDistributionHeaderId = @intLoadDistributionHeaderId
			AND intLoadHeaderId = @intLoadHeaderId
		
		IF (@strDestination IS NULL)
		BEGIN
			RAISERROR('Destination is invalid', 16, 1)
		END
		IF (@strDestination = 'Customer')
		BEGIN
			IF(@intEntityCustomerId IS NULL)
			BEGIN
				RAISERROR('Customer is invalid', 16, 1)
			END
			IF(@intEntitySalespersonId IS NULL)
			BEGIN
				RAISERROR('Salesperson is invalid', 16, 1)
			END
			IF (@intShipToLocationId IS NULL)
			BEGIN
				RAISERROR('Ship To is invalid', 16, 1)
			END
			IF (ISNULL(@dblFreight, 0) > 0 AND ISNULL(@intFreightItemId, '') = '')
			BEGIN
				RAISERROR('Freight Item not found. Please setup in Company Configuration', 16, 1)
			END
			IF (ISNULL(@dblSurcharge, 0) > 0 AND ISNULL(@intSurchargeItemId, '') = '')
			BEGIN
				RAISERROR('Surcharge Item not found. Please setup in Company Configuration', 16, 1)
			END
		END
		IF (@intCompanyLocationId IS NULL)
		BEGIN
			RAISERROR('Location is invalid', 16, 1)
		END
		IF (ISDATE(@dtmInvoiceDateTime) = 0)
		BEGIN
			RAISERROR('Invoice Date is invalid', 16, 1)
		END
		IF (@intDistributionItemId IS NULL)
		BEGIN
			RAISERROR('Distribution Item is invalid', 16, 1)
		END
		
		SELECT @intStockUOMId = intIssueUOMId
			, @strItem = strItemNo
			, @strItemLocation = strLocationName
		FROM vyuICGetItemStock
		WHERE intItemId = @intDistributionItemId
			AND intLocationId = @intCompanyLocationId
		
		IF (@intStockUOMId IS NULL)
		BEGIN
			SET @err = 'Default Issue UOM is not setup for item ' + @strItem + ' under location ' + @strItemLocation
			RAISERROR(@err , 16, 1)
		END
		IF (ISNULL(@dblUnits, 0) = 0)
		BEGIN
			RAISERROR('Distribution Units cannot be 0', 16, 1)
		END
		
		DELETE FROM #DistributionDetailTable WHERE intLoadDistributionDetailId = @intLoadDistributionDetailId
	END
	
	SELECT intLoadReceiptId
		, intInventoryReceiptId
	INTO #ReceiptDeleteTable
	FROM tblTRLoadReceipt TR
	JOIN vyuICGetItemStock IC ON TR.intItemId = IC.intItemId
		AND TR.intCompanyLocationId = IC.intLocationId
	WHERE (IC.strType = 'Non-Inventory' 
		OR (TR.strOrigin ='Terminal'
			AND (TR.dblUnitCost = 0
				AND TR.dblFreightRate = 0
				AND TR.dblPurSurcharge = 0)))
		AND ISNULL(intInventoryReceiptId, 0) <> 0
		AND intLoadHeaderId = @intLoadHeaderId
	UNION ALL
	SELECT intLoadReceiptId
		, intInventoryReceiptId
	FROM tblTRLoadReceipt TR
	WHERE TR.strOrigin = 'Location'
		AND ISNULL(intInventoryReceiptId, 0) <> 0
		AND intLoadHeaderId = @intLoadHeaderId
		
	SELECT intLoadReceiptId
		, intInventoryTransferId
	INTO #TransferDeleteTable
	FROM tblTRLoadReceipt TR
	JOIN vyuICGetItemStock IC ON TR.intItemId = IC.intItemId
		AND TR.intCompanyLocationId = IC.intLocationId
	WHERE (IC.strType = 'Non-Inventory' 
		OR (TR.strOrigin ='Terminal'
			AND (TR.dblUnitCost = 0
				AND TR.dblFreightRate = 0
				AND TR.dblPurSurcharge = 0)))
		AND ISNULL(intInventoryTransferId,0) <> 0
		AND intLoadHeaderId = @intLoadHeaderId
	UNION ALL
	SELECT intLoadReceiptId
		,TR.intInventoryTransferId
	FROM tblTRLoadDistributionHeader DH
	JOIN tblTRLoadDistributionDetail DD ON DH.intLoadDistributionHeaderId = DD.intLoadDistributionHeaderId
	JOIN tblTRLoadReceipt TR ON TR.intLoadHeaderId = DH.intLoadHeaderId
		AND TR.strReceiptLine IN (SELECT Item FROM dbo.fnTRSplit(DD.strReceiptLink,','))
	WHERE ((TR.strOrigin = 'Terminal'
		AND DH.strDestination = 'Location'
		AND TR.intCompanyLocationId = DH.intCompanyLocationId)
		OR (TR.strOrigin = 'Location' AND DH.strDestination = 'Customer' AND TR.intCompanyLocationId = DH.intCompanyLocationId)
		OR (TR.strOrigin = 'Terminal' AND DH.strDestination = 'Customer' AND TR.intCompanyLocationId = DH.intCompanyLocationId))
		AND ISNULL(TR.intInventoryTransferId,0) != 0 AND DH.intLoadHeaderId = @intLoadHeaderId

	SELECT intLoadDistributionHeaderId
		, intInvoiceId
	INTO #InvoiceDeleteTable
	FROM tblTRLoadDistributionHeader DH
	WHERE strDestination = 'Location'
		AND ISNULL(intInvoiceId,0) != 0
		AND DH.intLoadHeaderId = @intLoadHeaderId
		
	SELECT TOP 1 @intEntityUserSecurityId = [intEntityId]
	FROM tblSMUserSecurity
	WHERE [intEntityId] = @intUserId
	
	SET @intLoadReceiptId = NULL
	WHILE EXISTS (SELECT TOP 1 1 FROM #ReceiptDeleteTable)
	BEGIN
		SELECT TOP 1 @intLoadReceiptId = intLoadReceiptId
			, @intInventoryReceiptId = intInventoryReceiptId
		FROM #ReceiptDeleteTable
		
		UPDATE tblTRLoadReceipt
		SET intInventoryReceiptId = NULL
		WHERE intLoadReceiptId = @intLoadReceiptId
		
		EXEC uspICDeleteInventoryReceipt @intInventoryReceiptId, @intEntityUserSecurityId
		
		DELETE FROM #ReceiptDeleteTable WHERE intLoadReceiptId = @intLoadReceiptId
	END
	
	WHILE EXISTS (SELECT TOP 1 1 FROM #TransferDeleteTable)
	BEGIN
		SELECT TOP 1 @intLoadReceiptId = intLoadReceiptId
			, @intInventoryTransferId = intInventoryTransferId
		FROM #TransferDeleteTable
		
		UPDATE tblTRLoadReceipt
		set intInventoryTransferId = NULL
		where intLoadReceiptId = @intLoadReceiptId
		
		EXEC uspICDeleteInventoryTransfer @intInventoryTransferId, @intEntityUserSecurityId
		
		DELETE FROM #TransferDeleteTable WHERE intLoadReceiptId = @intLoadReceiptId
	END
	
	WHILE EXISTS (SELECT TOP 1 1 FROM #InvoiceDeleteTable)
	BEGIN
		SELECT TOP 1 @intLoadDistributionHeaderId = intLoadDistributionHeaderId
			, @intInvoiceId = intInvoiceId
		FROM #InvoiceDeleteTable
		
		UPDATE tblTRLoadDistributionHeader
		SET intInvoiceId = NULL
		WHERE intLoadDistributionHeaderId = @intLoadDistributionHeaderId

	   EXEC uspARDeleteInvoice @intInvoiceId,@intUserId

	   DELETE FROM #InvoiceDeleteTable WHERE intLoadDistributionHeaderId = @intLoadDistributionHeaderId
	END

	DROP TABLE #ReceiptList
	DROP TABLE #DistributionHeaderTable
	DROP TABLE #DistributionDetailTable
	DROP TABLE #ReceiptDeleteTable
	DROP TABLE #TransferDeleteTable
	DROP TABLE #InvoiceDeleteTable

END TRY
BEGIN CATCH
	SELECT 
		@ErrorMessage = ERROR_MESSAGE(),
		@ErrorSeverity = ERROR_SEVERITY(),
		@ErrorState = ERROR_STATE();

	-- Use RAISERROR inside the CATCH block to return error
	-- information about the original error that caused
	-- execution to jump to the CATCH block.
	RAISERROR (
		@ErrorMessage, -- Message text.
		@ErrorSeverity, -- Severity.
		@ErrorState -- State.
	);
END CATCH