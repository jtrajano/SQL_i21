﻿CREATE PROCEDURE uspMFGenerateDemandSummary (
	@strInvPlngReportMasterID NVARCHAR(MAX) = NULL
	,@intUnitMeasureId INT
	,@ysnRefreshContract BIT = 0
	,@intCompanyLocationId INT
	,@ysnLoadPlan BIT = 0
	)
AS
BEGIN
	IF @ysnLoadPlan = 1
	BEGIN
		SELECT strBook
			,strSubBook
			,strMainItemNo strCode
			,strMainDescription strGCQuality
			,strItemNo strQualityDesc
			,0 As strWorkingStockBenchmark
			,[Opening Inventory strMonth1]
			,[Forecasted Consumption strMonth1]
			,[Open Purchases strMonth1]
			,[Short/Excess Inventory strMonth1]
			,[Ending Inventory strMonth1]
			,[Opening Inventory strMonth2]
			,[Forecasted Consumption strMonth2]
			,[Open Purchases strMonth2]
			,[Short/Excess Inventory strMonth2]
			,[Ending Inventory strMonth2]
			,[Opening Inventory strMonth3]
			,[Forecasted Consumption strMonth3]
			,[Open Purchases strMonth3]
			,[Short/Excess Inventory strMonth3]
			,[Ending Inventory strMonth3]
			,[Opening Inventory strMonth4]
			,[Forecasted Consumption strMonth4]
			,[Open Purchases strMonth4]
			,[Short/Excess Inventory strMonth4]
			,[Ending Inventory strMonth4]
			,[Opening Inventory strMonth5]
			,[Forecasted Consumption strMonth5]
			,[Open Purchases strMonth5]
			,[Short/Excess Inventory strMonth5]
			,[Ending Inventory strMonth5]
			,[Opening Inventory strMonth6]
			,[Forecasted Consumption strMonth6]
			,[Open Purchases strMonth6]
			,[Short/Excess Inventory strMonth6]
			,[Ending Inventory strMonth6]
			,[Opening Inventory strMonth7]
			,[Forecasted Consumption strMonth7]
			,[Open Purchases strMonth7]
			,[Short/Excess Inventory strMonth7]
			,[Ending Inventory strMonth7]
			,[Opening Inventory strMonth8]
			,[Forecasted Consumption strMonth8]
			,[Open Purchases strMonth8]
			,[Short/Excess Inventory strMonth8]
			,[Ending Inventory strMonth8]
			,[Opening Inventory strMonth9]
			,[Forecasted Consumption strMonth9]
			,[Open Purchases strMonth9]
			,[Short/Excess Inventory strMonth9]
			,[Ending Inventory strMonth9]
			,[Opening Inventory strMonth10]
			,[Forecasted Consumption strMonth10]
			,[Open Purchases strMonth10]
			,[Short/Excess Inventory strMonth10]
			,[Ending Inventory strMonth10]
			,[Opening Inventory strMonth11]
			,[Forecasted Consumption strMonth11]
			,[Open Purchases strMonth11]
			,[Short/Excess Inventory strMonth11]
			,[Ending Inventory strMonth11]
			,[Opening Inventory strMonth12]
			,[Forecasted Consumption strMonth12]
			,[Open Purchases strMonth12]
			,[Short/Excess Inventory strMonth12]
			,[Ending Inventory strMonth12]
			,[Opening Inventory strMonth13]
			,[Forecasted Consumption strMonth13]
			,[Open Purchases strMonth13]
			,[Short/Excess Inventory strMonth13]
			,[Ending Inventory strMonth13]
			,[Opening Inventory strMonth14]
			,[Forecasted Consumption strMonth14]
			,[Open Purchases strMonth14]
			,[Short/Excess Inventory strMonth14]
			,[Ending Inventory strMonth14]
			,[Opening Inventory strMonth15]
			,[Forecasted Consumption strMonth15]
			,[Open Purchases strMonth15]
			,[Short/Excess Inventory strMonth15]
			,[Ending Inventory strMonth15]
			,[Opening Inventory strMonth16]
			,[Forecasted Consumption strMonth16]
			,[Open Purchases strMonth16]
			,[Short/Excess Inventory strMonth16]
			,[Ending Inventory strMonth16]
			,[Opening Inventory strMonth17]
			,[Forecasted Consumption strMonth17]
			,[Open Purchases strMonth17]
			,[Short/Excess Inventory strMonth17]
			,[Ending Inventory strMonth17]
			,[Opening Inventory strMonth18]
			,[Forecasted Consumption strMonth18]
			,[Open Purchases strMonth18]
			,[Short/Excess Inventory strMonth18]
			,[Ending Inventory strMonth18]
			,[Opening Inventory strMonth19]
			,[Forecasted Consumption strMonth19]
			,[Open Purchases strMonth19]
			,[Short/Excess Inventory strMonth19]
			,[Ending Inventory strMonth19]
			,[Opening Inventory strMonth20]
			,[Forecasted Consumption strMonth20]
			,[Open Purchases strMonth20]
			,[Short/Excess Inventory strMonth20]
			,[Ending Inventory strMonth20]
			,[Opening Inventory strMonth21]
			,[Forecasted Consumption strMonth21]
			,[Open Purchases strMonth21]
			,[Short/Excess Inventory strMonth21]
			,[Ending Inventory strMonth21]
			,[Opening Inventory strMonth22]
			,[Forecasted Consumption strMonth22]
			,[Open Purchases strMonth22]
			,[Short/Excess Inventory strMonth22]
			,[Ending Inventory strMonth22]
			,[Opening Inventory strMonth23]
			,[Forecasted Consumption strMonth23]
			,[Open Purchases strMonth23]
			,[Short/Excess Inventory strMonth23]
			,[Ending Inventory strMonth23]
			,[Opening Inventory strMonth24]
			,[Forecasted Consumption strMonth24]
			,[Open Purchases strMonth24]
			,[Short/Excess Inventory strMonth24]
			,[Ending Inventory strMonth24]
		FROM (
			SELECT MI.strItemNo AS strMainItemNo
				,MI.strDescription AS strMainDescription
				,I.strItemNo
				,B.strBook
				,SB.strSubBook
				,A.strAttributeName + ' ' + AV.strFieldName AS strAttributeName
				,Convert(NUMERIC(18, 6), CASE 
						WHEN AV.strValue = ''
							THEN 0.0
						ELSE AV.strValue
						END) strValue
			FROM tblMFInvPlngSummaryDetail AV
			JOIN tblCTReportAttribute A ON A.intReportAttributeID = AV.intAttributeId
			JOIN tblCTInvPlngReportMaster RM ON RM.intInvPlngReportMasterID = A.intReportMasterID
			LEFT JOIN tblICItem MI ON MI.intItemId = AV.intMainItemId
			JOIN tblICItem I ON I.intItemId = AV.intItemId
			LEFT JOIN tblCTBook B ON B.intBookId = RM.intBookId
			LEFT JOIN tblCTSubBook SB ON SB.intSubBookId = RM.intSubBookId
			WHERE A.intReportAttributeID IN (
					2 --Opening Inventory
					,8 --Forecasted Consumption
					,9 --Ending Inventory
					,12 --Short/Excess Inventory
					,13 --Open Purchases
					)
				AND IsNumeric(AV.strValue) = 0
				AND RM.intInvPlngReportMasterID IN (
					SELECT Item Collate Latin1_General_CI_AS
					FROM [dbo].[fnSplitString](@strInvPlngReportMasterID, ',')
					)
				--2-Opening Inventory;8-Forecasted Consumption;9-Ending Inventory;13-Open Purchases;12-Short/Excess Inventory
			) AS SourceTable
		PIVOT(SUM(strValue) FOR strAttributeName IN (
					[Opening Inventory strMonth1]
					,[Forecasted Consumption strMonth1]
					,[Open Purchases strMonth1]
					,[Short/Excess Inventory strMonth1]
					,[Ending Inventory strMonth1]
					,[Opening Inventory strMonth2]
					,[Forecasted Consumption strMonth2]
					,[Open Purchases strMonth2]
					,[Short/Excess Inventory strMonth2]
					,[Ending Inventory strMonth2]
					,[Opening Inventory strMonth3]
					,[Forecasted Consumption strMonth3]
					,[Open Purchases strMonth3]
					,[Short/Excess Inventory strMonth3]
					,[Ending Inventory strMonth3]
					,[Opening Inventory strMonth4]
					,[Forecasted Consumption strMonth4]
					,[Open Purchases strMonth4]
					,[Short/Excess Inventory strMonth4]
					,[Ending Inventory strMonth4]
					,[Opening Inventory strMonth5]
					,[Forecasted Consumption strMonth5]
					,[Open Purchases strMonth5]
					,[Short/Excess Inventory strMonth5]
					,[Ending Inventory strMonth5]
					,[Opening Inventory strMonth6]
					,[Forecasted Consumption strMonth6]
					,[Open Purchases strMonth6]
					,[Short/Excess Inventory strMonth6]
					,[Ending Inventory strMonth6]
					,[Opening Inventory strMonth7]
					,[Forecasted Consumption strMonth7]
					,[Open Purchases strMonth7]
					,[Short/Excess Inventory strMonth7]
					,[Ending Inventory strMonth7]
					,[Opening Inventory strMonth8]
					,[Forecasted Consumption strMonth8]
					,[Open Purchases strMonth8]
					,[Short/Excess Inventory strMonth8]
					,[Ending Inventory strMonth8]
					,[Opening Inventory strMonth9]
					,[Forecasted Consumption strMonth9]
					,[Open Purchases strMonth9]
					,[Short/Excess Inventory strMonth9]
					,[Ending Inventory strMonth9]
					,[Opening Inventory strMonth10]
					,[Forecasted Consumption strMonth10]
					,[Open Purchases strMonth10]
					,[Short/Excess Inventory strMonth10]
					,[Ending Inventory strMonth10]
					,[Opening Inventory strMonth11]
					,[Forecasted Consumption strMonth11]
					,[Open Purchases strMonth11]
					,[Short/Excess Inventory strMonth11]
					,[Ending Inventory strMonth11]
					,[Opening Inventory strMonth12]
					,[Forecasted Consumption strMonth12]
					,[Open Purchases strMonth12]
					,[Short/Excess Inventory strMonth12]
					,[Ending Inventory strMonth12]
					,[Opening Inventory strMonth13]
					,[Forecasted Consumption strMonth13]
					,[Open Purchases strMonth13]
					,[Short/Excess Inventory strMonth13]
					,[Ending Inventory strMonth13]
					,[Opening Inventory strMonth14]
					,[Forecasted Consumption strMonth14]
					,[Open Purchases strMonth14]
					,[Short/Excess Inventory strMonth14]
					,[Ending Inventory strMonth14]
					,[Opening Inventory strMonth15]
					,[Forecasted Consumption strMonth15]
					,[Open Purchases strMonth15]
					,[Short/Excess Inventory strMonth15]
					,[Ending Inventory strMonth15]
					,[Opening Inventory strMonth16]
					,[Forecasted Consumption strMonth16]
					,[Open Purchases strMonth16]
					,[Short/Excess Inventory strMonth16]
					,[Ending Inventory strMonth16]
					,[Opening Inventory strMonth17]
					,[Forecasted Consumption strMonth17]
					,[Open Purchases strMonth17]
					,[Short/Excess Inventory strMonth17]
					,[Ending Inventory strMonth17]
					,[Opening Inventory strMonth18]
					,[Forecasted Consumption strMonth18]
					,[Open Purchases strMonth18]
					,[Short/Excess Inventory strMonth18]
					,[Ending Inventory strMonth18]
					,[Opening Inventory strMonth19]
					,[Forecasted Consumption strMonth19]
					,[Open Purchases strMonth19]
					,[Short/Excess Inventory strMonth19]
					,[Ending Inventory strMonth19]
					,[Opening Inventory strMonth20]
					,[Forecasted Consumption strMonth20]
					,[Open Purchases strMonth20]
					,[Short/Excess Inventory strMonth20]
					,[Ending Inventory strMonth20]
					,[Opening Inventory strMonth21]
					,[Forecasted Consumption strMonth21]
					,[Open Purchases strMonth21]
					,[Short/Excess Inventory strMonth21]
					,[Ending Inventory strMonth21]
					,[Opening Inventory strMonth22]
					,[Forecasted Consumption strMonth22]
					,[Open Purchases strMonth22]
					,[Short/Excess Inventory strMonth22]
					,[Ending Inventory strMonth22]
					,[Opening Inventory strMonth23]
					,[Forecasted Consumption strMonth23]
					,[Open Purchases strMonth23]
					,[Short/Excess Inventory strMonth23]
					,[Ending Inventory strMonth23]
					,[Opening Inventory strMonth24]
					,[Forecasted Consumption strMonth24]
					,[Open Purchases strMonth24]
					,[Short/Excess Inventory strMonth24]
					,[Ending Inventory strMonth24]
					)) AS PivotTable;

		SELECT [strMonth1]
			,[strMonth2]
			,[strMonth3]
			,[strMonth4]
			,[strMonth5]
			,[strMonth6]
			,[strMonth7]
			,[strMonth8]
			,[strMonth9]
			,[strMonth10]
			,[strMonth11]
			,[strMonth12]
			,[strMonth13]
			,[strMonth14]
			,[strMonth15]
			,[strMonth16]
			,[strMonth17]
			,[strMonth18]
			,[strMonth19]
			,[strMonth20]
			,[strMonth21]
			,[strMonth22]
			,[strMonth23]
			,[strMonth24]
		FROM (
			SELECT strFieldName
				,strValue
			FROM tblMFInvPlngSummaryDetail SD
			JOIN tblCTReportAttribute RA ON RA.intReportAttributeID = SD.intAttributeId
			WHERE intAttributeId = 1
				AND RA.intReportMasterID IN (
					SELECT Item Collate Latin1_General_CI_AS
					FROM [dbo].[fnSplitString](@strInvPlngReportMasterID, ',')
					)
				AND strValue <> ''
			) AS SourceTable
		PIVOT(MIN(strValue) FOR strFieldName IN (
					[strMonth1]
					,[strMonth2]
					,[strMonth3]
					,[strMonth4]
					,[strMonth5]
					,[strMonth6]
					,[strMonth7]
					,[strMonth8]
					,[strMonth9]
					,[strMonth10]
					,[strMonth11]
					,[strMonth12]
					,[strMonth13]
					,[strMonth14]
					,[strMonth15]
					,[strMonth16]
					,[strMonth17]
					,[strMonth18]
					,[strMonth19]
					,[strMonth20]
					,[strMonth21]
					,[strMonth22]
					,[strMonth23]
					,[strMonth24]
					)) AS PivotTable;
	END
	ELSE
	BEGIN
		IF @ysnRefreshContract = 0
		BEGIN
			SELECT strBook
				,strSubBook
				,strMainItemNo strCode
				,strMainDescription strGCQuality
				,strItemNo strQualityDesc
				,0 As strWorkingStockBenchmark
				,[Opening Inventory strMonth1]
				,[Forecasted Consumption strMonth1]
				,[Open Purchases strMonth1]
				,[Short/Excess Inventory strMonth1]
				,[Ending Inventory strMonth1]
				,[Opening Inventory strMonth2]
				,[Forecasted Consumption strMonth2]
				,[Open Purchases strMonth2]
				,[Short/Excess Inventory strMonth2]
				,[Ending Inventory strMonth2]
				,[Opening Inventory strMonth3]
				,[Forecasted Consumption strMonth3]
				,[Open Purchases strMonth3]
				,[Short/Excess Inventory strMonth3]
				,[Ending Inventory strMonth3]
				,[Opening Inventory strMonth4]
				,[Forecasted Consumption strMonth4]
				,[Open Purchases strMonth4]
				,[Short/Excess Inventory strMonth4]
				,[Ending Inventory strMonth4]
				,[Opening Inventory strMonth5]
				,[Forecasted Consumption strMonth5]
				,[Open Purchases strMonth5]
				,[Short/Excess Inventory strMonth5]
				,[Ending Inventory strMonth5]
				,[Opening Inventory strMonth6]
				,[Forecasted Consumption strMonth6]
				,[Open Purchases strMonth6]
				,[Short/Excess Inventory strMonth6]
				,[Ending Inventory strMonth6]
				,[Opening Inventory strMonth7]
				,[Forecasted Consumption strMonth7]
				,[Open Purchases strMonth7]
				,[Short/Excess Inventory strMonth7]
				,[Ending Inventory strMonth7]
				,[Opening Inventory strMonth8]
				,[Forecasted Consumption strMonth8]
				,[Open Purchases strMonth8]
				,[Short/Excess Inventory strMonth8]
				,[Ending Inventory strMonth8]
				,[Opening Inventory strMonth9]
				,[Forecasted Consumption strMonth9]
				,[Open Purchases strMonth9]
				,[Short/Excess Inventory strMonth9]
				,[Ending Inventory strMonth9]
				,[Opening Inventory strMonth10]
				,[Forecasted Consumption strMonth10]
				,[Open Purchases strMonth10]
				,[Short/Excess Inventory strMonth10]
				,[Ending Inventory strMonth10]
				,[Opening Inventory strMonth11]
				,[Forecasted Consumption strMonth11]
				,[Open Purchases strMonth11]
				,[Short/Excess Inventory strMonth11]
				,[Ending Inventory strMonth11]
				,[Opening Inventory strMonth12]
				,[Forecasted Consumption strMonth12]
				,[Open Purchases strMonth12]
				,[Short/Excess Inventory strMonth12]
				,[Ending Inventory strMonth12]
				,[Opening Inventory strMonth13]
				,[Forecasted Consumption strMonth13]
				,[Open Purchases strMonth13]
				,[Short/Excess Inventory strMonth13]
				,[Ending Inventory strMonth13]
				,[Opening Inventory strMonth14]
				,[Forecasted Consumption strMonth14]
				,[Open Purchases strMonth14]
				,[Short/Excess Inventory strMonth14]
				,[Ending Inventory strMonth14]
				,[Opening Inventory strMonth15]
				,[Forecasted Consumption strMonth15]
				,[Open Purchases strMonth15]
				,[Short/Excess Inventory strMonth15]
				,[Ending Inventory strMonth15]
				,[Opening Inventory strMonth16]
				,[Forecasted Consumption strMonth16]
				,[Open Purchases strMonth16]
				,[Short/Excess Inventory strMonth16]
				,[Ending Inventory strMonth16]
				,[Opening Inventory strMonth17]
				,[Forecasted Consumption strMonth17]
				,[Open Purchases strMonth17]
				,[Short/Excess Inventory strMonth17]
				,[Ending Inventory strMonth17]
				,[Opening Inventory strMonth18]
				,[Forecasted Consumption strMonth18]
				,[Open Purchases strMonth18]
				,[Short/Excess Inventory strMonth18]
				,[Ending Inventory strMonth18]
				,[Opening Inventory strMonth19]
				,[Forecasted Consumption strMonth19]
				,[Open Purchases strMonth19]
				,[Short/Excess Inventory strMonth19]
				,[Ending Inventory strMonth19]
				,[Opening Inventory strMonth20]
				,[Forecasted Consumption strMonth20]
				,[Open Purchases strMonth20]
				,[Short/Excess Inventory strMonth20]
				,[Ending Inventory strMonth20]
				,[Opening Inventory strMonth21]
				,[Forecasted Consumption strMonth21]
				,[Open Purchases strMonth21]
				,[Short/Excess Inventory strMonth21]
				,[Ending Inventory strMonth21]
				,[Opening Inventory strMonth22]
				,[Forecasted Consumption strMonth22]
				,[Open Purchases strMonth22]
				,[Short/Excess Inventory strMonth22]
				,[Ending Inventory strMonth22]
				,[Opening Inventory strMonth23]
				,[Forecasted Consumption strMonth23]
				,[Open Purchases strMonth23]
				,[Short/Excess Inventory strMonth23]
				,[Ending Inventory strMonth23]
				,[Opening Inventory strMonth24]
				,[Forecasted Consumption strMonth24]
				,[Open Purchases strMonth24]
				,[Short/Excess Inventory strMonth24]
				,[Ending Inventory strMonth24]
			FROM (
				SELECT MI.strItemNo AS strMainItemNo
					,MI.strDescription AS strMainDescription
					,I.strItemNo
					,B.strBook
					,SB.strSubBook
					,A.strAttributeName + ' ' + AV.strFieldName AS strAttributeName
					,Convert(NUMERIC(18, 6), CASE 
							WHEN AV.strValue = ''
								THEN 0.0
							ELSE AV.strValue
							END) strValue
				FROM tblCTInvPlngReportAttributeValue AV
				JOIN tblCTReportAttribute A ON A.intReportAttributeID = AV.intReportAttributeID
				JOIN tblCTInvPlngReportMaster RM ON RM.intInvPlngReportMasterID = AV.intInvPlngReportMasterID
				LEFT JOIN tblICItem MI ON MI.intItemId = AV.intMainItemId
				JOIN tblICItem I ON I.intItemId = AV.intItemId
				LEFT JOIN tblCTBook B ON B.intBookId = RM.intBookId
				LEFT JOIN tblCTSubBook SB ON SB.intSubBookId = RM.intSubBookId
				WHERE A.intReportAttributeID IN (
						2 --Opening Inventory
						,8 --Forecasted Consumption
						,9 --Ending Inventory
						,12 --Short/Excess Inventory
						,13 --Open Purchases
						)
					AND IsNumeric(AV.strValue) = 0
					AND RM.intInvPlngReportMasterID IN (
						SELECT Item Collate Latin1_General_CI_AS
						FROM [dbo].[fnSplitString](@strInvPlngReportMasterID, ',')
						)
					--2-Opening Inventory;8-Forecasted Consumption;9-Ending Inventory;13-Open Purchases;12-Short/Excess Inventory
				) AS SourceTable
			PIVOT(SUM(strValue) FOR strAttributeName IN (
						[Opening Inventory strMonth1]
						,[Forecasted Consumption strMonth1]
						,[Open Purchases strMonth1]
						,[Short/Excess Inventory strMonth1]
						,[Ending Inventory strMonth1]
						,[Opening Inventory strMonth2]
						,[Forecasted Consumption strMonth2]
						,[Open Purchases strMonth2]
						,[Short/Excess Inventory strMonth2]
						,[Ending Inventory strMonth2]
						,[Opening Inventory strMonth3]
						,[Forecasted Consumption strMonth3]
						,[Open Purchases strMonth3]
						,[Short/Excess Inventory strMonth3]
						,[Ending Inventory strMonth3]
						,[Opening Inventory strMonth4]
						,[Forecasted Consumption strMonth4]
						,[Open Purchases strMonth4]
						,[Short/Excess Inventory strMonth4]
						,[Ending Inventory strMonth4]
						,[Opening Inventory strMonth5]
						,[Forecasted Consumption strMonth5]
						,[Open Purchases strMonth5]
						,[Short/Excess Inventory strMonth5]
						,[Ending Inventory strMonth5]
						,[Opening Inventory strMonth6]
						,[Forecasted Consumption strMonth6]
						,[Open Purchases strMonth6]
						,[Short/Excess Inventory strMonth6]
						,[Ending Inventory strMonth6]
						,[Opening Inventory strMonth7]
						,[Forecasted Consumption strMonth7]
						,[Open Purchases strMonth7]
						,[Short/Excess Inventory strMonth7]
						,[Ending Inventory strMonth7]
						,[Opening Inventory strMonth8]
						,[Forecasted Consumption strMonth8]
						,[Open Purchases strMonth8]
						,[Short/Excess Inventory strMonth8]
						,[Ending Inventory strMonth8]
						,[Opening Inventory strMonth9]
						,[Forecasted Consumption strMonth9]
						,[Open Purchases strMonth9]
						,[Short/Excess Inventory strMonth9]
						,[Ending Inventory strMonth9]
						,[Opening Inventory strMonth10]
						,[Forecasted Consumption strMonth10]
						,[Open Purchases strMonth10]
						,[Short/Excess Inventory strMonth10]
						,[Ending Inventory strMonth10]
						,[Opening Inventory strMonth11]
						,[Forecasted Consumption strMonth11]
						,[Open Purchases strMonth11]
						,[Short/Excess Inventory strMonth11]
						,[Ending Inventory strMonth11]
						,[Opening Inventory strMonth12]
						,[Forecasted Consumption strMonth12]
						,[Open Purchases strMonth12]
						,[Short/Excess Inventory strMonth12]
						,[Ending Inventory strMonth12]
						,[Opening Inventory strMonth13]
						,[Forecasted Consumption strMonth13]
						,[Open Purchases strMonth13]
						,[Short/Excess Inventory strMonth13]
						,[Ending Inventory strMonth13]
						,[Opening Inventory strMonth14]
						,[Forecasted Consumption strMonth14]
						,[Open Purchases strMonth14]
						,[Short/Excess Inventory strMonth14]
						,[Ending Inventory strMonth14]
						,[Opening Inventory strMonth15]
						,[Forecasted Consumption strMonth15]
						,[Open Purchases strMonth15]
						,[Short/Excess Inventory strMonth15]
						,[Ending Inventory strMonth15]
						,[Opening Inventory strMonth16]
						,[Forecasted Consumption strMonth16]
						,[Open Purchases strMonth16]
						,[Short/Excess Inventory strMonth16]
						,[Ending Inventory strMonth16]
						,[Opening Inventory strMonth17]
						,[Forecasted Consumption strMonth17]
						,[Open Purchases strMonth17]
						,[Short/Excess Inventory strMonth17]
						,[Ending Inventory strMonth17]
						,[Opening Inventory strMonth18]
						,[Forecasted Consumption strMonth18]
						,[Open Purchases strMonth18]
						,[Short/Excess Inventory strMonth18]
						,[Ending Inventory strMonth18]
						,[Opening Inventory strMonth19]
						,[Forecasted Consumption strMonth19]
						,[Open Purchases strMonth19]
						,[Short/Excess Inventory strMonth19]
						,[Ending Inventory strMonth19]
						,[Opening Inventory strMonth20]
						,[Forecasted Consumption strMonth20]
						,[Open Purchases strMonth20]
						,[Short/Excess Inventory strMonth20]
						,[Ending Inventory strMonth20]
						,[Opening Inventory strMonth21]
						,[Forecasted Consumption strMonth21]
						,[Open Purchases strMonth21]
						,[Short/Excess Inventory strMonth21]
						,[Ending Inventory strMonth21]
						,[Opening Inventory strMonth22]
						,[Forecasted Consumption strMonth22]
						,[Open Purchases strMonth22]
						,[Short/Excess Inventory strMonth22]
						,[Ending Inventory strMonth22]
						,[Opening Inventory strMonth23]
						,[Forecasted Consumption strMonth23]
						,[Open Purchases strMonth23]
						,[Short/Excess Inventory strMonth23]
						,[Ending Inventory strMonth23]
						,[Opening Inventory strMonth24]
						,[Forecasted Consumption strMonth24]
						,[Open Purchases strMonth24]
						,[Short/Excess Inventory strMonth24]
						,[Ending Inventory strMonth24]
						)) AS PivotTable;
		END
		ELSE
		BEGIN
			DECLARE @intReportMasterID INT
				,@dtmDate DATETIME
				--,@dtmStartOfMonth DATETIME
				,@intCurrentMonth INT

			IF OBJECT_ID('tempdb..#tblMFDemand') IS NOT NULL
				DROP TABLE #tblMFDemand

			CREATE TABLE #tblMFDemand (
				intItemId INT
				,dblQty NUMERIC(18, 6)
				,intAttributeId INT
				,intMonthId INT
				,intMainItemId INT
				)

			IF OBJECT_ID('tempdb..#tblMFFinalDemand') IS NOT NULL
				DROP TABLE #tblMFFinalDemand

			CREATE TABLE #tblMFFinalDemand (
				intItemId INT
				,dblQty NUMERIC(18, 6)
				,intAttributeId INT
				,intMonthId INT
				,intMainItemId INT
				)

			DECLARE @tblMFItemDetail TABLE (
				intItemId INT
				,intMainItemId INT
				,ysnSpecificItemDescription BIT
				,dblRatio NUMERIC(18, 6)
				)

			SELECT @intReportMasterID = intReportMasterID
			FROM tblCTReportMaster
			WHERE strReportName = 'Inventory Planning Report'

			SELECT @dtmDate = Max(dtmDate)
			FROM tblCTInvPlngReportMaster
			WHERE ysnPost = 1

			--SELECT @dtmStartOfMonth = DATEADD(month, DATEDIFF(month, 0, @dtmDate), 0)
			SELECT @intCurrentMonth = DATEDIFF(mm, 0, @dtmDate)

			INSERT INTO @tblMFItemDetail (
				intItemId
				,intMainItemId
				,ysnSpecificItemDescription
				)
			SELECT DISTINCT intItemId
				,intMainItemId
				,CASE 
					WHEN intItemId <> intMainItemId
						THEN 1
					ELSE 0
					END AS ysnSpecificItemDescription
			FROM tblCTInvPlngReportAttributeValue
			WHERE intReportAttributeID = 13 --Open Purchases 
				AND intInvPlngReportMasterID IN (
					SELECT Item Collate Latin1_General_CI_AS
					FROM [dbo].[fnSplitString](@strInvPlngReportMasterID, ',')
					)

			INSERT INTO #tblMFDemand (
				intItemId
				,dblQty
				,intAttributeId
				,intMonthId
				,intMainItemId
				)
			SELECT CASE 
					WHEN I.ysnSpecificItemDescription = 1
						THEN I.intItemId
					ELSE I.intMainItemId
					END AS intItemId
				,sum(dbo.fnCTConvertQuantityToTargetItemUOM(SS.intItemId, IU.intUnitMeasureId, @intUnitMeasureId, SS.dblBalance) * I.dblRatio) AS dblIntrasitQty
				,13 AS intAttributeId --Open Purchases
				,DATEDIFF(mm, 0, SS.dtmUpdatedAvailabilityDate) + 1 - @intCurrentMonth AS intMonthId
				,I.intMainItemId
			FROM @tblMFItemDetail I
			JOIN dbo.tblCTContractDetail SS ON SS.intItemId = I.intItemId
			JOIN dbo.tblICItemUOM IU ON IU.intItemUOMId = SS.intItemUOMId
				AND ISNULL(SS.intCompanyLocationId, 0) = (
					CASE 
						WHEN @intCompanyLocationId = 0
							THEN ISNULL(SS.intCompanyLocationId, 0)
						ELSE @intCompanyLocationId
						END
					)
			WHERE SS.intContractStatusId = 1
				AND SS.dtmUpdatedAvailabilityDate > @dtmDate
			GROUP BY CASE 
					WHEN I.ysnSpecificItemDescription = 1
						THEN I.intItemId
					ELSE I.intMainItemId
					END
				,DATEDIFF(mm, 0, SS.dtmUpdatedAvailabilityDate) + 1 - @intCurrentMonth
				,I.intMainItemId

			INSERT INTO #tblMFDemand (
				intItemId
				,dblQty
				,intAttributeId
				,intMonthId
				,intMainItemId
				)
			SELECT intItemId
				,- dblQty
				,12 AS intAttributeId --Short/Excess Inventory
				,intMonthId
				,intMainItemId
			FROM #tblMFDemand

			INSERT INTO #tblMFDemand (
				intItemId
				,dblQty
				,intAttributeId
				,intMonthId
				)
			SELECT intItemId
				,CASE 
					WHEN strValue = ''
						THEN NULL
					ELSE strValue
					END
				,intReportAttributeID
				,Replace(Replace(Replace(strFieldName, 'strMonth', ''), 'OpeningInv', '-1'), 'PastDue', '0') intMonthId
			FROM tblCTInvPlngReportAttributeValue
			WHERE intReportAttributeID IN (
					2
					,--Opening Inventory
					13
					,--Open Purchases
					12
					,--Short/Excess Inventory
					8
					,--Forecasted Consumption
					9 --Ending Inventory
					)
				AND intInvPlngReportMasterID IN (
					SELECT Item Collate Latin1_General_CI_AS
					FROM [dbo].[fnSplitString](@strInvPlngReportMasterID, ',')
					)

			INSERT INTO #tblMFFinalDemand (
				intItemId
				,dblQty
				,intAttributeId
				,intMonthId
				,intMainItemId
				)
			SELECT intItemId
				,SUM(dblQty) AS dblQty
				,intAttributeId
				,intMonthId
				,intMainItemId
			FROM #tblMFDemand
			GROUP BY intItemId
				,intAttributeId
				,intMonthId
				,intMainItemId

			SELECT strBook
				,strSubBook
				,strMainItemNo strCode
				,strMainDescription strGCQuality
				,strItemNo strQualityDesc
				,0 As strWorkingStockBenchmark
				,[Opening Inventory strMonth1]
				,[Forecasted Consumption strMonth1]
				,[Open Purchases strMonth1]
				,[Short/Excess Inventory strMonth1]
				,[Ending Inventory strMonth1]
				,[Opening Inventory strMonth2]
				,[Forecasted Consumption strMonth2]
				,[Open Purchases strMonth2]
				,[Short/Excess Inventory strMonth2]
				,[Ending Inventory strMonth2]
				,[Opening Inventory strMonth3]
				,[Forecasted Consumption strMonth3]
				,[Open Purchases strMonth3]
				,[Short/Excess Inventory strMonth3]
				,[Ending Inventory strMonth3]
				,[Opening Inventory strMonth4]
				,[Forecasted Consumption strMonth4]
				,[Open Purchases strMonth4]
				,[Short/Excess Inventory strMonth4]
				,[Ending Inventory strMonth4]
				,[Opening Inventory strMonth5]
				,[Forecasted Consumption strMonth5]
				,[Open Purchases strMonth5]
				,[Short/Excess Inventory strMonth5]
				,[Ending Inventory strMonth5]
				,[Opening Inventory strMonth6]
				,[Forecasted Consumption strMonth6]
				,[Open Purchases strMonth6]
				,[Short/Excess Inventory strMonth6]
				,[Ending Inventory strMonth6]
				,[Opening Inventory strMonth7]
				,[Forecasted Consumption strMonth7]
				,[Open Purchases strMonth7]
				,[Short/Excess Inventory strMonth7]
				,[Ending Inventory strMonth7]
				,[Opening Inventory strMonth8]
				,[Forecasted Consumption strMonth8]
				,[Open Purchases strMonth8]
				,[Short/Excess Inventory strMonth8]
				,[Ending Inventory strMonth8]
				,[Opening Inventory strMonth9]
				,[Forecasted Consumption strMonth9]
				,[Open Purchases strMonth9]
				,[Short/Excess Inventory strMonth9]
				,[Ending Inventory strMonth9]
				,[Opening Inventory strMonth10]
				,[Forecasted Consumption strMonth10]
				,[Open Purchases strMonth10]
				,[Short/Excess Inventory strMonth10]
				,[Ending Inventory strMonth10]
				,[Opening Inventory strMonth11]
				,[Forecasted Consumption strMonth11]
				,[Open Purchases strMonth11]
				,[Short/Excess Inventory strMonth11]
				,[Ending Inventory strMonth11]
				,[Opening Inventory strMonth12]
				,[Forecasted Consumption strMonth12]
				,[Open Purchases strMonth12]
				,[Short/Excess Inventory strMonth12]
				,[Ending Inventory strMonth12]
				,[Opening Inventory strMonth13]
				,[Forecasted Consumption strMonth13]
				,[Open Purchases strMonth13]
				,[Short/Excess Inventory strMonth13]
				,[Ending Inventory strMonth13]
				,[Opening Inventory strMonth14]
				,[Forecasted Consumption strMonth14]
				,[Open Purchases strMonth14]
				,[Short/Excess Inventory strMonth14]
				,[Ending Inventory strMonth14]
				,[Opening Inventory strMonth15]
				,[Forecasted Consumption strMonth15]
				,[Open Purchases strMonth15]
				,[Short/Excess Inventory strMonth15]
				,[Ending Inventory strMonth15]
				,[Opening Inventory strMonth16]
				,[Forecasted Consumption strMonth16]
				,[Open Purchases strMonth16]
				,[Short/Excess Inventory strMonth16]
				,[Ending Inventory strMonth16]
				,[Opening Inventory strMonth17]
				,[Forecasted Consumption strMonth17]
				,[Open Purchases strMonth17]
				,[Short/Excess Inventory strMonth17]
				,[Ending Inventory strMonth17]
				,[Opening Inventory strMonth18]
				,[Forecasted Consumption strMonth18]
				,[Open Purchases strMonth18]
				,[Short/Excess Inventory strMonth18]
				,[Ending Inventory strMonth18]
				,[Opening Inventory strMonth19]
				,[Forecasted Consumption strMonth19]
				,[Open Purchases strMonth19]
				,[Short/Excess Inventory strMonth19]
				,[Ending Inventory strMonth19]
				,[Opening Inventory strMonth20]
				,[Forecasted Consumption strMonth20]
				,[Open Purchases strMonth20]
				,[Short/Excess Inventory strMonth20]
				,[Ending Inventory strMonth20]
				,[Opening Inventory strMonth21]
				,[Forecasted Consumption strMonth21]
				,[Open Purchases strMonth21]
				,[Short/Excess Inventory strMonth21]
				,[Ending Inventory strMonth21]
				,[Opening Inventory strMonth22]
				,[Forecasted Consumption strMonth22]
				,[Open Purchases strMonth22]
				,[Short/Excess Inventory strMonth22]
				,[Ending Inventory strMonth22]
				,[Opening Inventory strMonth23]
				,[Forecasted Consumption strMonth23]
				,[Open Purchases strMonth23]
				,[Short/Excess Inventory strMonth23]
				,[Ending Inventory strMonth23]
				,[Opening Inventory strMonth24]
				,[Forecasted Consumption strMonth24]
				,[Open Purchases strMonth24]
				,[Short/Excess Inventory strMonth24]
				,[Ending Inventory strMonth24]
			FROM (
				SELECT MI.strItemNo AS strMainItemNo
					,MI.strDescription AS strMainDescription
					,I.strItemNo
					,B.strBook
					,SB.strSubBook
					,A.strAttributeName + ' strMonth' + CHAR(FD.intMonthId) AS strAttributeName
					,FD.dblQty strValue
				FROM #tblMFFinalDemand FD
				JOIN tblCTReportAttribute A ON A.intReportAttributeID = FD.intAttributeId
				JOIN tblCTInvPlngReportMaster RM ON RM.intInvPlngReportMasterID = @intReportMasterID
				LEFT JOIN tblICItem MI ON MI.intItemId = FD.intMainItemId
				JOIN tblICItem I ON I.intItemId = FD.intItemId
				LEFT JOIN tblCTBook B ON B.intBookId = RM.intBookId
				LEFT JOIN tblCTSubBook SB ON SB.intSubBookId = RM.intSubBookId
				WHERE A.intReportAttributeID IN (
						2
						,8
						,9
						,12
						,13
						)
					--AND IsNumeric(AV.strValue) = 0
					AND RM.intInvPlngReportMasterID IN (
						SELECT Item Collate Latin1_General_CI_AS
						FROM [dbo].[fnSplitString](@strInvPlngReportMasterID, ',')
						)
					--2-Opening Inventory;8-Forecasted Consumption;9-Ending Inventory;13-Open Purchases;12-Short/Excess Inventory
				) AS SourceTable
			PIVOT(SUM(strValue) FOR strAttributeName IN (
						[Opening Inventory strMonth1]
						,[Forecasted Consumption strMonth1]
						,[Open Purchases strMonth1]
						,[Short/Excess Inventory strMonth1]
						,[Ending Inventory strMonth1]
						,[Opening Inventory strMonth2]
						,[Forecasted Consumption strMonth2]
						,[Open Purchases strMonth2]
						,[Short/Excess Inventory strMonth2]
						,[Ending Inventory strMonth2]
						,[Opening Inventory strMonth3]
						,[Forecasted Consumption strMonth3]
						,[Open Purchases strMonth3]
						,[Short/Excess Inventory strMonth3]
						,[Ending Inventory strMonth3]
						,[Opening Inventory strMonth4]
						,[Forecasted Consumption strMonth4]
						,[Open Purchases strMonth4]
						,[Short/Excess Inventory strMonth4]
						,[Ending Inventory strMonth4]
						,[Opening Inventory strMonth5]
						,[Forecasted Consumption strMonth5]
						,[Open Purchases strMonth5]
						,[Short/Excess Inventory strMonth5]
						,[Ending Inventory strMonth5]
						,[Opening Inventory strMonth6]
						,[Forecasted Consumption strMonth6]
						,[Open Purchases strMonth6]
						,[Short/Excess Inventory strMonth6]
						,[Ending Inventory strMonth6]
						,[Opening Inventory strMonth7]
						,[Forecasted Consumption strMonth7]
						,[Open Purchases strMonth7]
						,[Short/Excess Inventory strMonth7]
						,[Ending Inventory strMonth7]
						,[Opening Inventory strMonth8]
						,[Forecasted Consumption strMonth8]
						,[Open Purchases strMonth8]
						,[Short/Excess Inventory strMonth8]
						,[Ending Inventory strMonth8]
						,[Opening Inventory strMonth9]
						,[Forecasted Consumption strMonth9]
						,[Open Purchases strMonth9]
						,[Short/Excess Inventory strMonth9]
						,[Ending Inventory strMonth9]
						,[Opening Inventory strMonth10]
						,[Forecasted Consumption strMonth10]
						,[Open Purchases strMonth10]
						,[Short/Excess Inventory strMonth10]
						,[Ending Inventory strMonth10]
						,[Opening Inventory strMonth11]
						,[Forecasted Consumption strMonth11]
						,[Open Purchases strMonth11]
						,[Short/Excess Inventory strMonth11]
						,[Ending Inventory strMonth11]
						,[Opening Inventory strMonth12]
						,[Forecasted Consumption strMonth12]
						,[Open Purchases strMonth12]
						,[Short/Excess Inventory strMonth12]
						,[Ending Inventory strMonth12]
						,[Opening Inventory strMonth13]
						,[Forecasted Consumption strMonth13]
						,[Open Purchases strMonth13]
						,[Short/Excess Inventory strMonth13]
						,[Ending Inventory strMonth13]
						,[Opening Inventory strMonth14]
						,[Forecasted Consumption strMonth14]
						,[Open Purchases strMonth14]
						,[Short/Excess Inventory strMonth14]
						,[Ending Inventory strMonth14]
						,[Opening Inventory strMonth15]
						,[Forecasted Consumption strMonth15]
						,[Open Purchases strMonth15]
						,[Short/Excess Inventory strMonth15]
						,[Ending Inventory strMonth15]
						,[Opening Inventory strMonth16]
						,[Forecasted Consumption strMonth16]
						,[Open Purchases strMonth16]
						,[Short/Excess Inventory strMonth16]
						,[Ending Inventory strMonth16]
						,[Opening Inventory strMonth17]
						,[Forecasted Consumption strMonth17]
						,[Open Purchases strMonth17]
						,[Short/Excess Inventory strMonth17]
						,[Ending Inventory strMonth17]
						,[Opening Inventory strMonth18]
						,[Forecasted Consumption strMonth18]
						,[Open Purchases strMonth18]
						,[Short/Excess Inventory strMonth18]
						,[Ending Inventory strMonth18]
						,[Opening Inventory strMonth19]
						,[Forecasted Consumption strMonth19]
						,[Open Purchases strMonth19]
						,[Short/Excess Inventory strMonth19]
						,[Ending Inventory strMonth19]
						,[Opening Inventory strMonth20]
						,[Forecasted Consumption strMonth20]
						,[Open Purchases strMonth20]
						,[Short/Excess Inventory strMonth20]
						,[Ending Inventory strMonth20]
						,[Opening Inventory strMonth21]
						,[Forecasted Consumption strMonth21]
						,[Open Purchases strMonth21]
						,[Short/Excess Inventory strMonth21]
						,[Ending Inventory strMonth21]
						,[Opening Inventory strMonth22]
						,[Forecasted Consumption strMonth22]
						,[Open Purchases strMonth22]
						,[Short/Excess Inventory strMonth22]
						,[Ending Inventory strMonth22]
						,[Opening Inventory strMonth23]
						,[Forecasted Consumption strMonth23]
						,[Open Purchases strMonth23]
						,[Short/Excess Inventory strMonth23]
						,[Ending Inventory strMonth23]
						,[Opening Inventory strMonth24]
						,[Forecasted Consumption strMonth24]
						,[Open Purchases strMonth24]
						,[Short/Excess Inventory strMonth24]
						,[Ending Inventory strMonth24]
						)) AS PivotTable;
		END

		SELECT [strMonth1]
			,[strMonth2]
			,[strMonth3]
			,[strMonth4]
			,[strMonth5]
			,[strMonth6]
			,[strMonth7]
			,[strMonth8]
			,[strMonth9]
			,[strMonth10]
			,[strMonth11]
			,[strMonth12]
			,[strMonth13]
			,[strMonth14]
			,[strMonth15]
			,[strMonth16]
			,[strMonth17]
			,[strMonth18]
			,[strMonth19]
			,[strMonth20]
			,[strMonth21]
			,[strMonth22]
			,[strMonth23]
			,[strMonth24]
		FROM (
			SELECT strFieldName
				,strValue
			FROM tblCTInvPlngReportAttributeValue
			WHERE intReportAttributeID = 1
				AND intInvPlngReportMasterID IN (
					SELECT Item Collate Latin1_General_CI_AS
					FROM [dbo].[fnSplitString](@strInvPlngReportMasterID, ',')
					)
				AND strValue <> ''
			) AS SourceTable
		PIVOT(MIN(strValue) FOR strFieldName IN (
					[strMonth1]
					,[strMonth2]
					,[strMonth3]
					,[strMonth4]
					,[strMonth5]
					,[strMonth6]
					,[strMonth7]
					,[strMonth8]
					,[strMonth9]
					,[strMonth10]
					,[strMonth11]
					,[strMonth12]
					,[strMonth13]
					,[strMonth14]
					,[strMonth15]
					,[strMonth16]
					,[strMonth17]
					,[strMonth18]
					,[strMonth19]
					,[strMonth20]
					,[strMonth21]
					,[strMonth22]
					,[strMonth23]
					,[strMonth24]
					)) AS PivotTable;
	END
END

