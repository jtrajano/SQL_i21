CREATE PROCEDURE [dbo].[uspSTProcessHandheldScannerImportReceipt]
	@HandheldScannerId INT,
	@UserId INT,
	@strReceiptRefNoList NVARCHAR(MAX),
	@ysnSuccess BIT OUTPUT,
	@strStatusMsg NVARCHAR(1000) OUTPUT
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
	
	-- Create table to handle Receipt Refference No.
	DECLARE @tblTempItems TABLE
	(
		strReceiptRefNo NVARCHAR(150) COLLATE Latin1_General_CI_AS
	)


	-- Insert to table
	INSERT INTO @tblTempItems
	(
		strReceiptRefNo
	)
	SELECT [strItem] AS strReceiptRefNo
	FROM [dbo].[fnSTGetRowsFromDelimitedValuesReturnString](@strReceiptRefNoList)


	--------------------------------------------------------------------------------------
	-------------------- Start Validate if has record to Process -------------------------
	--------------------------------------------------------------------------------------
	IF NOT EXISTS(
					SELECT TOP 1 1 FROM vyuSTGetHandheldScannerImportReceipt 
					WHERE intHandheldScannerId = @HandheldScannerId  
					AND strReceiptRefNoComment IN (SELECT strReceiptRefNo FROM @tblTempItems)
				 )
		BEGIN
			-- Flag Failed
			SET @ysnSuccess = CAST(0 AS BIT)
			SET @strStatusMsg = 'There are no records to process. ' + @strReceiptRefNoList + ' ' + CAST(@HandheldScannerId AS NVARCHAR(20))
			RETURN
		END
	--------------------------------------------------------------------------------------
	-------------------- End Validate if has record to Process ---------------------------
	--------------------------------------------------------------------------------------



	--------------------------------------------------------------------------------------
	------------ Start Validate if All Items have the same Store Location ----------------
	--------------------------------------------------------------------------------------
	IF EXISTS(
				SELECT TOP 1 1 
				FROM tblSTHandheldScannerImportReceipt IR
				INNER JOIN tblSTHandheldScanner HS
					ON IR.intHandheldScannerId = HS.intHandheldScannerId
				INNER JOIN tblSTStore ST
					ON HS.intStoreId = ST.intStoreId
				INNER JOIN tblICItem Item
					ON IR.intItemId = Item.intItemId
				LEFT JOIN tblICItemLocation ItemLoc
					ON Item.intItemId = ItemLoc.intItemId
					AND ST.intCompanyLocationId = ItemLoc.intLocationId
				WHERE IR.intHandheldScannerId = @HandheldScannerId
				AND ItemLoc.intItemLocationId IS NULL
			 )
		BEGIN
			DECLARE @strItemNoLocationSameAsStore AS NVARCHAR(MAX)

			SELECT @strItemNoLocationSameAsStore = COALESCE(@strItemNoLocationSameAsStore + ', ', '') + strItemNo
			FROM tblSTHandheldScannerImportReceipt IR
			INNER JOIN tblSTHandheldScanner HS
				ON IR.intHandheldScannerId = HS.intHandheldScannerId
			INNER JOIN tblSTStore ST
				ON HS.intStoreId = ST.intStoreId
			INNER JOIN tblICItem Item
				ON IR.intItemId = Item.intItemId
			LEFT JOIN tblICItemLocation ItemLoc
				ON Item.intItemId = ItemLoc.intItemId
				AND ST.intCompanyLocationId = ItemLoc.intLocationId
			WHERE IR.intHandheldScannerId = @HandheldScannerId
			AND ItemLoc.intItemLocationId IS NULL

			-- Flag Failed
			SET @ysnSuccess = CAST(0 AS BIT)
			SET @strStatusMsg = 'Selected Item/s  ' + @strItemNoLocationSameAsStore + '  has no location setup same as location of selected Store.'
			RETURN
		END
	--------------------------------------------------------------------------------------
	------------- End Validate if All Items have the same Store Location -----------------
	--------------------------------------------------------------------------------------




	SELECT DISTINCT intVendorId, intCompanyLocationId
	INTO #Vendors
	FROM vyuSTGetHandheldScannerImportReceipt
	WHERE intHandheldScannerId = @HandheldScannerId
	AND strReceiptRefNoComment IN (SELECT strReceiptRefNo FROM @tblTempItems)

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


	--------------------------------------------------------------------------------------
	--------- Start Validate if items does not have intItemUOMId -------------------------
	--------------------------------------------------------------------------------------
	IF EXISTS (
				SELECT TOP 1 1 FROM vyuSTGetHandheldScannerImportReceipt 
				WHERE intHandheldScannerId = @HandheldScannerId 
				AND intItemUOMId IS NULL 
				AND strReceiptRefNoComment IN (SELECT strReceiptRefNo FROM @tblTempItems)
			  )
		BEGIN
			DECLARE @strItemNoHasNoUOM AS NVARCHAR(MAX)

			SELECT @strItemNoHasNoUOM = COALESCE(@strItemNoHasNoUOM + ', ', '') + strItemNo
			FROM vyuSTGetHandheldScannerImportReceipt
			WHERE intHandheldScannerId = @HandheldScannerId
			AND intItemUOMId IS NULL

			-- Flag Failed
			SET @ysnSuccess = CAST(0 AS BIT)
			SET @strStatusMsg = 'Selected Item/s ' + @strItemNoHasNoUOM + ' has no default UOM'
			RETURN
		END
	--------------------------------------------------------------------------------------
	--------- End Validate if items does not have intItemUOMId ---------------------------
	--------------------------------------------------------------------------------------



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

		

			SELECT 
				IR.*
				, UOM.intUnitMeasureId
				, ROW_NUMBER() OVER (ORDER BY IR.intHandheldScannerImportReceiptId ASC) intSort
			INTO #tmpImportReceipts
			FROM vyuSTGetHandheldScannerImportReceipt IR
			LEFT JOIN tblICItemUOM UOM
				ON IR.intItemUOMId = UOM.intItemUOMId
			WHERE IR.intHandheldScannerId = @HandheldScannerId
				AND IR.intVendorId = @VendorId
				AND IR.intCompanyLocationId = @CompanyLocationId
				AND UOM.ysnStockUnit = CAST(1 AS BIT)
			ORDER BY IR.intHandheldScannerImportReceiptId ASC


			INSERT INTO @ReceiptStagingTable(
				strReceiptType
				,strSourceScreenName
				,intEntityVendorId
				,intShipFromId
				,intLocationId
				,intItemId
				,intItemLocationId
				,intItemUOMId
				, intCostUOMId
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
				,dblUnitRetail
				,intSort
			)	
			SELECT strReceiptType		= 'Direct'
				,strSourceScreenName	= 'None'
				,intEntityVendorId		= @VendorId
				,intShipFromId			= @ShipFrom
				,intLocationId			= @CompanyLocationId
				,intItemId				= intItemId
				,intItemLocationId		= intItemLocationId
				,intItemUOMId			= intItemUOMId
				, intCostUOMId			= intUnitMeasureId
				,strBillOfLadding		= ''
				,intContractHeaderId	= NULL
				,intContractDetailId	= NULL
				,dtmDate				= dtmReceiptDate
				,intShipViaId			= NULL
				,dblQty					= dblReceivedQty
				,dblCost				= dblCaseCost --dblUnitRetail
				,intCurrencyId			= @defaultCurrency
				,dblExchangeRate		= 1
				,intLotId				= NULL
				,intSubLocationId		= NULL
				,intStorageLocationId	= NULL
				,ysnIsStorage			= 0
				,dblFreightRate			= 0
				,intSourceId			= NULL
				,intSourceType		 	= 7 -- 7 means 'Store'
				,dblGross				= NULL
				,dblNet					= NULL
				,intInventoryReceiptId	= NULL
				,dblSurcharge			= NULL
				,ysnFreightInPrice		= NULL
				,strActualCostId		= NULL
				,intTaxGroupId			= NULL
				,strVendorRefNo			= strReceiptRefNoComment
				,strSourceId			= NULL
				,intPaymentOn			= NULL
				,strChargesLink			= NULL
				,dblUnitRetail			= dblUnitRetail
				,intSort				= intSort
			FROM #tmpImportReceipts
			WHERE intCompanyLocationId = @CompanyLocationId
				AND intVendorId = @VendorId
			ORDER BY intSort


			EXEC dbo.uspICAddItemReceipt 
				  @ReceiptStagingTable
				, @OtherCharges
				, @UserId;

			DROP TABLE #tmpImportReceipts

			DELETE FROM #Vendors 
			WHERE intVendorId = @VendorId 
				AND intCompanyLocationId = @CompanyLocationId

		END	

	DROP TABLE #Vendors

	-- Clear record from table
	DELETE FROM tblSTHandheldScannerImportReceipt 
	WHERE intHandheldScannerId = @HandheldScannerId
		AND strReceiptRefNoComment IN (SELECT strReceiptRefNo FROM @tblTempItems)

	-- Flag Success
	SET @ysnSuccess = CAST(1 AS BIT)
	SET @strStatusMsg = ''
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