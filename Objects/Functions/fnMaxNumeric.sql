CREATE FUNCTION [dbo].[fnMaxNumeric]
(
	@dblValue1 NUMERIC(38, 20),
	@dblValue2 NUMERIC(38, 20)
)
RETURNS NUMERIC(38, 20)
AS
BEGIN
	IF @dblValue1 > @dblValue2
		RETURN @dblValue1
	RETURN @dblValue2
END