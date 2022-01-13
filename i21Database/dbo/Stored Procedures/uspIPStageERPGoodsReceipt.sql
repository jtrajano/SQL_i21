CREATE PROCEDURE uspIPStageERPGoodsReceipt @strInfo1 NVARCHAR(MAX) = '' OUTPUT
	,@strInfo2 NVARCHAR(MAX) = '' OUTPUT
	,@intNoOfRowsAffected INT = 0 OUTPUT
AS
BEGIN TRY
	SET QUOTED_IDENTIFIER OFF
	SET ANSI_NULLS ON
	SET NOCOUNT ON
	SET XACT_ABORT ON
	SET ANSI_WARNINGS OFF

	DECLARE @idoc INT
	DECLARE @ErrMsg NVARCHAR(MAX) = ''
		,@intRowNo INT
		,@strXml NVARCHAR(MAX)
		,@strFinalErrMsg NVARCHAR(MAX) = ''
	DECLARE @tblIPInvReceipt TABLE (strReceiptNumber NVARCHAR(50))
	DECLARE @tblIPIDOCXMLStage TABLE (intIDOCXMLStageId INT)

	INSERT INTO @tblIPIDOCXMLStage (intIDOCXMLStageId)
	SELECT intIDOCXMLStageId
	FROM tblIPIDOCXMLStage
	WHERE strType = 'Transfer Goods Receipt'
		AND intStatusId IS NULL

	SELECT @intRowNo = MIN(intIDOCXMLStageId)
	FROM @tblIPIDOCXMLStage

	IF @intRowNo IS NULL
	BEGIN
		RETURN
	END

	UPDATE S
	SET S.intStatusId = - 1
	FROM tblIPIDOCXMLStage S
	JOIN @tblIPIDOCXMLStage TS ON TS.intIDOCXMLStageId = S.intIDOCXMLStageId

	WHILE (ISNULL(@intRowNo, 0) > 0)
	BEGIN
		BEGIN TRY
			BEGIN TRANSACTION

			SELECT @strXml = NULL
				,@idoc = NULL
				,@intNoOfRowsAffected = 1

			SELECT @strXml = strXml
			FROM tblIPIDOCXMLStage
			WHERE intIDOCXMLStageId = @intRowNo

			SET @strXml = REPLACE(@strXml, 'utf-8' COLLATE Latin1_General_CI_AS, 'utf-16' COLLATE Latin1_General_CI_AS)

			EXEC sp_xml_preparedocument @idoc OUTPUT
				,@strXml

			DELETE
			FROM @tblIPInvReceipt

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
			OUTPUT INSERTED.strERPReceiptNo
			INTO @tblIPInvReceipt
			SELECT TrxSequenceNo
				,CompanyLocation
				,ActionId
				,CreatedDate
				,CreatedByUser
				,VendorAccountNo
				,VendorRefNo
				,ERPReceiptNo
				,ReceiptDate
				,BOLNo
				,WarehouseRefNo
				,TransferOrderNo
				,ERPTransferOrderNo
			FROM OPENXML(@idoc, 'root/data/header', 2) WITH (
					TrxSequenceNo BIGINT
					,CompanyLocation NVARCHAR(6)
					,ActionId INT
					,CreatedDate DATETIME
					,CreatedByUser NVARCHAR(50)
					,VendorAccountNo NVARCHAR(100)
					,VendorRefNo NVARCHAR(50)
					,ERPReceiptNo NVARCHAR(50)
					,ReceiptDate DATETIME
					,BOLNo NVARCHAR(100)
					,WarehouseRefNo NVARCHAR(50)
					,TransferOrderNo NVARCHAR(50)
					,ERPTransferOrderNo NVARCHAR(50)
					)

			SELECT @strInfo1 = @strInfo1 + ISNULL(strReceiptNumber, '') + ','
			FROM @tblIPInvReceipt

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
			SELECT (
					SELECT TOP 1 intStageReceiptId
					FROM tblIPInvReceiptStage
					WHERE strERPReceiptNo = x.ERPReceiptNo
					)
				,TrxSequenceNo
				,parentId
				,ItemNo
				,ReceiptQty
				,ReceiptQtyUOM
				,GrossWeight
				,TareWeight
				,NetWeight
				,WeightUOM
				,Cost
				,CostUOM
				,Currency
				,StorageLocation
				,StorageUnit
				,ContainerNo
			FROM OPENXML(@idoc, 'root/data/header/line', 2) WITH (
					ERPReceiptNo NVARCHAR(50) COLLATE Latin1_General_CI_AS '../ERPReceiptNo'
					,TrxSequenceNo BIGINT
					,parentId BIGINT '@parentId'
					,ItemNo NVARCHAR(50)
					,ReceiptQty NUMERIC(18, 6)
					,ReceiptQtyUOM NVARCHAR(50)
					,GrossWeight NUMERIC(18, 6)
					,TareWeight NUMERIC(18, 6)
					,NetWeight NUMERIC(18, 6)
					,WeightUOM NVARCHAR(50)
					,Cost NUMERIC(18, 6)
					,CostUOM NVARCHAR(50)
					,Currency NVARCHAR(40)
					,StorageLocation NVARCHAR(50)
					,StorageUnit NVARCHAR(50)
					,ContainerNo NVARCHAR(100)
					) x

			UPDATE RI
			SET RI.intStageReceiptId = R.intStageReceiptId
			FROM tblIPInvReceiptStage R
			JOIN tblIPInvReceiptItemStage RI ON RI.intParentTrxSequenceNo = R.intTrxSequenceNo

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
				)
			SELECT (
					SELECT TOP 1 intStageReceiptId
					FROM tblIPInvReceiptStage
					WHERE strERPReceiptNo = x.ERPReceiptNo
					)
				,TrxSequenceNo
				,parentId
				,MotherLotNo
				,LotNo
				,Quantity
				,QuantityUOM
				,GrossWeight
				,TareWeight
				,NetWeight
				,WeightUOM
			FROM OPENXML(@idoc, 'root/data/header/line/detail', 2) WITH (
					ERPReceiptNo NVARCHAR(50) COLLATE Latin1_General_CI_AS '../../ERPReceiptNo'
					,TrxSequenceNo BIGINT
					,parentId BIGINT '@parentId'
					,MotherLotNo NVARCHAR(50)
					,LotNo NVARCHAR(50)
					,Quantity NUMERIC(18, 6)
					,QuantityUOM NVARCHAR(50)
					,GrossWeight NUMERIC(18, 6)
					,TareWeight NUMERIC(18, 6)
					,NetWeight NUMERIC(18, 6)
					,WeightUOM NVARCHAR(50)
					) x

			UPDATE RIL
			SET RIL.intStageReceiptId = R.intStageReceiptId
			FROM tblIPInvReceiptStage R
			JOIN tblIPInvReceiptItemStage RI ON RI.intParentTrxSequenceNo = R.intTrxSequenceNo
			JOIN tblIPInvReceiptItemLotStage RIL ON RIL.intParentTrxSequenceNo = RI.intTrxSequenceNo

			--Move to Archive
			INSERT INTO tblIPIDOCXMLArchive (
				strXml
				,strType
				,dtmCreatedDate
				)
			SELECT strXml
				,strType
				,dtmCreatedDate
			FROM tblIPIDOCXMLStage
			WHERE intIDOCXMLStageId = @intRowNo

			DELETE
			FROM tblIPIDOCXMLStage
			WHERE intIDOCXMLStageId = @intRowNo

			COMMIT TRANSACTION
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
				)
			SELECT TrxSequenceNo
				,CompanyLocation
				,CreatedDate
				,CreatedByUser
				,13
				,0
				,@ErrMsg
			FROM OPENXML(@idoc, 'root/data/header', 2) WITH (
					TrxSequenceNo BIGINT
					,CompanyLocation NVARCHAR(6)
					,CreatedDate DATETIME
					,CreatedByUser NVARCHAR(50)
					)

			--Move to Error
			INSERT INTO tblIPIDOCXMLError (
				strXml
				,strType
				,strMsg
				,dtmCreatedDate
				)
			SELECT strXml
				,strType
				,@ErrMsg
				,dtmCreatedDate
			FROM tblIPIDOCXMLStage
			WHERE intIDOCXMLStageId = @intRowNo

			DELETE
			FROM tblIPIDOCXMLStage
			WHERE intIDOCXMLStageId = @intRowNo
		END CATCH

		SELECT @intRowNo = MIN(intIDOCXMLStageId)
		FROM @tblIPIDOCXMLStage
		WHERE intIDOCXMLStageId > @intRowNo
	END

	UPDATE S
	SET S.intStatusId = NULL
	FROM tblIPIDOCXMLStage S
	JOIN @tblIPIDOCXMLStage TS ON TS.intIDOCXMLStageId = S.intIDOCXMLStageId
	WHERE S.intStatusId = - 1

	IF (ISNULL(@strInfo1, '')) <> ''
		SELECT @strInfo1 = LEFT(@strInfo1, LEN(@strInfo1) - 1)

	IF @strFinalErrMsg <> ''
		RAISERROR (
				@strFinalErrMsg
				,16
				,1
				)
END TRY

BEGIN CATCH
	SET @ErrMsg = ERROR_MESSAGE()

	IF @idoc <> 0
		EXEC sp_xml_removedocument @idoc

	RAISERROR (
			@ErrMsg
			,16
			,1
			,'WITH NOWAIT'
			)
END CATCH
