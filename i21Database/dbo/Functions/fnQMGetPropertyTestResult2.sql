CREATE FUNCTION [dbo].[fnQMGetPropertyTestResult2] (@intTestResultId INT)
RETURNS TABLE
AS RETURN

WITH CTE AS (
    SELECT P.intDataTypeId
        ,TR.dblMinValue
        ,TR.dblMaxValue
        ,strPropertyRangeText = ISNULL(TR.strPropertyRangeText, '')
        ,strPropertyValue = ISNULL(TR.strPropertyValue, '')
    FROM tblQMTestResult TR
    JOIN tblQMProperty P ON P.intPropertyId = TR.intPropertyId
    WHERE TR.intTestResultId = @intTestResultId
)

SELECT strResult =
    CASE
        WHEN CTE.strPropertyValue = ''
            THEN ''
        WHEN CTE.intDataTypeId = 1 OR CTE.intDataTypeId = 2 -- Integer / Float
            THEN CASE WHEN CTE.dblMinValue IS NOT NULL AND CTE.dblMaxValue IS NOT NULL
                THEN CASE WHEN (CTE.dblMaxValue - CTE.dblMinValue <= 1)
                    THEN CASE WHEN CTE.strPropertyValue >= CTE.dblMinValue AND CTE.strPropertyValue <= CTE.dblMaxValue
                        THEN 'Passed'
                        ELSE 'Failed'
                        END
                    ELSE
                        CASE WHEN CTE.strPropertyValue > CTE.dblMinValue AND CTE.strPropertyValue < CTE.dblMaxValue
                            THEN 'Passed'
                        WHEN CTE.strPropertyValue < CTE.dblMinValue OR CTE.strPropertyValue > CTE.dblMaxValue
                            THEN 'Failed'
                        WHEN CTE.strPropertyValue = CTE.dblMinValue OR CTE.strPropertyValue = CTE.dblMaxValue
                            THEN 'Marginal'
                        ELSE ''
                        END
                    END
                ELSE ''
                END
        WHEN CTE.intDataTypeId = 4 OR CTE.intDataTypeId = 5 OR CTE.intDataTypeId = 9 OR CTE.intDataTypeId = 12 -- Bit / List / String / DateTime
            THEN CASE
                WHEN CTE.strPropertyRangeText = ''
                    THEN ''
                WHEN NOT EXISTS (
                            SELECT 1
                            FROM [dbo].[fnSplitStringWithTrim](LOWER(CTE.strPropertyRangeText), ',')
                            WHERE Item = LOWER(CTE.strPropertyValue) COLLATE Latin1_General_CI_AS
                            )
                    THEN 'Failed'
                ELSE 'Passed'
                END
        ELSE ''
    END
FROM CTE

GO