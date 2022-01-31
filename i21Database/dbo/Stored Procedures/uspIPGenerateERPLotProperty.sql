CREATE PROCEDURE dbo.uspIPGenerateERPLotProperty (
	@strCompanyLocation NVARCHAR(6) = NULL
	,@ysnUpdateFeedStatus BIT = 1
	)
AS
BEGIN TRY
	SET NOCOUNT ON

	DECLARE @ErrMsg NVARCHAR(MAX)
		,@strXML NVARCHAR(MAX) = ''
		,@intLotPropertyFeedId INT
	DECLARE @tblOutput AS TABLE (
		intRowNo INT IDENTITY(1, 1)
		,intLotPropertyFeedId INT
		,strRowState NVARCHAR(50)
		,strXML NVARCHAR(MAX)
		,strInfo1 NVARCHAR(50)
		,strInfo2 NVARCHAR(50)
		)
	DECLARE @tblIPLotPropertyFeed TABLE (intLotPropertyFeedId INT)

	IF NOT EXISTS (
			SELECT *
			FROM dbo.tblIPLotPropertyFeed
			WHERE intStatusId IS NULL
			)
	BEGIN
		RETURN
	END

	DECLARE @tmp INT

	SELECT @tmp = strValue
	FROM tblIPSAPIDOCTag
	WHERE strMessageType = 'Lot Property'
		AND strTag = 'Count'

	IF ISNULL(@tmp, 0) = 0
		SELECT @tmp = 50

	INSERT INTO @tblIPLotPropertyFeed (intLotPropertyFeedId)
	SELECT TOP (@tmp) intLotPropertyFeedId
	FROM dbo.tblIPLotPropertyFeed
	WHERE strCompanyLocation = @strCompanyLocation
	AND intStatusId IS NULL

	SELECT @intLotPropertyFeedId = MIN(intLotPropertyFeedId)
	FROM @tblIPLotPropertyFeed

	IF @intLotPropertyFeedId IS NULL
	BEGIN
		RETURN
	END

	UPDATE dbo.tblIPLotPropertyFeed
	SET intStatusId = - 1
	WHERE intLotPropertyFeedId IN (
			SELECT PS.intLotPropertyFeedId
			FROM @tblIPLotPropertyFeed PS
			)

	WHILE @intLotPropertyFeedId IS NOT NULL
	BEGIN
		SELECT @strXML = @strXML + '<header id="' + ltrim(@intLotPropertyFeedId) + '">'  
		 +'<TrxSequenceNo>'+ltrim(@intLotPropertyFeedId) +'</TrxSequenceNo>'  
		 +'<CompanyLocation>'+strCompanyLocation +'</CompanyLocation>'  
		 +'<ActionId>1</ActionId>'  
		 +'<CreatedDate>'+CONVERT(VARCHAR(33), dtmCreatedDate, 126) +'</CreatedDate>'  
		 +'<TransactionTypeId>'+ ltrim(intTransactionTypeId) +'</TransactionTypeId>'  
		  --+'<StorageLocation>'+ IsNULL(strStorageLocation,'')  +'</StorageLocation>'  
		 +'<StorageLocation>'+ IsNULL(strStorageLocation,'')  +'</StorageLocation>'  
		 +'<ItemNo>'+ IsNULL(strItemNo,'')  +'</ItemNo>'  
		 +'<MotherLotNo>'+ IsNULL(strMotherLotNo,'')  +'</MotherLotNo>'  
		 +'<LotNo>'+ IsNULL(strLotNo,'')  +'</LotNo>'  
		 +'<StorageUnit>'+ IsNULL(strStorageUnit,'')  +'</StorageUnit>'  
		 +'<AdjustmentNo>'+ IsNULL(strAdjustmentNo,'')  +'</AdjustmentNo>'  
		 +'<NewExpiryDate>'+ IsNULL(convert(VARCHAR, dtmNewExpiryDate,112),'')  +'</NewExpiryDate>'  
		 +'<NewStatus>'+ IsNULL(strNewStatus,'')  +'</NewStatus>'  
		 +'<ReasonCode>'+ dbo.fnEscapeXML(IsNULL(strReasonCode,''))  +'</ReasonCode>'  
		 +'<Notes>'+ dbo.fnEscapeXML(IsNULL(strNotes,''))  +'</Notes>'  
		FROM tblIPLotPropertyFeed
		WHERE intLotPropertyFeedId = @intLotPropertyFeedId

		SELECT @strXML = @strXML + '</header>'

		/*  
    Not Processed: NULL  
    In-Progress: -1  
    Internal Error in i21: 1  
    Sent to AX: 2  
    AX 1st Level Failure: 3, AX 1st Level Success: 4  
    AX 2nd Level Failure: 5, AX 2nd Level Success: 6  
   */
		IF @ysnUpdateFeedStatus = 1
		BEGIN
			UPDATE dbo.tblIPLotPropertyFeed
			SET intStatusId = 2
				,strMessage = 'Success'
			WHERE intLotPropertyFeedId = @intLotPropertyFeedId
		END

		NextPO:

		SELECT @intLotPropertyFeedId = MIN(intLotPropertyFeedId)
		FROM @tblIPLotPropertyFeed
		WHERE intLotPropertyFeedId > @intLotPropertyFeedId
	END

	IF @strXML <> ''
	BEGIN
		SELECT @strXML = '<root><data>' + @strXML + '</data></root>'

		INSERT INTO @tblOutput (
			intLotPropertyFeedId
			,strXML
			,strInfo1
			,strInfo2
			)
		VALUES (
			@intLotPropertyFeedId
			,@strXML
			,ISNULL('', '')
			,ISNULL('', '')
			)
	END

	UPDATE dbo.tblIPLotPropertyFeed
	SET intStatusId = NULL
	WHERE intLotPropertyFeedId IN (
			SELECT PS.intLotPropertyFeedId
			FROM @tblIPLotPropertyFeed PS
			)
		AND intStatusId = - 1

	SELECT IsNULL(intLotPropertyFeedId, '0') AS id
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
