CREATE TABLE [dbo].[tblSMCustomTabDetail] (
    [intCustomTabDetailId]		INT			  IDENTITY (1, 1) NOT NULL,
    [intCustomTabId]			INT           NOT NULL,
	[strFieldName]				NVARCHAR (100)  COLLATE Latin1_General_CI_AS NOT NULL,
    [strControlName]			NVARCHAR (100) COLLATE Latin1_General_CI_AS NOT NULL,
    [strControlType]			NVARCHAR (100) COLLATE Latin1_General_CI_AS NOT NULL,
    [intTextLength]				INT			  NULL,
	[intFlex]					INT			  NULL,
	[intWidth]					INT			  NULL,
    [strLocation]				NVARCHAR (50) COLLATE Latin1_General_CI_AS NOT NULL,
    [ysnBuild]					BIT           NOT NULL,
    [ysnModified]				BIT           NOT NULL,
    [intSort]					INT           NOT NULL,
    [intConcurrencyId]			INT           NOT NULL,
    CONSTRAINT [PK_tblSMCustomTabDetail] PRIMARY KEY CLUSTERED ([intCustomTabDetailId] ASC),
    CONSTRAINT [FK_tblSMCustomTabDetail_tblSMCustomTab] FOREIGN KEY ([intCustomTabId]) REFERENCES [dbo].[tblSMCustomTab] ([intCustomTabId]) ON DELETE CASCADE
);







