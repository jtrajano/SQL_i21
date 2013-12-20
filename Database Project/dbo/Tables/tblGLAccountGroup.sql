CREATE TABLE [dbo].[tblGLAccountGroup] (
    [intAccountGroupID]        INT             IDENTITY (1, 1) NOT NULL,
    [strAccountGroup]          NVARCHAR (50)   COLLATE Latin1_General_CI_AS NOT NULL,
    [strAccountType]           NVARCHAR (20)   COLLATE Latin1_General_CI_AS NULL,
    [intParentGroupID]         INT             NULL,
    [intGroup]                 INT             NULL,
    [intSort]                  INT             NULL,
    [intConcurrencyID]         INT             NULL,
    [intAccountBegin]          INT             NULL,
    [intAccountEnd]            INT             NULL,
    [strAccountGroupNamespace] NVARCHAR (1000) COLLATE Latin1_General_CI_AS NULL,
    CONSTRAINT [PK_GLAccountGroup_AccountGroupID] PRIMARY KEY CLUSTERED ([intAccountGroupID] ASC)
);

