CREATE TABLE [dbo].[tblTMMeterType] (
    [intConcurrencyID]    INT             CONSTRAINT [DEF_tblTMMeterType_intConcurrencyID] DEFAULT ((0)) NULL,
    [intMeterTypeID]      INT             IDENTITY (1, 1) NOT NULL,
    [strMeterType]        NVARCHAR (50)   COLLATE Latin1_General_CI_AS CONSTRAINT [DEF_tblTMMeterType_strMeterType] DEFAULT ('') NOT NULL,
    [dblConversionFactor] NUMERIC (18, 8) CONSTRAINT [DEF_tblTMMeterType_dblConversionFactor] DEFAULT ((0)) NULL,
    [ysnDefault]          BIT             CONSTRAINT [DEF_tblTMMeterType_ysnDefault] DEFAULT ((0)) NULL,
    CONSTRAINT [PK_tblTMMeterType] PRIMARY KEY CLUSTERED ([intMeterTypeID] ASC)
);

