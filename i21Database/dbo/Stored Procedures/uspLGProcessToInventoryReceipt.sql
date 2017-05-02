CREATE PROCEDURE [dbo].[uspLGProcessToInventoryReceipt] 
	 @intLoadId INT
	,@intEntityUserSecurityId INT
	,@intInventoryReceiptId INT OUTPUT
AS
BEGIN TRY
	DECLARE @ErrorMessage NVARCHAR(4000)
	DECLARE @ErrorSeverity INT
	DECLARE @ErrorState INT
	DECLARE @InventoryReceiptId INT
	DECLARE @ErrMsg NVARCHAR(MAX)
	DECLARE @intSourceId INT
	DECLARE @intContractDetailId INT
	DECLARE @intLoadDetailId INT
	DECLARE @intMinRecordId INT
	DECLARE @dblLoadDetailQty NUMERIC(18, 6)
	DECLARE @intInventoryReceiptItemId INT
	DECLARE @ReceiptStagingTable ReceiptStagingTable
	DECLARE @LotEntries ReceiptItemLotStagingTable
	DECLARE @OtherCharges ReceiptOtherChargesTableType
	DECLARE @tblLoadDetail TABLE (
		intRecordId INT Identity(1, 1)
		,intLoadDetailId INT
		,intContractDetailId INT
		,dblLoadDetailQty NUMERIC(18, 6)
		)

	INSERT INTO @tblLoadDetail
	SELECT intLoadDetailId
		,intPContractDetailId
		,dblQuantity
	FROM tblLGLoadDetail
	WHERE intLoadId = @intLoadId

	IF EXISTS (
			SELECT 1
			FROM tblLGLoad L
			JOIN tblLGLoadDetail LD ON L.intLoadId = LD.intLoadId
			JOIN tblICInventoryReceiptItem RI ON RI.intSourceId = LD.intLoadDetailId
			WHERE L.intLoadId = @intLoadId
			)
	BEGIN
		RAISERROR ('Receipt has already been created for the inbound shipment.',16,1)
	END

	IF NOT EXISTS (SELECT 1 FROM tempdb..sysobjects WHERE id = OBJECT_ID('tempdb..#tmpAddItemReceiptResult'))
	BEGIN
		CREATE TABLE #tmpAddItemReceiptResult (
			intSourceId INT
			,intInventoryReceiptId INT
			)
	END

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
		)
	SELECT DISTINCT strReceiptType = 'Purchase Contract'
		,intEntityVendorId = LD.intEntityVendorId
		,intShipFromId = EL.intEntityLocationId
		,intLocationId = CD.intCompanyLocationId
		,LD.strBLNumber
		,intItemId = LD.intItemId
		,intItemLocationId = CD.intCompanyLocationId
		,intItemUOMId = LD.intItemUOMId
		,intContractHeaderId = LD.intPContractHeaderId
		,intContractDetailId = LD.intPContractDetailId
		,dtmDate = GETDATE()
		,intShipViaId = CD.intShipViaId
		,dblQty = LD.dblQuantity
		,intGrossNetUOMId = ISNULL(LD.intWeightItemUOMId, 0)
		,dblGross = LD.dblGross
		,dblNet = LD.dblNet
		,dblCost = ISNULL(LD.dblCost,0)
		,intCostUOMId = LD.intPCostUOMId
		,intCurrencyId = ISNULL(SC.intMainCurrencyId, AD.intSeqCurrencyId)
		,intSubCurrencyCents = ISNULL(SubCurrency.intCent, 1)
		,dblExchangeRate = 1
		,intLotId = NULL
		,intSubLocationId = ISNULL(CD.intSubLocationId, LD.intSubLocationId)
		,intStorageLocationId = ISNULL(CD.intStorageLocationId, LD.intStorageLocationId)
		,ysnIsStorage = 0
		,intSourceId = LD.intLoadDetailId
		,intSourceType = 2
		,strSourceId = LD.strLoadNumber
		,strSourceScreenName = 'Contract'
		,ysnSubCurrency = SubCurrency.ysnSubCurrency
		,intForexRateTypeId = CD.intRateTypeId
		,dblForexRate = CD.dblRate
		,LD.intLoadContainerId
	FROM vyuLGLoadContainerReceiptContracts LD
	JOIN tblCTContractDetail CD ON CD.intContractDetailId = LD.intPContractDetailId
	JOIN tblCTContractHeader CH ON CH.intContractHeaderId = CD.intContractHeaderId
	JOIN tblICItemLocation IL ON IL.intItemId = CD.intItemId
		AND IL.intLocationId = CD.intCompanyLocationId
	CROSS APPLY dbo.fnCTGetAdditionalColumnForDetailView(CD.intContractDetailId) AD
	JOIN tblEMEntityLocation EL ON EL.intEntityId = CH.intEntityId
		AND EL.ysnDefaultLocation = 1
	LEFT JOIN vyuICGetItemStock SK ON SK.intItemId = CD.intItemId
		AND SK.intLocationId = CD.intCompanyLocationId
	LEFT JOIN tblSMCurrency SC ON SC.intCurrencyID = AD.intSeqCurrencyId
	LEFT JOIN tblSMCurrency SubCurrency ON SubCurrency.intCurrencyID = CASE 
			WHEN SC.intMainCurrencyId IS NOT NULL
				THEN CD.intCurrencyId
			ELSE NULL
			END
	WHERE LD.intLoadId = @intLoadId

	INSERT INTO @OtherCharges (
		[intOtherChargeEntityVendorId]
		,[intChargeId]
		,[strCostMethod]
		,[dblRate]
		,[dblAmount]
		,[intCostUOMId]
		,[intContractHeaderId]
		,[intContractDetailId]
		,[ysnAccrue]
		,[strReceiptType]
		,[intShipViaId]
		,[intCurrencyId]
		,[intEntityVendorId]
		,[intShipFromId]
		,[intLocationId]
		,[ysnPrice]
		,[ysnSubCurrency]
		,[intCostCurrencyId]
		)
	SELECT CV.intEntityId
		,CV.intItemId
		,CV.strCostMethod
		,CASE 
			WHEN CV.strCostMethod = 'Amount'
				THEN 0
			ELSE CV.dblRate
			END
		,CASE 
			WHEN CV.strCostMethod = 'Amount'
				THEN CV.dblRate
			ELSE 0
			END
		,CV.intItemUOMId
		,(
			SELECT TOP 1 CD.intContractHeaderId
			FROM tblLGLoadDetail LD
			JOIN tblCTContractDetail CD ON CD.intContractDetailId = LD.intPContractDetailId
			WHERE intLoadId = @intLoadId
			)
		,(
			SELECT TOP 1 intPContractDetailId
			FROM tblLGLoadDetail
			WHERE intLoadId = @intLoadId
			)
		,CV.ysnAccrue
		,'Purchase Contract'
		,NULL
		,CV.intCurrencyId
		,NULL
		,NULL
		,(
			SELECT TOP 1 intPCompanyLocationId
			FROM tblLGLoadDetail
			WHERE intLoadId = @intLoadId
			)
		,CV.ysnPrice
		,NULL
		,CV.intCurrencyId
	FROM vyuLGLoadCostView CV
	JOIN tblLGLoad L ON L.intLoadId = CV.intLoadId
	WHERE L.intLoadId = @intLoadId
		AND ysnAccrue = 1

	IF NOT EXISTS (
			SELECT 1
			FROM @ReceiptStagingTable
			)
	BEGIN
		RETURN
	END

	EXEC dbo.uspICAddItemReceipt @ReceiptEntries = @ReceiptStagingTable
								,@OtherCharges = @OtherCharges
								,@intUserId = @intEntityUserSecurityId;

	SELECT TOP 1 @intInventoryReceiptId = intInventoryReceiptId
	FROM #tmpAddItemReceiptResult

	DECLARE @intMinInvRecItemId INT

	SELECT @intMinInvRecItemId = MIN(intInventoryReceiptItemId)
	FROM tblICInventoryReceiptItem
	WHERE intInventoryReceiptId = @intInventoryReceiptId

	WHILE @intMinInvRecItemId > 0
	BEGIN
		INSERT INTO dbo.tblICInventoryReceiptItemLot (
			[intInventoryReceiptItemId]
			,[intLotId]
			,[strLotNumber]
			,[strLotAlias]
			,intSubLocationId
			,intStorageLocationId
			,[intItemUnitMeasureId]
			,dblQuantity
			,dblGrossWeight
			,dblTareWeight
			,strContainerNo
			,[intSort]
			,[intConcurrencyId]
			)
		SELECT intInventoryReceiptItemId
			,NULL
			,''
			,''
			,intSubLocationId
			,intStorageLocationId
			,RI.intUnitMeasureId
			,RI.dblOpenReceive
			,dblGross
			,ISNULL(RI.dblGross,0) - ISNULL(RI.dblNet,0)
			,LC.strContainerNumber
			,1
			,1
		FROM tblICInventoryReceiptItem RI
		LEFT JOIN tblLGLoadContainer LC ON LC.intLoadContainerId = RI.intContainerId
		WHERE intInventoryReceiptItemId = @intMinInvRecItemId

		SELECT @intMinInvRecItemId = MIN(intInventoryReceiptItemId)
		FROM tblICInventoryReceiptItem
		WHERE intInventoryReceiptId = @intInventoryReceiptId
		  AND intInventoryReceiptItemId > @intMinInvRecItemId
	END
END TRY

BEGIN CATCH
	SET @ErrMsg = ERROR_MESSAGE()
	RAISERROR (@ErrMsg,18,1,'WITH NOWAIT')
END CATCH