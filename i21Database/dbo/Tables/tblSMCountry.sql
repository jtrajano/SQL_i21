CREATE TABLE [dbo].[tblSMCountry] (
    [intCountryID]     INT            IDENTITY (1, 1) NOT NULL,
    [strCountry]       NVARCHAR (100) COLLATE Latin1_General_CI_AS NOT NULL,
    [strPhoneNumber]   NVARCHAR (40)  COLLATE Latin1_General_CI_AS NULL,
    [strCountryCode]   NVARCHAR (40)  COLLATE Latin1_General_CI_AS NULL,
    [intSort]          INT            NULL,
    [intConcurrencyId] INT            DEFAULT 1 NOT NULL,
    CONSTRAINT [PK_SMCountry_CoutryID] PRIMARY KEY CLUSTERED ([intCountryID] ASC)
);

