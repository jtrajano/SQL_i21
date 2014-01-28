CREATE TABLE [dbo].[tblSMPreferences] (
    [intPreferenceID]  INT            IDENTITY (1, 1) NOT NULL,
    [intUserID]        INT            NOT NULL,
    [strPreference]    NVARCHAR (50)  COLLATE Latin1_General_CI_AS NOT NULL,
    [strDescription]   NVARCHAR (100) COLLATE Latin1_General_CI_AS NULL,
    [strValue]         NVARCHAR (100) COLLATE Latin1_General_CI_AS NULL,
    [intSort]          INT            NULL,
    [intConcurrencyId]      INT           NOT NULL DEFAULT 1,
    CONSTRAINT [PK_SMPreferences_PreferenceID] PRIMARY KEY CLUSTERED ([intUserID] ASC, [strPreference] ASC)
);

