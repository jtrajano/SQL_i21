CREATE TABLE [dbo].[tblFRCalculation] (
    [intCalculationID] INT            IDENTITY (1, 1) NOT NULL,
    [strType]          NVARCHAR (25)  COLLATE Latin1_General_CI_AS NULL,
    [intComponentID]   INT            NULL,
    [strCalculation]   NVARCHAR (500) COLLATE Latin1_General_CI_AS NULL,
    [imgCalcTree]      IMAGE          NULL,
    [intConcurrencyId] INT            DEFAULT 1 NOT NULL,
    CONSTRAINT [PK_tblFRCalculation] PRIMARY KEY CLUSTERED ([intCalculationID] ASC)
);

