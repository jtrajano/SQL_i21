﻿CREATE TABLE [dbo].[tblARAccountStatus] (
    [intAccountStatusId]   INT            IDENTITY (1, 1) NOT NULL,
    [strAccountStatusCode] CHAR (1)       COLLATE Latin1_General_CI_AS NOT NULL,
    [strDescription]       NVARCHAR (100) COLLATE Latin1_General_CI_AS NULL,
    [intConcurrencyId]     INT            CONSTRAINT [DF_tblARAccountStatus_intConcurrencyId] DEFAULT ((0)) NOT NULL
);

