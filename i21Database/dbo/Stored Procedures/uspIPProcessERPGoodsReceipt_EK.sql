CREATE PROCEDURE uspIPProcessERPGoodsReceipt_EK @strInfo1 NVARCHAR(MAX) = '' OUT
	,@strInfo2 NVARCHAR(MAX) = '' OUT
	,@intNoOfRowsAffected INT = 0 OUT
AS
BEGIN TRY
	SET QUOTED_IDENTIFIER OFF
	SET ANSI_NULLS ON
	SET NOCOUNT ON
	SET XACT_ABORT ON

	DECLARE @ErrMsg NVARCHAR(MAX)
		,@strFinalErrMsg NVARCHAR(MAX) = ''
		,@intUserId INT
		,@dtmDateCreated DATETIME = GETDATE()
		,@strError NVARCHAR(MAX)
	DECLARE @intTrxSequenceNo BIGINT
		,@dtmCreatedDate DATETIME
	DECLARE @strERPReceiptNo NVARCHAR(50)
		,@dtmReceiptDate DATETIME
		,@strVendorAccountNo NVARCHAR(100)
		,@strBLNumber NVARCHAR(50)
		,@strLocationName NVARCHAR(50)
		,@strWarehouseRefNo NVARCHAR(50)
		,@strOrderType NVARCHAR(50)
	DECLARE @intStageReceiptId INT
		,@strReceiptNo NVARCHAR(50)
	DECLARE @intEntityId INT
		,@intCompanyLocationId INT
		,@intInventoryReceiptId INT
		,@intNewStageReceiptId INT
		,@strActualLocationName NVARCHAR(100)
	DECLARE @strERPPONumber NVARCHAR(50)
		,@strERPItemNumber NVARCHAR(50)
		,@strERPPONumber2 NVARCHAR(50)
		,@strItemNo NVARCHAR(50)
		,@strSubLocationName NVARCHAR(50)
		,@strStorageLocationName NVARCHAR(50)
		,@dblQuantity NUMERIC(18, 6)
		,@strQuantityUOM NVARCHAR(50)
		,@dblGrossWeight NUMERIC(18, 6)
		,@dblTareWeight NUMERIC(18, 6)
		,@dblNetWeight NUMERIC(18, 6)
		,@strNetWeightUOM NVARCHAR(50)
		,@dblCost NUMERIC(38, 20)
		,@strCostUOM NVARCHAR(50)
		,@strCostCurrency NVARCHAR(50)
		,@strContainerNumber NVARCHAR(100)
	DECLARE @intStageReceiptItemId INT
		,@intItemId INT
		,@intStockItemUOMId INT
		,@intSubLocationId INT
		,@intStorageLocationId INT
		,@intQtyUnitMeasureId INT
		,@intQtyItemUOMId INT
		,@intNetWeightUnitMeasureId INT
		,@intNetWeightItemUOMId INT
		,@intCostUnitMeasureId INT
		,@intCostItemUOMId INT
		,@intDefaultCurrencyId INT
		,@intCostCurrencyId INT
		,@intMainCurrencyId INT
		,@ysnSubCurrency BIT
		,@intLoadId INT
		,@intLoadDetailId INT
		,@ysnPosted BIT
		,@intContractHeaderId INT
		,@intContractDetailId INT
		,@intBatchId INT
		,@dblDeliveredQuantity NUMERIC(18, 6)
	DECLARE @strLotNo NVARCHAR(50)
		,@dblLotQuantity NUMERIC(18, 6)
		,@strLotQuantityUOM NVARCHAR(50)
		,@dblLotGrossWeight NUMERIC(18, 6)
		,@dblLotTareWeight NUMERIC(18, 6)
		,@dblLotNetWeight NUMERIC(18, 6)
		,@strLotWeightUOM NVARCHAR(50)
		,@strLotStorageLocationName NVARCHAR(50)
		,@strLotMarks NVARCHAR(50)
		,@dtmLotManufacturedDate DATETIME
		,@dtmLotExpiryDate DATETIME
	DECLARE @intStageReceiptItemLotId INT
		,@intLotQtyUnitMeasureId INT
		,@intLotQtyItemUOMId INT
		,@intLotNetWeightUnitMeasureId INT
		,@intLotNetWeightItemUOMId INT
		,@intLotStorageLocationId INT
	DECLARE @tblIPInvReceiptStage TABLE (intStageReceiptId INT)
	DECLARE @ReceiptStagingTable ReceiptStagingTable
	DECLARE @OtherCharges ReceiptOtherChargesTableType
	DECLARE @LotEntries ReceiptItemLotStagingTable

	INSERT INTO @tblIPInvReceiptStage (intStageReceiptId)
	SELECT intStageReceiptId
	FROM tblIPInvReceiptStage
	WHERE intStatusId IS NULL

	SELECT @intStageReceiptId = MIN(intStageReceiptId)
	FROM @tblIPInvReceiptStage

	IF @intStageReceiptId IS NULL
	BEGIN
		RETURN
	END

	UPDATE S
	SET S.intStatusId = - 1
	FROM tblIPInvReceiptStage S
	JOIN @tblIPInvReceiptStage TS ON TS.intStageReceiptId = S.intStageReceiptId

	SELECT @intUserId = intEntityId
	FROM tblSMUserSecurity WITH (NOLOCK)
	WHERE strUserName = 'IRELYADMIN'

	SELECT @strInfo1 = ''
		,@strInfo2 = ''

	SELECT @strInfo1 = @strInfo1 + ISNULL(b.strERPReceiptNo, '') + ', '
	FROM @tblIPInvReceiptStage a
	JOIN tblIPInvReceiptStage b ON a.intStageReceiptId = b.intStageReceiptId

	IF Len(@strInfo1) > 0
	BEGIN
		SELECT @strInfo1 = Left(@strInfo1, Len(@strInfo1) - 1)
	END

	WHILE (@intStageReceiptId IS NOT NULL)
	BEGIN
		BEGIN TRY
			SELECT @intTrxSequenceNo = NULL
				,@dtmCreatedDate = NULL

			SELECT @strERPReceiptNo = NULL
				,@dtmReceiptDate = NULL
				,@strVendorAccountNo = NULL
				,@strBLNumber = NULL
				,@strLocationName = NULL
				,@strWarehouseRefNo = NULL
				,@strReceiptNo = NULL
				,@strOrderType = NULL

			SELECT @intEntityId = NULL
				,@intCompanyLocationId = NULL
				,@intInventoryReceiptId = NULL
				,@intNewStageReceiptId = NULL
				,@strActualLocationName = NULL

			SELECT @intStageReceiptItemId = NULL
				,@intStageReceiptItemLotId = NULL

			SELECT @intTrxSequenceNo = intTrxSequenceNo
				,@dtmCreatedDate = dtmCreated
				,@strERPReceiptNo = strERPReceiptNo
				,@dtmReceiptDate = dtmReceiptDate
				,@strVendorAccountNo = strVendorAccountNo
				,@strBLNumber = strBLNumber
				,@strLocationName = strLocationName
				,@strWarehouseRefNo = strWarehouseRefNo
				,@strOrderType = strOrderType
			FROM tblIPInvReceiptStage
			WHERE intStageReceiptId = @intStageReceiptId

			IF ISNULL(@strERPReceiptNo, '') = ''
			BEGIN
				SELECT @strError = 'SAP Receipt No cannot be blank.'

				RAISERROR (
						@strError
						,16
						,1
						)
			END

			IF @dtmReceiptDate IS NULL
			BEGIN
				SELECT @strError = 'Receipt Date cannot be blank.'

				RAISERROR (
						@strError
						,16
						,1
						)
			END

			--SELECT @intEntityId = t.intEntityId
			--FROM dbo.tblEMEntity t WITH (NOLOCK)
			--JOIN dbo.tblEMEntityType ET WITH (NOLOCK) ON ET.intEntityId = t.intEntityId
			--JOIN tblAPVendor V WITH (NOLOCK) ON V.intEntityId = t.intEntityId
			--WHERE ET.strType = 'Vendor'
			--	AND V.strVendorAccountNum = @strVendorAccountNo
			--IF ISNULL(@intEntityId, 0) = 0
			--BEGIN
			--	RAISERROR (
			--			'Invalid Vendor. '
			--			,16
			--			,1
			--			)
			--END
			SELECT @intCompanyLocationId = intCompanyLocationId
				,@strActualLocationName = strLocationName
			FROM dbo.tblSMCompanyLocation
			WHERE strVendorRefNoPrefix = @strLocationName
				AND strLocationType = 'Plant'

			IF @intCompanyLocationId IS NULL
			BEGIN
				RAISERROR (
						'Company Location not found.'
						,16
						,1
						)
			END

			IF NOT EXISTS (
					SELECT 1
					FROM tblIPInvReceiptItemStage
					WHERE intStageReceiptId = @intStageReceiptId
					)
			BEGIN
				RAISERROR (
						'Receipt Item is required. '
						,16
						,1
						)
			END

			IF NOT EXISTS (
					SELECT 1
					FROM tblIPInvReceiptItemLotStage
					WHERE intStageReceiptId = @intStageReceiptId
					)
			BEGIN
				RAISERROR (
						'Receipt Item Lot is required.'
						,16
						,1
						)
			END

			BEGIN TRAN

			DELETE
			FROM @ReceiptStagingTable

			DELETE
			FROM @LotEntries

			SELECT @intStageReceiptItemId = MIN(intStageReceiptItemId)
			FROM tblIPInvReceiptItemStage WITH (NOLOCK)
			WHERE intStageReceiptId = @intStageReceiptId

			WHILE @intStageReceiptItemId IS NOT NULL
			BEGIN
				SELECT @strERPPONumber = NULL
					,@strERPItemNumber = NULL
					,@strERPPONumber2 = NULL
					,@strItemNo = NULL
					,@strSubLocationName = NULL
					,@strStorageLocationName = NULL
					,@dblQuantity = NULL
					,@strQuantityUOM = NULL
					,@dblGrossWeight = NULL
					,@dblTareWeight = NULL
					,@dblNetWeight = NULL
					,@strNetWeightUOM = NULL
					,@dblCost = NULL
					,@strCostUOM = NULL
					,@strCostCurrency = NULL
					,@strContainerNumber = NULL

				SELECT @intItemId = NULL
					,@intStockItemUOMId = NULL
					,@intSubLocationId = NULL
					,@intStorageLocationId = NULL
					,@intQtyUnitMeasureId = NULL
					,@intQtyItemUOMId = NULL
					,@intNetWeightUnitMeasureId = NULL
					,@intNetWeightItemUOMId = NULL
					,@intCostUnitMeasureId = NULL
					,@intCostItemUOMId = NULL
					,@intDefaultCurrencyId = NULL
					,@intCostCurrencyId = NULL
					,@intMainCurrencyId = NULL
					,@ysnSubCurrency = NULL
					,@intLoadId = NULL
					,@intLoadDetailId = NULL
					,@ysnPosted = NULL
					,@intContractHeaderId = NULL
					,@intContractDetailId = NULL
					,@intBatchId = NULL
					,@dblDeliveredQuantity = NULL

				SELECT @strERPPONumber = RIS.strERPPONumber
					,@strERPItemNumber = RIS.strERPItemNumber
					,@strERPPONumber2 = RIS.strERPPONumber
					,@strItemNo = RIS.strItemNo
					,@strSubLocationName = RIS.strSubLocationName
					,@strStorageLocationName = RIS.strStorageLocationName
					,@dblQuantity = ISNULL(RIS.dblQuantity, 0)
					,@strQuantityUOM = RIS.strQuantityUOM
					,@dblGrossWeight = ISNULL(RIS.dblGrossWeight, 0)
					,@dblTareWeight = ISNULL(RIS.dblTareWeight, 0)
					,@dblNetWeight = ISNULL(RIS.dblNetWeight, 0)
					,@strNetWeightUOM = RIS.strNetWeightUOM
					,@dblCost = ISNULL(RIS.dblCost, 0)
					,@strCostUOM = RIS.strCostUOM
					,@strCostCurrency = RIS.strCostCurrency
					,@strContainerNumber = RIS.strContainerNumber
				FROM tblIPInvReceiptItemStage RIS WITH (NOLOCK)
				WHERE RIS.intStageReceiptItemId = @intStageReceiptItemId

				SELECT @intItemId = t.intItemId
				FROM tblICItem t WITH (NOLOCK)
				WHERE t.strItemNo = @strItemNo

				IF ISNULL(@intItemId, 0) = 0
				BEGIN
					RAISERROR (
							'Invalid Item No. '
							,16
							,1
							)
				END

				SELECT @intStockItemUOMId = t.intItemUOMId
				FROM tblICItemUOM t WITH (NOLOCK)
				WHERE t.intItemId = @intItemId
					AND t.ysnStockUnit = 1

				SELECT @intSubLocationId = t.intCompanyLocationSubLocationId
				FROM tblSMCompanyLocationSubLocation t WITH (NOLOCK)
				WHERE t.strSubLocationName = @strActualLocationName + ' / ' + @strSubLocationName
					AND t.intCompanyLocationId = @intCompanyLocationId

				IF ISNULL(@intSubLocationId, 0) = 0
				BEGIN
					SELECT @intSubLocationId = t.intCompanyLocationSubLocationId
					FROM tblSMCompanyLocationSubLocation t WITH (NOLOCK)
					WHERE t.strSubLocationName = @strSubLocationName
						AND t.intCompanyLocationId = @intCompanyLocationId
				END

				IF ISNULL(@intSubLocationId, 0) = 0
				BEGIN
					RAISERROR (
							'Invalid Sub Location. '
							,16
							,1
							)
				END

				SELECT @intStorageLocationId = t.intStorageLocationId
				FROM tblICStorageLocation t WITH (NOLOCK)
				WHERE t.strName = @strStorageLocationName
					AND t.intSubLocationId = @intSubLocationId

				IF ISNULL(@intStorageLocationId, 0) = 0
				BEGIN
					SELECT TOP 1 @intStorageLocationId = t.intStorageLocationId
					FROM tblICStorageLocation t WITH (NOLOCK)
					WHERE t.intSubLocationId = @intSubLocationId
						AND t.strName = 'SU'
				
					IF ISNULL(@intStorageLocationId, 0) = 0
					BEGIN
						RAISERROR (
								'Default Storage Unit is not configured. '
								,16
								,1
								)
					END
				END

				IF @dblQuantity <= 0
				BEGIN
					RAISERROR (
							'Invalid Quantity. '
							,16
							,1
							)
				END

				SELECT @intQtyUnitMeasureId = t.intUnitMeasureId
				FROM tblICUnitMeasure t WITH (NOLOCK)
				WHERE t.strUnitMeasure = @strQuantityUOM

				IF ISNULL(@intQtyUnitMeasureId, 0) = 0
				BEGIN
					RAISERROR (
							'Invalid Quantity UOM. '
							,16
							,1
							)
				END
				ELSE
				BEGIN
					SELECT @intQtyItemUOMId = intItemUOMId
					FROM tblICItemUOM t WITH (NOLOCK)
					WHERE t.intItemId = @intItemId
						AND t.intUnitMeasureId = @intQtyUnitMeasureId

					IF ISNULL(@intQtyItemUOMId, 0) = 0
					BEGIN
						RAISERROR (
								'Quantity UOM does not belongs to the Item. '
								,16
								,1
								)
					END
				END

				IF @dblGrossWeight <= 0
				BEGIN
					RAISERROR (
							'Invalid Gross Weight. '
							,16
							,1
							)
				END

				IF @dblNetWeight <= 0
				BEGIN
					RAISERROR (
							'Invalid Net Weight. '
							,16
							,1
							)
				END

				SELECT @intNetWeightUnitMeasureId = t.intUnitMeasureId
				FROM tblICUnitMeasure t WITH (NOLOCK)
				WHERE t.strUnitMeasure = @strNetWeightUOM

				IF ISNULL(@intNetWeightUnitMeasureId, 0) = 0
				BEGIN
					RAISERROR (
							'Invalid Net Weight UOM. '
							,16
							,1
							)
				END
				ELSE
				BEGIN
					SELECT @intNetWeightItemUOMId = intItemUOMId
					FROM tblICItemUOM t WITH (NOLOCK)
					WHERE t.intItemId = @intItemId
						AND t.intUnitMeasureId = @intNetWeightUnitMeasureId

					IF ISNULL(@intNetWeightItemUOMId, 0) = 0
					BEGIN
						RAISERROR (
								'Net Weight UOM does not belongs to the Item. '
								,16
								,1
								)
					END
				END

				--IF @dblCost <= 0
				--BEGIN
				--	RAISERROR (
				--			'Invalid Cost. '
				--			,16
				--			,1
				--			)
				--END

				SELECT @intCostUnitMeasureId = t.intUnitMeasureId
				FROM tblICUnitMeasure t WITH (NOLOCK)
				WHERE t.strUnitMeasure = @strCostUOM

				IF ISNULL(@intCostUnitMeasureId, 0) = 0
				BEGIN
					RAISERROR (
							'Invalid Cost UOM. '
							,16
							,1
							)
				END

				IF ISNULL(@strCostCurrency, '') = ''
				BEGIN
					RAISERROR (
							'Invalid Cost Currency. '
							,16
							,1
							)
				END

				IF @dblCost >= 0
					AND ISNULL(@strCostUOM, '') <> ''
					AND ISNULL(@strCostCurrency, '') <> ''
				BEGIN
					SELECT @intCostUnitMeasureId = t.intUnitMeasureId
					FROM tblICUnitMeasure t WITH (NOLOCK)
					WHERE t.strUnitMeasure = @strCostUOM

					IF ISNULL(@intCostUnitMeasureId, 0) = 0
					BEGIN
						RAISERROR (
								'Invalid Cost UOM. '
								,16
								,1
								)
					END
					ELSE
					BEGIN
						SELECT @intCostItemUOMId = intItemUOMId
						FROM tblICItemUOM t WITH (NOLOCK)
						WHERE t.intItemId = @intItemId
							AND t.intUnitMeasureId = @intCostUnitMeasureId

						IF ISNULL(@intCostItemUOMId, 0) = 0
						BEGIN
							RAISERROR (
									'Cost UOM does not belongs to the Item. '
									,16
									,1
									)
						END
					END

					SELECT TOP 1 @intDefaultCurrencyId = intDefaultCurrencyId
					FROM tblSMCompanyPreference t WITH (NOLOCK)

					SELECT @intCostCurrencyId = t.intCurrencyID
						,@intMainCurrencyId = t.intMainCurrencyId
						,@ysnSubCurrency = t.ysnSubCurrency
					FROM tblSMCurrency t WITH (NOLOCK)
					WHERE t.strCurrency = @strCostCurrency

					IF @ysnSubCurrency = 1
						SELECT @intCostCurrencyId = @intMainCurrencyId
							-- Cost UOM Conversion
							--SELECT @dblNewCost = dbo.fnCTConvertQtyToTargetItemUOM(@intCostItemUOMId, @intStockItemUOMId, @dblCost)
				END

				SELECT @intStageReceiptItemLotId = MIN(intStageReceiptItemLotId)
				FROM tblIPInvReceiptItemLotStage WITH (NOLOCK)
				WHERE intStageReceiptId = @intStageReceiptId
					AND intStageReceiptItemId = @intStageReceiptItemId

				WHILE @intStageReceiptItemLotId IS NOT NULL
				BEGIN
					SELECT @strLotNo = NULL
						,@dblLotQuantity = NULL
						,@strLotQuantityUOM = NULL
						,@dblLotGrossWeight = NULL
						,@dblLotTareWeight = NULL
						,@dblLotNetWeight = NULL
						,@strLotWeightUOM = NULL
						,@strLotStorageLocationName = NULL
						,@strLotMarks = NULL
						,@dtmLotManufacturedDate = NULL
						,@dtmLotExpiryDate = NULL

					SELECT @intLotQtyUnitMeasureId = NULL
						,@intLotQtyItemUOMId = NULL
						,@intLotNetWeightUnitMeasureId = NULL
						,@intLotNetWeightItemUOMId = NULL
						,@intLotStorageLocationId = NULL

					SELECT @strERPPONumber = NULL
						,@strERPItemNumber = NULL

					SELECT @strLotNo = strLotNo
						,@dblLotQuantity = ISNULL(dblQuantity, 0)
						,@strLotQuantityUOM = strQuantityUOM
						,@dblLotGrossWeight = ISNULL(dblGrossWeight, 0)
						,@dblLotTareWeight = ISNULL(dblTareWeight, 0)
						,@dblLotNetWeight = ISNULL(dblNetWeight, 0)
						,@strLotWeightUOM = strWeightUOM
						,@strLotStorageLocationName = strStorageLocationName
						,@strLotMarks = strMarks
						,@dtmLotManufacturedDate = dtmManufacturedDate
						,@dtmLotExpiryDate = dtmExpiryDate
					FROM tblIPInvReceiptItemLotStage WITH (NOLOCK)
					WHERE intStageReceiptItemLotId = @intStageReceiptItemLotId

					IF ISNULL(@strLotNo, '') = ''
					BEGIN
						RAISERROR (
								'Batch Id cannot be empty. '
								,16
								,1
								)
					END

					SELECT TOP 1 @strERPPONumber = strERPPONumber
						,@strERPItemNumber = strERPPOLineNo
					FROM tblMFBatch B WITH (NOLOCK)
					WHERE B.strBatchId = @strLotNo
						--AND B.intLocationId = @intCompanyLocationId

					IF ISNULL(@strERPPONumber, '') = ''
					BEGIN
						RAISERROR (
								'Invalid SAP PO No. '
								,16
								,1
								)
					END

					IF ISNULL(@strERPItemNumber, '') = ''
					BEGIN
						RAISERROR (
								'Invalid SAP PO Item No. '
								,16
								,1
								)
					END

					UPDATE B
					SET B.strERPPONumber2 = @strERPPONumber2
					FROM tblMFBatch B
					WHERE B.strBatchId = @strLotNo
						--AND B.intLocationId = @intCompanyLocationId

					SELECT TOP 1 @intLoadId = L.intLoadId
						,@intLoadDetailId = LD.intLoadDetailId
						,@ysnPosted = L.ysnPosted
						,@intBatchId = LD.intBatchId
						,@dblDeliveredQuantity = LD.dblDeliveredQuantity
					FROM tblLGLoad L WITH (NOLOCK)
					JOIN tblLGLoadDetail LD WITH (NOLOCK) ON LD.intLoadId = L.intLoadId
						AND L.intShipmentType = 1
						AND L.intShipmentStatus <> 10
						AND L.strExternalShipmentNumber = @strERPPONumber
						AND LD.strExternalShipmentItemNumber = @strERPItemNumber
					ORDER BY L.intLoadId DESC

					IF ISNULL(@intLoadId, 0) = 0
					BEGIN
						RAISERROR (
								'Invalid Load. '
								,16
								,1
								)
					END

					IF ISNULL(@ysnPosted, 0) = 0
					BEGIN
						RAISERROR (
								'Load is not yet posted. '
								,16
								,1
								)
					END

					IF ISNULL(@intBatchId, 0) = 0
					BEGIN
						RAISERROR (
								'Load Item is not associated with Batch. '
								,16
								,1
								)
					END

					IF ISNULL(@dblDeliveredQuantity, 0) > 0
					BEGIN
						RAISERROR (
								'Load Item is already received. '
								,16
								,1
								)
					END

					SELECT @intContractDetailId = LD.intPContractDetailId
						,@intContractHeaderId = CD.intContractHeaderId
					FROM tblLGLoadDetail LD WITH (NOLOCK)
					LEFT JOIN tblCTContractDetail CD WITH (NOLOCK) ON CD.intContractDetailId = LD.intPContractDetailId
						AND LD.intLoadDetailId = @intLoadDetailId

					IF @dblLotQuantity <= 0
					BEGIN
						RAISERROR (
								'Invalid Detail Quantity. '
								,16
								,1
								)
					END

					SELECT @intLotQtyUnitMeasureId = t.intUnitMeasureId
					FROM tblICUnitMeasure t WITH (NOLOCK)
					WHERE t.strUnitMeasure = @strLotQuantityUOM

					IF ISNULL(@intLotQtyUnitMeasureId, 0) = 0
					BEGIN
						RAISERROR (
								'Invalid Detail Quantity UOM. '
								,16
								,1
								)
					END
					ELSE
					BEGIN
						--SELECT @intLotQtyItemUOMId = intItemUOMId
						--FROM tblICItemUOM t WITH (NOLOCK)
						--WHERE t.intItemId = @intItemId
						--	AND t.intUnitMeasureId = @intLotQtyUnitMeasureId

						-- Take Qty UOM from Batch
						SELECT TOP 1 @intQtyItemUOMId = IUOM.intItemUOMId
						FROM tblMFBatch B WITH (NOLOCK)
						JOIN tblICItemUOM IUOM WITH (NOLOCK) ON IUOM.intItemId = B.intTealingoItemId
							AND IUOM.intUnitMeasureId = B.intPackageUOMId
							AND B.strBatchId = @strLotNo
							AND B.intTealingoItemId = @intItemId
							--AND B.intLocationId = @intCompanyLocationId

						SELECT @intLotQtyItemUOMId = @intQtyItemUOMId

						IF ISNULL(@intLotQtyItemUOMId, 0) = 0
						BEGIN
							RAISERROR (
									'Detail Quantity UOM does not belongs to the Item. '
									,16
									,1
									)
						END
					END

					IF @dblLotGrossWeight <= 0
					BEGIN
						RAISERROR (
								'Invalid Detail Gross Weight. '
								,16
								,1
								)
					END

					IF @dblLotNetWeight <= 0
					BEGIN
						RAISERROR (
								'Invalid Detail Net Weight. '
								,16
								,1
								)
					END

					SELECT @intLotNetWeightUnitMeasureId = t.intUnitMeasureId
					FROM tblICUnitMeasure t WITH (NOLOCK)
					WHERE t.strUnitMeasure = @strLotWeightUOM

					IF ISNULL(@intLotNetWeightUnitMeasureId, 0) = 0
					BEGIN
						RAISERROR (
								'Invalid Detail Net Weight UOM. '
								,16
								,1
								)
					END
					ELSE
					BEGIN
						SELECT @intLotNetWeightItemUOMId = intItemUOMId
						FROM tblICItemUOM t WITH (NOLOCK)
						WHERE t.intItemId = @intItemId
							AND t.intUnitMeasureId = @intLotNetWeightUnitMeasureId

						IF ISNULL(@intLotNetWeightItemUOMId, 0) = 0
						BEGIN
							RAISERROR (
									'Detail Net Weight UOM does not belongs to the Item. '
									,16
									,1
									)
						END
					END

					IF ISNULL(@strLotStorageLocationName, '') <> ''
					BEGIN
						SELECT @intLotStorageLocationId = t.intStorageLocationId
						FROM tblICStorageLocation t WITH (NOLOCK)
						WHERE t.strName = @strLotStorageLocationName
							AND t.intSubLocationId = @intSubLocationId

						IF ISNULL(@intLotStorageLocationId, 0) = 0
						BEGIN
							SELECT @intLotStorageLocationId = @intStorageLocationId
						END
					END

					IF @dtmLotExpiryDate IS NULL
					BEGIN
						SELECT @strError = 'Detail Expiry Date cannot be blank.'

						RAISERROR (
								@strError
								,16
								,1
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
						,dblTare
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
						,intSort
						,intLoadShipmentId
						,intLoadShipmentDetailId
						,strVendorRefNo
						,strWarehouseRefNo
						)
					SELECT strReceiptType = 'Approved Quality'
						,intEntityVendorId = LD.intVendorEntityId
						,intShipFromId = LD.intVendorEntityLocationId
						,intLocationId = @intCompanyLocationId
						,strBillOfLadding = @strBLNumber
						,intItemId = @intItemId
						,intItemLocationId = IL.intItemLocationId
						,intItemUOMId = @intQtyItemUOMId
						,intContractHeaderId = @intContractHeaderId
						,intContractDetailId = @intContractDetailId
						,dtmDate = @dtmReceiptDate
						,intShipViaId = CD.intShipViaId
						,dblQty = @dblQuantity
						,intGrossNetUOMId = @intNetWeightItemUOMId
						,dblGross = @dblGrossWeight
						,dblTare = @dblTareWeight
						,dblNet = @dblNetWeight
						,dblCost = @dblCost
						,intCostUOMId = @intCostItemUOMId
						,intCurrencyId = @intCostCurrencyId
						,intSubCurrencyCents = (
							CASE 
								WHEN ISNULL(@ysnSubCurrency, 0) = 1
									THEN 100
								ELSE 1
								END
							)
						,dblExchangeRate = 1
						,intLotId = NULL
						,intSubLocationId = ISNULL(@intSubLocationId, LD.intPSubLocationId)
						,intStorageLocationId = @intStorageLocationId
						,ysnIsStorage = 0
						,intSourceId = LD.intLoadDetailId
						,intSourceType = 2
						,strSourceId = L.strLoadNumber
						,strSourceScreenName = 'External System'
						,ysnSubCurrency = (
							CASE 
								WHEN ISNULL(@ysnSubCurrency, 0) = 1
									THEN 1
								ELSE 0
								END
							)
						,intForexRateTypeId = NULL
						,dblForexRate = NULL
						,intContainerId = - 1
						,intFreightTermId = L.intFreightTermId
						,intBookId = L.intBookId
						,intSubBookId = L.intSubBookId
						,intSort = LD.intLoadDetailId
						,intLoadShipmentId = LD.intLoadId
						,intLoadShipmentDetailId = LD.intLoadDetailId
						,strVendorRefNo = @strERPReceiptNo
						,strWarehouseRefNo = @strWarehouseRefNo
					FROM tblLGLoadDetail LD WITH (NOLOCK)
					JOIN tblLGLoad L WITH (NOLOCK) ON L.intLoadId = LD.intLoadId
						AND LD.intLoadDetailId = @intLoadDetailId
					JOIN tblMFBatch B WITH (NOLOCK) ON B.intBatchId = LD.intBatchId
					JOIN tblICItemLocation IL WITH (NOLOCK) ON IL.intItemId = LD.intItemId
						AND IL.intLocationId = LD.intPCompanyLocationId
					LEFT JOIN tblCTContractDetail CD WITH (NOLOCK) ON CD.intContractDetailId = LD.intPContractDetailId

					IF NOT EXISTS (
							SELECT 1
							FROM @ReceiptStagingTable
							)
					BEGIN
						RAISERROR (
								'Receipt Staging Table entries not inserted. '
								,16
								,1
								)
					END

					INSERT INTO @LotEntries (
						intLotId
						,strLotNumber
						,strLotAlias
						,intSubLocationId
						,intStorageLocationId
						,intContractHeaderId
						,intContractDetailId
						,intItemUnitMeasureId
						,intItemId
						,dblQuantity
						,dblGrossWeight
						,dblTareWeight
						,dblCost
						,strContainerNo
						,intSort
						,strMarkings
						,strCondition
						,intEntityVendorId
						,strReceiptType
						,intLocationId
						,intShipViaId
						,intShipFromId
						,intCurrencyId
						,intSourceType
						,strBillOfLadding
						,dtmExpiryDate
						,intParentLotId
						,strParentLotNumber
						,intLotStatusId
						,dtmManufacturedDate
						)
					SELECT intLotId = NULL
						,strLotNumber = @strLotNo
						,strLotAlias = NULL
						,intSubLocationId = RI.intSubLocationId
						,intStorageLocationId = ISNULL(@intLotStorageLocationId, RI.intStorageLocationId)
						,intContractHeaderId = RI.intContractHeaderId
						,intContractDetailId = RI.intContractDetailId
						,intItemUnitMeasureId = @intLotQtyItemUOMId
						,intItemId = RI.intItemId
						,dblQuantity = @dblLotQuantity
						,dblGrossWeight = @dblLotGrossWeight
						,dblTareWeight = @dblLotTareWeight
						,dblCost = RI.dblCost
						,strContainerNo = @strContainerNumber
						,intSort = RI.intSort
						,strMarkings = @strLotMarks
						,strCondition = 'Sound/Full'
						,intEntityVendorId = RI.intEntityVendorId
						,strReceiptType = RI.strReceiptType
						,intLocationId = RI.intLocationId
						,intShipViaId = RI.intShipViaId
						,intShipFromId = RI.intShipFromId
						,intCurrencyId = RI.intCurrencyId
						,intSourceType = RI.intSourceType
						,strBillOfLadding = RI.strBillOfLadding
						,dtmExpiryDate = @dtmLotExpiryDate
						,intParentLotId = NULL
						,strParentLotNumber = NULL
						,intLotStatusId = NULL
						,dtmManufacturedDate = @dtmLotManufacturedDate
					FROM @ReceiptStagingTable RI
					WHERE RI.intLoadShipmentDetailId = @intLoadDetailId

					SELECT @intStageReceiptItemLotId = MIN(intStageReceiptItemLotId)
					FROM tblIPInvReceiptItemLotStage WITH (NOLOCK)
					WHERE intStageReceiptId = @intStageReceiptId
						AND intStageReceiptItemId = @intStageReceiptItemId
						AND intStageReceiptItemLotId > @intStageReceiptItemLotId
				END

				SELECT @intStageReceiptItemId = MIN(intStageReceiptItemId)
				FROM tblIPInvReceiptItemStage WITH (NOLOCK)
				WHERE intStageReceiptId = @intStageReceiptId
					AND intStageReceiptItemId > @intStageReceiptItemId
			END

			IF EXISTS (
					SELECT 1
					FROM @ReceiptStagingTable
					)
			BEGIN
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

				-- Create IR with lots
				EXEC dbo.uspICAddItemReceipt @ReceiptEntries = @ReceiptStagingTable
					,@OtherCharges = @OtherCharges
					,@intUserId = @intUserId
					,@LotEntries = @LotEntries

				SELECT TOP 1 @intInventoryReceiptId = intInventoryReceiptId
				FROM #tmpAddItemReceiptResult

				-- If IR is created, Post the Receipt
				IF (@intInventoryReceiptId IS NOT NULL)
				BEGIN
					SELECT @strReceiptNo = strReceiptNumber
					FROM tblICInventoryReceipt
					WHERE intInventoryReceiptId = @intInventoryReceiptId

					SET @strInfo1 = ISNULL(@strReceiptNo, '') + ' / ' + ISNULL(@strERPReceiptNo, '')

					--Post Receipt
					EXEC uspICPostInventoryReceipt 1
						,0
						,@strReceiptNo
						,@intUserId

					DELETE
					FROM #tmpAddItemReceiptResult
					WHERE intInventoryReceiptId = @intInventoryReceiptId

					UPDATE B
					SET B.dtmWarehouseArrival = CAST(GETDATE() AS DATE)
					FROM tblMFBatch B
					WHERE B.dtmWarehouseArrival IS NULL
						AND B.strBatchId IN (
							SELECT strLotNumber
							FROM @LotEntries
							)
				END
			END

			INSERT INTO tblIPInvReceiptArchive (
				intTrxSequenceNo
				,dtmCreated
				,strERPReceiptNo
				,dtmReceiptDate
				,strVendorAccountNo
				,strBLNumber
				,strLocationName
				,strWarehouseRefNo
				,strOrderType
				,dtmTransactionDate
				,strErrorMessage
				,strImportStatus
				)
			SELECT intTrxSequenceNo
				,dtmCreated
				,strERPReceiptNo
				,dtmReceiptDate
				,strVendorAccountNo
				,strBLNumber
				,strLocationName
				,strWarehouseRefNo
				,strOrderType
				,dtmTransactionDate
				,''
				,'Success'
			FROM tblIPInvReceiptStage
			WHERE intStageReceiptId = @intStageReceiptId

			SELECT @intNewStageReceiptId = SCOPE_IDENTITY()

			INSERT INTO tblIPInvReceiptItemArchive (
				intStageReceiptId
				,intTrxSequenceNo
				,strERPPONumber
				,strERPItemNumber
				,strItemNo
				,strSubLocationName
				,strStorageLocationName
				,dblQuantity
				,strQuantityUOM
				,dblGrossWeight
				,dblTareWeight
				,dblNetWeight
				,strNetWeightUOM
				,dblCost
				,strCostUOM
				,strCostCurrency
				,strContainerNumber
				)
			SELECT @intNewStageReceiptId
				,intTrxSequenceNo
				,strERPPONumber
				,strERPItemNumber
				,strItemNo
				,strSubLocationName
				,strStorageLocationName
				,dblQuantity
				,strQuantityUOM
				,dblGrossWeight
				,dblTareWeight
				,dblNetWeight
				,strNetWeightUOM
				,dblCost
				,strCostUOM
				,strCostCurrency
				,strContainerNumber
			FROM tblIPInvReceiptItemStage
			WHERE intStageReceiptId = @intStageReceiptId

			INSERT INTO tblIPInvReceiptItemLotArchive (
				intStageReceiptId
				,intTrxSequenceNo
				,strLotNo
				,dblQuantity
				,strQuantityUOM
				,dblGrossWeight
				,dblTareWeight
				,dblNetWeight
				,strWeightUOM
				,strStorageLocationName
				,strMarks
				,dtmManufacturedDate
				,dtmExpiryDate
				,strERPPONumber
				,strERPItemNumber
				,intStageReceiptItemId
				)
			SELECT @intNewStageReceiptId
				,intTrxSequenceNo
				,strLotNo
				,dblQuantity
				,strQuantityUOM
				,dblGrossWeight
				,dblTareWeight
				,dblNetWeight
				,strWeightUOM
				,strStorageLocationName
				,strMarks
				,dtmManufacturedDate
				,dtmExpiryDate
				,strERPPONumber
				,strERPItemNumber
				,intStageReceiptItemId
			FROM tblIPInvReceiptItemLotStage
			WHERE intStageReceiptId = @intStageReceiptId

			DELETE
			FROM tblIPInvReceiptStage
			WHERE intStageReceiptId = @intStageReceiptId

			COMMIT TRAN
		END TRY

		BEGIN CATCH
			IF XACT_STATE() != 0
				AND @@TRANCOUNT > 0
				ROLLBACK TRANSACTION

			SET @ErrMsg = ERROR_MESSAGE()
			SET @strFinalErrMsg = @strFinalErrMsg + @ErrMsg

			INSERT INTO tblIPInvReceiptError (
				intTrxSequenceNo
				,dtmCreated
				,strERPReceiptNo
				,dtmReceiptDate
				,strVendorAccountNo
				,strBLNumber
				,strLocationName
				,strWarehouseRefNo
				,strOrderType
				,dtmTransactionDate
				,strErrorMessage
				,strImportStatus
				)
			SELECT intTrxSequenceNo
				,dtmCreated
				,strERPReceiptNo
				,dtmReceiptDate
				,strVendorAccountNo
				,strBLNumber
				,strLocationName
				,strWarehouseRefNo
				,strOrderType
				,dtmTransactionDate
				,@ErrMsg
				,'Failed'
			FROM tblIPInvReceiptStage
			WHERE intStageReceiptId = @intStageReceiptId

			SELECT @intNewStageReceiptId = SCOPE_IDENTITY()

			INSERT INTO tblIPInvReceiptItemError (
				intStageReceiptId
				,intTrxSequenceNo
				,strERPPONumber
				,strERPItemNumber
				,strItemNo
				,strSubLocationName
				,strStorageLocationName
				,dblQuantity
				,strQuantityUOM
				,dblGrossWeight
				,dblTareWeight
				,dblNetWeight
				,strNetWeightUOM
				,dblCost
				,strCostUOM
				,strCostCurrency
				,strContainerNumber
				)
			SELECT @intNewStageReceiptId
				,intTrxSequenceNo
				,strERPPONumber
				,strERPItemNumber
				,strItemNo
				,strSubLocationName
				,strStorageLocationName
				,dblQuantity
				,strQuantityUOM
				,dblGrossWeight
				,dblTareWeight
				,dblNetWeight
				,strNetWeightUOM
				,dblCost
				,strCostUOM
				,strCostCurrency
				,strContainerNumber
			FROM tblIPInvReceiptItemStage
			WHERE intStageReceiptId = @intStageReceiptId

			INSERT INTO tblIPInvReceiptItemLotError (
				intStageReceiptId
				,intTrxSequenceNo
				,strLotNo
				,dblQuantity
				,strQuantityUOM
				,dblGrossWeight
				,dblTareWeight
				,dblNetWeight
				,strWeightUOM
				,strStorageLocationName
				,strMarks
				,dtmManufacturedDate
				,dtmExpiryDate
				,strERPPONumber
				,strERPItemNumber
				,intStageReceiptItemId
				)
			SELECT @intNewStageReceiptId
				,intTrxSequenceNo
				,strLotNo
				,dblQuantity
				,strQuantityUOM
				,dblGrossWeight
				,dblTareWeight
				,dblNetWeight
				,strWeightUOM
				,strStorageLocationName
				,strMarks
				,dtmManufacturedDate
				,dtmExpiryDate
				,strERPPONumber
				,strERPItemNumber
				,intStageReceiptItemId
			FROM tblIPInvReceiptItemLotStage
			WHERE intStageReceiptId = @intStageReceiptId

			DELETE
			FROM tblIPInvReceiptStage
			WHERE intStageReceiptId = @intStageReceiptId
		END CATCH

		SELECT @intStageReceiptId = MIN(intStageReceiptId)
		FROM @tblIPInvReceiptStage
		WHERE intStageReceiptId > @intStageReceiptId
	END

	UPDATE S
	SET intStatusId = NULL
	FROM tblIPInvReceiptStage S
	JOIN @tblIPInvReceiptStage TS ON TS.intStageReceiptId = S.intStageReceiptId
	WHERE S.intStatusId = - 1

	IF ISNULL(@strFinalErrMsg, '') <> ''
		RAISERROR (
				@strFinalErrMsg
				,16
				,1
				)
END TRY

BEGIN CATCH
	SET @ErrMsg = ERROR_MESSAGE()

	RAISERROR (
			@ErrMsg
			,16
			,1
			,'WITH NOWAIT'
			)
END CATCH
