﻿CREATE TABLE [dbo].[tblRMUser] (
    [intUserId]        INT            IDENTITY (1, 1) NOT NULL,
    [strUsername]      NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NULL,
    [strPassword]      NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NULL,
    [intConcurrencyId] INT             NOT NULL DEFAULT 1 ,
    CONSTRAINT [PK_dbo.Users] PRIMARY KEY CLUSTERED ([intUserId] ASC)
);



