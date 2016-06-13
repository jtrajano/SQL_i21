--EXEC uspQMReportCOAHeaderDetail @intInventoryShipmentItemLotId = 1231,@intLotId=2588,@ysnTestReport=0;
CREATE PROCEDURE uspQMReportCOAHeaderDetail
     @intInventoryShipmentItemLotId INT
	,@intLotId INT
	,@ysnTestReport BIT = 0
AS
SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

BEGIN TRY
	DECLARE @ErrMsg NVARCHAR(MAX)
	DECLARE @ysnEnableParentLot BIT
	DECLARE @intProductTypeId INT
	DECLARE @intProductValueId INT
	DECLARE @intNumberofDecimalPlaces INT
		,@strComment NVARCHAR(MAX)
	DECLARE @intSampleId INT
		,@strSampleNumber NVARCHAR(MAX)
		,@dtmSampleReceivedDate DATETIME
		,@dtmSamplingEndDate DATETIME
		,@dtmTestingStartDate DATETIME
		,@dtmTestingEndDate DATETIME
		,@strSamplingMethod NVARCHAR(MAX)

	SET @intProductTypeId = 6
	SET @intProductValueId = @intLotId

	SELECT TOP 1 @ysnEnableParentLot = ISNULL(ysnEnableParentLot, 0)
	FROM dbo.tblQMCompanyPreference

	IF @ysnEnableParentLot = 1
	BEGIN
		SET @intProductTypeId = 11

		SELECT @intProductValueId = intParentLotId
		FROM dbo.tblICLot
		WHERE intLotId = @intLotId
	END

	SELECT TOP 1 @intSampleId = MAX(S.intSampleId)
	FROM dbo.tblQMSample S
	JOIN dbo.tblQMTestResult TR ON TR.intSampleId = S.intSampleId
		AND S.intSampleStatusId = 3
		AND S.intProductTypeId = @intProductTypeId
		AND S.intProductValueId = @intProductValueId

	SELECT @strSampleNumber = strSampleNumber
		,@dtmSampleReceivedDate = CONVERT(NVARCHAR, dtmSampleReceivedDate, 101)
		,@dtmSamplingEndDate = CONVERT(NVARCHAR, dtmSamplingEndDate, 101)
		,@dtmTestingStartDate = CONVERT(NVARCHAR, dtmTestingStartDate, 101)
		,@dtmTestingEndDate = CONVERT(NVARCHAR, dtmTestingEndDate, 101)
		,@strSamplingMethod = strSamplingMethod
	FROM dbo.tblQMSample
	WHERE intSampleId = @intSampleId

	SELECT TOP 1 @intNumberofDecimalPlaces = intNumberofDecimalPlaces
	FROM dbo.tblQMCompanyPreference

	SELECT TOP 1 @strComment = W.strComment
	FROM dbo.tblMFWorkOrderProducedLot WPL
	JOIN dbo.tblMFWorkOrder W ON W.intWorkOrderId = WPL.intWorkOrderId
		AND WPL.intLotId = @intLotId

	SELECT DISTINCT CL.strAddress
		,(CL.strCity + ' , ' + CL.strStateProvince) AS strShipperAddress
		,CL.strCountry
		,CL.strPhone
		,CL.strFax
		,CL.strLocationName AS strShipper
		,C.strDescription AS strProduct
		,I.strDescription AS strGrade
		,EL.strLocationName AS strBuyer
		,(EL.strCity + ' , ' + EL.strCountry) AS strDestination
		,CM.strVersionNo
		,CM.dtmEffectiveDate
		,CM.strRevisionNo
		,CM.strCommentTR
		,CM.strCommentCOA
		,CM.strDisclaimer
		,S.strBOLNumber AS strContractNo
		,S.strReferenceNumber AS strContainerNo
		,L.strLotNumber
		,CONVERT(NVARCHAR(25), CONVERT(NUMERIC(38, 3), SIL.dblQuantityShipped)) + ' ' + UPPER(UOM.strUnitMeasure) AS strNoOfUnits
		,UPPER(UOM.strUnitMeasure) AS strNoOfUnitsUOM
		,CONVERT(NVARCHAR(25), CONVERT(NUMERIC(38, 3), (
					SIL.dblQuantityShipped * (
						CASE 
							WHEN L.dblWeightPerQty = 0
								THEN 1
							ELSE L.dblWeightPerQty
							END
						)
					))) + ' ' + (
			CASE 
				WHEN L.dblWeightPerQty = 0
					THEN UPPER(UOM.strUnitMeasure)
				ELSE UPPER(UOM1.strUnitMeasure)
				END
			) AS strWeight
		,(
			CASE 
				WHEN L.dblWeightPerQty = 0
					THEN UPPER(UOM.strUnitMeasure)
				ELSE UPPER(UOM1.strUnitMeasure)
				END
			) AS strWeightUOM
		,ISNULL(@strComment, '') AS strWOComment
		,@strSampleNumber AS strCertificateNo
		,CASE 
			WHEN @ysnTestReport = 0
				THEN @strSamplingMethod
			ELSE CM.strSamplingMethod
			END AS strSamplingMethod
		,CONVERT(NVARCHAR(20), @dtmSampleReceivedDate, 101) + ' - ' + CONVERT(NVARCHAR(20), @dtmSamplingEndDate, 101) AS dtmSamplingDuration
		,CONVERT(NVARCHAR(20), @dtmTestingStartDate, 101) + ' - ' + CONVERT(NVARCHAR(20), @dtmTestingEndDate, 101) AS dtmTestingDuration
	FROM dbo.tblICInventoryShipmentItemLot SIL
	JOIN dbo.tblICInventoryShipmentItem SI ON SI.intInventoryShipmentItemId = SIL.intInventoryShipmentItemId
		AND SIL.intInventoryShipmentItemLotId = @intInventoryShipmentItemLotId
	JOIN dbo.tblICInventoryShipment S ON S.intInventoryShipmentId = SI.intInventoryShipmentId
	JOIN dbo.tblICLot L ON L.intLotId = SIL.intLotId
	JOIN dbo.tblICItem I ON I.intItemId = L.intItemId
	JOIN dbo.tblQMCOAMapping CM ON CM.intItemId = I.intItemId
	LEFT JOIN tblICItemUOM IUOM ON IUOM.intItemUOMId = L.intItemUOMId
	LEFT JOIN tblICUnitMeasure UOM ON UOM.intUnitMeasureId = IUOM.intUnitMeasureId
	LEFT JOIN tblICItemUOM IUOM1 ON IUOM1.intItemUOMId = L.intWeightUOMId
	LEFT JOIN tblICUnitMeasure UOM1 ON UOM1.intUnitMeasureId = IUOM1.intUnitMeasureId
	LEFT JOIN dbo.tblICCategory C ON C.intCategoryId = I.intCategoryId
	LEFT JOIN dbo.tblSMCompanyLocation CL ON CL.intCompanyLocationId = S.intShipFromLocationId
	LEFT JOIN dbo.tblEMEntityLocation EL ON EL.intEntityLocationId = S.intShipToLocationId
END TRY

BEGIN CATCH
	SET @ErrMsg = 'uspQMReportCOAHeaderDetail - ' + ERROR_MESSAGE()

	RAISERROR (
			@ErrMsg
			,18
			,1
			,'WITH NOWAIT'
			)
END CATCH
