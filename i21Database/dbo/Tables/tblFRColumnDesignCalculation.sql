CREATE TABLE [dbo].[tblFRColumnDesignCalculation] (
    [intColumnCalculationID] INT        IDENTITY (1, 1) NOT NULL,
    [intColumnID]            INT        NOT NULL,
    [intRefNoID]             INT        NOT NULL,
    [intRefNoCalc]           INT        NULL,
    [strAction]              NCHAR (10) COLLATE Latin1_General_CI_AS NULL,
    CONSTRAINT [PK_tblFRColumnDesignCalculation] PRIMARY KEY CLUSTERED ([intColumnCalculationID] ASC)
);

