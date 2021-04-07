CREATE PROCEDURE dbo.uspIPGenerateERPGoodsReceipt (
	@strCompanyLocation NVARCHAR(6) = NULL
	,@ysnUpdateFeedStatus BIT = 1
	)
AS
BEGIN TRY
	SET NOCOUNT ON

	DECLARE @ErrMsg NVARCHAR(MAX)
		,@strRowState NVARCHAR(50)
		,@strUserName NVARCHAR(50)
		,@strError NVARCHAR(MAX) = ''
		,@strXML NVARCHAR(MAX) = ''
		,@strItemXML NVARCHAR(MAX) = ''
		,@strContainerXML NVARCHAR(MAX) = ''
		,@strFinalXML NVARCHAR(MAX) = ''
	DECLARE @strQuantityUOM NVARCHAR(50)
		,@strDefaultCurrency NVARCHAR(40)
		,@intCurrencyId INT
		,@intUnitMeasureId INT
		,@intItemId INT
		,@intItemUOMId INT
	DECLARE @intInventoryReceiptId INT
		,@intActionId INT
		,@strVendorAccountNum NVARCHAR(50)
		,@strVendorRefNo NVARCHAR(50)
		,@strReceiptNumber NVARCHAR(50)
		,@dtmReceiptDate DATETIME
		,@strBillOfLading NVARCHAR(100)
		,@strWarehouseRefNo NVARCHAR(50)
		,@strTransferNo NVARCHAR(50)
		,@strERPTransferOrderNo NVARCHAR(50)
		,@strCurrency NVARCHAR(40)
	DECLARE @intInventoryReceiptItemId INT
		,@strContractNumber NVARCHAR(50)
		,@strSequenceNo NVARCHAR(3)
		,@strItemNo NVARCHAR(50)
		,@dblReceiptQty NUMERIC(18, 6)
		,@strReceiptQtyUOM NVARCHAR(50)
		,@dblGross NUMERIC(18, 6)
		,@dblNet NUMERIC(18, 6)
		,@dblTare NUMERIC(18, 6)
		,@dblUnitCost NUMERIC(18, 6)
		,@strSubLocationName NVARCHAR(50)
		,@strStorageLocation NVARCHAR(50)
		,@strContainerNumber NVARCHAR(100)
		,@strERPPONumber NVARCHAR(100)
		,@strERPItemNumber NVARCHAR(100)
	DECLARE @tblICInventoryReceipt TABLE (intInventoryReceiptId INT)
	DECLARE @tblICInventoryReceiptItem TABLE (intInventoryReceiptItemId INT)
	DECLARE @tblICInventoryReceiptItemLot TABLE (intInventoryReceiptItemLotId INT)

	DELETE
	FROM @tblICInventoryReceipt

	INSERT INTO @tblICInventoryReceipt (intInventoryReceiptId)
	SELECT DISTINCT R.intInventoryReceiptId
	FROM tblICInventoryReceiptItemLot RIL
	JOIN tblICInventoryReceiptItem RI ON RI.intInventoryReceiptItemId = RIL.intInventoryReceiptItemId
	JOIN tblICInventoryReceipt R ON R.intInventoryReceiptId = RI.intInventoryReceiptId
	JOIN tblCTContractDetail CD ON CD.intContractDetailId = RI.intContractDetailId
	JOIN tblSMCompanyLocation CL ON CL.intCompanyLocationId = CD.intCompanyLocationId
	AND CL.strLotOrigin = @strCompanyLocation
	WHERE R.strReceiptType = 'Purchase Contract'
		AND R.ysnPosted = 1
		AND RI.ysnExported IS NULL
		AND ISNULL(CD.strERPPONumber, '') <> ''

	DECLARE @tblOutput AS TABLE (
		intRowNo INT IDENTITY(1, 1)
		,intInventoryReceiptId INT
		,strRowState NVARCHAR(50)
		,strXML NVARCHAR(MAX)
		,strReceiptNumber NVARCHAR(50)
		,strTransferNo NVARCHAR(50)
		)

	IF NOT EXISTS (
			SELECT 1
			FROM @tblICInventoryReceipt
			)
	BEGIN
		RETURN
	END

	SELECT @intInventoryReceiptId = MIN(intInventoryReceiptId)
	FROM @tblICInventoryReceipt

	WHILE @intInventoryReceiptId IS NOT NULL
	BEGIN
		SELECT @strRowState = NULL
			,@strUserName = NULL
			,@strError = ''
			,@strXML = ''

		SELECT @intActionId = NULL
			,@strVendorAccountNum = NULL
			,@strVendorRefNo = NULL
			,@strReceiptNumber = NULL
			,@dtmReceiptDate = NULL
			,@strBillOfLading = NULL
			,@strWarehouseRefNo = NULL
			,@strTransferNo = NULL
			,@strERPTransferOrderNo = NULL
			,@strCurrency = NULL

		SELECT @intInventoryReceiptItemId = NULL

		SELECT @intActionId = (
				CASE 
					WHEN R.strReceiptType = 'Purchase Contract'
						THEN 1
					ELSE 2
					END
				)
			,@strUserName = US.strUserName
			,@strVendorAccountNum = V.strVendorAccountNum
			,@strVendorRefNo = R.strVendorRefNo
			,@strReceiptNumber = R.strReceiptNumber
			,@dtmReceiptDate = R.dtmReceiptDate
			,@strBillOfLading = R.strBillOfLading
			,@strWarehouseRefNo = R.strWarehouseRefNo
			,@strTransferNo = ''
			,@strERPTransferOrderNo = ''
			,@strCurrency = C.strCurrency
		FROM dbo.tblICInventoryReceipt R
		JOIN dbo.tblSMUserSecurity US ON US.intEntityId = ISNULL(R.intModifiedByUserId, R.intCreatedByUserId)
		JOIN dbo.tblAPVendor V ON V.intEntityId = R.intEntityVendorId
		LEFT JOIN tblSMCurrency C ON C.intCurrencyID = R.intCurrencyId
		WHERE intInventoryReceiptId = @intInventoryReceiptId

		IF NOT EXISTS (
				SELECT 1
				FROM tblIPInvReceiptFeed
				WHERE intInventoryReceiptId = @intInventoryReceiptId
				)
			INSERT INTO tblIPInvReceiptFeed (
				strCompanyLocation
				,intInventoryReceiptId
				,strReceiptNumber
				,strTransferNo
				,strERPTransferOrderNo
				,strCreatedBy
				,strTransactionType
				,intStatusId
				,strMessage
				,strFeedStatus
				)
			SELECT @strCompanyLocation
				,@intInventoryReceiptId
				,@strReceiptNumber
				,@strTransferNo
				,@strERPTransferOrderNo
				,@strUserName
				,LTRIM(@intActionId)
				,NULL
				,NULL
				,NULL

		IF @intActionId = 1
		BEGIN
			IF ISNULL(@strVendorAccountNum, '') = ''
			BEGIN
				SELECT @strError = @strError + 'Vendor Account Number cannot be blank. '
			END
		END

		IF @strError <> ''
		BEGIN
			UPDATE tblIPInvReceiptFeed
			SET strMessage = @strError
				,intStatusId = 1
			WHERE intInventoryReceiptId = @intInventoryReceiptId

			GOTO NextRec
		END

		DELETE
		FROM @tblICInventoryReceiptItemLot

		DELETE
		FROM @tblICInventoryReceiptItem

		INSERT INTO @tblICInventoryReceiptItem (intInventoryReceiptItemId)
		SELECT RI.intInventoryReceiptItemId
		FROM tblICInventoryReceiptItem RI
		WHERE RI.intInventoryReceiptId = @intInventoryReceiptId

		SELECT @intInventoryReceiptItemId = MIN(intInventoryReceiptItemId)
		FROM @tblICInventoryReceiptItem

		WHILE @intInventoryReceiptItemId IS NOT NULL
		BEGIN
			SELECT @strQuantityUOM = NULL
				,@strDefaultCurrency = NULL
				,@intCurrencyId = NULL
				,@intUnitMeasureId = NULL
				,@intItemId = NULL
				,@intItemUOMId = NULL

			SELECT @strContractNumber = NULL
				,@strSequenceNo = NULL
				,@strItemNo = NULL
				,@dblReceiptQty = NULL
				,@strReceiptQtyUOM = NULL
				,@dblGross = NULL
				,@dblNet = NULL
				,@dblTare = NULL
				,@dblUnitCost = NULL
				,@strSubLocationName = NULL
				,@strStorageLocation = NULL
				,@strContainerNumber = NULL
				,@strERPPONumber = NULL
				,@strERPItemNumber = NULL

			SELECT @intItemId = RI.intItemId
			FROM tblICInventoryReceiptItem RI
			WHERE RI.intInventoryReceiptItemId = @intInventoryReceiptItemId

			SELECT @strQuantityUOM = strQuantityUOM
				,@strDefaultCurrency = strDefaultCurrency
			FROM tblIPCompanyPreference

			SELECT @intCurrencyId = intCurrencyID
			FROM tblSMCurrency
			WHERE strCurrency = @strDefaultCurrency

			IF @intCurrencyId IS NULL
			BEGIN
				SELECT TOP 1 @intCurrencyId = intCurrencyID
					,@strDefaultCurrency = strCurrency
				FROM tblSMCurrency
				WHERE strCurrency LIKE '%USD%'
			END

			SELECT @intUnitMeasureId = IUOM.intUnitMeasureId
				,@intItemUOMId = IUOM.intItemUOMId
			FROM tblICUnitMeasure UOM
			JOIN tblICItemUOM IUOM ON IUOM.intUnitMeasureId = UOM.intUnitMeasureId
				AND IUOM.intItemId = @intItemId
				AND UOM.strUnitMeasure = @strQuantityUOM

			IF @intUnitMeasureId IS NULL
			BEGIN
				SELECT TOP 1 @intItemUOMId = IUOM.intItemUOMId
					,@intUnitMeasureId = IUOM.intUnitMeasureId
					,@strQuantityUOM = UOM.strUnitMeasure
				FROM dbo.tblICItemUOM IUOM
				JOIN dbo.tblICUnitMeasure UOM ON UOM.intUnitMeasureId = IUOM.intUnitMeasureId
					AND IUOM.intItemId = @intItemId
					AND IUOM.ysnStockUnit = 1
			END

			SELECT @strContractNumber = CH.strContractNumber
				,@strSequenceNo = LTRIM(CD.intContractSeq)
				,@strItemNo = I.strItemNo
				,@dblReceiptQty = RI.dblOrderQty
				,@strReceiptQtyUOM = UOM.strUnitMeasure
				,@dblGross = CONVERT(NUMERIC(18, 6), ISNULL(dbo.fnCTConvertQtyToTargetItemUOM(RI.intWeightUOMId, @intItemUOMId, RI.dblGross), 0))
				,@dblNet = CONVERT(NUMERIC(18, 6), ISNULL(dbo.fnCTConvertQtyToTargetItemUOM(RI.intWeightUOMId, @intItemUOMId, RI.dblNet), 0))
				,@dblUnitCost = CONVERT(NUMERIC(18, 6), ISNULL(dbo.fnCTConvertQtyToTargetItemUOM(RI.intCostUOMId, @intItemUOMId, RI.dblUnitCost), 0))
				,@strSubLocationName = ISNULL(CSL.strSubLocationName, '')
				,@strStorageLocation = ISNULL(SL.strName, '')
				,@strContainerNumber = ISNULL(LC.strContainerNumber, '')
				,@strERPPONumber = ISNULL(CD.strERPPONumber, '')
				,@strERPItemNumber = ISNULL(CD.strERPItemNumber, '')
			FROM tblICInventoryReceiptItem RI
			JOIN tblCTContractDetail CD ON CD.intContractDetailId = RI.intContractDetailId
				AND RI.intInventoryReceiptItemId = @intInventoryReceiptItemId
			JOIN tblCTContractHeader CH ON CH.intContractHeaderId = CD.intContractHeaderId
			JOIN tblICItem I ON I.intItemId = RI.intItemId
			JOIN tblICItemUOM IUOM ON IUOM.intItemUOMId = RI.intUnitMeasureId
			JOIN tblICUnitMeasure UOM ON UOM.intUnitMeasureId = IUOM.intUnitMeasureId
			LEFT JOIN tblSMCompanyLocationSubLocation CSL ON CSL.intCompanyLocationSubLocationId = RI.intSubLocationId
			LEFT JOIN tblICStorageLocation SL ON SL.intStorageLocationId = RI.intStorageLocationId
			LEFT JOIN tblLGLoadContainer LC ON LC.intLoadContainerId = RI.intContainerId
			WHERE RI.intInventoryReceiptItemId = @intInventoryReceiptItemId

			SELECT @dblTare = @dblGross - @dblNet

			IF @strSubLocationName = ''
			BEGIN
				SELECT @strError = @strError + 'Storage Location cannot be blank. '
			END

			IF @strStorageLocation = ''
			BEGIN
				SELECT @strError = @strError + 'Storage Unit cannot be blank. '
			END

			IF @intActionId = 1
			BEGIN
				IF ISNULL(@strContractNumber, '') = ''
				BEGIN
					SELECT @strError = @strError + 'Contract No. cannot be blank. '
				END

				IF @strERPPONumber = ''
				BEGIN
					SELECT @strError = @strError + 'ERP PO Number cannot be blank. '
				END

				IF @strERPItemNumber = ''
				BEGIN
					SELECT @strError = @strError + 'ERP PO Line No. cannot be blank. '
				END
			END

			IF @strError <> ''
			BEGIN
				UPDATE tblIPInvReceiptFeed
				SET strMessage = @strError
					,intStatusId = 1
				WHERE intInventoryReceiptId = @intInventoryReceiptId

				GOTO NextRec
			END

			SELECT @strContainerXML = ''

			SELECT RIL.strParentLotNumber
				,RIL.strLotNumber
				,RIL.dblQuantity
				,UOM.strUnitMeasure
				,CONVERT(NUMERIC(18, 6), ISNULL(dbo.fnCTConvertQtyToTargetItemUOM(RI.intWeightUOMId, @intItemUOMId, RIL.dblGrossWeight), 0))
				,CONVERT(NUMERIC(18, 6), ISNULL(dbo.fnCTConvertQtyToTargetItemUOM(RI.intWeightUOMId, @intItemUOMId, RIL.dblTareWeight), 0))
				,(CONVERT(NUMERIC(18, 6), ISNULL(dbo.fnCTConvertQtyToTargetItemUOM(RI.intWeightUOMId, @intItemUOMId, RIL.dblGrossWeight), 0)) - CONVERT(NUMERIC(18, 6), ISNULL(dbo.fnCTConvertQtyToTargetItemUOM(RI.intWeightUOMId, @intItemUOMId, RIL.dblTareWeight), 0)))
				,@strQuantityUOM
				,ISNULL(RIL.strVendorLotId, '')
				,RIL.dtmExpiryDate
				,SL.strName
				,LS.strSecondaryStatus
				,ISNULL(RIL.strCondition, '')
				,ISNULL(RIL.strMarkings, '')
				,ISNULL(O.strCountry, '')
				,ISNULL(RIL.strLotAlias, '')
				,ISNULL(RIL.strGarden, '')
			FROM tblICInventoryReceiptItemLot RIL
			JOIN tblICInventoryReceiptItem RI ON RI.intInventoryReceiptItemId = RIL.intInventoryReceiptItemId
				AND RIL.intInventoryReceiptItemId = @intInventoryReceiptItemId
			JOIN tblICItemUOM IUOM ON IUOM.intItemUOMId = RIL.intItemUnitMeasureId
			JOIN tblICUnitMeasure UOM ON UOM.intUnitMeasureId = IUOM.intUnitMeasureId
			JOIN tblICStorageLocation SL ON SL.intStorageLocationId = RIL.intStorageLocationId
			JOIN tblICLot L ON L.intLotId = RIL.intLotId
			JOIN tblICLotStatus LS ON LS.intLotStatusId = L.intLotStatusId
			LEFT JOIN tblSMCountry O ON O.intCountryID = RIL.intOriginId
			WHERE RIL.intInventoryReceiptItemId = @intInventoryReceiptItemId

			SELECT @intInventoryReceiptItemId = MIN(intInventoryReceiptItemId)
			FROM @tblICInventoryReceiptItem
			WHERE intInventoryReceiptItemId > @intInventoryReceiptItemId
		END

		IF @ysnUpdateFeedStatus = 1
		BEGIN
			UPDATE tblICInventoryReceiptItem
			SET ysnExported = 0
			WHERE intInventoryReceiptId = @intInventoryReceiptId

			UPDATE tblIPInvReceiptFeed
			SET strMessage = NULL
				,intStatusId = 2
			WHERE intInventoryReceiptId = @intInventoryReceiptId
		END

		NextRec:

		SELECT @intInventoryReceiptId = MIN(intInventoryReceiptId)
		FROM @tblICInventoryReceipt
		WHERE intInventoryReceiptId > @intInventoryReceiptId
	END

	IF @strFinalXML <> ''
	BEGIN
		SELECT @strFinalXML = '<root><data>' + @strFinalXML + '</data></root>'

		DELETE
		FROM @tblOutput

		INSERT INTO @tblOutput (
			intInventoryReceiptId
			,strRowState
			,strXML
			,strReceiptNumber
			,strTransferNo
			)
		VALUES (
			@intInventoryReceiptId
			,'CREATE'
			,@strFinalXML
			,ISNULL(@strReceiptNumber, '')
			,ISNULL(@strTransferNo, '')
			)
	END

	SELECT IsNULL(intInventoryReceiptId, '0') AS id
		,IsNULL(strXML, '') AS strXml
		,IsNULL(strReceiptNumber, '') AS strInfo1
		,IsNULL(strTransferNo, '') AS strInfo2
		,'' AS strOnFailureCallbackSql
	FROM @tblOutput
	ORDER BY intRowNo
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
