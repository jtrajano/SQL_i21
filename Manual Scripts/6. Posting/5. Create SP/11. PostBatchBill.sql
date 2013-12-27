IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[PostBatchBill]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[PostBatchBill]
GO
CREATE PROCEDURE PostBatchBill
	@ysnPost				BIT		= 0
	,@ysnRecap				BIT		= 0
	,@strTransactionID		NVARCHAR(40) = NULL 
	,@isSuccessful			BIT		= 0 OUTPUT 
	,@message_id			INT		= 0 OUTPUT 
AS

--[PostBatchBill] 1, 0, 1

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

DECLARE @Bill NVARCHAR(50)
DECLARE @Success BIT

SELECT strBillId INTO #Bills
	FROM tblAPBillBatches A 
		INNER JOIN tblAPBills B ON A.intBillBatchId = B.intBillBatchId
	WHERE B.ysnPosted = 0 AND A.intBillBatchId = @strTransactionID

WHILE(EXISTS(SELECT 1 FROM #Bills))
BEGIN

	SELECT TOP 1 @Bill = strBillId FROM #Bills
	EXEC PostBill 1, 0, @Bill, @isSuccessful OUTPUT
	IF(@isSuccessful = 0) RETURN;
	DELETE FROM #Bills WHERE strBillId = @Bill

END

UPDATE tblAPBillBatches
	SET ysnPosted = 1
		WHERE intBillBatchId = @strTransactionID

