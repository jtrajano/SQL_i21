CREATE PROCEDURE uspIPGenerateSAPShipment_DA
AS
BEGIN
	DECLARE @strXml NVARCHAR(MAX)
		,@strHeaderXML NVARCHAR(MAX)
		,@strDetailXML NVARCHAR(MAX)
		,@strError NVARCHAR(MAX) = ''
	DECLARE @tblOutput AS TABLE (
		intRowNo INT IDENTITY(1, 1)
		,strLoadStgIds NVARCHAR(MAX)
		,strRowState NVARCHAR(50)
		,strXml NVARCHAR(MAX)
		,strLoadNumber NVARCHAR(100)
		,strContractNumber NVARCHAR(100)
		)
	DECLARE @tblLGLoadStg TABLE (intLoadStgId INT)
	DECLARE @intLoadStgId INT
		,@strLoadNumber NVARCHAR(100)
		,@intLoadId INT
		,@ysnPosted BIT
		,@intShipmentStatus INT
		,@strRowState NVARCHAR(50)
	DECLARE @tblLGLoadDetailStg TABLE (intLGLoadDetailStgId INT)
	DECLARE @intLGLoadDetailStgId INT
		,@intLoadDetailId INT
		,@strExternalPONumber NVARCHAR(100)
		,@strExternalPOItemNumber NVARCHAR(100)
		,@dblDeliveredQty NUMERIC(18, 6)
		,@strUnitOfMeasure NVARCHAR(100)
		,@strCommodityCode NVARCHAR(100)
		,@dblGrossWt NUMERIC(18, 6)
		,@strWeightUOM NVARCHAR(50)
	DECLARE @strContractNumber NVARCHAR(50)
		,@intContractSeq INT
		,@strVendorAccountNum NVARCHAR(50)
		,@strPosition NVARCHAR(100)
		,@dtmScheduledDate DATETIME
		,@strBLNumber NVARCHAR(100)
		,@dtmBLDate DATETIME
		,@strLoadingCity NVARCHAR(50)
		,@strDestinationCity NVARCHAR(50)
		,@dtmETAPOL DATETIME
		,@dtmETSPOL DATETIME
		,@dtmETAPOD DATETIME
		,@strItemNo NVARCHAR(50)
		,@strShortName NVARCHAR(50)

	INSERT INTO @tblLGLoadStg (intLoadStgId)
	SELECT intLoadStgId
	FROM dbo.tblLGLoadStg
	WHERE ISNULL(strFeedStatus, '') = ''
		AND strTransactionType = 'Shipment'

	IF NOT EXISTS (
			SELECT 1
			FROM @tblLGLoadStg
			)
	BEGIN
		SELECT ISNULL(strLoadStgIds, '0') AS id
			,ISNULL(strXml, '') AS strXml
			,ISNULL(strLoadNumber, '') AS strInfo1
			,ISNULL(strContractNumber, '') AS strInfo2
			,'' AS strOnFailureCallbackSql
		FROM @tblOutput
		ORDER BY intRowNo

		RETURN
	END

	SELECT @intLoadStgId = MIN(intLoadStgId)
	FROM @tblLGLoadStg

	WHILE @intLoadStgId IS NOT NULL
	BEGIN
		SELECT @strLoadNumber = NULL
			,@intLoadId = NULL
			,@ysnPosted = NULL
			,@intShipmentStatus = NULL
			,@strRowState = NULL

		SELECT @strHeaderXML = ''

		SELECT @intLoadId = intLoadId
			,@strRowState = strRowState
		FROM dbo.tblLGLoadStg
		WHERE intLoadStgId = @intLoadStgId

		IF NOT EXISTS (
				SELECT 1
				FROM dbo.tblLGLoad WITH (NOLOCK)
				WHERE intLoadId = @intLoadId
				)
		BEGIN
			UPDATE tblLGLoadStg
			SET strFeedStatus = 'NA'
				,strMessage = 'LS is not available. '
			WHERE intLoadStgId = @intLoadStgId

			GOTO NEXT_SHIPMENT
		END

		SELECT @strLoadNumber = strLoadNumber
			,@ysnPosted = ISNULL(ysnPosted, 0)
			,@intShipmentStatus = intShipmentStatus
		FROM dbo.tblLGLoad WITH (NOLOCK)
		WHERE intLoadId = @intLoadId

		IF ISNULL(@ysnPosted, 0) = 0
		BEGIN
			UPDATE tblLGLoadStg
			SET strFeedStatus = 'NA'
				,strMessage = 'LS is not yet posted. '
			WHERE intLoadStgId = @intLoadStgId

			GOTO NEXT_SHIPMENT
		END

		-- Do not send any feed if the Load is Cancelled
		IF @intShipmentStatus = 10
		BEGIN
			UPDATE tblLGLoadStg
			SET strFeedStatus = 'NA'
				,strMessage = 'LS is already cancelled. '
			WHERE intLoadStgId = @intLoadStgId

			GOTO NEXT_SHIPMENT
		END

		DELETE
		FROM @tblLGLoadDetailStg

		INSERT INTO @tblLGLoadDetailStg (intLGLoadDetailStgId)
		SELECT intLGLoadDetailStgId
		FROM dbo.tblLGLoadDetailStg
		WHERE intLoadStgId = @intLoadStgId

		IF (
				SELECT COUNT(1)
				FROM @tblLGLoadDetailStg
				) > 1
		BEGIN
			UPDATE tblLGLoadStg
			SET strFeedStatus = 'NA'
				,strMessage = 'LS cannot have multiple line items. '
			WHERE intLoadStgId = @intLoadStgId

			GOTO NEXT_SHIPMENT
		END

		SELECT @intLGLoadDetailStgId = MIN(intLGLoadDetailStgId)
		FROM @tblLGLoadDetailStg

		WHILE @intLGLoadDetailStgId IS NOT NULL
		BEGIN
			SELECT @strDetailXML = ''

			SELECT @intLoadDetailId = NULL
				,@strExternalPONumber = NULL
				,@strExternalPOItemNumber = NULL
				,@dblDeliveredQty = NULL
				,@strUnitOfMeasure = NULL
				,@strCommodityCode = NULL
				,@dblGrossWt = NULL
				,@strWeightUOM = NULL

			SELECT @strContractNumber = NULL
				,@intContractSeq = NULL
				,@strVendorAccountNum = NULL
				,@strPosition = NULL
				,@dtmScheduledDate = NULL
				,@strBLNumber = NULL
				,@dtmBLDate = NULL
				,@strLoadingCity = NULL
				,@strDestinationCity = NULL
				,@dtmETAPOL = NULL
				,@dtmETSPOL = NULL
				,@dtmETAPOD = NULL
				,@strItemNo = NULL
				,@strShortName = NULL

			SELECT @intLoadDetailId = intLoadDetailId
				,@strExternalPONumber = strExternalPONumber
				,@strExternalPOItemNumber = strExternalPOItemNumber
				,@dblDeliveredQty = dblDeliveredQty
				,@strUnitOfMeasure = strUnitOfMeasure
				,@strCommodityCode = strCommodityCode
				,@dblGrossWt = dblGrossWt
				,@strWeightUOM = strWeightUOM
			FROM dbo.tblLGLoadDetailStg WITH (NOLOCK)
			WHERE intLGLoadDetailStgId = @intLGLoadDetailStgId

			SELECT @strContractNumber = CH.strContractNumber
				,@intContractSeq = CD.intContractSeq
				,@strVendorAccountNum = V.strVendorAccountNum
				,@strPosition = P.strPosition
				,@dtmScheduledDate = L.dtmScheduledDate
				,@strBLNumber = L.strBLNumber
				,@dtmBLDate = L.dtmBLDate
				,@strLoadingCity = LP.strCity
				,@strDestinationCity = DP.strCity
				,@dtmETAPOL = L.dtmETAPOL
				,@dtmETSPOL = L.dtmETSPOL
				,@dtmETAPOD = L.dtmETAPOD
				,@strItemNo = I.strItemNo
				,@strShortName = I.strShortName
			FROM dbo.tblLGLoadDetail LD WITH (NOLOCK)
			JOIN dbo.tblLGLoad L WITH (NOLOCK) ON L.intLoadId = LD.intLoadId
				AND LD.intLoadDetailId = @intLoadDetailId
			JOIN dbo.tblCTContractDetail CD WITH (NOLOCK) ON CD.intContractDetailId = LD.intPContractDetailId
			JOIN dbo.tblCTContractHeader CH WITH (NOLOCK) ON CH.intContractHeaderId = CD.intContractHeaderId
			JOIN dbo.vyuAPVendor V WITH (NOLOCK) ON V.intEntityId = LD.intVendorEntityId
			JOIN dbo.tblICItem I WITH (NOLOCK) ON I.intItemId = LD.intItemId
			LEFT JOIN dbo.tblCTPosition P WITH (NOLOCK) ON P.intPositionId = L.intPositionId
			LEFT JOIN dbo.tblSMCity LP WITH (NOLOCK) ON LP.intCityId = CD.intLoadingPortId
			LEFT JOIN dbo.tblSMCity DP WITH (NOLOCK) ON DP.intCityId = CD.intDestinationPortId

			SELECT @strDetailXML = '<LINE_ITEM>'

			SELECT @strDetailXML += '<SEQUENCE_NO>' + LTRIM(ISNULL(@intContractSeq, '')) + '</SEQUENCE_NO>'

			SELECT @strDetailXML += '<PO_LINE_ITEM_NO>' + ISNULL(@strExternalPOItemNumber, '') + '</PO_LINE_ITEM_NO>'

			SELECT @strDetailXML += '<ITEM_NO>' + dbo.fnEscapeXML(ISNULL(@strItemNo, '')) + '</ITEM_NO>'

			SELECT @strDetailXML += '<SHORT_NAME>' + ISNULL(@strShortName, '') + '</SHORT_NAME>'

			SELECT @strDetailXML += '<COMMODITY>' + ISNULL(@strCommodityCode, '') + '</COMMODITY>'

			SELECT @strDetailXML += '<GROSS_WEIGHT>' + ISNULL(CONVERT(NVARCHAR(50), CONVERT(NUMERIC(18, 2), @dblGrossWt)), '') + '</GROSS_WEIGHT>'

			SELECT @strDetailXML += '<WEIGHT_UOM>' + ISNULL(@strWeightUOM, '') + '</WEIGHT_UOM>'

			SELECT @strDetailXML += '</LINE_ITEM>'

			SELECT @intLGLoadDetailStgId = MIN(intLGLoadDetailStgId)
			FROM @tblLGLoadDetailStg
			WHERE intLGLoadDetailStgId > @intLGLoadDetailStgId
		END

		IF ISNULL(@strDetailXML, '') <> ''
		BEGIN
			SELECT @strError = ''

			IF ISNULL(@strExternalPONumber, '') = ''
			BEGIN
				SELECT @strError = @strError + 'External PO Number cannot be blank. '
			END

			IF ISNULL(@strPosition, '') = ''
			BEGIN
				SELECT @strError = @strError + 'Position cannot be blank. '
			END

			IF ISNULL(@strLoadingCity, '') = ''
			BEGIN
				SELECT @strError = @strError + 'Loading Port cannot be blank. '
			END

			IF ISNULL(@strDestinationCity, '') = ''
			BEGIN
				SELECT @strError = @strError + 'Destination Port cannot be blank. '
			END

			IF @dtmETAPOL IS NULL
			BEGIN
				SELECT @strError = @strError + 'ETA POL cannot be blank. '
			END

			IF @dtmETSPOL IS NULL
			BEGIN
				SELECT @strError = @strError + 'ETS POL cannot be blank. '
			END

			IF @dtmETAPOD IS NULL
			BEGIN
				SELECT @strError = @strError + 'ETA POD cannot be blank. '
			END

			IF @strError <> ''
			BEGIN
				UPDATE tblLGLoadStg
				SET strFeedStatus = 'NA'
					,strMessage = @strError
				WHERE intLoadStgId = @intLoadStgId

				GOTO NEXT_SHIPMENT
			END

			SELECT @strHeaderXML = '<ROOT_PO>'

			SELECT @strHeaderXML += '<CTRL_POINT>'

			SELECT @strHeaderXML += '<DOC_NO>' + LTRIM(ISNULL(@intLoadStgId, '')) + '</DOC_NO>'

			SELECT @strHeaderXML += '<MSG_TYPE>' + 'LS_CREATE' + '</MSG_TYPE>'

			SELECT @strHeaderXML += '<SENDER>i21</SENDER>'

			SELECT @strHeaderXML += '<RECEIVER>SAP</RECEIVER>'

			SELECT @strHeaderXML += '<SNDPRT>LS</SNDPRT>'

			SELECT @strHeaderXML += '<SNDPRN>IRE02</SNDPRN>'

			SELECT @strHeaderXML += '</CTRL_POINT>'

			SELECT @strHeaderXML += '<HEADER>'

			SELECT @strHeaderXML += '<LS_NO>' + ISNULL(@strLoadNumber, '') + '</LS_NO>'

			SELECT @strHeaderXML += '<CONTRACT_NO>' + ISNULL(@strContractNumber, '') + '</CONTRACT_NO>'

			SELECT @strHeaderXML += '<PO_NUMBER>' + ISNULL(@strExternalPONumber, '') + '</PO_NUMBER>'

			SELECT @strHeaderXML += '<VENDOR>' + ISNULL(@strVendorAccountNum, '') + '</VENDOR>'

			SELECT @strHeaderXML += '<POSITION>' + dbo.fnEscapeXML(ISNULL(@strPosition, '')) + '</POSITION>'

			SELECT @strHeaderXML += '<SCHEDULED_DATE>' + ISNULL(CONVERT(NVARCHAR, @dtmScheduledDate, 112), '') + '</SCHEDULED_DATE>'

			SELECT @strHeaderXML += '<QUANTITY>' + ISNULL(CONVERT(NVARCHAR(50), CONVERT(NUMERIC(18, 2), @dblDeliveredQty)), '') + '</QUANTITY>'

			SELECT @strHeaderXML += '<QUANTITY_UOM>' + ISNULL(@strUnitOfMeasure, '') + '</QUANTITY_UOM>'

			SELECT @strHeaderXML += '<BOL_NO>' + dbo.fnEscapeXML(ISNULL(@strBLNumber, '')) + '</BOL_NO>'

			SELECT @strHeaderXML += '<BOL_DATE>' + ISNULL(CONVERT(NVARCHAR, @dtmBLDate, 112), '') + '</BOL_DATE>'

			SELECT @strHeaderXML += '<LOAD_PORT>' + ISNULL(@strLoadingCity, '') + '</LOAD_PORT>'

			SELECT @strHeaderXML += '<DEST_PORT>' + ISNULL(@strDestinationCity, '') + '</DEST_PORT>'

			SELECT @strHeaderXML += '<ETA_POL>' + ISNULL(CONVERT(NVARCHAR, @dtmETAPOL, 112), '') + '</ETA_POL>'

			SELECT @strHeaderXML += '<ETS_POL>' + ISNULL(CONVERT(NVARCHAR, @dtmETSPOL, 112), '') + '</ETS_POL>'

			SELECT @strHeaderXML += '<ETA_POD>' + ISNULL(CONVERT(NVARCHAR, @dtmETAPOD, 112), '') + '</ETA_POD>'

			SELECT @strHeaderXML += '</HEADER>'
		END

		SELECT @strXml = @strHeaderXML + @strDetailXML + '</ROOT_PO>'

		DELETE
		FROM @tblOutput

		IF @strXml IS NOT NULL
		BEGIN
			INSERT INTO @tblOutput (
				strLoadStgIds
				,strRowState
				,strXml
				,strLoadNumber
				,strContractNumber
				)
			VALUES (
				@intLoadStgId
				,@strRowState
				,@strXml
				,ISNULL(@strLoadNumber, '')
				,ISNULL(@strContractNumber, '')
				)

			UPDATE tblLGLoadStg
			SET strFeedStatus = 'Awt Ack'
				,strMessage = NULL
				,ysnMailSent = 0
			WHERE intLoadStgId = @intLoadStgId
		END

		IF EXISTS (
				SELECT 1
				FROM @tblOutput
				)
		BEGIN
			BREAK
		END

		NEXT_SHIPMENT:

		SELECT @intLoadStgId = MIN(intLoadStgId)
		FROM @tblLGLoadStg
		WHERE intLoadStgId > @intLoadStgId
	END

	SELECT ISNULL(strLoadStgIds, '0') AS id
		,ISNULL(strXml, '') AS strXml
		,ISNULL(strLoadNumber, '') AS strInfo1
		,ISNULL(strContractNumber, '') AS strInfo2
		,'' AS strOnFailureCallbackSql
	FROM @tblOutput
	ORDER BY intRowNo
END
