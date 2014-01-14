﻿CREATE TABLE [dbo].[tblEntities] (
    [intEntityId]      INT            IDENTITY (1, 1) NOT NULL,
    [strName]          NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NOT NULL,
    [strWebsite]       NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NOT NULL,
    [strInternalNotes] NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NOT NULL,
    [RowVersion]       ROWVERSION     NOT NULL,
    [intConcurrencyID] INT            NULL,
    CONSTRAINT [PK_dbo.tblEntities] PRIMARY KEY CLUSTERED ([intEntityId] ASC)
);



