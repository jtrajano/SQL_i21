﻿CREATE TABLE [dbo].[tblTFTaxAuthorityCustomerLicense]
(
	[intTaxAuthorityCustomerLicenseId] INT IDENTITY NOT NULL, 
    [intTaxAuthorityId] INT NOT NULL, 
    [intEntityId] INT NOT NULL, 
    [strLicenseNumber] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
    [intConcurrencyId] INT NULL DEFAULT ((1)), 
    CONSTRAINT [PK_tblTFTaxAuthorityCustomerLicense] PRIMARY KEY ([intTaxAuthorityCustomerLicenseId]), 
    CONSTRAINT [FK_tblTFTaxAuthorityCustomerLicense_tblTFTaxAuthority] FOREIGN KEY ([intTaxAuthorityId]) REFERENCES [tblTFTaxAuthority]([intTaxAuthorityId]) ON DELETE CASCADE, 
    CONSTRAINT [FK_tblTFTaxAuthorityCustomerLicense_tblARCustomer] FOREIGN KEY ([intEntityId]) REFERENCES [tblARCustomer]([intEntityId]), 
    CONSTRAINT [AK_tblTFTaxAuthorityCustomerLicense] UNIQUE ([intTaxAuthorityId], [intEntityId]) 
)
