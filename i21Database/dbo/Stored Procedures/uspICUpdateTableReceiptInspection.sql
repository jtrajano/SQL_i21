CREATE PROCEDURE [dbo].[uspICUpdateTableReceiptInspection]
	@ReceiptId AS INT

AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

BEGIN

	-- Declare variables 
	DECLARE @intControlPointId INT = 3  -- 3 / 8 (Inspection / Shipping)
		    ,@intProductTypeId AS INT = 3 -- 3 (Receipt)

	-- Clear values of tblICInventoryReceiptInspection
	DELETE FROM tblICInventoryReceiptInspection where intInventoryReceiptId = @ReceiptId OR intInventoryReceiptId=NULL

	-- Create temp table #tmpGetQMInspectionResult
	BEGIN
		CREATE TABLE #tmpGetQMInspectionResult (
			strPropertyName NVARCHAR(50)
			,intPropertyId INT
			,strPropertyValue NVARCHAR(10)
			,intSequenceNo INT
		)
	END

	-- Insert values for #tmpGetQMInspectionResult
	IF EXISTS (SELECT 1 FROM dbo.tblQMTestResult where intProductValueId = @ReceiptId)
		--Do this if Receipt Number is a valid Receipt Id
		BEGIN
			INSERT INTO #tmpGetQMInspectionResult (
				strPropertyName
				,intPropertyId
				,strPropertyValue
				,intSequenceNo
			)
			EXEC dbo.uspQMInspectionGetResult
					@intControlPointId
					,@intProductTypeId 
					,@ReceiptId
		END
	ELSE
		--Do this if Receipt Number is not a valid Receipt Id
		BEGIN
			INSERT INTO #tmpGetQMInspectionResult (
				strPropertyName
				,intPropertyId
				,strPropertyValue
				,intSequenceNo
			)
			EXEC dbo.uspQMInspectionGetResult
					@intControlPointId
					,@intProductTypeId 
					,0
		END

	-- Insert values for tblICInventoryReceiptInspection
	INSERT INTO tblICInventoryReceiptInspection (
		[intInventoryReceiptId]
		,[intQAPropertyId]
		,[ysnSelected]
		,[intSort]
		,[intConcurrencyId]
		,[strPropertyName]
	)
	SELECT
		@ReceiptId
		,tmpResult.intPropertyId
		,CASE WHEN tmpResult.strPropertyValue = 'true' THEN 1 ELSE 0 END
		,1
		,1
		,tmpResult.strPropertyName
	FROM #tmpGetQMInspectionResult tmpResult
END