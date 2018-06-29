CREATE TABLE [dbo].[tblEMEntityContactNumber]
(
	[intEntityContactNumberId]       INT             IDENTITY (1, 1) NOT NULL,
    [intContactDetailId]                   INT NOT NULL,
    
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
    [strFormatLocal]                NVARCHAR (50)   COLLATE Latin1_General_CI_AS  NULL,
    [intCountryId]                  INT NULL DEFAULT(0),
	[intAreaCityLength]				INT NOT NULL DEFAULT 3,
    [ysnDisplayCountryCode]         BIT NULL,
    [intConcurrencyId]              INT CONSTRAINT [DF_tblEMEntityContactNumber_intConcurrencyId] DEFAULT ((0)) NOT NULL,

	CONSTRAINT [FK_tblEMEntityContactNumber_tblEMContactDetail] FOREIGN KEY ([intContactDetailId]) REFERENCES [tblEMContactDetail]([intContactDetailId]) ON DELETE CASCADE,
	CONSTRAINT [FK_tblEMEntityContactNumber_tblSMCountry] FOREIGN KEY ([intCountryId]) REFERENCES [tblSMCountry]([intCountryID]) ON DELETE CASCADE,
    CONSTRAINT [PK_tblEMEntityContactNumber] PRIMARY KEY CLUSTERED ([intEntityContactNumberId] ASC)
)

