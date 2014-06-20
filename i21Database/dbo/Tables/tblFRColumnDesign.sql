﻿CREATE TABLE [dbo].[tblFRColumnDesign] (
    [intColumnDetailId]        INT             IDENTITY (1, 1) NOT NULL,
    [strSegmentUsed]           NVARCHAR (4000) COLLATE Latin1_General_CI_AS NULL,
    [intColumnId]              INT             NOT NULL,
    [intRefNo]                 INT             NOT NULL,
    [ysnReverseSignforExpense] BIT             CONSTRAINT [DF__tblFRColu__ysnRe__42793730] DEFAULT ((0)) NOT NULL,
    [strColumnHeader]          NVARCHAR (255)  COLLATE Latin1_General_CI_AS NOT NULL,
    [strColumnCaption]         NVARCHAR (255)  COLLATE Latin1_General_CI_AS NULL,
    [strColumnType]            NVARCHAR (20)   COLLATE Latin1_General_CI_AS NULL,
    [strBudgetCode]            NVARCHAR (50)   COLLATE Latin1_General_CI_AS NULL,
    [strFilterType]            NVARCHAR (500)  COLLATE Latin1_General_CI_AS NULL,
    [dtmStartDate]             DATETIME        NULL,
    [dtmEndDate]               DATETIME        NULL,
    [strJustification]         NVARCHAR (20)   COLLATE Latin1_General_CI_AS NULL,
    [strFormatMask]            NVARCHAR (100)  COLLATE Latin1_General_CI_AS NULL,
    [strColumnFormula]         NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
    [ysnHiddenColumn]          BIT             NULL,
    [dblWidth]                 NUMERIC (18, 6) NULL,
    [intSort]                  INT             NULL,
    [intConcurrencyId]         INT             DEFAULT 1 NOT NULL,
    CONSTRAINT [PK_tblFRColumnDesign] PRIMARY KEY CLUSTERED ([intColumnDetailId] ASC),
    CONSTRAINT [FK_tblFRColumnDesign_tblFRColumn] FOREIGN KEY([intColumnId]) REFERENCES [dbo].[tblFRColumn] ([intColumnId]) ON DELETE CASCADE
);

