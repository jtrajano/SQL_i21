﻿CREATE TABLE [dbo].[tblCFItem] (
    [intItemId]                     INT             IDENTITY (1, 1) NOT NULL,
    [intTaxGroupMaster]             INT             NULL,
    [intNetworkId]                  INT             NULL,
    [intSiteId]                     INT             NULL,
    [strProductNumber]              NVARCHAR (250)  COLLATE Latin1_General_CI_AS NULL,
    [intARItemId]                   INT             NULL,
    [strProductDescription]         NVARCHAR (250)  COLLATE Latin1_General_CI_AS NULL,
    [dblOPISAverageCost1]           NUMERIC (18, 6) NULL,
    [dtmOPISEffectiveDate1]         DATETIME        NULL,
    [dblOPISAverageCost2]           NUMERIC (18, 6) NULL,
    [dtmOPISEffectiveDate2]         DATETIME        NULL,
    [dblOPISAverageCost3]           NUMERIC (18, 6) NULL,
    [dtmOPISEffectiveDate3]         DATETIME        NULL,
    [dblSellingPrice]               NUMERIC (18, 6) NULL,
    [dblPumpPrice]                  NUMERIC (18, 6) NULL,
    [ysnCarryNegligibleBalance]     BIT             NULL,
    [ysnIncludeInQuantityDiscount]  BIT             NULL,
    [strDepartmentType]             NVARCHAR (250)  COLLATE Latin1_General_CI_AS NULL,
    [ysnOverrideLocationSalesTax]   BIT             NULL,
    [dblRemoteFeePerTransaction]    NUMERIC (18, 6) NULL,
    [dblExtRemoteFeePerTransaction] NUMERIC (18, 6) NULL,
    [ysnMPGCalculation]             BIT             NULL,
    [ysnChargeOregonP]              BIT             NULL,
    [intCreatedUserId]              INT             NULL,
    [dtmCreated]                    DATETIME        NULL,
    [intLastModifiedUserId]         INT             NULL,
    [dtmLastModified]               DATETIME        NULL,
    [intConcurrencyId]              INT             CONSTRAINT [DF_tblCFItem_intConcurrencyId] DEFAULT ((1)) NULL,
    CONSTRAINT [PK_tblCFItem] PRIMARY KEY CLUSTERED ([intItemId] ASC),
    CONSTRAINT [FK_tblCFItem_tblCFSite] FOREIGN KEY ([intSiteId]) REFERENCES [dbo].[tblCFSite] ([intSiteId]) ON DELETE CASCADE
);







