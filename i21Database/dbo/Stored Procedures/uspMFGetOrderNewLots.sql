CREATE PROCEDURE uspMFGetOrderNewLots @intOrderHeaderId INT
	,@strStart NVARCHAR(10) = '0'
	,@strLimit NVARCHAR(10) = '100'
	,@strFilterCriteria NVARCHAR(MAX) = ''
	,@strSortField NVARCHAR(MAX) = 'intLotId'
	,@strSortDirection NVARCHAR(5) = 'DESC'
AS
SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

BEGIN TRY
	DECLARE @strItemId NVARCHAR(MAX)
		,@intStagingLocationId INT
		,@strLotId NVARCHAR(MAX)
		,@SQL NVARCHAR(MAX)
		,@ErrMsg NVARCHAR(MAX)

	SELECT @strItemId = COALESCE(@strItemId + ',', '') + CONVERT(NVARCHAR, OD.intItemId)
		,@intStagingLocationId = ISNULL(OH.intStagingLocationId, 0)
	FROM tblMFOrderDetail OD
	JOIN tblMFOrderHeader OH ON OH.intOrderHeaderId = OD.intOrderHeaderId
	WHERE OD.intOrderHeaderId = @intOrderHeaderId

	SELECT @strLotId = COALESCE(@strLotId + ',', '') + CONVERT(NVARCHAR, OM.intLotId)
	FROM tblMFOrderManifest OM
	WHERE OM.intOrderHeaderId = @intOrderHeaderId

	If @strLotId is null
	Select @strLotId=''

	SET @SQL = 'SELECT * FROM (
	SELECT DENSE_RANK() OVER (
	ORDER BY L.intLotId DESC
	) intRankNo
	,L.intLotId
	,L.strLotNumber
	,PL.strParentLotNumber
	,L.strLotAlias
	,LS.strSecondaryStatus AS strLotStatus
	,I.strItemNo
	,I.strDescription
	,L.dblQty AS dblLotQty
	,UM.strUnitMeasure AS strLotQtyUOM
	,' + LTRIM(@intOrderHeaderId) + ' AS intOrderHeaderId
	,COUNT(*) OVER () AS intTotalCount
FROM tblICLot L
JOIN tblICLotStatus LS ON LS.intLotStatusId = L.intLotStatusId
JOIN tblICItem I ON I.intItemId = L.intItemId
JOIN tblICItemUOM IU ON IU.intItemUOMId = L.intItemUOMId
JOIN tblICUnitMeasure UM ON UM.intUnitMeasureId = IU.intUnitMeasureId
JOIN tblICParentLot PL ON PL.intParentLotId = L.intParentLotId
WHERE L.dblQty > 0
	AND L.intStorageLocationId = ' + LTRIM(@intStagingLocationId) + ' 
	AND L.intItemId IN (
		SELECT *
		FROM dbo.fnSplitString(''' + @strItemId + ''', '','')
		)
	AND L.intLotId NOT IN (
		SELECT *
		FROM dbo.fnSplitString(''' + @strLotId + ''', '','')
		)'

	IF (LEN(@strFilterCriteria) > 0)
	BEGIN
		SET @strFilterCriteria = REPLACE(@strFilterCriteria, '[strLotStatus]', 'LS.strSecondaryStatus')
		SET @strFilterCriteria = REPLACE(@strFilterCriteria, '[dblLotQty]', 'L.dblQty')
		SET @strFilterCriteria = REPLACE(@strFilterCriteria, '[strLotQtyUOM]', 'UM.strUnitMeasure')
		SET @strFilterCriteria = REPLACE(@strFilterCriteria, '[strDescription]', 'I.strDescription')
		SET @SQL = @SQL + ' AND ' + @strFilterCriteria
	END

	SET @SQL = @SQL + ') t '
	SET @SQL = @SQL + '	WHERE intRankNo > ' + @strStart + '
			AND intRankNo <= ' + @strStart + '+' + @strLimit
	SET @SQL = @SQL + ' ORDER BY [' + @strSortField + '] ' + @strSortDirection

	--SELECT @SQL
	EXEC sp_executesql @SQL
END TRY

BEGIN CATCH
	SET @ErrMsg = ERROR_MESSAGE()

	IF @ErrMsg != ''
	BEGIN
		RAISERROR (
				@ErrMsg
				,16
				,1
				,'WITH NOWAIT'
				)
	END
END CATCH
