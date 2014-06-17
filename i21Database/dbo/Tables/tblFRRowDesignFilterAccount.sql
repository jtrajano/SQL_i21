CREATE TABLE [dbo].[tblFRRowDesignFilterAccount] (
    [intRowFilterAccountId] INT            IDENTITY (1, 1) NOT NULL,
    [intRowDetailId]        INT            NOT NULL,
    [intRowId]              INT            NOT NULL,
    [intRefNoId]            INT            NOT NULL,
    [strName]               NVARCHAR (50)  COLLATE Latin1_General_CI_AS NULL,
    [strCondition]          NVARCHAR (150) COLLATE Latin1_General_CI_AS NULL,
    [strCriteria]           NVARCHAR (150) COLLATE Latin1_General_CI_AS NULL,
    [strCriteriaBetween]    NVARCHAR (150) COLLATE Latin1_General_CI_AS NULL,
    [strJoin]               NVARCHAR (15)  COLLATE Latin1_General_CI_AS NULL,
    [intConcurrencyId]      INT            DEFAULT 1 NOT NULL,
    CONSTRAINT [PK_tblFRRowDesignFilterAccount] PRIMARY KEY CLUSTERED ([intRowFilterAccountId] ASC),
    CONSTRAINT [FK_tblFRRowDesign_tblFRRowDesignFilterAccount] FOREIGN KEY([intRowDetailId]) REFERENCES [dbo].[tblFRRowDesign] ([intRowDetailId]) ON DELETE CASCADE
);
