CREATE TABLE [dbo].[tblRKDPIInventory]
(
	intDPIInventoryId INT IDENTITY NOT NULL
	, intDPIHeaderId INT NOT NULL
	, dtmTransactionDate DATETIME NOT NULL
	, strReceiptNumber NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL
	, strDistribution NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL
	, dblIn NUMERIC(18, 6) NULL
	, strShipTicketNo NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL
	, dblOut NUMERIC(18, 6) NULL
	, strAdjNo NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL
	, dblAdjQty NUMERIC(18, 6) NULL
	, strCountNumber NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL
	, dblCountQty NUMERIC(18, 6) NULL
	, dblDummy NUMERIC(18, 6) NULL
	, dblBalanceForward NUMERIC(18, 6) NULL
	, strShipDistributionOption NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL
	, intInventoryReceiptId INT NULL
	, intInventoryShipmentId INT NULL
	, intInventoryAdjustmentId INT NULL
	, intInventoryCountId INT NULL
	, intInvoiceId INT NULL
	, intDeliverySheetId INT NULL
	, strDeliverySheetNumber NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL
	, intTicketId INT NULL
	, strTicketNumber NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL
	, intConcurrencyId INT NULL DEFAULT ((0))
    , CONSTRAINT [PK_tblRKDPIInventory] PRIMARY KEY ([intDPIInventoryId])
	, CONSTRAINT [FK_tblRKDPIInventory_tblRKDPIHeader] FOREIGN KEY ([intDPIHeaderId]) REFERENCES [tblRKDPIHeader]([intDPIHeaderId]) 
)