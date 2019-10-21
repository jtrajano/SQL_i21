CREATE TABLE [dbo].[tblCFInvoiceDiscountCalculationTempTable]
(
		 intAccountId						INT						  NULL
		,intSalesPersonId					INT						  NULL
		,intCustomerId						INT						  NULL
		,intInvoiceId						INT						  NULL
		,intTransactionId					INT						  NULL
		,intCustomerGroupId					INT						  NULL
		,intTermID							INT						  NULL
		,intBalanceDue						INT						  NULL
		,intDiscountDay						INT						  NULL
		,intDayofMonthDue					INT						  NULL
		,intDueNextMonth					INT						  NULL
		,intSort							INT						  NULL
		,intConcurrencyId					INT						  NULL
		,ysnAllowEFT						BIT						  NULL
		,ysnActive							BIT						  NULL
		,ysnEnergyTrac						BIT						  NULL
		,ysnShowOnCFInvoice					BIT						  NULL
		,dtmInvoiceDate						DATETIME				  NULL
		,dtmDiscountDate					DATETIME				  NULL
		,dtmDueDate							DATETIME				  NULL
		,dtmTransactionDate					DATETIME				  NULL
		,dtmBillingDate						DATETIME				  NULL
		,dtmPostedDate						DATETIME				  NULL
		,dblQuantity						NUMERIC(18,6)			  NULL
		,dblTotalQuantity					NUMERIC(18,6)			  NULL
		,dblDiscountRate					NUMERIC(18,6)			  NULL
		,dblDiscount						NUMERIC(18,6)			  NULL
		,dblTotalAmount						NUMERIC(18,6)			  NULL
		,dblAccountTotalAmount				NUMERIC(18,6)			  NULL
		,dblAccountTotalDiscount			NUMERIC(18,6)			  NULL
		,dblAccountTotalLessDiscount		NUMERIC(18,6)			  NULL
		,dblAccountTotalDiscountQuantity	NUMERIC(18,6)			  NULL
		,dblDiscountEP						NUMERIC(18,6)			  NULL
		,dblAPR								NUMERIC(18,6)			  NULL
		,strTerm							NVARCHAR(MAX)			  COLLATE Latin1_General_CI_AS NULL
		,strType							NVARCHAR(MAX)			  COLLATE Latin1_General_CI_AS NULL
		,strTermCode						NVARCHAR(MAX)			  COLLATE Latin1_General_CI_AS NULL
		,strNetwork							NVARCHAR(MAX)			  COLLATE Latin1_General_CI_AS NULL
		,strCustomerName					NVARCHAR(MAX)			  COLLATE Latin1_General_CI_AS NULL
		,strInvoiceCycle					NVARCHAR(MAX)			  COLLATE Latin1_General_CI_AS NULL
		,strGroupName						NVARCHAR(MAX)			  COLLATE Latin1_General_CI_AS NULL
		,strInvoiceNumber					NVARCHAR(MAX)			  COLLATE Latin1_General_CI_AS NULL
		,strInvoiceReportNumber				NVARCHAR(MAX)			  COLLATE Latin1_General_CI_AS NULL
		,strUserId							NVARCHAR(100)			  COLLATE Latin1_General_CI_AS NULL
		,strDiscountSchedule				NVARCHAR(100)			  COLLATE Latin1_General_CI_AS NULL
)