CREATE TABLE [dbo].[tblICInventorySubLedgerReport]
(
  [intInventorySubLedgerReportId] [int] IDENTITY NOT NULL,
  [strModule] [nvarchar](100) COLLATE Latin1_General_CI_AS NOT NULL,
  /* Valid Invoice Types:
      - Purchase Invoice
	  - Provisional Purchase Invoice
	  - Final Purchase Invoice
	  - Credit Memo
	  - Inventory Adjustment
  */
  strTransactionType NVARCHAR(100) COLLATE Latin1_General_CI_AS NOT NULL,
  strTransactionNo NVARCHAR(100) COLLATE Latin1_General_CI_AS NOT NULL,
  dtmDate DATETIME NOT NULL,
  intItemId INT NOT NULL,
  strProduct NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL,
  intPurchaseContractId INT NULL,
  strPurchaseContractNo NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
  strSequenceNo NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
  strAccountingPeriod NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
  strCounterParty NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
  strPort NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
  strLSNo NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
  strContainerNo NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
  strWarehouseName NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
  strContainerId NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
  strVessel NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
  strMarks NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
  dblBags NUMERIC(38, 20) NULL,
  dblNetWeight NUMERIC(38, 20) NULL,
  dblPricePerUOM NUMERIC(38, 20) NULL,
  dblPricePerBag NUMERIC(38, 20) NULL,
  strFixationStatus NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
  dblInvoiceAmount NUMERIC(38, 20) NULL,
  strBLNo NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
  strOrigin NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
  strFuturesMarket NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
  intFuturesMarketId INT NULL,

  CONSTRAINT [PK_tblICInventorySubLedgerReport_intInventorySubLedgerReportId] PRIMARY KEY CLUSTERED ([intInventorySubLedgerReportId] ASC),
)