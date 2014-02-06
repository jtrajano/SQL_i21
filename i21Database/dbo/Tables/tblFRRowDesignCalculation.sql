CREATE TABLE [dbo].[tblFRRowDesignCalculation] (
    [intRowCalculationID] INT        IDENTITY (1, 1) NOT NULL,
    [intRowID]            INT        NOT NULL,
    [intRefNoID]          INT        NOT NULL,
    [intRefNoCalc]        INT        NULL,
    [strAction]           NCHAR (10) COLLATE Latin1_General_CI_AS NULL,
    [intSort]             INT        NULL,
    CONSTRAINT [PK_tblFRRowDesignCalculation] PRIMARY KEY CLUSTERED ([intRowCalculationID] ASC)
);

