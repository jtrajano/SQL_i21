CREATE TABLE [dbo].[tblTMEventAutomation] (
    [intConcurrencyId]     INT           DEFAULT 1 NOT NULL,
    [intEventAutomationID] INT           IDENTITY (1, 1) NOT NULL,
    [intEventTypeID]       INT           DEFAULT 0 NULL,
    [strProduct]           NVARCHAR (50) COLLATE Latin1_General_CI_AS DEFAULT ('') NOT NULL,
    CONSTRAINT [PK_tblTMEventAutomation] PRIMARY KEY CLUSTERED ([intEventAutomationID] ASC),
    CONSTRAINT [FK_tblTMEventAutomation_tblTMEventType] FOREIGN KEY ([intEventTypeID]) REFERENCES [dbo].[tblTMEventType] ([intEventTypeID]) ON DELETE SET NULL
);

