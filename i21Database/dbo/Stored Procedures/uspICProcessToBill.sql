CREATE PROCEDURE [dbo].[uspICProcessToBill]
	@intReceiptId int,
	@intUserId int,
	@intBillId int OUTPUT
AS
SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

DECLARE @ErrorMessage NVARCHAR(4000);
DECLARE @ErrorSeverity INT;
DECLARE @ErrorState INT;

--BEGIN TRY
	
	CREATE TABLE #tmpBillIds (
		[intBillId] [INT] PRIMARY KEY,
		[intInventoryReceiptId] [INT],
		[intEntityVendorId] INT
	)

	INSERT INTO #tmpBillIds
	EXEC dbo.[uspAPCreateBillFromIR] 
		@intReceiptId,
		@intUserId

	SELECT TOP 1 @intBillId = intBillId FROM #tmpBillIds
	DROP TABLE #tmpBillIds

--END TRY
--BEGIN CATCH
--	SELECT 
--		@ErrorMessage = ERROR_MESSAGE(),
--		@ErrorSeverity = ERROR_SEVERITY(),
--		@ErrorState = ERROR_STATE();

--	-- Use RAISERROR inside the CATCH block to return error
--	-- information about the original error that caused
--	-- execution to jump to the CATCH block.
--	RAISERROR (
--		@ErrorMessage, -- Message text.
--		@ErrorSeverity, -- Severity.
--		@ErrorState -- State.
--	);
--END CATCH