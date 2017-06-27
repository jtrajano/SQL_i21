CREATE FUNCTION [dbo].[fnCFForceRounding] (
@value			NUMERIC(18,6)
)
RETURNS NUMERIC(18,3)
AS BEGIN
   
	DECLARE @value3			NUMERIC(18,3)
	DECLARE @addToValue		NUMERIC(18,3)
	--SET @value = 1.123990
	SET @value3 = round(@value, 3, 1)
	SET @addToValue = 0.000000

	SELECT @addToValue = ROUND(((9 - RIGHT(@value3,1)) / CONVERT(decimal(18,3),1000)),6)
	RETURN @value3 + @addToValue

END
GO