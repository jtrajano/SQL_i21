CREATE PROCEDURE [dbo].[uspPATLetters]  
	@xmlParam NVARCHAR(MAX) = NULL
AS
BEGIN
	DECLARE @idoc						INT
			, @strCustomerIds			NVARCHAR(MAX)		
			, @intLetterId				INT
			, @strLetterId				NVARCHAR(10)  
			 ,@strLetterName			NVARCHAR(MAX)				
			, @query					NVARCHAR(MAX)
			, @intEntityCustomerId		INT
			, @blb						VARBINARY(MAX)
			, @originalMsgInHTML		VARCHAR(MAX)	
			, @filterValue				VARCHAR(MAX)

	EXEC sp_xml_preparedocument @idoc OUTPUT, @xmlParam;

	DECLARE @temp_params TABLE (
			[fieldname]			NVARCHAR(50)	COLLATE Latin1_General_CI_AS
			, [condition]		NVARCHAR(20)	COLLATE Latin1_General_CI_AS    
			, [from]			NVARCHAR(MAX)
			, [to]				NVARCHAR(50)	COLLATE Latin1_General_CI_AS
			, [join]			NVARCHAR(10)	COLLATE Latin1_General_CI_AS
			, [begingroup]		NVARCHAR(50)	COLLATE Latin1_General_CI_AS
			, [endgroup]		NVARCHAR(50)	COLLATE Latin1_General_CI_AS
			, [datatype]		NVARCHAR(100)	COLLATE Latin1_General_CI_AS
	);

	DECLARE @SelectedCustomer TABLE  (
		intEntityId		INT
	);

	INSERT INTO 
		@temp_params
	SELECT *
	FROM OPENXML(@idoc, 'xmlparam/filters/filter', 2)
	WITH (	
			[fieldname]		NVARCHAR(50)	COLLATE Latin1_General_CI_AS
			, [condition]	NVARCHAR(20)	COLLATE Latin1_General_CI_AS
			, [from]		NVARCHAR(MAX)	COLLATE Latin1_General_CI_AS
			, [to]			NVARCHAR(50)	COLLATE Latin1_General_CI_AS
			, [join]		NVARCHAR(10)	COLLATE Latin1_General_CI_AS
			, [begingroup]	NVARCHAR(50)	COLLATE Latin1_General_CI_AS
			, [endgroup]	NVARCHAR(50)	COLLATE Latin1_General_CI_AS
			, [datatype]	NVARCHAR(50)	COLLATE Latin1_General_CI_AS
			);

	--Get Entities
	SELECT 
		@strCustomerIds = [from]		
	FROM 
		@temp_params 
	WHERE 
		[fieldname] = 'intEntityId' 

	SET @strCustomerIds = REPLACE (@strCustomerIds, '|^|', ',');
	SET @strCustomerIds = REVERSE(SUBSTRING(REVERSE(@strCustomerIds),PATINDEX('%[A-Za-z0-9]%',REVERSE(@strCustomerIds)),LEN(@strCustomerIds) - (PATINDEX('%[A-Za-z0-9]%',REVERSE(@strCustomerIds)) - 1)	) );
	-- End

	-- Get Letter
	SELECT 
		@intLetterId = [from]
	FROM 
		@temp_params 
	WHERE [fieldname] = 'intLetterId'
	
	SELECT @strLetterName = strName FROM tblSMLetter WHERE intLetterId = @intLetterId
	-- End

	-- Get Blob Message
	DECLARE @strMessage VARCHAR(MAX)
	SELECT
		@strMessage = CONVERT(VARCHAR(MAX), blbMessage)
	FROM
		tblSMLetter
	WHERE
		intLetterId  = @intLetterId

	SELECT 
		@blb = blbMessage 
	FROM 
		tblSMLetter 
	WHERE 
		intLetterId = @intLetterId
	-- End

	DECLARE @strCompanyName			NVARCHAR(100),
		@strCompanyAddress		NVARCHAR(100),
		@strCompanyPhone		NVARCHAR(50)

	SELECT TOP 1 
		@strCompanyName		= @strCompanyName, 
		@strCompanyAddress	= [dbo].fnARFormatCustomerAddress(NULL, NULL, NULL, strAddress, strCity, strState, strZip, strCountry, NULL, NULL),
		@strCompanyPhone	= strPhone
	FROM tblSMCompanySetup

	INSERT INTO 
		@SelectedCustomer
	SELECT intID 
		FROM [dbo].[fnGetRowsFromDelimitedValues](@strCustomerIds)

	SELECT
		SC.*
		, blbMessage			= CONVERT(varbinary(max),CONVERT(VARCHAR(MAX),(REPLACE(@strMessage,'[EntityName]', CusContact.strName))))
		, msg = @strMessage
		, strCompanyName		= @strCompanyName
		, strCompanyAddress		= @strCompanyAddress
		, strCompanyPhone		= @strCompanyPhone
		, strCustomerAddress	= [dbo].fnARFormatCustomerAddress(NULL, NULL, Cus.strName, Cus.strBillToAddress, Cus.strBillToCity, Cus.strBillToState, Cus.strBillToZipCode, Cus.strBillToCountry, NULL, NULL)
								  + CHAR(13) + (SELECT ISNULL(strAccountNumber,'') FROM tblARCustomer WHERE [intEntityId] = SC.intEntityId)
		, strAccountNumber		= (SELECT strAccountNumber FROM tblARCustomer WHERE [intEntityId] = SC.intEntityId)
	FROM
		@SelectedCustomer SC
	INNER JOIN 
		(
			SELECT 
				[intEntityId], 
				strBillToAddress, 
				strBillToCity, 
				strBillToCountry, 
				strBillToLocationName, 
				strBillToState, 
				strBillToZipCode, 
				intTermsId, 
				strName
			FROM 
			(
			SELECT 
				ARC.[intEntityId]
				, strCustomerNumber					= ISNULL(ARC.strCustomerNumber, EME.strEntityNo)
				, EME.strName
				, BillToLoc.strBillToAddress
				, BillToLoc.strBillToCity
				, BillToLoc.strBillToCountry
				, BillToLoc.strBillToLocationName
				, BillToLoc.strBillToState
				, BillToLoc.strBillToZipCode
				, ARC.intTermsId
				, ARC.strTerm
			FROM 
				(SELECT 
					[intEntityId], 
					strCustomerNumber, 
					intBillToId,
					intTermsId,
					strTerm	
								
				FROM 
					tblARCustomer ARC
				INNER JOIN (
							SELECT 
								intTermID,
								strTerm 
							FROM 
								tblSMTerm) SMT ON ARC.intTermsId = SMT.intTermID ) ARC
				INNER JOIN (
							SELECT 
								intEntityId, 
								strEntityNo, 
								strName								 
							FROM 
								tblEMEntity
							) EME ON ARC.[intEntityId] = EME.intEntityId
				LEFT JOIN (
							SELECT 
								Loc.intEntityId, 
								Loc.intEntityLocationId,
								Loc.intTermsId,
								SMT.strTerm																
							FROM 
								tblEMEntityLocation Loc
							INNER JOIN (
										SELECT 
											intTermID,
											strTerm 
										FROM 
											tblSMTerm) SMT ON Loc.intTermsId = SMT.intTermID
							WHERE Loc.ysnDefaultLocation = 1
							) EMEL ON ARC.[intEntityId] = EMEL.intEntityId
				LEFT JOIN (
							SELECT 
								intEntityId, 
								intEntityLocationId,
								strBillToAddress		= strAddress,
								strBillToCity			= strCity,
								strBillToLocationName	= strLocationName,
								strBillToCountry		= strCountry,
								strBillToState			= strState,
								strBillToZipCode		= strZipCode
							FROM 
								tblEMEntityLocation
							) BillToLoc ON ARC.[intEntityId] = BillToLoc.intEntityId AND ARC.intBillToId = BillToLoc.intEntityLocationId
			) Cus
		) Cus ON SC.intEntityId = Cus.[intEntityId] 
		INNER JOIN vyuARCustomerContacts CusContact
			ON CusContact.intEntityId = SC.intEntityId AND CusContact.ysnDefaultContact = 1

END