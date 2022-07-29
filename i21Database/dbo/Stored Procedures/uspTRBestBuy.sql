CREATE PROCEDURE [dbo].[uspTRBestBuy]
	@intCustomerId INT,
	@intCustomerLocationId INT,
	@strItemId NVARCHAR(500),
	@intShipViaId INT,
	@dtmTransactionDate DATETIME = NULL
AS
BEGIN
	
	DECLARE @tblBestBuy TABLE(intBestBuyDetail INT NOT NULL IDENTITY,
		intItemId INT NOT NULL,
		intSupplierId INT NOT NULL,
		strSupplierEntityNo NVARCHAR(100),
		strSupplierName NVARCHAR(200),
		intSupplyPointId INT NOT NULL,
		intEntityLocationId INT NOT NULL,
		strSupplyPointName NVARCHAR(200),
		strSupplypointZipCode NVARCHAR(50) NULL, 
		intContractDetailId INT NULL,
		strContractNumber NVARCHAR(200),
		intContractSeq INT NULL,
		dblBudgetedAllocation NUMERIC(18,6) NULL, /* Contract Quantity */
		dblActualAllocation NUMERIC(18,6) NULL, /* Scheduled Qty */
		dblRemainingAllocation NUMERIC(18,6) NULL,  /* Available Qty */
		dtmEffectiveDate DATETIME NOT NULL,
		dblCostPrice NUMERIC(18,6) NULL,
		dblFreightIn NUMERIC(18,6) NULL,
		dblTotalCostPrice NUMERIC(18,6) NULL,
		dblSellPrice NUMERIC(18,6) NULL,
		dblFreightOut NUMERIC(18,6) NULL,
		dblTotalSellPrice NUMERIC(18,6) NULL,
		dblMargin NUMERIC(18,6) NULL
	)

	IF(@dtmTransactionDate IS NULL) SET @dtmTransactionDate = GETDATE()

	DECLARE @strItemValue NVARCHAR(100) = NULL

	DECLARE @CursorItem AS CURSOR
	SET @CursorItem = CURSOR FOR
		SELECT Item FROM fnTRSplit(@strItemId, ',')

	OPEN @CursorItem
	FETCH NEXT FROM @CursorItem INTO @strItemValue
	WHILE @@FETCH_STATUS = 0
	BEGIN
		DECLARE @intItemId INT = CONVERT(int, @strItemValue)

		DECLARE @dblPrice NUMERIC(18,6) = NULL
		-- AR PRICING
		EXEC uspARGetItemPrice @ItemId = @intItemId, 
			@CustomerId = @intCustomerId, 
			@LocationId = @intCustomerLocationId,  
			@ItemUOMId = NULL,  
			@TransactionDate = @dtmTransactionDate,
			@Quantity = 0,
			@Price = @dblPrice OUT

		-- RACK PRICE
		DECLARE @intSupplyPointId INT = NULL,
			@intVendorId INT = NULL,
			@strZipCode NVARCHAR(50) = NULL,
			@strVendorName NVARCHAR(500) = NULL,
			@strVendorEntityNo NVARCHAR(100) = NULL,
			@strLocationName NVARCHAR(500) = NULL,
			@intEntityLocationId INT = NULL

		-- SUPPLY POINT ALLOCATION
		DECLARE @intContractDetailId INT = NULL,
			@strContractNumber NVARCHAR(50) = NULL,
			@intContractSeq INT = NULL,
			@dblBudgetedAllocation NUMERIC(18,6) = 0,
			@dblActualAllocation NUMERIC(18,6) = 0,
			@dblRemainingAllocation NUMERIC(18,6) = 0
		
		DECLARE @CursorSupplyPoint AS CURSOR
		SET @CursorSupplyPoint = CURSOR FOR
			SELECT SP.intSupplyPointId, V.intEntityId, EL.strZipCode, EL.strLocationName, E.strName, E.strEntityNo, SP.intEntityLocationId
			FROM tblTRSupplyPoint SP 
			INNER JOIN tblEMEntityLocation EL ON EL.intEntityLocationId = SP.intEntityLocationId
			INNER JOIN tblAPVendor V ON V.intEntityId = EL.intEntityId
			INNER JOIN tblEMEntity E ON E.intEntityId = V.intEntityId
			WHERE V.ysnTransportTerminal = 1

		OPEN @CursorSupplyPoint
		FETCH NEXT FROM @CursorSupplyPoint INTO @intSupplyPointId, @intVendorId, @strZipCode, @strLocationName, @strVendorName, @strVendorEntityNo, @intEntityLocationId
		WHILE @@FETCH_STATUS = 0
		BEGIN
			DECLARE @dblRackPrice NUMERIC(18,6) = NULL,
			@dblInvoiceFreightRate NUMERIC(18,6) = NULL,
			@dblReceiptFreightRate NUMERIC(18,6) = NULL,
			@dblReceiptSurchargeRate NUMERIC(18,6) = NULL,
			@dblInvoiceSurchargeRate NUMERIC(18,6) = NULL,
			@ysnFreightInPrice BIT = NULL,
			@ysnFreightOnly BIT = NULL,
			@dblMinimumUnitsIn NUMERIC(18,6) = NULL,
			@dblMinimumUnitsOut NUMERIC(18,6) = NULL

			-- RACK PRICE
			EXEC uspTRGetRackPrice @dtmEffectiveDateTime = @dtmTransactionDate, 
				@dblAdjustment = 0, 
				@intSupplyPointId = @intSupplyPointId, 
				@intItemId = @intItemId, 
				@dblIndexPrice = @dblRackPrice OUT

			-- SUPPLY POINT ALLOCATION
			SELECT 
			    @intContractDetailId = intContractDetailId,
				@strContractNumber = strContractNumber,
				@intContractSeq = intContractSeq,
				@dblBudgetedAllocation = ISNULL(dblScheduleQty, 0),
				@dblActualAllocation = ISNULL(dblBalance, 0) + ISNULL(dblAppliedQty, 0),
				@dblRemainingAllocation = ISNULL(dblAvailableQty, 0)
			FROM dbo.fnLGGetSupplyPointContractData(@intVendorId, @intEntityLocationId, @intItemId, @dtmTransactionDate, NULL)

			-- CUSTOMER FREIGHT
			EXEC uspTRGetCustomerFreight @intEntityCustomerId = @intCustomerId, 
				@intItemId = @intItemId, 
				@strZipCode = @strZipCode, 
				@intShipViaId = @intShipViaId, 
				@intShipToId = @intCustomerLocationId, 
				@dblReceiptGallons = NULL, 
				@dblInvoiceGallons = NULL, 
				@dtmReceiptDate = @dtmTransactionDate, 
				@dtmInvoiceDate = @dtmTransactionDate,
				@ysnToBulkPlant = 0, 
				@dblInvoiceFreightRate = @dblInvoiceFreightRate OUT,
				@dblReceiptFreightRate = @dblReceiptFreightRate OUT,
				@dblReceiptSurchargeRate = @dblReceiptSurchargeRate OUT,
				@dblInvoiceSurchargeRate = @dblInvoiceSurchargeRate OUT,
				@ysnFreightInPrice = @ysnFreightInPrice OUT,
				@ysnFreightOnly = @ysnFreightOnly OUT,
				@dblMinimumUnitsIn = @dblMinimumUnitsIn OUT,
				@dblMinimumUnitsOut = @dblMinimumUnitsOut OUT

			DECLARE @dblTotalCostPrice NUMERIC(18,6) = NULL
			SET @dblTotalCostPrice = (@dblRackPrice * ISNULL(@dblReceiptFreightRate, 0)) + @dblRackPrice

			INSERT INTO @tblBestBuy (intItemId, 
				dtmEffectiveDate, 
				intSupplierId, 
				intSupplyPointId, 
				intEntityLocationId,
				strSupplierEntityNo, 
				strSupplierName, 
				strSupplyPointName, 
				strSupplypointZipCode, 
				intContractDetailId,
				strContractNumber,
				intContractSeq,
				dblBudgetedAllocation,
				dblActualAllocation,
				dblRemainingAllocation,
				dblCostPrice, 
				dblFreightIn, 
				dblFreightOut, 
				dblTotalCostPrice) 
			VALUES (@intItemId, 
				@dtmTransactionDate, 
				@intVendorId, 
				@intSupplyPointId, 
				@intEntityLocationId,
				@strVendorEntityNo, 
				@strVendorName, 
				@strLocationName, 
				@strZipCode, 
				@intContractDetailId,
				@strContractNumber,
				@intContractSeq,
				@dblBudgetedAllocation,
				@dblActualAllocation,
				@dblRemainingAllocation,
				@dblRackPrice, 
				@dblRackPrice * ISNULL(@dblReceiptFreightRate, 0), 
				@dblInvoiceFreightRate, 
				@dblTotalCostPrice)

			FETCH NEXT FROM @CursorSupplyPoint INTO @intSupplyPointId, @intVendorId, @strZipCode, @strLocationName, @strVendorName, @strVendorEntityNo, @intEntityLocationId
		END
		CLOSE @CursorSupplyPoint
		DEALLOCATE @CursorSupplyPoint

		UPDATE @tblBestBuy SET dblSellPrice = @dblPrice,
			dblFreightOut = @dblPrice * ISNULL(dblFreightOut, 0),
			dblTotalSellPrice =  @dblPrice + (@dblPrice * ISNULL(dblFreightOut, 0)),
			dblTotalCostPrice =  dblCostPrice + dblFreightIn
		WHERE intItemId = @intItemId
		
		FETCH NEXT FROM @CursorItem INTO @strItemValue
	END
	CLOSE @CursorItem
	DEALLOCATE @CursorItem
	--intContractDetailId,
	--dblBudgetedAllocation,
	--dblActualAllocation,
	--dblRemainingAllocation,

	SELECT intSupplierId,
			strSupplierEntityNo,
			strSupplierName,
			intSupplyPointId,
			intEntityLocationId,
			strSupplyPointName,
			strSupplypointZipCode, 
			intContractDetailId,
			strContractNumber,
			intContractSeq,
			dblBudgetedAllocation,
			dblActualAllocation,
			dblRemainingAllocation,
			dtmEffectiveDate,
			dblCostPrice,
			dblFreightIn,
			dblTotalCostPrice,
			dblSellPrice,
			dblFreightOut,
			dblTotalSellPrice,
			dblMargin = dblTotalSellPrice - dblTotalCostPrice,
			intCustomerId = @intCustomerId,
			intCustomerLocationId = @intCustomerLocationId,
			intShipViaId = @intShipViaId
	FROM (
		SELECT intSupplierId,
			strSupplierEntityNo,
			strSupplierName,
			intSupplyPointId,
			intEntityLocationId,
			strSupplyPointName,
			strSupplypointZipCode, 
			intContractDetailId,
			strContractNumber,
			intContractSeq,
			dblBudgetedAllocation,
			dblActualAllocation,
			dblRemainingAllocation,
			dtmEffectiveDate,
			SUM(dblCostPrice) dblCostPrice,
			SUM(dblFreightIn) dblFreightIn,
			SUM(dblTotalCostPrice) dblTotalCostPrice,
			SUM(dblSellPrice) dblSellPrice,
			SUM(dblFreightOut) dblFreightOut,
			SUM(dblTotalSellPrice) dblTotalSellPrice
		FROM @tblBestBuy
		GROUP BY intSupplierId,
			strSupplierEntityNo,
			strSupplierName,
			intSupplyPointId,
			intEntityLocationId,
			strSupplyPointName,
			strSupplypointZipCode,
			intContractDetailId,
			strContractNumber,
			intContractSeq,
			dblBudgetedAllocation,
			dblActualAllocation,
			dblRemainingAllocation,
			dtmEffectiveDate
	) A


END