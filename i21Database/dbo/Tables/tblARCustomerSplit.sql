﻿CREATE TABLE [dbo].[tblARCustomerSplit] (
    [intSplitId]          INT           IDENTITY (1, 1) NOT NULL,
    [intEntityId]         INT           NOT NULL,
    [strSplitNumber]      NVARCHAR (50) COLLATE Latin1_General_CI_AS NULL,
    [strRecordType]       NVARCHAR (20) COLLATE Latin1_General_CI_AS NULL,
    [strAgExemptionClass] NVARCHAR (50) COLLATE Latin1_General_CI_AS NULL,
    [strDescription]      NVARCHAR (255) COLLATE Latin1_General_CI_AS NULL,
    [strAcres]            NVARCHAR (50) COLLATE Latin1_General_CI_AS NULL,
    [intConcurrencyId]    INT           NOT NULL,
    CONSTRAINT [PK_tblARCustomerSplit] PRIMARY KEY CLUSTERED ([intSplitId] ASC),
	CONSTRAINT [UKstrSplitNumber] UNIQUE NONCLUSTERED ([strSplitNumber] ASC)
);

