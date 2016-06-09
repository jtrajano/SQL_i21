--EXEC uspQMReportCOAHeader @intInventoryShipmentItemLotId = 1231;
CREATE PROCEDURE uspQMReportCOAHeader
     @intInventoryShipmentItemLotId INT
AS
SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

BEGIN TRY
	DECLARE @ErrMsg NVARCHAR(MAX)

	SELECT L.intLotId
		,S.intInventoryShipmentId
		,SIL.intInventoryShipmentItemLotId
		,I.intItemId
	FROM dbo.tblICInventoryShipmentItemLot SIL
	JOIN dbo.tblICInventoryShipmentItem SI ON SI.intInventoryShipmentItemId = SIL.intInventoryShipmentItemId
		AND SIL.intInventoryShipmentItemLotId = @intInventoryShipmentItemLotId
	JOIN dbo.tblICInventoryShipment S ON S.intInventoryShipmentId = SI.intInventoryShipmentId
	JOIN dbo.tblICLot L ON L.intLotId = SIL.intLotId
	JOIN dbo.tblICItem I ON I.intItemId = L.intItemId
END TRY

BEGIN CATCH
	SET @ErrMsg = 'uspQMReportCOAHeader - ' + ERROR_MESSAGE()

	RAISERROR (
			@ErrMsg
			,18
			,1
			,'WITH NOWAIT'
			)
END CATCH
