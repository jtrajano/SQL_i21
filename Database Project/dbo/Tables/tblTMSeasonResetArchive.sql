CREATE TABLE [dbo].[tblTMSeasonResetArchive] (
    [intSeasonResetArchiveID] INT            IDENTITY (1, 1) NOT NULL,
    [dtmDate]                 DATETIME       NOT NULL,
    [intUserID]               INT            NOT NULL,
    [strNewSeason]            NVARCHAR (6)   COLLATE Latin1_General_CI_AS NOT NULL,
    [strCurrentSeason]        NVARCHAR (6)   COLLATE Latin1_General_CI_AS NOT NULL,
    [strSeason]               NVARCHAR (100) COLLATE Latin1_General_CI_AS NULL,
    [intClockID]              INT            NOT NULL,
    [intConcurrencyId]        INT            DEFAULT 1 NOT NULL
);

