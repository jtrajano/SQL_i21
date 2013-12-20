CREATE TABLE [dbo].[tblGLCurrentFiscalYear] (
    [cntID]             INT             IDENTITY (1, 1) NOT NULL,
    [intFiscalYearID]   INT             NOT NULL,
    [dtmBeginDate]      DATETIME        CONSTRAINT [DF__tblGLCurr__dtmBe__5090EFD7] DEFAULT (getdate()) NOT NULL,
    [dtmEndDate]        DATETIME        CONSTRAINT [DF__tblGLCurr__dtmEn__51851410] DEFAULT (getdate()) NOT NULL,
    [dblPeriods]        NUMERIC (18, 6) CONSTRAINT [DF__tblGLCurr__dblPe__52793849] DEFAULT ((0)) NULL,
    [ysnShowAllPeriods] BIT             CONSTRAINT [DF__tblGLCurr__ysnSh__536D5C82] DEFAULT ((0)) NOT NULL,
    [ysnDuplicates]     BIT             NOT NULL,
    [intConcurrencyID]  INT             CONSTRAINT [DF__tblGLCurr__intCo__546180BB] DEFAULT ((1)) NULL,
    CONSTRAINT [PK_tblGLFiscalYear] PRIMARY KEY CLUSTERED ([cntID] ASC)
);

