CREATE PROCEDURE [dbo].[uspAPProcessToBill]
	@intRecordId int,
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
DECLARE @voucherCreated NVARCHAR(MAX);
DECLARE @billId INT;
	
CREATE TABLE #tmpBillIds (
	[intBillId] [INT] PRIMARY KEY,
	[intInventoryRecordId] [INT],
	[intEntityVendorId] INT,
	[intCurrencyId] INT
)
-- EXEC dbo.[uspAPCreateBillFromIR] 
-- 	@intRecordId,
-- 	@intUserId
EXEC [dbo].[uspICProcessToBill]
	@intReceiptId = @intRecordId,
	@intUserId = @intUserId,
	@intBillId = @billId OUTPUT,
	@strBillIds = @voucherCreated OUTPUT

SET @strBillIds = @voucherCreated

-- SELECT TOP 1 @intBillId = intBillId FROM #tmpBillIds

-- SELECT @strBillIds = 
-- 	LTRIM(
-- 		STUFF(
-- 				' ' + (
-- 					SELECT  CONVERT(NVARCHAR(50), intBillId) + '|^|'
-- 					FROM	#tmpBillIds
-- 					ORDER BY intBillId
-- 					FOR xml path('')
-- 				)
-- 			, 1
-- 			, 1
-- 			, ''
-- 		)
-- 	)

DROP TABLE #tmpBillIds
GO


