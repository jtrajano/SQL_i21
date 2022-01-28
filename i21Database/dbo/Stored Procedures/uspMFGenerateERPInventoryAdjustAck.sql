CREATE PROCEDURE dbo.uspMFGenerateERPInventoryAdjustAck (
	@strCompanyLocation NVARCHAR(6) = NULL
	,@ysnUpdateFeedStatus BIT = 1
	,@intTransactionTypeId INT
	)
AS
BEGIN TRY
	SET NOCOUNT ON

	DECLARE @ErrMsg NVARCHAR(MAX)
		,@strXML NVARCHAR(MAX) = ''
		,@intTrxSequenceNo BIGINT
		,@dtmCreatedDate DATETIME
		,@strCreatedBy NVARCHAR(50)
		,@strLotNo NVARCHAR(50)
		,@strStorageUnit NVARCHAR(50)
		,@strAdjustmentNo NVARCHAR(50)
		,@intStatusId INT
		,@strStatusText NVARCHAR(MAX)
		,@intInventoryAdjustmentAckId INT
	DECLARE @tblOutput TABLE (
		intRowNo INT IDENTITY(1, 1)
		,intId INT
		,strXML NVARCHAR(MAX)
		,strInfo1 NVARCHAR(50)
		,strInfo2 NVARCHAR(50)
		)
	DECLARE @tblIPInventoryAdjustmentAck TABLE (intInventoryAdjustmentAckId INT)

	IF NOT EXISTS (
			SELECT *
			FROM dbo.tblIPInventoryAdjustmentAck
			Where ysnInProgress is NULL
			)
	BEGIN
		RETURN
	END

	INSERT INTO @tblIPInventoryAdjustmentAck (intInventoryAdjustmentAckId)
	SELECT TOP 20 intInventoryAdjustmentAckId
	FROM dbo.tblIPInventoryAdjustmentAck
	WHERE strCompanyLocation = @strCompanyLocation
	AND ysnInProgress is NULL

	SELECT @intInventoryAdjustmentAckId = MIN(intInventoryAdjustmentAckId)
	FROM @tblIPInventoryAdjustmentAck

	IF @intInventoryAdjustmentAckId IS NULL
	BEGIN
		RETURN
	END

	UPDATE dbo.tblIPInventoryAdjustmentAck
	SET ysnInProgress =  1
	WHERE intInventoryAdjustmentAckId IN (
			SELECT PS.intInventoryAdjustmentAckId
			FROM @tblIPInventoryAdjustmentAck PS
			)

	WHILE @intInventoryAdjustmentAckId IS NOT NULL
	BEGIN
		SELECT @intTrxSequenceNo = NULL
			,@strCompanyLocation = NULL
			,@dtmCreatedDate = NULL
			,@strCreatedBy = NULL
			,@strLotNo = NULL
			,@strStorageUnit = NULL
			,@strAdjustmentNo = NULL
			,@intStatusId = NULL
			,@strStatusText = NULL

		SELECT @intTrxSequenceNo = intTrxSequenceNo
			,@strCompanyLocation = strCompanyLocation
			,@dtmCreatedDate = dtmCreatedDate
			,@strCreatedBy = strCreatedBy
			,@strLotNo = strLotNo
			,@strStorageUnit = strStorageUnit
			,@strAdjustmentNo = strAdjustmentNo
			,@intStatusId = intStatusId
			,@strStatusText = strStatusText
		FROM dbo.tblIPInventoryAdjustmentAck
		WHERE intInventoryAdjustmentAckId = @intInventoryAdjustmentAckId

		SELECT @strXML = @strXML + '<header TrxSequenceNo="' + ltrim(@intTrxSequenceNo) + '">'
			+'<TrxSequenceNo>'+ltrim(@intTrxSequenceNo) +'</TrxSequenceNo>'
			+'<CompanyLocation>'+@strCompanyLocation +'</CompanyLocation>'
			+'<CreatedDate>'+CONVERT(VARCHAR(33), GetDate(), 126) +'</CreatedDate>'
			+'<CreatedBy>'+	@strCreatedBy +'</CreatedBy>'
			+'<LotNo>'+	@strLotNo  +'</LotNo>'
			+'<StorageUnit>'+	@strStorageUnit   +'</StorageUnit>'
			+'<AdjustmentNo>'+	IsNULL(@strAdjustmentNo,'')    +'</AdjustmentNo>'
			+'<StatusId>'+	ltrim(@intStatusId)     +'</StatusId>'
			+'<StatusText>'+	dbo.fnEscapeXML(IsNULL(@strStatusText,''))     +'</StatusText>'
			+ '</header>'
		IF @ysnUpdateFeedStatus = 1
		BEGIN
			IF @intStatusId = 1
			BEGIN
				--Move to Achive
				INSERT INTO dbo.tblIPInventoryAdjustmentArchive (
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
					,strAdjustmentNo
				FROM dbo.tblIPInventoryAdjustmentAck
				WHERE intInventoryAdjustmentAckId = @intInventoryAdjustmentAckId

				DELETE
				FROM dbo.tblIPInventoryAdjustmentAck
				WHERE intInventoryAdjustmentAckId = @intInventoryAdjustmentAckId
			END
			ELSE
			BEGIN
				INSERT INTO dbo.tblIPInventoryAdjustmentError (
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
					,strStatusText
				FROM tblIPInventoryAdjustmentAck
				WHERE intInventoryAdjustmentAckId = @intInventoryAdjustmentAckId

				DELETE
				FROM dbo.tblIPInventoryAdjustmentAck
				WHERE intInventoryAdjustmentAckId = @intInventoryAdjustmentAckId
			END
		END

		NextPO:

		SELECT @intInventoryAdjustmentAckId = MIN(intInventoryAdjustmentAckId)
		FROM @tblIPInventoryAdjustmentAck
		WHERE intInventoryAdjustmentAckId > @intInventoryAdjustmentAckId
	END

	IF @strXML <> ''
	BEGIN
		SELECT @strXML = '<root><data>' + @strXML + '</data></root>'

		INSERT INTO @tblOutput (
			intId
			,strXML
			,strInfo1
			,strInfo2
			)
		VALUES (
			@intInventoryAdjustmentAckId
			,@strXML
			,ISNULL(@strLotNo, '')
			,ISNULL(@strStorageUnit, '')
			)
	END

	UPDATE dbo.tblIPInventoryAdjustmentAck
	SET ysnInProgress = NULL
	WHERE intInventoryAdjustmentAckId IN (
			SELECT PS.intInventoryAdjustmentAckId
			FROM @tblIPInventoryAdjustmentAck PS
			)
		AND ysnInProgress=1

	SELECT IsNULL(intId, '0') AS id
		,IsNULL(strXML, '') AS strXml
		,IsNULL(strInfo1, '') AS strInfo1
		,IsNULL(strInfo2, '') AS strInfo2
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
