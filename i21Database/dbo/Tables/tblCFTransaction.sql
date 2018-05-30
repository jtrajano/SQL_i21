CREATE TABLE [dbo].[tblCFTransaction] (
    [intTransactionId]           INT             IDENTITY (1, 1) NOT NULL,
    [intPriceIndexId]            INT             NULL,
    [intPriceProfileId]          INT             NULL,
    [intSiteGroupId]             INT             NULL,
    [strPriceProfileId]          NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
    [strPriceIndexId]            NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
    [strSiteGroup]               NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
    [dblPriceProfileRate]        NUMERIC (18, 6) NULL,
    [dblPriceIndexRate]          NUMERIC (18, 6) NULL,
    [dtmPriceIndexDate]          DATETIME        NULL,
    [intContractDetailId]        INT             NULL,
    [intContractId]              INT             NULL,
    [dblQuantity]                NUMERIC (18, 6) NULL,
    [dtmBillingDate]             DATETIME        NULL,
    [dtmTransactionDate]         DATETIME        NOT NULL,
    [intTransTime]               INT             NULL,
    [strSequenceNumber]          NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
    [strPONumber]                NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
    [strMiscellaneous]           NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
    [intOdometer]                INT             NULL,
    [intPumpNumber]              INT             NULL,
    [dblTransferCost]            NUMERIC (18, 6) NULL,
    [strPriceMethod]             NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
    [strPriceBasis]              NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
    [strTransactionType]         NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
    [strDeliveryPickupInd]       NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
    [intNetworkId]               INT             NULL,
    [intSiteId]                  INT             NULL,
    [intCardId]                  INT             NULL,
    [intVehicleId]               INT             NULL,
    [intProductId]               INT             NULL,
    [intARItemId]                INT             NULL,
    [intARLocationId]            INT             NULL,
    [dblOriginalTotalPrice]      NUMERIC (18, 6) NULL,
    [dblCalculatedTotalPrice]    NUMERIC (18, 6) NULL,
    [dblOriginalGrossPrice]      NUMERIC (18, 6) NULL,
    [dblCalculatedGrossPrice]    NUMERIC (18, 6) NULL,
    [dblCalculatedNetPrice]      NUMERIC (18, 6) NULL,
    [dblOriginalNetPrice]        NUMERIC (18, 6) NULL,
    [dblCalculatedPumpPrice]     NUMERIC (18, 6) NULL,
    [dblOriginalPumpPrice]       NUMERIC (18, 6) NULL,
    [dblCalculatedTotalTax]      NUMERIC (18, 6) NULL,
    [dblOriginalTotalTax]        NUMERIC (18, 6) NULL,
    [intSalesPersonId]           INT             NULL,
    [ysnInvalid]                 BIT             NULL,
    [ysnCreditCardUsed]          BIT             NULL,
    [ysnOriginHistory]           BIT             NULL,
    [ysnPosted]                  BIT             NULL,
    [strTransactionId]           NVARCHAR (450)  COLLATE Latin1_General_CI_AS NULL,
    [strPrintTimeStamp]          NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
    [strInvoiceReportNumber]     NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
    [strTempInvoiceReportNumber] NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
    [intInvoiceId]               INT             NULL,
    [intConcurrencyId]           INT             CONSTRAINT [DF_tblCFTransaction_intConcurrencyId_1] DEFAULT ((1)) NULL,
    [ysnPostedCSV]               BIT             NULL,
    [strForeignCardId]           NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
    [ysnDuplicate]               BIT             NULL,
    [dtmInvoiceDate]             DATETIME        NULL,
    [dtmPostedDate]              DATETIME        NULL,
    [dtmCreatedDate]             DATETIME        NULL,
    [strOriginalProductNumber]   NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
    [intOverFilledTransactionId] INT             NULL,
    [dblInventoryCost]           NUMERIC (18, 6) NULL,
    [dblMargin]                  NUMERIC (18, 6) NULL,
    [dblAdjustmentRate]          NUMERIC (18, 6) NULL,
    [dblGrossTransferCost]       NUMERIC (18, 6) NULL,
    [dblNetTransferCost]         NUMERIC (18, 6) NULL,
    [ysnOnHold]                  BIT             NULL,
    [intFreightTermId]           INT             NULL,
    [intForDeleteTransId]        INT             NULL,
    [intCustomerId]              INT             NULL,
    [ysnInvoiced]                  BIT             NULL,
    CONSTRAINT [PK_tblCFTransaction] PRIMARY KEY CLUSTERED ([intTransactionId] ASC),
    CONSTRAINT [FK_tblCFTransaction_tblARSalesperson] FOREIGN KEY ([intSalesPersonId]) REFERENCES [dbo].[tblARSalesperson] ([intEntityId]),
    CONSTRAINT [FK_tblCFTransaction_tblCFCard] FOREIGN KEY ([intCardId]) REFERENCES [dbo].[tblCFCard] ([intCardId]),
    CONSTRAINT [FK_tblCFTransaction_tblCFNetwork] FOREIGN KEY ([intNetworkId]) REFERENCES [dbo].[tblCFNetwork] ([intNetworkId]),
    CONSTRAINT [FK_tblCFTransaction_tblCFSite] FOREIGN KEY ([intSiteId]) REFERENCES [dbo].[tblCFSite] ([intSiteId]),
    CONSTRAINT [FK_tblCFTransaction_tblCFVehicle] FOREIGN KEY ([intVehicleId]) REFERENCES [dbo].[tblCFVehicle] ([intVehicleId]),
    CONSTRAINT [FK_tblCFTransaction_tblCTContractDetail] FOREIGN KEY ([intContractDetailId]) REFERENCES [dbo].[tblCTContractDetail] ([intContractDetailId]),
    CONSTRAINT [FK_tblCFTransaction_tblCTContractHeader] FOREIGN KEY ([intContractId]) REFERENCES [dbo].[tblCTContractHeader] ([intContractHeaderId]),
    CONSTRAINT [FK_tblCFTransaction_tblICItem] FOREIGN KEY ([intARItemId]) REFERENCES [dbo].[tblICItem] ([intItemId]),
    CONSTRAINT [UC_UTransactionId] UNIQUE NONCLUSTERED ([strTransactionId] ASC)
);


