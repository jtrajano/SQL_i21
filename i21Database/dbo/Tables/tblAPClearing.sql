﻿CREATE TABLE [dbo].[tblAPClearing]
(
	[intClearingId] 			INT IDENTITY(1, 1) NOT NULL,
	--HEADER
	[intTransactionId]			INT NOT NULL,
	[strTransactionId]			NVARCHAR(55) COLLATE Latin1_General_CI_AS NOT NULL,
	[strReferenceNumber]		NVARCHAR(55) COLLATE Latin1_General_CI_AS NULL,
	[intTransactionType]		INT NOT NULL,
	[dtmDate]					DATETIME NOT NULL,
	[intEntityVendorId]			INT NOT NULL,
	[intLocationId]				INT NOT NULL,
	--DETAIL
	[intTransactionDetailId]	INT NOT NULL,
	[intAccountId]				INT NOT NULL,
	[intItemId]					INT NULL,
	[intItemUOMId]				INT NULL,
	[dblQuantity]				NUMERIC(18, 6) DEFAULT 0 NOT NULL,
	[dblAmount]					NUMERIC(18, 6) DEFAULT 0 NOT NULL,
	--VOUCHER
	[intBillId]					INT NULL,
	[strBillId]					NVARCHAR(55) COLLATE Latin1_General_CI_AS NULL,
	[intBillDetailId]			INT NULL,
	[intBillDetailTaxId]		INT NULL,
	--OTHER INFORMATION
	[strCode]					NVARCHAR(55) COLLATE Latin1_General_CI_AS NOT NULL,
	[ysnPostAction]				BIT DEFAULT 1 NOT NULL,
	[dtmDateEntered]			DATETIME NOT NULL,

	CONSTRAINT [PK_dbo.tblAPClearing] PRIMARY KEY CLUSTERED ([intClearingId] ASC)
);