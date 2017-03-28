CREATE PROCEDURE [dbo].[uspARSearchStatementsCustomer]
(
	@strStatementFormat NVARCHAR(50)
	,@asOfDate NVARCHAR(50)
)
AS

DECLARE @tmpstrStatementFormat	NVARCHAR(50)
		,@tmpasOfDate			NVARCHAR(50)
		,@xmlParam				NVARCHAR(MAX) = NULL
		,@strQuery				NVARCHAR(MAX)
  
DECLARE @temp_statement_table TABLE (
	 [strReferenceNumber]			NVARCHAR(100) COLLATE Latin1_General_CI_AS
	,[intEntityCustomerId]			INT
	,[strTransactionType]			NVARCHAR(100) COLLATE Latin1_General_CI_AS	
	,[dtmDueDate]					DATETIME
	,[dtmDate]						DATETIME
	,[intDaysDue]					INT
	,[dblTotalAmount]				NUMERIC(18,6)
	,[dblAmountPaid]				NUMERIC(18,6)
	,[dblAmountDue]					NUMERIC(18,6)
	,[dblPastDue]					NUMERIC(18,6)
	,[dblMonthlyBudget]				NUMERIC(18,6)
	,[dblRunningBalance]			NUMERIC(18,6)
	,[strCustomerNumber]			NVARCHAR(100) COLLATE Latin1_General_CI_AS
	,[strName]						NVARCHAR(100) COLLATE Latin1_General_CI_AS
	,[strBOLNumber]					NVARCHAR(100) COLLATE Latin1_General_CI_AS
	,[dblCreditLimit]				NUMERIC(18,6)
	,[strAccountStatusCode]			NVARCHAR(5)	  COLLATE Latin1_General_CI_AS
	,[strLocationName]				NVARCHAR(100) COLLATE Latin1_General_CI_AS
	,[strFullAddress]				NVARCHAR(MAX) COLLATE Latin1_General_CI_AS
	,[strStatementFooterComment]	NVARCHAR(MAX) COLLATE Latin1_General_CI_AS	
	,[strCompanyName]				NVARCHAR(MAX) COLLATE Latin1_General_CI_AS
	,[strCompanyAddress]			NVARCHAR(MAX) COLLATE Latin1_General_CI_AS
	,[dblARBalance]					NUMERIC(18,6)  
	,[blbLogo]						VARBINARY (MAX)
	,[dblCreditAvailable]			NUMERIC(18,6)
	,[dbl0Days]						NUMERIC(18,6)
	,[dbl10Days]					NUMERIC(18,6)
	,[dbl30Days]					NUMERIC(18,6)
	,[dbl60Days]					NUMERIC(18,6)
	,[dbl90Days]					NUMERIC(18,6)
	,[dbl91Days]					NUMERIC(18,6)
	,[dblCredits]					NUMERIC(18,6)
	,[dblPrepayments]				NUMERIC(18,6)
)

SET @tmpstrStatementFormat = @strStatementFormat
SET @tmpasOfDate = @asOfDate

IF (@tmpstrStatementFormat = 'Open Item')
BEGIN
	SET @xmlParam =N'<?xml version="1.0" encoding="utf-16"?><xmlparam><filters><filter><fieldname>dtmAsOfDate</fieldname><condition>As Of</condition><from>1900-01-01</from><to>'
	SET @xmlParam = @xmlParam + @tmpasOfDate + '</to><join>AND</join><begingroup /><endgroup /><datatype>DateTime</datatype></filter>'	
	SET @xmlParam = @xmlParam + '<filter><fieldname>strStatementFormat</fieldname><condition>Equal To</condition><from>Open Item</from><join>AND</join><begingroup /><endgroup /><datatype>String</datatype></filter><filter><fieldname>ysnPrintZeroBalance</fieldname><condition>Equal To</condition><from>False</from><join>AND</join><begingroup /><endgroup /><datatype>Boolean</datatype></filter><filter><fieldname>ysnPrintCreditBalance</fieldname><condition>Equal To</condition><from>True</from><join>AND</join><begingroup /><endgroup /><datatype>Boolean</datatype></filter><filter><fieldname>ysnIncludeBudget</fieldname><condition>Equal To</condition><from>False</from><join>AND</join><begingroup /><endgroup /><datatype>Boolean</datatype></filter><filter><fieldname>ysnPrintOnlyPastDue</fieldname><condition>Equal To</condition><from>True</from><join>AND</join><begingroup /><endgroup /><datatype>Boolean</datatype></filter></filters></xmlparam>'
	SET @strQuery  = 'EXEC uspARCustomerStatementReport ' + '''' +  @xmlParam + ''''	 	
	EXEC(@strQuery)
END

