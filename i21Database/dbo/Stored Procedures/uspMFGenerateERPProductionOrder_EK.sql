CREATE PROCEDURE uspMFGenerateERPProductionOrder_EK (
	@limit INT = 100
	,@offset INT = 0
	,@ysnUpdateFeedStatus BIT = 1
	)
AS
BEGIN TRY
	SET NOCOUNT ON

	DECLARE @ErrMsg NVARCHAR(MAX)
		,@intUserId INT
		,@intWorkOrderId INT
		,@intWorkOrderPreStageId INT
		,@strRowState NVARCHAR(50)
		,@strXML NVARCHAR(MAX) = ''
		,@strWorkOrderNo NVARCHAR(50)
		,@strERPOrderNo NVARCHAR(50)
		,@strDetailXML NVARCHAR(MAX) = ''
		,@strUserName NVARCHAR(50)
		,@strWorkOrderType NVARCHAR(50)
		,@strSubLocationName NVARCHAR(50)
		,@intSubLocationId INT
		,@dblTaste NUMERIC(18, 6)
		,@dblHue NUMERIC(18, 6)
		,@dblIntensity NUMERIC(18, 6)
		,@dblMouthfeel NUMERIC(18, 6)
		,@dblAppearance NUMERIC(18, 6)
		,@dblMoisture NUMERIC(18, 6)
		,@dblVolume NUMERIC(18, 6)
		,@dblDustLevel NUMERIC(18, 6)
	DECLARE @tblOutput AS TABLE (
		intRowNo INT IDENTITY(1, 1)
		,intWorkOrderId INT
		,strRowState NVARCHAR(50)
		,strXML NVARCHAR(MAX)
		,strWorkOrderNo NVARCHAR(50)
		,strERPOrderNo NVARCHAR(50)
		)
	DECLARE @tblMFWorkOrderPreStage TABLE (intWorkOrderPreStageId INT)

	IF NOT EXISTS (
			Select *
			FROM dbo.tblMFWorkOrderPreStage
			WHERE intStatusId IS NULL
			AND strRowState <>'Deleted'
			)
	BEGIN
		RETURN
	END

	DECLARE @tmp INT
		,@FirstCount INT = 0

	SELECT @tmp = strValue
	FROM tblIPSAPIDOCTag
	WHERE strMessageType = 'Production Order'
		AND strTag = 'Count'

	IF ISNULL(@tmp, 0) = 0
		SELECT @tmp = 100

	IF @limit > @tmp
	BEGIN
		SELECT @limit = @tmp
	END

	INSERT INTO @tblMFWorkOrderPreStage (intWorkOrderPreStageId)
	SELECT TOP (@limit) PS.intWorkOrderPreStageId
	FROM dbo.tblMFWorkOrderPreStage PS
	WHERE PS.intStatusId IS NULL
	AND strRowState <>'Deleted'
	ORDER BY intWorkOrderPreStageId

	SELECT @intWorkOrderPreStageId = MIN(intWorkOrderPreStageId)
	FROM @tblMFWorkOrderPreStage

	IF @intWorkOrderPreStageId IS NULL
	BEGIN
		RETURN
	END

	UPDATE dbo.tblMFWorkOrderPreStage
	SET intStatusId = - 1
	WHERE intWorkOrderPreStageId IN (
			SELECT PS.intWorkOrderPreStageId
			FROM @tblMFWorkOrderPreStage PS
			)

	SELECT @strXML = '<root><DocNo>' + IsNULL(ltrim(@intWorkOrderPreStageId), '') + '</DocNo>' + '<MsgType>BlendSheet</MsgType>' + '<Sender>iRely</Sender>' + '<Receiver>SAP</Receiver>'

	WHILE @intWorkOrderPreStageId IS NOT NULL
	BEGIN
		SELECT @intWorkOrderId = NULL
			,@strRowState = NULL
			,@intUserId = NULL
			,@strUserName = NULL
			,@strERPOrderNo = NULL
			,@strWorkOrderNo = NULL
			,@strWorkOrderType = NULL
			,@strSubLocationName = NULL

		SELECT @intWorkOrderId = intWorkOrderId
			,@strRowState = strRowState
			,@intUserId = intUserId
			,@strUserName = strUserName
			,@strWorkOrderNo = strWorkOrderNo
			,@strWorkOrderType = strWorkOrderType
			,@strSubLocationName = strSubLocationName
		FROM dbo.tblMFWorkOrderPreStage
		WHERE intWorkOrderPreStageId = @intWorkOrderPreStageId

		SELECT @strWorkOrderNo = strWorkOrderNo
			,@strERPOrderNo = strERPOrderNo
			,@intSubLocationId = intSubLocationId
		FROM tblMFWorkOrder
		WHERE intWorkOrderId = @intWorkOrderId

		SELECT @dblTaste = 0

		SELECT @dblHue = 0

		SELECT @dblIntensity = 0

		SELECT @dblMouthfeel = 0

		SELECT @dblAppearance = 0, @dblMoisture=0,@dblVolume=0,@dblDustLevel =0

		SELECT @dblTaste = dblComputedValue
		FROM tblMFWorkOrderRecipeComputation C
		JOIN tblQMProperty P ON P.intPropertyId = C.intPropertyId
		WHERE P.strPropertyName = 'Taste'
		AND intWorkOrderId = @intWorkOrderId

		SELECT @dblHue = dblComputedValue
		FROM tblMFWorkOrderRecipeComputation C
		JOIN tblQMProperty P ON P.intPropertyId = C.intPropertyId
		WHERE P.strPropertyName = 'Hue'
		AND intWorkOrderId = @intWorkOrderId

		SELECT @dblIntensity = dblComputedValue
		FROM tblMFWorkOrderRecipeComputation C
		JOIN tblQMProperty P ON P.intPropertyId = C.intPropertyId
		WHERE P.strPropertyName = 'Intensity'
		AND intWorkOrderId = @intWorkOrderId

		SELECT @dblMouthfeel = dblComputedValue
		FROM tblMFWorkOrderRecipeComputation C
		JOIN tblQMProperty P ON P.intPropertyId = C.intPropertyId
		WHERE P.strPropertyName = 'Mouth feel'
		AND intWorkOrderId = @intWorkOrderId

		SELECT @dblAppearance = dblComputedValue
		FROM tblMFWorkOrderRecipeComputation C
		JOIN tblQMProperty P ON P.intPropertyId = C.intPropertyId
		WHERE P.strPropertyName = 'Appearance'
		AND intWorkOrderId = @intWorkOrderId

		SELECT @dblMoisture = dblComputedValue
		FROM tblMFWorkOrderRecipeComputation C
		JOIN tblQMProperty P ON P.intPropertyId = C.intPropertyId
		WHERE P.strPropertyName = 'Moisture'
		AND intWorkOrderId = @intWorkOrderId

		SELECT @dblVolume = dblComputedValue
		FROM tblMFWorkOrderRecipeComputation C
		JOIN tblQMProperty P ON P.intPropertyId = C.intPropertyId
		WHERE P.strPropertyName = 'Volume'
		AND intWorkOrderId = @intWorkOrderId

		SELECT @dblDustLevel = dblComputedValue
		FROM tblMFWorkOrderRecipeComputation C
		JOIN tblQMProperty P ON P.intPropertyId = C.intPropertyId
		WHERE P.strPropertyName = 'Dust Level'
		AND intWorkOrderId = @intWorkOrderId

		SELECT @strXML = @strXML + '<Header>'
		+ '<Status>'+Case When @strRowState = 'Modified' then 'U' Else 'C' End	  + '</Status>'
		+ '<Plant>' + IsNULL(CL.strVendorRefNoPrefix,'')   + '</Plant>'
		+ '<OrderNo>' + IsNULL(BR.strReferenceNo,'')   + '</OrderNo>' 
			+ '<BlendCode>' + I.strItemNo + '</BlendCode>' 
				+ '<BlendDescription>' + I.strDescription  + '</BlendDescription>' 
				+ '<DateApproved>' + IsNULL(CONVERT(VARCHAR(33), IsNULL(W.dtmApprovedDate,GETDATE()) , 126),'') + '</DateApproved>' 
				+ '<Mixes>' + [dbo].[fnRemoveTrailingZeroes]( BR.dblEstNoOfBlendSheet) + '</Mixes>'
				+ '<Parts>' + [dbo].[fnRemoveTrailingZeroes](ROUND(P.dblTotalPart,3)) + '</Parts>'
				+ '<NetWtPerMix>' + [dbo].[fnRemoveTrailingZeroes](Round(P.dblExpectedWeight/BR.dblEstNoOfBlendSheet,3)) + '</NetWtPerMix>'
				+ '<TotalBlendWt>' + [dbo].[fnRemoveTrailingZeroes](Round(P.dblExpectedWeight,3) ) + '</TotalBlendWt>'
				+ '<Volume>' + IsNULL([dbo].[fnRemoveTrailingZeroes](@dblVolume),0) + '</Volume>'
				+ '<DustLevel>' + IsNULL([dbo].[fnRemoveTrailingZeroes](@dblDustLevel),0) + '</DustLevel>'
				+ '<Moisture>' + IsNULL([dbo].[fnRemoveTrailingZeroes](@dblMoisture),0) + '</Moisture>'
				+ '<T>' + IsNULL([dbo].[fnRemoveTrailingZeroes](@dblTaste ),0) + '</T>'
				+ '<H>' + IsNULL([dbo].[fnRemoveTrailingZeroes](@dblHue ),0) + '</H>'
				+ '<I>' + IsNULL([dbo].[fnRemoveTrailingZeroes](@dblIntensity ),0) + '</I>'
				+ '<M>' + IsNULL([dbo].[fnRemoveTrailingZeroes](@dblMouthfeel ),0) + '</M>'
				+ '<A>' + IsNULL([dbo].[fnRemoveTrailingZeroes](@dblAppearance ),0) + '</A>'
				+ '<V>0</V>'
		FROM dbo.tblMFWorkOrder W
		JOIN dbo.tblICItem I ON I.intItemId = W.intItemId
		JOIN dbo.tblICItemUOM IU ON IU.intItemUOMId = W.intItemUOMId
		JOIN dbo.tblSMCompanyLocation CL ON CL.intCompanyLocationId = W.intLocationId
		JOIN tblMFBlendRequirement BR ON BR.intBlendRequirementId = W.intBlendRequirementId
		OUTER APPLY(SELECT SUM(WI.dblIssuedQuantity/BR.dblEstNoOfBlendSheet) dblTotalPart,Round(SUM(Round(WI.dblQuantity,3)),3) dblExpectedWeight
					FROM dbo.tblMFWorkOrderInputLot WI
					JOIN tblMFBlendRequirement BR ON BR.intBlendRequirementId = W.intBlendRequirementId
					WHERE WI.intWorkOrderId = W.intWorkOrderId) P
		WHERE W.intWorkOrderId = @intWorkOrderId

		SELECT @strDetailXML = ''

		SELECT @strDetailXML = @strDetailXML + '<Line>'
		+ '<WHLoc>' + IsNULL(SL.strName ,'') + '</WHLoc>' 
		+ '<Batch>' + L.strLotNumber   + '</Batch>' 
		+ '<Chop>' + IsNULL(B.strTeaGardenChopInvoiceNumber,'') + '</Chop>' 
		+ '<Mark>' + IsNULL(GM.strGardenMark ,'' ) + '</Mark>' 
		+ '<Grade>'+IsNULL(B.strLeafGrade,'')+'</Grade>' 
		+ '<TeaItem>' +  I.strItemNo + '</TeaItem>' 
		+ '<Material>' + IsNULL(I.strShortName,'' ) + '</Material>' 
		+ '<MaterialDescription>' + I.strDescription  + '</MaterialDescription>' 
		+ '<Origin>'+IsNULL(B.strTeaOrigin,'')+'</Origin>' 
		+ '<Location>' + IsNULL(LTRIM(SUBSTRING(ISNULL(CS.strSubLocationName, ''), CHARINDEX('/', CS.strSubLocationName) + 1, LEN(CS.strSubLocationName))) , '')  + '</Location>' 
		+ '<Parts>' +  [dbo].[fnRemoveTrailingZeroes](Round(WI.dblIssuedQuantity/BR.dblEstNoOfBlendSheet,3)  ) + '</Parts>' 
		+ '<WeightPerPack>' + [dbo].[fnRemoveTrailingZeroes](Round(L.dblWeightPerQty,3) ) + '</WeightPerPack>' 
		+ '<WeightPerMix>' + [dbo].[fnRemoveTrailingZeroes](Round(WI.dblQuantity/BR.dblEstNoOfBlendSheet,3)) + '</WeightPerMix>' 
		+ '<WeightPerBatch>' + [dbo].[fnRemoveTrailingZeroes](Round(WI.dblQuantity,3) ) + '</WeightPerBatch>' 
		+ '<WeightUOM>' + IsNULL(UM.strUnitMeasure,'')  + '</WeightUOM>' 
		+ '<Bags>' + [dbo].[fnRemoveTrailingZeroes](Round(WI.dblIssuedQuantity ,3)) + '</Bags>' 
		+ '<FW>' + IsNULL(WI.strFW,'')  + '</FW>' 
		+ '<UserID>' + US.strUserName  + '</UserID>' 
		+ '<UserName>' + US.strFullName  + '</UserName>' 
		+ '</Line>'
		FROM dbo.tblMFWorkOrderInputLot WI
		JOIN dbo.tblMFLotInventory LI ON LI.intLotId = WI.intLotId
			AND WI.intWorkOrderId = @intWorkOrderId
		JOIN dbo.tblMFBatch B ON B.intBatchId = LI.intBatchId
		JOIN dbo.tblICItem I ON I.intItemId = WI.intItemId
		JOIN dbo.tblICItemUOM IU ON IU.intItemUOMId = WI.intItemUOMId
		JOIN dbo.tblICUnitMeasure UM ON UM.intUnitMeasureId = IU.intUnitMeasureId
		JOIN tblICLot L ON L.intLotId = WI.intLotId
		JOIN tblSMCompanyLocationSubLocation CS ON CS.intCompanyLocationSubLocationId = L.intSubLocationId
		JOIN tblSMUserSecurity US ON US.intEntityId = WI.intCreatedUserId
		JOIN tblMFWorkOrder W ON W.intWorkOrderId = WI.intWorkOrderId
		JOIN tblMFBlendRequirement BR ON BR.intBlendRequirementId = W.intBlendRequirementId
		LEFT JOIN dbo.tblICStorageLocation SL ON SL.intStorageLocationId = WI.intStorageLocationId
		LEFT JOIN dbo.tblQMGardenMark GM ON GM.intGardenMarkId = B.intGardenMarkId

		IF IsNULL(@strDetailXML, '') <> ''
		BEGIN
			SELECT @strXML = @strXML + @strDetailXML + '</Header>'
		END


		IF @ysnUpdateFeedStatus = 1
		BEGIN
			UPDATE dbo.tblMFWorkOrderPreStage
			SET intStatusId = 2
				,strMessage = 'Success'
			WHERE intWorkOrderPreStageId = @intWorkOrderPreStageId
		END

	

		SELECT @intWorkOrderPreStageId = MIN(intWorkOrderPreStageId)
		FROM @tblMFWorkOrderPreStage
		WHERE intWorkOrderPreStageId > @intWorkOrderPreStageId
	END

	IF @strXML <> ''
	BEGIN
		SELECT @strXML =  @strXML + '</root>'

		INSERT INTO @tblOutput (
			intWorkOrderId
			,strRowState
			,strXML
			,strWorkOrderNo
			,strERPOrderNo
			)
		VALUES (
			@intWorkOrderId
			,@strRowState
			,@strXML
			,ISNULL(@strWorkOrderNo, '')
			,ISNULL(@strERPOrderNo, '')
			)
	END

	UPDATE dbo.tblMFWorkOrderPreStage
	SET intStatusId = NULL
	WHERE intWorkOrderPreStageId IN (
			SELECT PS.intWorkOrderPreStageId
			FROM @tblMFWorkOrderPreStage PS
			)
		AND intStatusId = - 1

	SELECT IsNULL(intWorkOrderId, '0') AS id
		,IsNULL(strXML, '') AS strXml
		,IsNULL(strWorkOrderNo, '') AS strInfo1
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
