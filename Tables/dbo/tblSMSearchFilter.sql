CREATE TABLE [dbo].[tblSMSearchFilter] (
    [intSearchFilterId] INT            IDENTITY (1, 1) NOT NULL,
    [intSearchFieldId]  INT            NOT NULL,
    [strValue]          NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NULL,
    [strCondition]      NVARCHAR (50)  COLLATE Latin1_General_CI_AS NULL,
    [strConjunction]    NVARCHAR (50)  COLLATE Latin1_General_CI_AS NULL,
    [intConcurrencyId]  INT            NOT NULL,
    CONSTRAINT [PK_tblSMSearchFilter] PRIMARY KEY CLUSTERED ([intSearchFilterId] ASC),
    CONSTRAINT [FK_tblSMSearchFilter_tblSMSearchField] FOREIGN KEY ([intSearchFieldId]) REFERENCES [dbo].[tblSMSearchField] ([intSearchFieldId]) ON DELETE CASCADE
);



