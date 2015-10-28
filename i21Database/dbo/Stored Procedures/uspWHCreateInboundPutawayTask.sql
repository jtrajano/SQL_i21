CREATE PROCEDURE [dbo].[uspWHCreateInboundPutawayTask] 
					@intOrderHeaderId INT, 
					@strUserName NVARCHAR(32), 
					@intCompanyLocationId INT = NULL
AS
BEGIN TRY
	SET NOCOUNT ON

	DECLARE @intLocalTran TINYINT
	DECLARE @intAddressId INT
	DECLARE @intToStorageLocationId INT
	DECLARE @intFromStorageLocationId INT
	DECLARE @intFromContainerId INT
	DECLARE @strTaskNo NVARCHAR(32)
	DECLARE @strTaskState NVARCHAR(16)
	DECLARE @dblQty FLOAT
	DECLARE @intSKUId NUMERIC(18, 0)
	DECLARE @strErrMsg NVARCHAR(MAX)
	DECLARE @tblSku TABLE (intSKUId INT)

	SET @strErrMsg = ''

	INSERT INTO @tblSku (intSKUId)
	SELECT om.intSKUId
	FROM tblWHOrderLineItem li
	INNER JOIN tblWHOrderManifest om ON om.intOrderLineItemId = li.intOrderLineItemId
	WHERE li.intOrderHeaderId = @intOrderHeaderId
	ORDER BY om.intSKUId

	SELECT @intSKUId = MIN(intSKUId)
	FROM @tblSku

	WHILE @intSKUId > 0
	BEGIN
		EXEC dbo.uspWHCreatePutAwayTask @intOrderHeaderId, @intSKUId, @strUserName, @intCompanyLocationId

		SELECT @intSKUId = MIN(intSKUId)
		FROM @tblSku
		WHERE intSKUId > @intSKUId
	END
END TRY

BEGIN CATCH
	SET @strErrMsg = ERROR_MESSAGE()

	IF @strErrMsg != ''
	BEGIN
		SET @strErrMsg = 'uspWHCreateInboundPutawayTask: ' + @strErrMsg

		RAISERROR (@strErrMsg, 16, 1, 'WITH NOWAIT')
	END
END CATCH