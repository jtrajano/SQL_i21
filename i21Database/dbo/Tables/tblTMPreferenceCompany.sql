CREATE TABLE [dbo].[tblTMPreferenceCompany] (
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
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Concurrency Check',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMPreferenceCompany',
    @level2type = N'COLUMN',
    @level2name = N'intConcurrencyId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Obsolete/Unused',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMPreferenceCompany',
    @level2type = N'COLUMN',
    @level2name = N'strSummitIntegration'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Identity Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMPreferenceCompany',
    @level2type = N'COLUMN',
    @level2name = N'intPreferenceCompanyID'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Ceiling Burn Rate',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMPreferenceCompany',
    @level2type = N'COLUMN',
    @level2name = N'intCeilingBurnRate'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Floor Burn Rate',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMPreferenceCompany',
    @level2type = N'COLUMN',
    @level2name = N'intFloorBurnRate'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Allow Class Fill Option',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMPreferenceCompany',
    @level2type = N'COLUMN',
    @level2name = N'ysnAllowClassFill'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Default Reserve Percent',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMPreferenceCompany',
    @level2type = N'COLUMN',
    @level2name = N'dblDefaultReservePercent'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'SMTP Server',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMPreferenceCompany',
    @level2type = N'COLUMN',
    @level2name = N'strSMTPServer'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'SMTP Username',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMPreferenceCompany',
    @level2type = N'COLUMN',
    @level2name = N'strSMTPUsername'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'SMTP Password',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMPreferenceCompany',
    @level2type = N'COLUMN',
    @level2name = N'strSMTPPassword'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'From Email',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMPreferenceCompany',
    @level2type = N'COLUMN',
    @level2name = N'strFromMail'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'From Email Name',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMPreferenceCompany',
    @level2type = N'COLUMN',
    @level2name = N'strFromName'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Mail Server Port',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMPreferenceCompany',
    @level2type = N'COLUMN',
    @level2name = N'intMailServerPort'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'SMTP Enable Authentication Option',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMPreferenceCompany',
    @level2type = N'COLUMN',
    @level2name = N'ysnEnableAuthentication'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'SMTP Eanable SSL',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMPreferenceCompany',
    @level2type = N'COLUMN',
    @level2name = N'ysnEnableSSL'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Lease Product Number',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMPreferenceCompany',
    @level2type = N'COLUMN',
    @level2name = N'strLeaseProductNumber'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Enable ETracker Option',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMPreferenceCompany',
    @level2type = N'COLUMN',
    @level2name = N'ysnEnableETracker'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'ETracker URL ',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMPreferenceCompany',
    @level2type = N'COLUMN',
    @level2name = N'strETrackerURL'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Use Delivery Term On Consumption Site Option',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMPreferenceCompany',
    @level2type = N'COLUMN',
    @level2name = N'ysnUseDeliveryTermOnCS'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Enable Lease Billing Above Minimum Use',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMPreferenceCompany',
    @level2type = N'COLUMN',
    @level2name = N'ysnEnableLeaseBillingAboveMinUse'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Indicates if previous import was done for the Origin Degree Day data',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMPreferenceCompany',
    @level2type = N'COLUMN',
    @level2name = N'ysnOriginDataImported'