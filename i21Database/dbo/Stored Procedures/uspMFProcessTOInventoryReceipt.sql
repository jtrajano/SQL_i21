CREATE PROCEDURE uspMFProcessTOInventoryReceipt (
	@intInventoryTransferId INT
	,@intUserId INT
	,@strReceiptNumber NVARCHAR(50) OUTPUT
	)
AS
BEGIN TRY
	DECLARE @intTransactionCount INT
		,@intInventoryReceiptId INT
		,@strErrorMessage NVARCHAR(MAX)
	DECLARE @ReceiptStagingTable ReceiptStagingTable
	DECLARE @OtherCharges ReceiptOtherChargesTableType

	IF NOT EXISTS (
			SELECT 1
			FROM dbo.tblICInventoryTransfer
			WHERE intInventoryTransferId = @intInventoryTransferId
				AND (
					intStatusId = 1
					OR intStatusId = 2
					)
			)
	BEGIN
		RAISERROR (
				'Inventory Transfer is already Closed.'
				,16
				,1
				)

		RETURN
	END

	IF NOT EXISTS (
			SELECT *
			FROM dbo.tblMFTOReceiptDetail
			WHERE intInventoryTransferId = @intInventoryTransferId
				AND ysnProcessed = 0
			)
	BEGIN
		RAISERROR (
				'There is no record to process for the selected TO.'
				,16
				,1
				)

		RETURN
	END

	SELECT @intTransactionCount = @@TRANCOUNT

	IF @intTransactionCount = 0
		BEGIN TRANSACTION

	SELECT @intInventoryReceiptId = NULL

	SELECT @strErrorMessage = ''

	IF NOT EXISTS (
			SELECT 1
			FROM tempdb..sysobjects
			WHERE id = OBJECT_ID('tempdb..#tmpAddItemReceiptResult')
			)
	BEGIN
		CREATE TABLE #tmpAddItemReceiptResult (
			intSourceId INT
			,intInventoryReceiptId INT
			)
	END

	DELETE
	FROM @ReceiptStagingTable

	INSERT INTO @ReceiptStagingTable (
		strReceiptType
		,intShipFromId
		,intLocationId
		,strBillOfLadding
		,intItemId
		,intItemLocationId
		,intItemUOMId
		,dtmDate
		,intShipViaId
		,dblQty
		,intGrossNetUOMId
		,dblGross
		,dblNet
		,dblCost
		,intCostUOMId
		,intCurrencyId
		,intSubCurrencyCents
		,dblExchangeRate
		,intLotId
		,intSubLocationId
		,intStorageLocationId
		,ysnIsStorage
		,intSourceId
		,intSourceType
		,strSourceId
		,strSourceScreenName
		,ysnSubCurrency
		,intForexRateTypeId
		,dblForexRate
		,intContainerId
		,intFreightTermId
		,intInventoryReceiptId
		,strVendorRefNo
		,intTaxGroupId
		,intInventoryTransferId
		,intInventoryTransferDetailId
		)
	SELECT DISTINCT strReceiptType = 'Transfer Order'
		,intShipFromId = T.intFromLocationId
		,intLocationId = IL.intLocationId
		,strBillOfLadding = T.strBolNumber
		,intItemId = I.intItemId
		,intItemLocationId = IL.intItemLocationId
		,intItemUOMId = D.intItemUOMId
		,dtmDate = dbo.fnRemoveTimeOnDate(GETDATE())
		,intShipViaId = T.intShipViaId
		,dblQty = D.dblQuantity
		,intGrossNetUOMId = NULL
		,dblGross = NULL
		,dblNet = NULL
		,dblCost = TD.dblCost
		,intCostUOMId = SIU.intItemUOMId
		,intCurrencyId = TD.intCurrencyId
		,intSubCurrencyCents = 1
		,dblExchangeRate = 1
		,intLotId = NULL
		,intSubLocationId = D.intSubLocationId
		,intStorageLocationId = D.intStorageLocationId
		,ysnIsStorage = 0
		,intSourceId = TD.intInventoryTransferDetailId
		,intSourceType = 0
		,strSourceId = T.strTransferNo
		,strSourceScreenName = 'Scanner'
		,ysnSubCurrency = 0
		,intForexRateTypeId = NULL
		,dblForexRate = NULL
		,intContainerId = NULL
		,intFreightTermId = (
			SELECT TOP 1 intFreightTermId
			FROM tblSMFreightTerms
			WHERE strFreightTerm = 'Deliver'
				AND strFobPoint = 'Destination'
			)
		,intInventoryReceiptId = NULL
		,strVendorRefNo = NULL
		,intTaxGroupId = NULL
		,intInventoryTransferId = T.intInventoryTransferId
		,intInventoryTransferDetailId = TD.intInventoryTransferDetailId
	FROM dbo.tblMFTOReceiptDetail D
	JOIN dbo.tblICInventoryTransferDetail TD ON TD.intInventoryTransferDetailId = D.intInventoryTransferDetailId
	JOIN dbo.tblICInventoryTransfer T ON T.intInventoryTransferId = TD.intInventoryTransferId
	JOIN dbo.tblICItem I ON I.intItemId = TD.intItemId
	JOIN dbo.tblICItemLocation IL ON IL.intItemId = I.intItemId
		AND IL.intLocationId = T.intToLocationId
	JOIN dbo.tblICItemUOM IU ON IU.intItemUOMId = TD.intItemUOMId
	JOIN dbo.tblICUnitMeasure UM ON UM.intUnitMeasureId = IU.intUnitMeasureId
	JOIN dbo.tblICItemUOM SIU ON SIU.intItemId = TD.intItemId
		AND SIU.ysnStockUnit = 1
	WHERE TD.intInventoryTransferId = @intInventoryTransferId
	ORDER BY TD.intInventoryTransferDetailId

	IF EXISTS (
			SELECT *
			FROM @ReceiptStagingTable
			)
	BEGIN
		EXEC dbo.uspICAddItemReceipt @ReceiptEntries = @ReceiptStagingTable
			,@OtherCharges = @OtherCharges
			,@intUserId = @intUserId;

		SELECT TOP 1 @intInventoryReceiptId = intInventoryReceiptId
		FROM #tmpAddItemReceiptResult

		SELECT @strReceiptNumber = strReceiptNumber
		FROM tblICInventoryReceipt
		WHERE intInventoryReceiptId = @intInventoryReceiptId

		UPDATE tblMFTOReceiptDetail
		SET ysnProcessed = 1
		WHERE intInventoryTransferId = @intInventoryTransferId

		DELETE
		FROM #tmpAddItemReceiptResult
	END

	IF @intTransactionCount = 0
		COMMIT TRANSACTION
END TRY

BEGIN CATCH
	SET @strErrorMessage = ERROR_MESSAGE()

	IF XACT_STATE() != 0
		AND @intTransactionCount = 0
		ROLLBACK TRANSACTION

	RAISERROR (
			@strErrorMessage
			,18
			,1
			,'WITH NOWAIT'
			)
END CATCH
