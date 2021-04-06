﻿CREATE TYPE [dbo].[APClearing] AS TABLE
(
	--HEADER
	[intTransactionId]			INT NOT NULL,												--TRANSACTION ID
	[strTransactionId]			NVARCHAR(55) COLLATE Latin1_General_CI_AS NOT NULL,			--TRANSACTION NUMBER E.G. IR-XXXX, PAT-XXXX
	[intTransactionType]		INT NOT NULL,												--TRANSACTION TYPE (DESIGNATED TRANSACTION NUMBERS ARE LISTED BELOW)
	[strReferenceNumber]		NVARCHAR(55) COLLATE Latin1_General_CI_AS NULL,				--TRANSACTION REFERENCE E.G. BOL NUMBER, INVOICE NUMBER
	[dtmDate]					DATETIME NOT NULL,											--TRANSACTION POST DATE
	[intEntityVendorId]			INT NOT NULL,												--TRANSACTION VENDOR ID
	[intLocationId]				INT NOT NULL,												--TRANSACTION LOCATION ID
	--DETAIL
	[intTransactionDetailId]	INT NOT NULL,												--TRANSACTION DETAIL ID
	[intAccountId]				INT NOT NULL,												--TRANSACTION ACCOUNT ID
	[intItemId]					INT NULL,													--TRANSACTION ITEM ID
	[intItemUOMId]				INT NULL,													--TRANSACTION ITEM UOM ID
	[dblQuantity]				NUMERIC(18, 6) DEFAULT 0 NOT NULL,							--TRANSACTION QUANTITY (WE CAN DIRECTLY PUT THE QUANTITY OF THE TRANSACTION, uspAPClearing WILL AUTOMATICALLY NEGATE IT IF @post = 0)
	[dblAmount]					NUMERIC(18, 6) DEFAULT 0 NOT NULL,							--TRANSACTION TOTAL (WE CAN DIRECTLY PUT THE AMOUNT OF THE TRANSACTION, uspAPClearing WILL AUTOMATICALLY NEGATE IT IF @post = 0)
	--OFFSET TRANSACTION DETAILS
	[intOffsetId]				INT NULL,													--TRANSACTION ID
	[strOffsetId]				NVARCHAR(55) COLLATE Latin1_General_CI_AS NULL,				--TRANSACTION NUMBER E.G. BL-XXXX
	[intOffsetDetailId]			INT NULL,													--TRANSACTION DETAIL ID
	[intOffsetDetailTaxId]		INT NULL,													--TRANSACTION DETAIL TAX ID
	--OTHER INFORMATION
	[strCode]					NVARCHAR(55) COLLATE Latin1_General_CI_AS NOT NULL,			--TRANSACTION SOURCE MODULE E.G. IR, AP
	[strRemarks]				NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL				--TRANSACTION REMARKS IF THERE IS
);

/*
	TRANSACTION NUMBERS
	RECEIPT				= 1
	RECEIPT CHARGE		= 2
	SHIPMENT CHARGE		= 3
	LOAD				= 4
	LOAD COST			= 5
	GRAIN				= 6
	TRANSFER			= 7
	TRANSFER CHARGE		= 8
	PAT					= 9

	NOTE: PLEASE ADD A TYPE AND NUMBER IF DOES NOT EXISTS
*/