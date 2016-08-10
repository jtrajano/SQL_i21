CREATE TABLE [dbo].[tblCFProductAuthDetail] (
    [intProductAuthDetailId] INT            IDENTITY (1, 1) NOT NULL,
    [intProductAuthId]       INT            NULL,
    [strNetworkProductCode]  NVARCHAR (50)  COLLATE Latin1_General_CI_AS NULL,
    [strDescription]         NVARCHAR (200) COLLATE Latin1_General_CI_AS NULL,
    [intConcurrencyId]       INT            CONSTRAINT [DF_tblCFProductAuth_intConcurrencyId] DEFAULT ((1)) NULL,
    CONSTRAINT [PK_tblCFProductAuth] PRIMARY KEY CLUSTERED ([intProductAuthDetailId] ASC),
    CONSTRAINT [FK_tblCFProductAuthDetail_tblCFProductAuth] FOREIGN KEY ([intProductAuthId]) REFERENCES [dbo].[tblCFProductAuth] ([intProductAuthId])
);

