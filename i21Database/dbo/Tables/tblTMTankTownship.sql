CREATE TABLE [dbo].[tblTMTankTownship] (
    [intTankTownshipId] INT           IDENTITY (1, 1) NOT NULL,
    [strTankTownship]   NVARCHAR (50) COLLATE Latin1_General_CI_AS NOT NULL,
    [intConcurrencyId]  INT           DEFAULT 1 NOT NULL,
    CONSTRAINT [PK_tblTMTownShip] PRIMARY KEY CLUSTERED ([intTankTownshipId] ASC)
);