GO

CREATE NONCLUSTERED INDEX [IX_tblCFTransaction_ysnPosted_dtmTransactionDate_intProductId] ON [dbo].[tblCFTransaction]
(
	[ysnPosted] ASC,
	[dtmTransactionDate] ASC,
	[intProductId] ASC
)
GO


















































GO
CREATE TRIGGER [dbo].[trgCFTransactionRecordNumber]
ON [dbo].[tblCFTransaction]
AFTER INSERT
AS
	DECLARE @CFID NVARCHAR(50)

	-- IF STARTING NUMBER IS EDITABLE --
		 -- FIX STARTING NUMBER --

	EXEC uspSMGetStartingNumber 52, @CFID OUT
	
	IF(@CFID IS NOT NULL)
	BEGIN
		UPDATE tblCFTransaction
			SET tblCFTransaction.strTransactionId = @CFID,
				tblCFTransaction.intForDeleteTransId = CAST(REPLACE(@CFID,'CFDT-','') AS int)
		FROM tblCFTransaction A
			INNER JOIN INSERTED B ON A.intTransactionId = B.intTransactionId
	END
GO
CREATE NONCLUSTERED INDEX [IX_tblCFTransaction_intVehicleId]
    ON [dbo].[tblCFTransaction]([intVehicleId] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_tblCFTransaction_intTransactionId]
    ON [dbo].[tblCFTransaction]([intTransactionId] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_tblCFTransaction_intSiteId]
    ON [dbo].[tblCFTransaction]([intSiteId] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_tblCFTransaction_intSiteGroupId]
    ON [dbo].[tblCFTransaction]([intSiteGroupId] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_tblCFTransaction_intProductId]
    ON [dbo].[tblCFTransaction]([intProductId] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_tblCFTransaction_intPriceProfileId]
    ON [dbo].[tblCFTransaction]([intPriceProfileId] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_tblCFTransaction_intPriceIndexId]
    ON [dbo].[tblCFTransaction]([intPriceIndexId] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_tblCFTransaction_intNetworkId]
    ON [dbo].[tblCFTransaction]([intNetworkId] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_tblCFTransaction_intInvoiceId]
    ON [dbo].[tblCFTransaction]([intInvoiceId] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_tblCFTransaction_intContractId]
    ON [dbo].[tblCFTransaction]([intContractId] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_tblCFTransaction_intContractDetailId]
    ON [dbo].[tblCFTransaction]([intContractDetailId] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_tblCFTransaction_intCardId]
    ON [dbo].[tblCFTransaction]([intCardId] ASC);


