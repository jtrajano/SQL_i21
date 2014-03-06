CREATE TABLE [dbo].[tblSMControl]
(
	[intControlId] INT NOT NULL PRIMARY KEY IDENTITY, 
    [intScreenId] INT NOT NULL, 
    [strControlId] NVARCHAR(50) NOT NULL, 
    [strControlName] NVARCHAR(100) NULL, 
    [strControlType] NCHAR(10) NOT NULL, 
    [intConcurrencyId] INT NOT NULL DEFAULT (1), 
    CONSTRAINT [FK_tblSMControl_tblSMScreen] FOREIGN KEY ([intScreenId]) REFERENCES [tblSMScreen]([intScreenId])
)

GO

CREATE INDEX [IX_tblSMControl_intScreenId] ON [dbo].[tblSMControl] ([intScreenId])

GO

CREATE INDEX [IX_tblSMControl_strControlId] ON [dbo].[tblSMControl] ([strControlId])

GO

CREATE INDEX [IX_tblSMControl_strControlName] ON [dbo].[tblSMControl] ([strControlName])

GO

CREATE INDEX [IX_tblSMControl_strControlType] ON [dbo].[tblSMControl] ([strControlType])
