CREATE TABLE [dbo].[tblTMTankType] (
    [intConcurrencyID] INT           CONSTRAINT [DEF_tblTMTankType_intConcurrencyID] DEFAULT ((0)) NULL,
    [intTankTypeID]    INT           IDENTITY (1, 1) NOT NULL,
    [strTankType]      NVARCHAR (50) COLLATE Latin1_General_CI_AS CONSTRAINT [DEF_tblTMTankType_strTankType] DEFAULT ('') NOT NULL,
    CONSTRAINT [PK_tblTMTankType] PRIMARY KEY CLUSTERED ([intTankTypeID] ASC)
);

