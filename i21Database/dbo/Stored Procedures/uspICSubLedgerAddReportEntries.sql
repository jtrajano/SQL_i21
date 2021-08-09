CREATE PROCEDURE [dbo].[uspICSubLedgerAddReportEntries]
	@SubLedgerReportEntries SubLedgerReportUdt READONLY,
	-- The raw data that will be transformed and inserted into the actual report table
	@intUserId AS INT
-- Security User Id (optional) 
AS

/*
	Summary:
		This stored procedure is called when posting the transaction. 
		This inserts the details of this transaction to the sub-ledger reporting table.
*/

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

INSERT INTO tblICInventorySubLedgerReport
	(strModule, strTransactionType, strTransactionNo, dtmDate,
	intItemId, strProduct, strPurchaseContractNo, strAccountingPeriod, strSequenceNo,
	strCounterParty, strContainerNo, strWarehouseName, strContainerId,
	strVessel, strMarks, dblBags, dblNetWeight, dblPricePerUOM, dblPricePerBag,
	strFixationStatus, dblInvoiceAmount, strBLNo, strOrigin, strFuturesMarket)
SELECT strSourceTransactionType, strInvoiceType, strInvoiceNo, dtmDate, e.intItemId, i.strDescription,
	strPurchaseContractNo, fiscal.strPeriod, e.strContractSequenceNo,
	strCounterParty, strContainerNo, strWarehouseName, strContainerId,
	strVessel, strMarks, e.dblBags, e.dblNetWeight, dblPricePerUOM, dblPricePerBag,
	strFixationStatus, dblInvoiceAmount, e.strBLNo, e.strOrigin, strFuturesMarket
FROM @SubLedgerReportEntries e
	INNER JOIN tblICItem i ON i.intItemId = e.intItemId
OUTER APPLY (
SELECT TOP 1
		fp.strPeriod
	FROM tblGLFiscalYearPeriod fp
	WHERE e.dtmDate BETWEEN fp.dtmStartDate AND fp.dtmEndDate
) fiscal