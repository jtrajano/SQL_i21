CREATE TABLE [dbo].[tblTMRegulatorType] (
    [intConcurrencyID]   INT           CONSTRAINT [DEF_tblTMRegulatorType_intConcurrencyID] DEFAULT ((0)) NULL,
    [intRegulatorTypeID] INT           IDENTITY (1, 1) NOT NULL,
    [strRegulatorType]   NVARCHAR (50) COLLATE Latin1_General_CI_AS CONSTRAINT [DEF_tblTMRegulatorType_strRegulatorType] DEFAULT ('') NOT NULL,
    CONSTRAINT [PK_tblTMRegulatorType] PRIMARY KEY CLUSTERED ([intRegulatorTypeID] ASC)
);

