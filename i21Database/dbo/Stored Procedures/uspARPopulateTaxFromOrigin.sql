CREATE PROCEDURE [dbo].[uspARPopulateTaxFromOrigin]  
AS
SET QUOTED_IDENTIFIER OFF  
SET ANSI_NULLS ON  
SET NOCOUNT ON  
SET ANSI_WARNINGS OFF  


IF(OBJECT_ID('tempdb..##ORIGINTAXES') IS NOT NULL) DROP TABLE ##ORIGINTAXES


CREATE TABLE ##ORIGINTAXES (
	   intId									INT             NULL
 	 , strOriginInvoiceNumber					CHAR(6)			COLLATE SQL_Latin1_General_CP1_CI_AS	NULL
	 , strOriginItemNumber						CHAR(10)		COLLATE SQL_Latin1_General_CP1_CI_AS	NULL
	 , strOriginState							CHAR(2)
	 , strTaxColumn                             VARCHAR(50)		COLLATE SQL_Latin1_General_CP1_CI_AS	NULL
	 , strTaxType								VARCHAR(10)		COLLATE SQL_Latin1_General_CP1_CI_AS	NULL
	 , dblTaxAMount								Numeric(18,6)
	 , strOriginTaxKey							VARCHAR(10)		COLLATE SQL_Latin1_General_CP1_CI_AS	NULL
	 , strOriginTaxGroup						VARCHAR(10)		COLLATE SQL_Latin1_General_CP1_CI_AS	NULL
)



INSERT INTO ##ORIGINTAXES
SELECT A4GLIdentity,pttic_ivc_no,
	   pttic_itm_no,
	   SUBSTRING ( pttic_tax_key ,11 , 2)[State],
	   TaxOrigin,
	   UPPER(SUBSTRING(TaxOrigin,12,3))[TaxType],
	   dblAmt 
	   , SUBSTRING ( pttic_tax_key ,13 , 3) 
	   ,  SUBSTRING ( pttic_tax_key ,11 , 2)  + ' ' + SUBSTRING ( pttic_tax_key ,13 , 3) 
FROM
(
  SELECT   A4GLIdentity,pttic_ivc_no,pttic_itm_no, pttic_tax_key,pttic_tax_cls_id
		,pttic_fet_amt
		,pttic_set_amt
		,pttic_sst_amt
		,pttic_sst_on_net
		,pttic_sst_on_fet
		,pttic_sst_on_set
		,pttic_sst_on_lc1
		,pttic_sst_on_lc2
		,pttic_sst_on_lc3
		,pttic_sst_on_lc4
		,pttic_sst_on_lc5
		,pttic_sst_on_lc6
		,pttic_sst_on_lc7
		,pttic_sst_on_lc8
		,pttic_sst_on_lc9
		,pttic_sst_on_lc10
		,pttic_sst_on_lc11
		,pttic_sst_on_lc12
		,pttic_lc1_amt
		,pttic_lc2_amt
		,pttic_lc3_amt
		,pttic_lc4_amt
		,pttic_lc5_amt
		,pttic_lc6_amt
		,pttic_lc7_amt
		,pttic_lc8_amt
		,pttic_lc9_amt
		,pttic_lc10_amt
		,pttic_lc11_amt
		,pttic_lc12_amt
		,pttic_lc1_on_net
		,pttic_lc1_on_fet
		,pttic_lc2_on_net
		,pttic_lc2_on_fet
		,pttic_lc3_on_net
		,pttic_lc3_on_fet
		,pttic_lc4_on_net
		,pttic_lc4_on_fet
		,pttic_lc5_on_net
		,pttic_lc5_on_fet
		,pttic_lc6_on_net
		,pttic_lc6_on_fet
		,pttic_lc7_on_net	
		,pttic_lc7_on_fet
		,pttic_lc8_on_net
		,pttic_lc8_on_fet
		,pttic_lc9_on_net
		,pttic_lc9_on_fet
		,pttic_lc10_on_net
		,pttic_lc10_on_fet
		,pttic_lc11_on_net
		,pttic_lc11_on_fet
		,pttic_lc12_on_net
		,pttic_lc12_on_fet
		,pttic_ship_fet_amt
		,pttic_ship_set_amt
		,pttic_ship_sst_amt
		,ship_sst_on_net
		,ship_sst_on_fet
		,ship_sst_on_set
		,ship_sst_on_lc1
		,ship_sst_on_lc2
		,ship_sst_on_lc3
		,ship_sst_on_lc4
		,ship_sst_on_lc5
		,ship_sst_on_lc6
		,ship_sst_on_lc7
		,ship_sst_on_lc8
		,ship_sst_on_lc9
		,ship_sst_on_lc10
		,ship_sst_on_lc11
		,ship_sst_on_lc12
		,pttic_ship_lc1_amt
		,pttic_ship_lc2_amt
		,pttic_ship_lc3_amt	
		,pttic_ship_lc4_amt	
		,pttic_ship_lc5_amt	
		,pttic_ship_lc6_amt	
		,pttic_ship_lc7_amt	
		,pttic_ship_lc8_amt	
		,pttic_ship_lc9_amt	
		,pttic_ship_lc10_amt	
		,pttic_ship_lc11_amt	
		,pttic_ship_lc12_amt	
		,ship_lc1_on_net	
		,ship_lc1_on_fet	
		,ship_lc2_on_net	
		,ship_lc2_on_fet	
		,ship_lc3_on_net	
		,ship_lc3_on_fet	
		,ship_lc4_on_net	
		,ship_lc4_on_fet	
		,ship_lc5_on_net	
		,ship_lc5_on_fet	
		,ship_lc6_on_net	
		,ship_lc6_on_fet	
		,ship_lc7_on_net	
		,ship_lc7_on_fet	
		,ship_lc8_on_net	
		,ship_lc8_on_fet	
		,ship_lc9_on_net	
		,ship_lc9_on_fet	
		,ship_lc10_on_net	
		,ship_lc10_on_fet	
		,ship_lc11_on_net	
		,ship_lc11_on_fet	
		,ship_lc12_on_net	
		,ship_lc12_on_fet
  from tmp_ptticmstImport 
) AS cp

