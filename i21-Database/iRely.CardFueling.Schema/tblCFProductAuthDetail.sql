CREATE TABLE [dbo].[tblCFProductAuthDetail] (
    [intProductAuthDetailId] INT IDENTITY (1, 1) NOT NULL,
    [intProductAuthId]       INT NULL,
    [intItemId]              INT NULL,
    [intConcurrencyId]       INT CONSTRAINT [DF_tblCFProductAuth_intConcurrencyId] DEFAULT ((1)) NULL,
    CONSTRAINT [PK_tblCFProductAuth] PRIMARY KEY CLUSTERED ([intProductAuthDetailId] ASC),
    CONSTRAINT [FK_tblCFProductAuthDetail_tblCFItem] FOREIGN KEY ([intItemId]) REFERENCES [dbo].[tblCFItem] ([intItemId]),
    CONSTRAINT [FK_tblCFProductAuthDetail_tblCFProductAuth] FOREIGN KEY ([intProductAuthId]) REFERENCES [dbo].[tblCFProductAuth] ([intProductAuthId]) ON DELETE CASCADE	
);



