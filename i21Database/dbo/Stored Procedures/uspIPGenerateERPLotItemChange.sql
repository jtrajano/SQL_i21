CREATE PROCEDURE dbo.uspIPGenerateERPLotItemChange (
	@strCompanyLocation NVARCHAR(6) = NULL
	,@ysnUpdateFeedStatus BIT = 1
	)
AS
BEGIN TRY
	SET NOCOUNT ON

	DECLARE @ErrMsg NVARCHAR(MAX)
		,@strXML NVARCHAR(MAX) = ''
		,@intLotItemChangeFeedId INT
	DECLARE @tblOutput AS TABLE (
		intRowNo INT IDENTITY(1, 1)
		,intLotItemChangeFeedId INT
		,strRowState NVARCHAR(50)
		,strXML NVARCHAR(MAX)
		,strInfo1 NVARCHAR(50)
		,strInfo2 NVARCHAR(50)
		)
	DECLARE @tblIPLotItemChangeFeed TABLE (intLotItemChangeFeedId INT)

	IF NOT EXISTS (
			SELECT *
			FROM dbo.tblIPLotItemChangeFeed
			WHERE intStatusId IS NULL
			)
	BEGIN
		RETURN
	END

	DECLARE @tmp INT

	SELECT @tmp = strValue
	FROM tblIPSAPIDOCTag
	WHERE strMessageType = 'Lot Item Change'
		AND strTag = 'Count'

	IF ISNULL(@tmp, 0) = 0
		SELECT @tmp = 50

	INSERT INTO @tblIPLotItemChangeFeed (intLotItemChangeFeedId)
	SELECT TOP (@tmp) intLotItemChangeFeedId
	FROM dbo.tblIPLotItemChangeFeed
	WHERE strCompanyLocation = @strCompanyLocation
	AND intStatusId IS NULL

	SELECT @intLotItemChangeFeedId = MIN(intLotItemChangeFeedId)
	FROM @tblIPLotItemChangeFeed

	IF @intLotItemChangeFeedId IS NULL
	BEGIN
		RETURN
	END

	UPDATE dbo.tblIPLotItemChangeFeed
	SET intStatusId = - 1
	WHERE intLotItemChangeFeedId IN (
			SELECT PS.intLotItemChangeFeedId
			FROM @tblIPLotItemChangeFeed PS
			)

	WHILE @intLotItemChangeFeedId IS NOT NULL
	BEGIN
		SELECT @strXML = @strXML + '<header id="' + ltrim(@intLotItemChangeFeedId) + '">'  
		 +'<TrxSequenceNo>'+ltrim(@intLotItemChangeFeedId) +'</TrxSequenceNo>'  
		 +'<CompanyLocation>'+strCompanyLocation +'</CompanyLocation>'  
		 +'<ActionId>1</ActionId>'  
		 +'<CreatedDate>'+CONVERT(VARCHAR(33), dtmCreatedDate, 126) +'</CreatedDate>'  
		 +'<CreatedByUser>'+ strCreatedByUser +'</CreatedByUser>'  
		 +'<TransactionTypeId>15</TransactionTypeId>' 
		 +'<StorageLocation>'+ IsNULL(strStorageLocation,'')  +'</StorageLocation>'  
		 +'<NewItemNo>'+ IsNULL(strNewItemNo,'')  +'</NewItemNo>'  
		  +'<OldItemNo>'+ IsNULL(strOldItemNo,'')  +'</OldItemNo>'  
		 +'<MotherLotNo>'+ IsNULL(strMotherLotNo,'')  +'</MotherLotNo>'  
		 +'<LotNo>'+ IsNULL(strLotNo,'')  +'</LotNo>'  
		 +'<StorageUnit>'+ IsNULL(strStorageUnit,'')  +'</StorageUnit>'  
		 +'<ReasonCode>'+ dbo.fnEscapeXML(IsNULL(strReasonCode,''))  +'</ReasonCode>'  
		 +'<Notes>'+ dbo.fnEscapeXML(IsNULL(strNotes,''))  +'</Notes>'  
		  +'<AdjustmentNo>'+ IsNULL(strAdjustmentNo,'')  +'</AdjustmentNo>'  
		FROM tblIPLotItemChangeFeed
		WHERE intLotItemChangeFeedId = @intLotItemChangeFeedId

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
			UPDATE dbo.tblIPLotItemChangeFeed
			SET intStatusId = 2
				,strMessage = 'Success'
			WHERE intLotItemChangeFeedId = @intLotItemChangeFeedId
		END

		NextPO:

		SELECT @intLotItemChangeFeedId = MIN(intLotItemChangeFeedId)
		FROM @tblIPLotItemChangeFeed
		WHERE intLotItemChangeFeedId > @intLotItemChangeFeedId
	END

	IF @strXML <> ''
	BEGIN
		SELECT @strXML = '<root><data>' + @strXML + '</data></root>'

		INSERT INTO @tblOutput (
			intLotItemChangeFeedId
			,strXML
			,strInfo1
			,strInfo2
			)
		VALUES (
			@intLotItemChangeFeedId
			,@strXML
			,ISNULL('', '')
			,ISNULL('', '')
			)
	END

	UPDATE dbo.tblIPLotItemChangeFeed
	SET intStatusId = NULL
	WHERE intLotItemChangeFeedId IN (
			SELECT PS.intLotItemChangeFeedId
			FROM @tblIPLotItemChangeFeed PS
			)
		AND intStatusId = - 1

	SELECT IsNULL(intLotItemChangeFeedId, '0') AS id
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
