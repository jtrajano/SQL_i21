CREATE PROCEDURE uspIPStageERPGoodsReceipt_EK @strInfo1 NVARCHAR(MAX) = '' OUTPUT
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
		,@dtmCurrentDate DATETIME

	DECLARE @tblIPInvReceipt TABLE (strReceiptNumber NVARCHAR(50))
	DECLARE @tblIPIDOCXMLStage TABLE (intIDOCXMLStageId INT)

	INSERT INTO @tblIPIDOCXMLStage (intIDOCXMLStageId)
	SELECT intIDOCXMLStageId
	FROM tblIPIDOCXMLStage
	WHERE strType = 'Goods Receipt'
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

	SELECT @dtmCurrentDate = GETDATE()

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
				,dtmCreated
				,strERPReceiptNo
				,dtmReceiptDate
				,strVendorAccountNo
				,strBLNumber
				,strLocationName
				,strWarehouseRefNo
				,strOrderType
				)
			OUTPUT INSERTED.strERPReceiptNo
			INTO @tblIPInvReceipt
			SELECT DocNo
				,@dtmCurrentDate
				,ReceiptNo
				,ReceiptDate
				,VendorAccountNo
				,BOLNo
				,[Location]
				,WarehouseRefNo
				,OrderType
			FROM OPENXML(@idoc, 'root/Header', 2) WITH (
					DocNo BIGINT '../DocNo'
					,ReceiptNo NVARCHAR(50) Collate Latin1_General_CI_AS
					,ReceiptDate DATETIME
					,VendorAccountNo NVARCHAR(100)
					,BOLNo NVARCHAR(50)
					,[Location] NVARCHAR(50)
					,WarehouseRefNo NVARCHAR(50)
					,OrderType NVARCHAR(50)
					) t
			WHERE NOT EXISTS (
					SELECT 1
					FROM tblIPInvReceiptStage S
					WHERE S.strERPReceiptNo = t.ReceiptNo
				)

			SELECT @strInfo1 = @strInfo1 + ISNULL(strReceiptNumber, '') + ','
			FROM @tblIPInvReceipt

			INSERT INTO tblIPInvReceiptItemStage (
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
			SELECT (
					SELECT TOP 1 intStageReceiptId
					FROM tblIPInvReceiptStage
					WHERE strERPReceiptNo = x.ReceiptNo
					)
				,DocNo
				,PONumber
				,POLineItemNo
				,ItemNo
				,StorageLocation
				,StorageUnit
				,Quantity
				,QuantityUOM
				,GrossWeight
				,TareWeight
				,NetWeight
				,NetWeightUOM
				,Cost
				,CostUOM
				,CostCurrency
				,ContainerNo
			FROM OPENXML(@idoc, 'root/Header/Line', 2) WITH (
					ReceiptNo NVARCHAR(50) COLLATE Latin1_General_CI_AS '../ReceiptNo'
					,DocNo BIGINT '../../DocNo'
					,PONumber NVARCHAR(50)
					,POLineItemNo NVARCHAR(50)
					,ItemNo NVARCHAR(50)
					,StorageLocation NVARCHAR(50)
					,StorageUnit NVARCHAR(50)
					,Quantity NUMERIC(18, 6)
					,QuantityUOM NVARCHAR(50)
					,GrossWeight NUMERIC(18, 6)
					,TareWeight NUMERIC(18, 6)
					,NetWeight NUMERIC(18, 6)
					,NetWeightUOM NVARCHAR(50)
					,Cost NUMERIC(18, 6)
					,CostUOM NVARCHAR(50)
					,CostCurrency NVARCHAR(40)
					,ContainerNo NVARCHAR(50)
					) x

			INSERT INTO tblIPInvReceiptItemLotStage (
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
				)
			SELECT (
					SELECT TOP 1 intStageReceiptId
					FROM tblIPInvReceiptStage
					WHERE strERPReceiptNo = x.ReceiptNo
					)
				,DocNo
				,BatchId
				,Quantity
				,QuantityUOM
				,GrossWeight
				,TareWeight
				,NetWeight
				,WeightUOM
				,StorageUnit
				,Marks
				,ManufacturedDate
				,ExpiryDate
				,PONumber
				,POLineItemNo
			FROM OPENXML(@idoc, 'root/Header/Line/Detail', 2) WITH (
					ReceiptNo NVARCHAR(50) COLLATE Latin1_General_CI_AS '../../ReceiptNo'
					,DocNo BIGINT '../../../DocNo'
					,BatchId NVARCHAR(50)
					,Quantity NUMERIC(18, 6)
					,QuantityUOM NVARCHAR(50)
					,GrossWeight NUMERIC(18, 6)
					,TareWeight NUMERIC(18, 6)
					,NetWeight NUMERIC(18, 6)
					,WeightUOM NVARCHAR(50)
					,StorageUnit NVARCHAR(50)
					,Marks NVARCHAR(50)
					,ManufacturedDate DATETIME
					,ExpiryDate DATETIME
					,PONumber NVARCHAR(50) '../PONumber'
					,POLineItemNo NVARCHAR(50) '../POLineItemNo'
					) x

			UPDATE RILS
			SET RILS.intStageReceiptItemId = RIS.intStageReceiptItemId
			FROM tblIPInvReceiptItemLotStage RILS
			JOIN tblIPInvReceiptItemStage RIS ON RIS.intStageReceiptId = RILS.intStageReceiptId
				AND RILS.strERPPONumber = RIS.strERPPONumber
				AND RILS.strERPItemNumber = RIS.strERPItemNumber

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
