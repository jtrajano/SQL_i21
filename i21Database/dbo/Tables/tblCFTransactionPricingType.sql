﻿CREATE TABLE [dbo].[tblCFTransactionPricingType] (
    [intItemId]					INT             NULL,
    [intProductId]				INT             NULL,
    [strProductNumber]			NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
    [strItemId]					NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
    [intCustomerId]				INT             NULL,
    [intLocationId]				INT             NULL,
    [dblQuantity]				NUMERIC (18, 6) NULL,
    [intItemUOMId]				INT             NULL,
    [dtmTransactionDate]		DATETIME        NULL,
    [strTransactionType]		NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
    [intNetworkId]				INT             NULL,
    [intSiteId]					INT             NULL,
    [dblTransferCost]			NUMERIC (18, 6) NULL,
    [dblInventoryCost]			NUMERIC (18, 6) NULL,
    [dblOriginalPrice]			NUMERIC (18, 6) NULL,
    [dblPrice]					NUMERIC (18, 6) NULL,
    [strPriceMethod]			NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
    [dblAvailableQuantity]		NUMERIC (18, 6) NULL,
    [intContractHeaderId]		INT             NULL,
    [intContractDetailId]		INT             NULL,
    [strContractNumber]			NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
    [intContractSeq]			INT             NULL,
    [strPriceBasis]				NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
    [intPriceProfileId]			INT             NULL,
    [intPriceIndexId]			INT             NULL,
    [intSiteGroupId]			INT             NULL,
    [strPriceProfileId]			NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
    [strPriceIndexId]			NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
    [strSiteGroup]				NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
    [dblPriceProfileRate]		NUMERIC (18, 6) NULL,
    [dblPriceIndexRate]			NUMERIC (18, 6) NULL,
    [dtmPriceIndexDate]			DATETIME        NULL,
    [dblMargin]					NUMERIC (18, 6) NULL,
    [dblAdjustmentRate]			NUMERIC (18, 6) NULL,
    [ysnDuplicate]				BIT             NULL,
    [ysnInvalid]				BIT             NULL,
    [dblGrossTransferCost]		NUMERIC (18, 6) NULL,
    [dblNetTransferCost]		NUMERIC (18, 6) NULL,
    [intFreightTermId]			INT             NULL,
	[dblOriginalTotalPrice]		NUMERIC (18, 6) NULL,
	[dblCalculatedTotalPrice]	NUMERIC (18, 6) NULL,
	[dblOriginalGrossPrice]		NUMERIC (18, 6) NULL,
	[dblCalculatedGrossPrice]	NUMERIC (18, 6) NULL,
	[dblCalculatedNetPrice]		NUMERIC (18, 6) NULL,
	[dblOriginalNetPrice]		NUMERIC (18, 6) NULL,
	[dblCalculatedPumpPrice]	NUMERIC (18, 6) NULL,
	[dblOriginalPumpPrice]		NUMERIC (18, 6) NULL,
);

