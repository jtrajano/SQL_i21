CREATE PROCEDURE uspPostBillBatch
	@batchId			AS NVARCHAR(20)		= NULL,
	@transactionType	AS NVARCHAR(30)		= NULL,
	@post				AS BIT				= 0,
	@recap				AS BIT				= 0,
	@param				AS NVARCHAR(MAX)	= NULL,
	@userId				AS INT				= 1,
	@beginDate			AS DATE				= NULL,
	@endDate			AS DATE				= NULL,
	@beginTransaction	AS NVARCHAR(50)		= NULL,
	@endTransaction		AS NVARCHAR(50)		= NULL,
	@successfulCount	AS INT				= 0 OUTPUT,
	@invalidCount		AS INT				= 0 OUTPUT,
	@success			AS BIT				= 0 OUTPUT,
	@recapId			AS NVARCHAR(250)	= NEWID OUTPUT
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

CREATE TABLE #tmpInvalidBillBatchData (
	[intBillBatchId] [int] PRIMARY KEY,
	UNIQUE (intBillBatchId)
);


DECLARE @BillBatchId int

--DECLARRE VARIABLES
DECLARE @MODULE_NAME NVARCHAR(25) = 'Accounts Payable'
SET @recapId = '1'
--=====================================================================================================================================
-- 	POPULATE JOURNALS TO POST TEMPORARY TABLE
---------------------------------------------------------------------------------------------------------------------------------------
INSERT INTO #tmpPostBillBatchData SELECT [intID] FROM [dbo].fnGetRowsFromDelimitedValues(@param)

SELECT TOP 1 @BillBatchId = intBillBatchId FROM #tmpPostBillBatchData

EXEC uspPostBill  @billBatchId = @BillBatchId, @post = 1, @recap = 0, @userId = @userId, @success = @success OUTPUT, @successfulCount = @successfulCount OUTPUT

IF(@success = 1 AND @successfulCount > 0)
BEGIN
UPDATE tblAPBillBatch
	SET ysnPosted = 1
		WHERE intBillBatchId IN (SELECT intBillBatchId FROM #tmpPostBillBatchData)
END