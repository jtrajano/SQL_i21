CREATE PROCEDURE dbo.uspIPGenerateERPTransferOrder (
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
		,@strFinalXML NVARCHAR(MAX) = ''
		,@strXML NVARCHAR(MAX) = ''
		,@strItemXML NVARCHAR(MAX) = ''
		,@strDetailXML NVARCHAR(MAX) = ''
	DECLARE @strQuantityUOM NVARCHAR(50)
		,@strDefaultCurrency NVARCHAR(40)
		,@intCurrencyId INT
		,@intUnitMeasureId INT
		,@intItemId INT
		,@intItemUOMId INT
	DECLARE @intInventoryTransferId INT
		,@intActionId INT
		,@strTransferNo NVARCHAR(50)
		,@dtmTransferDate DATETIME
		,@strShipVia NVARCHAR(50)
		,@strPaymentMethod NVARCHAR(50)
		,@strBolNumber NVARCHAR(50)
		,@dtmBolDate DATETIME
		,@dtmBolReceivedDate DATETIME
		,@strBroker NVARCHAR(50)
		,@strTrailerId NVARCHAR(100)
		,@strFromLocation NVARCHAR(50)
		,@strToLocation NVARCHAR(50)
	DECLARE @intInventoryTransferDetailId INT
		,@strItemNo NVARCHAR(50)
		,@strFromStorageLocation NVARCHAR(50)
		,@strFromStorageUnit NVARCHAR(50)
		,@strParentLotNumber NVARCHAR(50)
		,@strLotNumber NVARCHAR(50)
		,@dblQuantity NUMERIC(18, 6)
		,@strQtyUOM NVARCHAR(50)
		,@strToStorageLocation NVARCHAR(50)
		,@strToStorageUnit NVARCHAR(50)
		,@dtmDeliveryDate DATETIME
		,@strContainerNumber NVARCHAR(100)
		,@strMarks NVARCHAR(400)
		,@dblTransferPrice NUMERIC(18, 6)
		,@strCurrency NVARCHAR(40)
		,@strComment NVARCHAR(1000)
		,@dblGross NUMERIC(18, 6)
		,@dblTare NUMERIC(18, 6)
		,@dblNet NUMERIC(18, 6)
	DECLARE @tblICInventoryTransfer TABLE (intInventoryTransferId INT)
	DECLARE @tblICInventoryTransferDetail TABLE (intInventoryTransferDetailId INT)
	DECLARE @tblOutput AS TABLE (
		intRowNo INT IDENTITY(1, 1)
		,intInventoryTransferId INT
		,strRowState NVARCHAR(50)
		,strXML NVARCHAR(MAX)
		,strTransferNo NVARCHAR(50)
		,strERPTransferOrderNo NVARCHAR(50)
		)

	DELETE
	FROM @tblICInventoryTransfer

	INSERT INTO @tblICInventoryTransfer (intInventoryTransferId)
	SELECT DISTINCT IT.intInventoryTransferId
	FROM tblICInventoryTransfer IT
	JOIN tblICInventoryTransferDetail ITD ON ITD.intInventoryTransferId = IT.intInventoryTransferId
	JOIN tblSMCompanyLocation CL ON CL.intCompanyLocationId = IT.intFromLocationId
		AND CL.strLotOrigin = @strCompanyLocation
	WHERE IT.ysnPosted = 1
		AND IT.intInventoryTransferId NOT IN (
			SELECT intInventoryTransferId
			FROM tblIPInvTransferFeed
			WHERE ISNULL(intStatusId, 1) <> 1 -- If already sent, don't send the feed again
			)

	IF NOT EXISTS (
			SELECT 1
			FROM @tblICInventoryTransfer
			)
	BEGIN
		RETURN
	END

	SELECT @intInventoryTransferId = MIN(intInventoryTransferId)
	FROM @tblICInventoryTransfer

	WHILE @intInventoryTransferId IS NOT NULL
	BEGIN
		SELECT @strRowState = NULL
			,@strUserName = NULL
			,@strError = ''

		SELECT @intActionId = NULL
			,@strTransferNo = NULL
			,@dtmTransferDate = NULL
			,@strShipVia = NULL
			,@strPaymentMethod = NULL
			,@strBolNumber = NULL
			,@dtmBolDate = NULL
			,@dtmBolReceivedDate = NULL
			,@strBroker = NULL
			,@strTrailerId = NULL
			,@strFromLocation = NULL
			,@strToLocation = NULL

		SELECT @intInventoryTransferDetailId = NULL
			,@strDetailXML = ''

		SELECT @intActionId = 1

		SELECT @strUserName = US.strUserName
			,@strTransferNo = IT.strTransferNo
			,@dtmTransferDate = IT.dtmTransferDate
			,@strShipVia = V.strVendorAccountNum
			,@strBolNumber = IT.strBolNumber
			,@dtmBolDate = IT.dtmBolDate
			,@dtmBolReceivedDate = IT.dtmBolReceivedDate
			,@strBroker = E.strName
			,@strTrailerId = IT.strTrailerId
			,@strFromLocation = FCL.strLotOrigin
			,@strToLocation = TCL.strLotOrigin
			,@strPaymentMethod = PM.strPaymentMethod
		FROM dbo.tblICInventoryTransfer IT
		JOIN dbo.tblSMUserSecurity US ON US.intEntityId = ISNULL(IT.intEntityId, IT.intCreatedUserId)
		LEFT JOIN dbo.tblSMCompanyLocation FCL ON FCL.intCompanyLocationId = IT.intFromLocationId
		LEFT JOIN dbo.tblSMCompanyLocation TCL ON TCL.intCompanyLocationId = IT.intToLocationId
		LEFT JOIN dbo.tblAPVendor V ON V.intEntityId = IT.intShipViaId
		LEFT JOIN dbo.tblEMEntity E ON E.intEntityId = IT.intBrokerId
		LEFT JOIN dbo.tblSMPaymentMethod PM ON PM.intPaymentMethodID = V.intPaymentMethodId
		WHERE IT.intInventoryTransferId = @intInventoryTransferId

		IF NOT EXISTS (
				SELECT 1
				FROM tblIPInvTransferFeed
				WHERE intInventoryTransferId = @intInventoryTransferId
				)
		BEGIN
			INSERT INTO tblIPInvTransferFeed (
				strCompanyLocation
				,intInventoryTransferId
				,strTransferNo
				,strERPTransferOrderNo
				,strCreatedBy
				,strTransactionType
				,intStatusId
				,strMessage
				,strFeedStatus
				)
			SELECT @strCompanyLocation
				,@intInventoryTransferId
				,@strTransferNo
				,NULL
				,@strUserName
				,LTRIM(@intActionId)
				,NULL
				,NULL
				,NULL
		END
		ELSE
		BEGIN
			UPDATE tblIPInvTransferFeed
			SET strCreatedBy = @strUserName
				,strMessage = NULL
				,intStatusId = NULL
				,strFeedStatus = NULL
			WHERE intInventoryTransferId = @intInventoryTransferId
		END

		IF @dtmTransferDate IS NULL
		BEGIN
			SELECT @strError = @strError + 'Transfer Date cannot be blank. '
		END

		IF ISNULL(@strFromLocation, '') = ''
		BEGIN
			SELECT @strError = @strError + 'From Location cannot be blank. '
		END

		IF ISNULL(@strToLocation, '') = ''
		BEGIN
			SELECT @strError = @strError + 'To Location cannot be blank. '
		END

		IF @strError <> ''
		BEGIN
			UPDATE tblIPInvTransferFeed
			SET strMessage = @strError
				,intStatusId = 1
			WHERE intInventoryTransferId = @intInventoryTransferId

			GOTO NextRec
		END

		SELECT @strXML = ''

		SELECT @strXML += '<header id="' + LTRIM(@intInventoryTransferId) + '">'

		SELECT @strXML += '<TrxSequenceNo>' + LTRIM(@intInventoryTransferId) + '</TrxSequenceNo>'

		SELECT @strXML += '<CompanyLocation>' + LTRIM(@strCompanyLocation) + '</CompanyLocation>'

		SELECT @strXML += '<ActionId>' + LTRIM(@intActionId) + '</ActionId>'

		SELECT @strXML += '<CreatedDate>' + CONVERT(VARCHAR(33), GetDate(), 126) + '</CreatedDate>'

		SELECT @strXML += '<CreatedByUser>' + @strUserName + '</CreatedByUser>'

		SELECT @strXML += '<TransferNo>' + ISNULL(@strTransferNo, '') + '</TransferNo>'

		SELECT @strXML += '<TransferDate>' + ISNULL(CONVERT(VARCHAR, @dtmTransferDate, 112), '') + '</TransferDate>'

		SELECT @strXML += '<ShipVia>' + ISNULL(@strShipVia, '') + '</ShipVia>'

		SELECT @strXML += '<Book>' + ISNULL(@strPaymentMethod, '') + '</Book>'

		SELECT @strXML += '<BOLNumber>' + ISNULL(@strBolNumber, '') + '</BOLNumber>'

		SELECT @strXML += '<BOLDate>' + ISNULL(CONVERT(VARCHAR, @dtmBolDate, 112), '') + '</BOLDate>'

		SELECT @strXML += '<BOLReceivedDate>' + ISNULL(CONVERT(VARCHAR, @dtmBolReceivedDate, 112), '') + '</BOLReceivedDate>'

		SELECT @strXML += '<Broker>' + dbo.fnEscapeXML(ISNULL(@strBroker, '')) + '</Broker>'

		SELECT @strXML += '<TrailerId>' + dbo.fnEscapeXML(ISNULL(@strTrailerId, '')) + '</TrailerId>'

		SELECT @strXML += '<FromLocation>' + ISNULL(@strFromLocation, '') + '</FromLocation>'

		SELECT @strXML += '<ToLocation>' + ISNULL(@strToLocation, '') + '</ToLocation>'

		DELETE
		FROM @tblICInventoryTransferDetail

		INSERT INTO @tblICInventoryTransferDetail (intInventoryTransferDetailId)
		SELECT ITD.intInventoryTransferDetailId
		FROM tblICInventoryTransferDetail ITD
		WHERE ITD.intInventoryTransferId = @intInventoryTransferId

		SELECT @intInventoryTransferDetailId = MIN(intInventoryTransferDetailId)
		FROM @tblICInventoryTransferDetail

		WHILE @intInventoryTransferDetailId IS NOT NULL
		BEGIN
			SELECT @strQuantityUOM = NULL
				,@strDefaultCurrency = NULL
				,@intCurrencyId = NULL
				,@intUnitMeasureId = NULL
				,@intItemId = NULL
				,@intItemUOMId = NULL

			SELECT @strItemNo = NULL
				,@strFromStorageLocation = NULL
				,@strFromStorageUnit = NULL
				,@strParentLotNumber = NULL
				,@strLotNumber = NULL
				,@dblQuantity = NULL
				,@strQtyUOM = NULL
				,@strToStorageLocation = NULL
				,@strToStorageUnit = NULL
				,@dtmDeliveryDate = NULL
				,@strContainerNumber = NULL
				,@strMarks = NULL
				,@dblTransferPrice = NULL
				,@strCurrency = NULL
				,@strComment = NULL
				,@dblGross = NULL
				,@dblTare = NULL
				,@dblNet = NULL

			SELECT @intItemId = ITD.intItemId
			FROM dbo.tblICInventoryTransferDetail ITD
			WHERE ITD.intInventoryTransferDetailId = @intInventoryTransferDetailId

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

			SELECT @strItemNo = ISNULL(I.strItemNo, '')
				,@strFromStorageLocation = ISNULL(FSL.strSubLocationName, '')
				,@strFromStorageUnit = ISNULL(FSU.strName, '')
				,@strParentLotNumber = ISNULL(PL.strParentLotNumber, '')
				,@strLotNumber = ISNULL(L.strLotNumber, '')
				,@dblQuantity = CONVERT(NUMERIC(18, 6), ITD.dblQuantity)
				,@strQtyUOM = ISNULL(UOM.strUnitMeasure, '')
				,@strToStorageLocation = ISNULL(TSL.strSubLocationName, '')
				,@strToStorageUnit = ISNULL(TSU.strName, '')
				,@dtmDeliveryDate = ITD.dtmDeliveryDate
				,@strContainerNumber = ISNULL(ITD.strContainerNumber, '')
				,@strMarks = ISNULL(ITD.strMarks, '')
				,@dblTransferPrice = CONVERT(NUMERIC(18, 6), ITD.dblTransferPrice)
				,@strCurrency = ISNULL(C.strCurrency, '')
				,@strComment = ISNULL(ITD.strComment, '')
				,@dblGross = CONVERT(NUMERIC(18, 6), ISNULL(dbo.fnCTConvertQtyToTargetItemUOM(ITD.intGrossNetUOMId, @intItemUOMId, ITD.dblGross), 0))
				,@dblTare = CONVERT(NUMERIC(18, 6), ISNULL(dbo.fnCTConvertQtyToTargetItemUOM(ITD.intGrossNetUOMId, @intItemUOMId, ITD.dblTare), 0))
				,@dblNet = CONVERT(NUMERIC(18, 6), ISNULL(dbo.fnCTConvertQtyToTargetItemUOM(ITD.intGrossNetUOMId, @intItemUOMId, ITD.dblNet), 0))
			FROM tblICInventoryTransferDetail ITD
			JOIN tblICItem I ON I.intItemId = ITD.intItemId
			LEFT JOIN tblSMCompanyLocationSubLocation FSL ON FSL.intCompanyLocationSubLocationId = ITD.intFromSubLocationId
			LEFT JOIN tblICStorageLocation FSU ON FSU.intStorageLocationId = ITD.intFromStorageLocationId
			LEFT JOIN tblICLot L ON L.intLotId = ITD.intLotId
			LEFT JOIN tblICParentLot PL ON PL.intParentLotId = L.intParentLotId
			LEFT JOIN tblICItemUOM IUOM ON IUOM.intItemUOMId = ITD.intItemUOMId
			LEFT JOIN tblICUnitMeasure UOM ON UOM.intUnitMeasureId = IUOM.intUnitMeasureId
			LEFT JOIN tblSMCompanyLocationSubLocation TSL ON TSL.intCompanyLocationSubLocationId = ITD.intToSubLocationId
			LEFT JOIN tblICStorageLocation TSU ON TSU.intStorageLocationId = ITD.intToStorageLocationId
			LEFT JOIN tblSMCurrency C ON C.intCurrencyID = ITD.intCurrencyId
			WHERE ITD.intInventoryTransferDetailId = @intInventoryTransferDetailId

			IF ISNULL(@strItemNo, '') = ''
			BEGIN
				SELECT @strError = @strError + 'Item No cannot be blank. '
			END

			IF ISNULL(@strFromStorageLocation, '') = ''
			BEGIN
				SELECT @strError = @strError + 'From Storage Location cannot be blank. '
			END

			IF ISNULL(@strFromStorageUnit, '') = ''
			BEGIN
				SELECT @strError = @strError + 'From Storage Unit cannot be blank. '
			END

			IF ISNULL(@strParentLotNumber, '') = ''
			BEGIN
				SELECT @strError = @strError + 'Parent Lot No cannot be blank. '
			END

			IF ISNULL(@strLotNumber, '') = ''
			BEGIN
				SELECT @strError = @strError + 'Lot No cannot be blank. '
			END

			IF ISNULL(@dblQuantity, 0) = 0
			BEGIN
				SELECT @strError = @strError + 'Transfer Qty should be greater than 0. '
			END

			IF ISNULL(@strQtyUOM, '') = ''
			BEGIN
				SELECT @strError = @strError + 'Transfer Qty UOM cannot be blank. '
			END

			IF ISNULL(@strToStorageLocation, '') = ''
			BEGIN
				SELECT @strError = @strError + 'To Storage Location cannot be blank. '
			END

			IF ISNULL(@strToStorageUnit, '') = ''
			BEGIN
				SELECT @strError = @strError + 'To Storage Unit cannot be blank. '
			END

			IF ISNULL(@dblGross, 0) = 0
			BEGIN
				SELECT @strError = @strError + 'Gross Weight should be greater than 0. '
			END

			IF ISNULL(@dblNet, 0) = 0
			BEGIN
				SELECT @strError = @strError + 'Net Weight should be greater than 0. '
			END

			IF @strError <> ''
			BEGIN
				UPDATE tblIPInvTransferFeed
				SET strMessage = @strError
					,intStatusId = 1
				WHERE intInventoryTransferId = @intInventoryTransferId

				GOTO NextRec
			END

			SELECT @strItemXML = ''

			SELECT @strItemXML += '<line id="' + LTRIM(@intInventoryTransferDetailId) + '" parentId="' + LTRIM(@intInventoryTransferId) + '">'

			SELECT @strItemXML += '<TrxSequenceNo>' + LTRIM(@intInventoryTransferDetailId) + '</TrxSequenceNo>'

			SELECT @strItemXML += '<ItemNo>' + ISNULL(@strItemNo, '') + '</ItemNo>'

			SELECT @strItemXML += '<FromStorageLocation>' + ISNULL(@strFromStorageLocation, '') + '</FromStorageLocation>'

			SELECT @strItemXML += '<FromStorageUnit>' + ISNULL(@strFromStorageUnit, '') + '</FromStorageUnit>'

			SELECT @strItemXML += '<MotherLotNo>' + ISNULL(@strParentLotNumber, '') + '</MotherLotNo>'

			SELECT @strItemXML += '<LotNo>' + ISNULL(@strLotNumber, '') + '</LotNo>'

			SELECT @strItemXML += '<TransferQty>' + LTRIM(ISNULL(@dblQuantity, 0)) + '</TransferQty>'

			SELECT @strItemXML += '<TransferQtyUOM>' + ISNULL(@strQtyUOM, '') + '</TransferQtyUOM>'

			SELECT @strItemXML += '<ToStorageLocation>' + ISNULL(@strToStorageLocation, '') + '</ToStorageLocation>'

			SELECT @strItemXML += '<ToStorageUnit>' + ISNULL(@strToStorageUnit, '') + '</ToStorageUnit>'

			SELECT @strItemXML += '<DeliveryDate>' + ISNULL(CONVERT(VARCHAR, @dtmDeliveryDate, 112), '') + '</DeliveryDate>'

			SELECT @strItemXML += '<ContainerNo>' + dbo.fnEscapeXML(ISNULL(@strContainerNumber, '')) + '</ContainerNo>'

			SELECT @strItemXML += '<Marks>' + dbo.fnEscapeXML(ISNULL(@strMarks, '')) + '</Marks>'

			SELECT @strItemXML += '<TransferPrice>' + LTRIM(ISNULL(@dblTransferPrice, 0)) + '</TransferPrice>'

			SELECT @strItemXML += '<Currency>' + ISNULL(@strCurrency, '') + '</Currency>'

			SELECT @strItemXML += '<Comments>' + dbo.fnEscapeXML(ISNULL(@strComment, '')) + '</Comments>'

			SELECT @strItemXML += '<GrossWeight>' + LTRIM(ISNULL(@dblGross, 0)) + '</GrossWeight>'

			SELECT @strItemXML += '<TareWeight>' + LTRIM(ISNULL(@dblTare, 0)) + '</TareWeight>'

			SELECT @strItemXML += '<NetWeight>' + LTRIM(ISNULL(@dblNet, 0)) + '</NetWeight>'

			SELECT @strItemXML += '<WeightUOM>' + ISNULL(@strQuantityUOM, '') + '</WeightUOM>'

			SELECT @strItemXML += '</line>'

			IF ISNULL(@strItemXML, '') = ''
			BEGIN
				UPDATE tblIPInvTransferFeed
				SET strMessage = 'Transfer Detail XML not available. '
					,intStatusId = 1
				WHERE intInventoryTransferId = @intInventoryTransferId

				GOTO NextRec
			END

			SELECT @strDetailXML = @strDetailXML + @strItemXML

			SELECT @intInventoryTransferDetailId = MIN(intInventoryTransferDetailId)
			FROM @tblICInventoryTransferDetail
			WHERE intInventoryTransferDetailId > @intInventoryTransferDetailId
		END

		SELECT @strFinalXML = @strFinalXML + @strXML + @strDetailXML + '</header>'

		IF @ysnUpdateFeedStatus = 1
		BEGIN
			UPDATE tblIPInvTransferFeed
			SET strMessage = NULL
				,intStatusId = 2
			WHERE intInventoryTransferId = @intInventoryTransferId
		END

		NextRec:

		SELECT @intInventoryTransferId = MIN(intInventoryTransferId)
		FROM @tblICInventoryTransfer
		WHERE intInventoryTransferId > @intInventoryTransferId
	END

	IF @strFinalXML <> ''
	BEGIN
		SELECT @strFinalXML = '<root><data>' + @strFinalXML + '</data></root>'

		DELETE
		FROM @tblOutput

		INSERT INTO @tblOutput (
			intInventoryTransferId
			,strRowState
			,strXML
			,strTransferNo
			,strERPTransferOrderNo
			)
		VALUES (
			@intInventoryTransferId
			,'CREATE'
			,@strFinalXML
			,ISNULL(@strTransferNo, '')
			,''
			)
	END

	SELECT IsNULL(intInventoryTransferId, '0') AS id
		,IsNULL(strXML, '') AS strXml
		,IsNULL(strTransferNo, '') AS strInfo1
		,IsNULL(strERPTransferOrderNo, '') AS strInfo2
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
