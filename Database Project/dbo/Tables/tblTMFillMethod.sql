CREATE TABLE [dbo].[tblTMFillMethod] (
    [intConcurrencyID] INT           CONSTRAINT [DEF_tblTMFillMethod_intConcurrencyID] DEFAULT ((0)) NULL,
    [intFillMethodID]  INT           IDENTITY (1, 1) NOT NULL,
    [strFillMethod]    NVARCHAR (50) COLLATE Latin1_General_CI_AS CONSTRAINT [DEF_tblTMFillMethod_strFillMethod] DEFAULT ('') NOT NULL,
    [ysnDefault]       BIT           CONSTRAINT [DEF_tblTMFillMethod_ysnDefault] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_tblTMFillMethod] PRIMARY KEY CLUSTERED ([intFillMethodID] ASC)
);

