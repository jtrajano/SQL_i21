CREATE TABLE [dbo].[tblTMLeaseMinimumUse] (
    [intLeaseMinimumUseID] INT             IDENTITY (1, 1) NOT NULL,
    [dblSiteCapacity]      NUMERIC (18, 6) DEFAULT 0 NOT NULL,
    [dblMinimumUsage]      NUMERIC (18, 6) DEFAULT 0 NOT NULL,
    [intConcurrencyId]     INT             DEFAULT 1 NOT NULL,
    CONSTRAINT [PK_tblTMLeaseMinimumUse] PRIMARY KEY CLUSTERED ([intLeaseMinimumUseID] ASC)
);

