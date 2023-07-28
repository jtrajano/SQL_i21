--liquibase formatted sql

-- changeset Von:vyuICGetCategoryTax.sql.1 runOnChange:true splitStatements:false
-- comment: RK-1234

CREATE OR ALTER VIEW [dbo].[vyuICGetCategoryTax]
	AS 

SELECT CategoryTax.intCategoryTaxId
	, Category.intCategoryId
	, strCategory = Category.strCategoryCode
	, Tax.intTaxClassId
	, Tax.strTaxClass
	, ysnActive
FROM tblICCategoryTax CategoryTax
	LEFT JOIN tblICCategory Category ON Category.intCategoryId = CategoryTax.intCategoryId
	LEFT JOIN tblSMTaxClass Tax ON Tax.intTaxClassId = CategoryTax.intTaxClassId



