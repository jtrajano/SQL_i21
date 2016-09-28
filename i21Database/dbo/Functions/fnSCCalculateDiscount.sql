CREATE FUNCTION [dbo].[fnSCCalculateDiscount]
(
	@intTicketId int,
	@intTicketDiscountId int
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

	SELECT @dblTicketGrossUnit = dblGrossUnits, @dblTicketShrinkUnit = dblShrink, @dblTicketNetUnits = dblNetUnits 
	,@dblTicketGrossWeight = dblGrossWeight, @dblTicketTareWeight = dblTareWeight
	FROM tblSCTicket WHERE intTicketId = @intTicketId
	SELECT @dblDiscountAmount = dblDiscountAmount, @strDiscountCalculationOptionId = strCalcMethod FROM tblQMTicketDiscount WHERE intTicketDiscountId = @intTicketDiscountId;

	IF @strDiscountCalculationOptionId = '1' --NET WEIGHT
		BEGIN
			SET @calculatedValue =  @dblDiscountAmount * @dblTicketNetUnits
		END
	ELSE IF  @strDiscountCalculationOptionId = '2' --WET WEIGHT
		BEGIN
			SELECT @dblGrossShrinkPercentage = SUM(dblShrinkPercent) FROM tblQMTicketDiscount WHERE intTicketId = @intTicketId AND strShrinkWhat = 'Gross Weight'
			SELECT @dblWetShrinkPercentage = SUM(dblShrinkPercent) FROM tblQMTicketDiscount WHERE intTicketId = @intTicketId AND strShrinkWhat = 'Wet Weight'
			SET @dblTicketNetWeight = @dblTicketGrossWeight - @dblTicketTareWeight;
			SET @dblGrossShrink = @dblTicketNetWeight * ISNULL(@dblGrossShrinkPercentage,0);
			SET @dblGrossShrink = @dblGrossShrink / 100;
			SET @dblTicketWetUnits = (@dblTicketNetWeight - @dblGrossShrink)
            SET @dblWetShrink =  @dblTicketWetUnits * @dblWetShrinkPercentage;
            SET @dblWetShrink = @dblWetShrink / 100;
			SET @calculatedValue =  @dblDiscountAmount * (@dblTicketWetUnits - @dblWetShrink)
		END
	ELSE 
		SET @calculatedValue =  @dblDiscountAmount * @dblTicketGrossUnit

	RETURN @calculatedValue
END