﻿CREATE FUNCTION [dbo].[fnSCCalculateDiscountSplit]
(
	@intTicketId INT,
	@intEntityId INT,
	@intTicketDiscountId INT,
	@dblUnitQty AS NUMERIC(38, 20),
	@intUnitMeasureId INT = NULL,
	@dblCost AS NUMERIC(38, 20),
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
	,@dblQtyToDistribute AS NUMERIC(38, 20)
	,@strDiscountChargeType NVARCHAR(10)
	,@dblQtyBasedOnPassedQty AS NUMERIC(18, 6);

	IF @ysnDeliverySheet = 0
	BEGIN
		SELECT @dblTicketGrossUnit = dblGrossUnits, @dblTicketShrinkUnit = dblShrink
			, @dblTicketNetUnits = dblNetUnits , @intItemId = intItemId
		FROM tblSCTicket WHERE intTicketId = @intTicketId
		
		SELECT @dblDiscountAmount = dblDiscountAmount, @strDiscountCalculationOptionId = strCalcMethod, @strDiscountChargeType = strDiscountChargeType 
		FROM tblQMTicketDiscount WHERE intTicketDiscountId = @intTicketDiscountId

		SELECT @dblSplitPercent = dblSplitPercent FROM tblSCTicketSplit WHERE intCustomerId = @intEntityId AND intTicketId = @intTicketId

		
		set @dblQtyBasedOnPassedQty = dbo.fnMultiply(@dblTicketNetUnits, dbo.fnDivide(@dblSplitPercent, 100) )

	END
	ELSE
	BEGIN
		SELECT @dblTicketGrossUnit = dblGross, @dblTicketShrinkUnit = dblShrink, @dblTicketNetUnits = dblNet , @intItemId = intItemId
		FROM tblSCDeliverySheet WHERE intDeliverySheetId = @intTicketId

		SELECT @dblDiscountAmount = dblDiscountAmount, @strDiscountCalculationOptionId = strCalcMethod, @strDiscountChargeType = strDiscountChargeType 
		FROM tblQMTicketDiscount WHERE intTicketDiscountId = @intTicketDiscountId

		SELECT @dblSplitPercent = dblSplitPercent FROM tblSCDeliverySheetSplit WHERE intEntityId = @intEntityId AND intDeliverySheetId = @intTicketId
	END

	SET @dblSplitPercent = @dblSplitPercent / 100;
	
	IF ISNULL(@intUnitMeasureId,0 ) > 0
		SELECT @dblUOMQty = dblUnitQty FROM tblICItemUOM WHERE intItemId = @intItemId AND intUnitMeasureId = @intUnitMeasureId
	
	IF ISNULL(@dblUOMQty,0 ) = 0
		SET @dblUOMQty = 1

	IF @strDiscountCalculationOptionId = '1' --NET WEIGHT
	BEGIN
		SET @dblQtyToDistribute = @dblTicketNetUnits * @dblSplitPercent
		if(@dblQtyBasedOnPassedQty > 0 )
			SET @dblQtyToDistribute = dbo.fnMultiply(dbo.fnDivide(@dblUnitQty, @dblQtyBasedOnPassedQty), @dblQtyToDistribute)
		SET @calculatedValue = (@dblQtyToDistribute/ @dblUOMQty) * @dblDiscountAmount
	END
	ELSE IF  @strDiscountCalculationOptionId = '2' --WET WEIGHT
	BEGIN
		SELECT @dblGrossShrinkPercentage = SUM(dblShrinkPercent) FROM tblQMTicketDiscount WHERE intTicketId = @intTicketId AND strShrinkWhat = 'Gross Weight'
		SET @dblQtyToDistribute = @dblTicketGrossUnit * @dblSplitPercent

		if(@dblQtyBasedOnPassedQty > 0 )
			SET @dblQtyToDistribute = dbo.fnMultiply(dbo.fnDivide(@dblUnitQty, @dblQtyBasedOnPassedQty), @dblQtyToDistribute)

		SET @dblGrossShrink = @dblQtyToDistribute * ISNULL(@dblGrossShrinkPercentage,0);
		SET @dblGrossShrink = @dblGrossShrink / 100;
		SET @dblTicketWetUnits = (@dblQtyToDistribute / @dblUOMQty) - @dblGrossShrink
		SET @calculatedValue =  @dblDiscountAmount * @dblTicketWetUnits
	END
	ELSE 
	begin
		SET @dblQtyToDistribute = @dblTicketGrossUnit * @dblSplitPercent
		
		if(@dblQtyBasedOnPassedQty > 0 )
			SET @dblQtyToDistribute = dbo.fnMultiply(dbo.fnDivide(@dblUnitQty, @dblQtyBasedOnPassedQty), @dblQtyToDistribute)

		SET @calculatedValue =  (@dblQtyToDistribute / @dblUOMQty) * @dblDiscountAmount
	end

	IF @strDiscountChargeType = 'Percent'
		RETURN (@calculatedValue * @dblCost)
	
	RETURN @calculatedValue
END