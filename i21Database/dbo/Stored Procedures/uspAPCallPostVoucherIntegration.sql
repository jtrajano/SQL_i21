CREATE PROCEDURE [dbo].[uspAPCallPostVoucherIntegration]
	@billIds AS Id READONLY,
	@post AS BIT,
	@intUserId INT
AS

--IP Posting Parameters
DECLARE @strBillIds NVARCHAR(MAX);
DECLARE @strRowState NVARCHAR(10);

SELECT @strBillIds = COALESCE(@strBillIds + ',', '') +  CONVERT(VARCHAR(12),B.intBillId)
FROM @billIds A
INNER JOIN tblAPBill B ON A.intId = B.intBillId
ORDER BY B.strBillId

SET @strRowState = CASE WHEN @post = 0 THEN 'Unposted' ELSE 'Posted' END

INSERT INTO #tmpPostVoucherIntegrationError(intBillId, strBillId, strError)
EXEC uspIPPreStageBill @strBillIds, @strRowState, @intUserId