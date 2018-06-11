CREATE TABLE [dbo].[tblSMZipCode] (
    [intZipCodeID]     INT             IDENTITY (1, 1) NOT NULL,
    [strZipCode]       NVARCHAR (12)   COLLATE Latin1_General_CI_AS DEFAULT ('') NOT NULL,
    [strState]         NVARCHAR (50)   COLLATE Latin1_General_CI_AS DEFAULT ('') NOT NULL,
    [strCity]          NVARCHAR (50)   COLLATE Latin1_General_CI_AS DEFAULT ('') NOT NULL,
    [strCountry]       NVARCHAR (25)   COLLATE Latin1_General_CI_AS DEFAULT ('') NOT NULL,
	[intCountryID]	   INT			   NULL,
    [dblLatitude]      NUMERIC (18, 6) DEFAULT ((0)) NOT NULL,
    [dblLongitude]     NUMERIC (18, 6) DEFAULT ((0)) NOT NULL,
    [intSort]          INT             DEFAULT ((1)) NOT NULL,
    [intConcurrencyId] INT             DEFAULT 1 NOT NULL,
    CONSTRAINT [PK_tblSMZipCode] PRIMARY KEY CLUSTERED ([strZipCode], [strState], [strCity], [strCountry]),
	CONSTRAINT [FK_tblSMZipCode_tblSMCountry] FOREIGN KEY ([intCountryID]) REFERENCES [tblSMCountry]([intCountryID]) ON DELETE CASCADE
);


GO
