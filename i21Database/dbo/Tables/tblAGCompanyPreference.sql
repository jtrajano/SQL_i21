CREATE TABLE [dbo].[tblAGCompanyPreference] (
    [intCompanyPreferenceId]            INT             IDENTITY (1, 1) NOT NULL,
    [intConcurrencyId]                  INT             CONSTRAINT [DF_tblAGCompanyPreference_intConcurrencyId] DEFAULT 1 NOT NULL, 
    [intVolumeUOMId] INT NULL, 
    [intAreaUOMId] INT NULL, 
    [intWeightUOMId] INT NULL
);







