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
			  FROM tblBBRate r
				OUTER APPLY (
					SELECT TOP 1 i.intUnitMeasureId
					FROM tblICItemUOM i 
					WHERE i.intItemId = r.intItemId
						AND i.intUnitMeasureId = @intUnitMeasureId
				) u
			  WHERE r.intCustomerLocationId = @intEntityLocationId
				AND r.intItemId = @intItemId
				AND (r.intUnitMeasureId = @intUnitMeasureId OR u.intUnitMeasureId IS NOT NULL)
				AND r.dtmBeginDate <= @dtmDate
				AND ISNULL(r.dtmEndDate,'1/1/9999') >= @dtmDate
				AND r.intProgramChargeId = @intProgramChargeId
	)
	BEGIN
		INSERT INTO @tblReturnValue (dblRate,intProgramRateId)
		SELECT TOP 1 dblRatePerUnit, intRateId 
			  FROM tblBBRate r
			  	OUTER APPLY (
					SELECT TOP 1 i.intUnitMeasureId
					FROM tblICItemUOM i 
					WHERE i.intItemId = r.intItemId
						AND i.intUnitMeasureId = @intUnitMeasureId
				) u
			  WHERE r.intCustomerLocationId = @intEntityLocationId
				AND r.intItemId = @intItemId
				AND (r.intUnitMeasureId = @intUnitMeasureId OR u.intUnitMeasureId IS NOT NULL)
				AND r.dtmBeginDate <= @dtmDate
				AND ISNULL(dtmEndDate ,'1/1/9999') >= @dtmDate
				AND r.intProgramChargeId = @intProgramChargeId
		RETURN
	END

	--itemid, uom
	IF EXISTS(SELECT TOP 1 1 
			  FROM tblBBRate r
			  OUTER APPLY (
					SELECT TOP 1 i.intUnitMeasureId
					FROM tblICItemUOM i 
					WHERE i.intItemId = r.intItemId
						AND i.intUnitMeasureId = @intUnitMeasureId
				) u
			  WHERE intCustomerLocationId IS NULL
				AND intItemId = @intItemId
				AND (r.intUnitMeasureId = @intUnitMeasureId OR u.intUnitMeasureId IS NOT NULL)
				AND dtmBeginDate <= @dtmDate
				AND ISNULL(dtmEndDate, '1/1/9999') >= @dtmDate
				AND intProgramChargeId = @intProgramChargeId
	)
	BEGIN
		INSERT INTO @tblReturnValue (dblRate,intProgramRateId)
		SELECT TOP 1 dblRatePerUnit, intRateId 
			  FROM tblBBRate r
			  OUTER APPLY (
					SELECT TOP 1 i.intUnitMeasureId
					FROM tblICItemUOM i 
					WHERE i.intItemId = r.intItemId
						AND i.intUnitMeasureId = @intUnitMeasureId
				) u
			  WHERE intCustomerLocationId IS NULL
				AND intItemId = @intItemId
				AND (r.intUnitMeasureId = @intUnitMeasureId OR u.intUnitMeasureId IS NOT NULL)
				AND dtmBeginDate <= @dtmDate
				AND ISNULL(dtmEndDate,'1/1/9999') >= @dtmDate
				AND intProgramChargeId = @intProgramChargeId
		RETURN
	END

	---UOM
	IF EXISTS(SELECT TOP 1 1 
			  FROM tblBBRate r
			  OUTER APPLY (
					SELECT TOP 1 i.intUnitMeasureId
					FROM tblICItemUOM i 
					WHERE i.intItemId = r.intItemId
						AND i.intUnitMeasureId = @intUnitMeasureId
				) u
			  WHERE intCustomerLocationId IS NULL
				AND intItemId IS NULL
				AND (r.intUnitMeasureId = @intUnitMeasureId OR u.intUnitMeasureId IS NOT NULL)
				AND dtmBeginDate <= @dtmDate
				AND ISNULL(dtmEndDate,'1/1/9999') >= @dtmDate
				AND intProgramChargeId = @intProgramChargeId
	)
	BEGIN
		INSERT INTO @tblReturnValue (dblRate,intProgramRateId)
		SELECT TOP 1 dblRatePerUnit, intRateId 
			  FROM tblBBRate r
			  OUTER APPLY (
					SELECT TOP 1 i.intUnitMeasureId
					FROM tblICItemUOM i 
					WHERE i.intItemId = r.intItemId
						AND i.intUnitMeasureId = @intUnitMeasureId
				) u
			  WHERE intCustomerLocationId IS NULL
				AND intItemId IS NULL
				AND (r.intUnitMeasureId = @intUnitMeasureId OR u.intUnitMeasureId IS NOT NULL)
				AND dtmBeginDate <= @dtmDate
				AND ISNULL(dtmEndDate,'1/1/9999') >= @dtmDate
				AND intProgramChargeId = @intProgramChargeId
		RETURN
	END

	RETURN
END

GO