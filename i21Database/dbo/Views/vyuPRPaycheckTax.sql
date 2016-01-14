CREATE VIEW [dbo].[vyuPRPaycheckTax] 
AS
SELECT 
	PCX.intPaycheckId, 
	PCX.intEntityEmployeeId,
	PCX.dtmPayDate,
	strTaxId = (SELECT TOP 1 strTax FROM tblPRTypeTax WHERE intTypeTaxId = PCX.intTypeTaxId),
    PCX.intTypeTaxId,
	PCX.dblTotal,
    dblTotalYTD = (SELECT SUM (dblTotal) FROM 
						(SELECT PC2.intPaycheckId, 
								PC2.intEntityEmployeeId, 
								PC2.dtmPayDate, 
								PCT2.intTypeTaxId, 
								PCT2.dblTotal 
								FROM tblPRPaycheckTax PCT2 
									RIGHT JOIN tblPRPaycheck PC2 
									ON PC2.intPaycheckId = PCT2.intPaycheckId
									AND PCT2.strPaidBy = 'Employee') PCX2
							WHERE PCX2.dtmPayDate <= PCX.dtmPayDate 
								AND YEAR(PCX2.dtmPayDate) = YEAR(PCX.dtmPayDate)
								AND PCX2.intEntityEmployeeId = PCX.intEntityEmployeeId
								AND PCX2.intTypeTaxId = PCX.intTypeTaxId)
 FROM 
	(SELECT PC1.intPaycheckId, 
			PC1.intEntityEmployeeId, 
			PC1.dtmPayDate, 
			PCT1.intTypeTaxId, 
			PCT1.dblTotal 
		FROM tblPRPaycheckTax PCT1
		RIGHT JOIN tblPRPaycheck PC1 
		ON PC1.intPaycheckId = PCT1.intPaycheckId
		AND PCT1.strPaidBy = 'Employee') PCX
 GROUP BY 
	 PCX.intPaycheckId, 
	 PCX.intEntityEmployeeId, 
	 PCX.dtmPayDate, 
	 PCX.intTypeTaxId, 
	 PCX.dblTotal