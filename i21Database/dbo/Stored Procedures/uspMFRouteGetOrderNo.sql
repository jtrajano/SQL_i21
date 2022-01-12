CREATE PROCEDURE uspMFRouteGetOrderNo @strRouteNumber NVARCHAR(100)
	,@intLocationId INT
AS
BEGIN TRY
	DECLARE @intRouteId INT
		,@strError NVARCHAR(50)
	DECLARE @tblLGRouteOrder TABLE (
		intRowNo INT IDENTITY(1, 1)
		,intRouteOrderId INT
		)
	DECLARE @intRowNo INT
		,@intRouteOrderId INT
		,@intSalesOrderDetailId INT
		,@intInventoryTransferDetailId INT

	SELECT @intRouteId = NULL

	SELECT @intRouteId = intRouteId
	FROM tblLGRoute
	WHERE strRouteNumber = @strRouteNumber
		AND intSourceType = 6

	IF @intRouteId IS NULL
	BEGIN
		RAISERROR (
				'INVALID ROUTE NO.'
				,16
				,1
				)

		RETURN
	END

	IF NOT EXISTS (
			SELECT 1
			FROM tblLGRoute
			WHERE intRouteId = @intRouteId
				AND ISNULL(ysnPosted, 0) = 1
			)
	BEGIN
		RAISERROR (
				'ROUTE NO IS NOT YET POSTED.'
				,16
				,1
				)
	END

	DELETE
	FROM @tblLGRouteOrder

	INSERT INTO @tblLGRouteOrder (intRouteOrderId)
	SELECT RO.intRouteOrderId
	FROM tblLGRouteOrder RO
	JOIN tblLGRoute R ON R.intRouteId = RO.intRouteId
		AND RO.intRouteId = @intRouteId
		AND ISNULL(RO.strOrderNumber, '') <> ''
	ORDER BY RO.intSequence DESC

	SELECT @intRowNo = MIN(intRowNo)
	FROM @tblLGRouteOrder

	IF @intRowNo IS NULL
	BEGIN
		RAISERROR (
				'ROUTE DO NOT HAVE ANY SEQUENCES.'
				,16
				,1
				)

		RETURN
	END

	WHILE @intRowNo IS NOT NULL
	BEGIN
		SELECT @intRouteOrderId = NULL

		SELECT @intRouteOrderId = intRouteOrderId
		FROM @tblLGRouteOrder
		WHERE intRowNo = @intRowNo

		IF NOT EXISTS (
				SELECT 1
				FROM tblMFRouteOrderDetail ROD
				WHERE ROD.intRouteOrderId = @intRouteOrderId
				)
		BEGIN
			SELECT @intSalesOrderDetailId = RO.intSalesOrderDetailId
				,@intInventoryTransferDetailId = RO.intInventoryTransferDetailId
			FROM tblLGRouteOrder RO
			WHERE RO.intRouteOrderId = @intRouteOrderId

			BREAK
		END

		IF EXISTS (
				SELECT 1
				FROM tblMFRouteOrderDetail ROD
				WHERE ROD.intRouteOrderId = @intRouteOrderId
					AND ISNULL(ysnCompleted, 0) = 0
				)
		BEGIN
			SELECT @intSalesOrderDetailId = RO.intSalesOrderDetailId
				,@intInventoryTransferDetailId = RO.intInventoryTransferDetailId
			FROM tblLGRouteOrder RO
			WHERE RO.intRouteOrderId = @intRouteOrderId

			BREAK
		END

		SELECT @intSalesOrderDetailId = NULL
			,@intInventoryTransferDetailId = NULL

		SELECT @intRowNo = MIN(intRowNo)
		FROM @tblLGRouteOrder
		WHERE intRowNo > @intRowNo
	END

	IF @intSalesOrderDetailId IS NULL
		AND @intInventoryTransferDetailId IS NULL
	BEGIN
		RAISERROR (
				'ROUTE SEQUENCE IS COMPLETED.'
				,16
				,1
				)
	END
	ELSE IF @intSalesOrderDetailId IS NOT NULL
	BEGIN
		SELECT DISTINCT RO.intRouteOrderId
			,RO.intRouteId
			,RO.strOrderType
			,S.strSalesOrderNumber AS strOrderNumber
			,P.strPickListNo
			,RO.intSalesOrderId
			,RO.intSalesOrderDetailId
			,PD.intPickListId
			,PD.intPickListDetailId
			,NULL AS intInventoryTransferId
			,NULL AS intInventoryTransferDetailId
			,S.intCompanyLocationId AS intOrderLocationId
		FROM tblLGRouteOrder RO
		JOIN dbo.tblSOSalesOrderDetail SD ON SD.intSalesOrderDetailId = RO.intSalesOrderDetailId
			AND RO.intRouteOrderId = @intRouteOrderId
			AND SD.intSalesOrderDetailId = @intSalesOrderDetailId
		JOIN dbo.tblSOSalesOrder S ON S.intSalesOrderId = SD.intSalesOrderId
		JOIN dbo.tblMFPickList P ON P.intSalesOrderId = S.intSalesOrderId
		JOIN dbo.tblMFPickListDetail PD ON PD.intPickListId = P.intPickListId
		JOIN dbo.tblICItem i ON i.intItemId = SD.intItemId
			AND PD.intItemId = SD.intItemId
		JOIN dbo.tblICItemUOM iu ON iu.intItemUOMId = PD.intPickUOMId
			AND PD.intItemUOMId = SD.intItemUOMId
		JOIN dbo.tblICUnitMeasure um ON um.intUnitMeasureId = iu.intUnitMeasureId
		JOIN dbo.tblEMEntity E ON E.intEntityId = S.intEntityCustomerId
	END
	ELSE IF @intInventoryTransferDetailId IS NOT NULL
	BEGIN
		SELECT DISTINCT RO.intRouteOrderId
			,RO.intRouteId
			,RO.strOrderType
			,T.strTransferNo AS strOrderNumber
			,NULL AS strPickListNo
			,NULL AS intSalesOrderId
			,NULL AS intSalesOrderDetailId
			,NULL AS intPickListId
			,NULL AS intPickListDetailId
			,RO.intInventoryTransferId
			,RO.intInventoryTransferDetailId
			,T.intFromLocationId AS intOrderLocationId
		FROM tblLGRouteOrder RO
		JOIN dbo.tblICInventoryTransferDetail TD ON TD.intInventoryTransferDetailId = RO.intInventoryTransferDetailId
			AND RO.intRouteOrderId = @intRouteOrderId
			AND TD.intInventoryTransferDetailId = @intInventoryTransferDetailId
		JOIN dbo.tblICInventoryTransfer T ON T.intInventoryTransferId = TD.intInventoryTransferId
		JOIN dbo.tblICItem i ON i.intItemId = TD.intItemId
		JOIN dbo.tblICItemUOM iu ON iu.intItemUOMId = TD.intItemUOMId
		JOIN dbo.tblICUnitMeasure um ON um.intUnitMeasureId = iu.intUnitMeasureId
	END
END TRY

BEGIN CATCH
	SET @strError = ERROR_MESSAGE()

	RAISERROR (
			@strError
			,16
			,1
			,'WITH NOWAIT'
			)
END CATCH
