CREATE TABLE [dbo].[tblCFAccountQuoteSite] (
    [intAccountQuoteSiteId] INT IDENTITY (1, 1) NOT NULL,
    [intSiteId]             INT NOT NULL,
    [intAccountId]          INT NOT NULL,
    [intConcurrencyId]      INT CONSTRAINT [DF_tblCFAccountQuoteSite_intConcurrencyId] DEFAULT ((1)) NOT NULL,
    CONSTRAINT [PK_tblCFAccountQuoteSite] PRIMARY KEY CLUSTERED ([intAccountQuoteSiteId] ASC),
    CONSTRAINT [UQ_tblCFAccountQuoteSite_intAccountId_intSiteId] UNIQUE NONCLUSTERED ([intSiteId] ASC, [intAccountId] ASC)
);


GO