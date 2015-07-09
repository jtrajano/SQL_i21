CREATE TABLE [dbo].[tblCFTransaction] (
    [intTransactionId]        INT             IDENTITY (1, 1) NOT NULL,
    [intContractId]           INT             NULL,
    [dblQuantity]             NUMERIC (18, 6) NULL,
    [dtmBillingDate]          DATETIME        NULL,
    [dtmTransactionDate]      DATETIME        NULL,
    [intTransTime]            INT             NULL,
    [strSequenceNumber]       NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
    [strPONumber]             NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
    [strMiscellaneous]        NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
    [intOdometer]             INT             NULL,
    [intPumpNumber]           INT             NULL,
    [dblTransferCost]         NUMERIC (18, 6) NULL,
    [strPriceMethod]          NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
    [strPriceBasis]           NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
    [strTransactionType]      NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
    [strDeliveryPickupInd]    NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
    [intNetworkId]            INT             NULL,
    [intSiteId]               INT             NULL,
    [intCardId]               INT             NULL,
    [intVehicleId]            INT             NULL,
    [intProductId]            INT             NULL,
    [intARItemId]             INT             NULL,
    [intARLocationId]         INT             NULL,
    [dblOriginalTotalPrice]   NUMERIC (18, 6) NULL,
    [dblCalculatedTotalPrice] NUMERIC (18, 6) NULL,
    [dblOriginalGrossPrice]   NUMERIC (18, 6) NULL,
    [dblCalculatedGrossPrice] NUMERIC (18, 6) NULL,
    [dblCalculatedNetPrice]   NUMERIC (18, 6) NULL,
    [dblOriginalNetPrice]     NUMERIC (18, 6) NULL,
    [dblCalculatedPumpPrice]  NUMERIC (18, 6) NULL,
    [dblOriginalPumpPrice]    NUMERIC (18, 6) NULL,
    [intSalesPersonId]        INT             NULL,
    [intConcurrencyId]        INT             CONSTRAINT [DF_tblCFTransaction_intConcurrencyId_1] DEFAULT ((1)) NULL,
    CONSTRAINT [PK_tblCFTransaction] PRIMARY KEY CLUSTERED ([intTransactionId] ASC)
);





