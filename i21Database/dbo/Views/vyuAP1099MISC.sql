CREATE VIEW [dbo].[vyuAP1099MISC]
AS

WITH MISC1099 (
	strEmployerAddress
	,strCompanyName
	,strEIN
	,strFederalTaxId
	,strAddress
	,strVendorCompanyName
	,strPayeeName
	,strVendorId
	,strZip
	,strCity
	,strState
	,strZipState
	,intYear
	,dblBoatsProceeds
	,dblCropInsurance
	,dblFederalIncome
	,dblGrossProceedsAtty
	,dblMedicalPayments
	,dblNonemployeeCompensation
	,dblOtherIncome
	,dblParachutePayments
	,dblRents
	,dblRoyalties
	,dblSubstitutePayments
	,dblDirectSales
	,strDirectSales
	,intEntityVendorId
)
AS
(
	SELECT
		  strEmployerAddress = [dbo].[fnAPFormatAddress](NULL
										, B.strCompanyName
										, NULL
										, B.strAddress
										, B.strCity
										, B.strState
										, +' '+B.strZip
										, B.strCountry
										, B.strPhone) COLLATE Latin1_General_CI_AS
		, B.strCompanyName
		, strEIN = B.strEin--B.strFederalTaxID
		, A.strFederalTaxId
		, A.strAddress
		, A.strVendorCompanyName
		, A.strPayeeName
		, A.strVendorId
		, A.strZip
		, A.strCity
		, A.strState
		, A.strZipState
		, A.intYear
		, CASE WHEN SUM(A.dblBoatsProceeds) >= MIN(C.dbl1099MISCFishing) AND SUM(A.dblBoatsProceeds) != 0 THEN SUM(dblBoatsProceeds) ELSE NULL END AS dblBoatsProceeds
		, CASE WHEN SUM(A.dblCropInsurance) >= MIN(C.dbl1099MISCCrop) AND SUM(A.dblCropInsurance) != 0 THEN SUM(dblCropInsurance) ELSE NULL END AS dblCropInsurance
		, CASE WHEN SUM(A.dblFederalIncome) >= MIN(C.dbl1099MISCFederalIncome) AND SUM(A.dblFederalIncome) != 0 THEN SUM(dblFederalIncome) ELSE NULL END AS dblFederalIncome
		, CASE WHEN SUM(A.dblGrossProceedsAtty) >= MIN(C.dbl1099MISCGrossProceeds) AND SUM(A.dblGrossProceedsAtty) != 0 THEN SUM(dblGrossProceedsAtty) ELSE NULL END AS dblGrossProceedsAtty
		, CASE WHEN SUM(A.dblMedicalPayments) >= MIN(C.dbl1099MISCMedical) AND SUM(A.dblMedicalPayments) != 0 THEN SUM(dblMedicalPayments) ELSE NULL END AS dblMedicalPayments
		, CASE WHEN SUM(A.dblNonemployeeCompensation) >= MIN(C.dbl1099MISCNonemployee) AND SUM(A.dblNonemployeeCompensation) != 0 THEN SUM(dblNonemployeeCompensation) ELSE NULL END AS dblNonemployeeCompensation
		, CASE WHEN SUM(A.dblOtherIncome) >= MIN(C.dbl1099MISCOtherIncome) AND SUM(A.dblOtherIncome) != 0 THEN SUM(dblOtherIncome) ELSE NULL END AS dblOtherIncome
		, CASE WHEN SUM(A.dblParachutePayments) >= MIN(C.dbl1099MISCExcessGolden) AND SUM(A.dblParachutePayments) != 0 THEN SUM(dblParachutePayments) ELSE NULL END AS dblParachutePayments
		, CASE WHEN SUM(A.dblRents) >= MIN(C.dbl1099MISCRent) AND SUM(A.dblRents) != 0 THEN SUM(dblRents) ELSE NULL END AS dblRents
		, CASE WHEN SUM(A.dblRoyalties) >= MIN(C.dbl1099MISCRoyalties) AND SUM(A.dblRoyalties) != 0 THEN SUM(dblRoyalties) ELSE NULL END AS dblRoyalties
		, CASE WHEN SUM(A.dblSubstitutePayments) >= MIN(C.dbl1099MISCSubstitute) AND SUM(A.dblSubstitutePayments) != 0 THEN SUM(dblSubstitutePayments) ELSE NULL END AS dblSubstitutePayments
		, CASE WHEN SUM(A.dblDirectSales) >= MIN(C.dbl1099MISCDirecSales) AND SUM(A.dblDirectSales) != 0 THEN SUM(A.dblDirectSales) ELSE NULL END AS dblDirectSales
		, (CASE WHEN SUM(A.dblDirectSales) >= MIN(C.dbl1099MISCDirecSales) AND SUM(A.dblDirectSales) != 0 THEN 'X' ELSE NULL END) COLLATE Latin1_General_CI_AS AS strDirectSales
		, A.[intEntityId]
	FROM vyuAP1099 A
	CROSS JOIN tblSMCompanySetup B
	CROSS JOIN tblAP1099Threshold C
	WHERE A.int1099Form = 1
	GROUP BY intYear, [intEntityId]
	,B.strCompanyName, B.strAddress, B.strCity, B.strState, B.strZip, B.strCountry, B.strPhone, B.strEin--B.strFederalTaxID
	, A.strAddress
	, A.strVendorCompanyName
	, A.strPayeeName
	, A.strVendorId
	, A.strZip
	, A.strFederalTaxId
	, A.strCity
	, A.strState
	, A.strZipState
)

SELECT
	*
	,SUM(ISNULL(dblBoatsProceeds,0)
		+ ISNULL(dblCropInsurance,0)
		+ ISNULL(dblFederalIncome,0)
		+ ISNULL(dblDirectSales,0)
		+ ISNULL(dblGrossProceedsAtty,0)
		+ ISNULL(dblMedicalPayments,0)
		+ ISNULL(dblNonemployeeCompensation,0)
		+ ISNULL(dblOtherIncome,0)
		+ ISNULL(dblParachutePayments,0)
		+ ISNULL(dblRents,0)
		+ ISNULL(dblRoyalties,0)
		+ ISNULL(dblSubstitutePayments,0)) AS dblTotalPayment
FROM MISC1099 A
GROUP BY intEntityVendorId
	,strEmployerAddress
	,strCompanyName
	,strEIN
	,strFederalTaxId
	,strAddress
	,strVendorCompanyName
	,strPayeeName
	,strVendorId
	,strZip
	,strCity
	,strState
	,strZipState
	,intYear
	,dblBoatsProceeds
	,dblCropInsurance
	,dblDirectSales
	,dblFederalIncome
	,dblGrossProceedsAtty
	,dblMedicalPayments
	,dblNonemployeeCompensation
	,dblOtherIncome
	,dblParachutePayments
	,dblRents
	,dblRoyalties
	,dblSubstitutePayments
	,strDirectSales
HAVING SUM(ISNULL(dblBoatsProceeds,0)
		+ ISNULL(dblCropInsurance,0)
		+ ISNULL(dblDirectSales,0)
		+ ISNULL(dblFederalIncome,0)
		+ ISNULL(dblGrossProceedsAtty,0)
		+ ISNULL(dblMedicalPayments,0)
		+ ISNULL(dblNonemployeeCompensation,0)
		+ ISNULL(dblOtherIncome,0)
		+ ISNULL(dblParachutePayments,0)
		+ ISNULL(dblRents,0)
		+ ISNULL(dblRoyalties,0)
		+ ISNULL(dblSubstitutePayments,0)) > 0
GO