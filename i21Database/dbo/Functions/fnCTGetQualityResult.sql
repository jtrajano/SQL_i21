Create FUNCTION [dbo].[fnCTGetQualityResult] 
	(
		 @dblActualValue NUMERIC(18, 6),
		 @dblMinValue NUMERIC(18, 6),
		 @dblMaxValue NUMERIC(18, 6),
		 @dblTargetValue NUMERIC(18, 6),
		 @dblFactorUnderTarget NUMERIC(18, 6),
		 @dblFactorOverTarget NUMERIC(18,6),
		 @dblDiscount NUMERIC(18,6),
		 @dblPremium NUMERIC(18,6),
		 @strEscalatedBy nvarchar(20)
	)
RETURNS NUMERIC(18, 6)
AS
BEGIN
	
	Declare @dblResult Numeric(18,6)
	SET @dblResult = CASE WHEN @dblActualValue between @dblMinValue and @dblMaxValue THEN
						((@dblActualValue - @dblTargetValue) / (CASE WHEN @dblActualValue < @dblTargetValue THEN @dblFactorUnderTarget ELSE @dblFactorOverTarget END)) *
						CASE WHEN @dblActualValue < @dblTargetValue THEN @dblDiscount ELSE @dblPremium END
					ELSE NULL END
	if (@strEscalatedBy = 'Exact Factor')
	BEGIN 
		SET @dblResult = cast(@dblResult as int)
	END

	return @dblResult

END

