CREATE PROCEDURE [dbo].[uspARSearchStatementsCustomer]
(
	@strStatementFormat		NVARCHAR(50)  
	,@strAsOfDate			NVARCHAR(50) 
	,@strTransactionDate	NVARCHAR(50) 
	,@ysnDetailedFormat		BIT	= 0
)
AS

DECLARE @tmpstrStatementFormat	NVARCHAR(50)
		,@tmpDate				NVARCHAR(50)
		,@xmlParam				NVARCHAR(MAX) = NULL
		,@strQuery				NVARCHAR(MAX)
		,@strQuery1				NVARCHAR(MAX)
		,@tmpysnDetailedFormat	BIT
  
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
SET @tmpysnDetailedFormat = @ysnDetailedFormat

IF (@tmpysnDetailedFormat = 1)
BEGIN
	SET @tmpDate = @strAsOfDate
END
ELSE
BEGIN
	SET @tmpDate = @strTransactionDate
END

IF (@tmpstrStatementFormat = 'Open Item')
BEGIN
	SET @xmlParam =N'<?xml version="1.0" encoding="utf-16"?><xmlparam><filters><filter><fieldname>dtmAsOfDate</fieldname><condition>As Of</condition><from>1900-01-01</from><to>'
	SET @xmlParam = @xmlParam + @tmpDate + '</to><join>AND</join><begingroup /><endgroup /><datatype>DateTime</datatype></filter>'	
	SET @xmlParam = @xmlParam + '<filter><fieldname>strStatementFormat</fieldname><condition>Equal To</condition><from>Open Item</from><join>AND</join><begingroup /><endgroup /><datatype>String</datatype></filter>'
	SET @xmlParam = @xmlParam + '<filter><fieldname>ysnPrintZeroBalance</fieldname><condition>Equal To</condition><from>False</from><join>AND</join><begingroup /><endgroup /><datatype>Boolean</datatype></filter>'
	SET @xmlParam = @xmlParam + '<filter><fieldname>ysnPrintCreditBalance</fieldname><condition>Equal To</condition><from>True</from><join>AND</join><begingroup /><endgroup /><datatype>Boolean</datatype></filter>'
	SET @xmlParam = @xmlParam + '<filter><fieldname>ysnIncludeBudget</fieldname><condition>Equal To</condition><from>False</from><join>AND</join><begingroup /><endgroup /><datatype>Boolean</datatype></filter>'
	SET @xmlParam = @xmlParam + '<filter><fieldname>ysnPrintOnlyPastDue</fieldname><condition>Equal To</condition><from>True</from><join>AND</join><begingroup /><endgroup /><datatype>Boolean</datatype></filter>'
	SET @xmlParam = @xmlParam + '<filter><fieldname>ysnReportDetail</fieldname><condition>Equal To</condition><from>True</from><join>AND</join><begingroup /><endgroup /><datatype>Boolean</datatype></filter></filters></xmlparam>'
	PRINT @xmlParam
	SET @strQuery  = 'EXEC uspARCustomerStatementReport ' + '''' +  @xmlParam + ''''	 		
	EXEC(@strQuery)	 
END 

ELSE IF (@tmpstrStatementFormat = 'Balance Forward')
BEGIN
	SET @xmlParam=N'<?xml version="1.0" encoding="utf-16"?><xmlparam><filters><filter><fieldname>dtmAsOfDate</fieldname><condition>Between</condition><from>01/01/1900</from><to>'
	SET @xmlParam = @xmlParam + @tmpDate + '</to><join /><begingroup /><endgroup /><datatype>DateTime</datatype></filter>'
	SET @xmlParam = @xmlParam + '<filter><fieldname>ysnPrintZeroBalance</fieldname><condition>Equal To</condition><from>0</from><to>False</to><join /><begingroup /><endgroup /><datatype>Boolean</datatype></filter>'
	SET @xmlParam = @xmlParam + '<filter><fieldname>ysnPrintCreditBalance</fieldname><condition>Equal To</condition><from>1</from><to>True</to><join /><begingroup /><endgroup /><datatype>Boolean</datatype></filter>'
	SET @xmlParam = @xmlParam + '<filter><fieldname>ysnIncludeBudget</fieldname><condition>Equal To</condition><from>0</from><to>False</to><join /><begingroup /><endgroup /><datatype>Boolean</datatype></filter>'
	SET @xmlParam = @xmlParam + '<filter><fieldname>ysnPrintOnlyPastDue</fieldname><condition>Equal To</condition><from>1</from><to>True</to><join /><begingroup /><endgroup /><datatype>Boolean</datatype></filter>'
	SET @xmlParam = @xmlParam + '<filter><fieldname>ysnReportDetail</fieldname><condition>Equal To</condition><from>True</from><join>AND</join><begingroup /><endgroup /><datatype>Boolean</datatype></filter></filters></xmlparam>'
	SET @strQuery  = 'EXEC uspARCustomerStatementBalanceForwardReport ' + '''' +  @xmlParam + ''''	 
	EXEC(@strQuery)		
