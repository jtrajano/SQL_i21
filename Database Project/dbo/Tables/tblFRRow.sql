CREATE TABLE [dbo].[tblFRRow] (
    [intRowID]         INT            IDENTITY (1, 1) NOT NULL,
    [strRowName]       NVARCHAR (255) COLLATE Latin1_General_CI_AS NULL,
    [strDescription]   NVARCHAR (255) COLLATE Latin1_General_CI_AS NULL,
    [intMapID]         INT            NULL,
    [intConcurrencyID] INT            CONSTRAINT [DF__tblFRRow__intCon__4B7734FF] DEFAULT ((1)) NULL,
    CONSTRAINT [PK_tblFRRow] PRIMARY KEY CLUSTERED ([intRowID] ASC)
);

