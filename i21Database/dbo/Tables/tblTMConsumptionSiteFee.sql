CREATE TABLE [dbo].[tblTMConsumptionSiteFee] (
[intConcurrencyId]   INT  DEFAULT 1 NOT NULL,
[intConsumptionSiteFeeId] INT IDENTITY (1, 1) NOT NULL,
[dtmDateTime] DATETIME        DEFAULT 0 NULL,
[strType]			NVARCHAR (100)  COLLATE Latin1_General_CI_AS DEFAULT ('') NULL,
[strDescription]			NVARCHAR (100)  COLLATE Latin1_General_CI_AS DEFAULT ('') NULL,
[dblFee]			NUMERIC (18, 6) DEFAULT 0 NULL,
[intSiteId]			INT NOT	NULL,
CONSTRAINT [PK_tblTMConsumptionSiteFee] PRIMARY KEY ([intConsumptionSiteFeeId]),
CONSTRAINT [FK_tblTMConsumptionSiteFee_tblTMSite] FOREIGN KEY ([intSiteId]) REFERENCES [dbo].[tblTMSite] ([intSiteID])
)
GO
CREATE INDEX [IX_tblTMConsumptionSiteFee_intSiteId] ON [dbo].[tblTMConsumptionSiteFee] ([intSiteId])
GO