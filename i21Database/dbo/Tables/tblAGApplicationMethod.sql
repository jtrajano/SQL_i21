CREATE TABLE [dbo].[tblAGApplicationMethod]
(
    [intApplicationMethodId] INT IDENTITY(1,1) NOT NULL,
    [strApplicationMethod] NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL,
    [strDescription] NVARCHAR(250) COLLATE Latin1_General_CI_AS NULL,
    [intApplicationTypeId] INT NULL,
    [strWorkInstruction] NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL,
    [intConcurrencyId] INT NOT NULL DEFAULT(0),
    CONSTRAINT [PK_dbo.tblAGApplicationMethod_intApplicationMethodId] PRIMARY KEY CLUSTERED ([intApplicationMethodId] ASC)
)






