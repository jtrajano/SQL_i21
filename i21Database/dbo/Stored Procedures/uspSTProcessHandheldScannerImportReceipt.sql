CREATE PROCEDURE [dbo].[uspSTProcessHandheldScannerImportReceipt]
	@HandheldScannerId INT,
	@UserId INT
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

DECLARE @ErrorMessage NVARCHAR(4000);
DECLARE @ErrorSeverity INT;
DECLARE @ErrorState INT;
DECLARE @intEntityId int;

BEGIN TRY

	SELECT DISTINCT intVendorId, intCompanyLocationId
	INTO #Vendors
	FROM vyuSTGetHandheldScannerImportReceipt
	WHERE intHandheldScannerId = @HandheldScannerId

	DECLARE @VendorId INT,
		@ShipFrom INT,
		@VendorNo NVARCHAR(100),
		@CompanyLocationId INT,
		@ReceiptStagingTable ReceiptStagingTable,
		@OtherCharges ReceiptOtherChargesTableType,
		@defaultCurrency INT
	
	SELECT TOP 1 @defaultCurrency = intDefaultCurrencyId
	FROM tblSMCompanyPreference
	WHERE intCompanyPreferenceId = 1

	WHILE EXISTS (SELECT TOP 1 1 FROM #Vendors)
	BEGIN
		DELETE FROM @ReceiptStagingTable

		SELECT TOP 1 @VendorId = intVendorId, @CompanyLocationId = intCompanyLocationId FROM #Vendors

		SELECT TOP 1 @ShipFrom = intShipFromId, @VendorNo = strVendorId FROM tblAPVendor WHERE intEntityId = @VendorId
		IF (ISNULL(@ShipFrom, '') = '')
		BEGIN
			DECLARE @MSG NVARCHAR(250) = 'Vendor ' + @VendorNo + 'has no default Ship From!'
			RAISERROR(@MSG, 16, 1)
		END

		SELECT *
		INTO #tmpImportReceipts
		FROM vyuSTGetHandheldScannerImportReceipt
		WHERE intHandheldScannerId = @HandheldScannerId
			AND intVendorId = @VendorId
			AND intCompanyLocationId = @CompanyLocationId
		
		INSERT INTO @ReceiptStagingTable(
			strReceiptType
			,strSourceScreenName
			,intEntityVendorId
			,intShipFromId
			,intLocationId
			,intItemId
			,intItemLocationId
			,intItemUOMId
			,strBillOfLadding
			,intContractHeaderId
			,intContractDetailId
			,dtmDate
			,intShipViaId
			,dblQty
			,dblCost
			,intCurrencyId
			,dblExchangeRate
			,intLotId
			,intSubLocationId
			,intStorageLocationId
			,ysnIsStorage
			,dblFreightRate
			,intSourceId	
			,intSourceType		 	
			,dblGross
			,dblNet
			,intInventoryReceiptId
			,dblSurcharge
			,ysnFreightInPrice
			,strActualCostId
			,intTaxGroupId
			,strVendorRefNo
			,strSourceId			
			,intPaymentOn
			,strChargesLink
		)	
		SELECT strReceiptType		= 'Direct'
			,strSourceScreenName	= 'None'
			,intEntityVendorId		= @VendorId
			,intShipFromId			= @ShipFrom
			,intLocationId			= @CompanyLocationId
			,intItemId				= intItemId
			,intItemLocationId		= intItemLocationId
			,intItemUOMId			= intItemUOMId
			,strBillOfLadding		= ''
			,intContractHeaderId	= NULL
			,intContractDetailId	= NULL
			,dtmDate				= dtmReceiptDate
			,intShipViaId			= NULL
			,dblQty					= dblReceivedQty
			,dblCost				= dblUnitRetail
			,intCurrencyId			= @defaultCurrency
			,dblExchangeRate		= 1
			,intLotId				= NULL
			,intSubLocationId		= NULL
			,intStorageLocationId	= NULL
			,ysnIsStorage			= 0
			,dblFreightRate			= 0
			,intSourceId			= NULL
			,intSourceType		 	= 0
			,dblGross				= NULL
			,dblNet					= NULL
			,intInventoryReceiptId	= NULL
			,dblSurcharge			= NULL
			,ysnFreightInPrice		= NULL
			,strActualCostId		= NULL
			,intTaxGroupId			= NULL
			,strVendorRefNo			= NULL
			,strSourceId			= NULL
			,intPaymentOn			= NULL
			,strChargesLink			= NULL
		FROM #tmpImportReceipts
		WHERE intCompanyLocationId = @CompanyLocationId
			AND intVendorId = @VendorId

		EXEC dbo.uspICAddItemReceipt 
			@ReceiptStagingTable
			,@OtherCharges
			,@UserId;

		DROP TABLE #tmpImportReceipts

		DELETE FROM #Vendors WHERE intVendorId = @VendorId AND intCompanyLocationId = @CompanyLocationId
	END	
	DROP TABLE #Vendors

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