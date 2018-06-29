CREATE FUNCTION [dbo].[fnSCFreightCalculation]
(
	@dblQtytoDistribute NUMERIC(38, 20)
	,@dblNetUnits NUMERIC(38, 20)
	,@dblGrossUnits NUMERIC(38, 20)
	,@dblRate NUMERIC(38, 20) = NULL
)
RETURNS NUMERIC(18, 6) 
AS
BEGIN 
	DECLARE @retval NUMERIC(38,20),
			@percentage NUMERIC(38,20);
	IF ISNULL(@dblRate, 0) > 0
	BEGIN
		SET @percentage = @dblQtytoDistribute / @dblNetUnits
		SET @retval = (@percentage * @dblGrossUnits) * @dblRate
	END
	ELSE 
		SET @retval = (@dblQtytoDistribute / @dblNetUnits) * @dblGrossUnits

	return @retval;
END