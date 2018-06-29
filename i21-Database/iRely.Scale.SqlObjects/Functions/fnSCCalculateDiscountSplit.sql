CREATE FUNCTION [dbo].[fnSCCalculateDiscountSplit]
(
	@intTicketId INT,
	@intEntityId INT,
	@intTicketDiscountId INT,
	@dblUnitQty AS NUMERIC(38, 20),
	@intUnitMeasureId INT = NULL,
	@ysnDeliverySheet BIT = 0
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
	,@intItemId AS NUMERIC(38, 20)
	,@dblQtyToDistribute AS NUMERIC(38, 20);

	SELECT @dblTicketGrossUnit = dblGrossUnits, @dblTicketShrinkUnit = dblShrink, @dblTicketNetUnits = dblNetUnits 
	, @dblTicketGrossWeight = (dblGrossWeight + ISNULL(dblGrossWeight1, 0) + ISNULL(dblGrossWeight2, 0))
	, @dblTicketTareWeight = (dblTareWeight + ISNULL(dblTareWeight1, 0) + ISNULL(dblTareWeight2, 0))
	, @intItemId = intItemId
	FROM tblSCTicket WHERE intTicketId = @intTicketId
	SELECT @dblDiscountAmount = dblDiscountAmount, @strDiscountCalculationOptionId = strCalcMethod FROM tblQMTicketDiscount WHERE intTicketDiscountId = @intTicketDiscountId;

	IF @ysnDeliverySheet = 0
	BEGIN
		SELECT @dblSplitPercent = dblSplitPercent FROM tblSCTicketSplit WHERE intCustomerId = @intEntityId AND intTicketId = @intTicketId;
	END
	ELSE
	BEGIN
		SELECT @dblSplitPercent = dblSplitPercent FROM tblSCDeliverySheetSplit WHERE intEntityId = @intEntityId AND intDeliverySheetId = @intTicketId;
	END
	SET @dblSplitPercent = @dblSplitPercent / 100;

	IF ISNULL(@intUnitMeasureId,0 ) > 0
		SELECT @dblUOMQty = dblUnitQty FROM tblICItemUOM WHERE intItemId = @intItemId AND intUnitMeasureId = @intUnitMeasureId
	
	IF ISNULL(@dblUOMQty,0 ) = 0
		SET @dblUOMQty = 1

	IF @strDiscountCalculationOptionId = '1' --NET WEIGHT
		BEGIN
			SET @dblQtyToDistribute = @dblTicketNetUnits * @dblSplitPercent
			SET @calculatedValue = (@dblQtyToDistribute/ @dblUOMQty) * @dblDiscountAmount
		END
	ELSE IF  @strDiscountCalculationOptionId = '2' --WET WEIGHT
		BEGIN
			SELECT @dblGrossShrinkPercentage = SUM(dblShrinkPercent) FROM tblQMTicketDiscount WHERE intTicketId = @intTicketId AND strShrinkWhat = 'Gross Weight'
			SET @dblQtyToDistribute = @dblTicketGrossUnit * @dblSplitPercent
			SET @dblGrossShrink = @dblQtyToDistribute * ISNULL(@dblGrossShrinkPercentage,0);
			SET @dblGrossShrink = @dblGrossShrink / 100;
			SET @dblTicketWetUnits = (@dblQtyToDistribute / @dblUOMQty) - @dblGrossShrink
			SET @calculatedValue =  @dblDiscountAmount * @dblTicketWetUnits
		END
	ELSE 
		SET @dblQtyToDistribute = @dblTicketGrossUnit * @dblSplitPercent
		SET @calculatedValue =  (@dblQtyToDistribute / @dblUOMQty) * @dblDiscountAmount
	RETURN @calculatedValue
END