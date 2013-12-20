﻿CREATE TABLE [dbo].[tblTMWorkStatusType] (
    [intWorkStatusID]  INT           IDENTITY (1, 1) NOT NULL,
    [strWorkStatus]    NVARCHAR (50) COLLATE Latin1_General_CI_AS NOT NULL,
    [ysnDefault]       BIT           NULL,
    [intConcurrencyID] INT           NULL,
    CONSTRAINT [PK_tblTMWorkStatus] PRIMARY KEY CLUSTERED ([intWorkStatusID] ASC)
);

