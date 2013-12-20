CREATE TABLE [dbo].[tblDBPanelAccess] (
    [intPanelUserID] INT IDENTITY (1, 1) NOT NULL,
    [intUserID]      INT NOT NULL,
    [intPanelID]     INT NOT NULL,
    [ysnShow]        BIT DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_dbo.tblDBPanelAccess] PRIMARY KEY CLUSTERED ([intPanelUserID] ASC),
    CONSTRAINT [FK_dbo.tblDBPanelAccess_dbo.tblDBPanel_intPanelID] FOREIGN KEY ([intPanelID]) REFERENCES [dbo].[tblDBPanel] ([intPanelID]) ON DELETE CASCADE
);

