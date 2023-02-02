﻿CREATE PROCEDURE [dbo].[uspAPRptVendorStatement]
	@xmlParam NVARCHAR(MAX) = NULL
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

BEGIN
	DECLARE @tblAPVendorStatement TABLE (
		strLogoType NVARCHAR (10) COLLATE Latin1_General_CI_AS NULL,
		imgLogo VARBINARY(MAX) NULL,
		imgFooter VARBINARY(MAX) NULL,
		strCompanyName NVARCHAR(1000) NULL,
		strCompanyAddress NVARCHAR(1000) NULL,
		strLocationName NVARCHAR(1000) NULL,
		strCompanyVatNo NVARCHAR(1000) NULL,
		dtmDateFrom DATETIME NULL,
		dtmDateTo DATETIME NULL,
		strFullAddress NVARCHAR(1000) NULL,
		intEntityVendorId INT NULL,
		strVendorId NVARCHAR(1000) NULL,
		strVendorAccountNo NVARCHAR(1000) NULL,
		strVendorVatNo NVARCHAR(1000) NULL,
		strVendorName NVARCHAR(1000) NULL,
		dtmBillDate DATETIME NULL,
		dtmDueDate DATETIME NULL,
		intBillId INT NULL,
		strVendorOrderNumber NVARCHAR(1000) NULL,
		strTransactionType NVARCHAR(1000) NULL,
		strContractNumber NVARCHAR(1000) NULL,
		strItemDescription NVARCHAR(1000) NULL,
		dblDebit DECIMAL(18, 6) NULL,
		dblCredit DECIMAL(18, 6) NULL,
		strCurrency NVARCHAR(1000) NULL,
		strReportComment NVARCHAR(1000) NULL,
		intOrder INT NULL,
		intPartitionId INT NULL
	)

	IF ISNULL(@xmlParam,'') = '' 
	BEGIN
		SELECT * FROM @tblAPVendorStatement
	END
	ELSE
	BEGIN
		DECLARE @dtmDateFrom DATETIME
		DECLARE @dtmDateTo DATETIME
		DECLARE @strName NVARCHAR(1000)
		DECLARE @strLocationName NVARCHAR(1000)
		DECLARE @strCurrency NVARCHAR(1000)
		DECLARE @strReportComment NVARCHAR(1000)
		DECLARE @imgLogo VARBINARY(MAX)

		-- Declare XML document Id
		DECLARE @xmlDocumentId AS INT;

		-- Create a table variable to hold the XML data. 		
		DECLARE @temp_xml_table TABLE (
			id INT IDENTITY(1,1)
			,[fieldname] NVARCHAR(50)
			,condition NVARCHAR(20)      
			,[from] NVARCHAR(50)
			,[to] NVARCHAR(50)
			,[join] NVARCHAR(10)
			,[begingroup] NVARCHAR(50)
			,[endgroup] NVARCHAR(50)
			,[datatype] NVARCHAR(50)
		)
		-- Prepare the XML 
		EXEC sp_xml_preparedocument @xmlDocumentId output, @xmlParam

		-- Insert the XML to the xml table. 		
		INSERT INTO @temp_xml_table
		SELECT *
		FROM OPENXML(@xmlDocumentId, 'xmlparam/filters/filter', 2)
		WITH (
			[fieldname] nvarchar(50)
			, condition nvarchar(20)
			, [from] nvarchar(50)
			, [to] nvarchar(50)
			, [join] nvarchar(10)
			, [begingroup] nvarchar(50)
			, [endgroup] nvarchar(50)
			, [datatype] nvarchar(50)
		)

		-- Get XML paramters
		IF EXISTS(SELECT 1 FROM @temp_xml_table)
		BEGIN
			SELECT @dtmDateFrom = [from], @dtmDateTo = [to] FROM @temp_xml_table WHERE [fieldname] = 'dtmDate';
			SELECT @strName = [from] FROM @temp_xml_table WHERE [fieldname] = 'strName';
			SELECT @strLocationName = [from] FROM @temp_xml_table WHERE [fieldname] = 'strLocationName';
			SELECT @strCurrency = [from] FROM @temp_xml_table WHERE [fieldname] = 'strCurrency';
			SELECT @strReportComment = [from] FROM @temp_xml_table WHERE [fieldname] = 'strReportComment';
		END

		SET @dtmDateFrom = ISNULL(@dtmDateFrom, '1/1/1900')
		SET @dtmDateTo = ISNULL(@dtmDateTo, '12/31/2100')

		-- GET LOGO
		 SELECT @imgLogo = dbo.fnSMGetCompanyLogo('Header')

		-- ASSEMBLE VENDOR STATEMENTS
		INSERT INTO @tblAPVendorStatement
		SELECT 
			   CASE WHEN LP.imgLogo IS NOT NULL THEN 'Logo' ELSE 'Attachment' END,
			   ISNULL(LP.imgLogo, @imgLogo),
			   LPF.imgLogo,
			   CS.strCompanyName,
			   dbo.fnAPFormatAddress(NULL, NULL, NULL, CS.strAddress, CS.strCity, CS.strState, CS.strZip, CS.strCountry, NULL),
			   CL.strLocationName,
			   CL.strVatNo,
			   @dtmDateFrom,
			   @dtmDateTo,
			   dbo.fnAPFormatAddress(E.strName, NULL, NULL, EL.strAddress, EL.strCity, EL.strState, EL.strZipCode, EL.strCountry, NULL),
			   E.intEntityId,
			   V.strVendorId,
			   ISNULL(VANL.strVendorAccountNum, V.strVendorAccountNum),
			   ISNULL(EL.strVATNo, V.strVATNo),
			   E.strName,
			   A.dtmBillDate,
			   A.dtmDueDate,
			   A.intBillId,
			   A.strVendorOrderNumber,
			   A.strTransactionType,
			   CH.strContractNumber,
			   A.strDescription,
			   CASE WHEN A.dblTotal < 0 THEN ABS(A.dblTotal) ELSE 0 END,
			   CASE WHEN A.dblTotal > 0 THEN ABS(A.dblTotal) ELSE 0 END,
			   C.strCurrency,
			   @strReportComment,
			   A.intOrder,
			   DENSE_RANK() OVER(ORDER BY A.intShipToId, A.intEntityVendorId, A.intCurrencyId)
		FROM (
			--INITIAL BALANCES
			SELECT NULL intBillId, 
			       NULL strVendorOrderNumber, 
				   'Initial Balance' strTransactionType, 
				   @dtmDateFrom dtmBillDate, 
				   NULL dtmDueDate, 
				   intCurrencyId, 
				   SUM(dblTotal) dblTotal, 
				   NULL intContractHeaderId, 
				   'INITIAL BALANCE' strDescription,
				   intEntityVendorId, 
				   intShipToId,
				   0 intOrder
			FROM (
				SELECT *
				FROM vyuAPVendorStatement
				WHERE dtmBillDate BETWEEN '1/1/1900' AND @dtmDateFrom
			) IB
			GROUP BY intShipToId, intEntityVendorId, intCurrencyId
			UNION ALL
			--DETAILS
			SELECT * FROM vyuAPVendorStatement WHERE dtmBillDate BETWEEN DATEADD(DAY, 1, @dtmDateFrom) AND @dtmDateTo
		) A
		CROSS APPLY tblSMCompanySetup CS
		INNER JOIN tblSMCompanyLocation CL ON CL.intCompanyLocationId = A.intShipToId
		INNER JOIN (tblAPVendor V INNER JOIN tblEMEntity E ON V.intEntityId = E.intEntityId) ON V.intEntityId = A.intEntityVendorId
		LEFT JOIN tblAPVendorAccountNumLocation VANL ON VANL.intEntityVendorId = E.intEntityId AND VANL.intCompanyLocationId = CL.intCompanyLocationId AND VANL.intCurrencyId = A.intCurrencyId
		INNER JOIN tblEMEntityLocation EL ON EL.intEntityId = A.intEntityVendorId AND ysnDefaultLocation = 1
		LEFT JOIN tblCTContractHeader CH ON CH.intContractHeaderId = A.intContractHeaderId
		INNER JOIN tblSMCurrency C ON C.intCurrencyID = A.intCurrencyId
		LEFT JOIN tblSMLogoPreference LP ON LP.intCompanyLocationId = CL.intCompanyLocationId AND (LP.ysnVendorStatement = 1 OR LP.ysnDefault = 1)
		LEFT JOIN tblSMLogoPreferenceFooter LPF ON LPF.intCompanyLocationId = CL.intCompanyLocationId AND (LPF.ysnVendorStatement = 1 OR LPF.ysnDefault = 1)
		WHERE (NULLIF(@strName, '') IS NULL OR @strName = E.strName) 
		      AND (NULLIF(@strLocationName, '') IS NULL OR @strLocationName = CL.strLocationName)
			  AND (NULLIF(@strCurrency, '') IS NULL OR @strCurrency = C.strCurrency)

		SELECT * FROM @tblAPVendorStatement ORDER BY dtmBillDate, intOrder
	END
END