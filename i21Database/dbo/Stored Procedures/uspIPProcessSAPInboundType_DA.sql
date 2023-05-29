CREATE PROCEDURE uspIPProcessSAPInboundType_DA
AS
BEGIN
	DECLARE @intRowNo INT
		,@strXml NVARCHAR(MAX)
		,@idoc INT
		,@MSG_TYPE NVARCHAR(50)
		,@RCVPRN NVARCHAR(50)
		,@strType NVARCHAR(50)
	DECLARE @tblIPIDOCXMLStage TABLE (intIDOCXMLStageId INT)

	INSERT INTO @tblIPIDOCXMLStage (intIDOCXMLStageId)
	SELECT intIDOCXMLStageId
	FROM tblIPIDOCXMLStage
	WHERE strType = 'InboundXML'

	SELECT @intRowNo = MIN(intIDOCXMLStageId)
	FROM @tblIPIDOCXMLStage

	IF @intRowNo IS NULL
	BEGIN
		RETURN
	END

	WHILE (ISNULL(@intRowNo, 0) > 0)
	BEGIN
		SELECT @strXml = NULL
			,@idoc = NULL
			,@MSG_TYPE = NULL
			,@RCVPRN = NULL
			,@strType = NULL

		SELECT @strXml = strXml
		FROM tblIPIDOCXMLStage
		WHERE intIDOCXMLStageId = @intRowNo

		SET @strXml = REPLACE(@strXml, 'utf-8' COLLATE Latin1_General_CI_AS, 'utf-16' COLLATE Latin1_General_CI_AS)

		EXEC sp_xml_preparedocument @idoc OUTPUT
			,@strXml

		SELECT @MSG_TYPE = MSG_TYPE
			,@RCVPRN = RCVPRN
		FROM OPENXML(@idoc, 'ROOT_ACK/LINE_ITEM', 2) WITH (
				MSG_TYPE NVARCHAR(50) '../CTRL_POINT/MSG_TYPE'
				,RCVPRN NVARCHAR(50) '../CTRL_POINT/RCVPRN'
				)

		IF @MSG_TYPE = 'PO_CREATE_ACK'
			SELECT @strType = 'PO Ack'
		ELSE IF @MSG_TYPE = 'PO_UPDATE_ACK'
			SELECT @strType = 'PO Ack'
		ELSE IF @MSG_TYPE = 'RECEIPT_CREATE'
			SELECT @strType = 'Goods Receipt'
		ELSE IF @MSG_TYPE = 'STOCK_CREATE'
			SELECT @strType = 'Stock'

		UPDATE tblIPIDOCXMLStage
		SET strType = @strType
		WHERE intIDOCXMLStageId = @intRowNo

		SELECT @intRowNo = MIN(intIDOCXMLStageId)
		FROM @tblIPIDOCXMLStage
		WHERE intIDOCXMLStageId > @intRowNo
	END
END
