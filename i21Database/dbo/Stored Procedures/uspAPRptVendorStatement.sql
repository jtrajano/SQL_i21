CREATE PROCEDURE [dbo].[uspAPRptVendorStatement]
	@xmlParam NVARCHAR(MAX) = NULL
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

BEGIN
	DECLARE @tblAPVendorStatement TABLE (
		imgLogo VARBINARY(MAX) NULL,
		strCompanyName NVARCHAR(1000) NULL,
		strCompanyAddress NVARCHAR(1000) NULL,
		strLocationName NVARCHAR(1000) NULL,
		strCompanyVatNo NVARCHAR(1000) NULL,
		dtmDateFrom DATETIME NULL,
		dtmDateTo DATETIME NULL,
		strFullAddress NVARCHAR(1000) NULL,
		intEntityVendorId INT NULL,
		strVendorId NVARCHAR(1000) NULL,
		strVendorVatNo NVARCHAR(1000) NULL,
		strVendorName NVARCHAR(1000) NULL,
		dtmBillDate DATETIME NULL,
		dtmDueDate DATETIME NULL,
		intBillId INT NULL,
		strBillId NVARCHAR(1000) NULL,
		strTransactionType NVARCHAR(1000) NULL,
		strContractNumber NVARCHAR(1000) NULL,
		strItemDescription NVARCHAR(1000) NULL,
		dblDebit DECIMAL(18, 6) NULL,
		dblCredit DECIMAL(18, 6) NULL,
		strCurrency NVARCHAR(1000) NULL,
		strReportComment NVARCHAR(1000) NULL,
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
			SELECT @strReportComment = [from] FROM @temp_xml_table WHERE [fieldname] = 'strReportComment';
			SELECT @strLocationName = [from] FROM @temp_xml_table WHERE [fieldname] = 'strLocationName';
		END

		SET @dtmDateFrom = ISNULL(@dtmDateFrom, '1/1/1900')
		SET @dtmDateTo = ISNULL(@dtmDateTo, GETDATE())

		-- GET LOGO
		SELECT @imgLogo = imgLogo FROM tblSMLogoPreference WHERE ysnVendorStatement = 1
		IF @imgLogo IS NULL
		BEGIN
			SELECT @imgLogo = imgLogo FROM tblSMLogoPreference WHERE ysnDefault = 1

			IF @imgLogo IS NULL
			BEGIN
				SELECT @imgLogo = imgCompanyLogo FROM tblSMCompanySetup
			END
		END

		-- ASSEMBLE VENDOR STATEMENTS
		INSERT INTO @tblAPVendorStatement
		SELECT @imgLogo,
			   CS.strCompanyName,
			   dbo.fnAPFormatAddress(NULL, NULL, NULL, CS.strAddress, CS.strCity, CS.strState, CS.strZip, CS.strCountry, NULL),
			   CL.strLocationName,
			   CL.strVatNo,
			   @dtmDateFrom,
			   @dtmDateTo,
			   dbo.fnAPFormatAddress(E.strName, NULL, NULL, EL.strAddress, EL.strCity, EL.strState, EL.strZipCode, EL.strCountry, NULL),
			   E.intEntityId,
			   V.strVendorId,
			   ISNULL(EL.strVATNo, V.strVATNo),
			   E.strName,
			   A.dtmBillDate,
			   A.dtmDueDate,
			   A.intBillId,
			   A.strBillId,
			   A.strTransactionType,
			   CH.strContractNumber,
			   A.strDescription,
			   CASE WHEN A.dblTotal > 0 THEN ABS(A.dblTotal) ELSE 0 END,
			   CASE WHEN A.dblTotal < 0 THEN ABS(A.dblTotal) ELSE 0 END,
			   C.strCurrency,
			   @strReportComment,
			   DENSE_RANK() OVER(ORDER BY A.intShipToId, A.intEntityVendorId, A.intCurrencyId)
		FROM (
			--INITIAL BALANCES
			SELECT NULL intBillId, 
			       NULL strBillId, 
				   'Initial Balance' strTransactionType, 
				   @dtmDateFrom dtmBillDate, 
				   @dtmDateTo dtmDueDate, 
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
			SELECT * FROM vyuAPVendorStatement WHERE dtmBillDate BETWEEN @dtmDateFrom AND @dtmDateTo
		) A
		CROSS APPLY tblSMCompanySetup CS
		INNER JOIN tblSMCompanyLocation CL ON CL.intCompanyLocationId = A.intShipToId
		INNER JOIN (tblAPVendor V INNER JOIN tblEMEntity E ON V.intEntityId = E.intEntityId) ON V.intEntityId = A.intEntityVendorId
		INNER JOIN tblEMEntityLocation EL ON EL.intEntityId = A.intEntityVendorId AND ysnDefaultLocation = 1
		LEFT JOIN tblCTContractHeader CH ON CH.intContractHeaderId = A.intContractHeaderId
		INNER JOIN tblSMCurrency C ON C.intCurrencyID = A.intCurrencyId
		WHERE (NULLIF(@strName, '') IS NULL OR @strName = E.strName) AND (NULLIF(@strLocationName, '') IS NULL OR @strLocationName = CL.strLocationName)
		ORDER BY dtmBillDate, intOrder

		SELECT * FROM @tblAPVendorStatement
	END
END