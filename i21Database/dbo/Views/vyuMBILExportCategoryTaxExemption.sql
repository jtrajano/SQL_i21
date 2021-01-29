CREATE VIEW [dbo].[vyuMBILExportCategoryTaxExemption]  
AS  


SELECT * FROM 
	(
		SELECT SMTGCE.*, SMTGC.[intTaxCodeId],SMTGC.[intTaxGroupId]
		FROM
			tblSMTaxGroupCodeCategoryExemption SMTGCE
		INNER JOIN
			tblSMTaxGroupCode SMTGC
				ON SMTGCE.[intTaxGroupCodeId] = SMTGC.[intTaxGroupCodeId]
		INNER JOIN
			tblSMTaxGroup SMTG
				ON SMTGC.[intTaxGroupId] = SMTG.[intTaxGroupId] 
		INNER JOIN
			tblSMTaxCode SMTC
				ON SMTGC.[intTaxCodeId] = SMTC.[intTaxCodeId] 
		INNER JOIN
			tblICCategory ICC
				ON SMTGCE.[intCategoryId] = ICC.[intCategoryId]
	) tblCategory
