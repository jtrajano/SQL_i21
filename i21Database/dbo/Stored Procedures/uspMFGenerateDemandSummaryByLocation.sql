CREATE PROCEDURE [dbo].[uspMFGenerateDemandSummaryByLocation] @intInvPlngReportMasterID INT
AS
SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

BEGIN
	DECLARE @Txt1 VARCHAR(MAX)
		,@intItemIdList VARCHAR(MAX)
		,@strItemNoList VARCHAR(MAX)
		,@ysnAllItem BIT
		,@intCategoryId INT
		,@intMonthsToView INT = 12
		,@intMonthId INT= 1
		,@intLocationId INT
		,@dblSupplyTarget INT
		,@dblDecimalPart NUMERIC(18, 6)
		,@intIntegerPart INT
		,@dblTotalConsumptionQty NUMERIC(18, 6)
		,@intConsumptionAvlMonth INT
		,@dblEndInventory NUMERIC(18, 6)
		,@dblWeeksOfSsupply NUMERIC(18, 6)
		,@intConsumptionMonth INT
		,@dblRemainingConsumptionQty NUMERIC(18, 6)
		,@dblConsumptionQty NUMERIC(18, 6)

	IF ISNULL((
				SELECT 1
				FROM tblCTInvPlngReportMaster
				WHERE intInvPlngReportMasterID = @intInvPlngReportMasterID
				), 0) = 0
	BEGIN
		RETURN
	END

	SELECT @ysnAllItem = ysnAllItem
		,@intCategoryId = intCategoryId
	FROM tblCTInvPlngReportMaster
	WHERE intInvPlngReportMasterID = @intInvPlngReportMasterID

	IF ISNULL(@ysnAllItem, 0) = 0
	BEGIN
		IF ISNULL((
					SELECT TOP 1 intItemId
					FROM tblCTInvPlngReportMaterial
					WHERE intInvPlngReportMasterID = @intInvPlngReportMasterID
					), 0) = 0
		BEGIN
			--SELECT NULL
			RETURN
		END

		SET @Txt1 = ''

		SELECT @Txt1 = @Txt1 + CAST(intItemId AS VARCHAR(20)) + ','
		FROM tblCTInvPlngReportMaterial
		WHERE intInvPlngReportMasterID = @intInvPlngReportMasterID

		SELECT @intItemIdList = LEFT(@Txt1, LEN(@Txt1) - 1)

		SET @Txt1 = ''

		SELECT @Txt1 = @Txt1 + CAST(I.strItemNo AS VARCHAR(50)) + '^' -- ItemNo can contain ,
		FROM tblCTInvPlngReportMaterial RM
		JOIN tblICItem I ON I.intItemId = RM.intItemId
		WHERE RM.intInvPlngReportMasterID = @intInvPlngReportMasterID

		SELECT @strItemNoList = LEFT(@Txt1, LEN(@Txt1) - 1)
	END
	ELSE
	BEGIN
		SET @Txt1 = ''

		SELECT @Txt1 = @Txt1 + CAST(intItemId AS VARCHAR(20)) + ','
		FROM tblICItem
		WHERE intCategoryId = @intCategoryId

		IF Len(@Txt1) > 0
			SELECT @intItemIdList = LEFT(@Txt1, LEN(@Txt1) - 1)

		SET @Txt1 = ''

		SELECT @Txt1 = @Txt1 + CAST(I.strItemNo AS VARCHAR(50)) + '^' -- ItemNo can contain ,
		FROM tblICItem I
		WHERE intCategoryId = @intCategoryId

		IF Len(@Txt1) > 0
			SELECT @strItemNoList = LEFT(@Txt1, LEN(@Txt1) - 1)
	END

	SELECT RM.*
		,C.strCategoryCode
		,DH.strDemandName
		,B.strBook
		,SB.strSubBook
		,UOM.strUnitMeasure
		,CL.strLocationName
		,@intItemIdList AS 'intItemIdList'
		,@strItemNoList AS 'strItemNoList'
	FROM dbo.tblCTInvPlngReportMaster RM
	LEFT JOIN tblICCategory C ON C.intCategoryId = RM.intCategoryId
	LEFT JOIN tblMFDemandHeader DH ON DH.intDemandHeaderId = RM.intDemandHeaderId
	LEFT JOIN tblICUnitMeasure AS UOM ON UOM.intUnitMeasureId = RM.intUnitMeasureId
	LEFT JOIN tblSMCompanyLocation CL ON CL.intCompanyLocationId = RM.intCompanyLocationId
	LEFT JOIN tblCTBook B ON B.intBookId = RM.intBookId
	LEFT JOIN tblCTSubBook SB ON SB.intSubBookId = RM.intSubBookId
	WHERE RM.intInvPlngReportMasterID = @intInvPlngReportMasterID

	DECLARE @tblCTInvPlngReportAttributeValue TABLE (
		intInvPlngReportMasterID INT
		,intReportAttributeID INT
		,strFieldName NVARCHAR(50)
		,strValue NVARCHAR(50)
		,intLocationId INT
		,intMonthId INT
		,dblQty NUMERIC(18, 6)
		)

	INSERT INTO @tblCTInvPlngReportAttributeValue (
		intInvPlngReportMasterID
		,intReportAttributeID
		,strFieldName
		,strValue
		,intLocationId
		,intMonthId
		,dblQty
		)
	SELECT intInvPlngReportMasterID
		,intReportAttributeID
		,strFieldName
		,Sum(CASE 
				WHEN IsNumeric(strValue) = 1
					THEN Convert(NUMERIC(18, 6), strValue)
				ELSE 0
				END)
		,intLocationId
		,Replace(Replace(Replace(strFieldName, 'strMonth', ''), 'OpeningInv', ''), 'PastDue', '')
		,Sum(CASE 
				WHEN IsNumeric(strValue) = 1
					THEN Convert(NUMERIC(18, 6), strValue)
				ELSE 0
				END)
	FROM dbo.tblCTInvPlngReportAttributeValue s
	WHERE s.intInvPlngReportMasterID = @intInvPlngReportMasterID
		AND s.intReportAttributeID IN (
			2
			,5
			,4
			,6
			,8
			,9
			,13
			,14
			,15
			,16
			)
		AND intLocationId IS NOT NULL
	GROUP BY intInvPlngReportMasterID
		,intReportAttributeID
		,strFieldName
		,intLocationId

	DECLARE @tblSMCompanyLocation TABLE (intLocationId INT)

	INSERT INTO @tblSMCompanyLocation
	SELECT DISTINCT intLocationId
	FROM @tblCTInvPlngReportAttributeValue

	IF (
			SELECT Count(*)
			FROM @tblSMCompanyLocation
			) > 1
	BEGIN
		INSERT INTO @tblCTInvPlngReportAttributeValue (
			intInvPlngReportMasterID
			,intReportAttributeID
			,strFieldName
			,strValue
			,intLocationId
			,intMonthId
			,dblQty
			)
		SELECT intInvPlngReportMasterID
			,intReportAttributeID
			,strFieldName
			,Sum(CASE 
					WHEN IsNumeric(strValue) = 1
						THEN Convert(NUMERIC(18, 6), strValue)
					ELSE 0
					END)
			,9999
			,Replace(Replace(Replace(strFieldName, 'strMonth', ''), 'OpeningInv', ''), 'PastDue', '')
			,Sum(CASE 
					WHEN IsNumeric(strValue) = 1
						THEN Convert(NUMERIC(18, 6), strValue)
					ELSE 0
					END)
		FROM dbo.tblCTInvPlngReportAttributeValue s
		WHERE s.intInvPlngReportMasterID = @intInvPlngReportMasterID
			AND s.intReportAttributeID IN (
				2
				,5
				,6
				,8
				,9
				,13
				,14
				,15
				,16
				)
			AND intLocationId IS NOT NULL
			AND IsNumeric(strValue) = 1
		GROUP BY intInvPlngReportMasterID
			,intReportAttributeID
			,strFieldName
	END

	INSERT INTO @tblCTInvPlngReportAttributeValue (
		intInvPlngReportMasterID
		,intReportAttributeID
		,strFieldName
		,strValue
		,intLocationId
		)
	SELECT intInvPlngReportMasterID
		,intReportAttributeID
		,strFieldName
		,strValue
		,intLocationId
	FROM dbo.tblCTInvPlngReportAttributeValue s
	WHERE s.intInvPlngReportMasterID = @intInvPlngReportMasterID
		AND s.intReportAttributeID = 1

	INSERT INTO @tblCTInvPlngReportAttributeValue (
		intInvPlngReportMasterID
		,intReportAttributeID
		,strFieldName
		,strValue
		,intLocationId
		)
	SELECT intInvPlngReportMasterID
		,intReportAttributeID
		,strFieldName
		,MAX(strValue)
		,intLocationId
	FROM dbo.tblCTInvPlngReportAttributeValue s
	WHERE s.intInvPlngReportMasterID = @intInvPlngReportMasterID
		AND s.intReportAttributeID = 11
		Group by intInvPlngReportMasterID
		,intReportAttributeID
		,strFieldName
		,intLocationId

	WHILE @intMonthId <= @intMonthsToView
	BEGIN
		SELECT @intLocationId = NULL

		SELECT @intLocationId = MIN(intLocationId)
		FROM @tblSMCompanyLocation

		WHILE @intLocationId IS NOT NULL
		BEGIN
			BEGIN
				SELECT @dblEndInventory = 0
					,@dblWeeksOfSsupply = 0
					,@dblSupplyTarget = NULL
					,@dblDecimalPart = NULL
					,@intIntegerPart = NULL
					,@dblTotalConsumptionQty = NULL

				SELECT @dblSupplyTarget = MAX(dblQty)
				FROM @tblCTInvPlngReportAttributeValue
				WHERE intReportAttributeID = 11 --Weeks of Supply Target
					AND intMonthId = @intMonthId
					AND intLocationId = @intLocationId

				if @dblSupplyTarget is null
				Begin
					Select @dblSupplyTarget=0
				End

				SELECT @dblDecimalPart = @dblSupplyTarget % 1

				SELECT @intIntegerPart = @dblSupplyTarget - @dblDecimalPart

				IF @intIntegerPart = 0
				BEGIN
					IF @dblDecimalPart > 0
					BEGIN
						SELECT @dblTotalConsumptionQty = ABS(SUM(dblQty)) * @dblDecimalPart
						FROM @tblCTInvPlngReportAttributeValue
						WHERE intMonthId = @intMonthId + 1
							AND intReportAttributeID IN (
								8
								,15
								)
							AND intLocationId = @intLocationId
					END
				END
				ELSE
				BEGIN
					SELECT @dblTotalConsumptionQty = ABS(SUM(CASE 
									WHEN intReportAttributeID = 16
										AND dblQty > 0
										THEN 0
									ELSE dblQty
									END))
					FROM @tblCTInvPlngReportAttributeValue
					WHERE intMonthId BETWEEN @intMonthId + 1
							AND @intMonthId + @intIntegerPart
						AND intReportAttributeID IN (
							8
							,15
							,16
							)
						AND intLocationId = @intLocationId

					IF @dblDecimalPart > 0
					BEGIN
						SELECT @dblTotalConsumptionQty = isNULL(@dblTotalConsumptionQty, 0) + (
								ABS(SUM(CASE 
											WHEN intReportAttributeID = 16
												AND dblQty > 0
												THEN 0
											ELSE dblQty
											END)) * @dblDecimalPart
								)
						FROM @tblCTInvPlngReportAttributeValue
						WHERE intMonthId = @intMonthId + @intIntegerPart + 1
							AND intReportAttributeID IN (
								8
								,15
								,16
								)
							AND intLocationId = @intLocationId
					END
				END

				SELECT @dblEndInventory = dblQty
				FROM @tblCTInvPlngReportAttributeValue D
				WHERE intReportAttributeID = 9 --Ending Inventory
					AND intMonthId = @intMonthId
					AND intLocationId = @intLocationId

				IF @dblEndInventory IS NULL
					SELECT @dblEndInventory = 0

				SELECT @intConsumptionMonth = @intMonthId + 1

				INSERT INTO @tblCTInvPlngReportAttributeValue (
					intInvPlngReportMasterID
					,intReportAttributeID
					,strFieldName
					,strValue
					,intLocationId
					)
				SELECT @intInvPlngReportMasterID
					,12 --Short/Excess Inventory
					,'strMonth' + ltrim(@intMonthId)
					,@dblEndInventory - IsNULL(@dblTotalConsumptionQty, 0)
					,@intLocationId

				SELECT @intConsumptionAvlMonth = 0

				SELECT @intConsumptionAvlMonth = Count(*)
				FROM @tblCTInvPlngReportAttributeValue
				WHERE (
						intReportAttributeID IN (
							8
							,15
							)
						OR (
							intReportAttributeID = 16
							AND dblQty < 0
							)
						)
					AND intLocationId = @intLocationId

				IF @intConsumptionAvlMonth IS NULL
					SELECT @intConsumptionAvlMonth = @intMonthsToView

				WHILE @intConsumptionMonth <= 12
					--AND @dblEndInventory > 0
				BEGIN
					SELECT @dblRemainingConsumptionQty = NULL

					SELECT @dblRemainingConsumptionQty = ABS(SUM(CASE 
									WHEN intReportAttributeID = 16
										AND dblQty > 0
										THEN 0
									ELSE dblQty
									END))
					FROM @tblCTInvPlngReportAttributeValue
					WHERE intMonthId >= @intConsumptionMonth
						AND intReportAttributeID IN (
							8
							,15
							,16
							)
						AND intLocationId = @intLocationId

					IF @dblRemainingConsumptionQty IS NULL
						SELECT @dblRemainingConsumptionQty = 0

					IF (@dblRemainingConsumptionQty = 0)
						AND @intConsumptionMonth = @intMonthId + 1
					BEGIN
						IF NOT EXISTS (
								SELECT *
								FROM @tblCTInvPlngReportAttributeValue
								WHERE intReportAttributeID = 10
									AND dblQty = 999
									AND intLocationId = @intLocationId
								)
						BEGIN
							INSERT INTO @tblCTInvPlngReportAttributeValue (
								intInvPlngReportMasterID
								,intReportAttributeID
								,strFieldName
								,strValue
								,intLocationId
								)
							SELECT @intInvPlngReportMasterID
								,10 --Weeks of Supply
								,'strMonth' + ltrim(@intMonthId)
								,999
								,@intLocationId
						END
						ELSE
						BEGIN
							INSERT INTO @tblCTInvPlngReportAttributeValue (
								intInvPlngReportMasterID
								,intReportAttributeID
								,strFieldName
								,strValue
								,intLocationId
								)
							SELECT @intInvPlngReportMasterID
								,10 --Weeks of Supply
								,'strMonth' + ltrim(@intMonthId)
								,0
								,@intLocationId
						END

						GOTO NextMonth
					END

					SELECT @dblConsumptionQty = 0

					SELECT @dblConsumptionQty = ABS(SUM(CASE 
									WHEN intReportAttributeID = 16
										AND dblQty > 0
										THEN 0
									ELSE dblQty
									END))
					FROM @tblCTInvPlngReportAttributeValue
					WHERE intMonthId = @intConsumptionMonth
						AND intReportAttributeID IN (
							8
							,15
							,16
							)
						AND intLocationId = @intLocationId

					IF @dblConsumptionQty IS NULL
						SELECT @dblConsumptionQty = 0

					IF @dblEndInventory > @dblConsumptionQty
					BEGIN
						SELECT @dblEndInventory = @dblEndInventory - @dblConsumptionQty

						SELECT @dblWeeksOfSsupply = @dblWeeksOfSsupply + 1

						IF NOT EXISTS (
								SELECT 1
								FROM @tblCTInvPlngReportAttributeValue
								WHERE intMonthId > @intConsumptionMonth
									AND intReportAttributeID IN (
										8
										,15
										,16
										)
									AND intLocationId = @intLocationId
								HAVING ABS(SUM(CASE 
												WHEN intReportAttributeID = 16
													AND dblQty > 0
													THEN 0
												ELSE dblQty
												END)) > 0
								)
						BEGIN
							INSERT INTO @tblCTInvPlngReportAttributeValue (
								intInvPlngReportMasterID
								,intReportAttributeID
								,strFieldName
								,strValue
								,intLocationId
								)
							SELECT @intInvPlngReportMasterID
								,10 --Weeks of Supply
								,'strMonth' + ltrim(@intMonthId)
								,@dblWeeksOfSsupply
								,@intLocationId

							SELECT @dblEndInventory = 0
						END
					END
					ELSE
					BEGIN
						if @dblConsumptionQty>0
						SELECT @dblWeeksOfSsupply = @dblWeeksOfSsupply + (@dblEndInventory / @dblConsumptionQty)

						SELECT @dblEndInventory = 0

						INSERT INTO @tblCTInvPlngReportAttributeValue (
							intInvPlngReportMasterID
							,intReportAttributeID
							,strFieldName
							,strValue
							,intLocationId
							)
						SELECT @intInvPlngReportMasterID
							,10 --Weeks of Supply
							,'strMonth' + ltrim(@intMonthId)
							,@dblWeeksOfSsupply
							,@intLocationId
					END

					SELECT @intConsumptionMonth = @intConsumptionMonth + 1
				END

				NextMonth:
			END

			SELECT @intLocationId = Min(intLocationId)
			FROM @tblSMCompanyLocation
			WHERE intLocationId > @intLocationId
		END

		SELECT @intMonthId = @intMonthId + 1
	END

	SELECT Ext.intReportAttributeID [AttributeId]
		,CASE 
			WHEN RA.intReportAttributeID = 10
				AND 'Monthly' = 'Monthly'
				THEN 'Months of Supply'
			WHEN RA.intReportAttributeID = 11
				AND 'Monthly' = 'Monthly'
				THEN 'Months of Supply Target'
			WHEN RA.intReportAttributeID IN (
					5
					,6
					)
				AND '20 FT' <> ''
				THEN RA.strAttributeName + ' [20 FT]'
			ELSE RA.strAttributeName
			END AS strAttributeName
		,Ext.OpeningInv
		,Ext.PastDue
		,' [ ' + IsNULL(L.strLocationName, 'All') + ' ]' AS strGroupByColumn
		,IsNULL(L.intCompanyLocationId, 999) intLocationId
		,IsNULL(L.strLocationName, 'All') AS strLocationName
		,Ext.strMonth1
		,Ext.strMonth2
		,Ext.strMonth3
		,Ext.strMonth4
		,Ext.strMonth5
		,Ext.strMonth6
		,Ext.strMonth7
		,Ext.strMonth8
		,Ext.strMonth9
		,Ext.strMonth10
		,Ext.strMonth11
		,Ext.strMonth12
		,RA.ysnEditable 
	FROM (
		SELECT *
		FROM (
			SELECT intInvPlngReportMasterID
				,intReportAttributeID
				,strFieldName
				,strValue
				,intLocationId
			FROM @tblCTInvPlngReportAttributeValue
			) AS st
		pivot(MAX(strValue) FOR strFieldName IN (
					OpeningInv
					,PastDue
					,strMonth1
					,strMonth2
					,strMonth3
					,strMonth4
					,strMonth5
					,strMonth6
					,strMonth7
					,strMonth8
					,strMonth9
					,strMonth10
					,strMonth11
					,strMonth12
					)) p
		) Ext
	JOIN tblCTInvPlngReportMaster RM ON RM.intInvPlngReportMasterID = Ext.intInvPlngReportMasterID
		AND Ext.intInvPlngReportMasterID = @intInvPlngReportMasterID
	JOIN dbo.tblCTReportAttribute RA ON RA.intReportAttributeID = Ext.intReportAttributeID
		AND RA.ysnVisible = 1
	LEFT JOIN dbo.tblSMCompanyLocation L ON L.intCompanyLocationId = Ext.intLocationId
	ORDER BY intLocationId, strGroupByColumn
		,RA.intDisplayOrder
END
