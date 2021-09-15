CREATE PROCEDURE uspMFProcessInventoryReceipt (
	@intPurchaseId INT
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
			SELECT *
			FROM dbo.tblMFPODetail
			WHERE intPurchaseId=@intPurchaseId
				AND ysnProcessed = 0
			)
	BEGIN
		RAISERROR (
				'There is no record to process for the selected PO.'
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
		,intEntityVendorId
		,intShipFromId
		,intLocationId
		,strBillOfLadding
		,intItemId
		,intItemLocationId
		,intItemUOMId
		,intContractHeaderId
		,intContractDetailId
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
		)
	SELECT DISTINCT strReceiptType = 'Purchase Order'
		,intEntityVendorId = P.intEntityVendorId
		,intShipFromId = P.intShipFromId
		,intLocationId = IL.intLocationId
		,strBillOfLadding = NULL
		,intItemId = I.intItemId
		,intItemLocationId = IL.intItemLocationId
		,intItemUOMId = D.intItemUOMId
		,intContractHeaderId = PD.intPurchaseId
		,intContractDetailId = PD.intPurchaseDetailId
		,dtmDate = dbo.fnRemoveTimeOnDate(GETDATE())
		,intShipViaId = P.intShipViaId
		,dblQty = D.dblQuantity
		,intGrossNetUOMId = NULL
		,dblGross = NULL
		,dblNet = NULL
		,dblCost = PD.dblCost - (PD.dblCost * (ISNULL(PD.dblDiscount, 0) / 100))
		,intCostUOMId = PD.intCostUOMId
		,intCurrencyId = P.intCurrencyId
		,intSubCurrencyCents = (
			CASE 
				WHEN PD.ysnSubCurrency > 0
					THEN P.intSubCurrencyCents
				ELSE 1
				END
			)
		,dblExchangeRate = ISNULL(P.dblExchangeRate, 1)
		,intLotId = NULL
		,intSubLocationId = D.intSubLocationId
		,intStorageLocationId = D.intStorageLocationId
		,ysnIsStorage = 0
		,intSourceId = PD.intPurchaseId
		,intSourceType = 0
		,strSourceId = P.strPurchaseOrderNumber
		,strSourceScreenName = 'Scanner'
		,ysnSubCurrency = 0
		,intForexRateTypeId = PD.intForexRateTypeId
		,dblForexRate = PD.dblForexRate
		,intContainerId = NULL
		,intFreightTermId = P.intFreightTermId
		,intInventoryReceiptId = NULL
		,strVendorRefNo = P.strReference
		,intTaxGroupId = PD.intTaxGroupId
	FROM dbo.tblMFPODetail D
	JOIN dbo.tblPOPurchaseDetail PD ON PD.intPurchaseDetailId = D.intPurchaseDetailId
	JOIN dbo.tblPOPurchase P ON P.intPurchaseId = PD.intPurchaseId
	JOIN dbo.tblICItem I ON I.intItemId = PD.intItemId
	JOIN dbo.tblICItemLocation IL ON IL.intItemId = I.intItemId
		AND IL.intLocationId = PD.intLocationId
	JOIN dbo.tblICItemUOM IU ON IU.intItemUOMId = D.intItemUOMId
	JOIN dbo.tblICUnitMeasure UM ON UM.intUnitMeasureId = IU.intUnitMeasureId
	WHERE PD.intPurchaseId = @intPurchaseId
		AND PD.dblQtyOrdered != PD.dblQtyReceived
		AND I.strType IN (
			'Inventory'
			,'Non-Inventory'
			,'Finished Good'
			,'Raw Material'
			)
	ORDER BY PD.intPurchaseDetailId

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

		UPDATE tblMFPODetail
		SET ysnProcessed = 1
		WHERE intPurchaseId = @intPurchaseId

		-- Update the PO Received Qty
		UPDATE	pod
		SET		pod.dblQtyReceived = pod.dblQtyOrdered
		FROM	tblPOPurchase po INNER JOIN tblPOPurchaseDetail pod
					ON po.intPurchaseId = pod.intPurchaseId
				LEFT JOIN tblICItem i
						ON i.intItemId = pod.intItemId
		WHERE	po.intPurchaseId = @intPurchaseId 
				AND pod.intItemId IS NOT NULL				--DO NOT UPDATE MISC ENTRY
				AND i.strType NOT IN ('Other Charge')		--DOT NOT UPDATE OTHER CHARGES TYPE
	
		-- Update the PO Status 
		EXEC dbo.uspPOUpdateStatus @intPurchaseId

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
