CREATE PROCEDURE dbo.uspMFGetForecastDetail (
	@intAccountManagerId INT=0
	,@intBuyingGroupId INT=0
	,@intItemId INT
	,@ysnIncludeForecast BIT = 1
	,@ysnIncludeOrder BIT = 1
	,@ysnIncludeShipped BIT = 1
	)
AS
BEGIN
	DECLARE @intForecast INT
		,@intOrder INT
		,@intShipped INT

	SELECT @intForecast = 0
		,@intOrder = 0
		,@intShipped = 0

	IF @ysnIncludeForecast = 1
		SELECT @intForecast = 1

	IF @ysnIncludeOrder = 1
		SELECT @intOrder = 2

	IF @ysnIncludeShipped = 1
		SELECT @intShipped = 3

	SELECT FV.intForecastItemValueId
		,CASE 
			WHEN FV.intYear < YEAR(GETDATE()) - 1
				THEN 'History'
			ELSE 'Current'
			END AS strYearType
		,FV.intYear
		,FT.strType
		,FV.dblJan
		,FV.dblFeb
		,FV.dblMar
		,FV.dblApr
		,FV.dblMay
		,FV.dblJun
		,FV.dblJul
		,FV.dblAug
		,FV.dblSep
		,FV.dblOct
		,FV.dblNov
		,FV.dblDec
		,FV.dblTotal
		,FV.dblMonthlyAvg
		,FV.intConcurrencyId
		,I.intItemId
	FROM dbo.tblMFForecastItemValue FV
	JOIN dbo.tblMFForecastItemType FT ON FV.intForecastItemTypeId = FT.intForecastItemTypeId
	JOIN dbo.tblICItem I ON I.intItemId = FV.intItemId
	WHERE ISNULL(I.intAccountManagerId,@intAccountManagerId) = @intAccountManagerId
		AND ISNULL(I.intBuyingGroupId,@intBuyingGroupId) = @intBuyingGroupId
		AND I.intItemId = @intItemId
		AND FV.intForecastItemTypeId IN (
			@intForecast
			,@intOrder
			,@intShipped
			)
	ORDER BY FV.intYear
		,FV.intForecastItemTypeId
END

