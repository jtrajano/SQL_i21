CREATE TABLE [dbo].[tblSMDefaultValues] (
    [intDefaultValueId] INT IDENTITY (1, 1) NOT NULL,
    [intModuleId] INT NOT NULL,
    [intScreenId] INT NOT NULL,
    [strField] NVARCHAR (50) COLLATE Latin1_General_CI_AS NOT NULL,
    [intValueId] INT NOT NULL,
    [strValue] NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NULL,
    [intConcurrencyId] INT DEFAULT (1) NOT NULL,
    CONSTRAINT [PK_tblSMDefaultValues] PRIMARY KEY CLUSTERED ([intDefaultValueId] ASC),
    CONSTRAINT [FK_tblSMDefaultValues_tblSMModule] FOREIGN KEY ([intModuleId]) REFERENCES [dbo].[tblSMModule] ([intModuleId]),
    CONSTRAINT [FK_tblSMDefaultValues_tblSMScreen] FOREIGN KEY ([intScreenId]) REFERENCES [dbo].[tblSMScreen] ([intScreenId])
);

