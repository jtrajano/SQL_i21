CREATE TABLE [dbo].[tblDBPanelFormat] (
    [intPanelFormatID] INT            IDENTITY (1, 1) NOT NULL,
    [strColumn]        NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NULL,
    [strCondition]     NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NULL,
    [strValue1]        NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NULL,
    [strValue2]        NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NULL,
    [intBackColor]     INT            NOT NULL,
    [strFontStyle]     NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NULL,
    [intFontColor]     INT            NOT NULL,
    [strApplyTo]       NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NULL,
    [intPanelID]       INT            NOT NULL,
    [intUserID]        INT            NOT NULL,
    [intSort]          SMALLINT       NOT NULL,
    [strType]          NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NULL,
    [ysnVisible]       BIT            NOT NULL,
    CONSTRAINT [PK_dbo.tblDBPanelFormat] PRIMARY KEY CLUSTERED ([intPanelFormatID] ASC),
    CONSTRAINT [FK_dbo.tblDBPanelFormat_dbo.tblDBPanel_intPanelID] FOREIGN KEY ([intPanelID]) REFERENCES [dbo].[tblDBPanel] ([intPanelID]) ON DELETE CASCADE
);