UNPIVOT 
(
  dblAmt FOR TaxOrigin IN (
				 pttic_fet_amt
				,pttic_set_amt
				,pttic_sst_amt
				,pttic_sst_on_net
				,pttic_sst_on_fet
				,pttic_sst_on_set
				,pttic_sst_on_lc1
				,pttic_sst_on_lc2
				,pttic_sst_on_lc3
				,pttic_sst_on_lc4
				,pttic_sst_on_lc5
				,pttic_sst_on_lc6
				,pttic_sst_on_lc7
				,pttic_sst_on_lc8
				,pttic_sst_on_lc9
				,pttic_sst_on_lc10
				,pttic_sst_on_lc11
				,pttic_sst_on_lc12
				,pttic_lc1_amt
				,pttic_lc2_amt
				,pttic_lc3_amt
				,pttic_lc4_amt
				,pttic_lc5_amt
				,pttic_lc6_amt
				,pttic_lc7_amt
				,pttic_lc8_amt
				,pttic_lc9_amt
				,pttic_lc10_amt
				,pttic_lc11_amt
				,pttic_lc12_amt
				,pttic_lc1_on_net
				,pttic_lc1_on_fet
				,pttic_lc2_on_net
				,pttic_lc2_on_fet
				,pttic_lc3_on_net
				,pttic_lc3_on_fet
				,pttic_lc4_on_net
				,pttic_lc4_on_fet
				,pttic_lc5_on_net
				,pttic_lc5_on_fet
				,pttic_lc6_on_net
				,pttic_lc6_on_fet
				,pttic_lc7_on_net	
				,pttic_lc7_on_fet
				,pttic_lc8_on_net
				,pttic_lc8_on_fet
				,pttic_lc9_on_net
				,pttic_lc9_on_fet
				,pttic_lc10_on_net
				,pttic_lc10_on_fet
				,pttic_lc11_on_net
				,pttic_lc11_on_fet
				,pttic_lc12_on_net
				,pttic_lc12_on_fet
				,pttic_ship_fet_amt
				,pttic_ship_set_amt
				,pttic_ship_sst_amt
				,ship_sst_on_net
				,ship_sst_on_fet
				,ship_sst_on_set
				,ship_sst_on_lc1
				,ship_sst_on_lc2
				,ship_sst_on_lc3
				,ship_sst_on_lc4
				,ship_sst_on_lc5
				,ship_sst_on_lc6
				,ship_sst_on_lc7
				,ship_sst_on_lc8
				,ship_sst_on_lc9
				,ship_sst_on_lc10
				,ship_sst_on_lc11
				,ship_sst_on_lc12
				,pttic_ship_lc1_amt
				,pttic_ship_lc2_amt
				,pttic_ship_lc3_amt	
				,pttic_ship_lc4_amt	
				,pttic_ship_lc5_amt	
				,pttic_ship_lc6_amt	
				,pttic_ship_lc7_amt	
				,pttic_ship_lc8_amt	
				,pttic_ship_lc9_amt	
				,pttic_ship_lc10_amt	
				,pttic_ship_lc11_amt	
				,pttic_ship_lc12_amt	
				,ship_lc1_on_net	
				,ship_lc1_on_fet	
				,ship_lc2_on_net	
				,ship_lc2_on_fet	
				,ship_lc3_on_net	
				,ship_lc3_on_fet	
				,ship_lc4_on_net	
				,ship_lc4_on_fet	
				,ship_lc5_on_net	
				,ship_lc5_on_fet	
				,ship_lc6_on_net	
				,ship_lc6_on_fet	
				,ship_lc7_on_net	
				,ship_lc7_on_fet	
				,ship_lc8_on_net	
				,ship_lc8_on_fet	
				,ship_lc9_on_net	
				,ship_lc9_on_fet	
				,ship_lc10_on_net	
				,ship_lc10_on_fet	
				,ship_lc11_on_net	
				,ship_lc11_on_fet	
				,ship_lc12_on_net	
				,ship_lc12_on_fet
  )
)TempTax 

WHERE TempTax.dblAmt > 0 AND UPPER(SUBSTRING(TempTax.TaxOrigin,12,3))  IN ('FET','SET','SST')