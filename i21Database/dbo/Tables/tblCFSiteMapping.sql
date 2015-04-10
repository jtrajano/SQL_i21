CREATE TABLE [dbo].[tblCFSiteMapping] (
    [intSiteMappingId]     INT            IDENTITY (1, 1) NOT NULL,
    [intSiteLocationId]    INT            NULL,
    [strFieldName]         NVARCHAR (250) COLLATE Latin1_General_CI_AS NULL,
    [intFieldLineNumber]   INT            NULL,
    [intFieldColumnNumber] INT            NULL,
    [intFieldLength]       INT            NULL,
    [intConcurrencyId]     INT            CONSTRAINT [DF_tblCFSiteMapping_intConcurrencyId] DEFAULT ((1)) NULL,
    CONSTRAINT [PK_tblCFSiteMapping] PRIMARY KEY CLUSTERED ([intSiteMappingId] ASC),
    CONSTRAINT [FK_tblCFSiteMapping_tblCFSiteLocation] FOREIGN KEY ([intSiteLocationId]) REFERENCES [dbo].[tblCFSite] ([intSiteId])
);

