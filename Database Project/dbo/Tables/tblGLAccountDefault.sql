CREATE TABLE [dbo].[tblGLAccountDefault] (
    [intAccountDefaultID]    INT IDENTITY (1, 1) NOT NULL,
    [intSecurityUserID]      INT NOT NULL,
    [intGLAccountTemplateID] INT NOT NULL,
    [intConcurrencyID]       INT NULL,
    CONSTRAINT [PK_tblGLAccountDefault] PRIMARY KEY CLUSTERED ([intAccountDefaultID] ASC),
    CONSTRAINT [FK_tblGLAccountDefault_tblGLAccountTemplate] FOREIGN KEY ([intGLAccountTemplateID]) REFERENCES [dbo].[tblGLAccountTemplate] ([intGLAccountTemplateID])
);

