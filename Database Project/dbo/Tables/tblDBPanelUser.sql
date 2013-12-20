CREATE TABLE [dbo].[tblDBPanelUser] (
    [intPanelUserID] INT      IDENTITY (1, 1) NOT NULL,
    [intPanelID]     INT      NOT NULL,
    [intSort]        SMALLINT NOT NULL,
    [intPanelTabID]  INT      NOT NULL,
    [intColumn]      INT      NOT NULL,
    [intUserID]      INT      NOT NULL,
    CONSTRAINT [PK_dbo.tblDBPanelUser] PRIMARY KEY CLUSTERED ([intPanelUserID] ASC),
    CONSTRAINT [FK_dbo.tblDBPanelUser_dbo.tblDBPanel_intPanelID] FOREIGN KEY ([intPanelID]) REFERENCES [dbo].[tblDBPanel] ([intPanelID]) ON DELETE CASCADE,
    CONSTRAINT [FK_dbo.tblDBPanelUser_dbo.tblDBPanelTab_intPanelTabID] FOREIGN KEY ([intPanelTabID]) REFERENCES [dbo].[tblDBPanelTab] ([intPanelTabID]) ON DELETE CASCADE
);

