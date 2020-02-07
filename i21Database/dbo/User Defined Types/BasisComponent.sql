﻿CREATE TYPE [dbo].[BasisComponent] AS TABLE
(
	[intContractCostId]			INT NULL,
	[intPrevConcurrencyId]		INT NULL,
	[intContractDetailId]		INT NOT NULL,
	[intItemId]					INT NULL,
	[intVendorId]				INT NULL,
	[strCostMethod]				NVARCHAR(30) COLLATE Latin1_General_CI_AS NOT NULL,
	[intCurrencyId]				INT,
	[dblRate]					NUMERIC(18, 6) NOT NULL,
	[intItemUOMId]				INT NULL,
	[intRateTypeId]				INT NULL,
	[dblFX]						NUMERIC(18,6),
	[ysnAccrue]					BIT NOT NULL DEFAULT ((1)),
	[ysnMTM]					BIT NULL,
	[ysnPrice]					BIT NULL,
	[ysnAdditionalCost]			BIT NULL,
	--[ysnBasis]					BIT NULL,
	[ysnReceivable]				BIT,
	[strParty]					NVARCHAR(50) COLLATE Latin1_General_CI_AS,
	[strPaidBy]					NVARCHAR(50) COLLATE Latin1_General_CI_AS,
	[dtmDueDate]				DATETIME,
	[strReference]				NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL,
	[ysn15DaysFromShipment]		BIT NOT NULL DEFAULT ((0)),
	[strRemarks]				NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL,
	[strStatus]					NVARCHAR(50) COLLATE Latin1_General_CI_AS,
	[strCostStatus]				NVARCHAR(50) COLLATE Latin1_General_CI_AS,
    [dblReqstdAmount]			NUMERIC(18,6),
	[dblRcvdPaidAmount]			NUMERIC(18,6),
	[dblActualAmount]			NUMERIC(18,6),
	[dblAccruedAmount]			NUMERIC(18,6),
	[dblRemainingPercent]		NUMERIC(18,6),
	[dtmAccrualDate]			DATETIME,
	[strAPAR]					NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
	[strPayToReceiveFrom]		NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
	[strReferenceNo]			NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL,
	[intContractCostRefId]		INT,
	[ysnFromBasisComponent]		BIT NULL,
	[intConcurrencyId]			INT NOT NULL
)