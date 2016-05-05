CREATE TABLE [dbo].[tblEMEntityPhoneNumber] (
    [intEntityPhoneNumberId]        INT             IDENTITY (1, 1) NOT NULL,
    [intEntityId]                   INT NOT NULL,
    
    [strPhone]                      NVARCHAR (50)   COLLATE Latin1_General_CI_AS  NULL,
    [strPhoneCountry]               NVARCHAR (50)   COLLATE Latin1_General_CI_AS  NULL,
    [strPhoneArea]                  NVARCHAR (50)   COLLATE Latin1_General_CI_AS  NULL,
    [strPhoneLocal]                 NVARCHAR (50)   COLLATE Latin1_General_CI_AS  NULL,
    [strPhoneExtension]             NVARCHAR (50)   COLLATE Latin1_General_CI_AS  NULL,
    [strPhoneLookUp]                NVARCHAR (50)   COLLATE Latin1_General_CI_AS  NULL,
    [strMaskLocal]                  NVARCHAR (50)   COLLATE Latin1_General_CI_AS  NULL,
    [strMaskArea]                   NVARCHAR (50)   COLLATE Latin1_General_CI_AS  NULL,
    [strFormatCountry]              NVARCHAR (50)   COLLATE Latin1_General_CI_AS  NULL,
    [strFormatArea]                 NVARCHAR (50)   COLLATE Latin1_General_CI_AS  NULL,
    [strFormatLocal]                   NVARCHAR (50)   COLLATE Latin1_General_CI_AS  NULL,
    [ysnDisplayCountryCode]         BIT NULL,
    [intConcurrencyId]              INT CONSTRAINT [DF_tblEMEntityPhoneNumber_intConcurrencyId] DEFAULT ((0)) NOT NULL,

	CONSTRAINT [FK_tblEMEntityPhoneNumber_tblEMEntity] FOREIGN KEY ([intEntityId]) REFERENCES [tblEMEntity]([intEntityId]) ON DELETE CASCADE,
    CONSTRAINT [PK_tblEMEntityPhoneNumber] PRIMARY KEY CLUSTERED ([intEntityPhoneNumberId] ASC)
);







