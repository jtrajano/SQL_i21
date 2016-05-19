CREATE PROCEDURE uspQMReportLotQualityDetail
     @intWorkOrderId INT
	,@strLotType NVARCHAR(10)
AS
SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

BEGIN TRY
	DECLARE @ErrMsg NVARCHAR(MAX)
		,@SQL NVARCHAR(MAX)
		,@strColumnName NVARCHAR(MAX)
		,@strProperties NVARCHAR(MAX)
		,@dblTotalQuantity FLOAT

	--SELECT NULL strLotNumber,NULL strItemNo,NULL strDescription,0.0 dblQuantity,NULL strUnitMeasure,0 intProductValueId,0 intSampleId,0.0 strValue,NULL strProperty
	--FROM tblQMSample WHERE 1 = 2
	--RETURN

	IF OBJECT_ID('tempdb..##Quality') IS NOT NULL
		DROP TABLE ##Quality

	IF OBJECT_ID('tempdb..##WeightedAVG') IS NOT NULL
		DROP TABLE ##WeightedAVG

	IF @strLotType = 'INPUT'
	BEGIN
		SET @SQL = '
  SELECT L.strLotNumber,
    M.strItemNo,
    M.strDescription,
    I.dblQuantity,
    U.strUnitMeasure,
    V.*
  INTO ##Quality
  FROM tblMFWorkOrderInputLot I
  JOIN tblICItem M ON M.intItemId = I.intItemId
  JOIN tblICLot L ON L.intLotId = I.intLotId
  JOIN tblICItemUOM IU ON IU.intItemUOMId = I.intItemUOMId
  JOIN tblICUnitMeasure U ON U.intUnitMeasureId = IU.intUnitMeasureId
  JOIN vyuQMLotQuality V ON V.intProductValueId = L.intLotId
  WHERE I.intWorkOrderId = ' + LTRIM(@intWorkOrderId) + '
  ORDER BY I.intWorkOrderInputLotId
  '
	END
	ELSE
	BEGIN
		SET @SQL = '
  SELECT L.strLotNumber,
    M.strItemNo,
    M.strDescription,
    O.dblQuantity,
    U.strUnitMeasure,
    V.*
  INTO ##Quality
  FROM tblMFWorkOrderProducedLot O
  JOIN tblICItem M ON M.intItemId = O.intItemId
  JOIN tblICLot L ON L.intLotId = O.intLotId
  JOIN tblICItemUOM IU ON IU.intItemUOMId = O.intItemUOMId
  JOIN tblICUnitMeasure U ON U.intUnitMeasureId = IU.intUnitMeasureId
  JOIN vyuQMLotQuality V ON V.intProductValueId = L.intLotId
  WHERE O.intWorkOrderId = ' + LTRIM(@intWorkOrderId) + '
  ORDER BY O.intWorkOrderProducedLotId
  '
	END

	EXEC sp_executesql @SQL

	SELECT @strColumnName = STUFF((
				SELECT ', SUM(Q.dblQuantity*CONVERT(FLOAT,V.' + IB.COLUMN_NAME + '))/SUM(Q.dblQuantity) AS [' + IB.COLUMN_NAME + ']'
				FROM INFORMATION_SCHEMA.COLUMNS IB
				WHERE IB.TABLE_NAME = OB.TABLE_NAME
					AND IB.COLUMN_NAME NOT IN (
						'intProductValueId'
						,'intSampleId'
						)
				FOR XML PATH('')
				), 1, 2, '')
		,@strProperties = STUFF((
				SELECT ', ' + IB.COLUMN_NAME
				FROM INFORMATION_SCHEMA.COLUMNS IB
				WHERE IB.TABLE_NAME = OB.TABLE_NAME
					AND IB.COLUMN_NAME NOT IN (
						'intProductValueId'
						,'intSampleId'
						)
				FOR XML PATH('')
				), 1, 2, '')
	FROM INFORMATION_SCHEMA.COLUMNS OB
	WHERE OB.TABLE_NAME = 'vyuQMLotQuality'
		AND OB.COLUMN_NAME NOT IN (
			'intProductValueId'
			,'intSampleId'
			)

	SET @SQL = '
 SELECT ' + @strColumnName + '
 INTO ##WeightedAVG
 FROM ##Quality Q
 LEFT JOIN vyuQMLotQuality V ON V.intProductValueId = Q.intProductValueId
 '

	EXEC sp_executesql @SQL

	SELECT @dblTotalQuantity = ISNULL(SUM(dblQuantity), 0)
	FROM ##Quality

	SET @SQL = '
  SELECT * FROM
  (
   SELECT * FROM ##Quality
   UNION ALL
   SELECT ''Total'','''','''',' + LTRIM(@dblTotalQuantity) + ','''',0,0,* FROM ##WeightedAVG
  )A
  UNPIVOT
  (
   strValue FOR strProperty IN (' + @strProperties + ')
  )UNPVT
    '

	IF NOT EXISTS (
			SELECT *
			FROM ##Quality
			WHERE intProductValueId > 0
			)
	BEGIN
		SET @SQL = @SQL + 'UNION ALL SELECT NULL,NULL,NULL,NULL,NULL,NULL,NULL,0, Item FROM dbo.fnSplitStringWithTrim(''' + @strProperties + ''','','')'
	END

	EXEC sp_executesql @SQL
END TRY

BEGIN CATCH
	SET @ErrMsg = 'uspQMReportLotQualityDetail - ' + ERROR_MESSAGE()

	RAISERROR (
			@ErrMsg
			,16
			,1
			,'WITH NOWAIT'
			)
END CATCH
