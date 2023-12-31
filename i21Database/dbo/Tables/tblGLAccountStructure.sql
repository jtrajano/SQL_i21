﻿CREATE TABLE [dbo].[tblGLAccountStructure] (
    [intAccountStructureId]  INT            IDENTITY (1, 1) NOT NULL,
    [intStructureType]       INT            NOT NULL,
    [strStructureName]       NVARCHAR (25)  COLLATE Latin1_General_CI_AS NULL,
    [strType]                NVARCHAR (20)   COLLATE Latin1_General_CI_AS NULL,
    [intLength]              INT            NULL,
    [strMask]                NVARCHAR (100) COLLATE Latin1_General_CI_AS NULL,
    [intSort]                INT            NULL,
    [ysnBuild]               BIT            CONSTRAINT [DF_tblGLAccountStructure_ysnBuild] DEFAULT ((0)) NOT NULL,
    [intConcurrencyId]       INT            DEFAULT 1 NOT NULL,
    [intStartingPosition]    INT            NULL,
    [intOriginLength]        INT            NULL,
    [strOtherSoftwareColumn] NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NULL,
    CONSTRAINT [PK_GLAccountStructure_AccountStructureId] PRIMARY KEY CLUSTERED ([intAccountStructureId] ASC)
);

