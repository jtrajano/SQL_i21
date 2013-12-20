CREATE TABLE [dbo].[tblTMSiteLink] (
    [intConcurrencyID] INT CONSTRAINT [DEF_tblTMSiteLink_intConcurrencyID] DEFAULT ((0)) NULL,
    [intSiteLinkID]    INT IDENTITY (1, 1) NOT NULL,
    [intSiteID]        INT CONSTRAINT [DEF_tblTMSiteLink_intSiteID] DEFAULT ((0)) NULL,
    [intContractID]    INT CONSTRAINT [DEF_tblTMSiteLink_intContractID] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_tblTMSiteLink] PRIMARY KEY CLUSTERED ([intSiteLinkID] ASC),
    CONSTRAINT [FK_tblTMSiteLink_tblTMSite] FOREIGN KEY ([intSiteID]) REFERENCES [dbo].[tblTMSite] ([intSiteID]) ON DELETE CASCADE
);

