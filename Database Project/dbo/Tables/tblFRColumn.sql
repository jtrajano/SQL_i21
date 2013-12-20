CREATE TABLE [dbo].[tblFRColumn] (
    [intColumnID]      INT            IDENTITY (1, 1) NOT NULL,
    [intRowID]         INT            NULL,
    [strColumnName]    NVARCHAR (255) COLLATE Latin1_General_CI_AS NULL,
    [strDescription]   NVARCHAR (255) COLLATE Latin1_General_CI_AS NULL,
    [intConcurrencyID] INT            CONSTRAINT [DF__tblFRColu__intCo__276EDEB3] DEFAULT ((1)) NULL,
    CONSTRAINT [PK_tblFRColumn] PRIMARY KEY CLUSTERED ([intColumnID] ASC)
);

