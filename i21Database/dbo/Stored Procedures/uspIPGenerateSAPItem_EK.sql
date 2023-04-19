CREATE PROCEDURE dbo.uspIPGenerateSAPItem_EK (
	@ysnUpdateFeedStatus BIT = 1
	,@limit INT = 0
	,@offset INT = 0
	)
AS
BEGIN TRY
	SET NOCOUNT ON

	DECLARE @ErrMsg NVARCHAR(MAX)
	DECLARE @strXML NVARCHAR(MAX) = ''
		,@strLineXML NVARCHAR(MAX) = ''
		,@strLocationXML NVARCHAR(MAX) = ''
		,@strItemXML NVARCHAR(MAX) = ''
		,@strRootXML NVARCHAR(MAX) = ''
		,@strFinalXML NVARCHAR(MAX) = ''
		,@dtmCurrentDate DATETIME
		,@intDocID INT
		,@intItemPreStageId INT
		,@intTotalRows INT
	DECLARE @tblIPItemPreStage TABLE (intItemPreStageId INT)
	DECLARE @intItemId INT
		,@intProductId INT
		,@dblTMinValue NUMERIC(18, 6)
		,@dblTMaxValue NUMERIC(18, 6)
		,@dblTPinpointValue NUMERIC(18, 6)
		,@dblHMinValue NUMERIC(18, 6)
		,@dblHMaxValue NUMERIC(18, 6)
		,@dblHPinpointValue NUMERIC(18, 6)
		,@dblIMinValue NUMERIC(18, 6)
		,@dblIMaxValue NUMERIC(18, 6)
		,@dblIPinpointValue NUMERIC(18, 6)
		,@dblMMinValue NUMERIC(18, 6)
		,@dblMMaxValue NUMERIC(18, 6)
		,@dblMPinpointValue NUMERIC(18, 6)
		,@dblAMinValue NUMERIC(18, 6)
		,@dblAMaxValue NUMERIC(18, 6)
		,@dblAPinpointValue NUMERIC(18, 6)

	SELECT @dtmCurrentDate = CONVERT(CHAR, GETDATE(), 101)

	IF NOT EXISTS (
			SELECT 1
			FROM dbo.tblIPItemPreStage WITH (NOLOCK)
			WHERE dtmProcessedDate = @dtmCurrentDate
			)
	BEGIN
		DELETE
		FROM tblIPItemPreStage

		INSERT INTO tblIPItemPreStage (
			intItemPreStageId
			,intItemId
			,intStatusId
			,dtmProcessedDate
			)
		SELECT intItemPreStageId = ROW_NUMBER() OVER (
				ORDER BY (
						SELECT NULL
						)
				)
			,intItemId = I.intItemId
			,intStatusId = NULL
			,dtmProcessedDate = @dtmCurrentDate
		FROM dbo.tblICItem I WITH (NOLOCK)
		JOIN dbo.tblICCategory C WITH (NOLOCK) ON C.intCategoryId = I.intCategoryId
			AND C.strCategoryCode = 'Raw Tea'
			AND ISNULL(I.strShortName, '') <> ''
	END

	IF NOT EXISTS (
			SELECT 1
			FROM dbo.tblIPItemPreStage WITH (NOLOCK)
			WHERE intItemPreStageId BETWEEN @offset + 1
					AND @limit + @offset
			)
	BEGIN
		RETURN
	END

	DECLARE @tmp INT

	SELECT @tmp = strValue
	FROM tblIPSAPIDOCTag
	WHERE strMessageType = 'Tea Lingo Item'
		AND strTag = 'Count'

	IF ISNULL(@tmp, 0) = 0
		SELECT @tmp = 100

	IF @limit > @tmp
	BEGIN
		SELECT @limit = @tmp
	END

	DELETE
	FROM @tblIPItemPreStage

	SELECT @intDocID = NULL

	INSERT INTO @tblIPItemPreStage (intItemPreStageId)
	SELECT I.intItemPreStageId
	FROM dbo.tblIPItemPreStage I WITH (NOLOCK)
	WHERE I.intItemPreStageId BETWEEN @offset + 1
			AND @limit + @offset

	SELECT @intItemPreStageId = MIN(intItemPreStageId)
	FROM @tblIPItemPreStage

	IF @intItemPreStageId IS NULL
	BEGIN
		RETURN
	END

	WHILE @intItemPreStageId IS NOT NULL
	BEGIN
		SELECT @strXML = ''
			,@strLineXML = ''
			,@strLocationXML = ''

		SELECT @intItemId = NULL
			,@intProductId = NULL
			,@dblTMinValue = NULL
			,@dblTMaxValue = NULL
			,@dblTPinpointValue = NULL
			,@dblHMinValue = NULL
			,@dblHMaxValue = NULL
			,@dblHPinpointValue = NULL
			,@dblIMinValue = NULL
			,@dblIMaxValue = NULL
			,@dblIPinpointValue = NULL
			,@dblMMinValue = NULL
			,@dblMMaxValue = NULL
			,@dblMPinpointValue = NULL
			,@dblAMinValue = NULL
			,@dblAMaxValue = NULL
			,@dblAPinpointValue = NULL

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

		IF ISNULL(@intProductId, 0) <> 0
		BEGIN
			SELECT @dblTMinValue = PPV.dblMinValue
				,@dblTMaxValue = PPV.dblMaxValue
				,@dblTPinpointValue = PPV.dblPinpointValue
			FROM dbo.tblQMProductProperty PP
			JOIN dbo.tblQMProductPropertyValidityPeriod AS PPV ON PPV.intProductPropertyId = PP.intProductPropertyId
			JOIN dbo.tblQMProperty AS PRT ON PRT.intPropertyId = PP.intPropertyId
				AND PRT.strPropertyName = 'Taste'
			WHERE PP.intProductId = @intProductId

			SELECT @dblHMinValue = PPV.dblMinValue
				,@dblHMaxValue = PPV.dblMaxValue
				,@dblHPinpointValue = PPV.dblPinpointValue
			FROM dbo.tblQMProductProperty PP
			JOIN dbo.tblQMProductPropertyValidityPeriod AS PPV ON PPV.intProductPropertyId = PP.intProductPropertyId
			JOIN dbo.tblQMProperty AS PRT ON PRT.intPropertyId = PP.intPropertyId
				AND PRT.strPropertyName = 'Hue'
			WHERE PP.intProductId = @intProductId

			SELECT @dblIMinValue = PPV.dblMinValue
				,@dblIMaxValue = PPV.dblMaxValue
				,@dblIPinpointValue = PPV.dblPinpointValue
			FROM dbo.tblQMProductProperty PP
			JOIN dbo.tblQMProductPropertyValidityPeriod AS PPV ON PPV.intProductPropertyId = PP.intProductPropertyId
			JOIN dbo.tblQMProperty AS PRT ON PRT.intPropertyId = PP.intPropertyId
				AND PRT.strPropertyName = 'Intensity'
			WHERE PP.intProductId = @intProductId

			SELECT @dblMMinValue = PPV.dblMinValue
				,@dblMMaxValue = PPV.dblMaxValue
				,@dblMPinpointValue = PPV.dblPinpointValue
			FROM dbo.tblQMProductProperty PP
			JOIN dbo.tblQMProductPropertyValidityPeriod AS PPV ON PPV.intProductPropertyId = PP.intProductPropertyId
			JOIN dbo.tblQMProperty AS PRT ON PRT.intPropertyId = PP.intPropertyId
				AND PRT.strPropertyName = 'Mouth feel'
			WHERE PP.intProductId = @intProductId

			SELECT @dblAMinValue = PPV.dblMinValue
				,@dblAMaxValue = PPV.dblMaxValue
				,@dblAPinpointValue = PPV.dblPinpointValue
			FROM dbo.tblQMProductProperty PP
			JOIN dbo.tblQMProductPropertyValidityPeriod AS PPV ON PPV.intProductPropertyId = PP.intProductPropertyId
			JOIN dbo.tblQMProperty AS PRT ON PRT.intPropertyId = PP.intPropertyId
				AND PRT.strPropertyName = 'Appearance'
			WHERE PP.intProductId = @intProductId
		END

		SELECT @strXML = @strXML
			+ '<Header>'
			+ '<Revision>' + ISNULL(I.strGTIN, '') + '</Revision>'
			+ '<Origin>' + ISNULL(C.strISOCode, '') + '</Origin>'
			+ '<SubCluster>' + ISNULL(Region.strDescription, '') + '</SubCluster>'
			+ '<TeaClusterCode>' + ISNULL(attribute2.strAttribute2, '') + '</TeaClusterCode>'
			+ '<ManufactureType>' + ISNULL(ProductType.strDescription, '') + '</ManufactureType>'
			+ '<TeaColourCode>' + ISNULL(LEFT(Season.strDescription, 1), '') + '</TeaColourCode>'
			+ '<LeafSizeCode>' + ISNULL(Brand.strBrandCode, '') + '</LeafSizeCode>'
			+ '<ModellingLeafStyle>' + ISNULL(VG.strName, '') + '</ModellingLeafStyle>'
			+ '<DesignerItem>' + LTRIM(CASE WHEN ISNULL(I.ysnProducePartialPacking, 0) = 0 THEN 'NO' ELSE 'YES' END) + '</DesignerItem>'
			+ '<TeaItem>' + ISNULL(I.strItemNo, '') + '</TeaItem>'
			+ '<TeaItemName>' + ISNULL(I.strDescription, '') + '</TeaItemName>'
			+ '<ColourName>' + ISNULL(Season.strDescription, '') + '</ColourName>'
			+ '<TeaGroup>' + ISNULL(Brand.strBrandCode, '') + ISNULL(Region.strDescription, '') + '</TeaGroup>'
			+ '<CreateDate>' + ISNULL(CONVERT(VARCHAR(33), @dtmCurrentDate, 112), '') + '</CreateDate>'
			+ '<TastePinpoint>' + LTRIM(CONVERT(NUMERIC(18, 2), ISNULL(@dblTPinpointValue, 0))) + '</TastePinpoint>'
			+ '<HuePinpoint>' + LTRIM(CONVERT(NUMERIC(18, 2), ISNULL(@dblHPinpointValue, 0))) + '</HuePinpoint>'
			+ '<IntensityPinpoint>' + LTRIM(CONVERT(NUMERIC(18, 2), ISNULL(@dblIPinpointValue, 0))) + '</IntensityPinpoint>'
			+ '<MouthfeelPinpoint>' + LTRIM(CONVERT(NUMERIC(18, 2), ISNULL(@dblMPinpointValue, 0))) + '</MouthfeelPinpoint>'
			+ '<AppearancePinpoint>' + LTRIM(CONVERT(NUMERIC(18, 2), ISNULL(@dblAPinpointValue, 0))) + '</AppearancePinpoint>'
			+ '<AvgBulkDensity>' + LTRIM(CONVERT(NUMERIC(18, 2), ISNULL(I.dblBlendWeight, 0))) + '</AvgBulkDensity>'
			+ '<AvgPackWeight>' + LTRIM(CONVERT(NUMERIC(18, 2), ISNULL(I.dblNetWeight, 0))) + '</AvgPackWeight>'
			+ '<TFSActive>' + ISNULL(ProductLine.strDescription, '1') + '</TFSActive>'
			+ '<FeedStockGroupCode>' + ISNULL(I.strShortName, '') + '</FeedStockGroupCode>'
			+ '<CombinedConstraints>' + ISNULL(Class.strDescription, '') + '</CombinedConstraints>'
			+ '<OriginDescription>' + ISNULL(Origin.strDescription, '') + '</OriginDescription>'
			+ '<LeafSizeCategory>' + ISNULL(Manufacturer.strManufacturer, '') + '</LeafSizeCategory>'
			+ '<MouthfeelLow>' + LTRIM(CONVERT(NUMERIC(18, 2), ISNULL(@dblMMinValue, 0))) + '</MouthfeelLow>'
			+ '<MouthfeelUpper>' + LTRIM(CONVERT(NUMERIC(18, 2), ISNULL(@dblMMaxValue, 0))) + '</MouthfeelUpper>'
			+ '<HueLower>' + LTRIM(CONVERT(NUMERIC(18, 2), ISNULL(@dblHMinValue, 0))) + '</HueLower>'
			+ '<HueUpper>' + LTRIM(CONVERT(NUMERIC(18, 2), ISNULL(@dblHMaxValue, 0))) + '</HueUpper>'
			+ '<TasteLower>' + LTRIM(CONVERT(NUMERIC(18, 2), ISNULL(@dblTMinValue, 0))) + '</TasteLower>'
			+ '<TasteUpper>' + LTRIM(CONVERT(NUMERIC(18, 2), ISNULL(@dblTMaxValue, 0))) + '</TasteUpper>'
			+ '<IntensityLower>' + LTRIM(CONVERT(NUMERIC(18, 2), ISNULL(@dblIMinValue, 0))) + '</IntensityLower>'
			+ '<IntensityUpper>' + LTRIM(CONVERT(NUMERIC(18, 2), ISNULL(@dblIMaxValue, 0))) + '</IntensityUpper>'
			+ '<AppearanceLower>' + LTRIM(CONVERT(NUMERIC(18, 2), ISNULL(@dblAMinValue, 0))) + '</AppearanceLower>'
			+ '<AppearanceUpper>' + LTRIM(CONVERT(NUMERIC(18, 2), ISNULL(@dblAMaxValue, 0))) + '</AppearanceUpper>'
			+ '<ManufactureTypeName>' + ISNULL(Certification.strCertificationCode, '') + '</ManufactureTypeName>'
			+ '<ClusterName>' + ISNULL(attribute4.strAttribute4, '') + '</ClusterName>'
			+ '<ClusterType>' + ISNULL(attribute4.strAttribute4, '') + '</ClusterType>'
			+ '<QualityGroup>' + ISNULL(attribute3.strAttribute3, '') + '</QualityGroup>'
			+ '<MaterialCode></MaterialCode>'
			+ '<LeafSizeDescription>' + ISNULL(I.strModelNo, '') + '</LeafSizeDescription>'
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
		LEFT JOIN dbo.tblICCommodityAttribute2 attribute2 WITH (NOLOCK) ON attribute2.intCommodityAttributeId2 = I.intCommodityAttributeId2
		LEFT JOIN dbo.tblICCommodityAttribute4 attribute4 WITH (NOLOCK) ON attribute4.intCommodityAttributeId4 = I.intCommodityAttributeId4

		SELECT @strLineXML = @strLineXML
			+ '<Line>'
			+ '<UOM>' + ISNULL(UOM.strUnitMeasure, '') + '</UOM>'
			+ '<UnitQty>' + LTRIM(CONVERT(NUMERIC(18, 6), ISNULL(IUOM.dblUnitQty, 0))) + '</UnitQty>'
			+ '<IsStockUOM>' + LTRIM(ISNULL(IUOM.ysnStockUnit, '')) + '</IsStockUOM>'
			+ '</Line>'
		FROM dbo.tblICItemUOM IUOM WITH (NOLOCK)
		JOIN dbo.tblICUnitMeasure UOM WITH (NOLOCK) ON UOM.intUnitMeasureId = IUOM.intUnitMeasureId
			AND IUOM.intItemId = @intItemId

		SELECT @strLocationXML = @strLocationXML
			+ '<Location>'
			+ '<LocationName>' + ISNULL(CL.strLocationName, '') + '</LocationName>'
			+ '</Location>'
		FROM dbo.tblICItemLocation IL WITH (NOLOCK)
		JOIN dbo.tblSMCompanyLocation CL WITH (NOLOCK) ON CL.intCompanyLocationId = IL.intLocationId
			AND IL.intItemId = @intItemId

		IF ISNULL(@strXML, '') <> ''
		BEGIN
			SELECT @strItemXML += @strXML + @strLineXML + @strLocationXML + '</Header>'
		END

		SELECT @intItemPreStageId = MIN(intItemPreStageId)
		FROM @tblIPItemPreStage
		WHERE intItemPreStageId > @intItemPreStageId
	END

	IF @strItemXML <> ''
	BEGIN
		SELECT @intDocID = ISNULL(MAX(intItemPreStageId), 1)
		FROM @tblIPItemPreStage

		SELECT @intTotalRows = COUNT(1)
		FROM tblIPItemPreStage

		SELECT @strRootXML = '<DocNo>' + LTRIM(@intDocID) + '</DocNo>'

		SELECT @strRootXML += '<MsgType>Tea_Lingo</MsgType>'

		SELECT @strRootXML += '<Sender>iRely</Sender>'

		SELECT @strRootXML += '<Receiver>ICRON</Receiver>'

		SELECT @strRootXML += '<TotalRows>' + LTRIM(@intTotalRows) + '</TotalRows>'

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
