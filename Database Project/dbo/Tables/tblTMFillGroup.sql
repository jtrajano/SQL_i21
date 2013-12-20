﻿CREATE TABLE [dbo].[tblTMFillGroup] (
    [intFillGroupID]   INT           IDENTITY (1, 1) NOT NULL,
    [strFillGroupCode] NVARCHAR (6)  COLLATE Latin1_General_CI_AS NOT NULL,
    [strDescription]   NVARCHAR (50) COLLATE Latin1_General_CI_AS NULL,
    [ysnActive]        BIT           NULL,
    [intConcurrencyID] INT           CONSTRAINT [DF_tblTMFillGroup_intConcurrencyID] DEFAULT ((0)) NULL,
    CONSTRAINT [PK_tblTMFillGroup] PRIMARY KEY CLUSTERED ([intFillGroupID] ASC),
    CONSTRAINT [UQ_tblTMFillGroup_strFillGroupCode] UNIQUE NONCLUSTERED ([strFillGroupCode] ASC)
);