IF (@tmpstrStatementFormat = 'Balance Forward')
BEGIN
	SET @xmlParam =N'<?xml version="1.0" encoding="utf-16"?><xmlparam><filters><filter><fieldname>dtmAsOfDate</fieldname><condition>As Of</condition><from>1900-01-01</from><to>'
	SET @xmlParam = @xmlParam + @tmpasOfDate + '</to><join>AND</join><begingroup /><endgroup /><datatype>DateTime</datatype></filter>'	
	SET @xmlParam = @xmlParam + '<filter><fieldname>strStatementFormat</fieldname><condition>Equal To</condition><from>Balance Forward</from><join>AND</join><begingroup /><endgroup /><datatype>String</datatype></filter><filter><fieldname>ysnPrintZeroBalance</fieldname><condition>Equal To</condition><from>False</from><join>AND</join><begingroup /><endgroup /><datatype>Boolean</datatype></filter><filter><fieldname>ysnPrintCreditBalance</fieldname><condition>Equal To</condition><from>True</from><join>AND</join><begingroup /><endgroup /><datatype>Boolean</datatype></filter><filter><fieldname>ysnIncludeBudget</fieldname><condition>Equal To</condition><from>False</from><join>AND</join><begingroup /><endgroup /><datatype>Boolean</datatype></filter><filter><fieldname>ysnPrintOnlyPastDue</fieldname><condition>Equal To</condition><from>True</from><join>AND</join><begingroup /><endgroup /><datatype>Boolean</datatype></filter></filters></xmlparam>'
	SET @strQuery  = 'EXEC uspARCustomerStatementBalanceForwardReport ' + '''' +  @xmlParam + ''''	 
	EXEC(@strQuery)			 
END

IF (@tmpstrStatementFormat = 'Payment Activity')
BEGIN
	SET @xmlParam =N'<?xml version="1.0" encoding="utf-16"?><xmlparam><filters><filter><fieldname>dtmAsOfDate</fieldname><condition>As Of</condition><from>1900-01-01</from><to>'
	SET @xmlParam = @xmlParam + @tmpasOfDate + '</to><join>AND</join><begingroup /><endgroup /><datatype>DateTime</datatype></filter>'	
	SET @xmlParam = @xmlParam + '<filter><fieldname>strStatementFormat</fieldname><condition>Equal To</condition><from>Payment Activity</from><join>AND</join><begingroup /><endgroup /><datatype>String</datatype></filter><filter><fieldname>ysnPrintZeroBalance</fieldname><condition>Equal To</condition><from>False</from><join>AND</join><begingroup /><endgroup /><datatype>Boolean</datatype></filter><filter><fieldname>ysnPrintCreditBalance</fieldname><condition>Equal To</condition><from>True</from><join>AND</join><begingroup /><endgroup /><datatype>Boolean</datatype></filter><filter><fieldname>ysnIncludeBudget</fieldname><condition>Equal To</condition><from>False</from><join>AND</join><begingroup /><endgroup /><datatype>Boolean</datatype></filter><filter><fieldname>ysnPrintOnlyPastDue</fieldname><condition>Equal To</condition><from>True</from><join>AND</join><begingroup /><endgroup /><datatype>Boolean</datatype></filter></filters></xmlparam>'
	SET @strQuery  = 'EXEC uspARCustomerStatementPaymentActivityReport ' + '''' +  @xmlParam + ''''	 		
	EXEC(@strQuery)		
END

IF (@tmpstrStatementFormat = 'Running Balance')
BEGIN
	SET @xmlParam =N'<?xml version="1.0" encoding="utf-16"?><xmlparam><filters><filter><fieldname>dtmAsOfDate</fieldname><condition>As Of</condition><from>1900-01-01</from><to>'
	SET @xmlParam = @xmlParam + @tmpasOfDate + '</to><join>AND</join><begingroup /><endgroup /><datatype>DateTime</datatype></filter>'	
	SET @xmlParam = @xmlParam + '<filter><fieldname>strStatementFormat</fieldname><condition>Equal To</condition><from>Running Balance</from><join>AND</join><begingroup /><endgroup /><datatype>String</datatype></filter><filter><fieldname>ysnPrintZeroBalance</fieldname><condition>Equal To</condition><from>False</from><join>AND</join><begingroup /><endgroup /><datatype>Boolean</datatype></filter><filter><fieldname>ysnPrintCreditBalance</fieldname><condition>Equal To</condition><from>True</from><join>AND</join><begingroup /><endgroup /><datatype>Boolean</datatype></filter><filter><fieldname>ysnIncludeBudget</fieldname><condition>Equal To</condition><from>False</from><join>AND</join><begingroup /><endgroup /><datatype>Boolean</datatype></filter><filter><fieldname>ysnPrintOnlyPastDue</fieldname><condition>Equal To</condition><from>True</from><join>AND</join><begingroup /><endgroup /><datatype>Boolean</datatype></filter></filters></xmlparam>'
	SET @strQuery  = 'EXEC uspARCustomerStatementReport ' + '''' +  @xmlParam + ''''	
	EXEC(@strQuery)				
END

EXEC [uspARGetStatementsCustomer]