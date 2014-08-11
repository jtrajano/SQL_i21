CREATE TABLE [dbo].[tblTMFillMethod] (
    [intConcurrencyId] INT           DEFAULT 1 NOT NULL,
    [intFillMethodId]  INT           IDENTITY (1, 1) NOT NULL,
    [strFillMethod]    NVARCHAR (50) COLLATE Latin1_General_CI_AS DEFAULT ('') NOT NULL,
    [ysnDefault]       BIT           DEFAULT 1 NOT NULL,
    CONSTRAINT [PK_tblTMFillMethod] PRIMARY KEY CLUSTERED ([intFillMethodId] ASC),
	CONSTRAINT [UQ_tblTMFillMethod_strFillMethod] UNIQUE NONCLUSTERED ([strFillMethod] ASC)
);

