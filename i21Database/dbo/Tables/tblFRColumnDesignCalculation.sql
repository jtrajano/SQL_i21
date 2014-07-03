CREATE TABLE [dbo].[tblFRColumnDesignCalculation] (
    [intColumnCalculationId] INT        IDENTITY (1, 1) NOT NULL,
    [intColumnDetailId]		 INT        NULL,
    [intColumnDetailRefNo]	 INT        NULL,
    [intColumnId]            INT        NOT NULL,
    [intRefNoId]             INT        NOT NULL,
    [intRefNoCalc]           INT        NULL,
    [strAction]              NCHAR (10) COLLATE Latin1_General_CI_AS NULL,
    [intConcurrencyId]		 INT        DEFAULT 1 NOT NULL,
    CONSTRAINT [PK_tblFRColumnDesignCalculation] PRIMARY KEY CLUSTERED ([intColumnCalculationId] ASC),
    CONSTRAINT [FK_tblFRColumnDesign_tblFRColumnDesignCalculation] FOREIGN KEY([intColumnDetailId]) REFERENCES [dbo].[tblFRColumnDesign] ([intColumnDetailId]) ON DELETE CASCADE,
    CONSTRAINT [FK_tblFRColumnDesignCalculation_tblFRColumnDesign] FOREIGN KEY([intColumnDetailRefNo]) REFERENCES [dbo].[tblFRColumnDesign] ([intColumnDetailId])
);

