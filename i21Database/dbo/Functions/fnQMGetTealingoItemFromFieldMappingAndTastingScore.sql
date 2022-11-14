CREATE FUNCTION [dbo].[fnQMGetTealingoItemFromFieldMappingAndTastingScore](
    @intSampleId INT
)
RETURNS INT
AS BEGIN
    DECLARE @intItemId INT

    SELECT @intItemId = I.intItemId
    FROM tblQMSample S
    OUTER APPLY (
        SELECT intItemId = dbo.fnQMGetTealingoItemFromFieldMapping(S.intSampleId)
    ) I
    OUTER APPLY dbo.fnQMGetSampleTastingScore(S.intSampleId) STS
    OUTER APPLY (
        SELECT ysnValid = dbo.fnQMValidateTealingoItemTastingScore(
            I.intItemId
            ,STS.dblAppearance
            ,STS.dblHue
            ,STS.dblIntensity
            ,STS.dblTaste
            ,STS.dblMouthFeel
        )
    ) V
    WHERE S.intSampleId = @intSampleId
    AND V.ysnValid = 1
    
    RETURN @intItemId    
END