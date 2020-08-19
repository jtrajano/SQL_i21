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
		, @ReceiptLink NVARCHAR(50)
		, @BlendedItem BIT = 0
		, @dblNonBlendedDistributedQuantity DECIMAL(18, 6) = 0
		, @strFreightCostMethod NVARCHAR(20) = NULL
		, @strFreightBilledBy NVARCHAR(30) = NULL
	
	SELECT @dtmLoadDateTime = TL.dtmLoadDateTime
		, @intShipVia = TL.intShipViaId
		, @intSeller = TL.intSellerId
		, @intDriver = TL.intDriverId
		, @intFreightItemId = TL.intFreightItemId
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

	IF NOT EXISTS(SELECT TOP 1 1 FROM tblAPVendor WHERE intEntityId = @intShipVia)
	BEGIN
		RAISERROR('Please set the Ship Via as a Vendor.', 16, 1)
	END

	SELECT TOP 1 @intSurchargeItemId = intItemId FROM vyuICGetOtherCharges WHERE intOnCostTypeId = @intFreightItemId
	SELECT TOP 1 @ysnItemizeSurcharge = ISNULL(ysnItemizeSurcharge, 0) FROM tblTRCompanyPreference
	SELECT @strFreightBilledBy = strFreightBilledBy FROM tblSMShipVia where intEntityId = @intShipVia

	--IF (NOT EXISTS(SELECT TOP 1 1 FROM vyuICGetOtherCharges WHERE intItemId = @intSurchargeItemId AND intOnCostTypeId = @intFreightItemId) AND @intSurchargeItemId IS NOT NULL)
	--BEGIN
	--	RAISERROR(@MsgSurcharge, 16, 1)
	--END
	--IF (ISNULL(@intSurchargeItemId, '') <> '')
	--BEGIN
	--END

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
			, @strDescription = REPLACE(strDescription, '%', '')
		FROM vyuICGetItemStock
		WHERE intItemId = @intItemId
			AND intLocationId = @intCompanyLocation

		IF(@strFreightBilledBy = 'Other' AND (@dblFreight > 0 OR @dblSurcharge > 0))
		BEGIN
			IF NOT EXISTS(SELECT TOP 1 1 FROM tblAPVendor WHERE intEntityId = @intShipVia)
			BEGIN
				RAISERROR('Please set the Ship Via as a Vendor.', 16, 1)
			END
		END

		IF (ISNULL(@dblFreight, 0) > 0 AND ISNULL(@intFreightItemId, '') = '')
		BEGIN
				RAISERROR('Freight Item not found. Please setup in Company Configuration', 16, 1)
		END
		ELSE IF (ISNULL(@dblFreight, 0) > 0  AND ISNULL(@intFreightItemId, '') != '')
		BEGIN
			IF (ISNULL(@dblSurcharge, 0) > 0 AND ISNULL(@intSurchargeItemId, '') = '')
			BEGIN
				RAISERROR('Transports Load has a Surcharge. You must link the Surcharge Item to the Freight Item (using the On Cost dropdown from the Surcharge Item''s Setup tab > Cost tab), or zero-out the Surcharge amount in both Receipt and Distribution Detail.', 16, 1)
			END

			SELECT TOP 1 @strFreightCostMethod = strCostMethod FROM tblICItem WHERE intItemId = @intFreightItemId
			IF(ISNULL(@strFreightCostMethod, '') = '')
			BEGIN
				RAISERROR('Cost UOM is invalid. Make sure Item screen > Setup tab > Cost tab > Cost Method field is setup properly.', 16, 1)
			END
		END
		
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
				RAISERROR('Cannot find a valid Supply Point. If this TR Load is created from a Load Schedule, check the originating Load Scheudule''s Vendor and Vendor Location.', 16, 1)
			END
			IF (@intCompanyLocation IS NULL)
			BEGIN
				RAISERROR('Invalid Bulk Location', 16, 1)
			END
			
			IF (@intItemId IS NULL)
			BEGIN
				RAISERROR('Invalid Purchase Item', 16, 1)
			END
		
			--IF (ISNULL(@dblSurcharge, 0) > 0 AND ISNULL(@intSurchargeItemId, '') = '')
			--BEGIN
			--	IF ISNULL(@intSurchargeItemId, '') = ''
			--		SET @err = ' Surcharge Item is null. Please setup the on cost.'
			--	ELSE
			--		SET @err = CAST(@intSurchargeItemId AS NVARCHAR(10)) + ' Surcharge Item not found. Please setup in Company Configuration'

			--	RAISERROR(@err, 16, 1)
			--END
			
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

		IF EXISTS (SELECT TOP 1 1 FROM tblTRLoadReceipt TR
		LEFT JOIN tblTRLoadHeader TL ON TL.intLoadHeaderId = TR.intLoadHeaderId
		WHERE strBillOfLading = @strBOL
			AND TL.intLoadHeaderId != @intLoadHeaderId
			AND intTerminalId = @intTerminal
			AND TL.dtmLoadDateTime = @dtmLoadDateTime)
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

		-- Blend Item Active Check
		SELECT DISTINCT Recipe.intRecipeId, Recipe.strRecipeItemNo, Recipe.strLocationName
		INTO #tmpInactiveRecipe
		FROM tblTRLoadBlendIngredient BlendIngredient
		LEFT JOIN tblTRLoadDistributionDetail DistDetail ON DistDetail.intLoadDistributionDetailId = BlendIngredient.intLoadDistributionDetailId
		LEFT JOIN tblTRLoadDistributionHeader HeaderDistItem ON HeaderDistItem.intLoadDistributionHeaderId = DistDetail.intLoadDistributionHeaderId
		LEFT JOIN vyuMFGetRecipeItem Recipe ON Recipe.intRecipeItemId = BlendIngredient.intRecipeItemId
		WHERE HeaderDistItem.intLoadHeaderId = @intLoadHeaderId
			AND Recipe.ysnActive = 0

		IF EXISTS (SELECT TOP 1 1 FROM #tmpInactiveRecipe)
		BEGIN
			SELECT TOP 1 @strItem = strRecipeItemNo, @strItemLocation = strLocationName FROM #tmpInactiveRecipe

			SET @strresult = 'Recipe ' + @strItem + ' from location ' + @strItemLocation + ' is not set to active.'
			RAISERROR(@strresult, 16, 1)
		END

		DROP TABLE #tmpInactiveRecipe

		-- Blend Item Quantity Check
		SELECT BlendIngredient.intIngredientItemId
			, dblQuantity = SUM(BlendIngredient.dblQuantity)
			, ysnBlended = 1
		INTO #tmpBlendDistributionItems
		FROM vyuTRGetLoadBlendIngredient BlendIngredient
		LEFT JOIN tblMFRecipe Recipe ON Recipe.intRecipeId = BlendIngredient.intRecipeId
		LEFT JOIN tblTRLoadDistributionHeader HeaderDistItem ON HeaderDistItem.intLoadDistributionHeaderId = BlendIngredient.intLoadDistributionHeaderId
		WHERE HeaderDistItem.intLoadHeaderId = @intLoadHeaderId
			AND Recipe.ysnActive = 1
			AND BlendIngredient.intIngredientItemId = @intItemId
		GROUP BY BlendIngredient.intIngredientItemId

		UNION ALL 

		SELECT Detail.intItemId
			, Detail.dblUnits
			, Detail.ysnBlendedItem
		FROM tblTRLoadDistributionDetail Detail
		LEFT JOIN tblTRLoadDistributionHeader Header ON Header.intLoadDistributionHeaderId = Detail.intLoadDistributionHeaderId
		WHERE Detail.intLoadDistributionDetailId NOT IN (SELECT DISTINCT intLoadDistributionDetailId FROM vyuTRGetLoadBlendIngredient)
			AND Header.intLoadHeaderId = @intLoadHeaderId
			AND Detail.intItemId = @intItemId

		UNION ALL 

		SELECT BlendIngredient.intSubstituteItemId
			, dblQuantity = SUM(BlendIngredient.dblQuantity)
			, ysnBlended = 1
		FROM vyuTRGetLoadBlendIngredient BlendIngredient
		LEFT JOIN tblMFRecipe Recipe ON Recipe.intRecipeId = BlendIngredient.intRecipeId
		LEFT JOIN tblTRLoadDistributionHeader HeaderDistItem ON HeaderDistItem.intLoadDistributionHeaderId = BlendIngredient.intLoadDistributionHeaderId
		WHERE HeaderDistItem.intLoadHeaderId = @intLoadHeaderId
			AND Recipe.ysnActive = 1
			AND BlendIngredient.intSubstituteItemId = @intItemId
		GROUP BY BlendIngredient.intSubstituteItemId

		IF EXISTS (SELECT TOP 1 1 FROM #tmpBlendDistributionItems WHERE ysnBlended = 1)
		BEGIN
			SELECT @dblDistributedQuantity = SUM(dblQuantity) FROM #tmpBlendDistributionItems
			
			IF (@dblReceivedQuantity != @dblDistributedQuantity)
			BEGIN
				SET @strresult = 'Raw Materials ' + @strDescription + ' received quantity ' + LTRIM(@dblReceivedQuantity)  + ' does not match required quantity ' + LTRIM(@dblDistributedQuantity) + '.'
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
		, DD.strReceiptLink
		, DD.ysnBlendedItem
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
			, @ReceiptLink = DD.strReceiptLink
			, @BlendedItem = DD.ysnBlendedItem
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
			ELSE IF (ISNULL(@dblFreight, 0) = 0  AND ISNULL(@intFreightItemId, '') != '')
			BEGIN
				IF (ISNULL(@dblSurcharge, 0) > 0 )
				BEGIN
					RAISERROR('Transports Load has a Surcharge. You must input the Freight rate or zero-out the Surcharge in both Receipt and Distribution Detail.', 16, 1)
					--RAISERROR('Transport load has surcharge. You must input freight rate or zero out the surcharge.', 16, 1)
				END
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
		IF (@BlendedItem = 0 AND ISNULL(@ReceiptLink, '') = '')
		BEGIN
			IF NOT EXISTS (SELECT TOP 1 1 FROM tblICItem WHERE intItemId = @intDistributionItemId AND strType IN ('Service', 'Other Charge', 'Non-Inventory'))
			BEGIN
				RAISERROR('Receipt Link can only be blank for Blended, Service, Other Charge, and Non-Inventory items', 16, 1)
			END
		END
		ELSE IF (@BlendedItem = 1)
		BEGIN
			IF EXISTS(SELECT TOP 1 1 FROM tblTRLoadBlendIngredient WHERE intLoadDistributionDetailId = @intLoadDistributionDetailId AND ISNULL(strReceiptLink, '') = '')
			BEGIN
				RAISERROR('Receipt Link is required for Auto Blend raw materials', 16, 1)
			END
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

	-- Validate the BOL of Receipt and Distribution
	IF EXISTS(SELECT TOP 1 1 FROM tblTRLoadHeader LH
		INNER JOIN tblTRLoadReceipt LR ON LR.intLoadHeaderId = LH.intLoadHeaderId
		INNER JOIN tblTRLoadDistributionHeader DH ON DH.intLoadHeaderId = LH.intLoadHeaderId
		INNER JOIN tblTRLoadDistributionDetail DD ON DD.intLoadDistributionHeaderId = DH.intLoadDistributionHeaderId AND DD.strReceiptLink = LR.strReceiptLine
		WHERE LH.intLoadHeaderId = @intLoadHeaderId
	AND LR.strBillOfLading != DD.strBillOfLading
	AND DD.ysnBlendedItem = 0)
	BEGIN
		RAISERROR('BOL of Receipt and Distribution should be the same!', 16, 1)
	END

	-- Validate Zero values -- TR-730 & TR-909
	SELECT DISTINCT strOrigin = CASE WHEN ISNULL(TR.intLoadReceiptId, '') != '' THEN TR.strOrigin ELSE BlendIngredient.strOrigin END
		, dblCost = CASE WHEN ISNULL(TR.intLoadReceiptId, '') != '' THEN TR.dblUnitCost ELSE BlendIngredient.dblUnitCost END
		, dblFreight = CASE WHEN ISNULL(TR.intLoadReceiptId, '') != '' THEN TR.dblFreightRate ELSE BlendIngredient.dblFreightRate END
		, dblSurcharge = CASE WHEN ISNULL(TR.intLoadReceiptId, '') != '' THEN TR.dblPurSurcharge ELSE BlendIngredient.dblPurSurcharge END
		, DD.intItemId
		, strDestination = DH.strDestination
		, dblPrice = DD.dblPrice
		, dblDistFreight = DD.dblFreightRate
		, dblDistSurcharge
		, ysnFreightOnly = ISNULL(CustomerFreight.ysnFreightOnly, 0)
		, strReceiptLink = CASE WHEN ISNULL(TR.intLoadReceiptId, '') != '' THEN TR.strReceiptLine ELSE BlendIngredient.strReceiptLink END
	INTO #tmpDistributionList
	FROM tblTRLoadHeader TL
	LEFT JOIN tblTRLoadDistributionHeader DH ON DH.intLoadHeaderId = TL.intLoadHeaderId
	LEFT JOIN tblARCustomer Customer ON Customer.intEntityId = DH.intEntityCustomerId
	LEFT JOIN tblEMEntityLocation EL ON EL.intEntityLocationId = DH.intShipToLocationId
	LEFT JOIN tblTRLoadDistributionDetail DD ON DD.intLoadDistributionHeaderId = DH.intLoadDistributionHeaderId
	LEFT JOIN tblICItem Item ON Item.intItemId = DD.intItemId
	LEFT JOIN vyuICGetItemStock IC ON IC.intItemId = DD.intItemId AND IC.intLocationId = DH.intCompanyLocationId
	LEFT JOIN vyuTRGetLoadReceipt TR ON TR.intLoadHeaderId = TL.intLoadHeaderId AND TR.strReceiptLine = DD.strReceiptLink
	LEFT JOIN (
		SELECT DistItem.intLoadDistributionDetailId
			, HeaderDistItem.intLoadDistributionHeaderId
			, BlendIngredient.strReceiptLink
			, Receipt.strOrigin
			, Receipt.dblUnitCost
			, Receipt.dblFreightRate
			, Receipt.dblPurSurcharge
			, Receipt.strZipCode
		FROM tblTRLoadDistributionDetail DistItem
		LEFT JOIN tblTRLoadDistributionHeader HeaderDistItem ON HeaderDistItem.intLoadDistributionHeaderId = DistItem.intLoadDistributionHeaderId
		LEFT JOIN tblTRLoadHeader LoadHeader ON LoadHeader.intLoadHeaderId = HeaderDistItem.intLoadHeaderId
		LEFT JOIN vyuTRGetLoadBlendIngredient BlendIngredient ON BlendIngredient.intLoadDistributionDetailId = DistItem.intLoadDistributionDetailId
		LEFT JOIN vyuTRGetLoadReceipt Receipt ON Receipt.intLoadHeaderId = LoadHeader.intLoadHeaderId AND Receipt.intItemId = BlendIngredient.intIngredientItemId
		WHERE ISNULL(DistItem.strReceiptLink, '') = ''
	) BlendIngredient ON BlendIngredient.intLoadDistributionHeaderId = DH.intLoadDistributionHeaderId
	LEFT JOIN tblARCustomerFreightXRef CustomerFreight ON CustomerFreight.intEntityCustomerId = DH.intEntityCustomerId
			AND CustomerFreight.intEntityLocationId = DH.intShipToLocationId
			AND CustomerFreight.intCategoryId = Item.intCategoryId
			AND CustomerFreight.strZipCode = ISNULL(TR.strZipCode, BlendIngredient.strZipCode)
	WHERE (ISNULL(TR.strOrigin, '') != '' OR ISNULL(BlendIngredient.strOrigin, '') != '')
		AND TL.intLoadHeaderId = @intLoadHeaderId

	DECLARE @errMessage NVARCHAR(250)
		, @strLink NVARCHAR(10)
	
	SELECT TOP 1 @strLink = ISNULL(strReceiptLink, '') FROM #tmpDistributionList WHERE strOrigin = 'Terminal' AND strDestination = 'Customer' AND ISNULL(dblCost, 0) = 0 AND ISNULL(ysnFreightOnly, 0) = 0
	IF ISNULL(@strLink, '') <> ''
	BEGIN
		SET @errMessage = 'Terminal to Customer Load cannot have a cost of zero(0). ' + @strLink + ' has a zero(0) cost.' 
		RAISERROR(@errMessage, 16, 1)
	END

	SELECT TOP 1 @strLink = ISNULL(strReceiptLink, '') FROM #tmpDistributionList WHERE ISNULL(ysnFreightOnly, 0) = 0 AND ISNULL(dblCost, 0) = 0 AND ISNULL(dblPrice, 0) = 0
	IF ISNULL(@strLink, '') <> ''
	BEGIN
		SET @errMessage = 'Cost and Price cannot be zero(0) for Non-Freight-Only Customers. ' + @strLink + ' has a zero(0) cost and price.' 
		RAISERROR(@errMessage, 16, 1)
	END

	SELECT TOP 1 @strLink = ISNULL(strReceiptLink, '') FROM #tmpDistributionList WHERE strOrigin = 'Terminal' AND ISNULL(ysnFreightOnly, 0) = 0 AND ISNULL(dblCost, 0) = 0
	IF ISNULL(@strLink, '') <> ''
	BEGIN
		SET @errMessage = 'Terminal Receipts cannot have a cost of zero(0). ' + @strLink + ' has a zero(0) cost.' 
		RAISERROR(@errMessage, 16, 1)
	END

	SELECT TOP 1 @strLink = ISNULL(strReceiptLink, '') FROM #tmpDistributionList WHERE strDestination = 'Customer' AND ISNULL(ysnFreightOnly, 0) = 0 AND ISNULL(dblPrice, 0) = 0
	IF ISNULL(@strLink, '') <> ''
	BEGIN
		SET @errMessage = 'Customer Distributions cannot have a price of zero(0). ' + @strLink + ' has a zero(0) price.' 
		RAISERROR(@errMessage, 16, 1)
	END
	
	DROP TABLE #tmpDistributionList
	----------------------------------------------------------------------------------------


	-- Validate no transactions at all --
	SELECT TOP 1 LH.strTransaction, LR.strReceiptLine, LR.strOrigin, LDH.strDestination, intReceiptLocationId = LR.intCompanyLocationId, intDistributionLocationId = LDH.intCompanyLocationId
	INTO #tmpNoTrans
	FROM tblTRLoadReceipt LR
	JOIN tblTRLoadHeader LH ON LH.intLoadHeaderId = LR.intLoadHeaderId
	JOIN tblTRLoadDistributionHeader LDH ON LDH.intLoadHeaderId = LH.intLoadHeaderId
	JOIN tblTRLoadDistributionDetail LDD ON LDD.strReceiptLink = LR.strReceiptLine AND LDD.intLoadDistributionHeaderId = LDH.intLoadDistributionHeaderId
	WHERE LR.strOrigin = 'Location'
		AND LDH.strDestination = 'Location'
		AND LR.intCompanyLocationId = LDH.intCompanyLocationId
		AND LH.intLoadHeaderId = @intLoadHeaderId

	DECLARE @ReceiptLine NVARCHAR(50)
	IF EXISTS(SELECT TOP 1 1 FROM #tmpNoTrans)
	BEGIN
		SELECT TOP 1 @ReceiptLine = strReceiptLine FROM #tmpNoTrans

		SET @errMessage = 'Receipt Link ' + @ReceiptLine + ' has no transaction to post. There should atleast be a receipt, an invoice, or a transfer to post.'
		RAISERROR(@errMessage, 16, 1)
	END

	DROP TABLE #tmpNoTrans
	-------------------------------------

	
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
		
	-- SELECT intLoadReceiptId
	-- 	, intInventoryTransferId
	-- INTO #TransferDeleteTable
	-- FROM tblTRLoadReceipt TR
	-- JOIN vyuICGetItemStock IC ON TR.intItemId = IC.intItemId
	-- 	AND TR.intCompanyLocationId = IC.intLocationId
	-- WHERE (IC.strType = 'Non-Inventory' 
	-- 	OR (TR.strOrigin ='Terminal'
	-- 		AND (TR.dblUnitCost = 0
	-- 			AND TR.dblFreightRate = 0
	-- 			AND TR.dblPurSurcharge = 0)))
	-- 	AND ISNULL(intInventoryTransferId,0) <> 0
	-- 	AND intLoadHeaderId = @intLoadHeaderId
	-- UNION ALL
	-- SELECT intLoadReceiptId
	-- 	,TR.intInventoryTransferId
	-- FROM tblTRLoadDistributionHeader DH
	-- JOIN tblTRLoadDistributionDetail DD ON DH.intLoadDistributionHeaderId = DD.intLoadDistributionHeaderId
	-- JOIN tblTRLoadReceipt TR ON TR.intLoadHeaderId = DH.intLoadHeaderId
	-- 	AND TR.strReceiptLine IN (SELECT Item FROM dbo.fnTRSplit(DD.strReceiptLink,','))
	-- WHERE ((TR.strOrigin = 'Terminal'
	-- 	AND DH.strDestination = 'Location'
	-- 	AND TR.intCompanyLocationId = DH.intCompanyLocationId)
	-- 	OR (TR.strOrigin = 'Location' AND DH.strDestination = 'Customer' AND TR.intCompanyLocationId = DH.intCompanyLocationId)
	-- 	OR (TR.strOrigin = 'Terminal' AND DH.strDestination = 'Customer' AND TR.intCompanyLocationId = DH.intCompanyLocationId))
	-- 	AND ISNULL(TR.intInventoryTransferId,0) != 0 AND DH.intLoadHeaderId = @intLoadHeaderId

	SELECT DISTINCT TR.intLoadReceiptId
		,TR.intInventoryTransferId
		,0 AS ysnTran
	INTO #TransferDeleteTable
	FROM tblTRLoadDistributionHeader DH
		JOIN tblTRLoadReceipt TR ON TR.intLoadHeaderId = DH.intLoadHeaderId
 	WHERE TR.intLoadHeaderId = @intLoadHeaderId
	 	AND ISNULL(TR.intInventoryTransferId,0) != 0
		AND ((TR.strOrigin = 'Location' AND DH.strDestination = 'Location') 
			OR (TR.strOrigin = 'Terminal' AND DH.strDestination = 'Location' AND TR.intCompanyLocationId != DH.intCompanyLocationId)
			OR (TR.strOrigin = 'Location' AND DH.strDestination = 'Customer' AND TR.intCompanyLocationId != DH.intCompanyLocationId)
			OR (TR.strOrigin = 'Terminal' AND DH.strDestination = 'Customer' AND TR.intCompanyLocationId != DH.intCompanyLocationId))


	SELECT intLoadDistributionHeaderId
		, intInvoiceId
	INTO #InvoiceDeleteTable
	FROM tblTRLoadDistributionHeader DH
	WHERE strDestination = 'Location'
		AND ISNULL(intInvoiceId,0) != 0
		AND DH.intLoadHeaderId = @intLoadHeaderId
		
	SELECT TOP 1 @intEntityUserSecurityId = intEntityId
	FROM tblSMUserSecurity
	WHERE intEntityId = @intUserId
	
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
	
	-- WHILE EXISTS (SELECT TOP 1 1 FROM #TransferDeleteTable)
	-- BEGIN
	-- 	SELECT TOP 1 @intLoadReceiptId = intLoadReceiptId
	-- 		, @intInventoryTransferId = intInventoryTransferId
	-- 	FROM #TransferDeleteTable
		
	-- 	UPDATE tblTRLoadReceipt
	-- 	set intInventoryTransferId = NULL
	-- 	where intLoadReceiptId = @intLoadReceiptId
		
	-- 	EXEC uspICDeleteInventoryTransfer @intInventoryTransferId, @intEntityUserSecurityId
		
	-- 	DELETE FROM #TransferDeleteTable WHERE intLoadReceiptId = @intLoadReceiptId
	-- END

	WHILE EXISTS (SELECT TOP 1 1 FROM #TransferDeleteTable WHERE ysnTran = 0)
	BEGIN
		SELECT TOP 1 @intLoadReceiptId = intLoadReceiptId
		FROM #TransferDeleteTable WHERE ysnTran = 0
		
		UPDATE tblTRLoadReceipt
		set intInventoryTransferId = NULL
		where intLoadReceiptId = @intLoadReceiptId
	
		UPDATE #TransferDeleteTable SET ysnTran = 1 WHERE intLoadReceiptId = @intLoadReceiptId
	END

	WHILE EXISTS (SELECT TOP 1 1 FROM #TransferDeleteTable WHERE ysnTran = 1)
	BEGIN
		SET @intInventoryTransferId = NULL
		SELECT TOP 1 @intInventoryTransferId = intInventoryTransferId
		FROM #TransferDeleteTable WHERE ysnTran = 1
		
		EXEC uspICDeleteInventoryTransfer @intInventoryTransferId, @intEntityUserSecurityId

		DELETE FROM #TransferDeleteTable WHERE intInventoryTransferId = @intInventoryTransferId
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