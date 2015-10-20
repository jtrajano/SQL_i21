CREATE VIEW [dbo].[vyuAP1099MISC]
AS

WITH MISC1099 (
	strEmployerAddress
	,strCompanyName
	,strEIN
	,strFederalTaxId
	,strAddress
	,strVendorCompanyName
	,strVendorId
	,strZip
	,strCity
	,strState
	,strZipSate
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
	,ysnDirectSales
	,intEntityVendorId
)
AS
(
	SELECT
		  strEmployerAddress = [dbo].[fnAPFormatAddress](NULL
										, NULL
										, NULL
										, B.strAddress
										, B.strCity
										, B.strState
										, B.strZip
										, B.strCountry
										, B.strPhone)
		, B.strCompanyName
		, strEIN = B.strFederalTaxID
		, A.strFederalTaxId
		, A.strAddress
		, A.strVendorCompanyName
		, A.strVendorId
		, A.strZip
		, A.strCity
		, A.strState
		, A.strZipState
		, A.intYear
		, CASE WHEN SUM(A.dblBoatsProceeds) >= C.dbl1099MISCFishing THEN SUM(dblBoatsProceeds) ELSE 0 END AS dblBoatsProceeds
		, CASE WHEN SUM(A.dblCropInsurance) >= C.dbl1099MISCCrop THEN SUM(dblCropInsurance) ELSE 0 END AS dblCropInsurance
		, CASE WHEN SUM(A.dblFederalIncome) >= C.dbl1099MISCFederalIncome THEN SUM(dblFederalIncome) ELSE 0 END AS dblFederalIncome
		, CASE WHEN SUM(A.dblGrossProceedsAtty) >= C.dbl1099MISCGrossProceeds THEN SUM(dblGrossProceedsAtty) ELSE 0 END AS dblGrossProceedsAtty
		, CASE WHEN SUM(A.dblMedicalPayments) >= C.dbl1099MISCMedical THEN SUM(dblMedicalPayments) ELSE 0 END AS dblMedicalPayments
		, CASE WHEN SUM(A.dblNonemployeeCompensation) >= C.dbl1099MISCNonemployee THEN SUM(dblNonemployeeCompensation) ELSE 0 END AS dblNonemployeeCompensation
		, CASE WHEN SUM(A.dblOtherIncome) >= C.dbl1099MISCOtherIncome THEN SUM(dblOtherIncome) ELSE 0 END AS dblOtherIncome
		, CASE WHEN SUM(A.dblParachutePayments) >= C.dbl1099MISCExcessGolden THEN SUM(dblParachutePayments) ELSE 0 END AS dblParachutePayments
		, CASE WHEN SUM(A.dblRents) >= C.dbl1099MISCRent THEN SUM(dblRents) ELSE 0 END AS dblRents
		, CASE WHEN SUM(A.dblRoyalties) >= C.dbl1099MISCRoyalties THEN SUM(dblRoyalties) ELSE 0 END AS dblRoyalties
		, CASE WHEN SUM(A.dblSubstitutePayments) >= C.dbl1099MISCSubstitute THEN SUM(dblSubstitutePayments) ELSE 0 END AS dblSubstitutePayments
		, CASE WHEN SUM(A.dblDirectSales) >= C.dbl1099MISCDirecSales THEN SUM(A.dblDirectSales) ELSE 0 END AS dblDirectSales
		, CAST(CASE WHEN SUM(A.dblDirectSales) >= C.dbl1099MISCDirecSales THEN 1 ELSE 0 END AS BIT) AS ysnDirectSales
		, A.intEntityVendorId
	FROM vyuAP1099 A
	CROSS JOIN tblSMCompanySetup B
	CROSS JOIN tblAP1099Threshold C
	WHERE A.int1099Form = 1
	GROUP BY intYear, intEntityVendorId
	,B.strCompanyName, B.strAddress, B.strCity, B.strState, B.strZip, B.strCountry, B.strPhone, B.strFederalTaxID
	,C.dbl1099MISCFishing, C.dbl1099MISCCrop ,C.dbl1099MISCDirecSales, C.dbl1099MISCFederalIncome, C.dbl1099MISCGrossProceeds
	,C.dbl1099MISCMedical, C.dbl1099MISCNonemployee, C.dbl1099MISCOtherIncome, C.dbl1099MISCExcessGolden, C.dbl1099MISCRent
	,C.dbl1099MISCRoyalties, C.dbl1099MISCSubstitute, dblDirectSales
	, A.strAddress
	, A.strVendorCompanyName
	, A.strVendorId
	, A.strZip
	, A.strFederalTaxId
	, A.strCity
	, A.strState
	, A.strZipState
)

SELECT
	*
	,SUM(dblBoatsProceeds
		+ dblCropInsurance
		+ dblFederalIncome
		+ dblDirectSales
		+ dblGrossProceedsAtty
		+ dblMedicalPayments
		+ dblNonemployeeCompensation
		+ dblOtherIncome
		+ dblParachutePayments
		+ dblRents
		+ dblRoyalties
		+ dblSubstitutePayments) AS dblTotalPayment
FROM MISC1099 A
GROUP BY intEntityVendorId
	,strEmployerAddress
	,strCompanyName
	,strEIN
	,strFederalTaxId
	,strAddress
	,strVendorCompanyName
	,strVendorId
	,strZip
	,strCity
	,strState
	,strZipSate
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
	,ysnDirectSales
HAVING SUM(dblBoatsProceeds
		+ dblCropInsurance
		+ dblDirectSales
		+ dblFederalIncome
		+ dblGrossProceedsAtty
		+ dblMedicalPayments
		+ dblNonemployeeCompensation
		+ dblOtherIncome
		+ dblParachutePayments
		+ dblRents
		+ dblRoyalties
		+ dblSubstitutePayments) > 0