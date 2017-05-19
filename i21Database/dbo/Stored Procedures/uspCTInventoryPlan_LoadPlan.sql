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

	IF ISNULL((
				SELECT TOP 1 intItemId
				FROM dbo.tblCTInvPlngReportMaterial
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

	SELECT RM.*
		,C.strCategoryCode
		,@intItemIdList AS 'intItemIdList'
		,@strItemNoList AS 'strItemNoList'
	FROM dbo.tblCTInvPlngReportMaster RM
	JOIN tblICCategory C ON C.intCategoryId = RM.intCategoryId
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
	SET @SQL = @SQL + 'DECLARE @Table table(intItemId Int, strItemNo nvarchar(200), StdUOM varchar(20), BaseUOM varchar(20), AttributeId int, strAttributeName nvarchar(50), OpeningInv nvarchar(35), PastDue nvarchar(35)'

	WHILE @Cnt <= @intNoOfMonths
	BEGIN
		SET @SQL = @SQL + ', strMonth' + CAST(@Cnt AS CHAR(2)) + ' varchar(150)'
		SET @Cnt = @Cnt + 1
	END

	SET @SQL = @SQL + ' ) '
	SET @SQL = @SQL + ' INSERT INTO @Table 
						SELECT Ext.intItemId
						, M.strItemNo + '' ('' + UOM1.strUnitMeasure + '' per '' + UOM.strUnitMeasure + '' --> '' + CAST(CONVERT(DECIMAL(24,6),ISNULL(MUOM1.dblUnitQty,UOMCON.dblConversionToStock)) as nvarchar(30)) + '')'' [strItemNo]
						, UOM.strUnitMeasure [StdUOM]
						, UOM1.strUnitMeasure [BaseUOM]
						, Ext.intReportAttributeID [AttributeId]
						, RA.strAttributeName 
						, Ext.OpeningInv
						, Ext.PastDue'
	SET @Cnt = 1

	WHILE @Cnt <= @intNoOfMonths
	BEGIN
		SET @SQL = @SQL + ' ,Ext.strMonth' + RTRIM(CAST(@Cnt AS CHAR(2))) + ' '
		SET @Cnt = @Cnt + 1
	END

	SET @SQL = @SQL + ' FROM (
					Select * from (
					select	intInvPlngReportMasterID,intReportAttributeID,intItemId,strFieldName,strValue
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
					JOIN tblICItem M ON M.intItemId = Ext.intItemId
					JOIN tblICItemUOM MUOM ON MUOM.intItemId = M.intItemId
						  AND MUOM.ysnStockUnit = 1
					JOIN tblICUnitMeasure UOM ON UOM.intUnitMeasureId = MUOM.intUnitMeasureId
					JOIN tblCTItemDefaultUOM IUOM ON IUOM.intItemId = M.intItemId
					JOIN tblICUnitMeasure UOM1 ON UOM1.intUnitMeasureId = IUOM.intPurchaseUOMId
					JOIN dbo.tblCTReportAttribute RA ON RA.intReportAttributeID = Ext.intReportAttributeID

					LEFT JOIN tblICItemUOM MUOM1 ON MUOM1.intItemId = M.intItemId
						  AND MUOM1.intUnitMeasureId = UOM1.intUnitMeasureId
				     LEFT JOIN tblICUnitMeasureConversion UOMCON ON UOMCON.intUnitMeasureId = UOM1.intUnitMeasureId
						  AND UOMCON.intStockUnitMeasureId = MUOM.intUnitMeasureId
					WHERE Ext.intInvPlngReportMasterID = ' + CAST(@intInvPlngReportMasterID AS NVARCHAR(20)) + ' order by intInvPlngReportMasterID,Ext.intItemId, Ext.intReportAttributeID '
	--SET @SQL = CHAR(13) + @SQL + '	SELECT * FROM @Table'
	SET @SQL = CHAR(13) + @SQL + ' SELECT T.* FROM @Table T JOIN tblCTReportAttribute RA ON RA.intReportAttributeID = T.AttributeId ORDER By T.intItemId, RA.intDisplayOrder '

	SET @SQL = @SQL + ' SELECT AttributeId, strAttributeName
	,SUM( CASE WHEN ISNUMERIC(OpeningInv)=1 THEN CAST(OpeningInv AS float)  
                     ELSE 0 END ) [OpeningInv]
	,SUM( CASE WHEN ISNUMERIC(PastDue)=1 THEN CAST(PastDue AS float)  
                     ELSE 0 END ) [PastDue]'
	SET @Cnt = 1

	WHILE @Cnt <= @intNoOfMonths
	BEGIN
		SET @SQL = @SQL + ' ,SUM(CASE WHEN ISNUMERIC(strMonth' + RTRIM(CAST(@Cnt AS CHAR(2))) + ')=1 THEN CAST(strMonth' + RTRIM(CAST(@Cnt AS CHAR(2))) + ' AS float)  
                     ELSE 0 END ) [' + (left(convert(CHAR(12), DATEADD(m, @Cnt - 1, GETDATE()), 107), 3) + ' ' + right(convert(CHAR(12), DATEADD(m, @Cnt - 1, GETDATE()), 107), 2)) + '] '
		SET @Cnt = @Cnt + 1
	END

	SET @SQL = @SQL + ' FROM @Table WHERE AttributeId <> 1 
						Group By AttributeId, strAttributeName 
						Order By AttributeId'

	--SELECT @SQL		
	EXEC (@SQL)
END
