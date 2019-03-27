CREATE TABLE [dbo].[tblRKDPICompanyOwnership]
(
	intDPICompanyOwnershipId INT IDENTITY NOT NULL 
	, intDPIHeaderId INT NOT NULL
	, dtmTransactionDate DATETIME NULL
	, strDistribution NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL
	, dblUnpaidIn NUMERIC(18, 6) NULL
	, dblUnpaidOut NUMERIC(18, 6) NULL
	, dblUnpaidBalance NUMERIC(18, 6) NULL
	, dblPaidBalance NUMERIC(18, 6) NULL
	, dblInventoryBalanceCarryForward NUMERIC(18, 6) NULL
	, strReceiptNumber NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL
	, intReceiptId INT
	, intConcurrencyId INT NULL DEFAULT ((0))
    , CONSTRAINT [PK_tblRKDPICompanyOwnership] PRIMARY KEY ([intDPICompanyOwnershipId])
	, CONSTRAINT [FK_tblRKDPICompanyOwnership_tblRKDPIHeader] FOREIGN KEY ([intDPIHeaderId]) REFERENCES [tblRKDPIHeader]([intDPIHeaderId]) ON DELETE CASCADE
)