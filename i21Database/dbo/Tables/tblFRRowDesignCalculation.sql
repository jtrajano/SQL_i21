CREATE TABLE [dbo].[tblFRRowDesignCalculation] (
    [intRowCalculationId] INT        IDENTITY (1, 1) NOT NULL,
    [intRowDetailId]      INT        NULL,
    [intRowDetailRefNo]	  INT		 NULL,
    [intRowId]            INT        NOT NULL,
    [intRefNoId]          INT        NOT NULL,
    [intRefNoCalc]        INT        NULL,
    [strAction]           NCHAR (10) COLLATE Latin1_General_CI_AS NULL,
    [intSort]             INT        NULL,
    [intConcurrencyId]    INT        DEFAULT 1 NOT NULL,
    CONSTRAINT [PK_tblFRRowDesignCalculation] PRIMARY KEY CLUSTERED ([intRowCalculationId] ASC),
    CONSTRAINT [FK_tblFRRowDesign_tblFRRowDesignCalculation] FOREIGN KEY([intRowDetailId]) REFERENCES [dbo].[tblFRRowDesign] ([intRowDetailId]) ON DELETE CASCADE,
    CONSTRAINT [FK_tblFRRowDesignCalculation_tblFRRowDesign] FOREIGN KEY([intRowDetailRefNo]) REFERENCES [dbo].[tblFRRowDesign] ([intRowDetailId])
);
