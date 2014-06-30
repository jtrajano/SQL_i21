CREATE TABLE [dbo].[tblSMSearchField] (
    [intSearchFieldId] INT             IDENTITY (1, 1) NOT NULL,
    [intSearchId]      INT             NOT NULL,
    [strFieldName]     NVARCHAR (50)   COLLATE Latin1_General_CI_AS NULL,
    [strDescription]   NVARCHAR (50)   COLLATE Latin1_General_CI_AS NULL,
    [strDataType]      NVARCHAR (50)   COLLATE Latin1_General_CI_AS NULL,
    [dblFlex]          DECIMAL (18, 2) NULL,
    [intIndex]         INT             NULL,
    [strSortOrder]     NVARCHAR (50)   COLLATE Latin1_General_CI_AS NULL,
    [strGroupOrder]    NVARCHAR (50)   COLLATE Latin1_General_CI_AS NULL,
    [ysnGroupBy]       BIT             NULL,
    [ysnSortBy]        BIT             NULL,
    [ysnKey]           BIT             NULL,
    [ysnHidden]        BIT             NULL,
    [intConcurrencyId] INT             NOT NULL,
    CONSTRAINT [PK_tblSMSearchField] PRIMARY KEY CLUSTERED ([intSearchFieldId] ASC),
    CONSTRAINT [FK_tblSMSearchField_tblSMSearch] FOREIGN KEY ([intSearchId]) REFERENCES [dbo].[tblSMSearch] ([intSearchId]) ON DELETE CASCADE
);



