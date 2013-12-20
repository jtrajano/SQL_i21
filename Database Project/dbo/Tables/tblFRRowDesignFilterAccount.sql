CREATE TABLE [dbo].[tblFRRowDesignFilterAccount] (
    [intRowFilterAccountID] INT            IDENTITY (1, 1) NOT NULL,
    [intRowID]              INT            NOT NULL,
    [intRefNoID]            INT            NOT NULL,
    [strName]               NVARCHAR (50)  COLLATE Latin1_General_CI_AS NULL,
    [strCondition]          NVARCHAR (150) COLLATE Latin1_General_CI_AS NULL,
    [strCriteria]           NVARCHAR (150) COLLATE Latin1_General_CI_AS NULL,
    [strCriteriaBetween]    NVARCHAR (150) COLLATE Latin1_General_CI_AS NULL,
    [strJoin]               NVARCHAR (15)  COLLATE Latin1_General_CI_AS NULL,
    CONSTRAINT [PK_tblFRRowDesignAccounts] PRIMARY KEY CLUSTERED ([intRowFilterAccountID] ASC)
);

