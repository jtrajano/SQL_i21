CREATE TABLE [dbo].[tblTMRegulatorType] (
    [intConcurrencyId]   INT           DEFAULT 1 NOT NULL,
    [intRegulatorTypeId] INT           IDENTITY (1, 1) NOT NULL,
    [strRegulatorType]   NVARCHAR (50) COLLATE Latin1_General_CI_AS DEFAULT ('') NOT NULL,
    [ysnDefault] BIT NOT NULL DEFAULT 0, 
    CONSTRAINT [PK_tblTMRegulatorType] PRIMARY KEY CLUSTERED ([intRegulatorTypeId] ASC)
);

