CREATE PROCEDURE [dbo].[uspTRProcessTransportLoadFromMbil]
	@MBilLoadHeaderId INT
	,@Process NVARCHAR(50)
	,@ErrorMessage NVARCHAR(MAX) = NULL OUTPUT
	,@NewTransactionNumber NVARCHAR(50) OUTPUT

AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF


DECLARE @ErrorSeverity INT
DECLARE @ErrorState INT

DECLARE	 @h_strLoadNumber  NVARCHAR(50)
		,@h_strType  NVARCHAR(50)
		,@h_intLoadId int
		,@h_intShipVia INT
		,@h_intSeller INT
		,@h_intDriver INT
		,@h_dtmScheduledDate DATETIME
		,@h_intTruckId INT
		,@h_intTrailerId INT
		,@h_intDispatchOrderId INT
		,@h_intItemForFreightId INT
		,@h_ysnDiversion BIT
		,@h_strDiversionNumber NVARCHAR(50)
		,@h_intStateId INT

		,@newLoadHeaderId INT

		,@intRecord INT = 0
		,@h_intSupplyPointId INT 
		,@h_intItemId INT 
		,@h_intReceiptCompanyLocationId INT

SELECT TOP 1 * INTO #config FROM tblTRCompanyPreference

SELECT 
intLoadHeaderId
,strLoadNumber
,strType
,intDispatchOrderId
,intLoadId
,intDriverId
,intShipViaId
,intTruckId
,intTrailerId
,strTrailerNo
,dtmScheduledDate
,intPickupDetailId
,intVendorId
,intVendorLocationId
,intSupplyPointId
,strFreightSalesUnit
,intOutboundTaxGroupId
,intLoadDetailId
,intSalespersonId
,intSellerId
,intTaxGroupId
,intReceiptContractDetailId
,intContractDetailId
,intItemId
,intReceiptCompanyLocationId
,strZipPostalCode
,dblPickupQuantity
,dblGross
,dblNet
,dtmPickupFrom
,dtmPickupTo
,dtmActualPickupFrom
,dtmActualPickupTo
,strBOL
,strItemUOM
,strLoadRefNo
,strNote
,strPONumber
,strRack
,strTerminalRefNo
,ysnPickup
,intDeliveryHeaderId
,intCustomerId
,intCustomerLocationId
,intDistributionCompanyLocationId
,dtmActualDelivery
,intDeliveryDetailId
,intTMDispatchId
,intTMSiteId
,strTank
,dblStickStartReading
,dblStickEndReading
,dblWaterInches
,dblPrice
,dblDeliveredQty
,dblPercentFull
,ysnDelivered
,ysnDiversion
,strDiversionNumber
,intStateId
,intDispatchOrderRouteId
,intDispatchOrderDetailId
,ysnLockPrice
,intItemUOMId
 INTO #mbilloads FROM vyuMBILGetLoads WHERE intLoadHeaderId = @MBilLoadHeaderId

SELECT * INTO #mbilloadheader FROM #mbilloads ORDER BY strType 

SELECT TOP 1 
        @h_strLoadNumber = strLoadNumber
        ,@h_strType = strType
        ,@h_intLoadId = intLoadId
        ,@h_intShipVia = intShipViaId
        ,@h_intSeller = intSellerId
        ,@h_intDriver = intDriverId
        ,@h_dtmScheduledDate = dtmScheduledDate
		,@h_intStateId = intStateId
		,@h_intTruckId = intTruckId
		,@h_intTrailerId = intTrailerId
		,@h_intDispatchOrderId = intDispatchOrderId
		,@h_ysnDiversion = ysnDiversion
		,@h_strDiversionNumber = strDiversionNumber
		,@h_intSupplyPointId = intSupplyPointId
		, @h_intItemId = intItemId
		,@h_intReceiptCompanyLocationId= intReceiptCompanyLocationId
FROM #mbilloadheader WHERE intLoadHeaderId = @MBilLoadHeaderId

