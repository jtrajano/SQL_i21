CREATE TABLE [dbo].[tblFRHeaderDesign] (
    [intHeaderDetailID] INT             IDENTITY (1, 1) NOT NULL,
    [intHeaderID]       INT             NOT NULL,
    [intRefNo]          INT             NULL,
    [strDescription]    NVARCHAR (250)  COLLATE Latin1_General_CI_AS NULL,
    [strType]           NVARCHAR (250)  COLLATE Latin1_General_CI_AS NULL,
    [dblHeight]         NUMERIC (18, 6) NULL,
    [strFontName]       NCHAR (35)      COLLATE Latin1_General_CI_AS NULL,
    [strFontStyle]      NCHAR (20)      COLLATE Latin1_General_CI_AS NULL,
    [intFontSize]       INT             NULL,
    [strFontColor]      NCHAR (20)      COLLATE Latin1_General_CI_AS NULL,
    [strAllignment]     NVARCHAR (50)   COLLATE Latin1_General_CI_AS NULL,
    [intGroup]          INT             NULL,
    [strWith]           NVARCHAR (50)   COLLATE Latin1_General_CI_AS NULL,
    [strColumnName]     NVARCHAR (250)  COLLATE Latin1_General_CI_AS NULL,
    [intColumnRefNo]    INT             NULL,
    [intSort]           INT             NULL,
    [intConcurrencyID]  INT             CONSTRAINT [DF__tblFRHead__intCo__3DE0CF80] DEFAULT ((1)) NULL,
    CONSTRAINT [PK_tblFRHeaderDesign] PRIMARY KEY CLUSTERED ([intHeaderDetailID] ASC, [intHeaderID] ASC)
);

