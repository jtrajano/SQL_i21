CREATE FUNCTION [dbo].[fnSCCalculateDiscountSplit]
(
	@intTicketId INT,
	@intEntityId INT,
	@intTicketDiscountId INT,
	@strCostMethod NVARCHAR(10),
	@intUnitMeasureId INT = NULL
)
RETURNS NUMERIC(18, 6) 
AS
BEGIN 
	DECLARE @dblDiscountAmount AS NUMERIC(18, 6)
	,@dblWetShrink AS NUMERIC(18, 6)
	,@dblGrossShrink AS NUMERIC(18, 6)
	,@dblWetShrinkPercentage AS NUMERIC(18, 6)
	,@dblGrossShrinkPercentage AS NUMERIC(18, 6)
	,@dblTicketGrossWeight AS NUMERIC(18, 6)
	,@dblTicketTareWeight AS NUMERIC(18, 6)
	,@dblTicketNetWeight AS NUMERIC(18, 6)
	,@dblTicketGrossUnit AS NUMERIC(18, 6)
	,@dblTicketShrinkUnit AS NUMERIC(18, 6)
	,@dblTicketNetUnits AS NUMERIC(18, 6)
	,@dblTicketWetUnits AS NUMERIC(18, 6)
	,@calculatedValue AS NUMERIC(18, 6)
	,@strDiscountCalculationOptionId varchar
	,@dblSplitPercent AS NUMERIC(38, 20)
	,@dblUOMQty AS NUMERIC(38, 20)
	,@intItemId AS NUMERIC(38, 20);

	SELECT @dblTicketGrossUnit = dblGrossUnits, @dblTicketShrinkUnit = dblShrink, @dblTicketNetUnits = dblNetUnits 
	,@dblTicketGrossWeight = dblGrossWeight, @dblTicketTareWeight = dblTareWeight, @intItemId = intItemId
	FROM tblSCTicket WHERE intTicketId = @intTicketId
	SELECT @dblDiscountAmount = dblDiscountAmount, @strDiscountCalculationOptionId = strCalcMethod FROM tblQMTicketDiscount WHERE intTicketDiscountId = @intTicketDiscountId;
	SELECT @dblSplitPercent = dblSplitPercent FROM tblSCTicketSplit WHERE intCustomerId = @intEntityId AND intTicketId = @intTicketId;
	SET @dblSplitPercent = @dblSplitPercent / 100;

	IF ISNULL(@intUnitMeasureId,0 ) > 0
		SELECT @dblUOMQty = dblUnitQty FROM tblICItemUOM WHERE intItemId = @intItemId AND intUnitMeasureId = @intUnitMeasureId
	
	IF ISNULL(@dblUOMQty,0 ) = 0
		SET @dblUOMQty = 1

	IF @strDiscountCalculationOptionId = '1' --NET WEIGHT
		BEGIN
			SET @calculatedValue = ((@dblTicketNetUnits * @dblSplitPercent)/ @dblUOMQty) * @dblDiscountAmount
		END
	ELSE IF  @strDiscountCalculationOptionId = '2' --WET WEIGHT
		BEGIN
			SELECT @dblGrossShrinkPercentage = SUM(dblShrinkPercent) FROM tblQMTicketDiscount WHERE intTicketId = @intTicketId AND strShrinkWhat = 'Gross Weight'
			SET @dblGrossShrink = (@dblTicketGrossUnit * @dblSplitPercent) * ISNULL(@dblGrossShrinkPercentage,0);
			SET @dblGrossShrink = @dblGrossShrink / 100;
			SET @dblTicketWetUnits = ((@dblTicketGrossUnit * @dblSplitPercent) / @dblUOMQty) - @dblGrossShrink
			SET @calculatedValue =  @dblDiscountAmount * @dblTicketWetUnits
		END
	ELSE 
		SET @calculatedValue =  ((@dblTicketGrossUnit * @dblSplitPercent) / @dblUOMQty) * @dblDiscountAmount
	RETURN @calculatedValue
END