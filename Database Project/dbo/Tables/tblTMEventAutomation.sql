CREATE TABLE [dbo].[tblTMEventAutomation] (
    [intConcurrencyID]     INT           CONSTRAINT [DEF_tblTMEventAutomation_intConcurrencyID] DEFAULT ((0)) NULL,
    [intEventAutomationID] INT           IDENTITY (1, 1) NOT NULL,
    [intEventTypeID]       INT           CONSTRAINT [DEF_tblTMEventAutomation_intEventTypeID] DEFAULT ((0)) NULL,
    [strProduct]           NVARCHAR (50) COLLATE Latin1_General_CI_AS CONSTRAINT [DEF_tblTMEventAutomation_strProduct] DEFAULT ('') NOT NULL,
    CONSTRAINT [PK_tblTMEventAutomation] PRIMARY KEY CLUSTERED ([intEventAutomationID] ASC),
    CONSTRAINT [FK_tblTMEventAutomation_tblTMEventType] FOREIGN KEY ([intEventTypeID]) REFERENCES [dbo].[tblTMEventType] ([intEventTypeID]) ON DELETE SET NULL
);

