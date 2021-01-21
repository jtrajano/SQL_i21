CREATE PROCEDURE [dbo].[uspAPCallPostVoucherIntegration]
	@billIds AS Id,
	@post AS BIT,
	@intUserId INT
AS

IF OBJECT_ID(N'tempdb..#tmpPostVoucherIntegrationError') IS NOT NULL DROP TABLE #tmpPostVoucherIntegrationError
CREATE TABLE #tmpPostVoucherIntegrationError(intBillId INT, strBillId NVARCHAR(50), strError NVARCHAR(200));

--IP Posting Parameters
DECLARE @strBillIds NVARCHAR(MAX);
DECLARE @strRowState NVARCHAR(10);

SELECT @strBillIds = COALESCE(@strBillIds + ',', '') +  CONVERT(VARCHAR(12),B.strBillId)
FROM @billIds A
INNER JOIN tblAPBill B ON A.intId = B.intBillId
ORDER BY B.strBillId

SET @strRowState = CASE WHEN @post = 0 THEN 'Unposted' ELSE 'Posted' END

INSERT INTO #tmpPostVoucherIntegrationError(intBillId, strBillId, strError)
EXEC uspIPPreStageBill @strBillIds, @strRowState, @intUserId

--RETURN ALL THE VOUCHERS THAT HAS AN ERROR
SELECT * FROM #tmpPostVoucherIntegrationError