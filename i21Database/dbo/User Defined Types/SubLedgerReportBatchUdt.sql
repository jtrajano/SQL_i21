CREATE TYPE [dbo].[SubLedgerReportBatchUdt] AS TABLE
(
  intId INT IDENTITY(1,1) PRIMARY KEY CLUSTERED,

  intItemId INT NOT NULL,                                                           -- (required) The id of the inventory item
  strSourceTransactionType NVARCHAR(100) COLLATE Latin1_General_CI_AS NOT NULL,     -- Transaction form needed for batch transaction types entries ex: Invoice, Inventory Adjustment, Debit Memo, etc.
  dtmDate DATETIME NOT NULL,                                                        -- (required) The transaction date
  /* (required)
     Valid Invoice Types:
      - Purchase Invoice
	  - Provisional Purchase Invoice
	  - Final Purchase Invoice
	  - Credit Memo
	  - Inventory Adjustment
  */
  strInvoiceType NVARCHAR(100) COLLATE Latin1_General_CI_AS NOT NULL,
  strInvoiceNo NVARCHAR(100) COLLATE Latin1_General_CI_AS NOT NULL,                  -- The transaction no, ex: Invoice No., Adjustment No., etc.

  dblInvoiceAmount NUMERIC(38, 20) NOT NULL,                                         -- The amount of the transaction.
  dblQty NUMERIC(38, 20) NOT NULL,                                                   -- (required) The qty of the item
  dblNetWeight NUMERIC(38, 20) NULL,                                                 -- The net weight
  dblPricePerUOM NUMERIC(38, 20) NULL,                                               -- The price per UOM
  dblBags NUMERIC(38, 20) NULL,                                                      -- The no. of bags/pack
  dblPricePerBag NUMERIC(38, 20) NULL,                                               -- The price per bag/pack UOM type

  /* UOM IDs are not required but highly recommended to be supplied so we can always get the accurate UOMs */
  intItemUOMId INT NULL,                                                             -- The UOM of the Qty
  intWeightUOMId INT NULL,                                                           -- The UOM of the Netweight
  intPriceUOMId INT NULL,                                                            -- The Price UOM

  /* Basic contract info */
  intPurchaseContractId INT NULL,                                                    -- The primary Id of the purchase contract
  strPurchaseContractNo NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,             -- The purchase contract no., will resolve via contract id if not supplied
  strContractSequenceNo NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,             -- The contract sequence no

  /* Any of these 2, better if both */
  strFuturesMarket NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
  intFuturesMarketId INT NULL,

  /* Most of these fields are coming from Logistics module */
  strCounterParty NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,                   -- Supplier name
  strDestinationPort NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
  strLoadShipmentNo NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
  strContainerNo NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
  strWarehouseName NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
  strContainerId NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
  strVessel NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
  strMarks NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
  strFixationStatus NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,                 -- Valid Values: Fixed, Unfixed
  strBLNo NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
  strOrigin NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL
)