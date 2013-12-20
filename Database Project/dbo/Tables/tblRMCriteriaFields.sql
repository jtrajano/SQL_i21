CREATE TABLE [dbo].[tblRMCriteriaFields] (
    [intCriteriaFieldId]          INT            IDENTITY (1, 1) NOT NULL,
    [intReportId]                 INT            NOT NULL,
    [intCriteriaFieldSelectionId] INT            NULL,
    [strFieldName]                NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NULL,
    [strDataType]                 NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NULL,
    [strDescription]              NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NULL,
    [strConditions]               NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NULL,
    [ysnIsRequired]               BIT            NOT NULL,
    [ysnShow]                     BIT            NOT NULL,
    [ysnAllowSort]                BIT            NOT NULL,
    [ysnEditCondition]            BIT            NOT NULL,
    CONSTRAINT [PK_dbo.CriteriaFields] PRIMARY KEY CLUSTERED ([intCriteriaFieldId] ASC)
);

