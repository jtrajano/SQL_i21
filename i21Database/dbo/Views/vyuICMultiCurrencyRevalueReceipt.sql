CREATE VIEW [dbo].[vyuICMultiCurrencyRevalueReceipt]
AS
SELECT DISTINCT
	 strTransactionType			= CAST(NULL AS NVARCHAR(50))
	,strTransactionId			= CAST(NULL AS NVARCHAR(50))
	,strTransactionDate			= CAST(NULL AS NVARCHAR(50))
	,strTransactionDueDate		= CAST(NULL AS NVARCHAR(50))
	,strVendorName				= CAST(NULL AS NVARCHAR(50))
	,strCommodity				= CAST(NULL AS NVARCHAR(50))
	,strLineOfBusiness			= CAST(NULL AS NVARCHAR(50))
	,strLocation				= CAST(NULL AS NVARCHAR(50))
	,strTicket					= CAST(NULL AS NVARCHAR(50))
	,strContractNumber			= CAST(NULL AS NVARCHAR(50))
	,strItemId					= CAST(NULL AS NVARCHAR(50))
	,dblQuantity				= CAST(NULL AS NUMERIC(18, 6))
	,dblUnitPrice				= CAST(NULL AS NUMERIC(18, 6))
	,dblAmount					= CAST(NULL AS NUMERIC(18, 6))
	,intCurrencyId				= CAST(NULL AS INT)
	,intForexRateType			= CAST(NULL AS INT)
	,strForexRateType			= CAST(NULL AS NVARCHAR(50))
	,dblForexRate				= CAST(NULL AS NUMERIC(18, 6))
	,dblHistoricAmount			= CAST(NULL AS NUMERIC(18, 6))
	,dblNewForexRate			= 0 --Calcuate By GL
	,dblNewAmount				= 0 --Calcuate By GL
	,dblUnrealizedDebitGain		= 0 --Calcuate By GL
	,dblUnrealizedCreditGain	= 0 --Calcuate By GL
	,dblDebit					= 0 --Calcuate By GL
	,dblCredit					= 0 --Calcuate By GL