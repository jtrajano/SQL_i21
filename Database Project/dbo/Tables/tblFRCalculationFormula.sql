CREATE TABLE [dbo].[tblFRCalculationFormula] (
    [intCalculationFormulaID] INT            IDENTITY (1, 1) NOT NULL,
    [intColumnID]             INT            NULL,
    [intRowID]                INT            NULL,
    [intColumnRefNo]          INT            NULL,
    [intRowRefNo]             INT            NULL,
    [strFormula]              NVARCHAR (250) COLLATE Latin1_General_CI_AS NULL,
    [intConcurrencyID]        INT            DEFAULT ((1)) NULL,
    [strLocFormula]           NVARCHAR (250) COLLATE Latin1_General_CI_AS NULL,
    CONSTRAINT [PK_tblFRCalculationFormula] PRIMARY KEY CLUSTERED ([intCalculationFormulaID] ASC)
);

