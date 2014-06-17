CREATE TABLE [dbo].[tblFRHeaderDesign] (
    [intHeaderDetailId] INT             IDENTITY (1, 1) NOT NULL,
    [intHeaderId]       INT             NOT NULL,
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
    [intConcurrencyId]  INT             DEFAULT 1 NOT NULL,
    CONSTRAINT [PK_tblFRHeaderDesign] PRIMARY KEY CLUSTERED ([intHeaderDetailId] ASC, [intHeaderId] ASC),
    CONSTRAINT [FK_tblFRHeaderDesign_tblFRHeader] FOREIGN KEY ([intHeaderId]) REFERENCES [dbo].[tblFRHeader] ([intHeaderId]) ON DELETE CASCADE
    CONSTRAINT [FK_tblFRHeaderDesign_tblFRColumnDesign] FOREIGN KEY ([intColumnRefNo]) REFERENCES [dbo].[tblFRColumnDesign] ([intColumnDetailId])
);

