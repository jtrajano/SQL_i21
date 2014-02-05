CREATE TABLE [dbo].[tblTMPossessionType] (
    [intConcurrencyId]    INT           DEFAULT 1 NOT NULL,
    [intPossessionTypeID] INT           IDENTITY (1, 1) NOT NULL,
    [strPossessionType]   NVARCHAR (50) COLLATE Latin1_General_CI_AS DEFAULT ('') NOT NULL,
    CONSTRAINT [PK_tblTMPossessionType] PRIMARY KEY CLUSTERED ([intPossessionTypeID] ASC)
);

