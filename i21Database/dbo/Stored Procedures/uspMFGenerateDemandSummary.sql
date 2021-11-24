CREATE PROCEDURE uspMFGenerateDemandSummary (
	@strInvPlngReportMasterID NVARCHAR(MAX) = NULL
	,@intUnitMeasureId INT = 0
	,@ysnRefreshContract BIT = 0
	,@intCompanyLocationId INT
	,@ysnLoadPlan BIT = 0
	,@intInvPlngSummaryId INT = 0
	)
AS
BEGIN
	DECLARE @intNoOfMonths INT
		,@strBatch NVARCHAR(MAX) = ''
		,@strBatchId NVARCHAR(MAX) = ''
		,@ysnParent BIT
		,@intLocationId int
	DECLARE @tblMFItemBook TABLE (
		intId INT identity(1, 1)
		,intItemId INT
		,intBookId INT
		,intSubBookId INT
		,strItemNo NVARCHAR(MAX) COLLATE Latin1_General_CI_AS
		)
	DECLARE @intId INT
		,@strItemNo NVARCHAR(MAX)
		,@intItemId INT
		,@intBookId INT
		,@intSubBookId INT

	SELECT @ysnParent = ysnParent
	FROM tblIPMultiCompany
	WHERE ysnCurrentCompany = 1

	SELECT @intLocationId = intCompanyLocationId
	FROM tblSMCompanyLocation

	IF @ysnLoadPlan = 0
	BEGIN
		IF (
				SELECT Count(DISTINCT AV.strValue)
				FROM tblCTInvPlngReportAttributeValue AV
				JOIN tblCTInvPlngReportMaster RM ON RM.intInvPlngReportMasterID = AV.intInvPlngReportMasterID
				WHERE AV.intReportAttributeID = 1
					AND AV.intInvPlngReportMasterID IN (
						SELECT Item Collate Latin1_General_CI_AS
						FROM [dbo].[fnSplitString](@strInvPlngReportMasterID, ',')
						)
					AND strFieldName = 'strMonth1'
				) > 1
		BEGIN
			RAISERROR (
					'Starting month should be same for all the selected demand batches.'
					,16
					,1
					)

			RETURN
		END
	END

	IF @ysnLoadPlan = 1
	BEGIN
		INSERT INTO @tblMFItemBook (
			intItemId
			,intBookId
			,intSubBookId
			)
		SELECT DISTINCT AV.intItemId
			,AV.intBookId
			,AV.intSubBookId
		FROM tblMFInvPlngSummaryDetail AV
		WHERE intInvPlngSummaryId = @intInvPlngSummaryId
			AND AV.intAttributeId = 2 --Opening Inventory
			AND IsNumeric(AV.strValue) = 1
			AND AV.intMainItemId IS NULL
	END
	ELSE
	BEGIN
		IF @ysnRefreshContract = 0
		BEGIN
			INSERT INTO @tblMFItemBook (
				intItemId
				,intBookId
				,intSubBookId
				)
			SELECT DISTINCT IsNULL(AV.intMainItemId, AV.intItemId)
				,RM.intBookId
				,RM.intSubBookId
			FROM tblCTInvPlngReportAttributeValue AV
			JOIN tblCTInvPlngReportMaster RM ON RM.intInvPlngReportMasterID = AV.intInvPlngReportMasterID
			WHERE AV.intReportAttributeID = 2 --Opening Inventory
				AND AV.intInvPlngReportMasterID IN (
					SELECT Item Collate Latin1_General_CI_AS
					FROM [dbo].[fnSplitString](@strInvPlngReportMasterID, ',')
					)
		END
		ELSE
		BEGIN
			INSERT INTO @tblMFItemBook (
				intItemId
				,intBookId
				,intSubBookId
				)
			SELECT DISTINCT AV.intItemId
				,AV.intBookId
				,AV.intSubBookId
			FROM tblMFInvPlngSummaryDetail AV
			WHERE intInvPlngSummaryId = @intInvPlngSummaryId
				AND AV.intAttributeId = 2 --Opening Inventory
				AND IsNumeric(AV.strValue) = 1
				AND AV.intMainItemId IS NULL
		END
	END

	SELECT @intId = MIN(intId)
	FROM @tblMFItemBook

	WHILE @intId IS NOT NULL
	BEGIN
		SELECT @intItemId = NULL
			,@intBookId = NULL
			,@intSubBookId = NULL
			,@strItemNo = ''

		SELECT @intItemId = intItemId
			,@intBookId = intBookId
			,@intSubBookId = intSubBookId
		FROM @tblMFItemBook
		WHERE intId = @intId

		--IF EXISTS (
		--		SELECT *
		--		FROM tblICItemBundle IBundle
		--		LEFT JOIN tblICItemBook IBook ON IBook.intItemId = IBundle.intBundleItemId
		--			AND IBook.intBookId = @intBookId
		--			AND isNULL(IBook.intSubBookId, 0) = IsNULL(@intSubBookId, 0)
		--		WHERE IBundle.intItemId = @intItemId
		--			AND IBook.intItemId IS NULL
		--		)
		--BEGIN
		SELECT @strItemNo = @strItemNo + IsNULL(I.strShortName, '') + ' / '
		FROM tblICItemBundle IBundle
		JOIN tblICItem I ON I.intItemId = IBundle.intBundleItemId
		JOIN tblICItemBook IBook ON IBook.intItemId = IBundle.intBundleItemId
			AND IBook.intBookId = @intBookId
			AND isNULL(IBook.intSubBookId, 0) = IsNULL(@intSubBookId, 0)
		WHERE IBundle.intItemId = @intItemId

		--END
		IF @strItemNo IS NULL
			SELECT @strItemNo = ''

		IF len(@strItemNo) > 0
		BEGIN
			SELECT @strItemNo = left(@strItemNo, Len(@strItemNo) - 2)

			UPDATE @tblMFItemBook
			SET strItemNo = @strItemNo
			WHERE intId = @intId
		END

		SELECT @intId = MIN(intId)
		FROM @tblMFItemBook
		WHERE intId > @intId
	END

	IF @ysnLoadPlan = 1
	BEGIN
		SELECT @intNoOfMonths = Max(intNoOfMonths)
		FROM tblCTInvPlngReportMaster RM
		JOIN tblMFInvPlngSummaryBatch B ON B.intInvPlngReportMasterID = RM.intInvPlngReportMasterID
		WHERE B.intInvPlngSummaryId = @intInvPlngSummaryId

		IF @intNoOfMonths IS NULL
			SELECT @intNoOfMonths = 0

		SELECT @strBatch = @strBatch + RM.strPlanNo + ','
			,@strBatchId = @strBatchId + Ltrim(B.intInvPlngReportMasterID) + ','
		FROM tblMFInvPlngSummaryBatch B
		JOIN tblCTInvPlngReportMaster RM ON RM.intInvPlngReportMasterID = B.intInvPlngReportMasterID
		WHERE B.intInvPlngSummaryId = @intInvPlngSummaryId

		IF len(@strBatch) > 0
		BEGIN
			SELECT @strBatch = Left(@strBatch, len(@strBatch) - 1)

			SELECT @strBatchId = Left(@strBatchId, len(@strBatchId) - 1)
		END

		SELECT S.intInvPlngSummaryId
			,S.strPlanName
			,S.dtmDate
			,S.intUnitMeasureId
			,UM.strUnitMeasure
			,S.intBookId
			,B.strBook
			,S.intSubBookId
			,SB.strSubBook
			,S.strComment
			,S.intConcurrencyId
			,@strBatch AS strDemandPlans
			,@strBatchId AS strDemandIds
		FROM tblMFInvPlngSummary S
		LEFT JOIN tblCTBook B ON B.intBookId = S.intBookId
		LEFT JOIN tblCTSubBook SB ON SB.intSubBookId = S.intSubBookId
		JOIN tblICUnitMeasure UM ON UM.intUnitMeasureId = S.intUnitMeasureId
		WHERE intInvPlngSummaryId = @intInvPlngSummaryId

		SELECT @intNoOfMonths AS intNoOfMonths
			,[strMonth1]
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
			SELECT DISTINCT strFieldName
				,strValue
			FROM tblMFInvPlngSummaryDetail SD
			JOIN tblMFInvPlngSummaryBatch Batch ON Batch.intInvPlngSummaryId = SD.intInvPlngSummaryId
			WHERE intAttributeId = 1
				AND Batch.intInvPlngReportMasterID IN (
					SELECT Item Collate Latin1_General_CI_AS
					FROM [dbo].[fnSplitString](@strBatchId, ',')
					)
				AND strValue <> ''
				AND SD.intInvPlngSummaryId = @intInvPlngSummaryId
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

		SELECT Row_Number() OVER (
				ORDER BY strBook
					,strSubBook
					,strProductType
					,IsNULL(strMainItemNo, strItemNo)
					,strItemNo
					,strItemDescription
				) AS intSort
			,intBookId
			,intSubBookId
			,intMainItemId
			,intItemId
			,strBook
			,strSubBook
			,strProductType
			,strItemNo
			,strItemDescription
			,dblSupplyTarget AS strSupplyTarget
			,IsNULL([Opening Inventory strMonth1], 0) AS strOIMonth1
			,IsNULL([Forecasted Consumption strMonth1], 0) AS strFCMonth1
			,IsNULL([Existing Purchases strMonth1], 0) AS strOPMonth1
			,IsNULL([Planned Purchases strMonth1], 0) AS strSEMonth1
			,IsNULL([Ending Inventory strMonth1], 0) AS strEIMonth1
			,IsNULL([Weeks of Supply strMonth1], 0) AS strSTMonth1
			,IsNULL([Opening Inventory strMonth2], 0) AS strOIMonth2
			,IsNULL([Forecasted Consumption strMonth2], 0) AS strFCMonth2
			,IsNULL([Existing Purchases strMonth2], 0) AS strOPMonth2
			,IsNULL([Planned Purchases strMonth2], 0) AS strSEMonth2
			,IsNULL([Ending Inventory strMonth2], 0) AS strEIMonth2
			,IsNULL([Weeks of Supply strMonth2], 0) AS strSTMonth2
			,IsNULL([Opening Inventory strMonth3], 0) AS strOIMonth3
			,IsNULL([Forecasted Consumption strMonth3], 0) AS strFCMonth3
			,IsNULL([Existing Purchases strMonth3], 0) AS strOPMonth3
			,IsNULL([Planned Purchases strMonth3], 0) AS strSEMonth3
			,IsNULL([Ending Inventory strMonth3], 0) AS strEIMonth3
			,IsNULL([Weeks of Supply strMonth3], 0) AS strSTMonth3
			,IsNULL([Opening Inventory strMonth4], 0) AS strOIMonth4
			,IsNULL([Forecasted Consumption strMonth4], 0) AS strFCMonth4
			,IsNULL([Existing Purchases strMonth4], 0) AS strOPMonth4
			,IsNULL([Planned Purchases strMonth4], 0) AS strSEMonth4
			,IsNULL([Ending Inventory strMonth4], 0) AS strEIMonth4
			,IsNULL([Weeks of Supply strMonth4], 0) AS strSTMonth4
			,IsNULL([Opening Inventory strMonth5], 0) AS strOIMonth5
			,IsNULL([Forecasted Consumption strMonth5], 0) AS strFCMonth5
			,IsNULL([Existing Purchases strMonth5], 0) AS strOPMonth5
			,IsNULL([Planned Purchases strMonth5], 0) AS strSEMonth5
			,IsNULL([Ending Inventory strMonth5], 0) AS strEIMonth5
			,IsNULL([Weeks of Supply strMonth5], 0) AS strSTMonth5
			,IsNULL([Opening Inventory strMonth6], 0) AS strOIMonth6
			,IsNULL([Forecasted Consumption strMonth6], 0) AS strFCMonth6
			,IsNULL([Existing Purchases strMonth6], 0) AS strOPMonth6
			,IsNULL([Planned Purchases strMonth6], 0) AS strSEMonth6
			,IsNULL([Ending Inventory strMonth6], 0) AS strEIMonth6
			,IsNULL([Weeks of Supply strMonth6], 0) AS strSTMonth6
			,IsNULL([Opening Inventory strMonth7], 0) AS strOIMonth7
			,IsNULL([Forecasted Consumption strMonth7], 0) AS strFCMonth7
			,IsNULL([Existing Purchases strMonth7], 0) AS strOPMonth7
			,IsNULL([Planned Purchases strMonth7], 0) AS strSEMonth7
			,IsNULL([Ending Inventory strMonth7], 0) AS strEIMonth7
			,IsNULL([Weeks of Supply strMonth7], 0) AS strSTMonth7
			,IsNULL([Opening Inventory strMonth8], 0) AS strOIMonth8
			,IsNULL([Forecasted Consumption strMonth8], 0) AS strFCMonth8
			,IsNULL([Existing Purchases strMonth8], 0) AS strOPMonth8
			,IsNULL([Planned Purchases strMonth8], 0) AS strSEMonth8
			,IsNULL([Ending Inventory strMonth8], 0) AS strEIMonth8
			,IsNULL([Weeks of Supply strMonth8], 0) AS strSTMonth8
			,IsNULL([Opening Inventory strMonth9], 0) AS strOIMonth9
			,IsNULL([Forecasted Consumption strMonth9], 0) AS strFCMonth9
			,IsNULL([Existing Purchases strMonth9], 0) AS strOPMonth9
			,IsNULL([Planned Purchases strMonth9], 0) AS strSEMonth9
			,IsNULL([Ending Inventory strMonth9], 0) AS strEIMonth9
			,IsNULL([Weeks of Supply strMonth9], 0) AS strSTMonth9
			,IsNULL([Opening Inventory strMonth10], 0) AS strOIMonth10
			,IsNULL([Forecasted Consumption strMonth10], 0) AS strFCMonth10
			,IsNULL([Existing Purchases strMonth10], 0) AS strOPMonth10
			,IsNULL([Planned Purchases strMonth10], 0) AS strSEMonth10
			,IsNULL([Ending Inventory strMonth10], 0) AS strEIMonth10
			,IsNULL([Weeks of Supply strMonth10], 0) AS strSTMonth10
			,IsNULL([Opening Inventory strMonth11], 0) AS strOIMonth11
			,IsNULL([Forecasted Consumption strMonth11], 0) AS strFCMonth11
			,IsNULL([Existing Purchases strMonth11], 0) AS strOPMonth11
			,IsNULL([Planned Purchases strMonth11], 0) AS strSEMonth11
			,IsNULL([Ending Inventory strMonth11], 0) AS strEIMonth11
			,IsNULL([Weeks of Supply strMonth11], 0) AS strSTMonth11
			,IsNULL([Opening Inventory strMonth12], 0) AS strOIMonth12
			,IsNULL([Forecasted Consumption strMonth12], 0) AS strFCMonth12
			,IsNULL([Existing Purchases strMonth12], 0) AS strOPMonth12
			,IsNULL([Planned Purchases strMonth12], 0) AS strSEMonth12
			,IsNULL([Ending Inventory strMonth12], 0) AS strEIMonth12
			,IsNULL([Weeks of Supply strMonth12], 0) AS strSTMonth12
			,IsNULL([Opening Inventory strMonth13], 0) AS strOIMonth13
			,IsNULL([Forecasted Consumption strMonth13], 0) AS strFCMonth13
			,IsNULL([Existing Purchases strMonth13], 0) AS strOPMonth13
			,IsNULL([Planned Purchases strMonth13], 0) AS strSEMonth13
			,IsNULL([Ending Inventory strMonth13], 0) AS strEIMonth13
			,IsNULL([Weeks of Supply strMonth13], 0) AS strSTMonth13
			,IsNULL([Opening Inventory strMonth14], 0) AS strOIMonth14
			,IsNULL([Forecasted Consumption strMonth14], 0) AS strFCMonth14
			,IsNULL([Existing Purchases strMonth14], 0) AS strOPMonth14
			,IsNULL([Planned Purchases strMonth14], 0) AS strSEMonth14
			,IsNULL([Ending Inventory strMonth14], 0) AS strEIMonth14
			,IsNULL([Weeks of Supply strMonth14], 0) AS strSTMonth14
			,IsNULL([Opening Inventory strMonth15], 0) AS strOIMonth15
			,IsNULL([Forecasted Consumption strMonth15], 0) AS strFCMonth15
			,IsNULL([Existing Purchases strMonth15], 0) AS strOPMonth15
			,IsNULL([Planned Purchases strMonth15], 0) AS strSEMonth15
			,IsNULL([Ending Inventory strMonth15], 0) AS strEIMonth15
			,IsNULL([Weeks of Supply strMonth15], 0) AS strSTMonth15
			,IsNULL([Opening Inventory strMonth16], 0) AS strOIMonth16
			,IsNULL([Forecasted Consumption strMonth16], 0) AS strFCMonth16
			,IsNULL([Existing Purchases strMonth16], 0) AS strOPMonth16
			,IsNULL([Planned Purchases strMonth16], 0) AS strSEMonth16
			,IsNULL([Ending Inventory strMonth16], 0) AS strEIMonth16
			,IsNULL([Weeks of Supply strMonth16], 0) AS strSTMonth16
			,IsNULL([Opening Inventory strMonth17], 0) AS strOIMonth17
			,IsNULL([Forecasted Consumption strMonth17], 0) AS strFCMonth17
			,IsNULL([Existing Purchases strMonth17], 0) AS strOPMonth17
			,IsNULL([Planned Purchases strMonth17], 0) AS strSEMonth17
			,IsNULL([Ending Inventory strMonth17], 0) AS strEIMonth17
			,IsNULL([Weeks of Supply strMonth17], 0) AS strSTMonth17
			,IsNULL([Opening Inventory strMonth18], 0) AS strOIMonth18
			,IsNULL([Forecasted Consumption strMonth18], 0) AS strFCMonth18
			,IsNULL([Existing Purchases strMonth18], 0) AS strOPMonth18
			,IsNULL([Planned Purchases strMonth18], 0) AS strSEMonth18
			,IsNULL([Ending Inventory strMonth18], 0) AS strEIMonth18
			,IsNULL([Weeks of Supply strMonth18], 0) AS strSTMonth18
			,IsNULL([Opening Inventory strMonth19], 0) AS strOIMonth19
			,IsNULL([Forecasted Consumption strMonth19], 0) AS strFCMonth19
			,IsNULL([Existing Purchases strMonth19], 0) AS strOPMonth19
			,IsNULL([Planned Purchases strMonth19], 0) AS strSEMonth19
			,IsNULL([Ending Inventory strMonth19], 0) AS strEIMonth19
			,IsNULL([Weeks of Supply strMonth19], 0) AS strSTMonth19
			,IsNULL([Opening Inventory strMonth20], 0) AS strOIMonth20
			,IsNULL([Forecasted Consumption strMonth20], 0) AS strFCMonth20
			,IsNULL([Existing Purchases strMonth20], 0) AS strOPMonth20
			,IsNULL([Planned Purchases strMonth20], 0) AS strSEMonth20
			,IsNULL([Ending Inventory strMonth20], 0) AS strEIMonth20
			,IsNULL([Weeks of Supply strMonth20], 0) AS strSTMonth20
			,IsNULL([Opening Inventory strMonth21], 0) AS strOIMonth21
			,IsNULL([Forecasted Consumption strMonth21], 0) AS strFCMonth21
			,IsNULL([Existing Purchases strMonth21], 0) AS strOPMonth21
			,IsNULL([Planned Purchases strMonth21], 0) AS strSEMonth21
			,IsNULL([Ending Inventory strMonth21], 0) AS strEIMonth21
			,IsNULL([Weeks of Supply strMonth21], 0) AS strSTMonth21
			,IsNULL([Opening Inventory strMonth22], 0) AS strOIMonth22
			,IsNULL([Forecasted Consumption strMonth22], 0) AS strFCMonth22
			,IsNULL([Existing Purchases strMonth22], 0) AS strOPMonth22
			,IsNULL([Planned Purchases strMonth22], 0) AS strSEMonth22
			,IsNULL([Ending Inventory strMonth22], 0) AS strEIMonth22
			,IsNULL([Weeks of Supply strMonth22], 0) AS strSTMonth22
			,IsNULL([Opening Inventory strMonth23], 0) AS strOIMonth23
			,IsNULL([Forecasted Consumption strMonth23], 0) AS strFCMonth23
			,IsNULL([Existing Purchases strMonth23], 0) AS strOPMonth23
			,IsNULL([Planned Purchases strMonth23], 0) AS strSEMonth23
			,IsNULL([Ending Inventory strMonth23], 0) AS strEIMonth23
			,IsNULL([Weeks of Supply strMonth23], 0) AS strSTMonth23
			,IsNULL([Opening Inventory strMonth24], 0) AS strOIMonth24
			,IsNULL([Forecasted Consumption strMonth24], 0) AS strFCMonth24
			,IsNULL([Existing Purchases strMonth24], 0) AS strOPMonth24
			,IsNULL([Planned Purchases strMonth24], 0) AS strSEMonth24
			,IsNULL([Ending Inventory strMonth24], 0) AS strEIMonth24
			,IsNULL([Weeks of Supply strMonth24], 0) AS strSTMonth24
		FROM (
			SELECT B.strBook
				,SB.strSubBook
				,CA.strDescription AS strProductType
				,IsNULL(MI.strItemNo, I.strItemNo) AS strItemNo
				,(
					CASE 
						WHEN MI.intItemId IS NOT NULL
							THEN I.strItemNo + ' - ' + IsNULL(I.strShortName, '')
						ELSE IB.strItemNo
						END
					) AS strItemDescription
				,Replace(Replace(A.strAttributeName, '<a>+ ', ''), '</a>', '') + ' ' + AV.strFieldName AS strAttributeName
				,(
					CASE 
						WHEN IsNUmeric(AV.strValue) = 0
							THEN Convert(NUMERIC(18, 6), 0.0)
						ELSE AV.strValue
						END
					) strValue
				,B.intBookId
				,SB.intSubBookId
				,AV.intMainItemId
				,I.intItemId
				,CASE 
					WHEN @ysnParent = 1
						THEN ST.dblSupplyTarget
					ELSE IL.dblLeadTime
					END AS dblSupplyTarget
				,MI.strItemNo AS strMainItemNo
			FROM tblMFInvPlngSummaryDetail AV
			JOIN tblMFInvPlngSummary S ON S.intInvPlngSummaryId = AV.intInvPlngSummaryId
			JOIN tblCTReportAttribute A ON A.intReportAttributeID = AV.intAttributeId
			LEFT JOIN tblICItem MI ON MI.intItemId = AV.intMainItemId
			JOIN tblICItem I ON I.intItemId = AV.intItemId
			LEFT JOIN tblCTBook B ON B.intBookId = AV.intBookId
			LEFT JOIN tblCTSubBook SB ON SB.intSubBookId = AV.intSubBookId
			LEFT JOIN tblICCommodityAttribute CA ON CA.intCommodityId = I.intCommodityId
				AND I.intProductTypeId = CA.intCommodityAttributeId
				AND CA.strType = 'ProductType'
			LEFT JOIN tblIPItemSupplyTarget ST ON ST.intBookId = B.intBookId
				AND IsNULL(ST.intSubBookId, 0) = IsNULL(SB.intSubBookId, 0)
				AND ST.intItemId = I.intItemId
			LEFT JOIN @tblMFItemBook IB ON IB.intItemId = AV.intItemId
				AND IB.intBookId = B.intBookId
				AND IsNULL(IB.intSubBookId, 0) = IsNULL(SB.intSubBookId, 0)
			LEFT JOIN tblICItemLocation IL on IL.intItemId=I.intItemId and IL.intLocationId =@intLocationId
			WHERE A.intReportAttributeID IN (
					2 --Opening Inventory
					,4 --Existing Purchases
					,5 --Planned Purchases
					,8 --Forecasted Consumption
					,9 --Ending Inventory
					,10 --Weeks of Supply
					)
				AND IsNumeric(AV.strValue) = 1
				--2-Opening Inventory;8-Forecasted Consumption;9-Ending Inventory;13-Existing Purchases;12-Planned Purchases
				AND AV.strFieldName NOT IN (
					'OpeningInv'
					,'PastDue'
					)
				AND AV.intInvPlngSummaryId = @intInvPlngSummaryId
			) AS SourceTable
		PIVOT(SUM(strValue) FOR strAttributeName IN (
					[Opening Inventory strMonth1]
					,[Forecasted Consumption strMonth1]
					,[Existing Purchases strMonth1]
					,[Planned Purchases strMonth1]
					,[Ending Inventory strMonth1]
					,[Weeks of Supply strMonth1]
					,[Opening Inventory strMonth2]
					,[Forecasted Consumption strMonth2]
					,[Existing Purchases strMonth2]
					,[Planned Purchases strMonth2]
					,[Ending Inventory strMonth2]
					,[Weeks of Supply strMonth2]
					,[Opening Inventory strMonth3]
					,[Forecasted Consumption strMonth3]
					,[Existing Purchases strMonth3]
					,[Planned Purchases strMonth3]
					,[Ending Inventory strMonth3]
					,[Weeks of Supply strMonth3]
					,[Opening Inventory strMonth4]
					,[Forecasted Consumption strMonth4]
					,[Existing Purchases strMonth4]
					,[Planned Purchases strMonth4]
					,[Ending Inventory strMonth4]
					,[Weeks of Supply strMonth4]
					,[Opening Inventory strMonth5]
					,[Forecasted Consumption strMonth5]
					,[Existing Purchases strMonth5]
					,[Planned Purchases strMonth5]
					,[Ending Inventory strMonth5]
					,[Weeks of Supply strMonth5]
					,[Opening Inventory strMonth6]
					,[Forecasted Consumption strMonth6]
					,[Existing Purchases strMonth6]
					,[Planned Purchases strMonth6]
					,[Ending Inventory strMonth6]
					,[Weeks of Supply strMonth6]
					,[Opening Inventory strMonth7]
					,[Forecasted Consumption strMonth7]
					,[Existing Purchases strMonth7]
					,[Planned Purchases strMonth7]
					,[Ending Inventory strMonth7]
					,[Weeks of Supply strMonth7]
					,[Opening Inventory strMonth8]
					,[Forecasted Consumption strMonth8]
					,[Existing Purchases strMonth8]
					,[Planned Purchases strMonth8]
					,[Ending Inventory strMonth8]
					,[Weeks of Supply strMonth8]
					,[Opening Inventory strMonth9]
					,[Forecasted Consumption strMonth9]
					,[Existing Purchases strMonth9]
					,[Planned Purchases strMonth9]
					,[Ending Inventory strMonth9]
					,[Weeks of Supply strMonth9]
					,[Opening Inventory strMonth10]
					,[Forecasted Consumption strMonth10]
					,[Existing Purchases strMonth10]
					,[Planned Purchases strMonth10]
					,[Ending Inventory strMonth10]
					,[Weeks of Supply strMonth10]
					,[Opening Inventory strMonth11]
					,[Forecasted Consumption strMonth11]
					,[Existing Purchases strMonth11]
					,[Planned Purchases strMonth11]
					,[Ending Inventory strMonth11]
					,[Weeks of Supply strMonth11]
					,[Opening Inventory strMonth12]
					,[Forecasted Consumption strMonth12]
					,[Existing Purchases strMonth12]
					,[Planned Purchases strMonth12]
					,[Ending Inventory strMonth12]
					,[Weeks of Supply strMonth12]
					,[Opening Inventory strMonth13]
					,[Forecasted Consumption strMonth13]
					,[Existing Purchases strMonth13]
					,[Planned Purchases strMonth13]
					,[Ending Inventory strMonth13]
					,[Weeks of Supply strMonth13]
					,[Opening Inventory strMonth14]
					,[Forecasted Consumption strMonth14]
					,[Existing Purchases strMonth14]
					,[Planned Purchases strMonth14]
					,[Ending Inventory strMonth14]
					,[Weeks of Supply strMonth14]
					,[Opening Inventory strMonth15]
					,[Forecasted Consumption strMonth15]
					,[Existing Purchases strMonth15]
					,[Planned Purchases strMonth15]
					,[Ending Inventory strMonth15]
					,[Weeks of Supply strMonth15]
					,[Opening Inventory strMonth16]
					,[Forecasted Consumption strMonth16]
					,[Existing Purchases strMonth16]
					,[Planned Purchases strMonth16]
					,[Ending Inventory strMonth16]
					,[Weeks of Supply strMonth16]
					,[Opening Inventory strMonth17]
					,[Forecasted Consumption strMonth17]
					,[Existing Purchases strMonth17]
					,[Planned Purchases strMonth17]
					,[Ending Inventory strMonth17]
					,[Weeks of Supply strMonth17]
					,[Opening Inventory strMonth18]
					,[Forecasted Consumption strMonth18]
					,[Existing Purchases strMonth18]
					,[Planned Purchases strMonth18]
					,[Ending Inventory strMonth18]
					,[Weeks of Supply strMonth18]
					,[Opening Inventory strMonth19]
					,[Forecasted Consumption strMonth19]
					,[Existing Purchases strMonth19]
					,[Planned Purchases strMonth19]
					,[Ending Inventory strMonth19]
					,[Weeks of Supply strMonth19]
					,[Opening Inventory strMonth20]
					,[Forecasted Consumption strMonth20]
					,[Existing Purchases strMonth20]
					,[Planned Purchases strMonth20]
					,[Ending Inventory strMonth20]
					,[Weeks of Supply strMonth20]
					,[Opening Inventory strMonth21]
					,[Forecasted Consumption strMonth21]
					,[Existing Purchases strMonth21]
					,[Planned Purchases strMonth21]
					,[Ending Inventory strMonth21]
					,[Weeks of Supply strMonth21]
					,[Opening Inventory strMonth22]
					,[Forecasted Consumption strMonth22]
					,[Existing Purchases strMonth22]
					,[Planned Purchases strMonth22]
					,[Ending Inventory strMonth22]
					,[Weeks of Supply strMonth22]
					,[Opening Inventory strMonth23]
					,[Forecasted Consumption strMonth23]
					,[Existing Purchases strMonth23]
					,[Planned Purchases strMonth23]
					,[Ending Inventory strMonth23]
					,[Weeks of Supply strMonth23]
					,[Opening Inventory strMonth24]
					,[Forecasted Consumption strMonth24]
					,[Existing Purchases strMonth24]
					,[Planned Purchases strMonth24]
					,[Ending Inventory strMonth24]
					,[Weeks of Supply strMonth24]
					)) AS PivotTable
			--ORDER BY strBook
			--	,strSubBook
			--	,strProductType
			--	,strItemNo
			--	,strItemDescription
	END
	ELSE
	BEGIN
		SELECT @intNoOfMonths = Max(intNoOfMonths)
		FROM tblCTInvPlngReportMaster
		WHERE intInvPlngReportMasterID IN (
				SELECT Item Collate Latin1_General_CI_AS
				FROM [dbo].[fnSplitString](@strInvPlngReportMasterID, ',')
				)

		IF @intNoOfMonths IS NULL
			SELECT @intNoOfMonths = 0

		SELECT @intNoOfMonths AS intNoOfMonths
			,[strMonth1]
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

		IF @ysnRefreshContract = 0
		BEGIN
			SELECT Row_Number() OVER (
					ORDER BY strBook
						,strSubBook
						,strProductType
						,IsNULL(strMainItemNo, strItemNo)
						,strItemNo
						,strItemDescription
					) AS intSort
				,intBookId
				,intSubBookId
				,intMainItemId
				,intItemId
				,strBook
				,strSubBook
				,strProductType
				,strItemNo
				,strItemDescription
				,dblSupplyTarget AS strSupplyTarget
				,IsNULL([Opening Inventory strMonth1], 0) AS strOIMonth1
				,IsNULL([Forecasted Consumption strMonth1], 0) AS strFCMonth1
				,IsNULL([Existing Purchases strMonth1], 0) AS strOPMonth1
				,IsNULL([Planned Purchases strMonth1], 0) AS strSEMonth1
				,IsNULL([Ending Inventory strMonth1], 0) AS strEIMonth1
				,IsNULL([Weeks of Supply strMonth1], 0) AS strSTMonth1
				,IsNULL([Opening Inventory strMonth2], 0) AS strOIMonth2
				,IsNULL([Forecasted Consumption strMonth2], 0) AS strFCMonth2
				,IsNULL([Existing Purchases strMonth2], 0) AS strOPMonth2
				,IsNULL([Planned Purchases strMonth2], 0) AS strSEMonth2
				,IsNULL([Ending Inventory strMonth2], 0) AS strEIMonth2
				,IsNULL([Weeks of Supply strMonth2], 0) AS strSTMonth2
				,IsNULL([Opening Inventory strMonth3], 0) AS strOIMonth3
				,IsNULL([Forecasted Consumption strMonth3], 0) AS strFCMonth3
				,IsNULL([Existing Purchases strMonth3], 0) AS strOPMonth3
				,IsNULL([Planned Purchases strMonth3], 0) AS strSEMonth3
				,IsNULL([Ending Inventory strMonth3], 0) AS strEIMonth3
				,IsNULL([Weeks of Supply strMonth3], 0) AS strSTMonth3
				,IsNULL([Opening Inventory strMonth4], 0) AS strOIMonth4
				,IsNULL([Forecasted Consumption strMonth4], 0) AS strFCMonth4
				,IsNULL([Existing Purchases strMonth4], 0) AS strOPMonth4
				,IsNULL([Planned Purchases strMonth4], 0) AS strSEMonth4
				,IsNULL([Ending Inventory strMonth4], 0) AS strEIMonth4
				,IsNULL([Weeks of Supply strMonth4], 0) AS strSTMonth4
				,IsNULL([Opening Inventory strMonth5], 0) AS strOIMonth5
				,IsNULL([Forecasted Consumption strMonth5], 0) AS strFCMonth5
				,IsNULL([Existing Purchases strMonth5], 0) AS strOPMonth5
				,IsNULL([Planned Purchases strMonth5], 0) AS strSEMonth5
				,IsNULL([Ending Inventory strMonth5], 0) AS strEIMonth5
				,IsNULL([Weeks of Supply strMonth5], 0) AS strSTMonth5
				,IsNULL([Opening Inventory strMonth6], 0) AS strOIMonth6
				,IsNULL([Forecasted Consumption strMonth6], 0) AS strFCMonth6
				,IsNULL([Existing Purchases strMonth6], 0) AS strOPMonth6
				,IsNULL([Planned Purchases strMonth6], 0) AS strSEMonth6
				,IsNULL([Ending Inventory strMonth6], 0) AS strEIMonth6
				,IsNULL([Weeks of Supply strMonth6], 0) AS strSTMonth6
				,IsNULL([Opening Inventory strMonth7], 0) AS strOIMonth7
				,IsNULL([Forecasted Consumption strMonth7], 0) AS strFCMonth7
				,IsNULL([Existing Purchases strMonth7], 0) AS strOPMonth7
				,IsNULL([Planned Purchases strMonth7], 0) AS strSEMonth7
				,IsNULL([Ending Inventory strMonth7], 0) AS strEIMonth7
				,IsNULL([Weeks of Supply strMonth7], 0) AS strSTMonth7
				,IsNULL([Opening Inventory strMonth8], 0) AS strOIMonth8
				,IsNULL([Forecasted Consumption strMonth8], 0) AS strFCMonth8
				,IsNULL([Existing Purchases strMonth8], 0) AS strOPMonth8
				,IsNULL([Planned Purchases strMonth8], 0) AS strSEMonth8
				,IsNULL([Ending Inventory strMonth8], 0) AS strEIMonth8
				,IsNULL([Weeks of Supply strMonth8], 0) AS strSTMonth8
				,IsNULL([Opening Inventory strMonth9], 0) AS strOIMonth9
				,IsNULL([Forecasted Consumption strMonth9], 0) AS strFCMonth9
				,IsNULL([Existing Purchases strMonth9], 0) AS strOPMonth9
				,IsNULL([Planned Purchases strMonth9], 0) AS strSEMonth9
				,IsNULL([Ending Inventory strMonth9], 0) AS strEIMonth9
				,IsNULL([Weeks of Supply strMonth9], 0) AS strSTMonth9
				,IsNULL([Opening Inventory strMonth10], 0) AS strOIMonth10
				,IsNULL([Forecasted Consumption strMonth10], 0) AS strFCMonth10
				,IsNULL([Existing Purchases strMonth10], 0) AS strOPMonth10
				,IsNULL([Planned Purchases strMonth10], 0) AS strSEMonth10
				,IsNULL([Ending Inventory strMonth10], 0) AS strEIMonth10
				,IsNULL([Weeks of Supply strMonth10], 0) AS strSTMonth10
				,IsNULL([Opening Inventory strMonth11], 0) AS strOIMonth11
				,IsNULL([Forecasted Consumption strMonth11], 0) AS strFCMonth11
				,IsNULL([Existing Purchases strMonth11], 0) AS strOPMonth11
				,IsNULL([Planned Purchases strMonth11], 0) AS strSEMonth11
				,IsNULL([Ending Inventory strMonth11], 0) AS strEIMonth11
				,IsNULL([Weeks of Supply strMonth11], 0) AS strSTMonth11
				,IsNULL([Opening Inventory strMonth12], 0) AS strOIMonth12
				,IsNULL([Forecasted Consumption strMonth12], 0) AS strFCMonth12
				,IsNULL([Existing Purchases strMonth12], 0) AS strOPMonth12
				,IsNULL([Planned Purchases strMonth12], 0) AS strSEMonth12
				,IsNULL([Ending Inventory strMonth12], 0) AS strEIMonth12
				,IsNULL([Weeks of Supply strMonth12], 0) AS strSTMonth12
				,IsNULL([Opening Inventory strMonth13], 0) AS strOIMonth13
				,IsNULL([Forecasted Consumption strMonth13], 0) AS strFCMonth13
				,IsNULL([Existing Purchases strMonth13], 0) AS strOPMonth13
				,IsNULL([Planned Purchases strMonth13], 0) AS strSEMonth13
				,IsNULL([Ending Inventory strMonth13], 0) AS strEIMonth13
				,IsNULL([Weeks of Supply strMonth13], 0) AS strSTMonth13
				,IsNULL([Opening Inventory strMonth14], 0) AS strOIMonth14
				,IsNULL([Forecasted Consumption strMonth14], 0) AS strFCMonth14
				,IsNULL([Existing Purchases strMonth14], 0) AS strOPMonth14
				,IsNULL([Planned Purchases strMonth14], 0) AS strSEMonth14
				,IsNULL([Ending Inventory strMonth14], 0) AS strEIMonth14
				,IsNULL([Weeks of Supply strMonth14], 0) AS strSTMonth14
				,IsNULL([Opening Inventory strMonth15], 0) AS strOIMonth15
				,IsNULL([Forecasted Consumption strMonth15], 0) AS strFCMonth15
				,IsNULL([Existing Purchases strMonth15], 0) AS strOPMonth15
				,IsNULL([Planned Purchases strMonth15], 0) AS strSEMonth15
				,IsNULL([Ending Inventory strMonth15], 0) AS strEIMonth15
				,IsNULL([Weeks of Supply strMonth15], 0) AS strSTMonth15
				,IsNULL([Opening Inventory strMonth16], 0) AS strOIMonth16
				,IsNULL([Forecasted Consumption strMonth16], 0) AS strFCMonth16
				,IsNULL([Existing Purchases strMonth16], 0) AS strOPMonth16
				,IsNULL([Planned Purchases strMonth16], 0) AS strSEMonth16
				,IsNULL([Ending Inventory strMonth16], 0) AS strEIMonth16
				,IsNULL([Weeks of Supply strMonth16], 0) AS strSTMonth16
				,IsNULL([Opening Inventory strMonth17], 0) AS strOIMonth17
				,IsNULL([Forecasted Consumption strMonth17], 0) AS strFCMonth17
				,IsNULL([Existing Purchases strMonth17], 0) AS strOPMonth17
				,IsNULL([Planned Purchases strMonth17], 0) AS strSEMonth17
				,IsNULL([Ending Inventory strMonth17], 0) AS strEIMonth17
				,IsNULL([Weeks of Supply strMonth17], 0) AS strSTMonth17
				,IsNULL([Opening Inventory strMonth18], 0) AS strOIMonth18
				,IsNULL([Forecasted Consumption strMonth18], 0) AS strFCMonth18
				,IsNULL([Existing Purchases strMonth18], 0) AS strOPMonth18
				,IsNULL([Planned Purchases strMonth18], 0) AS strSEMonth18
				,IsNULL([Ending Inventory strMonth18], 0) AS strEIMonth18
				,IsNULL([Weeks of Supply strMonth18], 0) AS strSTMonth18
				,IsNULL([Opening Inventory strMonth19], 0) AS strOIMonth19
				,IsNULL([Forecasted Consumption strMonth19], 0) AS strFCMonth19
				,IsNULL([Existing Purchases strMonth19], 0) AS strOPMonth19
				,IsNULL([Planned Purchases strMonth19], 0) AS strSEMonth19
				,IsNULL([Ending Inventory strMonth19], 0) AS strEIMonth19
				,IsNULL([Weeks of Supply strMonth19], 0) AS strSTMonth19
				,IsNULL([Opening Inventory strMonth20], 0) AS strOIMonth20
				,IsNULL([Forecasted Consumption strMonth20], 0) AS strFCMonth20
				,IsNULL([Existing Purchases strMonth20], 0) AS strOPMonth20
				,IsNULL([Planned Purchases strMonth20], 0) AS strSEMonth20
				,IsNULL([Ending Inventory strMonth20], 0) AS strEIMonth20
				,IsNULL([Weeks of Supply strMonth20], 0) AS strSTMonth20
				,IsNULL([Opening Inventory strMonth21], 0) AS strOIMonth21
				,IsNULL([Forecasted Consumption strMonth21], 0) AS strFCMonth21
				,IsNULL([Existing Purchases strMonth21], 0) AS strOPMonth21
				,IsNULL([Planned Purchases strMonth21], 0) AS strSEMonth21
				,IsNULL([Ending Inventory strMonth21], 0) AS strEIMonth21
				,IsNULL([Weeks of Supply strMonth21], 0) AS strSTMonth21
				,IsNULL([Opening Inventory strMonth22], 0) AS strOIMonth22
				,IsNULL([Forecasted Consumption strMonth22], 0) AS strFCMonth22
				,IsNULL([Existing Purchases strMonth22], 0) AS strOPMonth22
				,IsNULL([Planned Purchases strMonth22], 0) AS strSEMonth22
				,IsNULL([Ending Inventory strMonth22], 0) AS strEIMonth22
				,IsNULL([Weeks of Supply strMonth22], 0) AS strSTMonth22
				,IsNULL([Opening Inventory strMonth23], 0) AS strOIMonth23
				,IsNULL([Forecasted Consumption strMonth23], 0) AS strFCMonth23
				,IsNULL([Existing Purchases strMonth23], 0) AS strOPMonth23
				,IsNULL([Planned Purchases strMonth23], 0) AS strSEMonth23
				,IsNULL([Ending Inventory strMonth23], 0) AS strEIMonth23
				,IsNULL([Weeks of Supply strMonth23], 0) AS strSTMonth23
				,IsNULL([Opening Inventory strMonth24], 0) AS strOIMonth24
				,IsNULL([Forecasted Consumption strMonth24], 0) AS strFCMonth24
				,IsNULL([Existing Purchases strMonth24], 0) AS strOPMonth24
				,IsNULL([Planned Purchases strMonth24], 0) AS strSEMonth24
				,IsNULL([Ending Inventory strMonth24], 0) AS strEIMonth24
				,IsNULL([Weeks of Supply strMonth24], 0) AS strSTMonth24
			FROM (
				SELECT B.strBook
					,SB.strSubBook
					,CA.strDescription AS strProductType
					,IsNULL(MI.strItemNo, I.strItemNo) AS strItemNo
					,(
						CASE 
							WHEN MI.intItemId IS NOT NULL
								THEN I.strItemNo + ' - ' + IsNULL(I.strShortName, '')
							ELSE IB.strItemNo
							END
						) AS strItemDescription
					,Replace(Replace(A.strAttributeName, '<a>+ ', ''), '</a>', '') + ' ' + AV.strFieldName AS strAttributeName
					,(
						CASE 
							WHEN IsNUmeric(AV.strValue) = 0
								THEN Convert(NUMERIC(18, 6), 0.0)
							ELSE AV.strValue
							END
						) * (
						CASE 
							WHEN AV.intReportAttributeID = 10
								THEN 1
							ELSE IsNULL(UMCByWeight.dblConversionToStock, 1)
							END
						) AS strValue
					,B.intBookId
					,SB.intSubBookId
					,AV.intMainItemId
					,I.intItemId
					,CASE 
					WHEN @ysnParent = 1
						THEN ST.dblSupplyTarget
					ELSE IL.dblLeadTime
					END AS dblSupplyTarget
					,MI.strItemNo AS strMainItemNo
				FROM tblCTInvPlngReportAttributeValue AV
				JOIN tblCTInvPlngReportMaster RM ON RM.intInvPlngReportMasterID = AV.intInvPlngReportMasterID
				JOIN tblCTReportAttribute A ON A.intReportAttributeID = AV.intReportAttributeID
					AND IsNumeric(AV.strValue) = 1
				LEFT JOIN tblICItem MI ON MI.intItemId = AV.intMainItemId
				JOIN tblICItem I ON I.intItemId = AV.intItemId
				LEFT JOIN tblCTBook B ON B.intBookId = RM.intBookId
				LEFT JOIN tblCTSubBook SB ON SB.intSubBookId = RM.intSubBookId
				LEFT JOIN tblICCommodityAttribute CA ON CA.intCommodityId = I.intCommodityId
					AND I.intProductTypeId = CA.intCommodityAttributeId
					AND CA.strType = 'ProductType'
				LEFT JOIN tblICUnitMeasureConversion UMCByWeight ON UMCByWeight.intUnitMeasureId = RM.intUnitMeasureId --From Unit
					AND UMCByWeight.intStockUnitMeasureId = @intUnitMeasureId
				LEFT JOIN tblIPItemSupplyTarget ST ON ST.intBookId = B.intBookId
					AND IsNULL(ST.intSubBookId, 0) = IsNULL(SB.intSubBookId, 0)
					AND ST.intItemId = I.intItemId
				LEFT JOIN @tblMFItemBook IB ON IB.intItemId = AV.intItemId
					AND IB.intBookId = B.intBookId
					AND IsNULL(IB.intSubBookId, 0) = IsNULL(SB.intSubBookId, 0)
					LEFT JOIN tblICItemLocation IL on IL.intItemId=I.intItemId and IL.intLocationId =@intLocationId
			
				WHERE EXISTS (
						SELECT 1
						FROM tblCTInvPlngReportAttributeValue AV1
						WHERE AV1.intInvPlngReportMasterID = AV.intInvPlngReportMasterID
							AND AV1.intItemId = AV.intItemId
							AND AV1.intReportAttributeID = 8
							AND IsNumeric(AV1.strValue) = 1
							AND (
								CASE 
									WHEN IsNUmeric(AV1.strValue) = 0
										THEN Convert(NUMERIC(18, 6), 0.0)
									ELSE ABS(AV1.strValue)
									END
								) > 0
						)
					AND A.intReportAttributeID IN (
						2 --Opening Inventory
						,4 --Existing Purchases
						,5 --Planned Purchases
						,8 --Forecasted Consumption
						,9 --Ending Inventory
						,10 --Weeks of Supply
						)
					AND AV.intInvPlngReportMasterID IN (
						SELECT Item Collate Latin1_General_CI_AS
						FROM [dbo].[fnSplitString](@strInvPlngReportMasterID, ',')
						)
					AND AV.strFieldName NOT IN (
						'OpeningInv'
						,'PastDue'
						)
					--2-Opening Inventory;8-Forecasted Consumption;9-Ending Inventory;13-Existing Purchases;12-Planned Purchases
				) AS SourceTable
			PIVOT(SUM(strValue) FOR strAttributeName IN (
						[Opening Inventory strMonth1]
						,[Forecasted Consumption strMonth1]
						,[Existing Purchases strMonth1]
						,[Planned Purchases strMonth1]
						,[Ending Inventory strMonth1]
						,[Weeks of Supply strMonth1]
						,[Opening Inventory strMonth2]
						,[Forecasted Consumption strMonth2]
						,[Existing Purchases strMonth2]
						,[Planned Purchases strMonth2]
						,[Ending Inventory strMonth2]
						,[Weeks of Supply strMonth2]
						,[Opening Inventory strMonth3]
						,[Forecasted Consumption strMonth3]
						,[Existing Purchases strMonth3]
						,[Planned Purchases strMonth3]
						,[Ending Inventory strMonth3]
						,[Weeks of Supply strMonth3]
						,[Opening Inventory strMonth4]
						,[Forecasted Consumption strMonth4]
						,[Existing Purchases strMonth4]
						,[Planned Purchases strMonth4]
						,[Ending Inventory strMonth4]
						,[Weeks of Supply strMonth4]
						,[Opening Inventory strMonth5]
						,[Forecasted Consumption strMonth5]
						,[Existing Purchases strMonth5]
						,[Planned Purchases strMonth5]
						,[Ending Inventory strMonth5]
						,[Weeks of Supply strMonth5]
						,[Opening Inventory strMonth6]
						,[Forecasted Consumption strMonth6]
						,[Existing Purchases strMonth6]
						,[Planned Purchases strMonth6]
						,[Ending Inventory strMonth6]
						,[Weeks of Supply strMonth6]
						,[Opening Inventory strMonth7]
						,[Forecasted Consumption strMonth7]
						,[Existing Purchases strMonth7]
						,[Planned Purchases strMonth7]
						,[Ending Inventory strMonth7]
						,[Weeks of Supply strMonth7]
						,[Opening Inventory strMonth8]
						,[Forecasted Consumption strMonth8]
						,[Existing Purchases strMonth8]
						,[Planned Purchases strMonth8]
						,[Ending Inventory strMonth8]
						,[Weeks of Supply strMonth8]
						,[Opening Inventory strMonth9]
						,[Forecasted Consumption strMonth9]
						,[Existing Purchases strMonth9]
						,[Planned Purchases strMonth9]
						,[Ending Inventory strMonth9]
						,[Weeks of Supply strMonth9]
						,[Opening Inventory strMonth10]
						,[Forecasted Consumption strMonth10]
						,[Existing Purchases strMonth10]
						,[Planned Purchases strMonth10]
						,[Ending Inventory strMonth10]
						,[Weeks of Supply strMonth10]
						,[Opening Inventory strMonth11]
						,[Forecasted Consumption strMonth11]
						,[Existing Purchases strMonth11]
						,[Planned Purchases strMonth11]
						,[Ending Inventory strMonth11]
						,[Weeks of Supply strMonth11]
						,[Opening Inventory strMonth12]
						,[Forecasted Consumption strMonth12]
						,[Existing Purchases strMonth12]
						,[Planned Purchases strMonth12]
						,[Ending Inventory strMonth12]
						,[Weeks of Supply strMonth12]
						,[Opening Inventory strMonth13]
						,[Forecasted Consumption strMonth13]
						,[Existing Purchases strMonth13]
						,[Planned Purchases strMonth13]
						,[Ending Inventory strMonth13]
						,[Weeks of Supply strMonth13]
						,[Opening Inventory strMonth14]
						,[Forecasted Consumption strMonth14]
						,[Existing Purchases strMonth14]
						,[Planned Purchases strMonth14]
						,[Ending Inventory strMonth14]
						,[Weeks of Supply strMonth14]
						,[Opening Inventory strMonth15]
						,[Forecasted Consumption strMonth15]
						,[Existing Purchases strMonth15]
						,[Planned Purchases strMonth15]
						,[Ending Inventory strMonth15]
						,[Weeks of Supply strMonth15]
						,[Opening Inventory strMonth16]
						,[Forecasted Consumption strMonth16]
						,[Existing Purchases strMonth16]
						,[Planned Purchases strMonth16]
						,[Ending Inventory strMonth16]
						,[Weeks of Supply strMonth16]
						,[Opening Inventory strMonth17]
						,[Forecasted Consumption strMonth17]
						,[Existing Purchases strMonth17]
						,[Planned Purchases strMonth17]
						,[Ending Inventory strMonth17]
						,[Weeks of Supply strMonth17]
						,[Opening Inventory strMonth18]
						,[Forecasted Consumption strMonth18]
						,[Existing Purchases strMonth18]
						,[Planned Purchases strMonth18]
						,[Ending Inventory strMonth18]
						,[Weeks of Supply strMonth18]
						,[Opening Inventory strMonth19]
						,[Forecasted Consumption strMonth19]
						,[Existing Purchases strMonth19]
						,[Planned Purchases strMonth19]
						,[Ending Inventory strMonth19]
						,[Weeks of Supply strMonth19]
						,[Opening Inventory strMonth20]
						,[Forecasted Consumption strMonth20]
						,[Existing Purchases strMonth20]
						,[Planned Purchases strMonth20]
						,[Ending Inventory strMonth20]
						,[Weeks of Supply strMonth20]
						,[Opening Inventory strMonth21]
						,[Forecasted Consumption strMonth21]
						,[Existing Purchases strMonth21]
						,[Planned Purchases strMonth21]
						,[Ending Inventory strMonth21]
						,[Weeks of Supply strMonth21]
						,[Opening Inventory strMonth22]
						,[Forecasted Consumption strMonth22]
						,[Existing Purchases strMonth22]
						,[Planned Purchases strMonth22]
						,[Ending Inventory strMonth22]
						,[Weeks of Supply strMonth22]
						,[Opening Inventory strMonth23]
						,[Forecasted Consumption strMonth23]
						,[Existing Purchases strMonth23]
						,[Planned Purchases strMonth23]
						,[Ending Inventory strMonth23]
						,[Weeks of Supply strMonth23]
						,[Opening Inventory strMonth24]
						,[Forecasted Consumption strMonth24]
						,[Existing Purchases strMonth24]
						,[Planned Purchases strMonth24]
						,[Ending Inventory strMonth24]
						,[Weeks of Supply strMonth24]
						)) AS PivotTable
		END
		ELSE
		BEGIN
			DECLARE @intReportMasterID INT
				,@dtmDate DATETIME
				,@intCurrentMonth INT

			IF OBJECT_ID('tempdb..#tblMFDemand') IS NOT NULL
				DROP TABLE #tblMFDemand

			CREATE TABLE #tblMFDemand (
				intItemId INT
				,dblQty NUMERIC(18, 6)
				,intAttributeId INT
				,intMonthId INT
				,intMainItemId INT
				,intBookId INT
				,intSubBookId INT
				)

			IF OBJECT_ID('tempdb..#tblMFFinalDemand') IS NOT NULL
				DROP TABLE #tblMFFinalDemand

			CREATE TABLE #tblMFFinalDemand (
				intItemId INT
				,dblQty NUMERIC(18, 6)
				,intAttributeId INT
				,intMonthId INT
				,intMainItemId INT
				,intBookId INT
				,intSubBookId INT
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

			DECLARE @tblMFDate TABLE (
				dtmDate DATETIME
				,intBookId INT
				,intSubBookId INT
				,intCurrentMonth INT
				)

			INSERT INTO @tblMFDate (
				dtmDate
				,intBookId
				,intSubBookId
				,intCurrentMonth
				)
			SELECT Max(dtmDate)
				,intBookId
				,intSubBookId
				,DATEDIFF(mm, 0, Max(dtmDate))
			FROM tblCTInvPlngReportMaster
			WHERE ysnPost = 1
				AND intInvPlngReportMasterID IN (
					SELECT Item Collate Latin1_General_CI_AS
					FROM [dbo].[fnSplitString](@strInvPlngReportMasterID, ',')
					)
			GROUP BY intBookId
				,intSubBookId

			INSERT INTO @tblMFItemDetail (
				intItemId
				,intMainItemId
				,ysnSpecificItemDescription
				)
			SELECT DISTINCT intItemId
				,IsNULL(intMainItemId, intItemId)
				,CASE 
					WHEN intItemId <> intMainItemId
						THEN 1
					ELSE 0
					END AS ysnSpecificItemDescription
			FROM tblCTInvPlngReportAttributeValue
			WHERE intReportAttributeID = 13 --Existing Purchases 
				AND intInvPlngReportMasterID IN (
					SELECT Item Collate Latin1_General_CI_AS
					FROM [dbo].[fnSplitString](@strInvPlngReportMasterID, ',')
					)

			INSERT INTO @tblMFItemDetail (
				intItemId
				,intMainItemId
				,ysnSpecificItemDescription
				)
			SELECT IB.intBundleItemId AS intItemId
				,IB.intItemId AS intMainItemId
				,0
			FROM @tblMFItemDetail I
			LEFT JOIN tblICItemBundle IB ON IB.intItemId = I.intItemId
			WHERE I.ysnSpecificItemDescription = 0
				--AND I.intMainItemId IS NULL
				AND NOT EXISTS (
					SELECT *
					FROM @tblMFItemDetail FI
					WHERE FI.intItemId = IB.intBundleItemId
					)
				AND IB.intBundleItemId IS NOT NULL

			INSERT INTO #tblMFDemand (
				intItemId
				,dblQty
				,intAttributeId
				,intMonthId
				,intMainItemId
				,intBookId
				,intSubBookId
				)
			SELECT CASE 
					WHEN I.ysnSpecificItemDescription = 1
						THEN I.intItemId
					ELSE I.intMainItemId
					END AS intItemId
				,sum(dbo.fnCTConvertQuantityToTargetItemUOM(SS.intItemId, IU.intUnitMeasureId, @intUnitMeasureId, SS.dblBalance)) AS dblIntrasitQty
				,4 AS intAttributeId --Existing Purchases
				,DATEDIFF(mm, 0, SS.dtmUpdatedAvailabilityDate) + 1 - D.intCurrentMonth AS intMonthId
				,CASE 
					WHEN I.ysnSpecificItemDescription = 1
						THEN I.intMainItemId
					ELSE NULL
					END AS intMainItemId
				,SS.intBookId
				,SS.intSubBookId
			FROM @tblMFItemDetail I
			JOIN dbo.tblCTContractDetail SS ON SS.intItemId = I.intItemId
			JOIN dbo.tblCTContractHeader CH ON CH.intContractHeaderId = SS.intContractHeaderId
				AND CH.intContractTypeId = 2
			JOIN dbo.tblICItemUOM IU ON IU.intItemUOMId = SS.intItemUOMId
				AND ISNULL(SS.intCompanyLocationId, 0) = (
					CASE 
						WHEN @intCompanyLocationId = 0
							THEN ISNULL(SS.intCompanyLocationId, 0)
						ELSE @intCompanyLocationId
						END
					)
			JOIN @tblMFDate D ON D.intBookId = SS.intBookId
				AND IsNULL(D.intSubBookId, 0) = IsNULL(SS.intSubBookId, 0)
			WHERE SS.intContractStatusId = 1
				AND SS.dtmUpdatedAvailabilityDate > D.dtmDate
			GROUP BY CASE 
					WHEN I.ysnSpecificItemDescription = 1
						THEN I.intItemId
					ELSE I.intMainItemId
					END
				,DATEDIFF(mm, 0, SS.dtmUpdatedAvailabilityDate) + 1 - D.intCurrentMonth
				,CASE 
					WHEN I.ysnSpecificItemDescription = 1
						THEN I.intMainItemId
					ELSE NULL
					END
				,SS.intBookId
				,SS.intSubBookId

			INSERT INTO #tblMFDemand (
				intItemId
				,dblQty
				,intAttributeId
				,intMonthId
				,intMainItemId
				,intBookId
				,intSubBookId
				)
			SELECT intItemId
				,- dblQty
				,5 AS intAttributeId --Planned Purchases
				,intMonthId
				,intMainItemId
				,intBookId
				,intSubBookId
			FROM #tblMFDemand

			INSERT INTO #tblMFDemand (
				intItemId
				,dblQty
				,intAttributeId
				,intMonthId
				,intBookId
				,intSubBookId
				,intMainItemId
				)
			SELECT AV.intItemId
				,CASE 
					WHEN AV.strValue = ''
						THEN NULL
					ELSE (
							(AV.strValue) * (
								CASE 
									WHEN AV.intAttributeId = 10
										THEN 1
									ELSE IsNULL(UMCByWeight.dblConversionToStock, 1)
									END
								)
							)
					END
				,AV.intAttributeId
				,Replace(Replace(Replace(AV.strFieldName, 'strMonth', ''), 'OpeningInv', '-1'), 'PastDue', '0') intMonthId
				,AV.intBookId
				,AV.intSubBookId
				,AV.intMainItemId
			FROM tblMFInvPlngSummaryDetail AV
			JOIN tblMFInvPlngSummary RM ON RM.intInvPlngSummaryId = AV.intInvPlngSummaryId
			JOIN tblMFInvPlngSummaryBatch B ON B.intInvPlngSummaryId = AV.intInvPlngSummaryId
			LEFT JOIN tblICUnitMeasureConversion UMCByWeight ON UMCByWeight.intUnitMeasureId = RM.intUnitMeasureId --From Unit
				AND UMCByWeight.intStockUnitMeasureId = @intUnitMeasureId
			WHERE AV.intAttributeId IN (
					2 --Opening Inventory
					,4 --Existing Purchases
					,5 --Planned Purchases
					,8 --Forecasted Consumption
					,9 --Ending Inventory
					,10 --Weeks of Supply
					)
				AND B.intInvPlngReportMasterID IN (
					SELECT Item Collate Latin1_General_CI_AS
					FROM [dbo].[fnSplitString](@strInvPlngReportMasterID, ',')
					)
				AND AV.intInvPlngSummaryId = @intInvPlngSummaryId

			INSERT INTO #tblMFFinalDemand (
				intItemId
				,dblQty
				,intAttributeId
				,intMonthId
				,intMainItemId
				,intBookId
				,intSubBookId
				)
			SELECT intItemId
				,SUM(dblQty) AS dblQty
				,intAttributeId
				,intMonthId
				,intMainItemId
				,intBookId
				,intSubBookId
			FROM #tblMFDemand
			GROUP BY intItemId
				,intAttributeId
				,intMonthId
				,intMainItemId
				,intBookId
				,intSubBookId

			SELECT Row_Number() OVER (
					ORDER BY strBook
						,strSubBook
						,strProductType
						,IsNULL(strMainItemNo, strItemNo)
						,strItemNo
						,strItemDescription
					) AS intSort
				,intBookId
				,intSubBookId
				,intMainItemId
				,intItemId
				,strBook
				,strSubBook
				,strProductType
				,strItemNo
				,strItemDescription
				,dblSupplyTarget AS strSupplyTarget
				,IsNULL([Opening Inventory strMonth1], 0) AS strOIMonth1
				,IsNULL([Forecasted Consumption strMonth1], 0) AS strFCMonth1
				,IsNULL([Existing Purchases strMonth1], 0) AS strOPMonth1
				,IsNULL([Planned Purchases strMonth1], 0) AS strSEMonth1
				,IsNULL([Ending Inventory strMonth1], 0) AS strEIMonth1
				,IsNULL([Weeks of Supply strMonth1], 0) AS strSTMonth1
				,IsNULL([Opening Inventory strMonth2], 0) AS strOIMonth2
				,IsNULL([Forecasted Consumption strMonth2], 0) AS strFCMonth2
				,IsNULL([Existing Purchases strMonth2], 0) AS strOPMonth2
				,IsNULL([Planned Purchases strMonth2], 0) AS strSEMonth2
				,IsNULL([Ending Inventory strMonth2], 0) AS strEIMonth2
				,IsNULL([Weeks of Supply strMonth2], 0) AS strSTMonth2
				,IsNULL([Opening Inventory strMonth3], 0) AS strOIMonth3
				,IsNULL([Forecasted Consumption strMonth3], 0) AS strFCMonth3
				,IsNULL([Existing Purchases strMonth3], 0) AS strOPMonth3
				,IsNULL([Planned Purchases strMonth3], 0) AS strSEMonth3
				,IsNULL([Ending Inventory strMonth3], 0) AS strEIMonth3
				,IsNULL([Weeks of Supply strMonth3], 0) AS strSTMonth3
				,IsNULL([Opening Inventory strMonth4], 0) AS strOIMonth4
				,IsNULL([Forecasted Consumption strMonth4], 0) AS strFCMonth4
				,IsNULL([Existing Purchases strMonth4], 0) AS strOPMonth4
				,IsNULL([Planned Purchases strMonth4], 0) AS strSEMonth4
				,IsNULL([Ending Inventory strMonth4], 0) AS strEIMonth4
				,IsNULL([Weeks of Supply strMonth4], 0) AS strSTMonth4
				,IsNULL([Opening Inventory strMonth5], 0) AS strOIMonth5
				,IsNULL([Forecasted Consumption strMonth5], 0) AS strFCMonth5
				,IsNULL([Existing Purchases strMonth5], 0) AS strOPMonth5
				,IsNULL([Planned Purchases strMonth5], 0) AS strSEMonth5
				,IsNULL([Ending Inventory strMonth5], 0) AS strEIMonth5
				,IsNULL([Weeks of Supply strMonth5], 0) AS strSTMonth5
				,IsNULL([Opening Inventory strMonth6], 0) AS strOIMonth6
				,IsNULL([Forecasted Consumption strMonth6], 0) AS strFCMonth6
				,IsNULL([Existing Purchases strMonth6], 0) AS strOPMonth6
				,IsNULL([Planned Purchases strMonth6], 0) AS strSEMonth6
				,IsNULL([Ending Inventory strMonth6], 0) AS strEIMonth6
				,IsNULL([Weeks of Supply strMonth6], 0) AS strSTMonth6
				,IsNULL([Opening Inventory strMonth7], 0) AS strOIMonth7
				,IsNULL([Forecasted Consumption strMonth7], 0) AS strFCMonth7
				,IsNULL([Existing Purchases strMonth7], 0) AS strOPMonth7
				,IsNULL([Planned Purchases strMonth7], 0) AS strSEMonth7
				,IsNULL([Ending Inventory strMonth7], 0) AS strEIMonth7
				,IsNULL([Weeks of Supply strMonth7], 0) AS strSTMonth7
				,IsNULL([Opening Inventory strMonth8], 0) AS strOIMonth8
				,IsNULL([Forecasted Consumption strMonth8], 0) AS strFCMonth8
				,IsNULL([Existing Purchases strMonth8], 0) AS strOPMonth8
				,IsNULL([Planned Purchases strMonth8], 0) AS strSEMonth8
				,IsNULL([Ending Inventory strMonth8], 0) AS strEIMonth8
				,IsNULL([Weeks of Supply strMonth8], 0) AS strSTMonth8
				,IsNULL([Opening Inventory strMonth9], 0) AS strOIMonth9
				,IsNULL([Forecasted Consumption strMonth9], 0) AS strFCMonth9
				,IsNULL([Existing Purchases strMonth9], 0) AS strOPMonth9
				,IsNULL([Planned Purchases strMonth9], 0) AS strSEMonth9
				,IsNULL([Ending Inventory strMonth9], 0) AS strEIMonth9
				,IsNULL([Weeks of Supply strMonth9], 0) AS strSTMonth9
				,IsNULL([Opening Inventory strMonth10], 0) AS strOIMonth10
				,IsNULL([Forecasted Consumption strMonth10], 0) AS strFCMonth10
				,IsNULL([Existing Purchases strMonth10], 0) AS strOPMonth10
				,IsNULL([Planned Purchases strMonth10], 0) AS strSEMonth10
				,IsNULL([Ending Inventory strMonth10], 0) AS strEIMonth10
				,IsNULL([Weeks of Supply strMonth10], 0) AS strSTMonth10
				,IsNULL([Opening Inventory strMonth11], 0) AS strOIMonth11
				,IsNULL([Forecasted Consumption strMonth11], 0) AS strFCMonth11
				,IsNULL([Existing Purchases strMonth11], 0) AS strOPMonth11
				,IsNULL([Planned Purchases strMonth11], 0) AS strSEMonth11
				,IsNULL([Ending Inventory strMonth11], 0) AS strEIMonth11
				,IsNULL([Weeks of Supply strMonth11], 0) AS strSTMonth11
				,IsNULL([Opening Inventory strMonth12], 0) AS strOIMonth12
				,IsNULL([Forecasted Consumption strMonth12], 0) AS strFCMonth12
				,IsNULL([Existing Purchases strMonth12], 0) AS strOPMonth12
				,IsNULL([Planned Purchases strMonth12], 0) AS strSEMonth12
				,IsNULL([Ending Inventory strMonth12], 0) AS strEIMonth12
				,IsNULL([Weeks of Supply strMonth12], 0) AS strSTMonth12
				,IsNULL([Opening Inventory strMonth13], 0) AS strOIMonth13
				,IsNULL([Forecasted Consumption strMonth13], 0) AS strFCMonth13
				,IsNULL([Existing Purchases strMonth13], 0) AS strOPMonth13
				,IsNULL([Planned Purchases strMonth13], 0) AS strSEMonth13
				,IsNULL([Ending Inventory strMonth13], 0) AS strEIMonth13
				,IsNULL([Weeks of Supply strMonth13], 0) AS strSTMonth13
				,IsNULL([Opening Inventory strMonth14], 0) AS strOIMonth14
				,IsNULL([Forecasted Consumption strMonth14], 0) AS strFCMonth14
				,IsNULL([Existing Purchases strMonth14], 0) AS strOPMonth14
				,IsNULL([Planned Purchases strMonth14], 0) AS strSEMonth14
				,IsNULL([Ending Inventory strMonth14], 0) AS strEIMonth14
				,IsNULL([Weeks of Supply strMonth14], 0) AS strSTMonth14
				,IsNULL([Opening Inventory strMonth15], 0) AS strOIMonth15
				,IsNULL([Forecasted Consumption strMonth15], 0) AS strFCMonth15
				,IsNULL([Existing Purchases strMonth15], 0) AS strOPMonth15
				,IsNULL([Planned Purchases strMonth15], 0) AS strSEMonth15
				,IsNULL([Ending Inventory strMonth15], 0) AS strEIMonth15
				,IsNULL([Weeks of Supply strMonth15], 0) AS strSTMonth15
				,IsNULL([Opening Inventory strMonth16], 0) AS strOIMonth16
				,IsNULL([Forecasted Consumption strMonth16], 0) AS strFCMonth16
				,IsNULL([Existing Purchases strMonth16], 0) AS strOPMonth16
				,IsNULL([Planned Purchases strMonth16], 0) AS strSEMonth16
				,IsNULL([Ending Inventory strMonth16], 0) AS strEIMonth16
				,IsNULL([Weeks of Supply strMonth16], 0) AS strSTMonth16
				,IsNULL([Opening Inventory strMonth17], 0) AS strOIMonth17
				,IsNULL([Forecasted Consumption strMonth17], 0) AS strFCMonth17
				,IsNULL([Existing Purchases strMonth17], 0) AS strOPMonth17
				,IsNULL([Planned Purchases strMonth17], 0) AS strSEMonth17
				,IsNULL([Ending Inventory strMonth17], 0) AS strEIMonth17
				,IsNULL([Weeks of Supply strMonth17], 0) AS strSTMonth17
				,IsNULL([Opening Inventory strMonth18], 0) AS strOIMonth18
				,IsNULL([Forecasted Consumption strMonth18], 0) AS strFCMonth18
				,IsNULL([Existing Purchases strMonth18], 0) AS strOPMonth18
				,IsNULL([Planned Purchases strMonth18], 0) AS strSEMonth18
				,IsNULL([Ending Inventory strMonth18], 0) AS strEIMonth18
				,IsNULL([Weeks of Supply strMonth18], 0) AS strSTMonth18
				,IsNULL([Opening Inventory strMonth19], 0) AS strOIMonth19
				,IsNULL([Forecasted Consumption strMonth19], 0) AS strFCMonth19
				,IsNULL([Existing Purchases strMonth19], 0) AS strOPMonth19
				,IsNULL([Planned Purchases strMonth19], 0) AS strSEMonth19
				,IsNULL([Ending Inventory strMonth19], 0) AS strEIMonth19
				,IsNULL([Weeks of Supply strMonth19], 0) AS strSTMonth19
				,IsNULL([Opening Inventory strMonth20], 0) AS strOIMonth20
				,IsNULL([Forecasted Consumption strMonth20], 0) AS strFCMonth20
				,IsNULL([Existing Purchases strMonth20], 0) AS strOPMonth20
				,IsNULL([Planned Purchases strMonth20], 0) AS strSEMonth20
				,IsNULL([Ending Inventory strMonth20], 0) AS strEIMonth20
				,IsNULL([Weeks of Supply strMonth20], 0) AS strSTMonth20
				,IsNULL([Opening Inventory strMonth21], 0) AS strOIMonth21
				,IsNULL([Forecasted Consumption strMonth21], 0) AS strFCMonth21
				,IsNULL([Existing Purchases strMonth21], 0) AS strOPMonth21
				,IsNULL([Planned Purchases strMonth21], 0) AS strSEMonth21
				,IsNULL([Ending Inventory strMonth21], 0) AS strEIMonth21
				,IsNULL([Weeks of Supply strMonth21], 0) AS strSTMonth21
				,IsNULL([Opening Inventory strMonth22], 0) AS strOIMonth22
				,IsNULL([Forecasted Consumption strMonth22], 0) AS strFCMonth22
				,IsNULL([Existing Purchases strMonth22], 0) AS strOPMonth22
				,IsNULL([Planned Purchases strMonth22], 0) AS strSEMonth22
				,IsNULL([Ending Inventory strMonth22], 0) AS strEIMonth22
				,IsNULL([Weeks of Supply strMonth22], 0) AS strSTMonth22
				,IsNULL([Opening Inventory strMonth23], 0) AS strOIMonth23
				,IsNULL([Forecasted Consumption strMonth23], 0) AS strFCMonth23
				,IsNULL([Existing Purchases strMonth23], 0) AS strOPMonth23
				,IsNULL([Planned Purchases strMonth23], 0) AS strSEMonth23
				,IsNULL([Ending Inventory strMonth23], 0) AS strEIMonth23
				,IsNULL([Weeks of Supply strMonth23], 0) AS strSTMonth23
				,IsNULL([Opening Inventory strMonth24], 0) AS strOIMonth24
				,IsNULL([Forecasted Consumption strMonth24], 0) AS strFCMonth24
				,IsNULL([Existing Purchases strMonth24], 0) AS strOPMonth24
				,IsNULL([Planned Purchases strMonth24], 0) AS strSEMonth24
				,IsNULL([Ending Inventory strMonth24], 0) AS strEIMonth24
				,IsNULL([Weeks of Supply strMonth24], 0) AS strSTMonth24
			FROM (
				SELECT B.strBook
					,SB.strSubBook
					,CA.strDescription AS strProductType
					,IsNULL(MI.strItemNo, I.strItemNo) AS strItemNo
					,(
						CASE 
							WHEN MI.intItemId IS NOT NULL
								THEN I.strItemNo + ' - ' + IsNULL(I.strShortName, '')
							ELSE IB.strItemNo
							END
						) AS strItemDescription
					,Replace(Replace(A.strAttributeName, '<a>+ ', ''), '</a>', '') + ' strMonth' + Ltrim(FD.intMonthId) AS strAttributeName
					,(
						CASE 
							WHEN IsNUmeric(FD.dblQty) = 0
								THEN Convert(NUMERIC(18, 6), 0.0)
							ELSE FD.dblQty
							END
						) AS strValue
					,B.intBookId
					,SB.intSubBookId
					,FD.intMainItemId
					,I.intItemId
					,CASE 
					WHEN @ysnParent = 1
						THEN ST.dblSupplyTarget
					ELSE IL.dblLeadTime
					END AS dblSupplyTarget
					,MI.strItemNo AS strMainItemNo
				FROM #tblMFFinalDemand FD
				JOIN tblCTReportAttribute A ON A.intReportAttributeID = FD.intAttributeId
				--JOIN tblCTInvPlngReportMaster RM ON RM.intInvPlngReportMasterID = @intReportMasterID
				LEFT JOIN tblICItem MI ON MI.intItemId = FD.intMainItemId
				JOIN tblICItem I ON I.intItemId = FD.intItemId
				LEFT JOIN tblCTBook B ON B.intBookId = FD.intBookId
				LEFT JOIN tblCTSubBook SB ON SB.intSubBookId = FD.intSubBookId
				LEFT JOIN tblICCommodityAttribute CA ON CA.intCommodityId = I.intCommodityId
					AND I.intProductTypeId = CA.intCommodityAttributeId
					AND CA.strType = 'ProductType'
				LEFT JOIN tblIPItemSupplyTarget ST ON ST.intBookId = B.intBookId
					AND IsNULL(ST.intSubBookId, 0) = IsNULL(SB.intSubBookId, 0)
					AND ST.intItemId = I.intItemId
				LEFT JOIN @tblMFItemBook IB ON IB.intItemId = FD.intItemId
					AND IB.intBookId = B.intBookId
					AND IsNULL(IB.intSubBookId, 0) = IsNULL(SB.intSubBookId, 0)
					LEFT JOIN tblICItemLocation IL on IL.intItemId=I.intItemId and IL.intLocationId =@intLocationId
				WHERE IsNumeric(FD.dblQty) = 1
					--2-Opening Inventory;8-Forecasted Consumption;9-Ending Inventory;13-Existing Purchases;12-Planned Purchases
				) AS SourceTable
			PIVOT(SUM(strValue) FOR strAttributeName IN (
						[Opening Inventory strMonth1]
						,[Forecasted Consumption strMonth1]
						,[Existing Purchases strMonth1]
						,[Planned Purchases strMonth1]
						,[Ending Inventory strMonth1]
						,[Weeks of Supply strMonth1]
						,[Opening Inventory strMonth2]
						,[Forecasted Consumption strMonth2]
						,[Existing Purchases strMonth2]
						,[Planned Purchases strMonth2]
						,[Ending Inventory strMonth2]
						,[Weeks of Supply strMonth2]
						,[Opening Inventory strMonth3]
						,[Forecasted Consumption strMonth3]
						,[Existing Purchases strMonth3]
						,[Planned Purchases strMonth3]
						,[Ending Inventory strMonth3]
						,[Weeks of Supply strMonth3]
						,[Opening Inventory strMonth4]
						,[Forecasted Consumption strMonth4]
						,[Existing Purchases strMonth4]
						,[Planned Purchases strMonth4]
						,[Ending Inventory strMonth4]
						,[Weeks of Supply strMonth4]
						,[Opening Inventory strMonth5]
						,[Forecasted Consumption strMonth5]
						,[Existing Purchases strMonth5]
						,[Planned Purchases strMonth5]
						,[Ending Inventory strMonth5]
						,[Weeks of Supply strMonth5]
						,[Opening Inventory strMonth6]
						,[Forecasted Consumption strMonth6]
						,[Existing Purchases strMonth6]
						,[Planned Purchases strMonth6]
						,[Ending Inventory strMonth6]
						,[Weeks of Supply strMonth6]
						,[Opening Inventory strMonth7]
						,[Forecasted Consumption strMonth7]
						,[Existing Purchases strMonth7]
						,[Planned Purchases strMonth7]
						,[Ending Inventory strMonth7]
						,[Weeks of Supply strMonth7]
						,[Opening Inventory strMonth8]
						,[Forecasted Consumption strMonth8]
						,[Existing Purchases strMonth8]
						,[Planned Purchases strMonth8]
						,[Ending Inventory strMonth8]
						,[Weeks of Supply strMonth8]
						,[Opening Inventory strMonth9]
						,[Forecasted Consumption strMonth9]
						,[Existing Purchases strMonth9]
						,[Planned Purchases strMonth9]
						,[Ending Inventory strMonth9]
						,[Weeks of Supply strMonth9]
						,[Opening Inventory strMonth10]
						,[Forecasted Consumption strMonth10]
						,[Existing Purchases strMonth10]
						,[Planned Purchases strMonth10]
						,[Ending Inventory strMonth10]
						,[Weeks of Supply strMonth10]
						,[Opening Inventory strMonth11]
						,[Forecasted Consumption strMonth11]
						,[Existing Purchases strMonth11]
						,[Planned Purchases strMonth11]
						,[Ending Inventory strMonth11]
						,[Weeks of Supply strMonth11]
						,[Opening Inventory strMonth12]
						,[Forecasted Consumption strMonth12]
						,[Existing Purchases strMonth12]
						,[Planned Purchases strMonth12]
						,[Ending Inventory strMonth12]
						,[Weeks of Supply strMonth12]
						,[Opening Inventory strMonth13]
						,[Forecasted Consumption strMonth13]
						,[Existing Purchases strMonth13]
						,[Planned Purchases strMonth13]
						,[Ending Inventory strMonth13]
						,[Weeks of Supply strMonth13]
						,[Opening Inventory strMonth14]
						,[Forecasted Consumption strMonth14]
						,[Existing Purchases strMonth14]
						,[Planned Purchases strMonth14]
						,[Ending Inventory strMonth14]
						,[Weeks of Supply strMonth14]
						,[Opening Inventory strMonth15]
						,[Forecasted Consumption strMonth15]
						,[Existing Purchases strMonth15]
						,[Planned Purchases strMonth15]
						,[Ending Inventory strMonth15]
						,[Weeks of Supply strMonth15]
						,[Opening Inventory strMonth16]
						,[Forecasted Consumption strMonth16]
						,[Existing Purchases strMonth16]
						,[Planned Purchases strMonth16]
						,[Ending Inventory strMonth16]
						,[Weeks of Supply strMonth16]
						,[Opening Inventory strMonth17]
						,[Forecasted Consumption strMonth17]
						,[Existing Purchases strMonth17]
						,[Planned Purchases strMonth17]
						,[Ending Inventory strMonth17]
						,[Weeks of Supply strMonth17]
						,[Opening Inventory strMonth18]
						,[Forecasted Consumption strMonth18]
						,[Existing Purchases strMonth18]
						,[Planned Purchases strMonth18]
						,[Ending Inventory strMonth18]
						,[Weeks of Supply strMonth18]
						,[Opening Inventory strMonth19]
						,[Forecasted Consumption strMonth19]
						,[Existing Purchases strMonth19]
						,[Planned Purchases strMonth19]
						,[Ending Inventory strMonth19]
						,[Weeks of Supply strMonth19]
						,[Opening Inventory strMonth20]
						,[Forecasted Consumption strMonth20]
						,[Existing Purchases strMonth20]
						,[Planned Purchases strMonth20]
						,[Ending Inventory strMonth20]
						,[Weeks of Supply strMonth20]
						,[Opening Inventory strMonth21]
						,[Forecasted Consumption strMonth21]
						,[Existing Purchases strMonth21]
						,[Planned Purchases strMonth21]
						,[Ending Inventory strMonth21]
						,[Weeks of Supply strMonth21]
						,[Opening Inventory strMonth22]
						,[Forecasted Consumption strMonth22]
						,[Existing Purchases strMonth22]
						,[Planned Purchases strMonth22]
						,[Ending Inventory strMonth22]
						,[Weeks of Supply strMonth22]
						,[Opening Inventory strMonth23]
						,[Forecasted Consumption strMonth23]
						,[Existing Purchases strMonth23]
						,[Planned Purchases strMonth23]
						,[Ending Inventory strMonth23]
						,[Weeks of Supply strMonth23]
						,[Opening Inventory strMonth24]
						,[Forecasted Consumption strMonth24]
						,[Existing Purchases strMonth24]
						,[Planned Purchases strMonth24]
						,[Ending Inventory strMonth24]
						,[Weeks of Supply strMonth24]
						)) AS PivotTable
				--ORDER BY strBook
				--	,strSubBook
				--	,strProductType
				--	,strItemNo
				--	,strItemDescription
		END
	END
END
