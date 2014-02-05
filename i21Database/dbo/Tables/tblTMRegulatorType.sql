CREATE TABLE [dbo].[tblTMRegulatorType] (
    [intConcurrencyId]   INT           DEFAULT 1 NOT NULL,
    [intRegulatorTypeID] INT           IDENTITY (1, 1) NOT NULL,
    [strRegulatorType]   NVARCHAR (50) COLLATE Latin1_General_CI_AS DEFAULT ('') NOT NULL,
    CONSTRAINT [PK_tblTMRegulatorType] PRIMARY KEY CLUSTERED ([intRegulatorTypeID] ASC)
);

