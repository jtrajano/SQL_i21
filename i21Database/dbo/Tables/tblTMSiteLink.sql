CREATE TABLE [dbo].[tblTMSiteLink] (
    [intConcurrencyId] INT DEFAULT 1 NOT NULL,
    [intSiteLinkID]    INT IDENTITY (1, 1) NOT NULL,
    [intSiteID]        INT DEFAULT 0 NULL,
    [intContractID]    INT DEFAULT 0 NOT NULL,
    CONSTRAINT [PK_tblTMSiteLink] PRIMARY KEY CLUSTERED ([intSiteLinkID] ASC),
    CONSTRAINT [FK_tblTMSiteLink_tblTMSite] FOREIGN KEY ([intSiteID]) REFERENCES [dbo].[tblTMSite] ([intSiteID]) ON DELETE CASCADE
);

