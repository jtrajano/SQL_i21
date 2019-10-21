CREATE PROCEDURE [dbo].[uspICSaveShipmentInspection]
	@ShipmentId AS INT

AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

BEGIN

	-- Declare variables 
	DECLARE @intUserId AS INT
			,@intControlPointId AS INT = 3
			,@intProductTypeId AS INT = 4
			,@tmpQualityInspectionTable QualityInspectionTable

	-- Add value for UserId
	SELECT @intUserId = intCreatedUserId FROM tblICInventoryShipment WHERE intInventoryShipmentId = @ShipmentId

	-- Insert values for @QualityTableValues
	INSERT INTO @tmpQualityInspectionTable (
		intPropertyId
		,strPropertyName
		,strPropertyValue
		,strComment
	)
	SELECT 
		ShipmentInspection.intQAPropertyId
		,ShipmentInspection.strPropertyName
		,CASE WHEN ShipmentInspection.ysnSelected = 1 THEN 'true' ELSE 'false' END
		,ShipmentInspection.strComment
	FROM tblICInventoryShipmentInspection ShipmentInspection
	WHERE ShipmentInspection.intInventoryShipmentId = @ShipmentId

	-- Save values to Quality
	EXEC [uspQMInspectionSaveResult]
		@intControlPointId
		,@intProductTypeId
		,@ShipmentId
		,@intUserId
		,@tmpQualityInspectionTable
END
