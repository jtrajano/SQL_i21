CREATE FUNCTION fnGetIncrementalAmount
(
	  @dblTotalGallons DECIMAL(18, 6) = 0
	, @dblTotalGallonsLimit DECIMAL(18, 6) = 0
	, @dblIncrementalGallons DECIMAL(18, 6) = 0
	, @dblIncrementalFeeAmount DECIMAL(18, 6) = 0
)
RETURNS DECIMAL(18, 6)
AS
BEGIN
	DECLARE @intMultiplier INT = 0
	DECLARE @dblExcessGallons DECIMAL(18, 6) = 0

	SET @dblExcessGallons = @dblTotalGallons - @dblTotalGallonsLimit

	WHILE(@dblExcessGallons > 0)
	BEGIN
		SET @intMultiplier += 1
		SET @dblExcessGallons -= @dblIncrementalGallons
	END

	RETURN (@intMultiplier * @dblIncrementalFeeAmount)
END
