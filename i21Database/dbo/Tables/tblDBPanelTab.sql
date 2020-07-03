CREATE TABLE [dbo].[tblDBPanelTab] (
    [intPanelTabId]     INT            IDENTITY (1, 1) NOT NULL,
    [intSort]           SMALLINT       NOT NULL,
    [intUserId]         INT            NOT NULL,
    [intColumn1Width]   INT            NOT NULL,
    [intColumn2Width]   INT            NOT NULL,
    [intColumn3Width]   INT            NOT NULL,
    [intColumn4Width]   INT            NOT NULL,
    [intColumn5Width]   INT            NOT NULL,
    [intColumn6Width]   INT            NOT NULL,
    [intColumnCount]    INT            NOT NULL,
    [strTabName]        NVARCHAR (MAX) COLLATE Latin1_General_CI_AS DEFAULT ('') NOT NULL,
    [strRenameTabName]  NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NULL,
    [intConcurrencyId ] INT            DEFAULT ((1)) NOT NULL,
    [ysnDefaultTab]		BIT NULL DEFAULT ((0)), 
	[ysnSystemTab]		BIT NULL DEFAULT ((0)), 

    CONSTRAINT [PK_dbo.tblDBPanelTab] PRIMARY KEY CLUSTERED ([intPanelTabId] ASC)
);

