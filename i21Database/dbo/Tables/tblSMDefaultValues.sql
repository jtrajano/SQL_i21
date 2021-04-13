CREATE TABLE [dbo].[tblSMDefaultValues] (
    [intDefaultValueId] INT IDENTITY (1, 1) NOT NULL,
    [strModule] NVARCHAR (50) COLLATE Latin1_General_CI_AS NOT NULL,
    [strScreen] NVARCHAR (50) COLLATE Latin1_General_CI_AS NOT NULL,
    [strField] NVARCHAR (50) COLLATE Latin1_General_CI_AS NOT NULL,
    [strValue] NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NULL,
    [intConcurrencyId] INT DEFAULT (1) NOT NULL,
    CONSTRAINT [PK_tblSMDefaultValues] PRIMARY KEY CLUSTERED ([intDefaultValueId] ASC)
);

