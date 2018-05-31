CREATE PROCEDURE [dbo].[uspQMInspectionDeleteResult] @intProductValueId INT -- intInventoryReceiptId / intInventoryShipmentId
	,@intProductTypeId INT = 3 -- 3 / 4 (Receipt / Shipment)
AS
SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

BEGIN
	DELETE
	FROM tblQMSample
	WHERE intProductTypeId = @intProductTypeId
		AND intProductValueId = @intProductValueId
END
