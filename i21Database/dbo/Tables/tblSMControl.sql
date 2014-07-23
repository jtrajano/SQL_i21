CREATE TABLE [dbo].[tblSMControl]
(
	[intControlId] INT NOT NULL PRIMARY KEY IDENTITY, 
    [intScreenId] INT NOT NULL, 
    [strControlId] NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL, 
    [strControlName] NVARCHAR(100) COLLATE Latin1_General_CI_AS NOT NULL, 
	[strContainer] NVARCHAR(100) COLLATE Latin1_General_CI_AS NOT NULL, 
    [strControlType] NVARCHAR(10) COLLATE Latin1_General_CI_AS NOT NULL, 
    [intConcurrencyId] INT NOT NULL DEFAULT (1), 
    CONSTRAINT [FK_tblSMControl_tblSMScreen] FOREIGN KEY ([intScreenId]) REFERENCES [tblSMScreen]([intScreenId]) ON DELETE CASCADE
)

GO

CREATE INDEX [IX_tblSMControl_intScreenId] ON [dbo].[tblSMControl] ([intScreenId])

GO

CREATE INDEX [IX_tblSMControl_strControlId] ON [dbo].[tblSMControl] ([strControlId])

GO

CREATE INDEX [IX_tblSMControl_strControlName] ON [dbo].[tblSMControl] ([strControlName])

GO

CREATE INDEX [IX_tblSMControl_strControlType] ON [dbo].[tblSMControl] ([strControlType])

GO

CREATE INDEX [IX_tblSMControl_strContainer] ON [dbo].[tblSMControl] ([strContainer])
