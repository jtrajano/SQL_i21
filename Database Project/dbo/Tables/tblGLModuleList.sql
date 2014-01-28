﻿CREATE TABLE [dbo].[tblGLModuleList] (
    [cntID]            INT           IDENTITY (1, 1) NOT NULL,
    [strModule]        NVARCHAR (20) COLLATE Latin1_General_CI_AS NOT NULL,
    [ysnOpen]          BIT           NOT NULL,
    [intConcurrencyId] INT           NOT NULL DEFAULT 1,
    CONSTRAINT [PK_tblGLModuleList] PRIMARY KEY CLUSTERED ([cntID] ASC, [strModule] ASC)
);

