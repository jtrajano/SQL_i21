CREATE TABLE [dbo].[tblFRHeader] (
    [intHeaderID]      INT            IDENTITY (1, 1) NOT NULL,
    [strDescription]   NVARCHAR (250) COLLATE Latin1_General_CI_AS NULL,
    [strHeaderName]    NVARCHAR (250) COLLATE Latin1_General_CI_AS NULL,
    [strHeaderType]    NVARCHAR (50)  COLLATE Latin1_General_CI_AS NULL,
    [intColumnID]      INT            NULL,
    [intConcurrencyID] INT            CONSTRAINT [DF__tblFRHead__intCo__40058253] DEFAULT ((1)) NULL,
    CONSTRAINT [PK_tblFRHeader_1] PRIMARY KEY CLUSTERED ([intHeaderID] ASC)
);

