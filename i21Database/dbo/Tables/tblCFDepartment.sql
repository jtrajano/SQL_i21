CREATE TABLE [dbo].[tblCFDepartment] (
    [intDepartmentId]          INT            IDENTITY (1, 1) NOT NULL,
    [intAccountId]             INT            NULL,
    [strDepartment]            NVARCHAR (250) COLLATE Latin1_General_CI_AS NULL,
    [strDepartmentDescription] NVARCHAR (250) COLLATE Latin1_General_CI_AS NULL,
    [intConcurrencyId]         INT            CONSTRAINT [DF_tblCFDepartment_intConcurrencyId] DEFAULT ((1)) NULL,
    CONSTRAINT [PK_tblCFDepartment] PRIMARY KEY CLUSTERED ([intDepartmentId] ASC),
    CONSTRAINT [FK_tblCFDepartment_tblCFAccount] FOREIGN KEY ([intAccountId]) REFERENCES [dbo].[tblCFAccount] ([intAccountId]) ON DELETE CASCADE
);



