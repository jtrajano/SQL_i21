CREATE TYPE StagingCommanderTax AS TABLE
(
	[intRowCount] 										  INT				NULL,
	[dtmPeriodEndDate]                                    DATETIME			NULL,
	[dtmPeriodBeginDate]                                  DATETIME			NULL,
	[intPeriodSeqNum]                                     INT				NULL,
	[strPeriodName]                                       NVARCHAR(MAX)		NULL,
	[strPeriodType]                                       NVARCHAR(MAX)		NULL,
	[strSysId] 										      NVARCHAR(MAX)		NULL,
	[strTaxRateBaseName]                                  NVARCHAR(MAX)		NULL,
	[dblTaxRateBaseTaxRate]                               NUMERIC(18,6)		NULL,
	[dblTaxInfoActualTaxRate]                             NUMERIC(18,6)		NULL,
	[dblTaxInfoTaxableSales]                              NUMERIC(18,6)		NULL,
	[dblTaxInfoNonTaxableSales]                           NUMERIC(18,6)		NULL,
	[dblTaxInfoSalesTax]                                  NUMERIC(18,6)		NULL,
	[dblTaxInfoRefundTax]                                 NUMERIC(18,6)		NULL,
	[dblTaxInfoNetTax]                                    NUMERIC(18,6)		NULL,
	[dblTaxInfoTaxableRefunds]                            NUMERIC(18,6)		NULL,
	[dblTaxInfoTaxExemptSales]                            NUMERIC(18,6)		NULL,
	[dblTaxInfoTaxExemptRefunds]                          NUMERIC(18,6)		NULL,
	[dblTaxInfoTaxForgivenSales]                          NUMERIC(18,6)		NULL,
	[dblTaxInfoTaxForgivenRefunds]                        NUMERIC(18,6)		NULL
)
