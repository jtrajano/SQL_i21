CREATE VIEW [dbo].[vyuICGetCategoryTax]
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