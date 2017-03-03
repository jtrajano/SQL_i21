CREATE PROCEDURE [dbo].[uspTMGetBudgetLetter]  
	@xmlParam NVARCHAR(MAX) = NULL
AS
BEGIN
	IF(ISNULL(@xmlParam,'') ='')
	BEGIN
		SELECT 
		strCompanyName = ''
		,strCompanyAddress = ''
		,strCompanyCity = ''
		,strCompanyState = ''
		,strCompanyZip = ''
		,strCustomerName = ''
		,strCustomerAddress = ''
		,strCustomerCity = ''
		,strCustomerState = ''
		,strCustomerZip = ''
		,intEntityCustomerId = 0
		,dblBudget = 0.0
		,dtmFirstDueDate = GETDATE()
		,blbLetterBody = CONVERT(VARBINARY(MAX),'')
		,ysnPrintCompanyHeading = 0
	END
	ELSE
	BEGIN
		DECLARE @idoc int
		DECLARE @strCustomerIds NVARCHAR(MAX)
		DECLARE @strLocationIds NVARCHAR(MAX)
		DECLARE @strTermIds NVARCHAR(MAX)
		DECLARE @strFirstPaymentDue DATETIME
		DECLARE @intBudgetLetterId INT
		DECLARE @strWhereClause NVARCHAR(MAX)
		DECLARE @strBudgetLetterId NVARCHAR(10)
		DECLARE @strPrintCompanyHeading NVARCHAR(1)
		DECLARE @query NVARCHAR(MAX)
		
		SET @strWhereClause = ''
		
		EXEC sp_xml_preparedocument @idoc OUTPUT, @xmlParam
		DECLARE @temp_params TABLE ([fieldname] NVARCHAR(50)
					, condition NVARCHAR(20)      
					, [from] NVARCHAR(MAX)
					, [to] NVARCHAR(50)
					, [join] NVARCHAR(10)
					, [begingroup] NVARCHAR(50)
					, [endgroup] NVARCHAR(50) 
					, [datatype] NVARCHAR(50)) 
		INSERT INTO @temp_params
		SELECT *
		FROM OPENXML(@idoc, 'xmlparam/filters/filter',2)
		WITH ([fieldname] NVARCHAR(50)
				, condition NVARCHAR(20)
				, [from] NVARCHAR(MAX)
				, [to] NVARCHAR(50)
				, [join] NVARCHAR(10)
				, [begingroup] NVARCHAR(50)
				, [endgroup] NVARCHAR(50)
				, [datatype] NVARCHAR(50))
			
		---Customer Ids Parameter	
		SELECT @strCustomerIds = [from]
		FROM @temp_params where [fieldname] = 'strCustomerIds'
		
		IF(ISNULL(@strCustomerIds,'') != '')
		BEGIN 
			SET @strWhereClause = ' WHERE C.intEntityId IN (' + @strCustomerIds + ') '
		END
		
		---Location Ids Parameter	
		SELECT @strLocationIds = [from]
		FROM @temp_params where [fieldname] = 'strLocationIds'
		
		IF (ISNULL(@strLocationIds,'') != '')
		BEGIN
			IF (@strWhereClause = '')
			BEGIN
				SET @strWhereClause = ' WHERE G.intLocationId IN (' + @strLocationIds + ') '
			END
			ELSE
			BEGIN
				SET @strWhereClause = @strWhereClause + ' AND G.intLocationId IN (' + @strLocationIds + ') '
			END
		END

		---Term Ids Parameter	
		SELECT @strLocationIds = [from]
		FROM @temp_params where [fieldname] = 'strTermIds'
		
		IF (ISNULL(@strLocationIds,'') != '')
		BEGIN
			IF (@strWhereClause = '')
			BEGIN
				SET @strWhereClause = ' WHERE D.intTermsId IN (' + @strLocationIds + ') '
			END
			ELSE
			BEGIN
				SET @strWhereClause = @strWhereClause + ' AND D.intTermsId IN (' + @strLocationIds + ') '
			END
		END
		
		---@dtmFirstPaymentDue
		SELECT @strFirstPaymentDue = [from] 
		FROM @temp_params where [fieldname] = 'dtmFirstPaymentDue'
		
		---@dtmFirstPaymentDue
		SELECT @intBudgetLetterId = [from]
		FROM @temp_params where [fieldname] = 'intBudgetLetterId'
		
		SET @strBudgetLetterId = CAST(@intBudgetLetterId AS NVARCHAR(10))
		
		---@ysnPrintCompanyHeading
		SELECT @strPrintCompanyHeading = ISNULL([from],'0')
		FROM @temp_params where [fieldname] = 'ysnPrintCompanyHeading'

		SET @strPrintCompanyHeading = ISNULL(@strPrintCompanyHeading,'0')
		
		EXEC (
		'
		SELECT DISTINCT
			strCompanyName = A.strCompanyName
			,strCompanyAddress = A.strAddress
			,strCompanyCity = A.strCity
			,strCompanyState = A.strState 
			,strCompanyZip = A.strZip
			,strCustomerName = C.strName
			,strCustomerAddress = D.strAddress
			,strCustomerCity = D.strCity
			,strCustomerState = D.strState
			,strCustomerZip = D.strZipCode
			,intEntityCustomerId = B.intEntityCustomerId
			,dblBudget = B.dblMonthlyBudget
			,dtmFirstDueDate = CAST(''' + @strFirstPaymentDue + ''' AS DATETIME)
			,blbLetterBody = E.blbMessage 
			,ysnPrintCompanyHeading = ' + @strPrintCompanyHeading  + '
			,intDeliveryTermId = D.intTermsId
		FROM (SELECT TOP 1 * FROM tblSMCompanySetup) A, tblARCustomer B
		INNER JOIN tblEMEntity C
			ON B.intEntityCustomerId = C.intEntityId
		INNER JOIN tblTMCustomer F
			ON C.intEntityId = F.intCustomerNumber
		INNER JOIN tblTMSite G
			ON F.intCustomerID = G.intCustomerID
		INNER JOIN tblARCustomer D
			ON C.intEntityId = D.intEntityCustomerId
		,(SELECT TOP 1 * FROM tblSMLetter WHERE intLetterId = ' + @strBudgetLetterId + ') E
		' + @strWhereClause
		)
	END
END
GO