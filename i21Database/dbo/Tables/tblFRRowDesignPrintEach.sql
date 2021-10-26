﻿CREATE TABLE [dbo].[tblFRRowDesignPrintEach] (    
	[intRowDetailId]			INT             IDENTITY (1, 1) NOT NULL,
    [intRowId]					INT             NOT NULL,
    [intRefNo]					INT             NOT NULL,
    [strDescription]			NVARCHAR (250)  COLLATE Latin1_General_CI_AS NULL,
    [strRowType]				NVARCHAR (50)   COLLATE Latin1_General_CI_AS NULL,
    [strBalanceSide]			NVARCHAR (10)   COLLATE Latin1_General_CI_AS NULL,
	[strSource]					NVARCHAR (10)   COLLATE Latin1_General_CI_AS NULL,
    [strRelatedRows]			NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
    [strAccountsUsed]			NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
	[strPercentage]				NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
	[strAccountsType]			NVARCHAR (50)   COLLATE Latin1_General_CI_AS NULL,
    [ysnShowCredit]				BIT             DEFAULT 1 NULL,
    [ysnShowDebit]				BIT             DEFAULT 1 NULL,
    [ysnShowOthers]				BIT             DEFAULT 1 NULL,
    [ysnLinktoGL]				BIT             NULL,
	[ysnPrintEach]				BIT             NULL,
	[ysnHidden]					BIT             NULL,
    [dblHeight]					NUMERIC (18, 6) NULL,
    [strFontName]				NVARCHAR (50)   COLLATE Latin1_General_CI_AS NULL,
    [strFontStyle]				NVARCHAR (50)   COLLATE Latin1_General_CI_AS NULL,
    [strFontColor]				NVARCHAR (50)   COLLATE Latin1_General_CI_AS NULL,
    [intFontSize]				INT             NULL,
    [strOverrideFormatMask]		NVARCHAR (100)  COLLATE Latin1_General_CI_AS NULL,
    [ysnForceReversedExpense]	BIT             DEFAULT 0 NULL,
	[ysnOverrideFormula]		BIT             DEFAULT 0 NULL,
	[ysnOverrideColumnFormula]	BIT             DEFAULT 0 NULL,
    [intSort]					INT             NULL,
	[dtmEntered]				DATETIME        NULL,
    [intConcurrencyId]			INT             DEFAULT 1 NOT NULL,
    CONSTRAINT [PK_tblFRRowDesignPrintEach] PRIMARY KEY CLUSTERED ([intRowDetailId] ASC),
    CONSTRAINT [FK_tblFRRowDesignPrintEach_tblFRRow] FOREIGN KEY([intRowId]) REFERENCES [dbo].[tblFRRow] ([intRowId]) ON DELETE CASCADE
);

GO
CREATE NONCLUSTERED INDEX [IX_tblFRRowDesignPrintEach_intRowId] ON [dbo].[tblFRRowDesignPrintEach] ([intRowId] asc)

GO
CREATE NONCLUSTERED INDEX [IX_tblFRRowDesignPrintEach_intRefNo] ON [dbo].[tblFRRowDesignPrintEach] ([intRefNo] asc)
