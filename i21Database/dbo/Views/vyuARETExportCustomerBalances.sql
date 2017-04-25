CREATE VIEW [dbo].[vyuARETExportCustomerBalances]
AS 
SELECT
	 blpatr				= ARCI.[strCustomerNumber]
	,bldept				= ISNULL(SMCL.[strLocationNumber], 	(
															SELECT TOP 1
																CL.[strLocationNumber]
															FROM
																tblEMEntityLocation EL
															INNER JOIN
																tblSMCompanyLocation CL
																	ON EL.[intWarehouseId] = CL.[intCompanyLocationId]
																	AND ISNULL(EL.[intWarehouseId],0) <> 0
															WHERE
																EL.[intEntityId] = ARCI.[intEntityCustomerId]
															)
								)
	,blterm				= SMT.[strTermCode]
	,blov30				= ISNULL(ARCI.[dbl60Days], 0.000000)
	,blov60				= ISNULL(ARCI.[dbl90Days], 0.000000)
	,blov90				= ISNULL(ARCI.[dbl91Days], 0.000000)
	,blcchr				= ISNULL(ARCI.[dblFuture], 0.000000) + ISNULL(ARCI.[dbl0Days], 0.000000) + ISNULL(ARCI.[dbl10Days], 0.000000) + ISNULL(ARCI.[dbl30Days], 0.000000)
	,blcpay				= ISNULL(ARCI.[dblUnappliedCredits], 0.000000) + ISNULL(ARCI.[dblPrepaids], 0.000000)
	,decLastPaymentAmt	= ISNULL(ARCI.[dblLastPayment], 0.000000)
	,dtLastPaymentDate	= CONVERT(NVARCHAR(8), ARCI.[dtmLastPaymentDate], 112)
FROM
	vyuARCustomerInquiry ARCI
INNER JOIN
	vyuARCustomer ARC
		ON ARCI.[intEntityCustomerId] = ARC.[intEntityCustomerId]
LEFT OUTER JOIN 
	tblEMEntityLocation EMEL
		ON ARC.intEntityCustomerId = EMEL.intEntityId AND EMEL.ysnDefaultLocation = 1
LEFT OUTER JOIN
	tblSMCompanyLocation SMCL
		ON EMEL.[intWarehouseId] = SMCL.[intCompanyLocationId]
LEFT OUTER JOIN
	tblSMTerm SMT
		ON ARC.[intTermsId]	 = SMT.[intTermID]