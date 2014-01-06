CREATE TABLE [dbo].[tblDBPanelUser] (
    [intPanelUserId] INT      IDENTITY (1, 1) NOT NULL,
    [intPanelId]     INT      NOT NULL,
    [intSort]        SMALLINT NOT NULL,
    [intPanelTabId]  INT      NOT NULL,
    [intColumn]      INT      NOT NULL,
    [intUserId]      INT      NOT NULL,
    CONSTRAINT [PK_dbo.tblDBPanelUser] PRIMARY KEY CLUSTERED ([intPanelUserId] ASC),
    CONSTRAINT [FK_dbo.tblDBPanelUser_dbo.tblDBPanel_intPanelID] FOREIGN KEY ([intPanelId]) REFERENCES [dbo].[tblDBPanel] ([intPanelId]) ON DELETE CASCADE,
    CONSTRAINT [FK_dbo.tblDBPanelUser_dbo.tblDBPanelTab_intPanelTabID] FOREIGN KEY ([intPanelTabId]) REFERENCES [dbo].[tblDBPanelTab] ([intPanelTabId]) ON DELETE CASCADE
);

