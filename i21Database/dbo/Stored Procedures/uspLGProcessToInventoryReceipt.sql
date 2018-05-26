CREATE PROCEDURE [dbo].[uspLGProcessToInventoryReceipt] 
	 @intLoadId INT
	,@intEntityUserSecurityId INT
	,@intInventoryReceiptId INT OUTPUT
AS
BEGIN TRY
	DECLARE @strErrorMessage NVARCHAR(MAX)
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
	DECLARE @intPContractDetailId INT
	DECLARE @intPEntityId INT
	DECLARE @intPItemId INT
	DECLARE @intLoadSourceType INT
	DECLARE @intMinInvRecItemId INT
	DECLARE @dblVoucherQty NUMERIC(18,6)
	DECLARE @dblBillQty NUMERIC(18, 6)
	DECLARE @dblPContractDetailQty NUMERIC(18, 6)

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

	SELECT @intLoadSourceType = intSourceType
	FROM tblLGLoad
	WHERE intLoadId = @intLoadId

	IF NOT EXISTS (SELECT 1 FROM tempdb..sysobjects WHERE id = OBJECT_ID('tempdb..#tmpAddItemReceiptResult'))
	BEGIN
		CREATE TABLE #tmpAddItemReceiptResult (
			intSourceId INT
			,intInventoryReceiptId INT
			)
	END

	IF ISNULL(@intLoadSourceType,0) = 1
	BEGIN
		IF EXISTS (
				SELECT LD.intItemId
				FROM tblLGLoadDetail LD
				JOIN tblICItemUOM U ON U.intItemUOMId = LD.intItemUOMId
				WHERE LD.intLoadId = @intLoadId
					AND LD.intItemId <> U.intItemId
				)
		BEGIN
			UPDATE LD
			SET intItemUOMId = IU.intItemUOMId
			FROM tblLGLoad L
			JOIN tblLGLoadDetail LD ON LD.intLoadId = L.intLoadId
			JOIN tblICItemUOM U ON U.intItemUOMId = LD.intItemUOMId
			JOIN tblICItemUOM IU ON IU.intUnitMeasureId = U.intUnitMeasureId
				AND IU.intItemId = LD.intItemId
			WHERE LD.intLoadId = @intLoadId
				AND LD.intItemId <> U.intItemId

			UPDATE LDCL
			SET intItemUOMId = LD.intItemUOMId
			FROM tblLGLoadDetail LD
			JOIN tblLGLoadDetailContainerLink LDCL ON LDCL.intLoadDetailId = LD.intLoadDetailId
			WHERE LD.intItemUOMId <> LDCL.intItemUOMId AND LD.intLoadId = @intLoadId
		END

		IF EXISTS (SELECT 1 FROM tblLGLoadDetailContainerLink WHERE intLoadId = @intLoadId)
		BEGIN
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
				,intBookId
				,intSubBookId
				)
			SELECT strReceiptType = 'Direct'
				,intEntityVendorId = LD.intVendorEntityId
				,intShipFromId = EL.intEntityLocationId
				,intLocationId = LD.intPCompanyLocationId
				,L.strBLNumber
				,intItemId = LD.intItemId
				,intItemLocationId = LD.intPCompanyLocationId
				,intItemUOMId = LD.intItemUOMId
				,intContractHeaderId = NULL
				,intContractDetailId = NULL
				,dtmDate = GETDATE()
				,intShipViaId = NULL
				,dblQty = ISNULL(LDCL.dblQuantity, LD.dblQuantity)
				,intGrossNetUOMId = LD.intWeightItemUOMId
				,dblGross = ISNULL(LDCL.dblLinkGrossWt, LD.dblGross)
				,dblNet = ISNULL(LDCL.dblLinkNetWt, LD.dblNet)
				,dblCost = 0 
				,intCostUOMId = NULL 
				,intCurrencyId = ISNULL(SC.intMainCurrencyId, L.intCurrencyId)
				,intSubCurrencyCents = ISNULL(SubCurrency.intCent, 1)
				,dblExchangeRate = 1
				,intLotId = NULL
				,intSubLocationId = LW.intSubLocationId 
				,intStorageLocationId = LW.intStorageLocationId
				,ysnIsStorage = 0
				,intSourceId = NULL
				,intSourceType = 0
				,strSourceId = NULL
				,strSourceScreenName = NULL
				,ysnSubCurrency = SubCurrency.ysnSubCurrency
				,intForexRateTypeId = NULL
				,dblForexRate = NULL
				,ISNULL(LC.intLoadContainerId, - 1)
				,L.intFreightTermId
				,L.intBookId
				,L.intSubBookId
			FROM tblLGLoad L 
			JOIN tblLGLoadDetail LD ON L.intLoadId = LD.intLoadId 
			JOIN tblICItemLocation IL ON IL.intItemId = LD.intItemId 
				AND IL.intLocationId = LD.intPCompanyLocationId 
			JOIN tblEMEntityLocation EL ON EL.intEntityId = LD.intVendorEntityId 
				AND EL.ysnDefaultLocation = 1 
			LEFT JOIN tblLGLoadDetailContainerLink LDCL ON LDCL.intLoadDetailId = LD.intLoadDetailId
			LEFT JOIN tblLGLoadContainer LC ON LC.intLoadContainerId = LDCL.intLoadContainerId 
			LEFT JOIN tblSMCurrency SC ON SC.intCurrencyID = L.intCurrencyId
			LEFT JOIN tblSMCurrency SubCurrency ON SubCurrency.intCurrencyID = CASE 
					WHEN SC.intMainCurrencyId IS NOT NULL
						THEN L.intCurrencyId
					ELSE NULL
					END 
			LEFT JOIN tblLGLoadWarehouseContainer LWC ON LWC.intLoadContainerId = LC.intLoadContainerId
			LEFT JOIN tblLGLoadWarehouse LW ON LW.intLoadWarehouseId = LWC.intLoadWarehouseId
			WHERE CAST((
						CASE 
							WHEN ISNULL(LDCL.dblReceivedQty, 0) = 0
								THEN 0
							ELSE 1
							END
						) AS BIT) = 0
				AND L.intLoadId = @intLoadId
			ORDER BY LDCL.intLoadDetailContainerLinkId
		END
		ELSE
		BEGIN
			
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
				,intBookId
				,intSubBookId
				)
			SELECT strReceiptType = 'Direct'
				,intEntityVendorId = LD.intVendorEntityId --
				,intShipFromId = EL.intEntityLocationId
				,intLocationId = LD.intPCompanyLocationId
				,L.strBLNumber 
				,intItemId = LD.intItemId 
				,intItemLocationId = LD.intPCompanyLocationId
				,intItemUOMId = LD.intItemUOMId
				,intContractHeaderId = NULL 
				,intContractDetailId = NUll 
				,dtmDate = GETDATE()
				,intShipViaId = NULl
				,dblQty = LD.dblQuantity-ISNULL(LD.dblDeliveredQuantity,0)
				,intGrossNetUOMId = LD.intWeightItemUOMId
				,dblGross =  LD.dblGross - ISNULL(LD.dblDeliveredGross,0)
				,dblNet = LD.dblNet -ISNULL(LD.dblDeliveredNet,0)
				,dblCost = 0
				,intCostUOMId = NULL
				,intCurrencyId = ISNULL(SC.intMainCurrencyId, L.intCurrencyId)
				,intSubCurrencyCents = ISNULL(SubCurrency.intCent, 1)
				,dblExchangeRate = 1
				,intLotId = NULL
				,intSubLocationId = LD.intPSubLocationId
				,intStorageLocationId = NULL
				,ysnIsStorage = 0
				,intSourceId = LD.intLoadDetailId
				,intSourceType = 0
				,strSourceId = L.strLoadNumber 
				,strSourceScreenName = NULL
				,ysnSubCurrency = SubCurrency.ysnSubCurrency
				,intForexRateTypeId = NULL
				,dblForexRate = NULL
				,- 1 --
				,L.intFreightTermId
				,L.intBookId
				,L.intSubBookId
			FROM tblLGLoad L
			JOIN tblLGLoadDetail LD ON L.intLoadId = LD.intLoadId
			JOIN tblICItemLocation IL ON IL.intItemId = LD.intItemId
				AND IL.intLocationId = LD.intPCompanyLocationId
			JOIN tblEMEntityLocation EL ON EL.intEntityId = LD.intVendorEntityId
				AND EL.ysnDefaultLocation = 1
			LEFT JOIN tblSMCurrency SC ON SC.intCurrencyID = L.intCurrencyId
			LEFT JOIN tblSMCurrency SubCurrency ON SubCurrency.intCurrencyID = CASE 
					WHEN SC.intMainCurrencyId IS NOT NULL
						THEN L.intCurrencyId
					ELSE NULL
					END
			WHERE L.intLoadId = @intLoadId
				AND LD.dblQuantity-ISNULL(LD.dblDeliveredQuantity,0) > 0 
		END
	
		IF NOT EXISTS(SELECT TOP 1 1 FROM @ReceiptStagingTable)
		BEGIN
			IF EXISTS(SELECT 1 FROM tblLGLoadDetailContainerLink WHERE intLoadId = @intLoadId)
			BEGIN
				SET @strErrorMessage = 'All the containers in the inbound shipment has already been received.'
			END
			ELSE 
			BEGIN
				SET @strErrorMessage = 'Item has already been received.'			
			END
			RAISERROR (@strErrorMessage,16,1)
		END

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
			,[intLocationId]
			,[ysnPrice]
			,[ysnSubCurrency]
			,[intCostCurrencyId]
			,[intShipFromId]
			,[strBillOfLadding]
			,[ysnInventoryCost]
			)
		SELECT CV.intEntityVendorId
			,CV.intItemId
			,CV.strCostMethod
			,CASE 
				WHEN CV.strCostMethod = 'Amount'
					THEN 0
				ELSE ROUND((
							CV.[dblShipmentUnitPrice] / (
								SELECT SUM(LOD.dblQuantity)
								FROM tblLGLoadDetail LOD
								WHERE LOD.intLoadId = L.intLoadId
								)
							) * CONVERT(NUMERIC(18, 6), LD.dblQuantity), 2)
				END
			,ROUND((
					CV.[dblTotal] / (
						SELECT SUM(LOD.dblQuantity)
						FROM tblLGLoadDetail LOD
						WHERE LOD.intLoadId = L.intLoadId
						)
					) * LD.dblQuantity, 2)
			,CV.intItemUOMId
			,CD.intContractHeaderId
			,LD.intPContractDetailId
			,1 ysnAccrue
			,'Purchase Contract'
			,NULL
			,L.intCurrencyId
			,LD.intVendorEntityId
			,LD.intPCompanyLocationId
			,0
			,CUR.ysnSubCurrency
			,CV.intCurrencyId
			,EL.intEntityLocationId
			,L.strBLNumber
			,I.ysnInventoryCost
		FROM vyuLGLoadCostForVendor CV
		JOIN tblLGLoadDetail LD ON LD.intLoadDetailId = CV.intLoadDetailId
		JOIN tblLGLoad L ON L.intLoadId = LD.intLoadId
		JOIN tblCTContractDetail CD ON CD.intContractDetailId = CASE 
				WHEN ISNULL(LD.intPContractDetailId, 0) = 0
					THEN LD.intSContractDetailId
				ELSE LD.intPContractDetailId
				END
		JOIN tblICItem I ON I.intItemId = CV.intItemId
		JOIN tblEMEntityLocation EL ON EL.intEntityId = CASE 
				WHEN ISNULL(LD.intPContractDetailId, 0) = 0
					THEN LD.intCustomerEntityId
				ELSE LD.intVendorEntityId
				END
			AND EL.ysnDefaultLocation = 1
		JOIN tblSMCurrency CUR ON CUR.intCurrencyID = CV.intCurrencyId
		WHERE L.intLoadId = @intLoadId
		GROUP BY CV.intEntityVendorId
			,CV.intItemId
			,CV.strCostMethod
			,CV.[dblShipmentUnitPrice]
			,CV.[dblTotal]
			,CV.intItemUOMId
			,CD.intContractHeaderId
			,LD.intPContractDetailId
			,CV.intCurrencyId
			,LD.dblQuantity
			,L.strBLNumber
			,I.ysnInventoryCost
			,CV.intLoadId
			,L.intLoadId
			,LD.intVendorEntityId
			,LD.intPCompanyLocationId
			,EL.intEntityLocationId
			,L.intCurrencyId
			,CUR.ysnSubCurrency

		UNION ALL

		SELECT CLSL.intVendorId
			,LWS.intItemId
			,'Per Unit'
			,LWS.dblUnitRate
			,LWS.dblActualAmount
			,LWS.intItemUOMId
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
			,1
			,'Purchase Contract'
			,NULL
			,L.intCurrencyId
			,(
				SELECT TOP 1 LOD.intVendorEntityId
				FROM tblLGLoadDetail LOD
				WHERE intLoadId = @intLoadId
				)
			,(
				SELECT TOP 1 intPCompanyLocationId
				FROM tblLGLoadDetail
				WHERE intLoadId = @intLoadId
				)
			,0
			,CUR.ysnSubCurrency
			,L.intCurrencyId
			,(
				SELECT TOP 1 EL.intEntityLocationId
				FROM tblLGLoadDetail LD
				JOIN tblCTContractDetail CD ON CD.intContractDetailId = LD.intPContractDetailId
				JOIN tblCTContractHeader CH ON CH.intContractHeaderId = CD.intContractHeaderId
				JOIN tblEMEntityLocation EL ON EL.intEntityId = CH.intEntityId
					AND EL.ysnDefaultLocation = 1
				WHERE LD.intLoadId = @intLoadId
				)
			,L.strBLNumber
			,I.ysnInventoryCost
		FROM tblLGLoad L
		JOIN tblLGLoadWarehouse LW ON LW.intLoadId = L.intLoadId
		JOIN tblLGLoadWarehouseServices LWS ON LW.intLoadWarehouseId = LWS.intLoadWarehouseId
		JOIN tblSMCompanyLocationSubLocation CLSL ON CLSL.intCompanyLocationSubLocationId = LW.intSubLocationId
		JOIN tblICItem I ON I.intItemId = LWS.intItemId
		JOIN tblSMCurrency CUR ON CUR.intCurrencyID = L.intCurrencyId
		WHERE L.intLoadId = @intLoadId

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

		SELECT @intMinInvRecItemId = MIN(intInventoryReceiptItemId)
		FROM tblICInventoryReceiptItem
		WHERE intInventoryReceiptId = @intInventoryReceiptId

		WHILE @intMinInvRecItemId > 0
		BEGIN
			SET @intPContractDetailId = NULL
			SET @dblVoucherQty = NULL
			SET @dblBillQty = NULL

			SELECT @intPContractDetailId = intLineNo
				  ,@intPItemId = intItemId
			FROM tblICInventoryReceiptItem
			WHERE intInventoryReceiptItemId = @intMinInvRecItemId

			SELECT @dblPContractDetailQty = dblQuantity
			FROM tblCTContractDetail
			WHERE intContractDetailId = @intPContractDetailId

			SELECT @intPEntityId = intEntityVendorId
			FROM tblICInventoryReceipt
			WHERE intInventoryReceiptId = @intInventoryReceiptId

			IF EXISTS (
					SELECT TOP 1 1
					FROM tblAPBill BI
					JOIN tblAPBillDetail BID ON BI.intBillId = BID.intBillId
					WHERE BID.intLoadId = @intLoadId
						AND BID.intContractDetailId = @intPContractDetailId
						AND BI.intTransactionType IN (1,2)
						AND BI.intEntityVendorId = @intPEntityId
						AND BID.intItemId = @intPItemId
					)
			BEGIN
				SELECT @dblVoucherQty = BID.dblQtyReceived
				FROM tblAPBill BI
				JOIN tblAPBillDetail BID ON BI.intBillId = BID.intBillId
				WHERE BID.intLoadId = @intLoadId
					AND BID.intContractDetailId = @intPContractDetailId
					AND BI.intTransactionType IN (1,2)
					AND BI.intEntityVendorId = @intPEntityId
					AND BID.intItemId = @intPItemId

				UPDATE tblICInventoryReceiptItem
				SET dblBillQty = (@dblVoucherQty / @dblPContractDetailQty) * dblReceived
				WHERE intInventoryReceiptItemId = @intMinInvRecItemId
			END

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
				,strMarkings
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
				,LC.strMarks
			FROM tblICInventoryReceiptItem RI
			LEFT JOIN tblLGLoadContainer LC ON LC.intLoadContainerId = RI.intContainerId
			WHERE intInventoryReceiptItemId = @intMinInvRecItemId

			SELECT @intMinInvRecItemId = MIN(intInventoryReceiptItemId)
			FROM tblICInventoryReceiptItem
			WHERE intInventoryReceiptId = @intInventoryReceiptId
			  AND intInventoryReceiptItemId > @intMinInvRecItemId
		END
	END
	ELSE 
	BEGIN 
		IF EXISTS (
				SELECT LD.intItemId
				FROM tblLGLoadDetail LD
				JOIN tblICItemUOM U ON U.intItemUOMId = LD.intItemUOMId
				WHERE LD.intLoadId = @intLoadId
					AND LD.intItemId <> U.intItemId
				)
		BEGIN
			UPDATE LD
			SET intItemUOMId = IU.intItemUOMId
			FROM tblLGLoad L
			JOIN tblLGLoadDetail LD ON LD.intLoadId = L.intLoadId
			JOIN tblICItemUOM U ON U.intItemUOMId = LD.intItemUOMId
			JOIN tblICItemUOM IU ON IU.intUnitMeasureId = U.intUnitMeasureId
				AND IU.intItemId = LD.intItemId
			WHERE LD.intLoadId = @intLoadId
				AND LD.intItemId <> U.intItemId

			UPDATE LDCL
			SET intItemUOMId = LD.intItemUOMId
			FROM tblLGLoadDetail LD
			JOIN tblLGLoadDetailContainerLink LDCL ON LDCL.intLoadDetailId = LD.intLoadDetailId
			WHERE LD.intItemUOMId <> LDCL.intItemUOMId AND LD.intLoadId = @intLoadId
		END
	
		IF EXISTS (SELECT 1 FROM tblLGLoadDetailContainerLink WHERE intLoadId = @intLoadId)
		BEGIN
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
				)
			SELECT strReceiptType = 'Purchase Contract'
				,intEntityVendorId = LD.intVendorEntityId --
				,intShipFromId = EL.intEntityLocationId
				,intLocationId = CD.intCompanyLocationId
				,L.strBLNumber --
				,intItemId = LD.intItemId --
				,intItemLocationId = CD.intCompanyLocationId
				,intItemUOMId = LD.intItemUOMId --
				,intContractHeaderId = CD.intContractHeaderId --
				,intContractDetailId = LD.intPContractDetailId --
				,dtmDate = GETDATE()
				,intShipViaId = CD.intShipViaId
				,dblQty = ISNULL(LDCL.dblQuantity, LD.dblQuantity) --
				,intGrossNetUOMId = ISNULL(LD.intWeightItemUOMId, CD.intNetWeightUOMId) --
				,dblGross = ISNULL(LDCL.dblLinkGrossWt, LD.dblGross) --
				,dblNet = ISNULL(LDCL.dblLinkNetWt, LD.dblNet) --
				,dblCost = ISNULL(AD.dblSeqPrice, LD.dblUnitPrice) --
				,intCostUOMId = ISNULL(AD.intSeqPriceUOMId,LD.intPriceUOMId)  --
				,intCurrencyId = CASE WHEN LD.strPriceStatus <> 'Priced' THEN ISNULL(LSC.intMainCurrencyId, LD.intPriceCurrencyId) ELSE ISNULL(SC.intMainCurrencyId, AD.intSeqCurrencyId) END
				,intSubCurrencyCents = ISNULL(SubCurrency.intCent, 1)
				,dblExchangeRate = 1
				,intLotId = NULL
				,intSubLocationId = ISNULL(LW.intSubLocationId, CD.intSubLocationId) --
				,intStorageLocationId = ISNULL(LW.intStorageLocationId, CD.intStorageLocationId) --
				,ysnIsStorage = 0
				,intSourceId = LD.intLoadDetailId --
				,intSourceType = 2
				,strSourceId = L.strLoadNumber --
				,strSourceScreenName = 'Contract'
				,ysnSubCurrency = SubCurrency.ysnSubCurrency
				,intForexRateTypeId = CD.intRateTypeId
				,dblForexRate = CD.dblRate
				,ISNULL(LC.intLoadContainerId, - 1) --
				,L.intFreightTermId
			FROM tblLGLoad L
			JOIN tblLGLoadDetail LD ON L.intLoadId = LD.intLoadId
			JOIN tblCTContractDetail CD ON CD.intContractDetailId = LD.intPContractDetailId
			JOIN tblCTContractHeader CH ON CH.intContractHeaderId = CD.intContractHeaderId
			CROSS APPLY dbo.fnCTGetAdditionalColumnForDetailView(CD.intContractDetailId) AD
			JOIN tblICItemLocation IL ON IL.intItemId = CD.intItemId
				AND IL.intLocationId = CD.intCompanyLocationId
			JOIN tblEMEntityLocation EL ON EL.intEntityId = CH.intEntityId
				AND EL.ysnDefaultLocation = 1
			LEFT JOIN tblLGLoadDetailContainerLink LDCL ON LDCL.intLoadDetailId = LD.intLoadDetailId
			LEFT JOIN tblLGLoadContainer LC ON LC.intLoadContainerId = LDCL.intLoadContainerId
			LEFT JOIN tblSMCurrency SC ON SC.intCurrencyID = AD.intSeqCurrencyId
			LEFT JOIN tblSMCurrency SubCurrency ON SubCurrency.intCurrencyID = CASE 
					WHEN SC.intMainCurrencyId IS NOT NULL
						THEN CD.intCurrencyId
					ELSE NULL
					END
			LEFT JOIN tblSMCurrency LSC ON LSC.intCurrencyID = LD.intPriceCurrencyId
			LEFT JOIN tblSMCurrency LSubCurrency ON LSubCurrency.intCurrencyID = CASE 
					WHEN SC.intMainCurrencyId IS NOT NULL
						THEN CD.intCurrencyId
					ELSE NULL
					END
			LEFT JOIN tblLGLoadWarehouseContainer LWC ON LWC.intLoadContainerId = LC.intLoadContainerId
			LEFT JOIN tblLGLoadWarehouse LW ON LW.intLoadWarehouseId = LWC.intLoadWarehouseId
			WHERE CAST((
						CASE 
							WHEN ISNULL(LDCL.dblReceivedQty, 0) = 0
								THEN 0
							ELSE 1
							END
						) AS BIT) = 0
				AND L.intLoadId = @intLoadId
			ORDER BY LDCL.intLoadDetailContainerLinkId
		END
		ELSE
		BEGIN
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
				)
			SELECT strReceiptType = 'Purchase Contract'
				,intEntityVendorId = LD.intVendorEntityId --
				,intShipFromId = EL.intEntityLocationId
				,intLocationId = CD.intCompanyLocationId
				,L.strBLNumber --
				,intItemId = LD.intItemId --
				,intItemLocationId = CD.intCompanyLocationId
				,intItemUOMId = LD.intItemUOMId --
				,intContractHeaderId = CD.intContractHeaderId --
				,intContractDetailId = LD.intPContractDetailId --
				,dtmDate = GETDATE()
				,intShipViaId = CD.intShipViaId
				,dblQty = LD.dblQuantity-ISNULL(LD.dblDeliveredQuantity,0) --
				,intGrossNetUOMId = ISNULL(LD.intWeightItemUOMId, CD.intNetWeightUOMId) --
				,dblGross =  LD.dblGross - ISNULL(LD.dblDeliveredGross,0) --
				,dblNet = LD.dblNet -ISNULL(LD.dblDeliveredNet,0) --
				,dblCost = ISNULL(AD.dblSeqPrice, LD.dblUnitPrice) --
				,intCostUOMId = ISNULL(AD.intSeqPriceUOMId,LD.intPriceUOMId)  --
				,intCurrencyId = CASE WHEN LD.strPriceStatus <> 'Priced' THEN ISNULL(LSC.intMainCurrencyId, LD.intPriceCurrencyId) ELSE ISNULL(SC.intMainCurrencyId, AD.intSeqCurrencyId) END
				,intSubCurrencyCents = ISNULL(SubCurrency.intCent, 1)
				,dblExchangeRate = 1
				,intLotId = NULL
				,intSubLocationId = ISNULL(CD.intSubLocationId, LD.intPSubLocationId) --
				,intStorageLocationId = CD.intStorageLocationId --
				,ysnIsStorage = 0
				,intSourceId = LD.intLoadDetailId --
				,intSourceType = 2
				,strSourceId = L.strLoadNumber --
				,strSourceScreenName = 'Contract'
				,ysnSubCurrency = SubCurrency.ysnSubCurrency
				,intForexRateTypeId = CD.intRateTypeId
				,dblForexRate = CD.dblRate
				,- 1 --
				,L.intFreightTermId
			FROM tblLGLoad L
			JOIN tblLGLoadDetail LD ON L.intLoadId = LD.intLoadId
			JOIN tblCTContractDetail CD ON CD.intContractDetailId = LD.intPContractDetailId
			JOIN tblCTContractHeader CH ON CH.intContractHeaderId = CD.intContractHeaderId
			CROSS APPLY dbo.fnCTGetAdditionalColumnForDetailView(CD.intContractDetailId) AD
			JOIN tblICItemLocation IL ON IL.intItemId = CD.intItemId
				AND IL.intLocationId = CD.intCompanyLocationId
			JOIN tblEMEntityLocation EL ON EL.intEntityId = CH.intEntityId
				AND EL.ysnDefaultLocation = 1
			LEFT JOIN tblSMCurrency SC ON SC.intCurrencyID = AD.intSeqCurrencyId
			LEFT JOIN tblSMCurrency SubCurrency ON SubCurrency.intCurrencyID = CASE 
					WHEN SC.intMainCurrencyId IS NOT NULL
						THEN CD.intCurrencyId
					ELSE NULL
					END
			LEFT JOIN tblSMCurrency LSC ON LSC.intCurrencyID = LD.intPriceCurrencyId
			LEFT JOIN tblSMCurrency LSubCurrency ON LSubCurrency.intCurrencyID = CASE 
					WHEN SC.intMainCurrencyId IS NOT NULL
						THEN CD.intCurrencyId
					ELSE NULL
					END
			WHERE L.intLoadId = @intLoadId
				AND LD.dblQuantity-ISNULL(LD.dblDeliveredQuantity,0) > 0
		END

		IF NOT EXISTS(SELECT TOP 1 1 FROM @ReceiptStagingTable)
		BEGIN
			IF EXISTS(SELECT 1 FROM tblLGLoadDetailContainerLink WHERE intLoadId = @intLoadId)
			BEGIN
				SET @strErrorMessage = 'All the containers in the inbound shipment has already been received.'
			END
			ELSE 
			BEGIN
				SET @strErrorMessage = 'Item has already been received.'			
			END
			RAISERROR (@strErrorMessage,16,1)
		END

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
			,[intLocationId]
			,[ysnPrice]
			,[ysnSubCurrency]
			,[intCostCurrencyId]
			,[intShipFromId]
			,[strBillOfLadding]
			,[ysnInventoryCost]
			)
		SELECT CV.intEntityVendorId
			,CV.intItemId
			,CV.strCostMethod
			,CASE 
				WHEN CV.strCostMethod = 'Amount'
					THEN 0
				ELSE ROUND((
							CV.[dblShipmentUnitPrice] / (
								SELECT SUM(LOD.dblQuantity)
								FROM tblLGLoadDetail LOD
								WHERE LOD.intLoadId = L.intLoadId
								)
							) * CONVERT(NUMERIC(18, 6), LD.dblQuantity), 2)
				END
			,ROUND((
					CV.[dblTotal] / (
						SELECT SUM(LOD.dblQuantity)
						FROM tblLGLoadDetail LOD
						WHERE LOD.intLoadId = L.intLoadId
						)
					) * LD.dblQuantity, 2)
			,CV.intItemUOMId
			,CD.intContractHeaderId
			,LD.intPContractDetailId
			,1 ysnAccrue
			,'Purchase Contract'
			,NULL
			,L.intCurrencyId
			,LD.intVendorEntityId
			,LD.intPCompanyLocationId
			,0
			,CUR.ysnSubCurrency
			,CV.intCurrencyId
			,EL.intEntityLocationId
			,L.strBLNumber
			,I.ysnInventoryCost
		FROM vyuLGLoadCostForVendor CV
		JOIN tblLGLoadDetail LD ON LD.intLoadDetailId = CV.intLoadDetailId
		JOIN tblLGLoad L ON L.intLoadId = LD.intLoadId
		JOIN tblCTContractDetail CD ON CD.intContractDetailId = CASE 
				WHEN ISNULL(LD.intPContractDetailId, 0) = 0
					THEN LD.intSContractDetailId
				ELSE LD.intPContractDetailId
				END
		JOIN tblICItem I ON I.intItemId = CV.intItemId
		JOIN tblEMEntityLocation EL ON EL.intEntityId = CASE 
				WHEN ISNULL(LD.intPContractDetailId, 0) = 0
					THEN LD.intCustomerEntityId
				ELSE LD.intVendorEntityId
				END
			AND EL.ysnDefaultLocation = 1
		JOIN tblSMCurrency CUR ON CUR.intCurrencyID = CV.intCurrencyId
		WHERE L.intLoadId = @intLoadId
		GROUP BY CV.intEntityVendorId
			,CV.intItemId
			,CV.strCostMethod
			,CV.[dblShipmentUnitPrice]
			,CV.[dblTotal]
			,CV.intItemUOMId
			,CD.intContractHeaderId
			,LD.intPContractDetailId
			,CV.intCurrencyId
			,LD.dblQuantity
			,L.strBLNumber
			,I.ysnInventoryCost
			,CV.intLoadId
			,L.intLoadId
			,LD.intVendorEntityId
			,LD.intPCompanyLocationId
			,EL.intEntityLocationId
			,L.intCurrencyId
			,CUR.ysnSubCurrency

		UNION ALL

		SELECT CLSL.intVendorId
			,LWS.intItemId
			,'Per Unit'
			,LWS.dblUnitRate
			,LWS.dblActualAmount
			,LWS.intItemUOMId
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
			,1
			,'Purchase Contract'
			,NULL
			,L.intCurrencyId
			,(
				SELECT TOP 1 LOD.intVendorEntityId
				FROM tblLGLoadDetail LOD
				WHERE intLoadId = @intLoadId
				)
			,(
				SELECT TOP 1 intPCompanyLocationId
				FROM tblLGLoadDetail
				WHERE intLoadId = @intLoadId
				)
			,0
			,CUR.ysnSubCurrency
			,L.intCurrencyId
			,(
				SELECT TOP 1 EL.intEntityLocationId
				FROM tblLGLoadDetail LD
				JOIN tblCTContractDetail CD ON CD.intContractDetailId = LD.intPContractDetailId
				JOIN tblCTContractHeader CH ON CH.intContractHeaderId = CD.intContractHeaderId
				JOIN tblEMEntityLocation EL ON EL.intEntityId = CH.intEntityId
					AND EL.ysnDefaultLocation = 1
				WHERE LD.intLoadId = @intLoadId
				)
			,L.strBLNumber
			,I.ysnInventoryCost
		FROM tblLGLoad L
		JOIN tblLGLoadWarehouse LW ON LW.intLoadId = L.intLoadId
		JOIN tblLGLoadWarehouseServices LWS ON LW.intLoadWarehouseId = LWS.intLoadWarehouseId
		JOIN tblSMCompanyLocationSubLocation CLSL ON CLSL.intCompanyLocationSubLocationId = LW.intSubLocationId
		JOIN tblICItem I ON I.intItemId = LWS.intItemId
		JOIN tblSMCurrency CUR ON CUR.intCurrencyID = L.intCurrencyId
		WHERE L.intLoadId = @intLoadId

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

		SELECT @intMinInvRecItemId = MIN(intInventoryReceiptItemId)
		FROM tblICInventoryReceiptItem
		WHERE intInventoryReceiptId = @intInventoryReceiptId

		WHILE @intMinInvRecItemId > 0
		BEGIN
			SET @intPContractDetailId = NULL
			SET @dblVoucherQty = NULL
			SET @dblBillQty = NULL

			SELECT @intPContractDetailId = intLineNo
				  ,@intPItemId = intItemId
			FROM tblICInventoryReceiptItem
			WHERE intInventoryReceiptItemId = @intMinInvRecItemId

			SELECT @dblPContractDetailQty = dblQuantity
			FROM tblCTContractDetail
			WHERE intContractDetailId = @intPContractDetailId

			SELECT @intPEntityId = intEntityVendorId
			FROM tblICInventoryReceipt
			WHERE intInventoryReceiptId = @intInventoryReceiptId

			IF EXISTS (
					SELECT TOP 1 1
					FROM tblAPBill BI
					JOIN tblAPBillDetail BID ON BI.intBillId = BID.intBillId
					WHERE BID.intLoadId = @intLoadId
						AND BID.intContractDetailId = @intPContractDetailId
						AND BI.intTransactionType IN (1,2)
						AND BI.intEntityVendorId = @intPEntityId
						AND BID.intItemId = @intPItemId
					)
			BEGIN
				SELECT @dblVoucherQty = BID.dblQtyReceived
				FROM tblAPBill BI
				JOIN tblAPBillDetail BID ON BI.intBillId = BID.intBillId
				WHERE BID.intLoadId = @intLoadId
					AND BID.intContractDetailId = @intPContractDetailId
					AND BI.intTransactionType IN (1,2)
					AND BI.intEntityVendorId = @intPEntityId
					AND BID.intItemId = @intPItemId

				UPDATE tblICInventoryReceiptItem
				SET dblBillQty = (@dblVoucherQty / @dblPContractDetailQty) * dblReceived
				WHERE intInventoryReceiptItemId = @intMinInvRecItemId
			END

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
				,strMarkings
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
				,LC.strMarks
			FROM tblICInventoryReceiptItem RI
			LEFT JOIN tblLGLoadContainer LC ON LC.intLoadContainerId = RI.intContainerId
			WHERE intInventoryReceiptItemId = @intMinInvRecItemId

			SELECT @intMinInvRecItemId = MIN(intInventoryReceiptItemId)
			FROM tblICInventoryReceiptItem
			WHERE intInventoryReceiptId = @intInventoryReceiptId
			  AND intInventoryReceiptItemId > @intMinInvRecItemId
		END
	END


END TRY

BEGIN CATCH
	SET @ErrMsg = ERROR_MESSAGE()
	RAISERROR (@ErrMsg,18,1,'WITH NOWAIT')
END CATCH