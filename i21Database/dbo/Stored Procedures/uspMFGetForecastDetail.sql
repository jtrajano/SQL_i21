﻿CREATE PROCEDURE dbo.uspMFGetForecastDetail (
	@intAccountManagerId INT
	,@intBuyingGroupId INT
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
		,FV.intJAN
		,FV.intFEB
		,FV.intMAR
		,FV.intAPR
		,FV.intMAY
		,FV.intJUN
		,FV.intJUL
		,FV.intAUG
		,FV.intSEP
		,FV.intOCT
		,FV.intNOV
		,FV.intDEC
		,FV.intTotal
		,FV.dblMonthlyAvg
	FROM dbo.tblMFForecastItemValue FV
	JOIN dbo.tblMFForecastItemType FT ON FV.intForecastItemTypeId = FT.intForecastItemTypeId
	JOIN dbo.tblICItem I ON I.intItemId = FV.intItemId
	WHERE I.intAccountManagerId = @intAccountManagerId
		AND I.intBuyingGroupId = @intBuyingGroupId
		AND I.intItemId = @intItemId
		AND FV.intForecastItemTypeId IN (
			@intForecast
			,@intOrder
			,@intShipped
			)
	ORDER BY FV.intYear
		,FV.intForecastItemTypeId
END

