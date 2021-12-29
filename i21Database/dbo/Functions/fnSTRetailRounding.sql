CREATE FUNCTION dbo.fnSTRetailRounding
(
  @dblRetailPrice AS NUMERIC(18,2)
)

-- To validate check here https://www.gs1.org/services/check-digit-calculator

RETURNS  NUMERIC(18,2)
AS BEGIN
	
	DECLARE @dblConvertedRetailRounding AS NUMERIC(18,2) = 0
	DECLARE @strCastedRetail AS NVARCHAR(30) = CAST(@dblRetailPrice AS NVARCHAR(30))

	IF ISNULL(@dblRetailPrice,0) != 0
	BEGIN
		SET @dblConvertedRetailRounding = CAST(LEFT(@strCastedRetail, LEN(@strCastedRetail)-1)
		   + REPLACE(RIGHT(@strCastedRetail, 1), RIGHT(@strCastedRetail, 1), 9) AS NUMERIC(18,2))
	END

    RETURN @dblConvertedRetailRounding
END