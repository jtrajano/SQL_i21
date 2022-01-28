CREATE PROCEDURE dbo.uspIPGenerateERPLotSplit (
	@strCompanyLocation NVARCHAR(6) = NULL
	,@ysnUpdateFeedStatus BIT = 1
	)
AS
BEGIN TRY
	SET NOCOUNT ON

	DECLARE @ErrMsg NVARCHAR(MAX)
		,@strXML NVARCHAR(MAX) = ''
		,@intLotSplitFeedId INT
	DECLARE @tblOutput AS TABLE (
		intRowNo INT IDENTITY(1, 1)
		,intLotSplitFeedId INT
		,strRowState NVARCHAR(50)
		,strXML NVARCHAR(MAX)
		,strInfo1 NVARCHAR(50)
		,strInfo2 NVARCHAR(50)
		)
	DECLARE @tblIPLotSplitFeed TABLE (intLotSplitFeedId INT)

	IF NOT EXISTS (
			SELECT *
			FROM dbo.tblIPLotSplitFeed
			WHERE intStatusId IS NULL
			)
	BEGIN
		RETURN
	END

	INSERT INTO @tblIPLotSplitFeed (intLotSplitFeedId)
	SELECT TOP 20 intLotSplitFeedId
	FROM dbo.tblIPLotSplitFeed
	WHERE strCompanyLocation = @strCompanyLocation
	AND intStatusId IS NULL

	SELECT @intLotSplitFeedId = MIN(intLotSplitFeedId)
	FROM @tblIPLotSplitFeed

	IF @intLotSplitFeedId IS NULL
	BEGIN
		RETURN
	END

	UPDATE dbo.tblIPLotSplitFeed
	SET intStatusId = - 1
	WHERE intLotSplitFeedId IN (
			SELECT PS.intLotSplitFeedId
			FROM @tblIPLotSplitFeed PS
			)

	WHILE @intLotSplitFeedId IS NOT NULL
	BEGIN
		SELECT @strXML = @strXML + '<header id="' + ltrim(@intLotSplitFeedId) + '">'  
		 +'<TrxSequenceNo>'+ltrim(@intLotSplitFeedId) +'</TrxSequenceNo>'  
		 +'<CompanyLocation>'+strCompanyLocation +'</CompanyLocation>'  
		 +'<ActionId>1</ActionId>'  
		 +'<CreatedDate>'+CONVERT(VARCHAR(33), dtmCreatedDate, 126) +'</CreatedDate>'  
		 +'<CreatedByUser>'+ strCreatedByUser +'</CreatedByUser>'  
		 +'<TransactionTypeId>17</TransactionTypeId>' 
		 +'<StorageLocation>'+ IsNULL(strStorageLocation,'')  +'</StorageLocation>'  
		 +'<ItemNo>'+ IsNULL(strItemNo,'')  +'</ItemNo>'  
		 +'<MotherLotNo>'+ IsNULL(strMotherLotNo,'')  +'</MotherLotNo>'  
		 +'<LotNo>'+ IsNULL(strLotNo,'')  +'</LotNo>'  
		 +'<StorageUnit>'+ IsNULL(strStorageUnit,'')  +'</StorageUnit>'  
		 +'<SplitStorageLocation>'+ IsNULL(strSplitStorageLocation,'')  +'</SplitStorageLocation>'  
		 +'<SplitStorageUnit>'+ IsNULL(strSplitStorageUnit,'')  +'</SplitStorageUnit>'  
		 +'<SplitLotNo>'+ IsNULL(strSplitLotNo,'')  +'</SplitLotNo>'  
		 +'<Quantity>'+ ltrim(dblQuantity)  +'</Quantity>'  
		 +'<QuantityUOM>'+ IsNULL(strQuantityUOM,'')  +'</QuantityUOM>'  
		 +'<ReasonCode>'+ dbo.fnEscapeXML(IsNULL(strReasonCode,''))  +'</ReasonCode>'  
		 +'<Notes>'+ dbo.fnEscapeXML(IsNULL(strNotes,''))  +'</Notes>'  
		FROM tblIPLotSplitFeed
		WHERE intLotSplitFeedId = @intLotSplitFeedId

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
			UPDATE dbo.tblIPLotSplitFeed
			SET intStatusId = 2
				,strMessage = 'Success'
			WHERE intLotSplitFeedId = @intLotSplitFeedId
		END

		NextPO:

		SELECT @intLotSplitFeedId = MIN(intLotSplitFeedId)
		FROM @tblIPLotSplitFeed
		WHERE intLotSplitFeedId > @intLotSplitFeedId
	END

	IF @strXML <> ''
	BEGIN
		SELECT @strXML = '<root><data>' + @strXML + '</data></root>'

		INSERT INTO @tblOutput (
			intLotSplitFeedId
			,strXML
			,strInfo1
			,strInfo2
			)
		VALUES (
			@intLotSplitFeedId
			,@strXML
			,ISNULL('', '')
			,ISNULL('', '')
			)
	END

	UPDATE dbo.tblIPLotSplitFeed
	SET intStatusId = NULL
	WHERE intLotSplitFeedId IN (
			SELECT PS.intLotSplitFeedId
			FROM @tblIPLotSplitFeed PS
			)
		AND intStatusId = - 1

	SELECT IsNULL(intLotSplitFeedId, '0') AS id
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
