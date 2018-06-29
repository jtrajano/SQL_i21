CREATE TABLE [dbo].[tblAPVoucherHistory]
(
	[intId]		INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
	[intBillId] INT NOT NULL,
	[strBillId] NVARCHAR (50)   COLLATE Latin1_General_CI_AS NULL,
	[dblQtyReceived] DECIMAL(18, 6) NOT NULL DEFAULT 0,
	[dblCost] DECIMAL(18, 6) NOT NULL DEFAULT 0, 
	[dblTotal] DECIMAL(18, 6) NOT NULL DEFAULT 0, 
	[dblAmountDue] DECIMAL (18, 6) NOT NULL DEFAULT 0,
	[strCommodity] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[strItemNo] NVARCHAR (50)  COLLATE Latin1_General_CI_AS NULL,
	[strLocation] NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL,
	[strTicketNumber] NVARCHAR(40) COLLATE Latin1_General_CI_AS NULL,
	[strQtyUnitMeasure] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[strCostUnitMeasure] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[strCurrency] NVARCHAR (40)   COLLATE Latin1_General_CI_AS NULL,
	[dtmTransactionDate] DATETIME NULL,
	[dtmTicketDateTime] DATETIME NULL,
	[dtmDateEntered] DATETIME NULL
)
