CREATE TABLE [dbo].[tblTMSiteFee] (
    [intConcurrencyId]             INT DEFAULT 1 NOT NULL,
    [intSiteFeeId]              INT IDENTITY (1, 1) NOT NULL,
    [intSiteID]                    INT DEFAULT 0 NULL,
    [intFeeId]                  INT DEFAULT 0 NULL,
    [guiApiUniqueId] UNIQUEIDENTIFIER NULL,
    [intRowNumber] INT NULL,
    CONSTRAINT [PK_tblTMSiteFee] PRIMARY KEY CLUSTERED ([intSiteFeeId] ASC),
    CONSTRAINT [FK_tblTMSiteFee_tblTMFee] FOREIGN KEY ([intFeeId]) REFERENCES [dbo].[tblTMFee] ([intFeeId]) ON DELETE CASCADE,
    CONSTRAINT [FK_tblTMSiteFee_tblTMSite] FOREIGN KEY ([intSiteID]) REFERENCES [dbo].[tblTMSite] ([intSiteID]) ON DELETE CASCADE
);
