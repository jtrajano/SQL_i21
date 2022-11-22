CREATE FUNCTION [dbo].[fnQMGetSampleTastingScore](
    @intSampleId INT
)
RETURNS TABLE
AS RETURN
SELECT
    S.intSampleId
    ,[dblAppearance]    = CASE WHEN ISNULL(APPEARANCE.strPropertyValue, '') = '' THEN NULL ELSE CAST(APPEARANCE.strPropertyValue AS NUMERIC(18,6)) END
    ,[dblHue]           = CASE WHEN ISNULL(HUE.strPropertyValue, '') = '' THEN NULL ELSE CAST(HUE.strPropertyValue AS NUMERIC(18,6)) END
    ,[dblIntensity]     = CASE WHEN ISNULL(INTENSITY.strPropertyValue, '') = '' THEN NULL ELSE CAST(INTENSITY.strPropertyValue AS NUMERIC(18,6)) END
    ,[dblTaste]         = CASE WHEN ISNULL(TASTE.strPropertyValue, '') = '' THEN NULL ELSE CAST(TASTE.strPropertyValue AS NUMERIC(18,6)) END
    ,[dblMouthFeel]     = CASE WHEN ISNULL(MOUTH_FEEL.strPropertyValue, '') = '' THEN NULL ELSE CAST(MOUTH_FEEL.strPropertyValue AS NUMERIC(18,6)) END
FROM tblQMSample S
-- Appearance
OUTER APPLY (SELECT TR.strPropertyValue FROM tblQMTestResult TR JOIN tblQMProperty P ON P.intPropertyId = TR.intPropertyId AND P.strPropertyName = 'Appearance' WHERE TR.intSampleId = S.intSampleId) APPEARANCE
-- Hue
OUTER APPLY (SELECT TR.strPropertyValue FROM tblQMTestResult TR JOIN tblQMProperty P ON P.intPropertyId = TR.intPropertyId AND P.strPropertyName = 'Hue' WHERE TR.intSampleId = S.intSampleId) HUE
-- Intensity
OUTER APPLY (SELECT TR.strPropertyValue FROM tblQMTestResult TR JOIN tblQMProperty P ON P.intPropertyId = TR.intPropertyId AND P.strPropertyName = 'Intensity' WHERE TR.intSampleId = S.intSampleId) INTENSITY
-- Taste
OUTER APPLY (SELECT TR.strPropertyValue FROM tblQMTestResult TR JOIN tblQMProperty P ON P.intPropertyId = TR.intPropertyId AND P.strPropertyName = 'Taste' WHERE TR.intSampleId = S.intSampleId) TASTE
-- Mouth Feel
OUTER APPLY (SELECT TR.strPropertyValue FROM tblQMTestResult TR JOIN tblQMProperty P ON P.intPropertyId = TR.intPropertyId AND P.strPropertyName = 'Mouth Feel' WHERE TR.intSampleId = S.intSampleId) MOUTH_FEEL

WHERE S.intSampleId = @intSampleId