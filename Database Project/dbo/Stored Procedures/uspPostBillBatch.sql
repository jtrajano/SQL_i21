CREATE PROCEDURE uspPostBillBatch
	@batchId			AS NVARCHAR(20)		= '',
	@journalType		AS NVARCHAR(30)		= '',
	@post				AS BIT				= 0,
	@recap				AS BIT				= 0,
	@param				AS NVARCHAR(MAX)	= '',
	@userId				AS INT				= 1,
	@successfulCount	AS INT				= 0 OUTPUT,
	@success			AS BIT				= 0 OUTPUT,
	@recapId			AS NVARCHAR(250)	=  NEWID OUTPUT
AS

--DECLARE @success BIT
--DECLARE @successfulCount INT
--EXEC uspPostBillBatch '', '', 1, 0, 16, 1, @success OUTPUT, @successfulCount OUTPUT

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

--=====================================================================================================================================
-- 	DECLARE TEMPORARY TABLES
---------------------------------------------------------------------------------------------------------------------------------------
CREATE TABLE #tmpPostBillBatchData (
	[intBillBatchId] [int] PRIMARY KEY,
	UNIQUE (intBillBatchId)
);

CREATE TABLE #tmpValidBillBatchyData (
	[intBillBatchId] [int] PRIMARY KEY,
	UNIQUE (intBillBatchId)
);


DECLARE @Bill int

--DECLARRE VARIABLES
DECLARE @MODULE_NAME NVARCHAR(25) = 'Accounts Payable'
SET @recapId = '1'
--=====================================================================================================================================
-- 	POPULATE JOURNALS TO POST TEMPORARY TABLE
---------------------------------------------------------------------------------------------------------------------------------------
IF (ISNULL(@param, '') <> '') 
	INSERT INTO #tmpPostBillBatchData SELECT [intID] FROM [dbo].fnGetRowsFromDelimitedValues(@param)
--ELSE IF Provision for Date Begin and Date End Parameter
--ELSE IF Provision for Journal Begin and Journal End Parameter
ELSE
	INSERT INTO #tmpPostBillBatchData SELECT [intBillBatchId] FROM tblAPBillBatch

SELECT B.intBillId INTO #Bills
	FROM tblAPBillBatch A 
		INNER JOIN tblAPBill B ON A.intBillBatchId = B.intBillBatchId
	WHERE B.ysnPosted = 0 AND A.intBillBatchId IN (SELECT intBillBatchId FROM #tmpPostBillBatchData)

WHILE(EXISTS(SELECT 1 FROM #Bills))
BEGIN

	SELECT TOP 1 @Bill = intBillId FROM #Bills
	EXEC uspPostBill '', '', 1, 0, @Bill, @userId, @success OUTPUT, @successfulCount OUTPUT
	--EXEC uspPostBill @batchId = '', @journalType = '', @post = 1, @recap = 0, @param = @Bill, @userId = @userId, @success = @success OUTPUT, @successfulCount = @successfulCount OUTPUT
	IF(@success = 0) RETURN;
	DELETE FROM #Bills WHERE intBillId = @Bill

END

UPDATE tblAPBillBatch
	SET ysnPosted = 1
		WHERE intBillBatchId IN (SELECT intBillBatchId FROM #tmpPostBillBatchData)

