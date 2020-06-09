CREATE VIEW [dbo].[vyuICInventorySubLedgerReport]
AS

SELECT
  strPO = NULLIF(ISNULL(r.strPurchaseContractNo, '') + ISNULL(r.strSequenceNo, ''), ''),
  strInvoiceNo = r.strTransactionNo, 
  strAccountingPeriod = fiscal.strPeriod,
  dtmInvoiceDate = r.dtmDate,
  strCounterParty = r.strCounterParty, 
  strProduct = i.strDescription, 
  strPort = r.strPort,
  strLSNo = r.strLSNo,
  strInvoiceType = r.strTransactionType,
  strContainerNo = r.strContainerNo,
  strWarehouseName = r.strWarehouseName,
  strContainerId = r.strContainerId,
  strVessel = r.strVessel,
  strMarks = r.strMarks,
  dblBags = r.dblBags, 
  dblNetWeight = r.dblNetWeight, 
  dblPriceUOM = r.dblPricePerUOM, 
  dblPricePerBag = r.dblPricePerBag,
  strFixationStatus = r.strFixationStatus, 
  dblInvoiceAmount = r.dblInvoiceAmount, 
  strBLNo = r.strBLNo, 
  strOrigin = r.strOrigin, 
  strFuturesMarket = r.strFuturesMarket,
  r.intInventorySubLedgerReportId,
  r.strModule, 
  r.intItemId, 
  r.strPurchaseContractNo, 
  r.strSequenceNo  
FROM tblICInventorySubLedgerReport r
INNER JOIN tblICItem i ON i.intItemId = r.intItemId
OUTER APPLY (
SELECT TOP 1
		fp.strPeriod
	FROM tblGLFiscalYearPeriod fp
	WHERE r.dtmDate BETWEEN fp.dtmStartDate AND fp.dtmEndDate
) fiscal