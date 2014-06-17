CREATE TABLE [dbo].[tblFRCalculationFormula] (
    [intCalculationFormulaId] INT            IDENTITY (1, 1) NOT NULL,
    [intColumnId]             INT            NULL,
    [intRowId]                INT            NULL,
    [intColumnRefNo]          INT            NULL,
    [intRowRefNo]             INT            NULL,
    [strFormula]              NVARCHAR (250) COLLATE Latin1_General_CI_AS NULL,
    [intConcurrencyId]        INT            DEFAULT 1 NOT NULL,
    [strLocFormula]           NVARCHAR (250) COLLATE Latin1_General_CI_AS NULL,
    CONSTRAINT [PK_tblFRCalculationFormula] PRIMARY KEY CLUSTERED ([intCalculationFormulaId] ASC)
);

