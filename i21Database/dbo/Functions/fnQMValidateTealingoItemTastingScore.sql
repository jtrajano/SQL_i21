CREATE FUNCTION [dbo].[fnQMValidateTealingoItemTastingScore](
    @intItemId INT
    ,@dblAppearance NUMERIC(18, 6)
    ,@dblHue NUMERIC(18, 6)
    ,@dblIntensity NUMERIC(18, 6)
    ,@dblTaste NUMERIC(18, 6)
    ,@dblMouthFeel NUMERIC(18, 6)
)
RETURNS BIT
AS BEGIN
    IF EXISTS (
        SELECT TOP 1 1
        FROM (
            SELECT TOP 1
                ITEM.intItemId,
                intValueMatchCount = COUNT(1)
            FROM tblICItem ITEM
            INNER JOIN tblQMProduct P ON P.intProductValueId = ITEM.intItemId AND P.intProductTypeId =  2 -- Item
            INNER JOIN tblQMProductProperty PP ON PP.intProductId = P.intProductId
            INNER JOIN tblQMProperty PROP ON PROP.intPropertyId = PP.intPropertyId
            LEFT JOIN tblQMProductPropertyValidityPeriod PPVP
                ON PP.intProductPropertyId = PPVP.intProductPropertyId
                AND DATEPART(dayofyear , GETDATE()) BETWEEN DATEPART(dayofyear , PPVP.dtmValidFrom) AND DATEPART(dayofyear , PPVP.dtmValidTo)
            WHERE
                ((PROP.strPropertyName = 'Appearance' AND PPVP.dblPinpointValue = @dblAppearance)
                OR (PROP.strPropertyName = 'Hue' AND PPVP.dblPinpointValue = @dblHue)
                OR (PROP.strPropertyName = 'Intensity' AND PPVP.dblPinpointValue = @dblIntensity)
                OR (PROP.strPropertyName = 'Taste' AND PPVP.dblPinpointValue = @dblTaste)
                OR (PROP.strPropertyName = 'Mouth Feel' AND PPVP.dblPinpointValue = @dblMouthFeel))
                AND ITEM.intItemId = @intItemId
            GROUP BY ITEM.intItemId
        ) R
        WHERE R.intValueMatchCount = 5 -- Item must match all 5 test Properties
            
    )
    BEGIN
        RETURN 1
    END
    
    RETURN 0
END