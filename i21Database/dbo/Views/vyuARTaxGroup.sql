CREATE VIEW [dbo].[vyuARTaxGroup]
AS 

SELECT 
	 SMTG.intTaxGroupId
	,SMTG.strDescription
	,SMTG.strTaxGroup
	,ICI.intItemId
FROM tblSMTaxGroup SMTG 
INNER JOIN tblSMTaxGroupCode SMTGC ON SMTG.intTaxGroupId = SMTGC.intTaxGroupId
INNER JOIN tblSMTaxCode SMTC ON SMTGC.intTaxCodeId = SMTC.intTaxCodeId
INNER JOIN tblICCategoryTax ICCT ON SMTC.intTaxClassId = ICCT.intTaxClassId
INNER JOIN tblICItem ICI ON ICCT.intCategoryId = ICI.intCategoryId
GROUP BY
	 SMTG.intTaxGroupId
	,SMTG.strDescription
	,SMTG.strTaxGroup
	,ICI.intItemId