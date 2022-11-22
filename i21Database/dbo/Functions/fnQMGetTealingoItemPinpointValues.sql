CREATE FUNCTION [dbo].[fnQMGetTealingoItemPinpointValues](
    @intItemId INT
)
RETURNS TABLE
AS RETURN
SELECT
    ITEM.intItemId
    ,[dblAppearance]    = APPEARANCE.dblPinpointValue
    ,[dblHue]           = HUE.dblPinpointValue
    ,[dblIntensity]     = INTENSITY.dblPinpointValue
    ,[dblTaste]         = TASTE.dblPinpointValue
    ,[dblMouthFeel]     = MOUTH_FEEL.dblPinpointValue
FROM tblICItem ITEM
INNER JOIN tblQMProduct P ON P.intProductValueId = ITEM.intItemId AND P.intProductTypeId =  2 -- Item
-- Appearance
OUTER APPLY (
    SELECT PPVP.dblPinpointValue FROM tblQMProductProperty PP INNER JOIN tblQMProperty PROP ON PROP.intPropertyId = PP.intPropertyId
    LEFT JOIN tblQMProductPropertyValidityPeriod PPVP ON PP.intProductPropertyId = PPVP.intProductPropertyId
    AND DATEPART(dayofyear , GETDATE()) BETWEEN DATEPART(dayofyear , PPVP.dtmValidFrom) AND DATEPART(dayofyear , PPVP.dtmValidTo)
    WHERE PP.intProductId = P.intProductId AND PROP.strPropertyName = 'Appearance'
) APPEARANCE
-- Hue
OUTER APPLY (
    SELECT PPVP.dblPinpointValue FROM tblQMProductProperty PP INNER JOIN tblQMProperty PROP ON PROP.intPropertyId = PP.intPropertyId
    LEFT JOIN tblQMProductPropertyValidityPeriod PPVP ON PP.intProductPropertyId = PPVP.intProductPropertyId
    AND DATEPART(dayofyear , GETDATE()) BETWEEN DATEPART(dayofyear , PPVP.dtmValidFrom) AND DATEPART(dayofyear , PPVP.dtmValidTo)
    WHERE PP.intProductId = P.intProductId AND PROP.strPropertyName = 'Hue'
) HUE
-- Intensity
OUTER APPLY (
    SELECT PPVP.dblPinpointValue FROM tblQMProductProperty PP INNER JOIN tblQMProperty PROP ON PROP.intPropertyId = PP.intPropertyId
    LEFT JOIN tblQMProductPropertyValidityPeriod PPVP ON PP.intProductPropertyId = PPVP.intProductPropertyId
    AND DATEPART(dayofyear , GETDATE()) BETWEEN DATEPART(dayofyear , PPVP.dtmValidFrom) AND DATEPART(dayofyear , PPVP.dtmValidTo)
    WHERE PP.intProductId = P.intProductId AND PROP.strPropertyName = 'Intensity'
) INTENSITY
-- Taste
OUTER APPLY (
    SELECT PPVP.dblPinpointValue FROM tblQMProductProperty PP INNER JOIN tblQMProperty PROP ON PROP.intPropertyId = PP.intPropertyId
    LEFT JOIN tblQMProductPropertyValidityPeriod PPVP ON PP.intProductPropertyId = PPVP.intProductPropertyId
    AND DATEPART(dayofyear , GETDATE()) BETWEEN DATEPART(dayofyear , PPVP.dtmValidFrom) AND DATEPART(dayofyear , PPVP.dtmValidTo)
    WHERE PP.intProductId = P.intProductId AND PROP.strPropertyName = 'Taste'
) TASTE
-- Mouth Feel
OUTER APPLY (
    SELECT PPVP.dblPinpointValue FROM tblQMProductProperty PP INNER JOIN tblQMProperty PROP ON PROP.intPropertyId = PP.intPropertyId
    LEFT JOIN tblQMProductPropertyValidityPeriod PPVP ON PP.intProductPropertyId = PPVP.intProductPropertyId
    AND DATEPART(dayofyear , GETDATE()) BETWEEN DATEPART(dayofyear , PPVP.dtmValidFrom) AND DATEPART(dayofyear , PPVP.dtmValidTo)
    WHERE PP.intProductId = P.intProductId AND PROP.strPropertyName = 'Mouth Feel'
) MOUTH_FEEL
WHERE ITEM.intItemId = @intItemId
    -- AND PROP.strPropertyName IN ('Appearance', 'Hue', 'Intensity', 'Taste', 'Mouth Feel')