DECLARE @ysnTRLoadPosted BIT = NULL
DECLARE @intLoadHeaderId INT = NULL
DECLARE @strLSNumber INT = NULL

	--VALIDATIONS
    IF EXISTS(SELECT 1 FROM #mbilloads)
	BEGIN
		SELECT TOP 1 @ysnTRLoadPosted  = ysnPosted 
			,@intLoadHeaderId = intLoadHeaderId
		FROM tblTRLoadHeader WHERE intMobileLoadHeaderId = @MBilLoadHeaderId

		IF @intLoadHeaderId IS NOT NULL AND @ysnTRLoadPosted = 1
		BEGIN
			SET @ErrorMessage  = 'Transport load already posted! Modifying the data is not allowed.'
			RETURN
		END

		IF EXISTS(SELECT TOP 1 1 FROM tblTRLoadHeader WHERE intLoadId = @h_intLoadId)
		BEGIN
			SET @ErrorMessage  = 'There is already an existing Transport Load associated to ' &  @strLSNumber & '.'
			RETURN
		END
	END

BEGIN TRY

	IF(@intLoadHeaderId IS NULL)
		BEGIN
    
	DECLARE @strTransportNumber NVARCHAR(50)= NULL
	EXEC uspSMGetStartingNumber 54, @strTransportNumber OUT  

	--INSERT
	INSERT INTO tblTRLoadHeader(strTransaction
		, dtmLoadDateTime
		, intShipViaId
		, intSellerId
		, intDriverId
		, strTractor
		, strTrailer
		, ysnDiversion
		, strDiversionNumber
		, intStateId
		, intConcurrencyId
		, intFreightItemId
		, intMobileLoadHeaderId
		, ysnPosted)
	VALUES (@strTransportNumber 
		, @h_dtmScheduledDate
		, @h_intShipVia
		, @h_intSeller
		, @h_intDriver
		, ''--strTractor 
		, ''-- strTrailer
		, @h_ysnDiversion
		, @h_strDiversionNumber
		, @h_intStateId
		, 1
		, (SELECT TOP 1  intItemForFreightId FROM #config)
		, @MBilLoadHeaderId
		, 0)
	SET @newLoadHeaderId = SCOPE_IDENTITY()

	DECLARE @dblIndexPrice AS NUMERIC(38, 20)
	EXEC uspTRGetRackPrice @h_dtmScheduledDate,0,@h_intSupplyPointId,@h_intItemId,@dblIndexPrice out
	IF (@dblIndexPrice = 0)
	BEGIN
		SELECT TOP 1 @dblIndexPrice = dblReceiveLastCost  from vyuICGetItemStock WHERE intItemId = @h_intItemId AND  intLocationId = @h_intReceiptCompanyLocationId	
	END

	--DECLARE @ysnComboFreight AS BIT 
	--SELECT TOP 1  @ysnComboFreight = ysnComboFreight FROM #config != true
        --// Combo Freight 
		--??? questionable lines of codes
		--IF(@ysnComboFreight != 1)
		--BEGIN
		--	dblComboFreightRate = 0;
		--	dblComboMinimumUnits = 0;
		--	ysnComboFreight = false;
		--	dblComboSurcharge = 0;
		--END
 
	SET @intRecord += 1;
		INSERT INTO tblTRLoadReceipt(intLoadHeaderId
		, strOrigin
		, intTerminalId
		, intSupplyPointId
		, intCompanyLocationId
		, strBillOfLading
		, intItemId
		, intContractDetailId
		, intDispatchOrderRouteId
		, dblGross
		, dblNet
		, intTaxGroupId
		, strReceiptLine
		, intLoadDetailId
		, ysnFreightInPrice
		, dblUnitCost
		, dblFreightRate
		, dblPurSurcharge

		--,dblComboFreightRate 
		--,dblComboMinimumUnits
		--,ysnComboFreight 
		--,dblComboSurcharge  

		, intConcurrencyId)
	
		SELECT TOP 1 @newLoadHeaderId
		, CASE WHEN (@h_strType = 'Inbound' OR @h_strType = 'Drop Ship') THEN 'Terminal' ELSE 'Location' END--- depends on type
		, intVendorId
		, intSupplyPointId
		, intReceiptCompanyLocationId
		, ISNULL(strBOL,'') --- Cannot be Null
		, intItemId
		, intContractDetailId
		, intDispatchOrderRouteId
		, dblGross
		, dblNet
		, intTaxGroupId
		, 'RL-' + CONVERt(nvarchar(10) ,@intRecord)
		, NULL --intLoadDetailId
		, 0   --ysnFreightInPrice  ???
		, @dblIndexPrice--0 ----dblUnitCost ---  ReceiptPrice(loadHeader.dtmLoadDateTime.GetValueOrDefault(), 0, load
		, NULL --- dblFreightRate
		, NULL --- dblPurSurcharge

		--,--dblComboFreightRate 
		--,--dblComboMinimumUnits
		--,--ysnComboFreight 
		--,--dblComboSurcharge  
		, 1
		FROM #mbilloads

		SET @NewTransactionNumber = @strTransportNumber
		END
	ELSE
		BEGIN
		--UPDATE
			Return;-- return for now.. as of now will only handle new tr creation in this SP
		END

END TRY	  
                  
--todo
--LOGGING
---uspTRTransportLoadAfterSave

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

GO