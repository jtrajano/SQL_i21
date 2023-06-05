CREATE PROCEDURE [dbo].[uspIPProcessERPInventoryAdjustment_EK] @strInfo1 NVARCHAR(MAX) = '' OUT
	,@strInfo2 NVARCHAR(MAX) = '' OUT
	,@intNoOfRowsAffected INT = 0 OUT
AS
BEGIN TRY
	SET QUOTED_IDENTIFIER OFF
	SET ANSI_NULLS ON
	SET NOCOUNT ON
	SET XACT_ABORT ON
	SET ANSI_WARNINGS ON

	DECLARE @intInventoryAdjustmentStageId INT
	DECLARE @ErrMsg NVARCHAR(max)
	DECLARE @dtmDate DATETIME
	DECLARE @intUserId INT
	DECLARE @strUserName NVARCHAR(100)
	DECLARE @strFinalErrMsg NVARCHAR(MAX) = ''
	DECLARE @ReceiptStagingTable ReceiptStagingTable
	DECLARE @OtherCharges ReceiptOtherChargesTableType
	DECLARE @TransferEntries AS InventoryTransferStagingTable
	DECLARE @intTransferId INT
		,@strTransactionId NVARCHAR(50)
		,@strWorkOrderNo NVARCHAR(50)
		,@intWorkOrderStatusId INT
	DECLARE @LotEntries ReceiptItemLotStagingTable
		,@ItemsForPost AS ItemCostingTableType
		,@intTrxSequenceNo BIGINT
		,@strCompanyLocation NVARCHAR(6)
		,@intActionId INT
		,@dtmCreatedDate DATETIME
		,@strCreatedBy NVARCHAR(50)
		,@intTransactionTypeId INT
		,@strStorageLocation NVARCHAR(50)
		,@strItemNo NVARCHAR(50)
		,@strMotherLotNo NVARCHAR(50)
		,@strLotNo NVARCHAR(50)
		,@strStorageUnit NVARCHAR(50)
		,@dblQuantity NUMERIC(38, 20)
		,@dblQty NUMERIC(38, 20)
		,@strQuantityUOM NVARCHAR(50)
		,@strReasonCode NVARCHAR(50)
		,@strNotes NVARCHAR(2048)
		,@strError NVARCHAR(MAX)
		,@intCompanyLocationSubLocationId INT
		,@intCompanyLocationId INT
		,@intStorageLocationId INT
		,@intItemId INT
		,@intUnitMeasureId INT
		,@intItemUOMId INT
		,@intLotId INT
		,@strAdjustmentNo NVARCHAR(50)
		,@intAdjustmentId INT
		,@intBatchId INT
		,@intTransactionId INT
		,@dblLastCost NUMERIC(18, 6)
		,@intItemLocationId INT
		,@GLEntries AS RecapTableType
		,@STARTING_NUMBER_BATCH AS INT = 3
		,@ACCOUNT_CATEGORY_TO_COUNTER_INVENTORY AS NVARCHAR(255) = 'Work In Progress'
		,@strBatchId AS NVARCHAR(40)
		,@intInventoryReceiptItemId INT
		,@intInventoryReceiptId INT
		,@intLoadContainerId INT
		,@intLoadId INT
		,@strNewStorageLocation NVARCHAR(50)
		,@strNewStorageUnit NVARCHAR(50)
		,@intCompanyLocationNewSubLocationId INT
		,@intNewStorageLocationId INT
		,@intNewLotId INT
		,@intLotItemUOMId INT
		,@dblWeightPerQty NUMERIC(38, 20)
		,@dblStandardCost NUMERIC(38, 20)
		,@ysnDifferenceQty BIT = 1
		,@intContractHeaderId INT
		,@intContractDetailId INT
		,@intLoadDetailId INT
		,@intParentLotId INT
		,@strParentLotNumber NVARCHAR(50)
		,@dblNoOfPack NUMERIC(38, 20)
		,@dblNetWeight NUMERIC(38, 20)
		,@strContainerNo NVARCHAR(50)
		,@strMarkings NVARCHAR(50)
		,@intEntityVendorId INT
		,@strCondition NVARCHAR(50)
		,@strOrderNo NVARCHAR(50)
		,@strPrevOrderNo NVARCHAR(50)
		,@intOrderCompleted INT
		,@intPrevOrderCompleted INT
		,@intWorkOrderId INT
		,@ItemsToReserve AS dbo.ItemReservationTableType
		,@ItemsToReserve2 AS dbo.ItemReservationTableType
		,@intLotStatusId INT
		,@strNetWeightUOM NVARCHAR(50)
		,@strStatus NVARCHAR(50)
		,@dtmExpiryDate DATETIME
		,@intFreightTermId INT
		,@strReceiptNo NVARCHAR(50)
		,@strActualLocationName NVARCHAR(50)
		,@strNewLocation NVARCHAR(50)
		,@intNewCompanyLocationId INT
		,@strNewLocationName NVARCHAR(50)
		,@strTranferOrderStatus NVARCHAR(50)
		,@dblWeight NUMERIC(38, 20)
		,@dblLotQuantity NUMERIC(38, 20)
		,@intNetWeightUnitMeasureId INT
		,@intNetWeightItemUOMId INT
		,@intStockReservationId INT
		,@intStockReservationId2 INT
		,@intLotId2 INT
		,@intSubLocationId2 INT
		,@intStorageLocationId2 INT
		,@intTransactionId2 INT
		,@ysnReservationByStorageLocation BIT
		,@intInventoryTransactionType INT
		,@ItemsToUnReserve AS dbo.ItemReservationTableType
		,@ItemsToReserve1 AS dbo.ItemReservationTableType
		,@intWorkOrderInputLotId INT
	DECLARE @StockReservation TABLE(intStockId int identity(1,1),intStockReservationId int, dblQty numeric(18,6))
	DECLARE @intRecordId INT
		,@intStockId INT		
		
	DECLARE @dblBalance NUMERIC(18,6), @intConsumedLotId INT
	DECLARE @tblMFWorkOrderInputLot TABLE(intRecordId int identity(1,1),intLotId INT, dblBalance NUMERIC(18,6), intConsumedLotId INT)
												
	DECLARE @tblICStockReservation TABLE (
		intTransactionId INT
		,intInventoryTransactionType INT
		)

	SELECT @dtmDate = GETDATE()

	SELECT @intUserId = intEntityId
	FROM tblSMUserSecurity WITH (NOLOCK)
	WHERE strUserName = 'IRELYADMIN'

	DECLARE @tblIPInventoryAdjustmentStage TABLE (intInventoryAdjustmentStageId INT)

	INSERT INTO @tblIPInventoryAdjustmentStage
	SELECT intInventoryAdjustmentStageId
	FROM tblIPInventoryAdjustmentStage
	WHERE intStatusId IS NULL

	UPDATE tblIPInventoryAdjustmentStage
	SET intStatusId = - 1
	WHERE intInventoryAdjustmentStageId IN (
			SELECT intInventoryAdjustmentStageId
			FROM @tblIPInventoryAdjustmentStage
			)

	SELECT @intInventoryAdjustmentStageId = MIN(intInventoryAdjustmentStageId)
	FROM @tblIPInventoryAdjustmentStage

	SELECT @strInfo1 = ''

	SELECT @strInfo1 = @strInfo1 + ISNULL(b.strLotNo, '') + ', '
	FROM @tblIPInventoryAdjustmentStage a
	JOIN tblIPInventoryAdjustmentStage b ON a.intInventoryAdjustmentStageId = b.intInventoryAdjustmentStageId

	IF Len(@strInfo1) > 0
	BEGIN
		SELECT @strInfo1 = Left(@strInfo1, Len(@strInfo1) - 1)
	END

	WHILE @intInventoryAdjustmentStageId IS NOT NULL
	BEGIN
		BEGIN TRY
			SELECT @intTrxSequenceNo = NULL
				,@strCompanyLocation = NULL
				,@intActionId = NULL
				,@dtmCreatedDate = NULL
				,@strCreatedBy = NULL
				,@intTransactionTypeId = NULL
				,@strStorageLocation = NULL
				,@strItemNo = NULL
				,@strMotherLotNo = NULL
				,@strLotNo = NULL
				,@strStorageUnit = NULL
				,@dblQuantity = NULL
				,@strQuantityUOM = NULL
				,@strReasonCode = NULL
				,@strNotes = NULL
				,@strNewStorageLocation = NULL
				,@strNewStorageUnit = NULL
				,@intCompanyLocationNewSubLocationId = NULL
				,@intNewStorageLocationId = NULL
				,@dblWeightPerQty = NULL
				,@strOrderNo = NULL
				,@intOrderCompleted = NULL
				,@strNetWeightUOM = NULL
				,@strStatus = NULL
				,@dtmExpiryDate = NULL
				,@strNewLocation = NULL
				,@strTranferOrderStatus = NULL

			SELECT @intTrxSequenceNo = intTrxSequenceNo
				,@strCompanyLocation = strCompanyLocation
				,@intActionId = intActionId
				,@dtmCreatedDate = dtmCreatedDate
				,@strCreatedBy = strCreatedBy
				,@intTransactionTypeId = intTransactionTypeId
				,@strStorageLocation = strStorageLocation
				,@strItemNo = strItemNo
				,@strMotherLotNo = strMotherLotNo
				,@strLotNo = strLotNo
				,@strStorageUnit = strStorageUnit
				,@dblQuantity = dblQuantity
				,@strQuantityUOM = strQuantityUOM
				,@dblQuantity = dblQuantity
				,@strQuantityUOM = strQuantityUOM
				,@dblNetWeight = dblNetWeight
				,@strNetWeightUOM = strNetWeightUOM
				,@strStatus = strStatus
				,@strReasonCode = strReasonCode
				,@strNotes = strNotes
				,@strNewLocation = strNewLocation
				,@strNewStorageLocation = strNewStorageLocation
				,@strNewStorageUnit = strNewStorageUnit
				,@strOrderNo = strOrderNo
				,@intOrderCompleted = intOrderCompleted
				,@dtmExpiryDate = dtmExpiryDate
				,@strTranferOrderStatus = strTranferOrderStatus
			FROM tblIPInventoryAdjustmentStage
			WHERE intInventoryAdjustmentStageId = @intInventoryAdjustmentStageId

			IF @strLotNo = ''
			BEGIN
				GOTO skipValidation
			END

			--IF EXISTS (
			--		SELECT 1
			--		FROM tblIPInventoryAdjustmentArchive
			--		WHERE intTrxSequenceNo = @intTrxSequenceNo
			--		)
			--BEGIN
			--	SELECT @strError = 'TrxSequenceNo ' + ltrim(@intTrxSequenceNo) + ' is already processed in i21.'
			--	RAISERROR (
			--			@strError
			--			,16
			--			,1
			--			)
			--END
			--IF EXISTS (
			--		SELECT 1
			--		FROM tblIPInventoryAdjustmentAck
			--		WHERE intTrxSequenceNo = @intTrxSequenceNo
			--		)
			--BEGIN
			--	SELECT @strError = 'TrxSequenceNo ' + Ltrim(@intTrxSequenceNo) + ' is exists in i21.'
			--	RAISERROR (
			--			@strError
			--			,16
			--			,1
			--			)
			--END
			SELECT @intCompanyLocationId = NULL
				,@strActualLocationName = NULL

			SELECT @intCompanyLocationId = intCompanyLocationId
				,@strActualLocationName = strLocationName
			FROM dbo.tblSMCompanyLocation
			WHERE strVendorRefNoPrefix = @strCompanyLocation
				AND strLocationType = 'Plant'

			IF @intCompanyLocationId IS NULL
			BEGIN
				SELECT @strError = 'Company Location ' + @strCompanyLocation + 'is not available.'

				RAISERROR (
						@strError
						,16
						,1
						)
			END

			IF (
					@strStorageLocation IS NULL
					OR @strStorageLocation = ''
					)
				AND @intTransactionTypeId <> 12
			BEGIN
				SELECT @strError = 'Storage Location cannot be blank.'

				RAISERROR (
						@strError
						,16
						,1
						)
			END

			SELECT @intCompanyLocationSubLocationId = NULL

			SELECT @intCompanyLocationSubLocationId = intCompanyLocationSubLocationId
			FROM dbo.tblSMCompanyLocationSubLocation
			WHERE strSubLocationName = @strActualLocationName + ' / ' + @strStorageLocation
				AND intCompanyLocationId = @intCompanyLocationId

			IF @intCompanyLocationSubLocationId IS NULL
			BEGIN
				SELECT @intCompanyLocationSubLocationId = intCompanyLocationSubLocationId
				FROM dbo.tblSMCompanyLocationSubLocation
				WHERE strSubLocationName = @strStorageLocation
					AND intCompanyLocationId = @intCompanyLocationId
			END

			IF @intCompanyLocationSubLocationId IS NULL
				AND @intTransactionTypeId <> 12
			BEGIN
				SELECT @strError = 'Storage Location ' + @strStorageLocation + ' is not available.'

				RAISERROR (
						@strError
						,16
						,1
						)
			END

			IF @strStorageUnit IS NULL
				OR @strStorageUnit = ''
			BEGIN
				SELECT @strStorageUnit = 'SU'
			END

			SELECT @intStorageLocationId = NULL

			SELECT @intStorageLocationId = intStorageLocationId
			FROM dbo.tblICStorageLocation
			WHERE strName = @strStorageUnit
				AND intSubLocationId = @intCompanyLocationSubLocationId

			IF @intStorageLocationId IS NULL
				AND @intTransactionTypeId <> 12
			BEGIN
				SELECT @strError = 'Storage Unit ' + @strStorageUnit + ' is not available.'

				RAISERROR (
						@strError
						,16
						,1
						)
			END

			IF @intTransactionTypeId IN (
					12
					,20
					)
			BEGIN
				SELECT @intNewCompanyLocationId = NULL
					,@strNewLocationName = NULL

				SELECT @intNewCompanyLocationId = intCompanyLocationId
					,@strNewLocationName = strLocationName
				FROM dbo.tblSMCompanyLocation
				WHERE strVendorRefNoPrefix = @strNewLocation
					AND strLocationType = 'Plant'

				IF @intNewCompanyLocationId IS NULL
				BEGIN
					SELECT @strError = 'New Company Location ' + @strNewLocationName + 'is not available.'

					RAISERROR (
							@strError
							,16
							,1
							)
				END

				IF @strNewStorageLocation IS NULL
					OR @strNewStorageLocation = ''
				BEGIN
					SELECT @strError = 'New Storage Location cannot be blank.'

					RAISERROR (
							@strError
							,16
							,1
							)
				END

				SELECT @intCompanyLocationNewSubLocationId = NULL

				SELECT @intCompanyLocationNewSubLocationId = intCompanyLocationSubLocationId
				FROM dbo.tblSMCompanyLocationSubLocation
				WHERE strSubLocationName = @strNewLocationName + ' / ' + @strNewStorageLocation
					AND intCompanyLocationId = @intNewCompanyLocationId

				IF @intCompanyLocationNewSubLocationId IS NULL
				BEGIN
					SELECT @intCompanyLocationNewSubLocationId = intCompanyLocationSubLocationId
					FROM dbo.tblSMCompanyLocationSubLocation
					WHERE strSubLocationName = @strNewStorageLocation
						AND intCompanyLocationId = @intNewCompanyLocationId
				END

				IF @intCompanyLocationNewSubLocationId IS NULL
				BEGIN
					SELECT @strError = 'New Storage Location ' + @strNewStorageLocation + ' is not available.'

					RAISERROR (
							@strError
							,16
							,1
							)
				END

				IF @strNewStorageUnit IS NULL
					OR @strNewStorageUnit = ''
				BEGIN
					SELECT @strNewStorageUnit = 'SU'
				END

				SELECT @intNewStorageLocationId = NULL

				SELECT @intNewStorageLocationId = intStorageLocationId
				FROM dbo.tblICStorageLocation
				WHERE strName = @strNewStorageUnit
					AND intSubLocationId = @intCompanyLocationNewSubLocationId

				IF @intNewStorageLocationId IS NULL
				BEGIN
					SELECT @strError = 'New Storage Unit ' + @strNewStorageUnit + ' is not available.'

					RAISERROR (
							@strError
							,16
							,1
							)
				END
			END

			--IF @strItemNo IS NULL
			--	OR @strItemNo = ''
			--BEGIN
			--	SELECT @strError = 'Item cannot be blank.'
			--	RAISERROR (
			--			@strError
			--			,16
			--			,1
			--			)
			--END
			SELECT @intItemId = NULL

			SELECT @intItemId = intItemId
			FROM dbo.tblICItem
			WHERE strItemNo = @strItemNo

			--IF @intItemId IS NULL
			--BEGIN
			--	SELECT @strError = 'Item ' + @strItemNo + ' is not available.'
			--	RAISERROR (
			--			@strError
			--			,16
			--			,1
			--			)
			--END
			SELECT @intLotId = NULL
				,@dblQty = NULL
				,@dblWeight = NULL

			--SELECT @intItemId = NULL
			SELECT @intLotId = intLotId
				,@dblLastCost = dblLastCost
				,@intLotItemUOMId = intItemUOMId
				,@dblWeightPerQty = dblWeightPerQty
				,@dblQty = dblQty
				,@dblWeight = (
					CASE 
						WHEN dblWeight IS NULL
							OR dblWeight = 0
							THEN dblQty
						ELSE dblWeight
						END
					)
				,@intItemId = (
					CASE 
						WHEN @intItemId IS NOT NULL
							THEN @intItemId
						ELSE intItemId
						END
					)
			FROM tblICLot
			WHERE strLotNumber = @strLotNo
				AND intStorageLocationId = @intStorageLocationId

			IF @intTransactionTypeId NOT IN (
					16
					,18
					)
			BEGIN
				IF @strQuantityUOM IS NULL
					OR @strQuantityUOM = ''
				BEGIN
					SELECT @strError = 'UOM cannot be blank.'

					RAISERROR (
							@strError
							,16
							,1
							)
				END

				SELECT @intUnitMeasureId = NULL

				SELECT @intUnitMeasureId = intUnitMeasureId
				FROM dbo.tblICUnitMeasure
				WHERE strUnitMeasure = @strQuantityUOM

				IF @intUnitMeasureId IS NULL
				BEGIN
					SELECT @strError = 'Unit Measure ' + @strQuantityUOM + ' is not available.'

					RAISERROR (
							@strError
							,16
							,1
							)
				END

				SELECT @intItemUOMId = NULL

				SELECT @intItemUOMId = intItemUOMId
				FROM tblICItemUOM
				WHERE intItemId = @intItemId
					AND intUnitMeasureId = @intUnitMeasureId
			END

			IF @intLotId IS NULL
				AND @strLotNo <> ''
				AND @intTransactionTypeId <> 12
			BEGIN
				SELECT @strError = 'Lot ' + @strLotNo + ' is not available in the storage unit ' + @strStorageUnit + '.'

				RAISERROR (
						@strError
						,16
						,1
						)
			END

			IF @intTransactionTypeId = 12
			BEGIN
				SELECT @intLotItemUOMId = intItemUOMId
					,@dblWeightPerQty = dblWeightPerQty
					,@intItemId = (
						CASE 
							WHEN @intItemId IS NOT NULL
								THEN @intItemId
							ELSE intItemId
							END
						)
				FROM tblICLot
				WHERE strLotNumber = @strLotNo
					AND dblWeightPerQty > 1
			END

			IF EXISTS (
					SELECT *
					FROM tblICInventoryTransfer IT
					WHERE IT.strERPTransferNo = @strNotes
						AND intStatusId = 2
					)
				AND @dblQuantity < 0
			BEGIN
				SELECT @strError = 'ERP Transfer Order Number ' + @strNotes + ' is already processed in i21.'

				RAISERROR (
						@strError
						,16
						,1
						)
			END

			IF EXISTS (
					SELECT *
					FROM tblICInventoryTransfer IT
					WHERE IT.strERPTransferNo = @strNotes
						AND intStatusId = 3
					)
				AND @dblQuantity > 0
			BEGIN
				SELECT @strError = 'ERP Transfer Order Number ' + @strNotes + ' is already processed in i21.'

				RAISERROR (
						@strError
						,16
						,1
						)
			END

			skipValidation:

			BEGIN TRAN

			IF @intTransactionTypeId = 12
			BEGIN
				DECLARE @intInventoryTransferId INT
					,@intInventoryTransferDetailId INT
					,@strTransferOrderNo NVARCHAR(50)

				SELECT @intInventoryTransferId = NULL
					,@intInventoryTransferDetailId = NULL
					,@strTransferOrderNo = NULL

				SELECT @intInventoryTransferId = IT.intInventoryTransferId
					,@intInventoryTransferDetailId = ITD.intInventoryTransferDetailId
					,@strTransferOrderNo = strTransferNo
				FROM tblICInventoryTransfer IT
				JOIN tblICInventoryTransferDetail ITD ON IT.intInventoryTransferId = ITD.intInventoryTransferId
				WHERE IT.strERPTransferNo = @strNotes
					AND ITD.intLotId = @intLotId

				IF @intInventoryTransferId IS NULL
					AND @dblQuantity < 0
				BEGIN
					IF NOT EXISTS (
							SELECT 1
							FROM tempdb..sysobjects
							WHERE id = OBJECT_ID('tempdb..#tmpAddInventoryTransferResult')
							)
					BEGIN
						CREATE TABLE #tmpAddInventoryTransferResult (
							intSourceId INT
							,intInventoryTransferId INT
							)
					END

					IF NOT EXISTS (
							SELECT *
							FROM @TransferEntries
							WHERE strERPTransferNo = @strNotes
							)
					BEGIN
						DELETE
						FROM @TransferEntries
					END

					IF @dblWeightPerQty > 0
					BEGIN
						SELECT @dblLotQuantity = dbo.[fnDivide](@dblQuantity, @dblWeightPerQty)
					END
					ELSE
					BEGIN
						SELECT @dblLotQuantity = @dblQuantity
							,@intLotItemUOMId = @intItemUOMId
					END

					SELECT @intNetWeightUnitMeasureId = NULL

					SELECT @intNetWeightUnitMeasureId = intUnitMeasureId
					FROM dbo.tblICUnitMeasure
					WHERE strUnitMeasure = @strNetWeightUOM

					IF @intNetWeightUnitMeasureId IS NULL
					BEGIN
						SELECT @strError = 'Unit Measure ' + @strNetWeightUOM + ' is not available.'

						RAISERROR (
								@strError
								,16
								,1
								)
					END

					SELECT @intNetWeightItemUOMId = NULL

					SELECT @intNetWeightItemUOMId = intItemUOMId
					FROM tblICItemUOM
					WHERE intItemId = @intItemId
						AND intUnitMeasureId = @intNetWeightUnitMeasureId

					-- Insert the data needed to create the inventory transfer.
					INSERT INTO @TransferEntries (
						-- Header
						[dtmTransferDate]
						,[strTransferType]
						,[intSourceType]
						,[strDescription]
						,[intFromLocationId]
						,[intToLocationId]
						,[ysnShipmentRequired]
						,[intStatusId]
						,[intShipViaId]
						,[intFreightUOMId]
						-- Detail
						,[intItemId]
						,[intLotId]
						,[intItemUOMId]
						,[dblQuantityToTransfer]
						,intItemWeightUOMId
						,[dblGrossWeight]
						,[dblTareWeight]
						,[strNewLotId]
						,[intFromSubLocationId]
						,[intToSubLocationId]
						,[intFromStorageLocationId]
						,[intToStorageLocationId]
						-- Integration Field
						,[intInventoryTransferId]
						,[intSourceId]
						,[strSourceId]
						,[strSourceScreenName]
						,strERPTransferNo
						)
					SELECT -- Header
						[dtmTransferDate] = GETDATE()
						,[strTransferType] = 'Location to Location'
						,[intSourceType] = 0
						,[strDescription] = NULL
						,[intFromLocationId] = @intCompanyLocationId
						,[intToLocationId] = @intNewCompanyLocationId
						,[ysnShipmentRequired] = 1
						,[intStatusId] = 1
						,[intShipViaId] = NULL
						,[intFreightUOMId] = NULL
						-- Detail
						,[intItemId] = @intItemId
						,[intLotId] = @intLotId
						,[intItemUOMId] = @intLotItemUOMId
						,[dblQuantityToTransfer] = ABS(@dblLotQuantity)
						,intItemWeightUOMId = @intNetWeightItemUOMId
						,[dblGrossWeight] = ABS(dbo.fnMFConvertQuantityToTargetItemUOM(@intLotItemUOMId, @intNetWeightItemUOMId, @dblLotQuantity))
						,[dblTareWeight] = 0
						,[strNewLotId] = NULL
						,[intFromSubLocationId] = @intCompanyLocationSubLocationId
						,[intToSubLocationId] = @intCompanyLocationNewSubLocationId
						,[intFromStorageLocationId] = @intStorageLocationId
						,[intToStorageLocationId] = @intNewStorageLocationId
						-- Integration Field
						,[intInventoryTransferId] = NULL
						,[intSourceId] = @intInventoryAdjustmentStageId
						,[strSourceId] = @strNotes
						,[strSourceScreenName] = 'Stock Transfer'
						,strERPTransferNo = @strNotes

					IF NOT EXISTS (
							SELECT 1
							FROM tblIPInventoryAdjustmentStage
							WHERE intInventoryAdjustmentStageId > @intInventoryAdjustmentStageId
								AND strNotes = @strNotes
								AND dblQuantity < 0
							)
					BEGIN
						-- Call uspICAddInventoryTransfer stored procedure.
						EXEC dbo.uspICAddInventoryTransfer @TransferEntries
							,@intUserId

						DELETE
						FROM @TransferEntries

						-- Post the Inventory Transfers                                            
						WHILE EXISTS (
								SELECT TOP 1 1
								FROM #tmpAddInventoryTransferResult
								)
						BEGIN
							SELECT @intTransferId = NULL
								,@strTransactionId = NULL

							SELECT TOP 1 @intTransferId = intInventoryTransferId
							FROM #tmpAddInventoryTransferResult

							-- Post the Inventory Transfer that was created
							SELECT @strTransactionId = strTransferNo
							FROM tblICInventoryTransfer
							WHERE intInventoryTransferId = @intTransferId

							EXEC dbo.uspICPostInventoryTransfer 1
								,0
								,@strTransactionId
								,@intUserId;

							DELETE
							FROM #tmpAddInventoryTransferResult
							WHERE intInventoryTransferId = @intTransferId
						END;
					END
				END
				ELSE
				BEGIN
					----************************************************
					SELECT @intFreightTermId = intFreightTermId
					FROM tblSMFreightTerms WITH (NOLOCK)
					WHERE strFreightTerm = 'Deliver'
						AND strFobPoint = 'Destination'

					IF @dblWeightPerQty > 0
					BEGIN
						SELECT @dblLotQuantity = dbo.[fnDivide](@dblQuantity, @dblWeightPerQty)
					END
					ELSE
					BEGIN
						SELECT @dblLotQuantity = @dblQuantity
							,@intLotItemUOMId = @intItemUOMId
					END

					SELECT @intNetWeightUnitMeasureId = NULL

					SELECT @intNetWeightUnitMeasureId = intUnitMeasureId
					FROM dbo.tblICUnitMeasure
					WHERE strUnitMeasure = @strNetWeightUOM

					IF @intNetWeightUnitMeasureId IS NULL
					BEGIN
						SELECT @strError = 'Unit Measure ' + @strNetWeightUOM + ' is not available.'

						RAISERROR (
								@strError
								,16
								,1
								)
					END

					SELECT @intNetWeightItemUOMId = NULL

					SELECT @intNetWeightItemUOMId = intItemUOMId
					FROM tblICItemUOM
					WHERE intItemId = @intItemId
						AND intUnitMeasureId = @intNetWeightUnitMeasureId

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
						,intEntityVendorId = - 1
						,intShipFromId = - 1
						,intTransferorId = IT.intFromLocationId
						,intLocationId = IT.intToLocationId
						,strBillOfLadding = IT.strBolNumber
						,intItemId = ITD.intItemId
						,intItemLocationId = @intCompanyLocationId
						,intItemUOMId = ITD.intItemUOMId
						,intContractHeaderId = @intInventoryTransferId
						,intContractDetailId = @intInventoryTransferDetailId
						,dtmDate = GETDATE()
						,intShipViaId = IT.intShipViaId
						,dblQty = Case When Round(@dblLotQuantity,0)=0 Then 1 Else Round(@dblLotQuantity,0) End
						,intGrossNetUOMId = @intNetWeightItemUOMId
						,dblGross = dbo.fnMFConvertQuantityToTargetItemUOM(ITD.intItemUOMId, @intNetWeightItemUOMId, @dblLotQuantity)
						,dblNet = dbo.fnMFConvertQuantityToTargetItemUOM(ITD.intItemUOMId, @intNetWeightItemUOMId, @dblLotQuantity)
						,dblCost = ITD.dblCost
						,intCostUOMId = @intItemUOMId
						,intCurrencyId = ITD.intCurrencyId
						,intSubCurrencyCents = 1
						,dblExchangeRate = 1
						,intLotId = NULL
						,intSubLocationId = ITD.intToSubLocationId
						,intStorageLocationId = ITD.intToStorageLocationId
						,ysnIsStorage = 0
						,intSourceId = NULL
						,intSourceType = 0 -- Transfer Order
						,strSourceId = @strTransferOrderNo
						,strSourceScreenName = 'External System'
						,ysnSubCurrency = 0
						,intForexRateTypeId = NULL
						,dblForexRate = NULL
						,intContainerId = NULL
						,intFreightTermId = NULL
						,intBookId = NULL
						,intSubBookId = NULL
						,intSort = @intInventoryTransferDetailId
						,intLoadShipmentId = NULL
						,intLoadShipmentDetailId = NULL
						,strVendorRefNo = NULL
						,dblUnitRetail = ITD.dblCost
						,intShipFromEntityId = NULL
						,strWarehouseRefNo = NULL
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
						,strCertificate
						,strCertificateId
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
						,dblGrossWeight = dbo.fnMFConvertQuantityToTargetItemUOM(RI.intItemUOMId, @intNetWeightItemUOMId, RI.dblQty)
						,dblTareWeight = 0
						,dblCost = 0
						,strContainerNo = NULL
						,intSort = RI.intSort
						,strMarkings = NULL
						,strCondition = 'Clean Wgt'
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
						,strCertificate = NULL --@strCertificate
						,strCertificateId = NULL --@strCertificateId
					FROM @ReceiptStagingTable RI
					WHERE RI.intInventoryTransferId = @intInventoryTransferId
						AND RI.intInventoryTransferDetailId = @intInventoryTransferDetailId
				END

				IF EXISTS (
						SELECT 1
						FROM @ReceiptStagingTable
						)
					AND NOT EXISTS (
						SELECT 1
						FROM tblIPInventoryAdjustmentStage
						WHERE intInventoryAdjustmentStageId > @intInventoryAdjustmentStageId
							AND strNotes = @strNotes
							AND dblQuantity > 0
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

						--	--Post Receipt
						EXEC uspICPostInventoryReceipt 1
							,0
							,@strReceiptNo
							,@intUserId

						UPDATE tblICInventoryTransfer
						SET intStatusId = 3
						WHERE intInventoryTransferId = @intInventoryTransferId

						DELETE
						FROM #tmpAddItemReceiptResult
						WHERE intInventoryReceiptId = @intInventoryReceiptId
					END
				END
						----************************************************
			END
			ELSE IF @intTransactionTypeId = 20 --Lot Move
			BEGIN
				IF @dblWeight - @dblQuantity < 0
					AND ABS(@dblWeight - @dblQuantity) < 1
				BEGIN
					SELECT @dblQuantity = @dblWeight
				END

				IF @dblWeightPerQty > 0
				BEGIN
					SELECT @dblQuantity = dbo.[fnDivide](@dblQuantity, @dblWeightPerQty)
				END

				SELECT @intItemUOMId = @intLotItemUOMId

				EXEC dbo.uspMFLotMove @intLotId = @intLotId
					,@intNewSubLocationId = @intCompanyLocationNewSubLocationId
					,@intNewStorageLocationId = @intNewStorageLocationId
					,@dblMoveQty = @dblQuantity
					,@intMoveItemUOMId = @intItemUOMId
					,@intUserId = @intUserId
					,@blnValidateLotReservation = 1
					,@blnInventoryMove = 1
					,@dtmDate = NULL
					,@strReasonCode = @strReasonCode
					,@strNotes = @strNotes
					,@ysnBulkChange = 0
					,@ysnSourceLotEmptyOut = 0
					,@ysnDestinationLotEmptyOut = 0
					,@intNewLotId = @intNewLotId OUTPUT
					,@intWorkOrderId = NULL
					,@intAdjustmentId = @intAdjustmentId OUTPUT
					,@ysnExternalSystemMove = 1

				SELECT @strAdjustmentNo = NULL

				SELECT @strAdjustmentNo = strAdjustmentNo
				FROM dbo.tblICInventoryAdjustment
				WHERE intInventoryAdjustmentId = @intAdjustmentId
			END
			ELSE IF @intTransactionTypeId = 10 --Quantity Change
			BEGIN
				EXEC dbo.uspMFLotAdjustQty @intLotId = @intLotId
					,@dblNewLotQty = @dblQuantity
					,@intAdjustItemUOMId = @intItemUOMId
					,@intUserId = @intUserId
					,@strReasonCode = @strReasonCode
					,@blnValidateLotReservation = 0
					,@strNotes = @strNotes
					,@dtmDate = NULL
					,@ysnBulkChange = 0
					,@strReferenceNo = NULL
					,@intAdjustmentId = @intAdjustmentId OUTPUT
					,@ysnDifferenceQty = @ysnDifferenceQty
			END
			ELSE IF @intTransactionTypeId = 16 --Status Change
			BEGIN
				SELECT @intLotStatusId = NULL

				SELECT @intLotStatusId = intLotStatusId
				FROM tblICLotStatus
				WHERE strPrimaryStatus = @strStatus

				EXEC uspMFSetLotStatus @intLotId
					,@intLotStatusId
					,@intUserId
					,@strNotes
					,@strReasonCode
					,@dtmDate
					,@ysnBulkChange = 0
			END
			ELSE IF @intTransactionTypeId = 18 --Expiry Date Change
			BEGIN
				EXEC uspMFSetLotExpiryDate @intLotId = @intLotId
					,@dtmNewExpiryDate = @dtmExpiryDate
					,@intUserId = @intUserId
					,@strReasonCode = @strReasonCode
					,@strNotes = @strNotes
					,@dtmDate = @dtmDate
					,@ysnBulkChange = 0
			END
			ELSE IF @intTransactionTypeId IN (
					8
					,0
					,- 8
					)
			BEGIN
				SELECT @ysnReservationByStorageLocation=IsNULL(ysnDefaultPalletTagReprintonPositiveRelease,0)
				FROM tblSMCompanyLocation
				WHERE intCompanyLocationId =@intCompanyLocationId 

				IF @ysnReservationByStorageLocation IS NULL
				BEGIN
					SELECT @ysnReservationByStorageLocation=0 
				END

				IF @strLotNo = ''
				BEGIN
					SELECT @intWorkOrderId = NULL
						,@strWorkOrderNo = NULL

					SELECT @intWorkOrderId = intWorkOrderId
						,@strWorkOrderNo = strWorkOrderNo
						,@intCompanyLocationId=intLocationId
					FROM tblMFWorkOrder
					WHERE strERPOrderNo = @strOrderNo

					SELECT @ysnReservationByStorageLocation=IsNULL(ysnDefaultPalletTagReprintonPositiveRelease,0)
					FROM tblSMCompanyLocation
					WHERE intCompanyLocationId =@intCompanyLocationId 

					IF @ysnReservationByStorageLocation IS NULL
					BEGIN
						SELECT @ysnReservationByStorageLocation=0 
					END

					IF @ysnReservationByStorageLocation = 0
					BEGIN
						DELETE
						FROM @ItemsToReserve

						EXEC dbo.uspICCreateStockReservation @ItemsToReserve
							,@intWorkOrderId
							,8
					END

					UPDATE tblMFWorkOrder
					SET intStatusId = 13
						,dtmCompletedDate = GETDATE()
					WHERE intWorkOrderId = @intWorkOrderId

					UPDATE tblMFBlendRequirement
					SET intStatusId = 2
					WHERE strReferenceNo = @strOrderNo
				END
				ELSE
				BEGIN
					EXEC dbo.uspMFGeneratePatternId @intCategoryId = NULL
						,@intItemId = @intItemId
						,@intManufacturingId = NULL
						,@intSubLocationId = NULL
						,@intLocationId = @intCompanyLocationId
						,@intOrderTypeId = NULL
						,@intBlendRequirementId = NULL
						,@intPatternCode = 33
						,@ysnProposed = 0
						,@strPatternString = @intTransactionId OUTPUT

					SELECT @intItemLocationId = NULL

					SELECT @intItemLocationId = intItemLocationId
					FROM tblICItemLocation
					WHERE intItemId = @intItemId
						AND intLocationId = @intCompanyLocationId

					EXEC dbo.uspSMGetStartingNumber @STARTING_NUMBER_BATCH
						,@strBatchId OUTPUT

					SELECT @dtmDate = dbo.fnGetBusinessDate(GETDATE(), @intCompanyLocationId)

					IF @dblLastCost IS NULL
					BEGIN
						SELECT @dblLastCost = t.dblStandardCost
						FROM tblICItemPricing t WITH (NOLOCK)
						WHERE t.intItemId = @intItemId
							AND t.intItemLocationId = @intItemLocationId
					END

					IF @dblLastCost IS NULL
					BEGIN
						SELECT @dblLastCost = 0
					END

					IF @dblWeight - abs(@dblQuantity) < 0
						AND ABS(@dblWeight - abs(@dblQuantity)) < 1
					BEGIN
						SELECT @dblQuantity = Case When @intTransactionTypeId=8 Then -@dblWeight Else @dblWeight End
					END

					--Lot Tracking
					IF NOT EXISTS (
							SELECT *
							FROM @ItemsForPost
							WHERE strTransactionId = @strOrderNo
							)
					BEGIN
						DELETE
						FROM @ItemsForPost
					END

					INSERT INTO @ItemsForPost (
						intItemId
						,intItemLocationId
						,intItemUOMId
						,dtmDate
						,dblQty
						,dblUOMQty
						,dblCost
						,dblSalesPrice
						,intCurrencyId
						,dblExchangeRate
						,intTransactionId
						,intTransactionDetailId
						,strTransactionId
						,intTransactionTypeId
						,intLotId
						,intSubLocationId
						,intStorageLocationId
						,intSourceTransactionId
						,strSourceTransactionId
						)
					SELECT intItemId = @intItemId
						,intItemLocationId = @intItemLocationId
						,intItemUOMId = @intItemUOMId
						,dtmDate = @dtmDate
						,dblQty = @dblQuantity
						,dblUOMQty = 1
						,dblCost = @dblLastCost
						,dblSalesPrice = 0
						,intCurrencyId = NULL
						,dblExchangeRate = 1
						,intTransactionId = @intTransactionId
						,intTransactionDetailId = @intTransactionId
						,strTransactionId = @strOrderNo
						,intTransactionTypeId = 8
						,intLotId = @intLotId
						,intSubLocationId = @intCompanyLocationSubLocationId
						,intStorageLocationId = @intStorageLocationId
						,intSourceTransactionId = 8
						,strSourceTransactionId = @intTransactionId

						--*********************
						SELECT @intWorkOrderId = NULL
							,@intWorkOrderInputLotId=NULL
						
						SELECT @intWorkOrderId = intWorkOrderId
						FROM tblMFWorkOrder
						WHERE strERPOrderNo = @strOrderNo
						
						SELECT @intWorkOrderInputLotId =intWorkOrderInputLotId  
						FROM dbo.tblMFWorkOrderInputLot WI
						WHERE WI.intWorkOrderId =@intWorkOrderId 
						AND WI.intLotId IN (SELECT L.intLotId FROM tblICLot L Where strLotNumber=@strLotNo )

						UPDATE dbo.tblMFWorkOrderInputLot 
						SET intConsumedLotId =@intLotId, dblConsumedQty =IsNULL(dblConsumedQty,0)+@dblQuantity 
						WHERE intWorkOrderInputLotId =@intWorkOrderInputLotId 
						--*********************

					IF @intTransactionTypeId = 8
						AND @ysnReservationByStorageLocation = 0
					BEGIN
						SELECT @intWorkOrderId = NULL
							,@strWorkOrderNo = NULL

						SELECT @intWorkOrderId = intWorkOrderId
							,@strWorkOrderNo = strWorkOrderNo
						FROM tblMFWorkOrder
						WHERE strERPOrderNo = @strOrderNo

						SELECT @intStockReservationId = NULL
							,@intStockReservationId2 = NULL
							,@intLotId2 = NULL
							,@intSubLocationId2 = NULL
							,@intStorageLocationId2 = NULL
							,@intTransactionId2 = NULL

						SELECT @intStockReservationId = NULL

						SELECT @intStockReservationId = intStockReservationId
						FROM tblICStockReservation
						WHERE intLotId = @intLotId
							AND dblQty = @dblQuantity
							AND intTransactionId = @intWorkOrderId
							AND ysnPosted = 0

						IF @intStockReservationId IS NULL
						BEGIN
							SELECT @intStockReservationId2 = intStockReservationId
								,@intLotId2 = intLotId
								,@intSubLocationId2 = intSubLocationId
								,@intStorageLocationId2 = intStorageLocationId
								,@intTransactionId2 = intTransactionId
							FROM tblICStockReservation SR
							WHERE dblQty = abs(@dblQuantity)
								AND intTransactionId = @intWorkOrderId
								AND ysnPosted = 0
								AND SR.intLotId IN (
									SELECT L.intLotId
									FROM tblICLot L
									WHERE L.strLotNumber = @strLotNo
									)

							SELECT @intStockReservationId = intStockReservationId
							FROM tblICStockReservation
							WHERE intLotId = @intLotId
								AND dblQty = abs(@dblQuantity)
								AND ysnPosted = 0

							UPDATE tblICStockReservation
							SET intLotId = @intLotId2
								,intSubLocationId = @intSubLocationId2
								,intStorageLocationId = @intStorageLocationId2
							WHERE intStockReservationId = @intStockReservationId

							UPDATE tblICStockReservation
							SET intLotId = @intLotId
								,intSubLocationId = @intCompanyLocationSubLocationId
								,intStorageLocationId = @intStorageLocationId
							WHERE intStockReservationId = @intStockReservationId2
						END
					END

					IF NOT EXISTS (
							SELECT *
							FROM tblIPInventoryAdjustmentStage
							WHERE strOrderNo = @strOrderNo
								AND intStatusId = - 1
								AND intInventoryAdjustmentStageId > @intInventoryAdjustmentStageId
							)
					BEGIN
						SELECT @intWorkOrderId = NULL
							,@strWorkOrderNo = NULL
							,@intWorkOrderStatusId = NULL

						SELECT @intWorkOrderId = intWorkOrderId
							,@strWorkOrderNo = strWorkOrderNo
							,@intWorkOrderStatusId = intStatusId
						FROM tblMFWorkOrder
						WHERE strERPOrderNo = @strOrderNo

						IF @ysnReservationByStorageLocation = 0
						BEGIN
							DELETE
							FROM @ItemsToReserve2

							INSERT INTO @ItemsToReserve2 (
								intItemId
								,intItemLocationId
								,intItemUOMId
								,intLotId
								,intSubLocationId
								,intStorageLocationId
								,dblQty
								,intTransactionId
								,strTransactionId
								,intTransactionTypeId
								)
							SELECT intItemId = SR.intItemId
								,intItemLocationId = SR.intItemLocationId
								,intItemUOMId = SR.intItemUOMId
								,intLotId = SR.intLotId
								,intSubLocationId = SR.intSubLocationId
								,intStorageLocationId = SR.intStorageLocationId
								,dblQty = SR.dblQty
								,intTransactionId = SR.intTransactionId
								,strTransactionId = SR.strTransactionId
								,intTransactionTypeId = 8
							FROM tblICStockReservation SR
							WHERE SR.intTransactionId = @intWorkOrderId
								AND SR.strTransactionId = @strWorkOrderNo
								AND SR.intInventoryTransactionType = 8

							EXEC dbo.uspICCreateStockReservation @ItemsToReserve
								,@intWorkOrderId
								,8
						END
						ELSE
						BEGIN
							INSERT INTO @tblICStockReservation (
								intTransactionId
								,intInventoryTransactionType
								)
							SELECT DISTINCT TOP 1 R.intTransactionId
								,R.intInventoryTransactionType
							FROM tblICStockReservation R
							JOIN @ItemsForPost L ON L.intLotId = R.intLotId
								AND ysnPosted = 0
								AND R.dblQty > 0

							DELETE
							FROM @ItemsToReserve2

							INSERT INTO @ItemsToReserve2 (
								intItemId
								,intItemLocationId
								,intItemUOMId
								,intLotId
								,intSubLocationId
								,intStorageLocationId
								,dblQty
								,intTransactionId
								,strTransactionId
								,intTransactionTypeId
								)
							SELECT SR.intItemId
								,SR.intItemLocationId
								,SR.intItemUOMId
								,SR.intLotId
								,SR.intSubLocationId
								,SR.intStorageLocationId
								,SR.dblQty
								,SR.intTransactionId
								,SR.strTransactionId
								,SR.intInventoryTransactionType
							FROM tblICStockReservation SR
							JOIN @tblICStockReservation SR1 ON SR1.intTransactionId = SR.intTransactionId
								AND SR1.intInventoryTransactionType = SR.intInventoryTransactionType

							SELECT @intTransactionId = MIN(intTransactionId)
							FROM @tblICStockReservation

							WHILE @intTransactionId IS NOT NULL
							BEGIN
								SELECT @intInventoryTransactionType = intInventoryTransactionType
								FROM @tblICStockReservation
								WHERE intTransactionId = @intTransactionId

								EXEC dbo.uspICCreateStockReservation @ItemsToUnReserve
									,@intTransactionId
									,@intInventoryTransactionType

								SELECT @intTransactionId = MIN(intTransactionId)
								FROM @tblICStockReservation
								WHERE intTransactionId > @intTransactionId
							END
						END

						DELETE
						FROM @GLEntries

						-- Call the post routine 
						INSERT INTO @GLEntries (
							[dtmDate]
							,[strBatchId]
							,[intAccountId]
							,[dblDebit]
							,[dblCredit]
							,[dblDebitUnit]
							,[dblCreditUnit]
							,[strDescription]
							,[strCode]
							,[strReference]
							,[intCurrencyId]
							,[dblExchangeRate]
							,[dtmDateEntered]
							,[dtmTransactionDate]
							,[strJournalLineDescription]
							,[intJournalLineNo]
							,[ysnIsUnposted]
							,[intUserId]
							,[intEntityId]
							,[strTransactionId]
							,[intTransactionId]
							,[strTransactionType]
							,[strTransactionForm]
							,[strModuleName]
							,[intConcurrencyId]
							,[dblDebitForeign]
							,[dblDebitReport]
							,[dblCreditForeign]
							,[dblCreditReport]
							,[dblReportingRate]
							,[dblForeignRate]
							,[strRateType]
							,[intSourceEntityId]
							,[intCommodityId]
							)
						EXEC dbo.uspICPostCosting @ItemsForPost
							,@strBatchId
							,@ACCOUNT_CATEGORY_TO_COUNTER_INVENTORY
							,@intUserId

						EXEC dbo.uspGLBookEntries @GLEntries
							,1

						DELETE
						FROM @ItemsToReserve

						IF @intOrderCompleted = 0
							AND @intWorkOrderStatusId <> 13
						BEGIN
							IF @ysnReservationByStorageLocation = 0
							BEGIN
								INSERT INTO @ItemsToReserve (
									intItemId
									,intItemLocationId
									,intItemUOMId
									,intLotId
									,intSubLocationId
									,intStorageLocationId
									,dblQty
									,intTransactionId
									,strTransactionId
									,intTransactionTypeId
									)
								SELECT intItemId = SR.intItemId
									,intItemLocationId = SR.intItemLocationId
									,intItemUOMId = SR.intItemUOMId
									,intLotId = SR.intLotId
									,intSubLocationId = SR.intSubLocationId
									,intStorageLocationId = SR.intStorageLocationId
									,dblQty = CASE 
										WHEN SR.dblQty + IsNULL(RR1.dblQty, 0) < 0
											THEN 0
										ELSE SR.dblQty + IsNULL(RR1.dblQty, 0)
										END
									,intTransactionId = SR.intTransactionId
									,strTransactionId = SR.strTransactionId
									,intTransactionTypeId = 8
								FROM @ItemsToReserve2 SR
								JOIN tblICLot L ON L.intLotId = SR.intLotId
								OUTER APPLY (
									SELECT TOP 1 RR.dblQty
									FROM @ItemsForPost RR
									JOIN tblICLot L2 ON L2.intLotId = RR.intLotId
									WHERE L2.strLotNumber = L.strLotNumber
									) RR1

								EXEC dbo.uspICCreateStockReservation @ItemsToReserve
									,@intWorkOrderId
									,8
							END
							ELSE
							BEGIN
								SELECT @intTransactionId = NULL

								SELECT @intTransactionId = MIN(intTransactionId)
								FROM @tblICStockReservation

								WHILE @intTransactionId IS NOT NULL
								BEGIN
									SELECT @intInventoryTransactionType = NULL

									SELECT @intInventoryTransactionType = intInventoryTransactionType
									FROM @tblICStockReservation
									WHERE intTransactionId = @intTransactionId

									DELETE
									FROM @ItemsToReserve1

									INSERT INTO @ItemsToReserve1 (
										intItemId
										,intItemLocationId
										,intItemUOMId
										,intLotId
										,intSubLocationId
										,intStorageLocationId
										,dblQty
										,intTransactionId
										,strTransactionId
										,intTransactionTypeId
										)
									SELECT intItemId = SR.intItemId
										,intItemLocationId = SR.intItemLocationId
										,intItemUOMId = SR.intItemUOMId
										,intLotId = SR.intLotId
										,intSubLocationId = SR.intSubLocationId
										,intStorageLocationId = SR.intStorageLocationId
										,dblQty = CASE 
											WHEN SR.dblQty + IsNULL(RR1.dblQty, 0) < 0
												THEN 0
											ELSE SR.dblQty + IsNULL(RR1.dblQty, 0)
											END
										,intTransactionId = SR.intTransactionId
										,strTransactionId = SR.strTransactionId
										,intTransactionTypeId = 8
									FROM @ItemsToReserve2 SR
									JOIN tblICLot L ON L.intLotId = SR.intLotId
									OUTER APPLY (
										SELECT TOP 1 RR.dblQty
										FROM @ItemsForPost RR
										JOIN tblICLot L2 ON L2.intLotId = RR.intLotId
										WHERE L2.strLotNumber = L.strLotNumber
										) RR1
									WHERE intTransactionId = @intTransactionId
										AND intTransactionTypeId = @intInventoryTransactionType

									EXEC dbo.uspICCreateStockReservation @ItemsToReserve1
										,@intTransactionId
										,@intInventoryTransactionType

									SELECT @intTransactionId = MIN(intTransactionId)
									FROM @tblICStockReservation
									WHERE intTransactionId > @intTransactionId
								END
							END
						END

						IF @intOrderCompleted = 1
						BEGIN
							UPDATE tblMFWorkOrder
							SET intStatusId = 13
								,dtmCompletedDate = GETDATE()
							WHERE intWorkOrderId = @intWorkOrderId

							UPDATE tblMFBlendRequirement
							SET intStatusId = 2
							WHERE strReferenceNo = @strOrderNo

							INSERT INTO @tblMFWorkOrderInputLot (
								intLotId
								,dblBalance
								,intConsumedLotId
								)
							SELECT intLotId
								,dblQuantity + IsNULL(dblConsumedQty, 0)
								,intConsumedLotId
							FROM dbo.tblMFWorkOrderInputLot
							WHERE intWorkOrderId = @intWorkOrderId
								AND dblQuantity + IsNULL(dblConsumedQty, 0) > 1

							SELECT @intRecordId = MIN(intRecordId)
							FROM @tblMFWorkOrderInputLot

							WHILE @intRecordId IS NOT NULL
							BEGIN
								SELECT @intLotId = NULL
									,@dblBalance = NULL
									,@intConsumedLotId = NULL

								SELECT @intLotId = intLotId
									,@dblBalance = dblBalance
									,@intConsumedLotId = intConsumedLotId
								FROM @tblMFWorkOrderInputLot
								WHERE intRecordId = @intRecordId

								DELETE
								FROM @StockReservation

								INSERT INTO @StockReservation (
									intStockReservationId
									,dblQty
									)
								SELECT intStockReservationId
									,dblQty
								FROM dbo.tblICStockReservation
								WHERE intLotId = @intLotId
									AND dblQty > 1

								INSERT INTO @StockReservation (
									intStockReservationId
									,dblQty
									)
								SELECT intStockReservationId
									,dblQty
								FROM dbo.tblICStockReservation
								WHERE intLotId = @intConsumedLotId
									AND dblQty > 1

								SELECT @intStockId = MIN(intStockId)
								FROM @StockReservation

								WHILE @intStockId IS NOT NULL
									AND @dblBalance > 0
								BEGIN
									SELECT @intStockReservationId = NULL
										,@dblQty = NULL

									SELECT @intStockReservationId = intStockReservationId
										,@dblQty = dblQty
									FROM @StockReservation
									WHERE intStockId = @intStockId

									IF @dblQty >= @dblBalance
									BEGIN
										SELECT @dblBalance = 0

										UPDATE dbo.tblICStockReservation
										SET dblQty = dblQty - @dblBalance
										WHERE intStockReservationId = @intStockReservationId
									END
									ELSE
									BEGIN
										SELECT @dblBalance = @dblBalance - @dblQty

										UPDATE dbo.tblICStockReservation
										SET dblQty = 0
										WHERE intStockReservationId = @intStockReservationId
									END

									SELECT @intStockId = MIN(intStockId)
									FROM @StockReservation
									WHERE intStockId > @intStockId
								END

								SELECT @intRecordId = MIN(intRecordId)
								FROM @tblMFWorkOrderInputLot
								WHERE intRecordId > @intRecordId
							END
								END


						DELETE
						FROM @ItemsForPost
					END
				END
			END

			MOVE_TO_ARCHIVE:

			--Move to Ack
			INSERT INTO tblIPInventoryAdjustmentArchive (
				intTrxSequenceNo
				,strCompanyLocation
				,intActionId
				,dtmCreatedDate
				,strCreatedBy
				,intTransactionTypeId
				,strStorageLocation
				,strItemNo
				,strMotherLotNo
				,strLotNo
				,strStorageUnit
				,dblQuantity
				,strQuantityUOM
				,strReasonCode
				,strNotes
				,strNewLocation
				,strNewStorageLocation
				,strNewStorageUnit
				,strOrderNo
				,intOrderCompleted
				,strTranferOrderStatus
				,strAdjustmentNo
				)
			SELECT intTrxSequenceNo
				,strCompanyLocation
				,intActionId
				,dtmCreatedDate
				,strCreatedBy
				,intTransactionTypeId
				,strStorageLocation
				,strItemNo
				,strMotherLotNo
				,strLotNo
				,strStorageUnit
				,dblQuantity
				,strQuantityUOM
				,strReasonCode
				,strNotes
				,strNewLocation
				,strNewStorageLocation
				,strNewStorageUnit
				,strOrderNo
				,intOrderCompleted
				,strTranferOrderStatus
				,@strAdjustmentNo
			FROM tblIPInventoryAdjustmentStage
			WHERE intInventoryAdjustmentStageId = @intInventoryAdjustmentStageId

			DELETE
			FROM tblIPInventoryAdjustmentStage
			WHERE intInventoryAdjustmentStageId = @intInventoryAdjustmentStageId

			COMMIT TRAN
		END TRY

		BEGIN CATCH
			IF XACT_STATE() != 0
				AND @@TRANCOUNT > 0
				ROLLBACK TRANSACTION

			SET @ErrMsg = NULL
			SET @ErrMsg = ERROR_MESSAGE()
			SET @strFinalErrMsg = @strFinalErrMsg + @ErrMsg

			--Move to Error
			INSERT INTO tblIPInventoryAdjustmentError (
				intTrxSequenceNo
				,strCompanyLocation
				,intActionId
				,dtmCreatedDate
				,strCreatedBy
				,intTransactionTypeId
				,strStorageLocation
				,strItemNo
				,strMotherLotNo
				,strLotNo
				,strStorageUnit
				,dblQuantity
				,strQuantityUOM
				,strReasonCode
				,strNotes
				,strNewLocation
				,strNewStorageLocation
				,strNewStorageUnit
				,strOrderNo
				,intOrderCompleted
				,strTranferOrderStatus
				,strErrorMessage
				)
			SELECT intTrxSequenceNo
				,strCompanyLocation
				,intActionId
				,dtmCreatedDate
				,strCreatedBy
				,intTransactionTypeId
				,strStorageLocation
				,strItemNo
				,strMotherLotNo
				,strLotNo
				,strStorageUnit
				,dblQuantity
				,strQuantityUOM
				,strReasonCode
				,strNotes
				,strNewLocation
				,strNewStorageLocation
				,strNewStorageUnit
				,strOrderNo
				,intOrderCompleted
				,strTranferOrderStatus
				,@ErrMsg AS strStatusText
			FROM tblIPInventoryAdjustmentStage
			WHERE intInventoryAdjustmentStageId = @intInventoryAdjustmentStageId

			DELETE
			FROM tblIPInventoryAdjustmentStage
			WHERE intInventoryAdjustmentStageId = @intInventoryAdjustmentStageId
		END CATCH

		SELECT @intInventoryAdjustmentStageId = MIN(intInventoryAdjustmentStageId)
		FROM @tblIPInventoryAdjustmentStage
		WHERE intInventoryAdjustmentStageId > @intInventoryAdjustmentStageId
	END

	UPDATE tblIPInventoryAdjustmentStage
	SET intStatusId = NULL
	WHERE intInventoryAdjustmentStageId IN (
			SELECT intInventoryAdjustmentStageId
			FROM @tblIPInventoryAdjustmentStage
			)
		AND intStatusId = - 1

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
