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
		DECLARE @strStartMonth NVARCHAR(10)
		DECLARE @ysnIsOriginIntegration BIT
		

		SELECT TOP 1 @ysnIsOriginIntegration = ysnUseOriginIntegration FROM tblTMPreferenceCompany

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
			IF(@ysnIsOriginIntegration = 1)
			BEGIN
				SET @strWhereClause = ' WHERE B.A4GLIdentity IN (' + @strCustomerIds + ') '
			END
			ELSE
			BEGIN
				SET @strWhereClause = ' WHERE B.intEntityId IN (' + @strCustomerIds + ') '
			END
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
		SELECT @strTermIds = [from]
		FROM @temp_params where [fieldname] = 'strTermsIds'
		
		IF (ISNULL(@strTermIds,'') != '')
		BEGIN
			IF (@strWhereClause = '')
			BEGIN
				IF(@ysnIsOriginIntegration = 1)
				BEGIN
					SET @strWhereClause = ' WHERE (ISNULL(G.intDeliveryTermID,I.A4GLIdentity)) IN (' + @strTermIds + ') '
				END
				ELSE
				BEGIN
					SET @strWhereClause = ' WHERE (ISNULL(G.intDeliveryTermID,B.intTermsId)) IN (' + @strTermIds + ') '
				END
				
			END
			ELSE
			BEGIN
				IF(@ysnIsOriginIntegration = 1)
				BEGIN
					SET @strWhereClause = @strWhereClause + ' AND (ISNULL(G.intDeliveryTermID,I.A4GLIdentity)) IN (' + @strTermIds + ') '
				END
				ELSE
				BEGIN
					SET @strWhereClause = @strWhereClause + ' AND (ISNULL(G.intDeliveryTermID,,B.intTermsId)) IN (' + @strTermIds + ') '
				END
				
			END
		END

		--Start Month
		SELECT @strStartMonth = [from]
		FROM @temp_params where [fieldname] = 'intStartMonth'
		
		IF (ISNULL(@strStartMonth,'') != '')
		BEGIN
			IF (@strWhereClause = '')
			BEGIN
				IF(@ysnIsOriginIntegration = 1)
				BEGIN
					SET @strWhereClause = ' WHERE B.vwcus_budget_beg_mm = ' + @strStartMonth 
				END
				ELSE
				BEGIN
					SET @strWhereClause = ' WHERE MONTH(B.dtmBudgetBeginDate) = ' + @strStartMonth 
				END
				
			END
			ELSE
			BEGIN
				IF(@ysnIsOriginIntegration = 1)
				BEGIN
					SET @strWhereClause = @strWhereClause + ' AND B.vwcus_budget_beg_mm =' + @strStartMonth 
				END
				ELSE
				BEGIN
					SET @strWhereClause = @strWhereClause + ' AND MONTH(B.dtmBudgetBeginDate) =' + @strStartMonth 
				END
				
			END
		END

		--Budget Amount checking
		IF (@strWhereClause = '')
		BEGIN
			IF(@ysnIsOriginIntegration = 1)
			BEGIN
				SET @strWhereClause = ' WHERE ISNULL(B.vwcus_budget_amt,0) <> 0 ' 
			END
			ELSE
			BEGIN
				SET @strWhereClause = ' WHERE ISNULL(B.dblMonthlyBudget,0) <> 0 ' 
			END
			
		END
		ELSE
		BEGIN
			IF(@ysnIsOriginIntegration = 1)
			BEGIN
				SET @strWhereClause = @strWhereClause + ' AND ISNULL(B.vwcus_budget_amt,0) <> 0'
			END
			ELSE
			BEGIN
				SET @strWhereClause = @strWhereClause + ' AND ISNULL(B.dblMonthlyBudget,0) <> 0'
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
		

		IF(@ysnIsOriginIntegration = 1)
		BEGIN
			EXEC (
				'
				SELECT DISTINCT
					strCompanyName = A.strCompanyName
					,strCompanyAddress = A.strAddress
					,strCompanyCity = A.strCity
					,strCompanyState = A.strState 
					,strCompanyZip = A.strZip
					,strCustomerName = B.strFullName
					,strCustomerAddress = RTRIM(B.strFormattedAddress)
					,strCustomerCity = RTRIM(B.vwcus_city)
					,strCustomerState = RTRIM(B.vwcus_state)
					,strCustomerZip = RTRIM(B.vwcus_zip)
					,intEntityCustomerId = B.A4GLIdentity
					,dblBudget = B.vwcus_budget_amt
					,dtmFirstDueDate = CAST(''' + @strFirstPaymentDue + ''' AS DATETIME)
					,blbLetterBody = H.blbMessage 
					,ysnPrintCompanyHeading = ' + @strPrintCompanyHeading  + '
					,intDeliveryTermId = I.A4GLIdentity
				FROM (SELECT TOP 1 * FROM tblSMCompanySetup) A, 
				vwcusmst B
				INNER JOIN tblTMCustomer F
					ON B.A4GLIdentity = F.intCustomerNumber
				INNER JOIN tblTMSite G
					ON F.intCustomerID = G.intCustomerID
				INNER JOIN vwtrmmst I
					ON B.vwcus_terms_cd = I.vwtrm_key_n
				,(SELECT TOP 1 * FROM tblSMLetter WHERE intLetterId = ' + @strBudgetLetterId + ') H
				' + @strWhereClause
				)
		END
		ELSE
		BEGIN
			EXEC (
				'
				SELECT DISTINCT
					strCompanyName = A.strCompanyName
					,strCompanyAddress = A.strAddress
					,strCompanyCity = A.strCity
					,strCompanyState = A.strState 
					,strCompanyZip = A.strZip
					,strCustomerName = C.strName
					,strCustomerAddress = E.strAddress
					,strCustomerCity = E.strCity
					,strCustomerState = E.strState
					,strCustomerZip = E.strZipCode
					,intEntityCustomerId = B.intEntityId
					,dblBudget = B.dblMonthlyBudget
					,dtmFirstDueDate = CAST(''' + @strFirstPaymentDue + ''' AS DATETIME)
					,blbLetterBody = H.blbMessage 
					,ysnPrintCompanyHeading = ' + @strPrintCompanyHeading  + '
					,intDeliveryTermId = B.intTermsId
				FROM (SELECT TOP 1 * FROM tblSMCompanySetup) A, tblARCustomer B
				INNER JOIN tblEMEntity C
					ON B.intEntityId = C.intEntityId
				INNER JOIN tblTMCustomer F
					ON C.intEntityId = F.intCustomerNumber	
				INNER JOIN tblTMSite G
					ON F.intCustomerID = G.intCustomerID
				INNER JOIN tblEMEntityLocation E
					ON C.intEntityId = E.intEntityId
						AND ysnDefaultLocation = 1
				,(SELECT TOP 1 * FROM tblSMLetter WHERE intLetterId = ' + @strBudgetLetterId + ') H
				' + @strWhereClause
				)
		END
		
	END
END
GO