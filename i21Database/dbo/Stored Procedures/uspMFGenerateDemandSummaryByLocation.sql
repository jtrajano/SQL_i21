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
	JOIN tblICCategory C ON C.intCategoryId = RM.intCategoryId
	LEFT JOIN tblMFDemandHeader DH ON DH.intDemandHeaderId = RM.intDemandHeaderId
	LEFT JOIN tblICUnitMeasure AS UOM ON UOM.intUnitMeasureId = RM.intUnitMeasureId
	LEFT JOIN tblSMCompanyLocation CL ON CL.intCompanyLocationId = RM.intCompanyLocationId
	LEFT JOIN tblCTBook B ON B.intBookId = RM.intBookId
	LEFT JOIN tblCTSubBook SB ON SB.intSubBookId = RM.intSubBookId
	WHERE RM.intInvPlngReportMasterID = @intInvPlngReportMasterID

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
	FROM (
		SELECT *
		FROM (
			SELECT intInvPlngReportMasterID
				,intReportAttributeID
				,strFieldName
				,strValue
				,intLocationId
			FROM tblCTInvPlngReportAttributeValue s
			WHERE s.intInvPlngReportMasterID = @intInvPlngReportMasterID
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
	ORDER BY strGroupByColumn
		,RA.intDisplayOrder
END
