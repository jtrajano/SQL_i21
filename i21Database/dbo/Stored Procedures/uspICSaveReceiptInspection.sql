CREATE PROCEDURE [dbo].[uspICSaveReceiptInspection]
	@ReceiptId AS INT

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
			,@intProductTypeId AS INT = 3
			,@tmpQualityInspectionTable QualityInspectionTable

	-- Add value for UserId
	SELECT @intUserId = intCreatedUserId FROM tblICInventoryReceipt WHERE intInventoryReceiptId = @ReceiptId

	-- Insert values for @QualityTableValues
	INSERT INTO @tmpQualityInspectionTable (
		intPropertyId
		,strPropertyName
		,strPropertyValue
	)
	SELECT 
		ReceiptInspection.intQAPropertyId
		,ReceiptInspection.strPropertyName
		,CASE WHEN ReceiptInspection.ysnSelected = 1 THEN 'true' ELSE 'false' END
	FROM tblICInventoryReceiptInspection ReceiptInspection
	WHERE ReceiptInspection.intInventoryReceiptId = @ReceiptId

	-- Save values to Quality
	EXEC [uspQMInspectionSaveResult]
		@intControlPointId
		,@intProductTypeId
		,@ReceiptId
		,@intUserId
		,@tmpQualityInspectionTable
END
