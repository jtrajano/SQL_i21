CREATE TABLE [dbo].[tblSMDocumentMaintenance]
(
	[intDocumentMaintenanceId]			INT NOT NULL IDENTITY, 
    [strCode]		NVARCHAR(10)  COLLATE Latin1_General_CI_AS NULL, 
    [strTitle]		NVARCHAR(50)  COLLATE Latin1_General_CI_AS NOT NULL, 
	[intCompanyLocationId]  INT NULL,
	[intLineOfBusinessId]	INT NULL,
    [intEntityCustomerId]	INT NULL, 
	[strSource]				NVARCHAR(25)  COLLATE Latin1_General_CI_AS NULL,
	[strType]			    NVARCHAR(25)  COLLATE Latin1_General_CI_AS NULL, 
	[ysnCopyAll]			BIT NOT NULL DEFAULT 0,
    [intConcurrencyId]		INT NOT NULL DEFAULT ((0)),
	CONSTRAINT [PK_tblSMDocumentMaintenance_intDocumentId] PRIMARY KEY CLUSTERED ([intDocumentMaintenanceId] ASC),
	CONSTRAINT [FK_tblSMDocumentMaintenance_tblARCustomer_intEntityCustomerId] FOREIGN KEY ([intEntityCustomerId]) REFERENCES [dbo].[tblARCustomer] ([intEntityId]),
	CONSTRAINT [FK_tblSMDocumentMaintenance_tblSMCompanyLocation_intCompanyLocationId] FOREIGN KEY ([intCompanyLocationId]) REFERENCES [dbo].[tblSMCompanyLocation] ([intCompanyLocationId]), 
    CONSTRAINT [FK_tblSMDocumentMaintenance_tblSMLineOfBusiness] FOREIGN KEY ([intLineOfBusinessId]) REFERENCES [tblSMLineOfBusiness]([intLineOfBusinessId]),
    CONSTRAINT [AK_tblSMDocumentMaintenance_strCode] UNIQUE ([strCode])
)

GO