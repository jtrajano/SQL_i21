CREATE TABLE [dbo].[tblRMFieldSelectionFilter] (
    [intFieldSelectionFilterId] INT            IDENTITY (1, 1) NOT NULL,
    [intCriteriaFieldId]        INT            NOT NULL,
    [intFilterType]             INT            NOT NULL,
    [strFilter]                 NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NULL,
    [strJoin]                   NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NULL,
    CONSTRAINT [PK_dbo.FieldSelectionFilters] PRIMARY KEY CLUSTERED ([intFieldSelectionFilterId] ASC),
    CONSTRAINT [FK_dbo.FieldSelectionFilters_dbo.CriteriaFields_intCriteriaFieldId] FOREIGN KEY ([intCriteriaFieldId]) REFERENCES [dbo].[tblRMCriteriaField] ([intCriteriaFieldId]) ON DELETE CASCADE
);

