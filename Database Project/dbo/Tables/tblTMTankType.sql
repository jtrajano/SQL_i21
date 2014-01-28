CREATE TABLE [dbo].[tblTMTankType] (
    [intConcurrencyId] INT           DEFAULT 1 NOT NULL,
    [intTankTypeID]    INT           IDENTITY (1, 1) NOT NULL,
    [strTankType]      NVARCHAR (50) COLLATE Latin1_General_CI_AS DEFAULT ('') NOT NULL,
    CONSTRAINT [PK_tblTMTankType] PRIMARY KEY CLUSTERED ([intTankTypeID] ASC)
);

