CREATE TABLE [dbo].[tblCFSiteGroup] (
    [intSiteGroupId]   INT            IDENTITY (1, 1) NOT NULL,
    [strSiteGroup]     NVARCHAR (250) COLLATE Latin1_General_CI_AS NULL,
    [strDescription]   NVARCHAR (250) COLLATE Latin1_General_CI_AS NULL,
    [strType]          NVARCHAR (250) COLLATE Latin1_General_CI_AS NULL,
    [intConcurrencyId] INT            CONSTRAINT [DF_tblCFSiteGroup_intConcurrencyId] DEFAULT ((1)) NULL,
    CONSTRAINT [PK_tblCFSiteGroup] PRIMARY KEY CLUSTERED ([intSiteGroupId] ASC)
);

