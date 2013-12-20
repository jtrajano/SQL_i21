CREATE TABLE [dbo].[tblTMEventType] (
    [intConcurrencyID] INT            CONSTRAINT [DEF_tblTMEventType_intConcurrencyID] DEFAULT ((0)) NULL,
    [intEventTypeID]   INT            IDENTITY (1, 1) NOT NULL,
    [strEventType]     NVARCHAR (50)  COLLATE Latin1_General_CI_AS CONSTRAINT [DEF_tblTMEventType_strEventType] DEFAULT ('') NOT NULL,
    [ysnDefault]       BIT            CONSTRAINT [DEF_tblTMEventType_ysnDefault] DEFAULT ((0)) NOT NULL,
    [strDescription]   NVARCHAR (200) COLLATE Latin1_General_CI_AS CONSTRAINT [DEF_tblTMEventType_strDescription] DEFAULT ('') NULL,
    CONSTRAINT [PK_tblTMEventType] PRIMARY KEY CLUSTERED ([intEventTypeID] ASC)
);

