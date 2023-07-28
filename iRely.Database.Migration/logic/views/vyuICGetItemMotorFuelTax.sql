--liquibase formatted sql

-- changeset Von:vyuICGetItemMotorFuelTax.sql.1 runOnChange:true splitStatements:false
-- comment: RK-1234

CREATE OR ALTER VIEW [dbo].[vyuICGetItemMotorFuelTax]
	AS

SELECT ItemMFT.intItemMotorFuelTaxId,
	ItemMFT.intItemId,
	ItemMFT.intTaxAuthorityId,
	TaxAuthority.strTaxAuthorityCode,
	strTaxAuthorityDescription = TaxAuthority.strDescription,
	ItemMFT.intProductCodeId,
	ProductCode.strProductCode,
	strProductDescription = ProductCode.strDescription,
	ProductCode.strProductCodeGroup
FROM tblICItemMotorFuelTax ItemMFT
LEFT JOIN tblTFTaxAuthority TaxAuthority ON TaxAuthority.intTaxAuthorityId = ItemMFT.intTaxAuthorityId
LEFT JOIN tblTFProductCode ProductCode ON ProductCode.intProductCodeId = ItemMFT.intProductCodeId



