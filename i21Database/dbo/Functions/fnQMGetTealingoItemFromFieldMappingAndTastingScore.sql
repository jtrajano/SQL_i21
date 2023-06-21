CREATE FUNCTION [dbo].[fnQMGetTealingoItemFromFieldMappingAndTastingScore](
    @intSampleId INT
)
RETURNS INT
AS BEGIN
    DECLARE @intItemId INT

    SELECT TOP 1 @intItemId = ITEM.intItemId
    FROM tblQMSample S
    -- Sustainability / Rain Forest
    LEFT JOIN tblICCommodityProductLine SUSTAINABILITY ON SUSTAINABILITY.intCommodityProductLineId = S.intProductLineId
    -- Origin
    LEFT JOIN (tblICCommodityAttribute CA INNER JOIN tblSMCountry ORIGIN ON ORIGIN.intCountryID = CA.intCountryID) ON CA.intCommodityAttributeId = S.intCountryID
    -- Size
    LEFT JOIN tblICBrand SIZE ON SIZE.intBrandId = S.intBrandId
    -- Style
    LEFT JOIN tblCTValuationGroup STYLE ON STYLE.intValuationGroupId = S.intValuationGroupId
    LEFT JOIN tblICItem ITEM ON ITEM.strItemNo LIKE SIZE.strBrandCode -- Leaf Size
        -- TODO: To update filter once Sub Cluster is provided
        + '%' -- To be updated by sub cluster
        + STYLE.strName -- Leaf Style
        + ORIGIN.strISOCode -- Origin
        + (Case When SUSTAINABILITY.strDescription <> '' Then '-' + LEFT(SUSTAINABILITY.strDescription, 1) Else '' End) -- Rain Forest / Sustainability
    OUTER APPLY dbo.fnQMGetSampleTastingScore(S.intSampleId) STS
    -- Match sample tasting score values with Item template's pinpoint values
    OUTER APPLY (
        SELECT
            [dblAppearance]    = ISNULL(APPEARANCE.dblPinpointValue, 0)
            ,[dblHue]           = ISNULL(HUE.dblPinpointValue, 0)
            ,[dblIntensity]     = ISNULL(INTENSITY.dblPinpointValue, 0)
            ,[dblTaste]         = ISNULL(TASTE.dblPinpointValue, 0)
            ,[dblMouthFeel]     = ISNULL(MOUTH_FEEL.dblPinpointValue, 0)
        FROM tblICItem I        
        -- Appearance
        OUTER APPLY (SELECT PPVP.dblPinpointValue FROM tblQMProduct P JOIN tblQMProductProperty PP ON PP.intProductId = P.intProductId JOIN tblQMProperty PROP ON PROP.intPropertyId = PP.intPropertyId
             JOIN tblQMProductPropertyValidityPeriod PPVP ON PP.intProductPropertyId = PPVP.intProductPropertyId AND DATEPART(dayofyear , GETDATE()) BETWEEN DATEPART(dayofyear , PPVP.dtmValidFrom) AND DATEPART(dayofyear , PPVP.dtmValidTo)
                WHERE P.intProductValueId = ITEM.intItemId AND P.intProductTypeId =  2 -- Item
                AND PROP.strPropertyName = 'Appearance') APPEARANCE
        -- Hue
        OUTER APPLY (SELECT PPVP.dblPinpointValue FROM tblQMProduct P JOIN tblQMProductProperty PP ON PP.intProductId = P.intProductId JOIN tblQMProperty PROP ON PROP.intPropertyId = PP.intPropertyId
             JOIN tblQMProductPropertyValidityPeriod PPVP ON PP.intProductPropertyId = PPVP.intProductPropertyId AND DATEPART(dayofyear , GETDATE()) BETWEEN DATEPART(dayofyear , PPVP.dtmValidFrom) AND DATEPART(dayofyear , PPVP.dtmValidTo)
                WHERE P.intProductValueId = ITEM.intItemId AND P.intProductTypeId =  2 -- Item
                AND PROP.strPropertyName = 'Hue') HUE
        -- Intensity
        OUTER APPLY (SELECT PPVP.dblPinpointValue FROM tblQMProduct P JOIN tblQMProductProperty PP ON PP.intProductId = P.intProductId JOIN tblQMProperty PROP ON PROP.intPropertyId = PP.intPropertyId
             JOIN tblQMProductPropertyValidityPeriod PPVP ON PP.intProductPropertyId = PPVP.intProductPropertyId AND DATEPART(dayofyear , GETDATE()) BETWEEN DATEPART(dayofyear , PPVP.dtmValidFrom) AND DATEPART(dayofyear , PPVP.dtmValidTo)
                WHERE P.intProductValueId = ITEM.intItemId AND P.intProductTypeId =  2 -- Item
                AND PROP.strPropertyName = 'Intensity') INTENSITY
        -- Taste
        OUTER APPLY (SELECT PPVP.dblPinpointValue FROM tblQMProduct P JOIN tblQMProductProperty PP ON PP.intProductId = P.intProductId JOIN tblQMProperty PROP ON PROP.intPropertyId = PP.intPropertyId
             JOIN tblQMProductPropertyValidityPeriod PPVP ON PP.intProductPropertyId = PPVP.intProductPropertyId AND DATEPART(dayofyear , GETDATE()) BETWEEN DATEPART(dayofyear , PPVP.dtmValidFrom) AND DATEPART(dayofyear , PPVP.dtmValidTo)
                WHERE P.intProductValueId = ITEM.intItemId AND P.intProductTypeId =  2 -- Item
                AND PROP.strPropertyName = 'Taste') TASTE
        -- Mouth Feel
        OUTER APPLY (SELECT PPVP.dblPinpointValue FROM tblQMProduct P JOIN tblQMProductProperty PP ON PP.intProductId = P.intProductId JOIN tblQMProperty PROP ON PROP.intPropertyId = PP.intPropertyId
             JOIN tblQMProductPropertyValidityPeriod PPVP ON PP.intProductPropertyId = PPVP.intProductPropertyId AND DATEPART(dayofyear , GETDATE()) BETWEEN DATEPART(dayofyear , PPVP.dtmValidFrom) AND DATEPART(dayofyear , PPVP.dtmValidTo)
                WHERE P.intProductValueId = ITEM.intItemId AND P.intProductTypeId =  2 -- Item
                AND PROP.strPropertyName = 'Mouth Feel') MOUTH_FEEL
    ) PP

    WHERE S.intSampleId = @intSampleId
        AND STS.dblAppearance = PP.dblAppearance
        AND STS.dblHue = PP.dblHue
        AND STS.dblIntensity = PP.dblIntensity
        AND STS.dblTaste = PP.dblTaste
        AND STS.dblMouthFeel = PP.dblMouthFeel
    GROUP BY ITEM.intItemId
    ORDER BY COUNT(1) Desc
    
    RETURN @intItemId    
END