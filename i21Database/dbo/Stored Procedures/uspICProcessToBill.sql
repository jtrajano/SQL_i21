CREATE PROCEDURE [dbo].[uspICProcessToBill]
	@intReceiptId int,
	@intUserId int,
	@intBillId int OUTPUT,
	@strBillIds NVARCHAR(MAX) = NULL OUTPUT
AS
SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
--SET ANSI_WARNINGS OFF

DECLARE @ErrorMessage NVARCHAR(4000);
DECLARE @ErrorSeverity INT;
DECLARE @ErrorState INT;
	
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

SELECT @strBillIds = 
	LTRIM(
		STUFF(
				' ' + (
					SELECT  CONVERT(NVARCHAR(50), intBillId) + '|^|'
					FROM	#tmpBillIds
					ORDER BY intBillId
					FOR xml path('')
				)
			, 1
			, 1
			, ''
		)
	)

DROP TABLE #tmpBillIds