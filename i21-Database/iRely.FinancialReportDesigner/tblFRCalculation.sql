CREATE TABLE [dbo].[tblFRCalculation] (
    [intCalculationId] INT            IDENTITY (1, 1) NOT NULL,
    [strType]          NVARCHAR (25)  COLLATE Latin1_General_CI_AS NULL,
    [intComponentId]   INT            NULL,
    [strCalculation]   NVARCHAR (500) COLLATE Latin1_General_CI_AS NULL,
    [imgCalcTree]      IMAGE          NULL,
    [intConcurrencyId] INT            DEFAULT 1 NOT NULL,
    CONSTRAINT [PK_tblFRCalculation] PRIMARY KEY CLUSTERED ([intCalculationId] ASC)
);

