CREATE TYPE StagingPassportTLM AS TABLE
(
	[intRowCount] 								  INT				NULL,
	[intTaxLevelID]						  		  INT			    NULL,
	[dblMerchandiseCode]				  		  NUMERIC(18,6)     NULL,
	[dblTaxableSalesAmount]						  NUMERIC(18,6)     NULL,
	[dblTaxableSalesRefundedAmount]				  NUMERIC(18,6)     NULL,
	[dblTaxCollectedAmount]						  NUMERIC(18,6)     NULL,
	[dblTaxExemptSalesAmount]					  NUMERIC(18,6)     NULL,
	[dblTaxExemptSalesRefundedAmount]			  NUMERIC(18,6)     NULL,
	[dblTaxForgivenSalesAmount]					  NUMERIC(18,6)     NULL,
	[dblTaxForgivenSalesRefundedAmount]			  NUMERIC(18,6)     NULL,
	[dblTaxRefundedAmount]						  NUMERIC(18,6)     NULL
)