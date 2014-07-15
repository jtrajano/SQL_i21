CREATE TABLE [dbo].[tblTMRegulatorType] (
    [intConcurrencyId]   INT           DEFAULT ((1)) NOT NULL,
    [intRegulatorTypeId] INT           IDENTITY (1, 1) NOT NULL,
    [strRegulatorType]   NVARCHAR (50) COLLATE Latin1_General_CI_AS DEFAULT ('') NOT NULL,
    [ysnDefault]         BIT           DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_tblTMRegulatorType] PRIMARY KEY CLUSTERED ([intRegulatorTypeId] ASC),
    CONSTRAINT [IX_tblTMRegulatorType] UNIQUE NONCLUSTERED ([strRegulatorType] ASC)
);



