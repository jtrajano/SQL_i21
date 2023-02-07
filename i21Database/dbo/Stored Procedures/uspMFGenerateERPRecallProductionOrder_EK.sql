CREATE PROCEDURE uspMFGenerateERPRecallProductionOrder_EK (
	@limit INT = 0
	,@offset INT = 0
	,@ysnUpdateFeedStatus BIT = 1
	)
AS
BEGIN TRY
	SET NOCOUNT ON

	DECLARE @ErrMsg NVARCHAR(MAX)
		,@intRecallPreStageId INT
		,@strXML NVARCHAR(MAX) = ''
		,@strHeaderXML NVARCHAR(MAX) = ''
		,@strERPOrderNo NVARCHAR(50)
		,@intWorkOrderId INT
		,@intLocationId INT
		,@strPlantNo NVARCHAR(50)
		,@strError NVARCHAR(MAX) = ''
		,@strWorkOrderNo NVARCHAR(50)
	DECLARE @tblOutput AS TABLE (
		intRowNo INT IDENTITY(1, 1)
		,intRecallId INT
		,strRowState NVARCHAR(50)
		,strXML NVARCHAR(MAX)
		,strRecallNo NVARCHAR(50)
		,strERPOrderNo NVARCHAR(50)
		)
	DECLARE @tblMFRecallPreStage TABLE (intRecallPreStageId INT)

	IF NOT EXISTS (
			SELECT *
			FROM dbo.tblMFRecallPreStage
			WHERE intStatusId IS NULL
			)
	BEGIN
		RETURN
	END

	DECLARE @tmp INT
		,@FirstCount INT = 0

	SELECT @tmp = strValue
	FROM tblIPSAPIDOCTag
	WHERE strMessageType = 'Recall Production Order'
		AND strTag = 'Count'

	IF ISNULL(@tmp, 0) = 0
		SELECT @tmp = 100

	IF @limit > @tmp
	BEGIN
		SELECT @limit = @tmp
	END

	INSERT INTO @tblMFRecallPreStage (intRecallPreStageId)
	SELECT TOP (@limit) PS.intRecallPreStageId
	FROM dbo.tblMFRecallPreStage PS
	WHERE PS.intStatusId IS NULL
	ORDER BY intRecallPreStageId

	SELECT @intRecallPreStageId = MIN(intRecallPreStageId)
	FROM @tblMFRecallPreStage

	IF @intRecallPreStageId IS NULL
	BEGIN
		RETURN
	END

	UPDATE dbo.tblMFRecallPreStage
	SET intStatusId = - 1
	WHERE intRecallPreStageId IN (
			SELECT PS.intRecallPreStageId
			FROM @tblMFRecallPreStage PS
			)

	SELECT @strXML = '<root><CtrlPoint><DocNo>' + IsNULL(ltrim(@intRecallPreStageId), '') + '</DocNo>' + '<MsgType>Recall_BlendSheet</MsgType>' + '<Sender>iRely</Sender>' + '<Receiver>SAP</Receiver></CtrlPoint>'

	WHILE @intRecallPreStageId IS NOT NULL
	BEGIN
		SELECT @intWorkOrderId = NULL
			,@intLocationId = NULL
			,@strERPOrderNo = NULL
			,@strPlantNo = NULL
			,@strWorkOrderNo = NULL

		SELECT @intWorkOrderId = intWorkOrderId
		FROM dbo.tblMFRecallPreStage
		WHERE intRecallPreStageId = @intRecallPreStageId

		SELECT @intLocationId = intLocationId
			,@strERPOrderNo = strERPOrderNo
			,@strWorkOrderNo = strWorkOrderNo
		FROM tblMFWorkOrder
		WHERE intWorkOrderId = @intWorkOrderId

		SELECT @strPlantNo = strVendorRefNoPrefix
		FROM tblSMCompanyLocation
		WHERE intCompanyLocationId = @intLocationId

		IF @strERPOrderNo IS NULL
		BEGIN
			SELECT @strError = @strError + 'ERP Order No cannot be blank. '
		END

		IF @strPlantNo IS NULL
		BEGIN
			SELECT @strError = @strError + 'Plant cannot be blank. '
		END

		IF @strError <> ''
		BEGIN
			UPDATE tblMFRecallPreStage
			SET strMessage = @strError
				,intStatusId = 1
			WHERE intWorkOrderId = @intWorkOrderId

			SELECT @strError = ''

			GOTO NextItemRec
		END

		SELECT @strHeaderXML = @strHeaderXML + '<Header><Plant>' + IsNULL(@strPlantNo, '') + '</Plant>' + '<OrderNo>' + IsNULL(@strERPOrderNo, '') + '</OrderNo></Header>'

		IF @ysnUpdateFeedStatus = 1
		BEGIN
			UPDATE dbo.tblMFRecallPreStage
			SET intStatusId = 2
				,strMessage = 'Success'
			WHERE intRecallPreStageId = @intRecallPreStageId
		END

		NextItemRec:

		SELECT @intRecallPreStageId = MIN(intRecallPreStageId)
		FROM @tblMFRecallPreStage
		WHERE intRecallPreStageId > @intRecallPreStageId
	END

	IF @strHeaderXML <> ''
	BEGIN
		SELECT @strXML = @strXML + @strHeaderXML + '</root>'

		INSERT INTO @tblOutput (
			intRecallId
			,strRowState
			,strXML
			,strRecallNo
			,strERPOrderNo
			)
		VALUES (
			@intWorkOrderId
			,'Added'
			,@strXML
			,ISNULL(@strWorkOrderNo, '')
			,ISNULL(@strERPOrderNo, '')
			)
	END

	UPDATE dbo.tblMFRecallPreStage
	SET intStatusId = NULL
	WHERE intRecallPreStageId IN (
			SELECT PS.intRecallPreStageId
			FROM @tblMFRecallPreStage PS
			)
		AND intStatusId = - 1

	SELECT IsNULL(intRecallId, '0') AS id
		,IsNULL(strXML, '') AS strXml
		,IsNULL(strRecallNo, '') AS strInfo1
		,IsNULL(strERPOrderNo, '') AS strInfo2
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
