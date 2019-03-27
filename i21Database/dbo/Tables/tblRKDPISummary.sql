﻿CREATE TABLE [dbo].[tblRKDPISummary]
(
	intDPISummaryId INT IDENTITY NOT NULL 
	, intDPIHeaderId INT NOT NULL
	, dtmTransactionDate DATETIME NULL
	, dblReceiveIn NUMERIC(18, 6) NULL
	, dblShipOut NUMERIC(18, 6) NULL
	, dblAdjustments NUMERIC(18, 6) NULL
	, dblCount NUMERIC(18, 6) NULL
	, dblInvoiceQty NUMERIC(18, 6) NULL
	, dblInventoryBalance NUMERIC(18, 6) NULL
	, dblSalesInTransit NUMERIC(18, 6) NULL
	, strDistributionA NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL
	, dblAIn NUMERIC(18, 6) NULL
	, dblAOut NUMERIC(18, 6) NULL
	, dblANet NUMERIC(18, 6) NULL
	, strDistributionB NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL
	, dblBIn NUMERIC(18, 6) NULL
	, dblBOut NUMERIC(18, 6) NULL
	, dblBNet NUMERIC(18, 6) NULL
	, strDistributionC NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL
	, dblCIn NUMERIC(18, 6) NULL
	, dblCOut NUMERIC(18, 6) NULL
	, dblCNet NUMERIC(18, 6) NULL
	, strDistributionD NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL
	, dblDIn NUMERIC(18, 6) NULL
	, dblDOut NUMERIC(18, 6) NULL
	, dblDNet NUMERIC(18, 6) NULL
	, strDistributionE NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL
	, dblEIn NUMERIC(18, 6) NULL
	, dblEOut NUMERIC(18, 6) NULL
	, dblENet NUMERIC(18, 6) NULL
	, strDistributionF NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL
	, dblFIn NUMERIC(18, 6) NULL
	, dblFOut NUMERIC(18, 6) NULL
	, dblFNet NUMERIC(18, 6) NULL
	, strDistributionG NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL
	, dblGIn NUMERIC(18, 6) NULL
	, dblGOut NUMERIC(18, 6) NULL
	, dblGNet NUMERIC(18, 6) NULL
	, strDistributionH NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL
	, dblHIn NUMERIC(18, 6) NULL
	, dblHOut NUMERIC(18, 6) NULL
	, dblHNet NUMERIC(18, 6) NULL
	, strDistributionI NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL
	, dblIIn NUMERIC(18, 6) NULL
	, dblIOut NUMERIC(18, 6) NULL
	, dblINet NUMERIC(18, 6) NULL
	, strDistributionJ NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL
	, dblJIn NUMERIC(18, 6) NULL
	, dblJOut NUMERIC(18, 6) NULL
	, dblJNet NUMERIC(18, 6) NULL
	, strDistributionK NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL
	, dblKIn NUMERIC(18, 6) NULL
	, dblKOut NUMERIC(18, 6) NULL
	, dblKNet NUMERIC(18, 6) NULL
	, dblUnpaidIn NUMERIC(18, 6) NULL
	, dblUnpaidOut NUMERIC(18, 6) NULL
	, dblBalance NUMERIC(18, 6) NULL
	, dblPaidBalance NUMERIC(18, 6) NULL
	, dblTotalCompanyOwned NUMERIC(18, 6) NULL
	, dblUnpaidBalance NUMERIC(18, 6) NULL
	, intConcurrencyId INT NULL DEFAULT ((0)) 
    , CONSTRAINT [PK_tblRKDPISummary] PRIMARY KEY ([intDPISummaryId])
	, CONSTRAINT [FK_tblRKDPISummary_tblRKDPIHeader] FOREIGN KEY ([intDPIHeaderId]) REFERENCES [tblRKDPIHeader]([intDPIHeaderId]) ON DELETE CASCADE
)