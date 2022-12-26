CREATE PROCEDURE dbo.uspIPGenerateSAPLeadTimeBulk_EK (
	@ysnUpdateFeedStatus BIT = 1
	,@limit INT = 0
	,@offset INT = 0
	)
AS
BEGIN TRY
	SET NOCOUNT ON

	DECLARE @ErrMsg NVARCHAR(MAX)
	DECLARE @strXML NVARCHAR(MAX) = ''
		,@strRootXML NVARCHAR(MAX) = ''
		,@strFinalXML NVARCHAR(MAX) = ''
		,@dtmCurrentDate DATETIME
		,@intDocID INT
		,@intTotalRows INT
	DECLARE @tblIPLeadTimeSAPPreStage TABLE (intLeadTimePreStageId INT)

	SELECT @dtmCurrentDate = CONVERT(CHAR, GETDATE(), 101)

	IF NOT EXISTS (
			SELECT 1
			FROM dbo.tblIPLeadTimeSAPPreStage WITH (NOLOCK)
			WHERE dtmProcessedDate = @dtmCurrentDate
			)
	BEGIN
		DELETE
		FROM tblIPLeadTimeSAPPreStage

		INSERT INTO tblIPLeadTimeSAPPreStage (
			intLeadTimePreStageId
			,intLocationLeadTimeId
			,intStatusId
			,dtmProcessedDate
			)
		SELECT intLeadTimePreStageId = ROW_NUMBER() OVER (
				ORDER BY (
						SELECT NULL
						)
				)
			,intLocationLeadTimeId = LLT.intLocationLeadTimeId
			,intStatusId = NULL
			,dtmProcessedDate = @dtmCurrentDate
		FROM dbo.tblMFLocationLeadTime LLT WITH (NOLOCK)
	END

	IF NOT EXISTS (
			SELECT 1
			FROM dbo.tblIPLeadTimeSAPPreStage WITH (NOLOCK)
			WHERE intStatusId IS NULL
			)
	BEGIN
		RETURN
	END

	DECLARE @tmp INT

	SELECT @tmp = strValue
	FROM tblIPSAPIDOCTag
	WHERE strMessageType = 'Lead Time'
		AND strTag = 'Count'

	IF ISNULL(@tmp, 0) = 0
		SELECT @tmp = 100

	IF @limit > @tmp
	BEGIN
		SELECT @limit = @tmp
	END

	DELETE
	FROM @tblIPLeadTimeSAPPreStage

	SELECT @intDocID = NULL

	INSERT INTO @tblIPLeadTimeSAPPreStage (intLeadTimePreStageId)
	SELECT TOP (@limit) LTS.intLeadTimePreStageId
	FROM dbo.tblIPLeadTimeSAPPreStage LTS WITH (NOLOCK)
	WHERE intStatusId IS NULL

	SELECT @strXML = @strXML
		+ '<Header>'
		+ '<Origin>' + ISNULL(C.strISOCode, '') + '</Origin>'
		+ '<BuyingCenter>' + ISNULL(CL.strOregonFacilityNumber, '') + '</BuyingCenter>'
		+ '<StorageLocation>' + LTRIM(SUBSTRING(ISNULL(SL.strSubLocationName, ''), CHARINDEX('/', SL.strSubLocationName) + 1, LEN(SL.strSubLocationName))) + '</StorageLocation>'
		+ '<Channel>' + ISNULL(MZ.strMarketZoneCode, '') + '</Channel>'
		+ '<PlantCode>' + ISNULL(CL1.strOregonFacilityNumber, '') + '</PlantCode>'
		+ '<PlantDescription>' + ISNULL(CL1.strLocationName, '') + '</PlantDescription>'
		+ '<FromShippingUnit>' + ISNULL(DC.strCity, '') + '</FromShippingUnit>'
		+ '<FromShipUnitDesc>' + ISNULL(DC.strVAT, '') + '</FromShipUnitDesc>'
		+ '<ToShippingUnit>' + ISNULL(AC.strCity, '') + '</ToShippingUnit>'
		+ '<ToShipUnitDesc>' + ISNULL(AC.strVAT, '') + '</ToShipUnitDesc>'
		+ '<P_S>' + LTRIM(CONVERT(NUMERIC(18, 0), ISNULL(LLT.dblPurchaseToShipment, 0))) + '</P_S>'
		+ '<P_P>' + LTRIM(CONVERT(NUMERIC(18, 0), ISNULL(LLT.dblPortToPort, 0))) + '</P_P>'
		+ '<P_MU>' + LTRIM(CONVERT(NUMERIC(18, 0), ISNULL(LLT.dblPortToMixingUnit, 0))) + '</P_MU>'
		+ '<MU_B>' + LTRIM(CONVERT(NUMERIC(18, 0), ISNULL(LLT.dblMUToAvailableForBlending, 0))) + '</MU_B>'
		+ '<SendDate>' + ISNULL(CONVERT(VARCHAR(33), @dtmCurrentDate, 126), '') + '</SendDate>'
		+ '</Header>'
	FROM @tblIPLeadTimeSAPPreStage LTS
	JOIN tblIPLeadTimeSAPPreStage LTS1 WITH (NOLOCK) ON LTS1.intLeadTimePreStageId = LTS.intLeadTimePreStageId
	JOIN tblMFLocationLeadTime LLT WITH (NOLOCK) ON LLT.intLocationLeadTimeId = LTS1.intLocationLeadTimeId
	JOIN tblSMCountry C WITH (NOLOCK) ON C.intCountryID = LLT.intOriginId
	JOIN tblSMCompanyLocation CL WITH (NOLOCK) ON CL.intCompanyLocationId = LLT.intBuyingCenterId
	JOIN tblSMCompanyLocationSubLocation SL WITH (NOLOCK) ON SL.intCompanyLocationSubLocationId = LLT.intReceivingStorageLocation
	JOIN tblSMCompanyLocation CL1 WITH (NOLOCK) ON CL1.intCompanyLocationId = SL.intCompanyLocationId
	JOIN tblARMarketZone MZ WITH (NOLOCK) ON MZ.intMarketZoneId = LLT.intChannelId
	JOIN tblSMCity DC WITH (NOLOCK) ON DC.intCityId = LLT.intPortOfDispatchId
	JOIN tblSMCity AC WITH (NOLOCK) ON AC.intCityId = LLT.intPortOfArrivalId

	IF @strXML <> ''
	BEGIN
		SELECT @intDocID = ISNULL(MAX(intLeadTimePreStageId), 1)
		FROM @tblIPLeadTimeSAPPreStage

		SELECT @intTotalRows = COUNT(1)
		FROM tblIPLeadTimeSAPPreStage

		SELECT @strRootXML = '<DocNo>' + LTRIM(@intDocID) + '</DocNo>'

		SELECT @strRootXML += '<MsgType>Lead_Time</MsgType>'

		SELECT @strRootXML += '<Sender>iRely</Sender>'

		SELECT @strRootXML += '<Receiver>SAP</Receiver>'

		SELECT @strRootXML += '<TotalRows>' + LTRIM(@intTotalRows) + '</TotalRows>'

		SELECT @strFinalXML = '<root>' + @strRootXML + @strXML + '</root>'
	END

	UPDATE tblIPLeadTimeSAPPreStage
	SET intStatusId = 1
	WHERE intLeadTimePreStageId IN (
			SELECT intLeadTimePreStageId
			FROM @tblIPLeadTimeSAPPreStage
			)
		AND intStatusId IS NULL

	SELECT ISNULL(1, '0') AS id
		,ISNULL(@strFinalXML, '') AS strXml
		,'' AS strInfo1
		,'' AS strInfo2
		,'' AS strOnFailureCallbackSql
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
