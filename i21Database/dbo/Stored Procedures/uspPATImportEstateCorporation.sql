CREATE PROCEDURE [dbo].[uspPATImportEstateCorporation]
	@checking BIT = 0,
	@total INT = 0 OUTPUT
AS
BEGIN

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

	DECLARE @estateCorporationTable TABLE(
		[intTempId] INT IDENTITY PRIMARY KEY,
		[intCorporateCustomerId] INT,
		[intRefundTypeId] INT
	)
	
	---------------------------- BEGIN - INSERT INTO ESTATE/CORPORATION TEMPORARY TABLE -----------------------
	INSERT INTO @estateCorporationTable(intCorporateCustomerId, intRefundTypeId)
	SELECT EM.intEntityId AS [intCorporateCustomerId], RR.intRefundTypeId AS [intRefundTypeId] FROM vyuEMEntity EM
	OUTER APPLY(
		SELECT DISTINCT paest_corp_cus_no, paest_rfd_type FROM paestmst PAEST
		WHERE EM.strType = 'Customer' AND EM.strEntityNo = LTRIM(RTRIM(PAEST.paest_corp_cus_no COLLATE Latin1_General_CI_AS))
	) PAEST
	INNER JOIN tblPATRefundRate RR
		ON RR.strRefundType = CONVERT(CHAR(5), PAEST.paest_rfd_type)
	---------------------------- END - INSERT INTO ESTATE/CORPORATION TEMPORARY TABLE -----------------------


	------------------- BEGIN - RETURN COUNT TO BE IMPORTED ----------------------------
	IF(@checking = 1)
	BEGIN
		SELECT @total = COUNT(*) FROM @estateCorporationTable tempEC
		LEFT OUTER JOIN tblPATEstateCorporation EC
			ON tempEC.intCorporateCustomerId = EC.intCorporateCustomerId AND tempEC.intRefundTypeId = EC.intRefundTypeId
		WHERE tempEC.intCorporateCustomerId NOT IN (SELECT intCorporateCustomerId FROM tblPATEstateCorporation) AND tempEC.intRefundTypeId NOT IN (SELECT intRefundTypeId FROM tblPATEstateCorporation)

		RETURN @total;
	END
	------------------- END - RETURN COUNT TO BE IMPORTED ----------------------------

	---------------------------- BEGIN - INSERT INTO ESTATE CORPORATION TABLE -----------------------
	INSERT INTO tblPATEstateCorporation(intCorporateCustomerId, intRefundTypeId, intConcurrencyId)
	SELECT tempEC.intCorporateCustomerId, tempEC.intRefundTypeId, 1 FROM @estateCorporationTable tempEC
	LEFT OUTER JOIN tblPATEstateCorporation EC
		ON tempEC.intCorporateCustomerId = EC.intCorporateCustomerId AND tempEC.intRefundTypeId = EC.intRefundTypeId
	WHERE tempEC.intCorporateCustomerId NOT IN (SELECT intCorporateCustomerId FROM tblPATEstateCorporation) AND tempEC.intRefundTypeId NOT IN (SELECT intRefundTypeId FROM tblPATEstateCorporation)
	---------------------------- END - INSERT INTO ESTATE CORPORATION TABLE -----------------------

	
	---------------------------- BEGIN - INSERT INTO ESTATE CORPORATION DETAIL TABLE -----------------------
	INSERT INTO tblPATEstateCorporationDetail(intEstateCorporationId, intCustomerId, dblOwnerPercentage, ysnPaid, dtmPaidDate, dblPaidAmount, strPaidCheckNo, dtmBirthDate, intConcurrencyId)
	SELECT	EC.intEstateCorporationId, 
			EMCorp.intEntityId, 
			PAEST.paest_owner_pct,
			CASE WHEN PAEST.paest_paid_rev_dt > 0 THEN 1 ELSE 0 END AS [ysnPaid],
			(CONVERT (DATETIME, CAST (PAEST.paest_paid_rev_dt AS CHAR (12)), 112)) AS [dtmPaidDate],
			PAEST.paest_paid_amt AS [dblPaidAmount],
			PAEST.paest_paid_chk_no AS [strPaidCheckNo],
			(CONVERT (DATETIME, CAST (PAC.pacus_birth_rev_dt AS CHAR (12)), 112)) AS [dtmBirthDate],
			1
	FROM paestmst PAEST
	INNER JOIN (SELECT intEntityId, strEntityNo FROM vyuEMEntity EM WHERE EM.strType = 'Customer') EM
		ON EM.strEntityNo = LTRIM(RTRIM(PAEST.paest_corp_cus_no COLLATE Latin1_General_CI_AS))
	INNER JOIN tblPATRefundRate RR
		ON RR.strRefundType = CONVERT(CHAR(5), PAEST.paest_rfd_type)
	INNER JOIN tblPATEstateCorporation EC
		ON EC.intCorporateCustomerId = EM.intEntityId AND EC.intRefundTypeId = RR.intRefundTypeId
	INNER JOIN (SELECT intEntityId, strEntityNo FROM vyuEMEntity EM WHERE EM.strType = 'Customer') EMCorp
		ON EMCorp.strEntityNo = LTRIM(RTRIM(PAEST.paest_cus_no COLLATE Latin1_General_CI_AS))
	INNER JOIN (SELECT pacus_birth_rev_dt from pacusmst) PAC
		ON PAC.pacus_birth_rev_dt = PAEST.paest_cus_no
	---------------------------- END - INSERT INTO ESTATE CORPORATION DETAIL TABLE -----------------------
END