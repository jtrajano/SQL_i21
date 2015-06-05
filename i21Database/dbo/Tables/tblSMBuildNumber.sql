﻿CREATE TABLE [dbo].[tblSMBuildNumber] (
    [intVersionID]  INT           IDENTITY (1, 1) NOT NULL,
    [strVersionNo]  NVARCHAR (30) COLLATE Latin1_General_CI_AS NOT NULL,
    [dtmLastUpdate] DATETIME      NOT NULL, 
    [strStashCommitId] NVARCHAR (11) COLLATE Latin1_General_CI_AS NULL
);

