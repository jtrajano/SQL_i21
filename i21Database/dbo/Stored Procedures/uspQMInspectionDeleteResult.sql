CREATE PROCEDURE [dbo].[uspQMInspectionDeleteResult] @intProductValueId INT -- intInventoryReceiptId / intInventoryShipmentId
	,@intProductTypeId INT = 3 -- 3 / 4 (Receipt / Shipment)
AS
SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

BEGIN
	-- Remove values from Quality Table for Incoming Inspection Result
	DELETE
	FROM tblQMTestResult
	WHERE intSampleId IS NULL
		AND intControlPointId = 3
		AND intProductTypeId = @intProductTypeId
		AND intProductValueId = @intProductValueId
END
