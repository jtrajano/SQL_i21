CREATE PROCEDURE [dbo].[uspICUpdateTableShipmentInspection]
	@ShipmentId AS INT

AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

BEGIN

	-- Declare variables 
	DECLARE @intControlPointId INT = 3  -- 3 / 8 (Inspection / Shipping)
		    ,@intProductTypeId AS INT = 4 -- 3 (Shipment)

	-- Clear values of tblICInventoryShipmentInspection
	DELETE FROM tblICInventoryShipmentInspection where intInventoryShipmentId = @ShipmentId OR intInventoryShipmentId=NULL

	-- Create temp table #tmpGetQMInspectionResult
	BEGIN
		CREATE TABLE #tmpGetQMInspectionResult (
			strPropertyName NVARCHAR(100)
			,intPropertyId INT
			,strPropertyValue NVARCHAR(10)
			,intSequenceNo INT
			,strComment NVARCHAR(200)
		)
	END

	-- Insert values for #tmpGetQMInspectionResult
	IF EXISTS (SELECT 1 FROM dbo.tblQMTestResult where intProductTypeId = 4 AND intProductValueId = @ShipmentId)
		--Do this if Shipment Number is a valid Shipment Id
		BEGIN
			INSERT INTO #tmpGetQMInspectionResult (
				strPropertyName
				,intPropertyId
				,strPropertyValue
				,intSequenceNo
				,strComment
			)
			EXEC dbo.uspQMInspectionGetResult
					@intControlPointId
					,@intProductTypeId 
					,@ShipmentId
		END
	ELSE
		--Do this if Shipment Number is not a valid Shipment Id
		BEGIN
			INSERT INTO #tmpGetQMInspectionResult (
				strPropertyName
				,intPropertyId
				,strPropertyValue
				,intSequenceNo
				,strComment
			)
			EXEC dbo.uspQMInspectionGetResult
					@intControlPointId
					,@intProductTypeId
					,0
		END

	-- Insert values for tblICInventoryShipmentInspection
	INSERT INTO tblICInventoryShipmentInspection (
		[intInventoryShipmentId]
		,[intQAPropertyId]
		,[ysnSelected]
		,[intSort]
		,[intConcurrencyId]
		,[strPropertyName]
		,[strComment]
	)
	SELECT
		@ShipmentId
		,tmpResult.intPropertyId
		,CASE WHEN tmpResult.strPropertyValue = 'true' THEN 1 ELSE 0 END
		,1
		,1
		,tmpResult.strPropertyName
		,tmpResult.strComment
	FROM #tmpGetQMInspectionResult tmpResult
END