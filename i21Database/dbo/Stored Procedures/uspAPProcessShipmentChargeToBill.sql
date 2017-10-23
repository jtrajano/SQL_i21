CREATE PROCEDURE [dbo].[uspAPProcessShipmentChargeToBill]
	@intShipmentId int,
    @intShipmentChargeId int,
	@intUserId int,
	@intBillId int OUTPUT,
	@strBillId NVARCHAR(MAX) = NULL OUTPUT
AS
SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
--SET ANSI_WARNINGS OFF

DECLARE @ErrorMessage NVARCHAR(4000);
DECLARE @ErrorSeverity INT;
DECLARE @ErrorState INT;
	
CREATE TABLE #tmpBillId (
	[intBillId] [INT] PRIMARY KEY,
	[intInventoryShipmentId] [INT],
	[intEntityVendorId] [INT],
	[intCurrencyId] [INT]
)

INSERT INTO #tmpBillId
EXEC dbo.[uspAPCreateBillFromShipmentCharge] 
	@intShipmentId,
    @intShipmentChargeId,
	@intUserId

SELECT @intBillId = intBillId FROM #tmpBillId

SELECT @strBillId = 
	LTRIM(
		STUFF(
				' ' + (
					SELECT  CONVERT(NVARCHAR(50), intBillId) + '|^|'
					FROM	#tmpBillId
					ORDER BY intBillId
					FOR xml path('')
				)
			, 1
			, 1
			, ''
		)
	)

DROP TABLE #tmpBillId
GO


