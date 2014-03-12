CREATE TABLE [dbo].[tblGLAccountDefault] (
    [intAccountDefaultId]    INT IDENTITY (1, 1) NOT NULL,
    [intSecurityUserId]      INT NOT NULL,
    [intGLAccountTemplateId] INT NOT NULL,
    [intConcurrencyId]       INT DEFAULT 1 NOT NULL,
    CONSTRAINT [PK_tblGLAccountDefault] PRIMARY KEY CLUSTERED ([intAccountDefaultId] ASC),
    CONSTRAINT [FK_tblGLAccountDefault_tblGLAccountTemplate] FOREIGN KEY ([intGLAccountTemplateId]) REFERENCES [dbo].[tblGLAccountTemplate] ([intGLAccountTemplateId])
);

