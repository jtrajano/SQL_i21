CREATE PROCEDURE dbo.uspIPGenerateSAPPrice_EK (@ysnUpdateFeedStatus BIT = 1)
AS
BEGIN TRY
	SET NOCOUNT ON

	DECLARE @ErrMsg NVARCHAR(MAX)
	DECLARE @strXML NVARCHAR(MAX) = ''
		,@strItemXML NVARCHAR(MAX) = ''
		,@strRootXML NVARCHAR(MAX) = ''
		,@strFinalXML NVARCHAR(MAX) = ''
		,@dtmCurrentDate DATETIME
		,@intDocID INT
		,@intItemPreStageId INT
	DECLARE @tblIPItemPreStage TABLE (intItemPreStageId INT)
	DECLARE @intItemId INT
		,@intProductId INT

	SELECT @dtmCurrentDate = CONVERT(CHAR, GETDATE(), 101)

	DECLARE @tmp INT

	SELECT @tmp = strValue
	FROM tblIPSAPIDOCTag
	WHERE strMessageType = 'Price Simulation'
		AND strTag = 'Count'

	IF ISNULL(@tmp, 0) = 0
		SELECT @tmp = 100

	DELETE
	FROM @tblIPItemPreStage

	SELECT @intDocID = NULL

	INSERT INTO @tblIPItemPreStage (intItemPreStageId)
	SELECT DISTINCT TOP (@tmp) I.intItemPreStageId
	FROM dbo.tblIPItemPreStage I WITH (NOLOCK)
	WHERE I.intStatusId IS NULL

	SELECT @intItemPreStageId = MIN(intItemPreStageId)
	FROM @tblIPItemPreStage

	IF @intItemPreStageId IS NULL
	BEGIN
		RETURN
	END

	WHILE @intItemPreStageId IS NOT NULL
	BEGIN
		SELECT @strXML = ''

		SELECT @intItemId = NULL
			,@intProductId = NULL

		SELECT @intItemId = S.intItemId
		FROM dbo.tblIPItemPreStage S WITH (NOLOCK)
		WHERE S.intItemPreStageId = @intItemPreStageId

		SELECT TOP 1 @intProductId = P.intProductId
		FROM dbo.tblQMProduct P
		JOIN dbo.tblQMProductControlPoint PC ON PC.intProductId = P.intProductId
		WHERE P.intProductTypeId = 2 -- Item
			AND P.intProductValueId = @intItemId
			--AND PC.intSampleTypeId = @intSampleTypeId
			AND P.ysnActive = 1
		ORDER BY P.intProductId DESC

		SELECT @strXML = @strXML
			+ '<Header>'
			+ '<Revision>' + ISNULL(I.strGTIN, '') + '</Revision>'
			+ '<Origin>' + ISNULL(C.strISOCode, '') + '</Origin>'
			+ '<SubCluster>' + ISNULL(Region.strDescription, '') + '</SubCluster>'
			+ '<TeaClusterCode>' + ISNULL(Certification.strCertificationName, '') + '</TeaClusterCode>'
			+ '<ManufactureType>' + ISNULL(ProductType.strDescription, '') + '</ManufactureType>'
			+ '<TeaColourCode>' + ISNULL(LEFT(Season.strDescription, 1), '') + '</TeaColourCode>'
			+ '<LeafSizeCode>' + ISNULL(Brand.strBrandCode, '') + '</LeafSizeCode>'
			+ '<ModellingLeafStyle>' + ISNULL(VG.strName, '') + '</ModellingLeafStyle>'
			+ '<DesignerItem>' + LTRIM(ISNULL(I.ysnProducePartialPacking, '')) + '</DesignerItem>'
			+ '<TeaItem>' + ISNULL(I.strItemNo, '') + '</TeaItem>'
			+ '<TeaItemName>' + ISNULL(I.strDescription, '') + '</TeaItemName>'
			+ '<ColourName>' + ISNULL(Season.strDescription, '') + '</ColourName>'
			+ '<TeaGroup>' + ISNULL(Brand.strBrandCode, '') + ISNULL(Region.strDescription, '') + ISNULL(VG.strName, '') + '</TeaGroup>'
			+ '<CreateDate>' + ISNULL(CONVERT(VARCHAR(33), @dtmCurrentDate, 126), '') + '</CreateDate>'
			+ '<ManufactureTypeName>' + ISNULL(Certification.strCertificationCode, '') + '</ManufactureTypeName>'
			+ '<ClusterName>' + ISNULL(Certification.strIssuingOrganization, '') + '</ClusterName>'
			+ '<ClusterType>' + ISNULL(Certification.strCertificationIdName, '') + '</ClusterType>'
			+ '<QualityGroup>' + ISNULL(attribute3.strAttribute3, '') + '</QualityGroup>'
			+ '<MaterialCode>' + ISNULL(I.strModelNo, '') + '</MaterialCode>'
			+ '<LeafSizeDescription>' + ISNULL(Brand.strBrandName, '') + '</LeafSizeDescription>'
			+ '<AllocationCode>' + ISNULL(attribute1.strAttribute1, '') + '</AllocationCode>'
			+ '<LeafStyleDescription>' + ISNULL(VG.strDescription, '') + '</LeafStyleDescription>'
		FROM dbo.tblICItem I WITH (NOLOCK)
		JOIN dbo.tblIPItemPreStage S WITH (NOLOCK) ON S.intItemId = I.intItemId
			AND I.intItemId = @intItemId
		LEFT JOIN dbo.tblICCommodityAttribute Origin WITH (NOLOCK) ON Origin.intCommodityAttributeId = I.intOriginId
		LEFT JOIN dbo.tblSMCountry C WITH (NOLOCK) ON C.intCountryID = Origin.intCountryID
		LEFT JOIN dbo.tblICCommodityAttribute Region WITH (NOLOCK) ON Region.intCommodityAttributeId = I.intRegionId
		LEFT JOIN dbo.tblICCertification Certification WITH (NOLOCK) ON Certification.intCertificationId = I.intCertificationId
		LEFT JOIN dbo.tblICCommodityAttribute ProductType WITH (NOLOCK) ON ProductType.intCommodityAttributeId = I.intProductTypeId
		LEFT JOIN dbo.tblICCommodityAttribute Season WITH (NOLOCK) ON Season.intCommodityAttributeId = I.intSeasonId
		LEFT JOIN dbo.tblICBrand Brand WITH (NOLOCK) ON Brand.intBrandId = I.intBrandId
		LEFT JOIN dbo.tblCTValuationGroup VG WITH (NOLOCK) ON VG.intValuationGroupId = I.intValuationGroupId
		LEFT JOIN dbo.tblICCommodityProductLine ProductLine WITH (NOLOCK) ON ProductLine.intCommodityProductLineId = I.intProductLineId
		LEFT JOIN dbo.tblICCommodityAttribute Class WITH (NOLOCK) ON Class.intCommodityAttributeId = I.intClassVarietyId
		LEFT JOIN dbo.tblICManufacturer Manufacturer WITH (NOLOCK) ON Manufacturer.intManufacturerId = I.intManufacturerId
		LEFT JOIN dbo.tblICCommodityAttribute3 attribute3 WITH (NOLOCK) ON attribute3.intCommodityAttributeId3 = I.intCommodityAttributeId3
		LEFT JOIN dbo.tblICCommodityAttribute1 attribute1 WITH (NOLOCK) ON attribute1.intCommodityAttributeId1 = I.intCommodityAttributeId1

		IF ISNULL(@strXML, '') <> ''
		BEGIN
			SELECT @strItemXML += @strXML + '</Header>'
		END

		SELECT @intItemPreStageId = MIN(intItemPreStageId)
		FROM @tblIPItemPreStage
		WHERE intItemPreStageId > @intItemPreStageId
	END

	IF @strItemXML <> ''
	BEGIN
		SELECT @intDocID = ISNULL(MAX(intItemPreStageId), 1)
		FROM @tblIPItemPreStage

		SELECT @strRootXML = '<DocNo>' + LTRIM(@intDocID) + '</DocNo>'

		SELECT @strRootXML += '<MsgType>Price_Simulation</MsgType>'

		SELECT @strRootXML += '<Sender>iRely</Sender>'

		SELECT @strRootXML += '<Receiver>SAP</Receiver>'

		SELECT @strFinalXML = '<root>' + @strRootXML + @strItemXML + '</root>'
	END

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
