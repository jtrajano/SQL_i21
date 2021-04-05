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
		,@strFinalXML NVARCHAR(MAX) = ''
	DECLARE @intContractFeedId INT
		,@intContractDetailId INT

	DECLARE @strQuantityUOM NVARCHAR(50)
		,@strDefaultCurrency NVARCHAR(40)
		,@intCurrencyId INT
		,@intUnitMeasureId INT
		,@intItemId INT
		,@intItemUOMId INT
	DECLARE @intActionId INT


	--DECLARE @tblOutput AS TABLE (
	--	intRowNo INT IDENTITY(1, 1)
	--	,intContractFeedId INT
	--	,strRowState NVARCHAR(50)
	--	,strXML NVARCHAR(MAX)
	--	,strContractNumber NVARCHAR(100)
	--	,strERPPONumber NVARCHAR(100)
	--	)
	DECLARE @tblCTContractFeed TABLE (intContractFeedId INT)

	IF NOT EXISTS (
			SELECT 1
			FROM tblCTContractFeed
			WHERE intStatusId IS NULL
			)
	BEGIN
		RETURN
	END

	DELETE
	FROM @tblCTContractFeed

	INSERT INTO @tblCTContractFeed (intContractFeedId)
	SELECT TOP 50 CF.intContractFeedId
	FROM tblCTContractFeed CF
	JOIN tblCTContractHeader CH ON CH.intContractHeaderId = CF.intContractHeaderId
		AND CF.intStatusId IS NULL
		AND CH.intContractTypeId = 2
	JOIN tblCTContractDetail CD ON CD.intContractDetailId = CF.intContractDetailId
	JOIN tblSMCompanyLocation CL ON CL.intCompanyLocationId = CD.intCompanyLocationId
		AND CL.strLotOrigin = @strCompanyLocation

	SELECT @intContractFeedId = MIN(intContractFeedId)
	FROM @tblCTContractFeed

	IF @intContractFeedId IS NULL
	BEGIN
		RETURN
	END

	UPDATE tblCTContractFeed
	SET intStatusId = - 1
	WHERE intContractFeedId IN (
			SELECT intContractFeedId
			FROM @tblCTContractFeed
			)

	WHILE @intContractFeedId IS NOT NULL
	BEGIN
		SELECT @strRowState = NULL
			,@strUserName = NULL
			,@strError = ''
			,@strXML = ''

		SELECT @intContractDetailId = NULL

		SELECT @strQuantityUOM = NULL
			,@strDefaultCurrency = NULL
			,@intCurrencyId = NULL
			,@intUnitMeasureId = NULL
			,@intItemId = NULL
			,@intItemUOMId = NULL

		SELECT @intActionId = NULL

		SELECT @intContractDetailId = intContractDetailId
			,@strRowState = strRowState
			,@strUserName = strCreatedBy
			,@intItemId = intItemId
		FROM dbo.tblCTContractFeed
		WHERE intContractFeedId = @intContractFeedId

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



		--IF ISNULL(@strCustomerPrefix, '') = ''
		--BEGIN
		--	SELECT @strError = @strError + 'Customer Prefix cannot be blank. '
		--END


		IF @strError <> ''
		BEGIN
			UPDATE dbo.tblCTContractFeed
			SET strMessage = @strError
				,intStatusId = 1
			WHERE intContractFeedId = @intContractFeedId

			GOTO NextPO
		END

		BEGIN
			IF @strRowState <> 'Added'
				--AND IsNULL(@strERPCONumber, '') = ''
			BEGIN
				GOTO NextPO
			END

			-- If previous feed is waiting for acknowledgement then do not send the current feed
			IF EXISTS (
					SELECT TOP 1 1
					FROM tblCTContractFeed CF
					JOIN tblCTContractDetail CD ON CD.intContractDetailId = CF.intContractDetailId
						AND CD.intContractDetailId = @intContractDetailId
					JOIN tblSMCompanyLocation CL ON CL.intCompanyLocationId = CD.intCompanyLocationId
						AND CL.strLotOrigin = @strCompanyLocation
						AND CF.intContractFeedId < @intContractFeedId
						AND intStatusId = 2
					ORDER BY CF.intContractFeedId DESC
					)
			BEGIN
				GOTO NextPO
			END

			IF NOT EXISTS (
					SELECT 1
					FROM tblCTContractDetail
					WHERE intContractDetailId = @intContractDetailId
					)
			BEGIN
				UPDATE dbo.tblCTContractFeed
				SET strMessage = 'Contract Seq not available. '
					,intStatusId = 1
				WHERE intContractFeedId = @intContractFeedId

				GOTO NextPO
			END
			ELSE
			BEGIN
				SELECT @intActionId = (
						CASE 
							WHEN @strRowState = 'Added'
								THEN 1
							WHEN @strRowState = 'Modified'
								THEN 2
							ELSE 3
							END
						)
			END

			SELECT @strXML = '<header id="' + LTRIM(@intContractFeedId) + '">'

			SELECT @strXML += '<TrxSequenceNo>' + LTRIM(@intContractFeedId) + '</TrxSequenceNo>'

			SELECT @strXML += '<CompanyLocation>' + LTRIM(@strCompanyLocation) + '</CompanyLocation>'

			SELECT @strXML += '<ActionId>' + LTRIM(@intActionId) + '</ActionId>'

			SELECT @strXML += '<CreatedDate>' + CONVERT(VARCHAR(33), GetDate(), 126) + '</CreatedDate>'

			SELECT @strXML += '<CreatedByUser>' + @strUserName + '</CreatedByUser>'



			IF IsNULL(@strXML, '') <> ''
			BEGIN
				SELECT @strFinalXML = @strFinalXML + @strXML + '</header>'


			END
			ELSE
			BEGIN
				UPDATE dbo.tblCTContractFeed
				SET strMessage = 'XML not available. '
					,intStatusId = 1
				WHERE intContractFeedId = @intContractFeedId

				GOTO NextPO
			END
		END

		IF @ysnUpdateFeedStatus = 1
		BEGIN
			UPDATE tblCTContractFeed
			SET intStatusId = 2
				,strMessage = NULL
			WHERE intContractFeedId = @intContractFeedId
		END

		NextPO:

		SELECT @intContractFeedId = MIN(intContractFeedId)
		FROM @tblCTContractFeed
		WHERE intContractFeedId > @intContractFeedId
	END

	IF @strFinalXML <> ''
	BEGIN
		SELECT @strFinalXML = '<root><data>' + @strFinalXML + '</data></root>'

		--DELETE
		--FROM @tblOutput

		--INSERT INTO @tblOutput (
		--	intContractFeedId
		--	,strRowState
		--	,strXML
		--	,strContractNumber
		--	,strERPPONumber
		--	)
		--VALUES (
		--	@intContractFeedId
		--	,@strRowState
		--	,@strFinalXML
		--	,ISNULL(@strContractNumber, '')
		--	,ISNULL(@strERPCONumber, '')
		--	)
	END

	UPDATE tblCTContractFeed
	SET intStatusId = NULL
	WHERE intContractFeedId IN (
			SELECT intContractFeedId
			FROM @tblCTContractFeed
			)
		AND intStatusId = - 1

	--SELECT IsNULL(intContractFeedId, '0') AS id
	--	,IsNULL(strXML, '') AS strXml
	--	,IsNULL(strContractNumber, '') AS strInfo1
	--	,IsNULL(strERPPONumber, '') AS strInfo2
	--	,'' AS strOnFailureCallbackSql
	--FROM @tblOutput
	--ORDER BY intRowNo
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
