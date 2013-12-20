﻿CREATE TABLE [dbo].[tblRMFieldSelectionFilters] (
    [intFieldSelectionFilterId] INT            IDENTITY (1, 1) NOT NULL,
    [intCriteriaFieldId]        INT            NOT NULL,
    [intFilterType]             INT            NOT NULL,
    [strFilter]                 NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NULL,
    [strJoin]                   NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NULL,
    CONSTRAINT [PK_dbo.FieldSelectionFilters] PRIMARY KEY CLUSTERED ([intFieldSelectionFilterId] ASC)
);

