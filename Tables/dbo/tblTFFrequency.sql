CREATE TABLE [dbo].[tblTFFrequency] (
    [intFrequencyId]   INT            IDENTITY (1, 1) NOT NULL,
    [strFrequency]     NVARCHAR (250) COLLATE Latin1_General_CI_AS NULL,
    [intConcurrencyId] INT            CONSTRAINT [DF_tblTFFrequency_intConcurrencyId] DEFAULT ((1)) NULL,
    CONSTRAINT [PK_tblTFFrequency] PRIMARY KEY CLUSTERED ([intFrequencyId] ASC)
);

