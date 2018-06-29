CREATE TABLE [dbo].[tblCFCityCountyCode] (
    [intCityCountyCodeId]  INT            NULL,
    [intStateCodeId]       INT            NULL,
    [intCountyCode]        INT            NULL,
    [intCityCode]          INT            NULL,
    [strCountyDescription] NVARCHAR (250) COLLATE Latin1_General_CI_AS NULL,
    [strCityDescription]   NVARCHAR (250) COLLATE Latin1_General_CI_AS NULL,
    [strTaxAuth1]          NVARCHAR (250) COLLATE Latin1_General_CI_AS NULL,
    [strTaxAuth2]          NVARCHAR (250) COLLATE Latin1_General_CI_AS NULL,
    [intConcurrencyId]     INT            CONSTRAINT [DF_tblCFCityCountyCode_intConcurrencyId] DEFAULT ((1)) NULL
);

