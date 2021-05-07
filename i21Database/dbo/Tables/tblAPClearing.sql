CREATE TABLE [dbo].[tblAPClearing]
(
	[intClearingId] 			INT IDENTITY(1, 1) NOT NULL,
	--HEADER
	[intTransactionId]			INT NOT NULL,
	[strTransactionId]			NVARCHAR(55) COLLATE Latin1_General_CI_AS NOT NULL,
	[intTransactionType]		INT NOT NULL,
	[strReferenceNumber]		NVARCHAR(55) COLLATE Latin1_General_CI_AS NULL,
	[dtmDate]					DATETIME NOT NULL,
	[intEntityVendorId]			INT NOT NULL,
	[intLocationId]				INT NOT NULL,
	--DETAIL
	[intTransactionDetailId]	INT NOT NULL,
	[intAccountId]				INT NOT NULL,
	[intItemId]					INT NULL,
	[intItemUOMId]				INT NULL,
	[dblQuantity]				NUMERIC(18, 6) NOT NULL DEFAULT 0,
	[dblAmount]					NUMERIC(18, 6) NOT NULL DEFAULT 0,
	--VOUCHER
	[intOffsetId]				INT NULL,
	[strOffsetId]				NVARCHAR(55) COLLATE Latin1_General_CI_AS NULL,
	[intOffsetDetailId]			INT NULL,
	[intOffsetDetailTaxId]		INT NULL,
	--OTHER INFORMATION
	[strCode]					NVARCHAR(55) COLLATE Latin1_General_CI_AS NOT NULL,
	[ysnPostAction]				BIT NOT NULL DEFAULT 1,
	[dtmDateEntered]			DATETIME NOT NULL,
	[strRemarks]				NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL

	CONSTRAINT [PK_dbo.tblAPClearing] PRIMARY KEY CLUSTERED ([intClearingId] ASC)
);