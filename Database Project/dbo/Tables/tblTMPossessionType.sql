CREATE TABLE [dbo].[tblTMPossessionType] (
    [intConcurrencyID]    INT           CONSTRAINT [DEF_tblTMPossessionType_intConcurrencyID] DEFAULT ((0)) NULL,
    [intPossessionTypeID] INT           IDENTITY (1, 1) NOT NULL,
    [strPossessionType]   NVARCHAR (50) COLLATE Latin1_General_CI_AS CONSTRAINT [DEF_tblTMPossessionType_strPossessionType] DEFAULT ('') NOT NULL,
    CONSTRAINT [PK_tblTMPossessionType] PRIMARY KEY CLUSTERED ([intPossessionTypeID] ASC)
);