END

ELSE IF (@tmpstrStatementFormat = 'Payment Activity')
BEGIN
	SET @xmlParam=N'<?xml version="1.0" encoding="utf-16"?><xmlparam><filters><filter><fieldname>dtmAsOfDate</fieldname><condition>Between</condition><from>01/01/1900</from><to>'
	SET @xmlParam = @xmlParam + @tmpDate + '</to><join /><begingroup /><endgroup /><datatype>DateTime</datatype></filter>'
	SET @xmlParam = @xmlParam + '<filter><fieldname>ysnPrintZeroBalance</fieldname><condition>Equal To</condition><from>0</from><to>False</to><join /><begingroup /><endgroup /><datatype>Boolean</datatype></filter>'
	SET @xmlParam = @xmlParam + '<filter><fieldname>ysnPrintCreditBalance</fieldname><condition>Equal To</condition><from>1</from><to>True</to><join /><begingroup /><endgroup /><datatype>Boolean</datatype></filter>'
	SET @xmlParam = @xmlParam + '<filter><fieldname>ysnIncludeBudget</fieldname><condition>Equal To</condition><from>0</from><to>False</to><join /><begingroup /><endgroup /><datatype>Boolean</datatype></filter>'
	SET @xmlParam = @xmlParam + '<filter><fieldname>ysnPrintOnlyPastDue</fieldname><condition>Equal To</condition><from>1</from><to>True</to><join /><begingroup /><endgroup /><datatype>Boolean</datatype></filter>'
	SET @xmlParam = @xmlParam + '<filter><fieldname>ysnReportDetail</fieldname><condition>Equal To</condition><from>True</from><join>AND</join><begingroup /><endgroup /><datatype>Boolean</datatype></filter></filters></xmlparam>'
	SET @strQuery  = 'EXEC uspARCustomerStatementPaymentActivityReport ' + '''' +  @xmlParam + ''''	 		
	EXEC(@strQuery)		
END

ELSE IF (@tmpstrStatementFormat = 'Running Balance')
BEGIN
	SET @xmlParam =N'<?xml version="1.0" encoding="utf-16"?><xmlparam><filters><filter><fieldname>dtmDate</fieldname><condition>Between</condition><from>01/01/1900</from>'
	SET @xmlParam = @xmlParam + @tmpDate + '<to>03/29/2017</to><join /><begingroup /><endgroup /><datatype>DateTime</datatype></filter>'
	SET @xmlParam = @xmlParam + '<filter><fieldname>ysnPrintZeroBalance</fieldname><condition>Equal To</condition><from>0</from><to>False</to><join /><begingroup /><endgroup /><datatype>Boolean</datatype></filter>'
	SET @xmlParam = @xmlParam + '<filter><fieldname>ysnPrintCreditBalance</fieldname><condition>Equal To</condition><from>1</from><to>True</to><join /><begingroup /><endgroup /><datatype>Boolean</datatype></filter>'
	SET @xmlParam = @xmlParam + '<filter><fieldname>ysnIncludeBudget</fieldname><condition>Equal To</condition><from>0</from><to>False</to><join /><begingroup /><endgroup /><datatype>Boolean</datatype></filter>'
	SET @xmlParam = @xmlParam + '<filter><fieldname>ysnPrintOnlyPastDue</fieldname><condition>Equal To</condition><from>1</from><to>True</to><join /><begingroup /><endgroup /><datatype>Boolean</datatype></filter>'
	SET @xmlParam = @xmlParam + '<filter><fieldname>strStatementFormat</fieldname><condition>Equal To</condition><from>Running Balance</from><join /><begingroup /><endgroup /><datatype>String</datatype></filter>'
	SET @xmlParam = @xmlParam + '<filter><fieldname>ysnReportDetail</fieldname><condition>Equal To</condition><from>True</from><join>AND</join><begingroup /><endgroup /><datatype>Boolean</datatype></filter></filters></xmlparam>'
	SET @strQuery  = 'EXEC uspARCustomerStatementReport ' + '''' +  @xmlParam + ''''	
	EXEC(@strQuery)	 			
END

ELSE
BEGIN
	SET @xmlParam =N'<?xml version="1.0" encoding="utf-16"?><xmlparam><filters><filter><fieldname>dtmDate</fieldname><condition>As Of</condition><from>1900-01-01</from><to>'
	SET @xmlParam = @xmlParam + @tmpDate + '</to><join>AND</join><begingroup /><endgroup /><datatype>DateTime</datatype></filter>'
	SET @xmlParam = @xmlParam + '<filter><fieldname>ysnReportDetail</fieldname><condition>Equal To</condition><from>True</from><join>AND</join><begingroup /><endgroup /><datatype>Boolean</datatype></filter></filters></xmlparam>'
	SET @strQuery  = 'EXEC uspARCustomerStatementDetailReport ' + '''' +  @xmlParam + ''''	
	EXEC(@strQuery)		
END

SELECT * FROM tblARSearchStatementCustomer