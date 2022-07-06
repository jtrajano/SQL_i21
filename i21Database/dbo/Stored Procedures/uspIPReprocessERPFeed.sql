CREATE PROCEDURE uspIPReprocessERPFeed @strType NVARCHAR(50) = ''
AS
BEGIN TRY
	DECLARE @FailedFeed TABLE (
		intRecordId INT IDENTITY(1, 1)
		,intStageReceiptId INT
		)
	DECLARE @dtmDate DATETIME
		,@intStageReceiptId INT
		,@intNewStageReceiptId INT

	SELECT @dtmDate = CONVERT(DATETIME, CONVERT(CHAR, GETDATE(), 101))

	IF @strType = 'Stock'
	BEGIN
		INSERT INTO tblIPLotStage (
			intTrxSequenceNo
			,strCompanyLocation
			,dtmCreatedDate
			,strCreatedBy
			,strSubLocationName
			,strItemNo
			,strLotNumber
			,strStorageLocationName
			,dblNetWeight
			,strNetWeightUOM
			)
		SELECT intTrxSequenceNo
			,strCompanyLocation
			,dtmCreatedDate
			,strCreatedBy
			,strSubLocationName
			,strItemNo
			,strLotNumber
			,strStorageLocationName
			,dblNetWeight
			,strNetWeightUOM
		FROM tblIPLotError
		WHERE dtmTransactionDate > @dtmDate
			AND strErrorMessage LIKE '%deadlock%'

		DELETE
		FROM tblIPLotError
		WHERE dtmTransactionDate > @dtmDate
			AND strErrorMessage LIKE '%deadlock%'

		IF EXISTS (
				SELECT TOP 1 1
				FROM tblIPLotStage
				)
		BEGIN
			EXEC uspIPProcessERPStockFeed
		END
	END

	IF @strType = 'Receipt'
	BEGIN
		DELETE
		FROM @FailedFeed

		INSERT INTO @FailedFeed (intStageReceiptId)
		SELECT intStageReceiptId
		FROM tblIPInvReceiptError
		WHERE dtmTransactionDate > @dtmDate
			AND strErrorMessage LIKE '%deadlock%'

		SELECT @intStageReceiptId = MIN(intStageReceiptId)
		FROM @FailedFeed

		WHILE @intStageReceiptId IS NOT NULL
		BEGIN
			SELECT @intNewStageReceiptId = NULL

			INSERT INTO tblIPInvReceiptStage (
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
			FROM tblIPInvReceiptError
			WHERE intStageReceiptId = @intStageReceiptId

			SELECT @intNewStageReceiptId = SCOPE_IDENTITY()

			INSERT INTO tblIPInvReceiptItemStage (
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
			FROM tblIPInvReceiptItemError
			WHERE intStageReceiptId = @intStageReceiptId

			INSERT INTO tblIPInvReceiptItemLotStage (
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
			FROM tblIPInvReceiptItemLotError
			WHERE intStageReceiptId = @intStageReceiptId

			DELETE
			FROM tblIPInvReceiptError
			WHERE intStageReceiptId = @intStageReceiptId

			SELECT @intStageReceiptId = MIN(intStageReceiptId)
			FROM @FailedFeed
			WHERE intStageReceiptId > @intStageReceiptId
		END

		IF EXISTS (
				SELECT TOP 1 1
				FROM tblIPInvReceiptStage
				)
		BEGIN
			EXEC uspIPProcessERPGoodsReceipt
		END
	END
END TRY

BEGIN CATCH
END CATCH
