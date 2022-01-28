CREATE PROCEDURE dbo.uspIPGenerateERPLotMerge (
	@strCompanyLocation NVARCHAR(6) = NULL
	,@ysnUpdateFeedStatus BIT = 1
	)
AS
BEGIN TRY
	SET NOCOUNT ON

	DECLARE @ErrMsg NVARCHAR(MAX)
		,@strXML NVARCHAR(MAX) = ''
		,@intLotMergeFeedId INT
	DECLARE @tblOutput AS TABLE (
		intRowNo INT IDENTITY(1, 1)
		,intLotMergeFeedId INT
		,strRowState NVARCHAR(50)
		,strXML NVARCHAR(MAX)
		,strInfo1 NVARCHAR(50)
		,strInfo2 NVARCHAR(50)
		)
	DECLARE @tblIPLotMergeFeed TABLE (intLotMergeFeedId INT)

	IF NOT EXISTS (
			SELECT *
			FROM dbo.tblIPLotMergeFeed
			WHERE intStatusId IS NULL
			)
	BEGIN
		RETURN
	END

	INSERT INTO @tblIPLotMergeFeed (intLotMergeFeedId)
	SELECT TOP 20 intLotMergeFeedId
	FROM dbo.tblIPLotMergeFeed
	WHERE strCompanyLocation = @strCompanyLocation

	SELECT @intLotMergeFeedId = MIN(intLotMergeFeedId)
	FROM @tblIPLotMergeFeed

	IF @intLotMergeFeedId IS NULL
	BEGIN
		RETURN
	END

	UPDATE dbo.tblIPLotMergeFeed
	SET intStatusId = - 1
	WHERE intLotMergeFeedId IN (
			SELECT PS.intLotMergeFeedId
			FROM @tblIPLotMergeFeed PS
			)

	WHILE @intLotMergeFeedId IS NOT NULL
	BEGIN
		SELECT @strXML = @strXML + '<header id="' + ltrim(@intLotMergeFeedId) + '">'  
		 +'<TrxSequenceNo>'+ltrim(@intLotMergeFeedId) +'</TrxSequenceNo>'  
		 +'<CompanyLocation>'+strCompanyLocation +'</CompanyLocation>'  
		 +'<ActionId>1</ActionId>'  
		 +'<CreatedDate>'+CONVERT(VARCHAR(33), dtmCreatedDate, 126) +'</CreatedDate>'  
		 +'<CreatedByUser>'+ strCreatedByUser +'</CreatedByUser>'  
		 +'<TransactionTypeId>19</TransactionTypeId>' 
		 +'<StorageLocation>'+ IsNULL(strStorageLocation,'')  +'</StorageLocation>'  
		 +'<ItemNo>'+ IsNULL(strItemNo,'')  +'</ItemNo>'  
		 +'<MotherLotNo>'+ IsNULL(strMotherLotNo,'')  +'</MotherLotNo>'  
		 +'<LotNo>'+ IsNULL(strLotNo,'')  +'</LotNo>'  
		 +'<StorageUnit>'+ IsNULL(strStorageUnit,'')  +'</StorageUnit>'  
		 +'<DestinationStorageLocation>'+ IsNULL(strDestinationStorageLocation,'')  +'</DestinationStorageLocation>'  
		 +'<DestinationStorageUnit>'+ IsNULL(strDestinationStorageUnit,'')  +'</DestinationStorageUnit>'  
		 +'<DestinationLotNo>'+ IsNULL(strDestinationLotNo,'')  +'</DestinationLotNo>'  
		 +'<Quantity>'+ ltrim(dblQuantity)  +'</Quantity>'  
		 +'<QuantityUOM>'+ IsNULL(strQuantityUOM,'')  +'</QuantityUOM>'  
		 +'<ReasonCode>'+ dbo.fnEscapeXML(IsNULL(strReasonCode,''))  +'</ReasonCode>'  
		 +'<Notes>'+ dbo.fnEscapeXML(IsNULL(strNotes,''))  +'</Notes>'  
		FROM tblIPLotMergeFeed
		WHERE intLotMergeFeedId = @intLotMergeFeedId

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
			UPDATE dbo.tblIPLotMergeFeed
			SET intStatusId = 2
				,strMessage = 'Success'
			WHERE intLotMergeFeedId = @intLotMergeFeedId
		END

		NextPO:

		SELECT @intLotMergeFeedId = MIN(intLotMergeFeedId)
		FROM @tblIPLotMergeFeed
		WHERE intLotMergeFeedId > @intLotMergeFeedId
	END

	IF @strXML <> ''
	BEGIN
		SELECT @strXML = '<root><data>' + @strXML + '</data></root>'

		INSERT INTO @tblOutput (
			intLotMergeFeedId
			,strXML
			,strInfo1
			,strInfo2
			)
		VALUES (
			@intLotMergeFeedId
			,@strXML
			,ISNULL('', '')
			,ISNULL('', '')
			)
	END

	UPDATE dbo.tblIPLotMergeFeed
	SET intStatusId = NULL
	WHERE intLotMergeFeedId IN (
			SELECT PS.intLotMergeFeedId
			FROM @tblIPLotMergeFeed PS
			)
		AND intStatusId = - 1

	SELECT IsNULL(intLotMergeFeedId, '0') AS id
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
