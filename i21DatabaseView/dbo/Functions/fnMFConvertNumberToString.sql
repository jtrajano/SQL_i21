CREATE FUNCTION [dbo].[fnMFConvertNumberToString] (
	@dblQty NUMERIC(38, 20)
	,@intDecimal INT
	,@intTotalDigit INT
	)
RETURNS NVARCHAR(50)
AS
BEGIN
	DECLARE @strQty NVARCHAR(50) = ''

	SELECT @strQty = LEFT(REPLACE(LTRIM(dbo.fnRemoveTrailingZeroes(ROUND(ISNULL(@dblQty, 0), @intDecimal, 1))), '.', ''), @intTotalDigit)

	SELECT @strQty = (
			CASE 
				WHEN LEN(@strQty) < @intTotalDigit
					THEN REPLICATE('0', @intTotalDigit - LEN(@strQty)) + @strQty
				ELSE @strQty
				END
			)

	RETURN @strQty
END
