﻿CREATE TABLE [dbo].[tblARCustomerSplitDetail] (
    [intSplitDetailId] INT             IDENTITY (1, 1) NOT NULL,
    [intSplitId]       INT             NOT NULL,
    [intEntityId]      INT             NULL,
    [dblSplitPercent]  NUMERIC (18, 6) NULL,
    [strOption]        NVARCHAR (50)   COLLATE Latin1_General_CI_AS NULL,
	[intCompanyId]	   INT			   NULL,
    [intConcurrencyId] INT             NOT NULL,
    CONSTRAINT [PK_tblARCustomerSplitDetail] PRIMARY KEY CLUSTERED ([intSplitDetailId] ASC)
);

