CREATE TABLE [dbo].[tblTMCOBOLREADSiteLink] (
    [CustomerNumber]         CHAR (10) CONSTRAINT [DEF_tblTMCOBOLREADSiteLink_CustomerNumber] DEFAULT ((0)) NOT NULL,
    [SiteNumber]             CHAR (4)  CONSTRAINT [DEF_tblTMCOBOLREADSiteLink_SiteNumber] DEFAULT ((0)) NOT NULL,
    [ContractCustomerNumber] CHAR (10) CONSTRAINT [DEF_tblTMCOBOLREADSiteLink_ContractCustomerNumber] DEFAULT ((0)) NOT NULL,
    [ContractNumber]         CHAR (8)  CONSTRAINT [DEF_tblTMCOBOLREADSiteLink_ContractNumber] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_tblTMCOBOLREADSiteLink] PRIMARY KEY CLUSTERED ([ContractCustomerNumber] ASC, [ContractNumber] ASC, [CustomerNumber] ASC, [SiteNumber] ASC)
);

