CREATE FUNCTION [dbo].[fnBBGetChargeRates]
(
	@intProgramChargeId INT
	,@intEntityLocationId INT
	,@intItemId INT
	,@intUnitMeasureId INT
	,@dtmDate DATETIME
)
RETURNS @tblReturnValue TABLE(
	dblRate NUMERIC(18,6)
	,intProgramRateId INT
)

BEGIN
	
	--location ,item, uom
	IF EXISTS(SELECT TOP 1 1 
			  FROM tblBBRate
			  WHERE intCustomerLocationId = @intEntityLocationId
				AND intItemId = @intItemId
				AND intUnitMeasureId = @intUnitMeasureId
				AND dtmBeginDate <= @dtmDate
				AND ISNULL(dtmEndDate,'1/1/9999') >= @dtmDate
				AND intProgramChargeId = @intProgramChargeId
	)
	BEGIN
		INSERT INTO @tblReturnValue (dblRate,intProgramRateId)
		SELECT TOP 1 dblRatePerUnit, intRateId 
			  FROM tblBBRate
			  WHERE intCustomerLocationId = @intEntityLocationId
				AND intItemId = @intItemId
				AND intUnitMeasureId = @intUnitMeasureId
				AND dtmBeginDate <= @dtmDate
				AND ISNULL(dtmEndDate ,'1/1/9999') >= @dtmDate
				AND intProgramChargeId = @intProgramChargeId
		RETURN
	END

	--itemid, uom
	IF EXISTS(SELECT TOP 1 1 
			  FROM tblBBRate
			  WHERE intCustomerLocationId IS NULL
				AND intItemId = @intItemId
				AND intUnitMeasureId = @intUnitMeasureId
				AND dtmBeginDate <= @dtmDate
				AND ISNULL(dtmEndDate, '1/1/9999') >= @dtmDate
				AND intProgramChargeId = @intProgramChargeId
	)
	BEGIN
		INSERT INTO @tblReturnValue (dblRate,intProgramRateId)
		SELECT TOP 1 dblRatePerUnit, intRateId 
			  FROM tblBBRate
			  WHERE intCustomerLocationId IS NULL
				AND intItemId = @intItemId
				AND intUnitMeasureId = @intUnitMeasureId
				AND dtmBeginDate <= @dtmDate
				AND ISNULL(dtmEndDate,'1/1/9999') >= @dtmDate
				AND intProgramChargeId = @intProgramChargeId
		RETURN
	END

	---UOM
	IF EXISTS(SELECT TOP 1 1 
			  FROM tblBBRate
			  WHERE intCustomerLocationId IS NULL
				AND intItemId IS NULL
				AND intUnitMeasureId = @intUnitMeasureId
				AND dtmBeginDate <= @dtmDate
				AND ISNULL(dtmEndDate,'1/1/9999') >= @dtmDate
				AND intProgramChargeId = @intProgramChargeId
	)
	BEGIN
		INSERT INTO @tblReturnValue (dblRate,intProgramRateId)
		SELECT TOP 1 dblRatePerUnit, intRateId 
			  FROM tblBBRate
			  WHERE intCustomerLocationId IS NULL
				AND intItemId IS NULL
				AND intUnitMeasureId = @intUnitMeasureId
				AND dtmBeginDate <= @dtmDate
				AND ISNULL(dtmEndDate,'1/1/9999') >= @dtmDate
				AND intProgramChargeId = @intProgramChargeId
		RETURN
	END

	RETURN
END

GO