CREATE TABLE [dbo].[tblTMCOBOLREADSiteLink] (
    [CustomerNumber]         CHAR (10) CONSTRAINT [DEF_tblTMCOBOLREADSiteLink_CustomerNumber] DEFAULT ((0)) NOT NULL,
    [SiteNumber]             CHAR (4)  CONSTRAINT [DEF_tblTMCOBOLREADSiteLink_SiteNumber] DEFAULT ((0)) NOT NULL,
    [ContractCustomerNumber] CHAR (10) CONSTRAINT [DEF_tblTMCOBOLREADSiteLink_ContractCustomerNumber] DEFAULT ((0)) NOT NULL,
    [ContractNumber]         CHAR (8)  CONSTRAINT [DEF_tblTMCOBOLREADSiteLink_ContractNumber] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_tblTMCOBOLREADSiteLink] PRIMARY KEY CLUSTERED ([ContractCustomerNumber] ASC, [ContractNumber] ASC, [CustomerNumber] ASC, [SiteNumber] ASC)
);


GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Customer Number',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMCOBOLREADSiteLink',
    @level2type = N'COLUMN',
    @level2name = N'CustomerNumber'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Site Number',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMCOBOLREADSiteLink',
    @level2type = N'COLUMN',
    @level2name = N'SiteNumber'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Customer Number of the contract number in Origin',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMCOBOLREADSiteLink',
    @level2type = N'COLUMN',
    @level2name = N'ContractCustomerNumber'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Contract Number',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMCOBOLREADSiteLink',
    @level2type = N'COLUMN',
    @level2name = N'ContractNumber'