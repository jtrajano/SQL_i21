CREATE TABLE [dbo].[cstGLAccount] (
    [intId] INT NOT NULL,
    CONSTRAINT [PK_cstGLAccount] PRIMARY KEY CLUSTERED ([intId] ASC),
    CONSTRAINT [FK_cstGLAccount.tblGLAccount_intAccountId] FOREIGN KEY ([intId]) REFERENCES [dbo].[tblGLAccount] ([intAccountId]) ON DELETE CASCADE
);
