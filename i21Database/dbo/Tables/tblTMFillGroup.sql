CREATE TABLE [dbo].[tblTMFillGroup] (
    [intFillGroupId]   INT           IDENTITY (1, 1) NOT NULL,
    [strFillGroupCode] NVARCHAR (6)  COLLATE Latin1_General_CI_AS NOT NULL,
    [strDescription]   NVARCHAR (50) COLLATE Latin1_General_CI_AS NULL,
    [ysnActive]        BIT           NULL,
    [intConcurrencyId] INT           DEFAULT 1 NOT NULL,
    CONSTRAINT [PK_tblTMFillGroup] PRIMARY KEY CLUSTERED ([intFillGroupId] ASC),
    CONSTRAINT [UQ_tblTMFillGroup_strFillGroupCode] UNIQUE NONCLUSTERED ([strFillGroupCode] ASC)
);

