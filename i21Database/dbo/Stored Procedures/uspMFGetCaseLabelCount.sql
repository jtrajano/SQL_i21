CREATE PROCEDURE uspMFGetCaseLabelCount (@strOrderManifestId NVARCHAR(50))
AS
BEGIN TRY
	DECLARE @intOrderDetailId INT
		,@intQty INT
		,@intCaseLabelCount INT
		,@ErrMsg NVARCHAR(MAX)

	SELECT @intOrderDetailId = intOrderDetailId
	FROM dbo.tblMFOrderManifest
	WHERE intOrderManifestId IN (
			SELECT *
			FROM dbo.fnSplitString(@strOrderManifestId, '^')
			)

	SELECT @intQty = dblQty
	FROM tblMFOrderDetail
	WHERE intOrderDetailId = @intOrderDetailId

	SELECT @intCaseLabelCount = Count(*)
	FROM dbo.tblMFOrderManifestLabel L
	JOIN dbo.tblMFOrderManifest M ON M.intOrderManifestId = L.intOrderManifestId
		AND L.ysnDeleted = 0
		AND intCustomerLabelTypeId = 2
	WHERE M.intOrderDetailId IN (
			SELECT OM1.intOrderDetailId
			FROM dbo.fnSplitString(@strOrderManifestId, '^') OM
			JOIN dbo.tblMFOrderManifest OM1 ON OM1.intOrderManifestId = OM.Item
			)

	SELECT IsNULL(@intQty, 0) AS intRequiredQty
		,IsNULL(@intCaseLabelCount, 0) AS intPrintedCaseLabelCount
END TRY

BEGIN CATCH
	SET @ErrMsg = ERROR_MESSAGE()

	RAISERROR (
			@ErrMsg
			,18
			,1
			,'WITH NOWAIT'
			)
END CATCH
