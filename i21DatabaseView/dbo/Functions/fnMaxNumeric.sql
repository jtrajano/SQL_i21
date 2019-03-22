CREATE FUNCTION [dbo].[fnMaxNumeric]
(
	@dblValue1 NUMERIC,
	@dblValue2 NUMERIC
)
RETURNS NUMERIC
AS
BEGIN
	IF @dblValue1 > @dblValue2
		RETURN @dblValue1
	RETURN @dblValue2
END