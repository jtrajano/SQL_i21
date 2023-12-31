﻿CREATE TABLE [dbo].[tblDBPanelFilter] (
    [intFilterId]       INT            IDENTITY (1, 1) NOT NULL,
    [intSourceFilterId] INT            NOT NULL,
    [strFilterType]     NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NULL,
    [strFilter]         NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NOT NULL,
    [intConcurrencyId ] INT            DEFAULT ((1)) NOT NULL,
    CONSTRAINT [PK_dbo.tblDBPanelFilter] PRIMARY KEY CLUSTERED ([intFilterId] ASC)
);

