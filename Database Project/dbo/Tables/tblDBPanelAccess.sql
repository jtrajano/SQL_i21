CREATE TABLE [dbo].[tblDBPanelAccess] (
    [intPanelUserId] INT IDENTITY (1, 1) NOT NULL,
    [intUserId]      INT NOT NULL,
    [intPanelId]     INT NOT NULL,
    [ysnShow]        BIT DEFAULT ((0)) NOT NULL,
    [intConcurrencyId ] INT NOT NULL DEFAULT ((1)), 
    CONSTRAINT [PK_dbo.tblDBPanelAccess] PRIMARY KEY CLUSTERED ([intPanelUserId] ASC),
    CONSTRAINT [FK_dbo.tblDBPanelAccess_dbo.tblDBPanel_intPanelID] FOREIGN KEY ([intPanelId]) REFERENCES [dbo].[tblDBPanel] ([intPanelId]) ON DELETE CASCADE
);

