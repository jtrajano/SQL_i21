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
		,@intContainerTypeId INT,@ysnDisplayRestrictedBookInDemandView bit

	SELECT @ysnDisplayDemandWithItemNoAndDescription = ysnDisplayDemandWithItemNoAndDescription
		,@strSupplyTarget = strSupplyTarget
		,@intContainerTypeId = intContainerTypeId
		,@ysnDisplayRestrictedBookInDemandView=IsNULL(ysnDisplayRestrictedBookInDemandView,0)
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

	IF OBJECT_ID('tempdb..#tblMFItemBook') IS NOT NULL
		DROP TABLE #tblMFItemBook

	CREATE TABLE #tblMFItemBook (
		intId INT identity(1, 1)
		,intItemId INT
		,strBook NVARCHAR(MAX)
		)

		if @ysnDisplayRestrictedBookInDemandView=1
	Begin

	DECLARE @intItemId INT
		,@intItemBookId INT
		,@intId int
		,@strBook nvarchar(MAX)

	INSERT INTO #tblMFItemBook (intItemId)
	SELECT distinct intItemId
	FROM tblCTInvPlngReportAttributeValue
	WHERE intItemId <> IsNULL(intMainItemId, intItemId)
	and intInvPlngReportMasterID=@intInvPlngReportMasterID

	SELECT @intId = MIN(intId)
	FROM #tblMFItemBook

	WHILE @intId IS NOT NULL
	BEGIN
		SELECT @intItemBookId = NULL
			,@strBook = ''

		SELECT @intItemBookId = intItemId
		FROM #tblMFItemBook
		WHERE intId = @intId

		SELECT @strBook = @strBook + strBook + ','
		FROM tblCTBook B
		WHERE NOT EXISTS (
				SELECT intBookId
				FROM tblICItemBook IB
				WHERE IB.intItemId = @intItemBookId
					AND IB.intBookId = B.intBookId
				)

		IF @strBook IS NULL
			SELECT @strBook = ''

		IF len(@strBook) > 0
		BEGIN
			SELECT @strBook = left(@strBook, Len(@strBook) - 1)

			UPDATE #tblMFItemBook
			SET strBook = @strBook
			WHERE intId = @intId
		END

		SELECT @intId = MIN(intId)
		FROM #tblMFItemBook
		WHERE intId > @intId
	END

	End

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

	SELECT @intNoOfMonths = 12

	SET @SQL = ''
	SET @SQL = @SQL + 'DECLARE @Table table(intItemId Int, strItemNo nvarchar(200), AttributeId int, strAttributeName nvarchar(50), OpeningInv nvarchar(35), PastDue nvarchar(35),intMainItemId Int, strMainItemNo nvarchar(50), strGroupByColumn nvarchar(50)'

	WHILE @Cnt <= @intNoOfMonths
	BEGIN
		SET @SQL = @SQL + ', strMonth' + CAST(@Cnt AS CHAR(2)) + ' varchar(150)'
		SET @Cnt = @Cnt + 1
	END

	SET @SQL = @SQL + ' ) '
	SET @SQL = @SQL + ' INSERT INTO @Table 
						SELECT Ext.intItemId
						,CASE 
				WHEN '+Ltrim(@ysnDisplayRestrictedBookInDemandView) +'= 0 and IsNULL(strBook,'''')=''''
					THEN (CASE 
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
						END )
				ELSE (
						CASE 
							WHEN '+Ltrim(@ysnDisplayDemandWithItemNoAndDescription)+' = 1
								THEN (
										CASE 
											WHEN M.intItemId = IsNULL(MI.intItemId,M.intItemId)
												THEN M.strItemNo + '' - '' + M.strDescription
											WHEN M.intItemId <> IsNULL(MI.intItemId,M.intItemId) and strBook IS NULL
												Then M.strItemNo + '' - '' + M.strDescription + '' [ '' + MI.strItemNo + '' - '' + MI.strDescription + '' ]''
											ELSE M.strItemNo + '' - '' + M.strDescription + '' [ '' + MI.strItemNo + '' - '' + MI.strDescription + '' ] Restricted [''+strBook+'']''
											END
										)
							ELSE (
									CASE 
										WHEN M.intItemId = IsNULL(MI.intItemId,M.intItemId)
											THEN M.strItemNo
										WHEN M.intItemId <> IsNULL(MI.intItemId,M.intItemId) and strBook IS NULL
											Then M.strItemNo + '' [ '' + MI.strItemNo + '' ]'' 
										ELSE M.strItemNo + '' [ '' + MI.strItemNo + '' ] Restricted [''+strBook+'']''
										END
									)
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
						, Ext.intMainItemId
						, MI.strItemNo
						, CASE 
										WHEN M.intItemId = IsNULL(MI.intItemId,M.intItemId)
											THEN M.strItemNo
										Else MI.strItemNo + '' [ '' + M.strItemNo + '' ]'' 
										END	AS strGroupByColumn '
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
					Left JOIN #tblMFItemBook IB on IB.intItemId=Ext.intItemId
					order by Ext.intInvPlngReportMasterID,Ext.intItemId, Ext.intReportAttributeID '
	SET @SQL = CHAR(13) + @SQL + ' SELECT T.* FROM @Table T JOIN tblCTReportAttribute RA ON RA.intReportAttributeID = T.AttributeId ORDER By IsNULL(T.strMainItemNo,T.strItemNo), T.strItemNo, RA.intDisplayOrder '

	--SELECT @SQL		
	EXEC (@SQL)
END
