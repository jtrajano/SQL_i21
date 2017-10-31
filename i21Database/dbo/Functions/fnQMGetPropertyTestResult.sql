CREATE FUNCTION [dbo].[fnQMGetPropertyTestResult] (@intTestResultId INT)
RETURNS NVARCHAR(20)
AS
BEGIN
	DECLARE @intDataTypeId INT
		,@dblMinValue NUMERIC(18, 6)
		,@dblMaxValue NUMERIC(18, 6)
		,@strPropertyRangeText NVARCHAR(MAX) = ''
		,@strPropertyValue NVARCHAR(MAX) = ''
	DECLARE @strResult NVARCHAR(20) = ''

	SELECT @intDataTypeId = P.intDataTypeId
		,@dblMinValue = TR.dblMinValue
		,@dblMaxValue = TR.dblMaxValue
		,@strPropertyRangeText = ISNULL(TR.strPropertyRangeText, '')
		,@strPropertyValue = ISNULL(TR.strPropertyValue, '')
	FROM tblQMTestResult TR
	JOIN tblQMProperty P ON P.intPropertyId = TR.intPropertyId
	WHERE TR.intTestResultId = @intTestResultId

	IF @strPropertyValue = ''
		SELECT @strResult = ''
	ELSE
	BEGIN
		IF @intDataTypeId = 1
			OR @intDataTypeId = 2 -- Integer / Float
		BEGIN
			IF @dblMinValue IS NOT NULL
				AND @dblMaxValue IS NOT NULL
			BEGIN
				IF @strPropertyValue > @dblMinValue
					AND @strPropertyValue < @dblMaxValue
					SELECT @strResult = 'Passed'
				ELSE IF @strPropertyValue < @dblMinValue
					OR @strPropertyValue > @dblMaxValue
					SELECT @strResult = 'Failed'
				ELSE IF @strPropertyValue = @dblMinValue
					OR @strPropertyValue = @dblMaxValue
					SELECT @strResult = 'Marginal'
				ELSE
					SELECT @strResult = ''
			END
			ELSE
				SELECT @strResult = ''
		END
		ELSE IF @intDataTypeId = 4
			OR @intDataTypeId = 5
			OR @intDataTypeId = 9
			OR @intDataTypeId = 12 -- Bit / List / String / DateTime
		BEGIN
			IF @strPropertyRangeText = ''
				SELECT @strResult = ''
			ELSE
			BEGIN
				IF NOT EXISTS (
						SELECT 1
						FROM [dbo].[fnSplitStringWithTrim](LOWER(@strPropertyRangeText), ',')
						WHERE Item = LOWER(@strPropertyValue)
						)
					SELECT @strResult = 'Failed'
				ELSE
					SELECT @strResult = 'Passed'
			END
		END
	END

	RETURN @strResult
END
