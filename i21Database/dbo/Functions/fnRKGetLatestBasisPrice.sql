CREATE FUNCTION [dbo].[fnRKGetLatestBasisPrice] (
	@intItemId INT
	,@dtmCurrentDate DATETIME
	)
RETURNS @returntable TABLE (
	dblBasisOrDiscount NUMERIC(18, 6)
	,intUnitMeasureId INT
	,strUnitMeasure NVARCHAR(100)
	,intItemUOMId INT
	)
AS
BEGIN
	DECLARE @intM2MBasisId INT;
	DECLARE @intFutureMonthId INT;
	DECLARE @strFutureMonth NVARCHAR(100);

	WITH cte
	AS (
		SELECT t.intM2MBasisId
			,t.dtmM2MBasisDate
			,ROW_NUMBER() OVER (
				ORDER BY ABS(DATEDIFF(dd, t.dtmM2MBasisDate, @dtmCurrentDate))
				) AS rowNum
		FROM tblRKM2MBasis t
		)
	SELECT @intM2MBasisId = intM2MBasisId
	FROM cte
	WHERE rowNum = 1;

	WITH cte
	AS (
		SELECT t.intFutureMonthId
			,t.dtmFutureMonthsDate
			,ROW_NUMBER() OVER (
				ORDER BY ABS(DATEDIFF(dd, t.dtmFutureMonthsDate, @dtmCurrentDate))
				) AS rowNum
		FROM tblRKFuturesMonth t
		)
	SELECT @intFutureMonthId = intFutureMonthId
	FROM cte
	WHERE rowNum = 1;

	SELECT @strFutureMonth = strFutureMonth
	FROM tblRKFuturesMonth
	WHERE intFutureMonthId = @intFutureMonthId

	INSERT INTO @returntable (
		dblBasisOrDiscount
		,intUnitMeasureId
		,strUnitMeasure
		,intItemUOMId
		)
	SELECT TOP 1 BD.dblBasisOrDiscount
		,BD.intUnitMeasureId
		,UM.strUnitMeasure
		,IU.intItemUOMId
	FROM tblRKM2MBasisDetail BD
	JOIN tblICUnitMeasure UM ON UM.intUnitMeasureId = BD.intUnitMeasureId
	JOIN tblICItemUOM IU ON IU.intUnitMeasureId = UM.intUnitMeasureId AND IU.intItemId = BD.intItemId
	WHERE intM2MBasisId = @intM2MBasisId
		AND BD.intItemId = @intItemId
		AND strPeriodTo = @strFutureMonth

	RETURN
END