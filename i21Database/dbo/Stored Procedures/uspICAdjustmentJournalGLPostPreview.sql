CREATE PROCEDURE dbo.uspICAdjustmentJournalGLPostPreview @intInventoryAdjustmentId INT = 0
AS
SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS ON

--Sanitize the @xmlParam 
IF NULLIF(@intInventoryAdjustmentId, 0) IS NULL
BEGIN
--SET @xmlParam = NULL
SELECT
	  0 AS 'intInventoryAdjustmentId'
	, '' AS 'strReportSource'
	, '' AS 'strAdjustmentNo'
	, '' AS 'strBatchId'
	, '' AS 'strWarehouse'
	, '' AS 'strTransactionType'
	, '' AS 'strAccountId'
	, '' AS 'strAccountDescription'
	, '' AS 'strAccountGroup'
	, CAST(0 AS NUMERIC(18, 6)) AS 'dblDebit'
	, CAST(0 AS NUMERIC(18, 6)) AS 'dblCredit'
	, CAST(0 AS NUMERIC(18, 6)) AS 'dblDebitUnit'
	, CAST(0 AS NUMERIC(18, 6)) AS 'dblCreditUnit'
	, '' AS 'strLotNumber'
	, '' AS 'strReference'
	, '' AS 'strVendor'
	, CAST(NULL AS DATETIME) AS 'dtmTransactionDate'
	, '' AS 'strTransactionType'
	RETURN
END

DECLARE @strAdjustmentNo NVARCHAR(100)
DECLARE @strBatchId NVARCHAR(50)
DECLARE @ysnPost BIT
DECLARE @ItemIds TABLE (intItemId INT, intSubLocationId INT, intLotId INT)

--EXEC dbo.uspICPostInventoryAdjustment @ysnPost = 1, @ysnRecap = 0, 
--	@strTransactionId =  'IA-19', @intEntityUserSecurityId = 1, 
--	@strBatchId = @strBatchId OUT

SELECT @ysnPost = a.ysnPosted, @strAdjustmentNo = a.strAdjustmentNo
FROM tblICInventoryAdjustment a
WHERE a.intInventoryAdjustmentId = @intInventoryAdjustmentId

INSERT INTO @ItemIds (intItemId, intSubLocationId, intLotId)
SELECT DISTINCT ad.intItemId, ad.intSubLocationId, ad.intLotId
FROM tblICInventoryAdjustment a
	INNER JOIN tblICInventoryAdjustmentDetail ad ON ad.intInventoryAdjustmentId = a.intInventoryAdjustmentId
WHERE a.intInventoryAdjustmentId = @intInventoryAdjustmentId

IF @ysnPost = 0
BEGIN
	EXEC dbo.uspICPostInventoryAdjustment @ysnPost = 1, @ysnRecap = 1, 
		@strTransactionId = @strAdjustmentNo, @intEntityUserSecurityId = 1, 
		@strBatchId = @strBatchId OUT

	SELECT
	      a.intInventoryAdjustmentId
		, 'Preview' AS strReportSource
		, a.strAdjustmentNo
		, gr.strBatchId
		, strWarehouse = ''
		, gr.strTransactionForm AS strTransactionType
		, gr.strAccountId
		, strAccountDescription = gr.strAccountId + ' - ' + gr.strAccountGroup
		, gr.strAccountGroup
		, gr.dblDebit
		, gr.dblCredit
		, gr.dblDebitUnit
		, gr.dblCreditUnit
		, strLotNumber = ''
		, gr.strReference
		, e.strVendorId AS strVendor
		, gr.dtmTransactionDate
		, gr.strTransactionType
	FROM tblGLPostRecap gr
	INNER JOIN tblICInventoryAdjustment a ON a.intInventoryAdjustmentId = gr.intTransactionId
	LEFT JOIN tblAPVendor e ON e.intEntityId = gr.intEntityId
	--LEFT OUTER JOIN (
	--	SELECT
	--		  MAX(sl.strSubLocationName) AS strWarehouse
	--		, MAX(lot.strLotNumber) strLotNumber
	--		, MAX(ids.intItemId) intItemId
	--	FROM @ItemIds ids
	--	INNER JOIN tblICInventoryAdjustmentDetail d ON d.intItemId = ids.intItemId
	--	LEFT JOIN tblSMCompanyLocationSubLocation sl ON sl.intCompanyLocationSubLocationId = ids.intSubLocationId
	--	LEFT JOIN tblICLot lot ON lot.intLotId = ids.intLotId
	--) ad ON ad.intItemId = gr.intTransactionDetailId
	WHERE gr.strBatchId = @strBatchId
		AND gr.strTransactionForm = 'Inventory Adjustment'
		AND gr.strModuleName = 'Inventory'
	ORDER BY gr.dblDebit DESC
END
ELSE
BEGIN
	SELECT
		  a.intInventoryAdjustmentId
		, 'Transaction' AS strReportSource
		, a.strAdjustmentNo
		, gr.strBatchId
		, strWarehouse = ''
		, gr.strTransactionForm AS strTransactionType
		, ac.strAccountId
		, strAccountDescription = ac.strDescription
		, ag.strAccountGroup
		, gr.dblDebit
		, gr.dblCredit
		, gr.dblDebitUnit
		, gr.dblCreditUnit
		, strLotNumber = ''
		, gr.strReference
		, e.strVendorId AS strVendor
		, gr.dtmTransactionDate
		, gr.strTransactionType
	FROM tblGLDetail gr
	INNER JOIN tblGLAccount ac ON ac.intAccountId = gr.intAccountId
	LEFT JOIN tblGLAccountGroup ag ON ag.intAccountGroupId = ac.intAccountGroupId
	INNER JOIN tblICInventoryAdjustment a ON a.intInventoryAdjustmentId = gr.intTransactionId
	LEFT JOIN tblAPVendor e ON e.intEntityId = gr.intEntityId
	WHERE gr.strTransactionForm = 'Inventory Adjustment'
		AND gr.strModuleName = 'Inventory'
		AND gr.strTransactionId = @strAdjustmentNo
	ORDER BY gr.dblDebit DESC

END
