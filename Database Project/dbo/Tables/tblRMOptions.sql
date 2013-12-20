﻿CREATE TABLE [dbo].[tblRMOptions] (
    [intOptionId]    INT            IDENTITY (1, 1) NOT NULL,
    [strName]        NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NULL,
    [strDescription] NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NULL,
    [intType]        INT            NOT NULL,
    [strSettings]    NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NULL,
    [ysnShow]        BIT            NOT NULL,
    [intReportId]    INT            NOT NULL,
    [ysnEnable]      BIT            NOT NULL,
    [intSortId]      INT            NOT NULL,
    CONSTRAINT [PK_dbo.Options] PRIMARY KEY CLUSTERED ([intOptionId] ASC)
);

