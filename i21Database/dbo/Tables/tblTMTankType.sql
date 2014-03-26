CREATE TABLE [dbo].[tblTMTankType] (
    [intConcurrencyId] INT           DEFAULT 1 NOT NULL,
    [intTankTypeId]    INT           IDENTITY (1, 1) NOT NULL,
    [strTankType]      NVARCHAR (50) COLLATE Latin1_General_CI_AS DEFAULT ('') NOT NULL,
    CONSTRAINT [PK_tblTMTankType] PRIMARY KEY CLUSTERED ([intTankTypeId] ASC)
);

