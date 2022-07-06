CREATE TABLE [dbo].[tblCTVendorCertification]
(
	[intCertificationProgramId] [int] IDENTITY(1,1) NOT NULL,
	[intCertificationId] [int] NOT NULL,
	[intEntityId] [int] NOT NULL,
	[strCertificationId] nvarchar(50) NULL,
	[dtmValidFrom] datetime NOT NULL,
	[dtmValidTo] datetime NOT NULL,
	[intSort] [int] NULL,
	[intCreatedByUserId] [int] NULL,
	[dtmDateCreated] datetime NOT NULL default getdate(),
	[dtmLastUpdatedDate] datetime NULL,
	[intUpdatedById] [int] NULL,
	[intConcurrencyId] [int] NOT NULL DEFAULT (1),
	CONSTRAINT [PK_tblCTVendorCertification_intCertificationVendorId] PRIMARY KEY CLUSTERED  ([intCertificationProgramId] ASC),
	CONSTRAINT [FK_tblCTVendorCertification_tblICCertification] FOREIGN KEY([intCertificationId]) REFERENCES [dbo].[tblICCertification] ([intCertificationId]),
	CONSTRAINT [FK_tblCTVendorCertification_tblEMEntity] FOREIGN KEY([intEntityId]) REFERENCES [dbo].tblEMEntity ([intEntityId])
)
