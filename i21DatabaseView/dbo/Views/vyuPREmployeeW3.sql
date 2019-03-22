CREATE VIEW [dbo].[vyuPREmployeeW3]
AS
SELECT
	intYear					 = vyuPREmployeeW2.intYear
	,ysnThirdPartySickPay	 = CAST(MAX(CAST(ysnThirdPartySickPay AS INT)) AS BIT) /* box b */
	,intW2Count				 = COUNT(1) /* box C */
	,dblAdjustedGross		 = SUM(dblAdjustedGross) /* box 1 */
	,dblFIT					 = SUM(dblFIT) /* box 2 */
	,dblTaxableSS			 = SUM(dblTaxableSS) /* box 3 */
	,dblSSTax				 = SUM(dblSSTax) /* box 4 */
	,dblTaxableMed			 = SUM(dblTaxableMed) /* box 5 */
	,dblMedTax				 = SUM(dblMedTax) /* box 6 */
	,dblTaxableSSTips		 = SUM(dblTaxableSSTips) /* box 7 */
	,dblAllocatedTips		 = SUM(dblAllocatedTips) /* box 8 */
	,dblDependentCare		 = SUM(dblDependentCare) /* box 10 */
	,dblNonqualifiedPlans	 = SUM(dblNonqualifiedPlans) /* box 11 */
	,dblDefferedCompensation = ISNULL(tblDefferedCompensation.dblDefferedCompensation, 0) /* box 12a */
	,dblThirdPartyIncomeTax	 = 0 /* box 14 (not implemented yet) */
	,dblTaxableState		 = SUM(dblTaxableState) /* box 16 */
	,dblStateTax			 = SUM(dblStateTax) /* box 17 */
	,dblTaxableLocal		 = SUM(dblTaxableLocal) /* box 18 */
	,dblLocalTax			 = SUM(dblLocalTax) + SUM(ISNULL(dblLocalTax2, 0)) /* box 19 */
FROM
	vyuPREmployeeW2 
	LEFT JOIN
	(SELECT 
		intYear, 
		dblDefferedCompensation = SUM(dblBoxAmount) 
	 FROM 
		(SELECT intYear, dblBoxAmount = SUM(dblBox12a) FROM vyuPREmployeeW2 WHERE strBox12a IN ('D', 'E', 'F', 'G', 'H', 'S', 'Y', 'AA', 'BB', 'EE') GROUP BY intYear
		 UNION ALL SELECT intYear, dblBoxAmount = SUM(dblBox12b) FROM vyuPREmployeeW2 WHERE strBox12b IN ('D', 'E', 'F', 'G', 'H', 'S', 'Y', 'AA', 'BB', 'EE') GROUP BY intYear
		 UNION ALL SELECT intYear, dblBoxAmount = SUM(dblBox12c) FROM vyuPREmployeeW2 WHERE strBox12c IN ('D', 'E', 'F', 'G', 'H', 'S', 'Y', 'AA', 'BB', 'EE') GROUP BY intYear
		 UNION ALL SELECT intYear, dblBoxAmount = SUM(dblBox12d) FROM vyuPREmployeeW2 WHERE strBox12d IN ('D', 'E', 'F', 'G', 'H', 'S', 'Y', 'AA', 'BB', 'EE') GROUP BY intYear
		 ) BoxAmounts
	 GROUP BY intYear
	 ) tblDefferedCompensation
	ON vyuPREmployeeW2.intYear = tblDefferedCompensation.intYear
GROUP BY
	vyuPREmployeeW2.intYear
	,tblDefferedCompensation.dblDefferedCompensation

GO