CREATE TABLE [dbo].[tblCFPriceProfileDetail] (
    [intPriceProfileDetailId] INT             IDENTITY (1, 1) NOT NULL,
    [intPriceProfileHeaderId] INT             NOT NULL,
    [intItemId]               INT             NULL,
    [intNetworkId]            INT             NULL,
    [intSiteGroupId]          INT             NULL,
    [intSiteId]               INT             NULL,
    [intLocalPricingIndex]    INT             NULL,
    [dblRate]                 NUMERIC (18, 6) NULL,
    [strBasis]                NVARCHAR (250)  COLLATE Latin1_General_CI_AS NULL,
    [intConcurrencyId]        INT             CONSTRAINT [DF_tblCFPriceProfileDetail_intConcurrencyId] DEFAULT ((1)) NULL,
    [ysnForceRounding] BIT NULL, 
    CONSTRAINT [PK_tblCFPriceProfileDetail] PRIMARY KEY CLUSTERED ([intPriceProfileDetailId] ASC),
    CONSTRAINT [FK_tblCFPriceProfileDetail_tblCFPriceIndex] FOREIGN KEY ([intLocalPricingIndex]) REFERENCES [dbo].[tblCFPriceIndex] ([intPriceIndexId]),
    CONSTRAINT [FK_tblCFPriceProfileDetail_tblCFPriceProfileHeader] FOREIGN KEY ([intPriceProfileHeaderId]) REFERENCES [dbo].[tblCFPriceProfileHeader] ([intPriceProfileHeaderId]) ON DELETE CASCADE,
    CONSTRAINT [FK_tblCFPriceProfileDetail_tblICItem] FOREIGN KEY ([intItemId]) REFERENCES [dbo].[tblICItem] ([intItemId])
);









