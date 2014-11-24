﻿CREATE TABLE [dbo].[tblTMPreferenceCompany] (
    [intConcurrencyId]                 INT             DEFAULT 1 NOT NULL,
    [strSummitIntegration]             NVARCHAR (10)   COLLATE Latin1_General_CI_AS DEFAULT (N'AG') NOT NULL,
    [intPreferenceCompanyID]           INT             IDENTITY (1, 1) NOT NULL,
    [intCeilingBurnRate]               INT             DEFAULT 10 NULL,
    [intFloorBurnRate]                 INT             DEFAULT 10 NULL,
    [ysnAllowClassFill]                BIT             DEFAULT 1 NULL,
    [dblDefaultReservePercent]         NUMERIC (18, 6) NULL DEFAULT 25,
    [strSMTPServer]                    NVARCHAR (50)   COLLATE Latin1_General_CI_AS NULL,
    [strSMTPUsername]                  NVARCHAR (50)   COLLATE Latin1_General_CI_AS NULL,
    [strSMTPPassword]                  NVARCHAR (50)   COLLATE Latin1_General_CI_AS NULL,
    [strFromMail]                      NVARCHAR (50)   COLLATE Latin1_General_CI_AS NULL,
    [strFromName]                      NVARCHAR (50)   COLLATE Latin1_General_CI_AS NULL,
    [intMailServerPort]                INT             NULL,
    [ysnEnableAuthentication]          BIT             NULL,
    [ysnEnableSSL]                     BIT             NULL,
    [strLeaseProductNumber]            NVARCHAR (50)   COLLATE Latin1_General_CI_AS NULL DEFAULT '',
    [ysnEnableETracker]                BIT             NULL DEFAULT 0,
    [strETrackerURL]                   NVARCHAR (200)  COLLATE Latin1_General_CI_AS NULL,
    [ysnUseDeliveryTermOnCS]           BIT             DEFAULT 1 NULL,
    [ysnEnableLeaseBillingAboveMinUse] BIT             DEFAULT 0 NULL,
    [ysnOriginDataImported] BIT NOT NULL DEFAULT 1, 
    [dblDefaultBurnRate] NUMERIC(18, 6) NOT NULL DEFAULT 1, 
    CONSTRAINT [PK_tblTMPreferenceCompany] PRIMARY KEY CLUSTERED ([intPreferenceCompanyID] ASC)
);


GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Default burn rate for new Site',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMPreferenceCompany',
    @level2type = N'COLUMN',
    @level2name = N'dblDefaultBurnRate'