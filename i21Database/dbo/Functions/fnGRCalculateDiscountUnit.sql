CREATE FUNCTION [dbo].[fnGRCalculateDiscountUnit]
(
  @intCustomerStorageId INT
 ,@intTicketDiscountId INT
 ,@dblNetWeight AS NUMERIC(18, 6)
)
RETURNS NUMERIC(18, 6)
AS
BEGIN
	DECLARE 
	     @intScaleTicketId INT
		,@dblGrossShrink AS NUMERIC(18, 6)
		,@dblGrossShrinkPercentage AS NUMERIC(18, 6)
		,@dblTicketGrossUnit AS NUMERIC(18, 6)
		,@dblTicketNetUnits AS NUMERIC(18, 6)
		,@dblTicketWetUnits AS NUMERIC(18, 6)
		,@CalculatedUnits AS NUMERIC(18, 6)
		,@strDiscountCalculationOptionId NVARCHAR(10)

	SELECT @intScaleTicketId = intTicketId
	FROM tblGRCustomerStorage
	WHERE intCustomerStorageId = @intCustomerStorageId

	SELECT @dblTicketGrossUnit = dblGrossUnits
		,@dblTicketNetUnits = dblNetUnits
	FROM tblSCTicket
	WHERE intTicketId = @intScaleTicketId

	SELECT @strDiscountCalculationOptionId = strCalcMethod
	FROM tblQMTicketDiscount
	WHERE intTicketDiscountId = @intTicketDiscountId

	IF @strDiscountCalculationOptionId = '1' --NET WEIGHT
	BEGIN
		SET @CalculatedUnits = @dblNetWeight
	END
	ELSE IF @strDiscountCalculationOptionId = '2' --WET WEIGHT
	BEGIN
		SELECT @dblGrossShrinkPercentage = SUM(dblShrinkPercent)
		FROM tblQMTicketDiscount
		WHERE intTicketFileId = @intCustomerStorageId
			AND strShrinkWhat = 'Gross Weight'
			AND strSourceType = 'Storage'

		SET @dblGrossShrink = @dblTicketGrossUnit * ISNULL(@dblGrossShrinkPercentage, 0)
		SET @dblGrossShrink = @dblGrossShrink / 100.0
		SET @dblTicketWetUnits = (@dblTicketGrossUnit - @dblGrossShrink)
		SET @CalculatedUnits = (@dblNetWeight / @dblTicketNetUnits) * @dblTicketWetUnits
	END
	ELSE
		SET @CalculatedUnits = (@dblNetWeight / @dblTicketNetUnits) * @dblTicketGrossUnit

	RETURN @CalculatedUnits
END