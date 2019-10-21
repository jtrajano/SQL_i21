CREATE TABLE [dbo].[tblRMFieldSelectionFilter] (
    [intFieldSelectionFilterId] INT            IDENTITY (1, 1) NOT NULL,
    [intCriteriaFieldId]        INT            NOT NULL,
    [intFilterType]             INT            NOT NULL,
    [strFilter]                 NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NULL,
    [strJoin]                   NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NULL,
    [intConcurrencyId]          INT            DEFAULT ((1)) NOT NULL,
    CONSTRAINT [PK_dbo.FieldSelectionFilters] PRIMARY KEY CLUSTERED ([intFieldSelectionFilterId] ASC),
    CONSTRAINT [FK_tblRMFieldSelectionFilter_tblRMCriteriaField] FOREIGN KEY ([intCriteriaFieldId]) REFERENCES [dbo].[tblRMCriteriaField] ([intCriteriaFieldId]) ON DELETE CASCADE
);



