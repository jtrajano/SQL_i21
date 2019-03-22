CREATE FUNCTION [dbo].[fnAPBankRounding]
(
	@amount DECIMAL(38,16),
	@decimalPlace INT
)
RETURNS DECIMAL(38, 16)
AS
BEGIN
	
	DECLARE @isNegative BIT;

	DECLARE @inputAbs DECIMAL(38, 16);

	DECLARE @leftPart DECIMAL(38, 16);

	DECLARE @rightPart DECIMAL(38, 16);

	DECLARE @halfWay DECIMAL(38, 16);

	DECLARE @ten DECIMAL(38, 16);

	-- Separate the input into @isNegative and @inputAbs

	IF @amount < 0

	BEGIN

		SET @isNegative = 1;

	END ELSE

	BEGIN

		SET @isNegative = 0;

	END

	SET @inputAbs = ABS(@amount);

	-- Truncate the aInput and store it as @leftPart

	SET @leftPart = ROUND(@inputAbs, @decimalPlace, 1);

	-- Store the part to be rounded as @rightPart

	SET @rightPart = @inputAbs - @leftPart;

	-- Calculate the halfway point for rounding

	SET @ten = 10;

	SET @halfWay = POWER(@ten, -@decimalPlace) * 0.5;

	-- If the @rightPart is not exactly half way,

	-- the result is the same as the Arithmetic Rounding

	IF @rightPart <> @halfWay
	BEGIN
		RETURN ROUND(@amount, @decimalPlace, 0)
	END -- IF

	-- If the last digit of the @leftPart is odd,

	-- the result is the same as the Arithmetic Rounding

	IF (@leftPart * 0.5) <> ROUND(@leftPart * 0.5, @decimalPlace, 1)
	BEGIN
		RETURN ROUND(@amount, @decimalPlace, 0);
	END

		-- If the last digit is even, Truncate

	IF @isNegative = 1
	BEGIN
		RETURN -@leftPart
	END

	RETURN @leftPart

END
