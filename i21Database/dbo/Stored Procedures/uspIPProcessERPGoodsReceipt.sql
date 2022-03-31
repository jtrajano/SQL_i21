CREATE PROCEDURE uspIPProcessERPGoodsReceipt @strInfo1 NVARCHAR(MAX) = '' OUT
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
		,@strCompanyLocation NVARCHAR(6)
		,@intActionId INT
		,@dtmCreatedDate DATETIME
		,@strCreatedBy NVARCHAR(50)
	DECLARE @intStageReceiptId INT
		,@strVendorAccountNo NVARCHAR(100)
		,@strVendorRefNo NVARCHAR(50)
		,@strERPReceiptNo NVARCHAR(50)
		,@dtmReceiptDate DATETIME
		,@strBLNumber NVARCHAR(100)
		,@strWarehouseRefNo NVARCHAR(50)
		,@strTransferOrderNo NVARCHAR(50)
		,@strERPTransferOrderNo NVARCHAR(50)
		,@strReceiptNo NVARCHAR(50)
	DECLARE @intCompanyLocationId INT
		,@intInventoryTransferId INT
		,@intInventoryReceiptId INT
		,@intNewStageReceiptId INT
		,@intFreightTermId INT
	DECLARE @strItemNo NVARCHAR(50)
		,@dblQuantity NUMERIC(18, 6)
		,@dblGrossWeight NUMERIC(18, 6)
		,@dblTareWeight NUMERIC(18, 6)
		,@dblNetWeight NUMERIC(18, 6)
		,@strNetWeightUOM NVARCHAR(50)
		,@dblCost NUMERIC(38, 20)
		,@strCostUOM NVARCHAR(50)
		,@strCurrency NVARCHAR(50)
		,@strSubLocationName NVARCHAR(50)
		,@strStorageLocationName NVARCHAR(50)
		,@strContainerNumber NVARCHAR(100)
		,@strLotNo NVARCHAR(50)
		,@strLotPrimaryStatus NVARCHAR(50)
		,@strOrgLotStatus NVARCHAR(50)
	DECLARE @intStageReceiptItemLotId INT
		,@intItemId INT
		,@intSubLocationId INT
		,@intStorageLocationId INT
		,@intQtyUnitMeasureId INT
		,@intQtyItemUOMId INT
		,@intNetWeightUnitMeasureId INT
		,@intNetWeightItemUOMId INT
		,@intCostUnitMeasureId INT
		,@intCostItemUOMId INT
		,@intDefaultCurrencyId INT
		,@intCurrencyId INT
		,@intMainCurrencyId INT
		,@ysnSubCurrency BIT
		,@intLotId INT
		,@intInventoryTransferDetailId INT
		,@dtmExpiryDate DATETIME
		,@intLotStatusId INT
		,@intParentLotId INT
		,@strParentLotNumber NVARCHAR(50)
		,@strLotCondition NVARCHAR(50)
		,@intDefaultForexRateTypeId INT
		,@dblForexRate NUMERIC(18,6)
		,@intTransferDetailCurrencyId INT
	DECLARE @InventoryTransferDetail TABLE (intInventoryTransferDetailId INT)
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

	SELECT @strInfo2 = @strInfo2 + ISNULL(strTransferOrderNo, '') + ', '
	FROM (
		SELECT DISTINCT b.strTransferOrderNo
		FROM @tblIPInvReceiptStage a
		JOIN tblIPInvReceiptStage b ON a.intStageReceiptId = b.intStageReceiptId
		) AS DT

	IF Len(@strInfo2) > 0
	BEGIN
		SELECT @strInfo2 = Left(@strInfo2, Len(@strInfo2) - 1)
	END

	WHILE (@intStageReceiptId IS NOT NULL)
	BEGIN
		BEGIN TRY
			SELECT @intTrxSequenceNo = NULL
				,@strCompanyLocation = NULL
				,@intActionId = NULL
				,@dtmCreatedDate = NULL
				,@strCreatedBy = NULL

			SELECT @strVendorAccountNo = NULL
				,@strVendorRefNo = NULL
				,@strERPReceiptNo = NULL
				,@dtmReceiptDate = NULL
				,@strBLNumber = NULL
				,@strWarehouseRefNo = NULL
				,@strTransferOrderNo = NULL
				,@strERPTransferOrderNo = NULL
				,@strReceiptNo = NULL

			SELECT @intCompanyLocationId = NULL
				,@intInventoryTransferId = NULL
				,@intInventoryReceiptId = NULL
				,@intNewStageReceiptId = NULL
				,@intFreightTermId = NULL

			SELECT @intStageReceiptItemLotId = NULL

			SELECT @intTrxSequenceNo = intTrxSequenceNo
				,@strCompanyLocation = strCompCode
				,@intActionId = intActionId
				,@dtmCreatedDate = dtmCreated
				,@strCreatedBy = strCreatedBy
				,@strVendorAccountNo = strVendorAccountNo
				,@strVendorRefNo = strVendorRefNo
				,@strERPReceiptNo = strERPReceiptNo
				,@dtmReceiptDate = dtmReceiptDate
				,@strBLNumber = strBLNumber
				,@strWarehouseRefNo = strWarehouseRefNo
				,@strTransferOrderNo = strTransferOrderNo
				,@strERPTransferOrderNo = strERPTransferOrderNo
			FROM tblIPInvReceiptStage
			WHERE intStageReceiptId = @intStageReceiptId

			IF EXISTS (
					SELECT 1
					FROM tblIPInvReceiptArchive
					WHERE intTrxSequenceNo = @intTrxSequenceNo
					)
			BEGIN
				SELECT @strError = 'TrxSequenceNo ' + LTRIM(@intTrxSequenceNo) + ' is already processed in i21.'

				RAISERROR (
						@strError
						,16
						,1
						)
			END

			SELECT @intCompanyLocationId = intCompanyLocationId
			FROM dbo.tblSMCompanyLocation
			WHERE strLotOrigin = @strCompanyLocation

			SELECT @intInventoryTransferId = intInventoryTransferId
			FROM dbo.tblICInventoryTransfer WITH (NOLOCK)
			WHERE strTransferNo = @strTransferOrderNo

			IF @intFreightTermId IS NULL
			BEGIN
				SELECT @intFreightTermId = intFreightTermId
				FROM tblSMFreightTerms WITH (NOLOCK)
				WHERE strFreightTerm = 'Deliver'
					AND strFobPoint = 'Destination'
			END

			IF @intCompanyLocationId IS NULL
			BEGIN
				SELECT @strError = 'Company Location not found.'

				RAISERROR (
						@strError
						,16
						,1
						)
			END

			IF ISNULL(@strERPReceiptNo, '') = ''
			BEGIN
				SELECT @strError = 'ERP Receipt No cannot be blank.'

				RAISERROR (
						@strError
						,16
						,1
						)
			END

			IF ISNULL(@strTransferOrderNo, '') = ''
			BEGIN
				SELECT @strError = 'Transfer Order No cannot be blank.'

				RAISERROR (
						@strError
						,16
						,1
						)
			END

			IF ISNULL(@strERPTransferOrderNo, '') = ''
			BEGIN
				SELECT @strError = 'ERP Transfer Order No cannot be blank.'

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

			IF @intInventoryTransferId IS NULL
			BEGIN
				SELECT @strError = 'Transfer Order No not found.'

				RAISERROR (
						@strError
						,16
						,1
						)
			END

			IF NOT EXISTS (
					SELECT 1
					FROM tblICInventoryTransfer
					WHERE intInventoryTransferId = @intInventoryTransferId
						AND ysnShipmentRequired = 1
						AND intStatusId = 2 -- In Transit
						AND ysnPosted = 1
					)
			BEGIN
				RAISERROR (
						'Transfer Order No is not posted / already received.'
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
						'Receipt Item is required.'
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

			IF EXISTS (
					SELECT 1
					FROM tblICInventoryReceipt R
					JOIN tblICInventoryReceiptItem RI ON RI.intInventoryReceiptId = R.intInventoryReceiptId
						AND R.strReceiptType = 'Transfer Order'
						AND RI.intOrderId = @intInventoryTransferId
					)
			BEGIN
				SELECT @strError = 'Receipt already exists for the Transfer Order No.'

				RAISERROR (
						@strError
						,16
						,1
						)
			END

			BEGIN TRAN

			DELETE
			FROM @ReceiptStagingTable

			DELETE
			FROM @LotEntries

			DELETE
			FROM @InventoryTransferDetail

			SELECT @intStageReceiptItemLotId = MIN(intStageReceiptItemLotId)
			FROM tblIPInvReceiptItemLotStage WITH (NOLOCK)
			WHERE intStageReceiptId = @intStageReceiptId

			WHILE @intStageReceiptItemLotId IS NOT NULL
			BEGIN
				SELECT @strItemNo = NULL
					,@dblQuantity = NULL
					,@dblGrossWeight = NULL
					,@dblTareWeight = NULL
					,@dblNetWeight = NULL
					,@strNetWeightUOM = NULL
					,@dblCost = NULL
					,@strCostUOM = NULL
					,@strCurrency = NULL
					,@strSubLocationName = NULL
					,@strStorageLocationName = NULL
					,@strContainerNumber = NULL
					,@strLotNo = NULL
					,@strLotPrimaryStatus = NULL
					,@strOrgLotStatus = NULL

				SELECT @intItemId = NULL
					,@intSubLocationId = NULL
					,@intStorageLocationId = NULL
					,@intQtyUnitMeasureId = NULL
					,@intQtyItemUOMId = NULL
					,@intNetWeightUnitMeasureId = NULL
					,@intNetWeightItemUOMId = NULL
					,@intCostUnitMeasureId = NULL
					,@intCostItemUOMId = NULL
					,@intDefaultCurrencyId = NULL
					,@intCurrencyId = NULL
					,@intMainCurrencyId = NULL
					,@ysnSubCurrency = NULL
					,@intLotId = NULL
					,@intInventoryTransferDetailId = NULL
					,@dtmExpiryDate = NULL
					,@intLotStatusId = NULL
					,@intParentLotId = NULL
					,@strParentLotNumber = NULL
					,@strLotCondition = NULL
					,@intDefaultForexRateTypeId = NULL
					,@dblForexRate = NULL
					,@intTransferDetailCurrencyId = NULL

				SELECT @strItemNo = RIS.strItemNo
					,@strSubLocationName = RIS.strSubLocationName
					,@strStorageLocationName = RIS.strStorageLocationName
					,@dblCost = ISNULL(RIS.dblCost, 0)
					,@strCostUOM = RIS.strCostUOM
					,@strCurrency = RIS.strCostCurrency
					,@strContainerNumber = RIS.strContainerNumber
					,@strLotNo = RILS.strLotNo
					,@strLotPrimaryStatus = RILS.strLotPrimaryStatus
					,@dblGrossWeight = ISNULL(RILS.dblGrossWeight, 0)
					,@dblTareWeight = ISNULL(RILS.dblTareWeight, 0)
					,@dblNetWeight = ISNULL(RILS.dblNetWeight, 0)
					,@strNetWeightUOM = RILS.strWeightUOM
				FROM tblIPInvReceiptItemLotStage RILS WITH (NOLOCK)
				JOIN tblIPInvReceiptItemStage RIS WITH (NOLOCK) ON RIS.intTrxSequenceNo = RILS.intParentTrxSequenceNo
				WHERE RILS.intStageReceiptItemLotId = @intStageReceiptItemLotId

				IF @dblNetWeight <= 0
				BEGIN
					RAISERROR (
							'Invalid Net Weight. '
							,16
							,1
							)
				END

				SELECT TOP 1 @intInventoryTransferDetailId = ITD.intInventoryTransferDetailId
					,@dblQuantity = ISNULL(ITD.dblQuantity, 0)
					,@intQtyItemUOMId = ITD.intItemUOMId
					,@intQtyUnitMeasureId = IUOM.intUnitMeasureId
					,@intLotId = L.intLotId
					,@strLotCondition = ISNULL(ITD.strLotCondition, 'Sound/Full')
					--,@dblCost = (dbo.fnMultiply(ITD.dblQuantity, ISNULL(ITD.dblCost, 0)) / ITD.dblNet) -- Line Total / Net Wt
					,@intTransferDetailCurrencyId = ITD.intCurrencyId
				FROM tblICInventoryTransferDetail ITD
				JOIN tblICItemUOM IUOM ON IUOM.intItemUOMId = ITD.intItemUOMId
					AND ITD.intInventoryTransferId = @intInventoryTransferId
				JOIN tblICLot L ON L.intLotId = ITD.intLotId
					AND L.strLotNumber = @strLotNo
				WHERE ITD.intInventoryTransferDetailId NOT IN (
						SELECT ISNULL(intInventoryTransferDetailId, 0)
						FROM @InventoryTransferDetail
						)
				ORDER BY ABS(ITD.dblNet - @dblNetWeight)

				IF @strLotCondition = ''
					SELECT @strLotCondition = 'Sound/Full'

				SELECT @dblCost = dbo.fnDivide(SUM(dbo.fnMultiply(dblQty, dblCost)), SUM(dblQty))
				FROM tblICInventoryTransaction WITH (NOLOCK)
				WHERE intTransactionTypeId = 13
					AND intTransactionId = @intInventoryTransferId
					AND intTransactionDetailId = @intInventoryTransferDetailId
					AND ysnIsUnposted = 0
					AND dblQty > 0

				IF ISNULL(@intLotId, 0) = 0
				BEGIN
					RAISERROR (
							'Invalid Lot No. '
							,16
							,1
							)
				END

				IF ISNULL(@intInventoryTransferDetailId, 0) = 0
				BEGIN
					RAISERROR (
							'Lot is not available in the Transfer Order Items.'
							,16
							,1
							)
				END

				SELECT @dtmExpiryDate = L.dtmExpiryDate
					,@intLotStatusId = L.intLotStatusId
					,@strOrgLotStatus = LS.strPrimaryStatus
					,@intParentLotId = L.intParentLotId
					,@strParentLotNumber = PL.strParentLotNumber
				FROM tblICLot L
				JOIN tblICParentLot PL ON PL.intParentLotId = L.intParentLotId
				JOIN tblICLotStatus LS ON LS.intLotStatusId = L.intLotStatusId
				WHERE L.intLotId = @intLotId

				IF ISNULL(@strLotPrimaryStatus, '') <> @strOrgLotStatus
				BEGIN
					SELECT @strError = 'Lot Status is not matching with i21.'

					RAISERROR (
							@strError
							,16
							,1
							)
				END

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

				IF NOT EXISTS (
						SELECT 1
						FROM tblICInventoryTransferDetail
						WHERE intInventoryTransferDetailId = @intInventoryTransferDetailId
							AND intItemId = @intItemId
						)
				BEGIN
					RAISERROR (
							'Item is not available in the Transfer Order Items.'
							,16
							,1
							)
				END

				SELECT @intSubLocationId = t.intCompanyLocationSubLocationId
				FROM tblSMCompanyLocationSubLocation t WITH (NOLOCK)
				WHERE t.strSubLocationName = @strSubLocationName
					AND t.intCompanyLocationId = @intCompanyLocationId

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
					RAISERROR (
							'Invalid Storage Location. '
							,16
							,1
							)
				END

				IF @dblQuantity <= 0
				BEGIN
					RAISERROR (
							'Invalid Quantity. '
							,16
							,1
							)
				END

				IF ISNULL(@intQtyUnitMeasureId, 0) = 0
				BEGIN
					RAISERROR (
							'Invalid Quantity UOM. '
							,16
							,1
							)
				END

				IF @dblGrossWeight <= 0
				BEGIN
					RAISERROR (
							'Invalid Gross Weight. '
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

				IF @dblCost >= 0
				BEGIN
					SELECT @intCostItemUOMId = t.intItemUOMId
					FROM tblICItemUOM t WITH (NOLOCK)
					WHERE t.intItemId = @intItemId
						AND t.ysnStockUnit = 1
				END

				--IF @dblCost >= 0
				--	AND ISNULL(@strCostUOM, '') <> ''
				--BEGIN
				--	SELECT @intCostUnitMeasureId = t.intUnitMeasureId
				--	FROM tblICUnitMeasure t WITH (NOLOCK)
				--	WHERE t.strUnitMeasure = @strCostUOM
				--	IF ISNULL(@intCostUnitMeasureId, 0) = 0
				--	BEGIN
				--		RAISERROR (
				--				'Invalid Cost UOM. '
				--				,16
				--				,1
				--				)
				--	END
				--	ELSE
				--	BEGIN
				--		SELECT @intCostItemUOMId = intItemUOMId
				--		FROM tblICItemUOM t WITH (NOLOCK)
				--		WHERE t.intItemId = @intItemId
				--			AND t.intUnitMeasureId = @intCostUnitMeasureId
				--		IF ISNULL(@intCostItemUOMId, 0) = 0
				--		BEGIN
				--			RAISERROR (
				--					'Cost UOM does not belongs to the Item. '
				--					,16
				--					,1
				--					)
				--		END
				--	END
				--END
				SELECT TOP 1 @intDefaultCurrencyId = intDefaultCurrencyId
				FROM tblSMCompanyPreference t WITH (NOLOCK)

				SELECT @strCurrency = strCurrency
				FROM tblSMCurrency
				WHERE intCurrencyID = @intTransferDetailCurrencyId

				IF ISNULL(@strCurrency, '') <> ''
				BEGIN
					SELECT @intCurrencyId = t.intCurrencyID
						,@intMainCurrencyId = t.intMainCurrencyId
						,@ysnSubCurrency = t.ysnSubCurrency
					FROM tblSMCurrency t WITH (NOLOCK)
					WHERE t.strCurrency = @strCurrency

					IF @ysnSubCurrency = 1
						SELECT @intCurrencyId = @intMainCurrencyId
				END
				ELSE
				BEGIN
					SELECT @intCurrencyId = @intDefaultCurrencyId
						,@ysnSubCurrency = 0
				END

				--IF @intDefaultCurrencyId <> @intCurrencyId
				--BEGIN
				--	SELECT TOP 1 @intDefaultForexRateTypeId = intInventoryRateTypeId
				--	FROM tblSMMultiCurrency
				--	SELECT @dblForexRate = dblRate
				--	FROM [dbo].[fnSMGetForexRate](@intCurrencyId, @intDefaultForexRateTypeId, GETDATE())
				--END
				INSERT INTO @ReceiptStagingTable (
					strReceiptType
					,intEntityVendorId
					,intShipFromId
					,intTransferorId
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
					,intSort
					,intLoadShipmentId
					,intLoadShipmentDetailId
					,strVendorRefNo
					,dblUnitRetail
					,intShipFromEntityId
					,strWarehouseRefNo
					,intInventoryTransferId
					,intInventoryTransferDetailId
					)
				SELECT TOP 1 strReceiptType = 'Transfer Order'
					,intEntityVendorId = -1
					,intShipFromId = -1
					,intTransferorId = IT.intFromLocationId
					,intLocationId = IT.intToLocationId
					,strBillOfLadding = ISNULL(@strBLNumber, IT.strBolNumber)
					,intItemId = @intItemId
					,intItemLocationId = @intCompanyLocationId
					,intItemUOMId = @intQtyItemUOMId
					,intContractHeaderId = NULL
					,intContractDetailId = NULL
					,dtmDate = @dtmReceiptDate
					,intShipViaId = IT.intShipViaId
					,dblQty = @dblQuantity
					,intGrossNetUOMId = @intNetWeightItemUOMId
					,dblGross = @dblGrossWeight
					,dblNet = @dblNetWeight
					,dblCost = @dblCost
					,intCostUOMId = @intCostItemUOMId
					,intCurrencyId = @intCurrencyId
					,intSubCurrencyCents = (
						CASE 
							WHEN ISNULL(@ysnSubCurrency, 0) = 1
								THEN 100
							ELSE 1
							END
						)
					,dblExchangeRate = ISNULL(@dblForexRate, 1)
					,intLotId = NULL
					,intSubLocationId = @intSubLocationId
					,intStorageLocationId = @intStorageLocationId
					,ysnIsStorage = 0
					,intSourceId = NULL
					,intSourceType = 0 -- Transfer Order
					,strSourceId = @strTransferOrderNo
					,strSourceScreenName = 'External System'
					,ysnSubCurrency = (
						CASE 
							WHEN ISNULL(@ysnSubCurrency, 0) = 1
								THEN 1
							ELSE 0
							END
						)
					,intForexRateTypeId = @intDefaultForexRateTypeId
					,dblForexRate = @dblForexRate
					,intContainerId = NULL
					,intFreightTermId = @intFreightTermId
					,intBookId = NULL
					,intSubBookId = NULL
					,intSort = @intInventoryTransferDetailId
					,intLoadShipmentId = NULL
					,intLoadShipmentDetailId = NULL
					,strVendorRefNo = @strVendorRefNo
					,dblUnitRetail = @dblCost
					,intShipFromEntityId = NULL
					,strWarehouseRefNo = @strWarehouseRefNo
					,intInventoryTransferId = @intInventoryTransferId
					,intInventoryTransferDetailId = @intInventoryTransferDetailId
				FROM tblICInventoryTransfer IT
				JOIN tblICInventoryTransferDetail ITD ON ITD.intInventoryTransferId = IT.intInventoryTransferId
					AND ITD.intInventoryTransferDetailId = @intInventoryTransferDetailId
				WHERE IT.intInventoryTransferId = @intInventoryTransferId

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
					)
				SELECT intLotId = NULL
					,strLotNumber = @strLotNo
					,strLotAlias = NULL
					,intSubLocationId = RI.intSubLocationId
					,intStorageLocationId = RI.intStorageLocationId
					,intContractHeaderId = RI.intContractHeaderId
					,intContractDetailId = RI.intContractDetailId
					,intItemUnitMeasureId = RI.intItemUOMId
					,intItemId = RI.intItemId
					,dblQuantity = RI.dblQty
					,dblGrossWeight = @dblGrossWeight
					,dblTareWeight = @dblTareWeight
					,dblCost = 0
					,strContainerNo = @strContainerNumber
					,intSort = RI.intSort
					,strMarkings = NULL
					,strCondition = @strLotCondition
					,intEntityVendorId = RI.intEntityVendorId
					,strReceiptType = RI.strReceiptType
					,intLocationId = RI.intLocationId
					,intShipViaId = RI.intShipViaId
					,intShipFromId = RI.intShipFromId
					,intCurrencyId = RI.intCurrencyId
					,intSourceType = RI.intSourceType
					,strBillOfLadding = RI.strBillOfLadding
					,dtmExpiryDate = @dtmExpiryDate
					,intParentLotId = @intParentLotId
					,strParentLotNumber = @strParentLotNumber
					,intLotStatusId = @intLotStatusId
				FROM @ReceiptStagingTable RI
				WHERE RI.intInventoryTransferId = @intInventoryTransferId
					AND RI.intInventoryTransferDetailId = @intInventoryTransferDetailId

				INSERT INTO @InventoryTransferDetail (intInventoryTransferDetailId)
				SELECT @intInventoryTransferDetailId

				SELECT @intStageReceiptItemLotId = MIN(intStageReceiptItemLotId)
				FROM tblIPInvReceiptItemLotStage WITH (NOLOCK)
				WHERE intStageReceiptId = @intStageReceiptId
					AND intStageReceiptItemLotId > @intStageReceiptItemLotId
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

					SET @strInfo1 = ISNULL(@strReceiptNo, '')

					--Post Receipt
					EXEC uspICPostInventoryReceipt 1
						,0
						,@strReceiptNo
						,@intUserId
					
					DELETE
					FROM #tmpAddItemReceiptResult
					WHERE intInventoryReceiptId = @intInventoryReceiptId
				END
			END

			INSERT INTO tblIPInitialAck (
				intTrxSequenceNo
				,strCompanyLocation
				,dtmCreatedDate
				,strCreatedBy
				,intMessageTypeId
				,intStatusId
				,strStatusText
				,strReceiptNo
				)
			SELECT @intTrxSequenceNo
				,@strCompanyLocation
				,@dtmCreatedDate
				,@strCreatedBy
				,13 AS intMessageTypeId
				,1 AS intStatusId
				,'Success' AS strStatusText
				,@strReceiptNo

			INSERT INTO tblIPInvReceiptArchive (
				intTrxSequenceNo
				,strCompCode
				,intActionId
				,dtmCreated
				,strCreatedBy
				,strVendorAccountNo
				,strVendorRefNo
				,strERPReceiptNo
				,dtmReceiptDate
				,strBLNumber
				,strWarehouseRefNo
				,strTransferOrderNo
				,strERPTransferOrderNo
				,dtmTransactionDate
				)
			SELECT intTrxSequenceNo
				,strCompCode
				,intActionId
				,dtmCreated
				,strCreatedBy
				,strVendorAccountNo
				,strVendorRefNo
				,strERPReceiptNo
				,dtmReceiptDate
				,strBLNumber
				,strWarehouseRefNo
				,strTransferOrderNo
				,strERPTransferOrderNo
				,dtmTransactionDate
			FROM tblIPInvReceiptStage
			WHERE intStageReceiptId = @intStageReceiptId

			SELECT @intNewStageReceiptId = SCOPE_IDENTITY()

			INSERT INTO tblIPInvReceiptItemArchive (
				intStageReceiptId
				,intTrxSequenceNo
				,intParentTrxSequenceNo
				,strItemNo
				,dblQuantity
				,strQuantityUOM
				,dblGrossWeight
				,dblTareWeight
				,dblNetWeight
				,strNetWeightUOM
				,dblCost
				,strCostUOM
				,strCostCurrency
				,strSubLocationName
				,strStorageLocationName
				,strContainerNumber
				)
			SELECT @intNewStageReceiptId
				,intTrxSequenceNo
				,intParentTrxSequenceNo
				,strItemNo
				,dblQuantity
				,strQuantityUOM
				,dblGrossWeight
				,dblTareWeight
				,dblNetWeight
				,strNetWeightUOM
				,dblCost
				,strCostUOM
				,strCostCurrency
				,strSubLocationName
				,strStorageLocationName
				,strContainerNumber
			FROM tblIPInvReceiptItemStage
			WHERE intStageReceiptId = @intStageReceiptId

			INSERT INTO tblIPInvReceiptItemLotArchive (
				intStageReceiptId
				,intTrxSequenceNo
				,intParentTrxSequenceNo
				,strMotherLotNo
				,strLotNo
				,dblQuantity
				,strQuantityUOM
				,dblGrossWeight
				,dblTareWeight
				,dblNetWeight
				,strWeightUOM
				,strLotPrimaryStatus
				)
			SELECT @intNewStageReceiptId
				,intTrxSequenceNo
				,intParentTrxSequenceNo
				,strMotherLotNo
				,strLotNo
				,dblQuantity
				,strQuantityUOM
				,dblGrossWeight
				,dblTareWeight
				,dblNetWeight
				,strWeightUOM
				,strLotPrimaryStatus
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

			INSERT INTO tblIPInitialAck (
				intTrxSequenceNo
				,strCompanyLocation
				,dtmCreatedDate
				,strCreatedBy
				,intMessageTypeId
				,intStatusId
				,strStatusText
				,strReceiptNo
				)
			SELECT @intTrxSequenceNo
				,@strCompanyLocation
				,@dtmCreatedDate
				,@strCreatedBy
				,13 AS intMessageTypeId
				,0 AS intStatusId
				,@ErrMsg AS strStatusText
				,@strReceiptNo

			INSERT INTO tblIPInvReceiptError (
				intTrxSequenceNo
				,strCompCode
				,intActionId
				,dtmCreated
				,strCreatedBy
				,strVendorAccountNo
				,strVendorRefNo
				,strERPReceiptNo
				,dtmReceiptDate
				,strBLNumber
				,strWarehouseRefNo
				,strTransferOrderNo
				,strERPTransferOrderNo
				,dtmTransactionDate
				,strErrorMessage
				,strImportStatus
				)
			SELECT intTrxSequenceNo
				,strCompCode
				,intActionId
				,dtmCreated
				,strCreatedBy
				,strVendorAccountNo
				,strVendorRefNo
				,strERPReceiptNo
				,dtmReceiptDate
				,strBLNumber
				,strWarehouseRefNo
				,strTransferOrderNo
				,strERPTransferOrderNo
				,dtmTransactionDate
				,@ErrMsg
				,'Failed'
			FROM tblIPInvReceiptStage
			WHERE intStageReceiptId = @intStageReceiptId

			SELECT @intNewStageReceiptId = SCOPE_IDENTITY()

			INSERT INTO tblIPInvReceiptItemError (
				intStageReceiptId
				,intTrxSequenceNo
				,intParentTrxSequenceNo
				,strItemNo
				,dblQuantity
				,strQuantityUOM
				,dblGrossWeight
				,dblTareWeight
				,dblNetWeight
				,strNetWeightUOM
				,dblCost
				,strCostUOM
				,strCostCurrency
				,strSubLocationName
				,strStorageLocationName
				,strContainerNumber
				)
			SELECT @intNewStageReceiptId
				,intTrxSequenceNo
				,intParentTrxSequenceNo
				,strItemNo
				,dblQuantity
				,strQuantityUOM
				,dblGrossWeight
				,dblTareWeight
				,dblNetWeight
				,strNetWeightUOM
				,dblCost
				,strCostUOM
				,strCostCurrency
				,strSubLocationName
				,strStorageLocationName
				,strContainerNumber
			FROM tblIPInvReceiptItemStage
			WHERE intStageReceiptId = @intStageReceiptId

			INSERT INTO tblIPInvReceiptItemLotError (
				intStageReceiptId
				,intTrxSequenceNo
				,intParentTrxSequenceNo
				,strMotherLotNo
				,strLotNo
				,dblQuantity
				,strQuantityUOM
				,dblGrossWeight
				,dblTareWeight
				,dblNetWeight
				,strWeightUOM
				,strLotPrimaryStatus
				)
			SELECT @intNewStageReceiptId
				,intTrxSequenceNo
				,intParentTrxSequenceNo
				,strMotherLotNo
				,strLotNo
				,dblQuantity
				,strQuantityUOM
				,dblGrossWeight
				,dblTareWeight
				,dblNetWeight
				,strWeightUOM
				,strLotPrimaryStatus
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
