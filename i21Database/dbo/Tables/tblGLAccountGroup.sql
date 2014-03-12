CREATE TABLE [dbo].[tblGLAccountGroup] (
    [intAccountGroupId]        INT             IDENTITY (1, 1) NOT NULL,
    [strAccountGroup]          NVARCHAR (50)   COLLATE Latin1_General_CI_AS NOT NULL,
    [strAccountType]           NVARCHAR (20)   COLLATE Latin1_General_CI_AS NULL,
    [intParentGroupId]         INT             NULL,
    [intGroup]                 INT             NULL,
    [intSort]                  INT             NULL,
    [intConcurrencyId]         INT             DEFAULT 1 NOT NULL,
    [intAccountBegin]          INT             NULL,
    [intAccountEnd]            INT             NULL,
    [strAccountGroupNamespace] NVARCHAR (1000) COLLATE Latin1_General_CI_AS NULL,
    CONSTRAINT [PK_GLAccountGroup_AccountGroupId] PRIMARY KEY CLUSTERED ([intAccountGroupId] ASC)
);

