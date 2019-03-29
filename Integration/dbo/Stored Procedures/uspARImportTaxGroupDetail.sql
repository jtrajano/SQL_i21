
CREATE PROCEDURE [dbo].[uspARImportTaxGroupDetail]
AS
BEGIN

	DECLARE @ysnPttaxmst BIT = 0,
			@ysnPtitmmst BIT = 0,
			@ysnPtclsmst BIT = 0;

	SELECT TOP 1 @ysnPttaxmst = 1 from INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'pttaxmst';
	SELECT TOP 1 @ysnPtitmmst = 1 from INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'ptitmmst';
	SELECT TOP 1 @ysnPtclsmst = 1 from INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'ptclsmst';



	IF (@ysnPttaxmst = 1 AND @ysnPtitmmst = 1 AND @ysnPtclsmst = 1)
	BEGIN
			DECLARE @ORIGINTAXCODE as AROriginTaxCodeTableType,
					@FETTAXCODE as AROriginTaxCodeTableType,
					@SETTAXCODE as AROriginTaxCodeTableType,
					@SSTTAXCODE as AROriginTaxCodeTableType;
					
				

			--FET---FEDERAL EXCISE TAX
		    DECLARE @FETTaxClassIdGas INT = 0,
					@FETTaxClassIdDiesel INT = 0;
			


					SELECT @FETTaxClassIdGas = intTaxClassId FROM tblSMTaxClass
					WHERE strTaxClass Like '%Federal Excise Tax Gas%';

					SELECT @FETTaxClassIdDiesel = intTaxClassId FROM tblSMTaxClass
					WHERE strTaxClass Like '%Federal Excise Tax Diesel%';

			WITH TaxCodes AS (
				SELECT  
						strTaxGroup				= isnull(pttax_state,'') + ' ' + isnull(pttax_local1,'') + ' ' + ISNULL(pttax_local2,''),
						intTaxClassId			= CASE WHEN ptcls_desc like '%DIESEL%' THEN @FETTaxClassIdDiesel WHEN ptcls_desc like '%GAS%' THEN @FETTaxClassIdGas ELSE 0 END,
						strTaxClass				= CASE WHEN ptcls_desc like '%DIESEL%' THEN 'FEDERAL EXCISE TAX DIESEL' WHEN ptcls_desc like '%GAS%' THEN 'FEDERAL EXCISE TAX GAS' ELSE '' END,
						strTaxCode				= 'FET '+ ptcls_desc,
						strDescription			= 'FET '+ ptcls_desc,
						strUnitMeasure			=  ptitm_unit,
						strTaxableByOtherTaxes	= pttax_sst_on_fet_yn,
						strState				= pttax_state, 
						strCountry				= 'USA',
						dblRate					= pttax_fet_rt,
						strAccountId			= pttax_fet_acct,
						dtmEffectiveDate		=  CONVERT(datetime, (
														SUBSTRING(cast(pttax_eff_rev_dt as nvarchar(30)), 1, 4) + '-' +
														SUBSTRING(cast(pttax_eff_rev_dt as nvarchar(30)), 5, 2) + '-' +
														SUBSTRING(cast(pttax_eff_rev_dt as nvarchar(30)), 7, 2) 
													)),
						intRowNumber			=  ROW_NUMBER() 
												   OVER (PARTITION BY 
															pttax_state + pttax_local1 + pttax_local2 ,ptcls_desc
													     ORDER BY 
															pttax_state + pttax_local1 + pttax_local2,
														    ptcls_desc,
															CONVERT(datetime,(
																SUBSTRING(CAST(pttax_eff_rev_dt as nvarchar(30)), 1, 4) + '-' + 
																SUBSTRING(CAST(pttax_eff_rev_dt as nvarchar(30)), 5, 2) + '-' +  
																SUBSTRING(CAST(pttax_eff_rev_dt as nvarchar(30)), 7, 2)
															)) DESC
													)  
				FROM pttaxmst
					INNER JOIN ptitmmst on pttax_itm_no = ptitm_itm_no
					INNER JOIN ptclsmst on ptitm_class = ptcls_class
				WHERE
					pttax_fet_rt <> 0 
				GROUP BY
				pttax_state + pttax_local1 + pttax_local2,
				ptcls_desc,
				ptitm_unit,
				pttax_sst_on_fet_yn,
				pttax_state, 
				pttax_local1, 
				pttax_local2, 
				pttax_eff_rev_dt,
				pttax_fet_rt,
				pttax_fet_acct
			)
			INSERT INTO @FETTAXCODE(
				[strTaxGroup],
				[intTaxClassId],
				[strTaxClass],
				[strTaxCode],
				[strDescription],
				[strUnitMeasure],
				[strTaxableByOtherTaxes],
				[strState],
				[strCountry],
				[dblRate],
				[strAccountId],
				[intSalesTaxAccountId],
				[intPurchaseTaxAccountId],
				[dtmEffectiveDate]
			)
			SELECT  
				[strTaxGroup],
				[intTaxClassId],
				[strTaxClass],
				[strTaxCode],
				[strDescription],
				[strUnitMeasure],
				[strTaxableByOtherTaxes],
				[strState],
				[strCountry],
				[dblRate],
				[strAccountId],
				[intSalesTaxAccountId] = 0,
				[intPurchaseTaxAccountId] = 0,
				[dtmEffectiveDate]
			FROM TaxCodes
			WHERE intRowNumber = 1 AND intTaxClassId <> 0
			ORDER BY  strTaxGroup, strTaxClass, strTaxCode

			INSERT INTO @ORIGINTAXCODE
			SELECT * FROM @FETTAXCODE

			-------@FETTAXCODE--END-----



			--SET---STATE EXCISE TAX
		    DECLARE @SETTaxClassIdGas INT = 0,
					@SETTaxClassIdDiesel INT = 0;
			


					SELECT @SETTaxClassIdGas = intTaxClassId FROM tblSMTaxClass
					WHERE strTaxClass Like '%State Excise Tax Gas%';

					SELECT @SETTaxClassIdDiesel = intTaxClassId FROM tblSMTaxClass
					WHERE strTaxClass Like '%State Excise Tax Diesel%';

			WITH TaxCodes AS (
				SELECT  
						strTaxGroup				= isnull(pttax_state,'') + ' ' + isnull(pttax_local1,'') + ' ' + ISNULL(pttax_local2,''),
						intTaxClassId			= CASE WHEN ptcls_desc like '%DIESEL%' THEN @SETTaxClassIdDiesel WHEN ptcls_desc like '%GAS%' THEN @SETTaxClassIdGas ELSE 0 END,
						strTaxClass				= CASE WHEN ptcls_desc like '%DIESEL%' THEN 'FEDERAL EXCISE TAX DIESEL' WHEN ptcls_desc like '%GAS%' THEN 'FEDERAL EXCISE TAX GAS' ELSE '' END,
						strTaxCode				= 'SET '+ ptcls_desc,
						strDescription			= 'SET '+ ptcls_desc,
						strUnitMeasure			=  ptitm_unit,
						strTaxableByOtherTaxes	= pttax_sst_on_set_yn,
						strState				= pttax_state, 
						strCountry				= 'USA',
						dblRate					= pttax_set_rt,
						strAccountId			= pttax_set_acct,
						dtmEffectiveDate		=  CONVERT(datetime, (
														SUBSTRING(cast(pttax_eff_rev_dt as nvarchar(30)), 1, 4) + '-' +
														SUBSTRING(cast(pttax_eff_rev_dt as nvarchar(30)), 5, 2) + '-' +
														SUBSTRING(cast(pttax_eff_rev_dt as nvarchar(30)), 7, 2) 
													)),
						intRowNumber			=  ROW_NUMBER() 
												   OVER (PARTITION BY 
															pttax_state + pttax_local1 + pttax_local2 ,ptcls_desc
													     ORDER BY 
															pttax_state + pttax_local1 + pttax_local2,
														    ptcls_desc,
															CONVERT(datetime,(
																SUBSTRING(CAST(pttax_eff_rev_dt as nvarchar(30)), 1, 4) + '-' + 
																SUBSTRING(CAST(pttax_eff_rev_dt as nvarchar(30)), 5, 2) + '-' +  
																SUBSTRING(CAST(pttax_eff_rev_dt as nvarchar(30)), 7, 2)
															)) DESC
													)  
				FROM pttaxmst
					INNER JOIN ptitmmst on pttax_itm_no = ptitm_itm_no
					INNER JOIN ptclsmst on ptitm_class = ptcls_class
				WHERE
					pttax_set_rt <> 0 
				GROUP BY
				pttax_state + pttax_local1 + pttax_local2,
				ptcls_desc,
				ptitm_unit,
				pttax_sst_on_set_yn,
				pttax_state, 
				pttax_local1, 
				pttax_local2, 
				pttax_eff_rev_dt,
				pttax_set_rt,
				pttax_set_acct
			)
			INSERT INTO @SETTAXCODE(
				[strTaxGroup],
				[intTaxClassId],
				[strTaxClass],
				[strTaxCode],
				[strDescription],
				[strUnitMeasure],
				[strTaxableByOtherTaxes],
				[strState],
				[strCountry],
				[dblRate],
				[strAccountId],
				[intSalesTaxAccountId],
				[intPurchaseTaxAccountId],
				[dtmEffectiveDate]
			)
			SELECT  
				[strTaxGroup],
				[intTaxClassId],
				[strTaxClass],
				[strTaxCode],
				[strDescription],
				[strUnitMeasure],
				[strTaxableByOtherTaxes],
				[strState],
				[strCountry],
				[dblRate],
				[strAccountId],
				[intSalesTaxAccountId] = 0,
				[intPurchaseTaxAccountId] = 0,
				[dtmEffectiveDate]
			FROM TaxCodes
			WHERE intRowNumber = 1 AND intTaxClassId <> 0
			ORDER BY  strTaxGroup, strTaxClass, strTaxCode

			INSERT INTO @ORIGINTAXCODE
			SELECT * FROM @SETTAXCODE

			-------@SETTAXCODE--END-----


			--SST---SALES STATE TAX
		    DECLARE @SSTTaxClassId INT = 0;
			

			SELECT @SSTTaxClassId = intTaxClassId FROM tblSMTaxClass
			WHERE strTaxClass Like '%State Sales Tax%';
					

			WITH TaxCodes AS (
				SELECT  
						strTaxGroup				= isnull(pttax_state,'') + ' ' + isnull(pttax_local1,'') + ' ' + ISNULL(pttax_local2,''),
						intTaxClassId			=  @SSTTaxClassId,
						strTaxClass				= 'State Sales Tax',
						strTaxCode				= 'SST '+ ptcls_desc,
						strDescription			= 'SST '+ ptcls_desc,
						strUnitMeasure			=  ptitm_unit,
						strTaxableByOtherTaxes	= 'N',
						strState				= pttax_state, 
						strCountry				= 'USA',
						dblRate					= pttax_sst_rt,
						strAccountId			= pttax_sst_acct,
						dtmEffectiveDate		=  CONVERT(datetime, (
														SUBSTRING(cast(pttax_eff_rev_dt as nvarchar(30)), 1, 4) + '-' +
														SUBSTRING(cast(pttax_eff_rev_dt as nvarchar(30)), 5, 2) + '-' +
														SUBSTRING(cast(pttax_eff_rev_dt as nvarchar(30)), 7, 2) 
													)),
						intRowNumber			=  ROW_NUMBER() 
												   OVER (PARTITION BY 
															pttax_state + pttax_local1 + pttax_local2 ,ptcls_desc
													     ORDER BY 
															pttax_state + pttax_local1 + pttax_local2,
														    ptcls_desc,
															CONVERT(datetime,(
																SUBSTRING(CAST(pttax_eff_rev_dt as nvarchar(30)), 1, 4) + '-' + 
																SUBSTRING(CAST(pttax_eff_rev_dt as nvarchar(30)), 5, 2) + '-' +  
																SUBSTRING(CAST(pttax_eff_rev_dt as nvarchar(30)), 7, 2)
															)) DESC
													)  
				FROM pttaxmst
					INNER JOIN ptitmmst on pttax_itm_no = ptitm_itm_no
					INNER JOIN ptclsmst on ptitm_class = ptcls_class
				WHERE
					pttax_sst_rt <> 0 
				GROUP BY
				pttax_state + pttax_local1 + pttax_local2,
				ptcls_desc,
				ptitm_unit,
				pttax_sst_on_set_yn,
				pttax_state, 
				pttax_local1, 
				pttax_local2, 
				pttax_eff_rev_dt,
				pttax_sst_rt,
				pttax_sst_acct
			)
			INSERT INTO @SSTTAXCODE
			(	[strTaxGroup],
				[intTaxClassId],
				[strTaxClass],
				[strTaxCode],
				[strDescription],
				[strUnitMeasure],
				[strTaxableByOtherTaxes],
				[strState],
				[strCountry],
				[dblRate],
				[strAccountId],
				[intSalesTaxAccountId],
				[intPurchaseTaxAccountId],
				[dtmEffectiveDate]
			)
			SELECT  
				[strTaxGroup],
				[intTaxClassId],
				[strTaxClass],
				[strTaxCode],
				[strDescription],
				[strUnitMeasure],
				[strTaxableByOtherTaxes],
				[strState],
				[strCountry],
				[dblRate],
				[strAccountId],
				[intSalesTaxAccountId] = 0,
				[intPurchaseTaxAccountId] = 0,
				[dtmEffectiveDate]
			FROM TaxCodes
			WHERE intRowNumber = 1 AND intTaxClassId <> 0
			ORDER BY  strTaxGroup, strTaxClass, strTaxCode

			INSERT INTO @ORIGINTAXCODE
			SELECT * FROM @SSTTAXCODE

			---------@SSTTAXCODE--END-----




			--Updating Account

			UPDATE ORI
			SET [intSalesTaxAccountId] = SRC.intAccountId,
				[intPurchaseTaxAccountId] = SRC.intAccountId
			FROM @ORIGINTAXCODE ORI
			INNER JOIN tblGLAccount SRC
			ON SUBSTRING(ORI.strAccountId,1,4) = SUBSTRING(SRC.strAccountId,1,4) 

			--INSERTING Tax Codes

			INSERT INTO tblSMTaxCode
			(
				[intTaxClassId],
				[strTaxCode],
				[strDescription],
				[strTaxableByOtherTaxes],
				[strState],
				[strCountry],
				[intSalesTaxAccountId],
				[intPurchaseTaxAccountId],
				[strZipCode],
				[strCity] 
			) SELECT [intTaxClassId],
				[strTaxCode],
				[strDescription],
				[strTaxableByOtherTaxes],
				[strState] = '',
				[strCountry],
				[intSalesTaxAccountId],
				[intPurchaseTaxAccountId],
				[strZipCode] = '',
				[strCity] = ''
			FROM (SELECT
					ORIG.[intTaxClassId],
					ORIG.[strTaxCode],
					ORIG.[strDescription],
					ORIG.[strTaxableByOtherTaxes],
					[strState] = '',
					ORIG.[strCountry],
					ORIG.[intSalesTaxAccountId],
					ORIG.[intPurchaseTaxAccountId],
					[strZipCode] = '',
					[strCity] = '',
					[intRowNumber] = ROW_NUMBER() OVER (Partition by ORIG.[strTaxCode] order by ORIG.[strTaxCode])
				FROM @ORIGINTAXCODE ORIG
				LEFT JOIN tblSMTaxCode SRC
				ON ORIG.strTaxCode = SRC.strTaxCode
				WHERE SRC.strTaxCode IS NULL
			) taxcodes
			WHERE intRowNumber = 1


			--UPDATE intUnitMeasureId
			UPDATE ORIG
			SET ORIG.intUnitMeasureId  = ICUnit.intUnitMeasureId,
				ORIG.strCalculationMethod = 'Unit'
			FROM @ORIGINTAXCODE ORIG
			INNER JOIN tblICUnitMeasure ICUnit
			ON ICUnit.strUnitMeasure LIKE  '%'+ORIG.strUnitMeasure+'%';
			


			--INSERT INTO TaxCodeRate

			
			
			WITH TaxCodeRate as(
				SELECT  intTaxCodeId			= SRC.intTaxCodeId, 
						strCalculationMethod	= 'Unit',
						intUnitMeasureId		= ORIG.intUnitMeasureId, 
						dblRate					= ORIG.dblRate, 
						dtmEffectiveDate		= ORIG.dtmEffectiveDate,
						intRN					= ROW_NUMBER() OVER (PARTITION BY SRC.intTaxCodeId,ORIG.intUnitMeasureId,ORIG.dtmEffectiveDate ORDER BY SRC.intTaxCodeId, ORIG.dblRate DESC)
				FROM tblSMTaxCode SRC
				INNER JOIN @ORIGINTAXCODE ORIG
				ON ORIG.strTaxCode = SRC.strTaxCode
				LEFT JOIN tblSMTaxCodeRate TAXRATE
				ON SRC.intTaxCodeId = TAXRATE.intTaxCodeId AND
					ORIG.strCalculationMethod = TAXRATE.strCalculationMethod AND
					ORIG.dtmEffectiveDate = TAXRATE.dtmEffectiveDate AND
					ORIG.intUnitMeasureId = TAXRATE.intUnitMeasureId
				WHERE TAXRATE.intTaxCodeId IS NULL AND ORIG.intUnitMeasureId IS NOT NULL)
			INSERT INTO tblSMTaxCodeRate(
						intTaxCodeId,
						strCalculationMethod,
						intUnitMeasureId,
						dblRate,
						dtmEffectiveDate)
			SELECT intTaxCodeId,		
				   strCalculationMethod,
				   intUnitMeasureId,	
				   dblRate,	
				   dtmEffectiveDate
			FROM TaxCodeRate
			WHERE intRN = 1		
				   			
			--InserdtmEffectiveDate	t into TaxGroupCode
			INSERT INTO tblSMTaxGroupCode(intTaxCodeId,intTaxGroupId)
			SELECT T.intTaxCodeId, G.intTaxGroupId FROM tblSMTaxCode T
			INNER JOIN @ORIGINTAXCODE  O
			ON T.strTaxCode = O.strTaxCode
			INNER JOIN tblSMTaxGroup G
			ON G.strTaxGroup LIKE '%'+ O.strTaxGroup + '%'
			LEFT JOIN tblSMTaxGroupCode GC
			ON T.intTaxCodeId = GC.intTaxCodeId AND G.intTaxGroupId = GC.intTaxGroupId
			WHERE GC.intTaxCodeId IS NULL AND GC.intTaxGroupId IS NULL
	END
END
			
