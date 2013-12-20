CREATE TABLE [dbo].[tblTMLeaseMinimumUse] (
    [intLeaseMinimumUseID] INT             IDENTITY (1, 1) NOT NULL,
    [dblSiteCapacity]      NUMERIC (18, 6) CONSTRAINT [DF_tblTMLeaseMinimumUse_dblSiteCapacity] DEFAULT ((0)) NOT NULL,
    [dblMinimumUsage]      NUMERIC (18, 6) CONSTRAINT [DF_tblTMLeaseMinimumUse_dblMinimumUsage] DEFAULT ((0)) NOT NULL,
    [intConcurrencyID]     INT             CONSTRAINT [DF_tblTMLeaseMinimumUse_intConcurrencyID] DEFAULT ((0)) NULL,
    CONSTRAINT [PK_tblTMLeaseMinimumUse] PRIMARY KEY CLUSTERED ([intLeaseMinimumUseID] ASC)
);

