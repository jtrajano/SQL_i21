CREATE TABLE [dbo].[tblCFSite] (
    [intSiteId]                      INT            IDENTITY (1, 1) NOT NULL,
    [intNetworkId]                   INT            NULL,
    [intTaxGroupId]                  INT            NULL,
    [strSiteNumber]                  NVARCHAR (250) COLLATE Latin1_General_CI_AS NULL,
    [intARLocationId]                INT            NULL,
    [intCardId]                      INT            NULL,
    [strTaxState]                    NVARCHAR (250) COLLATE Latin1_General_CI_AS NULL,
    [strAuthorityId1]                NVARCHAR (250) COLLATE Latin1_General_CI_AS NULL,
    [strAuthorityId2]                NVARCHAR (250) COLLATE Latin1_General_CI_AS NULL,
    [ysnFederalExciseTax]            BIT            NULL,
    [ysnStateExciseTax]              BIT            NULL,
    [ysnStateSalesTax]               BIT            NULL,
    [ysnLocalTax1]                   BIT            NULL,
    [ysnLocalTax2]                   BIT            NULL,
    [ysnLocalTax3]                   BIT            NULL,
    [ysnLocalTax4]                   BIT            NULL,
    [ysnLocalTax5]                   BIT            NULL,
    [ysnLocalTax6]                   BIT            NULL,
    [ysnLocalTax7]                   BIT            NULL,
    [ysnLocalTax8]                   BIT            NULL,
    [ysnLocalTax9]                   BIT            NULL,
    [ysnLocalTax10]                  BIT            NULL,
    [ysnLocalTax11]                  BIT            NULL,
    [ysnLocalTax12]                  BIT            NULL,
    [intNumberOfLinesPerTransaction] INT            NULL,
    [intIgnoreCardID]                INT            NULL,
    [strImportFileName]              NVARCHAR (250) COLLATE Latin1_General_CI_AS NULL,
    [strImportPath]                  NVARCHAR (250) COLLATE Latin1_General_CI_AS NULL,
    [intNumberOfDecimalInPrice]      INT            NULL,
    [intNumberOfDecimalInQuantity]   INT            NULL,
    [intNumberOfDecimalInTotal]      INT            NULL,
    [strImportType]                  NVARCHAR (250) COLLATE Latin1_General_CI_AS NULL,
    [strControllerType]              NVARCHAR (250) COLLATE Latin1_General_CI_AS NULL,
    [ysnPumpCalculatesTaxes]         BIT            NULL,
    [ysnSiteAcceptsMajorCreditCards] BIT            NULL,
    [ysnCenexSite]                   BIT            NULL,
    [ysnUseControllerCard]           BIT            NULL,
    [intCashCustomerID]              INT            NULL,
    [ysnProcessCashSales]            BIT            NULL,
    [ysnAssignBatchByDate]           BIT            NULL,
    [ysnMultipleSiteImport]          BIT            NULL,
    [strSiteName]                    NVARCHAR (250) COLLATE Latin1_General_CI_AS NULL,
    [strDeliveryPickup]              NVARCHAR (250) COLLATE Latin1_General_CI_AS NULL,
    [strSiteAddress]                 NVARCHAR (250) COLLATE Latin1_General_CI_AS NULL,
    [strSiteCity]                    NVARCHAR (250) COLLATE Latin1_General_CI_AS NULL,
    [intPPHostId]                    INT            NULL,
    [strPPSiteType]                  NVARCHAR (250) COLLATE Latin1_General_CI_AS NULL,
    [ysnPPLocalPrice]                BIT            NULL,
    [intPPLocalHostId]               INT            NULL,
    [strPPLocalSiteType]             NVARCHAR (250) COLLATE Latin1_General_CI_AS NULL,
    [intPPLocalSiteId]               INT            NULL,
    [intRebateSiteGroupId]           INT            NULL,
    [intAdjustmentSiteGroupId]       INT            NULL,
    [dtmLastTransactionDate]         DATETIME       NULL,
    [ysnEEEStockItemDetail]          BIT            NULL,
    [ysnRecalculateTaxesOnRemote]    BIT            NULL,
    [strSiteType]                    NVARCHAR (250) COLLATE Latin1_General_CI_AS NULL,
    [intCreatedUserId]               INT            NULL,
    [dtmCreated]                     DATETIME       NULL,
    [intLastModifiedUserId]          INT            NULL,
    [dtmLastModified]                DATETIME       NULL,
    [intConcurrencyId]               INT            CONSTRAINT [DF_tblCFSite_intConcurrencyId] DEFAULT ((1)) NULL,
    [intImportMapperId]              INT            NULL,
    CONSTRAINT [PK_tblCFSiteLocation] PRIMARY KEY CLUSTERED ([intSiteId] ASC),
    CONSTRAINT [FK_tblCFSite_tblARCustomer] FOREIGN KEY ([intCashCustomerID]) REFERENCES [dbo].[tblARCustomer] ([intEntityId]),
    CONSTRAINT [FK_tblCFSite_tblCFNetwork] FOREIGN KEY ([intNetworkId]) REFERENCES [dbo].[tblCFNetwork] ([intNetworkId]),
    CONSTRAINT [FK_tblCFSite_tblCFSiteGroup] FOREIGN KEY ([intAdjustmentSiteGroupId]) REFERENCES [dbo].[tblCFSiteGroup] ([intSiteGroupId]),
    CONSTRAINT [FK_tblCFSite_tblSMCompanyLocation] FOREIGN KEY ([intARLocationId]) REFERENCES [dbo].[tblSMCompanyLocation] ([intCompanyLocationId]),
    CONSTRAINT [FK_tblCFSite_tblSMImportFileHeader] FOREIGN KEY ([intImportMapperId]) REFERENCES [dbo].[tblSMImportFileHeader] ([intImportFileHeaderId])
);


















GO
CREATE NONCLUSTERED INDEX [IX_tblCFSite_intSiteId]
    ON [dbo].[tblCFSite]([intSiteId] ASC);


GO
CREATE NONCLUSTERED INDEX [tblCFSite_intSiteId]
    ON [dbo].[tblCFSite]([intSiteId] ASC);


GO
CREATE NONCLUSTERED INDEX [tblCFSite_intNetworkId]
    ON [dbo].[tblCFSite]([intNetworkId] ASC);


GO
CREATE NONCLUSTERED INDEX [tblCFSite_intCardId]
    ON [dbo].[tblCFSite]([intCardId] ASC);

