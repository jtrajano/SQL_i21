﻿CREATE TABLE [dbo].[tblRMCriteriaFieldSelection] (
    [intCriteriaFieldSelectionId] INT            IDENTITY (1, 1) NOT NULL,
    [strName]                     NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NULL,
    [intConnectionId]             INT            NULL,
    [strFieldName]                NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NULL,
    [strCaption]                  NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NULL,
    [strValueField]               NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NULL,
    [strDisplayField]             NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NULL,
    [ysnDistinct]                 BIT            NOT NULL,
    [strSource]                   NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NULL,
    [intFieldSourceType]          INT            NOT NULL,
    [intConcurrencyId]            INT            DEFAULT ((1)) NOT NULL,
    CONSTRAINT [PK_dbo.CriteriaFieldSelections] PRIMARY KEY CLUSTERED ([intCriteriaFieldSelectionId] ASC),
    CONSTRAINT [FK_tblRMCriteriaFieldSelection_tblRMConnection] FOREIGN KEY ([intConnectionId]) REFERENCES [dbo].[tblRMConnection] ([intConnectionId])
);



