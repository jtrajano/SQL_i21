CREATE PROCEDURE [dbo].[uspCTInventoryPlan_LoadPlan] @intInvPlngReportMasterID INT
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
		,@ysnDisplayDemandWithItemNoAndDescription BIT
		,@strSupplyTarget NVARCHAR(50)
		,@strContainerType NVARCHAR(50)
		,@intContainerTypeId INT

	SELECT @ysnDisplayDemandWithItemNoAndDescription = ysnDisplayDemandWithItemNoAndDescription
		,@strSupplyTarget = strSupplyTarget
		,@intContainerTypeId = intContainerTypeId
	FROM tblMFCompanyPreference

	IF @ysnDisplayDemandWithItemNoAndDescription IS NULL
		SELECT @ysnDisplayDemandWithItemNoAndDescription = 0

	IF @intContainerTypeId IS NULL
		SELECT @intContainerTypeId = 0

	IF @strSupplyTarget IS NULL
		SELECT @strSupplyTarget = ''

	SELECT @strContainerType = strContainerType
	FROM tblLGContainerType
	WHERE intContainerTypeId = @intContainerTypeId

	IF @strContainerType IS NULL
		SELECT @strContainerType = ''

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
	LEFT JOIN tblCTBook B ON B.intBookId = DH.intBookId
	LEFT JOIN tblCTSubBook SB ON SB.intSubBookId = DH.intSubBookId
	WHERE RM.intInvPlngReportMasterID = @intInvPlngReportMasterID

	DECLARE @intReportMasterID INT

	SELECT @intReportMasterID = intReportMasterID
	FROM tblCTInvPlngReportMaster
	WHERE intInvPlngReportMasterID = @intInvPlngReportMasterID

	DECLARE @MinAttr INT
		,@MaxAttr INT
		,@MinAttrLoopValue INT

	SELECT @MinAttr = MIN(intReportAttributeID)
		,@MaxAttr = MAX(intReportAttributeID)
	FROM dbo.tblCTReportAttribute
	WHERE intReportMasterID = @intReportMasterID

	SET @MinAttrLoopValue = @MinAttr

	DECLARE @SQL VARCHAR(max)
		,@intNoOfMonths INT
		,@Cnt INT

	SET @Cnt = 1

	SELECT @intNoOfMonths = intNoOfMonths
	FROM dbo.tblCTInvPlngReportMaster
	WHERE intInvPlngReportMasterID = @intInvPlngReportMasterID

	SET @SQL = ''
	SET @SQL = @SQL + 'DECLARE @Table table(intItemId Int, strItemNo nvarchar(200), AttributeId int, strAttributeName nvarchar(50), OpeningInv nvarchar(35), PastDue nvarchar(35),intMainItemId Int'

	WHILE @Cnt <= @intNoOfMonths
	BEGIN
		SET @SQL = @SQL + ', strMonth' + CAST(@Cnt AS CHAR(2)) + ' varchar(150)'
		SET @Cnt = @Cnt + 1
	END

	SET @SQL = @SQL + ' ) '
	SET @SQL = @SQL + ' INSERT INTO @Table 
						SELECT Ext.intItemId
						,CASE 
						WHEN ' + Ltrim(@ysnDisplayDemandWithItemNoAndDescription) + ' = 1
							THEN (
									CASE 
										WHEN M.intItemId = IsNULL(MI.intItemId,M.intItemId)
											THEN M.strItemNo + '' - '' + M.strDescription
										ELSE M.strItemNo + '' - '' + M.strDescription + '' [ '' + MI.strItemNo + '' - '' + MI.strDescription + '' ]''
										END
									)
						ELSE (
								CASE 
									WHEN M.intItemId = IsNULL(MI.intItemId,M.intItemId)
										THEN M.strItemNo
									ELSE M.strItemNo + '' [ '' + MI.strItemNo + '' ]''
									END
								)
						END AS strItemNo
						, Ext.intReportAttributeID [AttributeId]
						, CASE 
				WHEN RA.intReportAttributeID = 10
					AND ''' + @strSupplyTarget + ''' = ''Monthly''
					THEN ''Months of Supply''
				WHEN RA.intReportAttributeID = 11
					AND ''' + @strSupplyTarget + 
		''' = ''Monthly''
					THEN ''Months of Supply Target''
				WHEN RA.intReportAttributeID IN (
						5
						,6
						) AND ''' + @strContainerType + ''' <>''''
					THEN RA.strAttributeName + '' [' + @strContainerType + ']''
				ELSE RA.strAttributeName
				END AS strAttributeName
						, Ext.OpeningInv
						, Ext.PastDue
						, Ext.intMainItemId'
	SET @Cnt = 1

	WHILE @Cnt <= @intNoOfMonths
	BEGIN
		SET @SQL = @SQL + ' ,Ext.strMonth' + RTRIM(CAST(@Cnt AS CHAR(2))) + ' '
		SET @Cnt = @Cnt + 1
	END

	SET @SQL = @SQL + ' FROM (
					Select * from (
					select	intInvPlngReportMasterID,intReportAttributeID,intItemId,strFieldName,strValue,intMainItemId
					from	tblCTInvPlngReportAttributeValue s
					 ) as st
						pivot
						(
							max(strValue)
							for strFieldName in (OpeningInv,PastDue'
	SET @Cnt = 1

	WHILE @Cnt <= @intNoOfMonths
	BEGIN
		SET @SQL = @SQL + ' ,strMonth' + RTRIM(CAST(@Cnt AS CHAR(2))) + ' '
		SET @Cnt = @Cnt + 1
	END

	SET @SQL = @SQL + ')
						) p
					) Ext
					JOIN tblCTInvPlngReportMaster RM ON RM.intInvPlngReportMasterID = Ext.intInvPlngReportMasterID
						AND Ext.intInvPlngReportMasterID = ' + CAST(@intInvPlngReportMasterID AS NVARCHAR(20)) + '
					JOIN tblICItem M ON M.intItemId = Ext.intItemId
					JOIN dbo.tblCTReportAttribute RA ON RA.intReportAttributeID = Ext.intReportAttributeID
					LEFT JOIN tblICItem MI ON MI.intItemId = Ext.intMainItemId
					order by Ext.intInvPlngReportMasterID,Ext.intItemId, Ext.intReportAttributeID '
	SET @SQL = CHAR(13) + @SQL + ' SELECT T.* FROM @Table T JOIN tblCTReportAttribute RA ON RA.intReportAttributeID = T.AttributeId ORDER By T.intItemId, RA.intDisplayOrder '

	--SELECT @SQL		
	EXEC (@SQL)
END