GO
CREATE NONCLUSTERED INDEX [tblCFTransaction_intVehicleId]
    ON [dbo].[tblCFTransaction]([intVehicleId] ASC);


GO
CREATE NONCLUSTERED INDEX [tblCFTransaction_intTransactionId]
    ON [dbo].[tblCFTransaction]([intTransactionId] ASC);


GO
CREATE NONCLUSTERED INDEX [tblCFTransaction_intSiteId]
    ON [dbo].[tblCFTransaction]([intSiteId] ASC);


GO
CREATE NONCLUSTERED INDEX [tblCFTransaction_intSiteGroupId]
    ON [dbo].[tblCFTransaction]([intSiteGroupId] ASC);


GO
CREATE NONCLUSTERED INDEX [tblCFTransaction_intProductId]
    ON [dbo].[tblCFTransaction]([intProductId] ASC);


GO
CREATE NONCLUSTERED INDEX [tblCFTransaction_intPriceProfileId]
    ON [dbo].[tblCFTransaction]([intPriceProfileId] ASC);


GO
CREATE NONCLUSTERED INDEX [tblCFTransaction_intPriceIndexId]
    ON [dbo].[tblCFTransaction]([intPriceIndexId] ASC);


GO
CREATE NONCLUSTERED INDEX [tblCFTransaction_intNetworkId]
    ON [dbo].[tblCFTransaction]([intNetworkId] ASC);


GO
CREATE NONCLUSTERED INDEX [tblCFTransaction_intInvoiceId]
    ON [dbo].[tblCFTransaction]([intInvoiceId] ASC);


GO
CREATE NONCLUSTERED INDEX [tblCFTransaction_intContractId]
    ON [dbo].[tblCFTransaction]([intContractId] ASC);


GO
CREATE NONCLUSTERED INDEX [tblCFTransaction_intContractDetailId]
    ON [dbo].[tblCFTransaction]([intContractDetailId] ASC);


GO
CREATE NONCLUSTERED INDEX [tblCFTransaction_intCardId]
    ON [dbo].[tblCFTransaction]([intCardId] ASC);


GO
CREATE NONCLUSTERED INDEX [tblCFTransaction_intARLocationId]
    ON [dbo].[tblCFTransaction]([intARLocationId] ASC);


GO

CREATE NONCLUSTERED INDEX [tblCFTransaction_intARItemId]
    ON [dbo].[tblCFTransaction]([intARItemId] ASC);

GO

CREATE NONCLUSTERED INDEX [IX_tblCFTransaction_17_1326992154__K46_K31] ON [dbo].[tblCFTransaction]
(
	[ysnPosted] ASC,
	[intProductId] ASC
)
GO

CREATE NONCLUSTERED INDEX [IX_tblCFTransaction_17_1326992154__K46_K31_K1_13] ON [dbo].[tblCFTransaction]
(
	[ysnPosted] ASC,
	[intProductId] ASC,
	[intTransactionId] ASC
)
INCLUDE ( 	[dblQuantity])

GO
CREATE NONCLUSTERED INDEX [IX_tblCFTransaction_17_1326992154__K46_K27_K1_K29_K31_25] ON [dbo].[tblCFTransaction]
(
	[ysnPosted] ASC,
	[intNetworkId] ASC,
	[intTransactionId] ASC,
	[intCardId] ASC,
	[intProductId] ASC
)
INCLUDE ( 	[strTransactionType]) 
GO


CREATE NONCLUSTERED INDEX [IX_tblCFTransaction_17_1326992154__K46_K27_K1_K29_K31_13_25] ON [dbo].[tblCFTransaction]
(
	[ysnPosted] ASC,
	[intNetworkId] ASC,
	[intTransactionId] ASC,
	[intCardId] ASC,
	[intProductId] ASC
)
INCLUDE ( 	[dblQuantity],
	[strTransactionType])
GO

