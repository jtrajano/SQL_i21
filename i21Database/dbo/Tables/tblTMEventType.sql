CREATE TABLE [dbo].[tblTMEventType] (
    [intConcurrencyId] INT            DEFAULT 1 NOT NULL,
    [intEventTypeID]   INT            IDENTITY (1, 1) NOT NULL,
    [strEventType]     NVARCHAR (50)  COLLATE Latin1_General_CI_AS DEFAULT ('') NOT NULL,
    [ysnDefault]       BIT            DEFAULT 0 NOT NULL,
    [strDescription]   NVARCHAR (200) COLLATE Latin1_General_CI_AS CONSTRAINT [DEF_tblTMEventType_strDescription] DEFAULT ('') NULL,
    CONSTRAINT [PK_tblTMEventType] PRIMARY KEY CLUSTERED ([intEventTypeID] ASC)
);

