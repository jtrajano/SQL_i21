CREATE PROCEDURE [dbo].[uspTFGenerateStateScript]
	@TaxAuthorityId INT

AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

DECLARE @ErrorMessage NVARCHAR(4000)
DECLARE @ErrorSeverity INT
DECLARE @ErrorState INT

BEGIN TRY

	DECLARE @TaxAuthorityCode NVARCHAR(2)
		, @TADescription NVARCHAR(50)
     
	SELECT @TaxAuthorityCode = strTaxAuthorityCode
		, @TADescription = strDescription
	FROM tblTFTaxAuthority
	WHERE intTaxAuthorityId = @TaxAuthorityId

	PRINT('-- Declare the Tax Authority Code that will be used all throughout ' + @TADescription + ' Default Data
	PRINT (''Deploying ' + @TADescription + ' Tax Forms'')
	DECLARE @TaxAuthorityCode NVARCHAR(10) = ''' + @TaxAuthorityCode + '''
		, @TaxAuthorityId INT
	SELECT @TaxAuthorityId = intTaxAuthorityId FROM tblTFTaxAuthority WHERE strTaxAuthorityCode = @TaxAuthorityCode')

	DECLARE @ProductCodeQuery NVARCHAR(MAX)
		, @ProductCodeQueryALL NVARCHAR(MAX)
		, @ProductResults NVARCHAR(MAX)

	SET @ProductCodeQueryALL = '
	-- Product Codes
	/* Generate script for Product Codes. Specify Tax Authority Id to filter out specific Product Codes only.' + CHAR(10)

	SET @ProductCodeQuery = 'select strQuery = ''UNION ALL SELECT intProductCodeId = '' + CAST(intProductCodeId AS NVARCHAR(10)) 
		+ CASE WHEN strProductCode IS NULL THEN '', strProductCode = NULL'' ELSE '', strProductCode = '''''' + strProductCode + ''''''''  END
		+ CASE WHEN strDescription IS NULL THEN '', strDescription = NULL'' ELSE '', strDescription = '''''' + strDescription + ''''''''  END
		+ CASE WHEN strProductCodeGroup IS NULL THEN '', strProductCodeGroup = NULL'' ELSE '', strProductCodeGroup = '''''' + strProductCodeGroup + ''''''''  END
		+ CASE WHEN strNote IS NULL THEN '', strNote = NULL'' ELSE '', strNote = '''''' + strNote + '''''''' END 
		+ '', intMasterId = '' + CASE WHEN intMasterId IS NULL THEN CAST(' + CAST(@TaxAuthorityId AS NVARCHAR(10)) + ' AS NVARCHAR(20)) + CAST(intProductCodeId AS NVARCHAR(20)) ELSE CAST(intMasterId AS NVARCHAR(20)) END -- First 2 digit for TaxAuthorityCodeID
	from tblTFProductCode
	where intTaxAuthorityId = ' + CAST(@TaxAuthorityId AS NVARCHAR(10)) + ''

	SET @ProductCodeQueryALL += @ProductCodeQuery + CHAR(10) +  '*/

	DECLARE @ProductCodes AS TFProductCodes

	INSERT INTO @ProductCodes (
		intProductCodeId
		, strProductCode
		, strDescription
		, strProductCodeGroup
		, strNote
		, intMasterId
	)
	-- Insert generated script here. Remove first instance of "UNION ALL "'

	PRINT @ProductCodeQueryALL

	EXEC PrintSQLResults @ProductCodeQuery, @ProductResults OUTPUT

	PRINT @ProductResults

	PRINT (CHAR(10) + 'EXEC uspTFUpgradeProductCodes @TaxAuthorityCode = @TaxAuthorityCode, @ProductCodes = @ProductCodes')



	DECLARE @TaxCategoryQuery NVARCHAR(MAX)
		, @TaxCategoryQueryALL NVARCHAR(MAX)
		, @TaxCategoryResults NVARCHAR(MAX)

	SET @TaxCategoryQueryALL = '
	-- Tax Category
	/* Generate script for Tax Categories. Specify Tax Authority Id to filter out specific Tax Categories only.' + CHAR(10)

	SET @TaxCategoryQuery = 'select strQuery = ''UNION ALL SELECT intTaxCategoryId = '' + CAST(intTaxCategoryId AS NVARCHAR(10))
		+ CASE WHEN strState IS NULL THEN '', strState = NULL'' ELSE '', strState = '''''' + strState + ''''''''  END
		+ CASE WHEN strTaxCategory IS NULL THEN '', strTaxCategory = NULL'' ELSE '', strTaxCategory = '''''' + strTaxCategory + ''''''''  END
		+ '', intMasterId = '' + CASE WHEN intMasterId IS NULL THEN CAST(' + CAST(@TaxAuthorityId AS NVARCHAR(10)) + ' AS NVARCHAR(20)) + CAST(intTaxCategoryId AS NVARCHAR(20)) ELSE CAST(intMasterId AS NVARCHAR(20)) END
	from tblTFTaxCategory
	where intTaxAuthorityId = ' + CAST(@TaxAuthorityId AS NVARCHAR(10)) + ''

	SET @TaxCategoryQueryALL += @TaxCategoryQuery + CHAR(10) +  '*/

	DECLARE @TaxCategories AS TFTaxCategory

	INSERT INTO @TaxCategories(
		intTaxCategoryId
		, strState
		, strTaxCategory
		, intMasterId
	)
	-- Insert generated script here. Remove first instance of "UNION ALL "'

	PRINT @TaxCategoryQueryALL

	EXEC PrintSQLResults @TaxCategoryQuery, @TaxCategoryResults OUTPUT

	PRINT @TaxCategoryResults

	PRINT (CHAR(10) + 'EXEC uspTFUpgradeTaxCategories @TaxAuthorityCode = @TaxAuthorityCode, @TaxCategories = @TaxCategories')
	


	DECLARE @RCQuery NVARCHAR(MAX)
		, @RCQueryALL NVARCHAR(MAX)
		, @RCResults NVARCHAR(MAX)

	SET @RCQueryALL = '
	-- Reporting Component
	/* Generate script for Reporting Components. Specify Tax Authority Id to filter out specific Reporting Components only.' + CHAR(10)

	SET @RCQuery = 'select strQuery = ''UNION ALL SELECT intReportingComponentId = '' + CAST(intReportingComponentId AS NVARCHAR(10))
		+ CASE WHEN strFormCode IS NULL THEN '', strFormCode = NULL'' ELSE '', strFormCode = '''''' + strFormCode + ''''''''  END
		+ CASE WHEN strFormName IS NULL THEN '', strFormName = NULL'' ELSE '', strFormName = '''''' + strFormName + ''''''''  END
		+ CASE WHEN strScheduleCode IS NULL THEN '', strScheduleCode = NULL'' ELSE '', strScheduleCode = '''''' + strScheduleCode + ''''''''  END
		+ CASE WHEN strScheduleName IS NULL THEN '', strScheduleName = NULL'' ELSE '', strScheduleName = '''''' + strScheduleName + '''''''' END 
		+ CASE WHEN strType IS NULL THEN '', strType = NULL'' ELSE '', strType = '''''' + strType + '''''''' END
		+ CASE WHEN strNote IS NULL THEN '', strNote = NULL'' ELSE '', strNote = '''''' + strNote + '''''''' END
		+ CASE WHEN strTransactionType IS NULL THEN '', strTransactionType = NULL'' ELSE '', strTransactionType = '''''' + strTransactionType + '''''''' END
		+ CASE WHEN strStoredProcedure IS NULL THEN '', strStoredProcedure = NULL'' ELSE '', strStoredProcedure = '''''' + strStoredProcedure + '''''''' END
		+ CASE WHEN intSort IS NULL THEN '', intSort = NULL'' ELSE '', intSort = '''''' + CAST(intSort AS NVARCHAR(10)) + ''''''''  END
		+ CASE WHEN intComponentTypeId IS NULL THEN '', intComponentTypeId = NULL'' ELSE '', intComponentTypeId = '''''' + CAST(intComponentTypeId AS NVARCHAR(10)) + ''''''''  END
		+ '', intMasterId = '' + CASE WHEN intMasterId IS NULL THEN CAST(' + CAST(@TaxAuthorityId AS NVARCHAR(10)) + ' AS NVARCHAR(20)) + CAST(intReportingComponentId AS NVARCHAR(20)) ELSE CAST(intMasterId AS NVARCHAR(20)) END
	from tblTFReportingComponent
	where intTaxAuthorityId = ' + CAST(@TaxAuthorityId AS NVARCHAR(10)) + ''

	SET @RCQueryALL += @RCQuery + CHAR(10) +  '*/

	DECLARE @ReportingComponent AS TFReportingComponent

	INSERT INTO @ReportingComponent(
		intReportingComponentId
		, strFormCode
		, strFormName
		, strScheduleCode
		, strScheduleName
		, strType
		, strNote
		, strTransactionType
		, strStoredProcedure
		, intSort
		, intComponentTypeId
		, intMasterId
	)
	-- Insert generated script here. Remove first instance of "UNION ALL "'

	PRINT @RCQueryALL

	EXEC PrintSQLResults @RCQuery, @RCResults OUTPUT

	PRINT @RCResults

	PRINT (CHAR(10) + 'EXEC uspTFUpgradeReportingComponents @TaxAuthorityCode = @TaxAuthorityCode, @ReportingComponent = @ReportingComponent')
	


	DECLARE @TaxCriteriaQuery NVARCHAR(MAX)
		, @TaxCriteriaQueryALL NVARCHAR(MAX)
		, @TaxCriteriaResults NVARCHAR(MAX)

	SET @TaxCriteriaQueryALL = '
	-- Tax Criteria
	/* Generate script for Tax Criteria. Specify Tax Authority Id to filter out specific Tax Criteria only.' + CHAR(10)

	SET @TaxCriteriaQuery = 'select strQuery = ''UNION ALL SELECT intTaxCriteriaId = '' + CAST(intReportingComponentCriteriaId AS NVARCHAR(10))
		+ CASE WHEN TaxCat.strTaxCategory IS NULL THEN '', strTaxCategory = NULL'' ELSE '', strTaxCategory = '''''' + TaxCat.strTaxCategory + ''''''''  END
		+ CASE WHEN TaxCat.strState IS NULL THEN '', strState = NULL'' ELSE '', strState = '''''' + TaxCat.strState + ''''''''  END
		+ CASE WHEN strFormCode IS NULL THEN '', strFormCode = NULL'' ELSE '', strFormCode = '''''' + strFormCode + ''''''''  END
		+ CASE WHEN strScheduleCode IS NULL THEN '', strScheduleCode = NULL'' ELSE '', strScheduleCode = '''''' + strScheduleCode + ''''''''  END
		+ CASE WHEN strType IS NULL THEN '', strType = NULL'' ELSE '', strType = '''''' + strType + '''''''' END
		+ CASE WHEN strCriteria IS NULL THEN '', strCriteria = NULL'' ELSE '', strCriteria = '''''' + strCriteria + '''''''' END
		+ '', intMasterId = '' + CASE WHEN TaxCrit.intMasterId IS NULL THEN CAST(' + CAST(@TaxAuthorityId AS NVARCHAR(10)) + ' AS NVARCHAR(20)) + CAST(intReportingComponentCriteriaId AS NVARCHAR(20)) ELSE CAST(TaxCrit.intMasterId AS NVARCHAR(20)) END
	from tblTFReportingComponentCriteria TaxCrit
	left join tblTFTaxCategory TaxCat ON TaxCat.intTaxCategoryId = TaxCrit.intTaxCategoryId
	left join tblTFReportingComponent RC ON RC.intReportingComponentId = TaxCrit.intReportingComponentId
	where RC.intTaxAuthorityId = ' + CAST(@TaxAuthorityId AS NVARCHAR(10)) + ' and TaxCat.intTaxAuthorityId = ' + CAST(@TaxAuthorityId AS NVARCHAR(10)) + ''

	SET @TaxCriteriaQueryALL += @TaxCriteriaQuery + CHAR(10) +  '*/

	DECLARE @TaxCriteria AS TFTaxCriteria

	INSERT INTO @TaxCriteria(
		intTaxCriteriaId
		, strTaxCategory
		, strState
		, strFormCode
		, strScheduleCode
		, strType
		, strCriteria
		, intMasterId
	)
	-- Insert generated script here. Remove first instance of "UNION ALL "'

	PRINT @TaxCriteriaQueryALL

	EXEC PrintSQLResults @TaxCriteriaQuery, @TaxCriteriaResults OUTPUT

	PRINT @TaxCriteriaResults

	PRINT (CHAR(10) + 'EXEC uspTFUpgradeTaxCriteria @TaxAuthorityCode = @TaxAuthorityCode, @TaxCriteria = @TaxCriteria')
	


	DECLARE @RCPCQuery NVARCHAR(MAX)
		, @RCPCQueryALL NVARCHAR(MAX)
		, @RCPCResults NVARCHAR(MAX)

	SET @RCPCQueryALL = '
	-- Reporting Component - Base
	/* Generate script for Valid Product Codes. Specify Tax Authority Id to filter out specific Valid Product Codes only.' + CHAR(10)

	SET @RCPCQuery = 'select strQuery = ''UNION ALL SELECT intValidProductCodeId = '' + CAST(intReportingComponentProductCodeId AS NVARCHAR(10))
		+ CASE WHEN PC.strProductCode IS NULL THEN '', strProductCode = NULL'' ELSE '', strProductCode = '''''' + PC.strProductCode + ''''''''  END
		+ CASE WHEN RC.strFormCode IS NULL THEN '', strFormCode = NULL'' ELSE '', strFormCode = '''''' + strFormCode + ''''''''  END
		+ CASE WHEN strScheduleCode IS NULL THEN '', strScheduleCode = NULL'' ELSE '', strScheduleCode = '''''' + strScheduleCode + ''''''''  END
		+ CASE WHEN RC.strType IS NULL THEN '', strType = '''''''''' ELSE '', strType = '''''' + RC.strType + '''''''' END
		+ '', intMasterId = '' + CASE WHEN RCPC.intMasterId IS NULL THEN CAST(' + CAST(@TaxAuthorityId AS NVARCHAR(10)) + ' AS NVARCHAR(20)) + CAST(intReportingComponentProductCodeId AS NVARCHAR(20)) ELSE CAST(RCPC.intMasterId AS NVARCHAR(20)) END
	from tblTFReportingComponentProductCode RCPC
	left join tblTFProductCode PC ON PC.intProductCodeId= RCPC.intProductCodeId
	left join tblTFReportingComponent RC ON RC.intReportingComponentId = RCPC.intReportingComponentId
	where RC.intTaxAuthorityId = ' + CAST(@TaxAuthorityId AS NVARCHAR(10)) + ''

	SET @RCPCQueryALL += @RCPCQuery + CHAR(10) +  '*/

	DECLARE @ValidProductCodes AS TFValidProductCodes
	
	INSERT INTO @ValidProductCodes(
		intValidProductCodeId
		, strProductCode
		, strFormCode
		, strScheduleCode
		, strType
		, intMasterId
	)
	-- Insert generated script here. Remove first instance of "UNION ALL "'

	PRINT @RCPCQueryALL

	EXEC PrintSQLResults @RCPCQuery, @RCPCResults OUTPUT

	PRINT @RCPCResults

	PRINT (CHAR(10) + 'EXEC uspTFUpgradeValidProductCodes @TaxAuthorityCode = @TaxAuthorityCode, @ValidProductCodes = @ValidProductCodes')
	


	DECLARE @RCOSQuery NVARCHAR(MAX)
		, @RCOSQueryALL NVARCHAR(MAX)
		, @RCOSResults NVARCHAR(MAX)

	SET @RCOSQueryALL = '
	/* Generate script for Valid Origin States. Specify Tax Authority Id to filter out specific Valid Origin States only.' + CHAR(10)

	SET @RCOSQuery = 'select strQuery = ''UNION ALL SELECT intValidOriginStateId = '' + CAST(intReportingComponentOriginStateId AS NVARCHAR(10))
		+ CASE WHEN RC.strFormCode IS NULL THEN '', strFormCode = NULL'' ELSE '', strFormCode = '''''' + RC.strFormCode + ''''''''  END
		+ CASE WHEN RC.strScheduleCode IS NULL THEN '', strScheduleCode = NULL'' ELSE '', strScheduleCode = '''''' + RC.strScheduleCode + ''''''''  END
		+ CASE WHEN RC.strType IS NULL THEN '', strType = NULL'' ELSE '', strType = '''''' + RC.strType + '''''''' END
		+ CASE WHEN ODS.strOriginDestinationState COLLATE Latin1_General_CI_AS IS NULL THEN '', strState = NULL'' ELSE '', strState = '''''' + ODS.strOriginDestinationState COLLATE Latin1_General_CI_AS + ''''''''  END
		+ CASE WHEN RCOS.strType IS NULL THEN '', strStatus = NULL'' ELSE '', strStatus = '''''' + RCOS.strType + ''''''''  END
		+ '', intMasterId = '' + CASE WHEN RCOS.intMasterId IS NULL THEN CAST(' + CAST(@TaxAuthorityId AS NVARCHAR(10)) + ' AS NVARCHAR(20)) + CAST(intReportingComponentOriginStateId AS NVARCHAR(20)) ELSE CAST(RCOS.intMasterId AS NVARCHAR(20)) END
	from tblTFReportingComponentOriginState RCOS
	left join tblTFOriginDestinationState ODS ON ODS.intOriginDestinationStateId= RCOS.intOriginDestinationStateId
	left join tblTFReportingComponent RC ON RC.intReportingComponentId = RCOS.intReportingComponentId
	where RC.intTaxAuthorityId = ' + CAST(@TaxAuthorityId AS NVARCHAR(10)) + ''

	SET @RCOSQueryALL += @RCOSQuery + CHAR(10) +  '*/

	DECLARE @ValidOriginStates AS TFValidOriginStates

	INSERT INTO @ValidOriginStates(
		intValidOriginStateId
		, strFormCode
		, strScheduleCode
		, strType
		, strState
		, strStatus
		, intMasterId
	)
	-- Insert generated script here. Remove first instance of "UNION ALL "'

	PRINT @RCOSQueryALL

	EXEC PrintSQLResults @RCOSQuery, @RCOSResults OUTPUT

	PRINT @RCOSResults

	PRINT (CHAR(10) + 'EXEC uspTFUpgradeValidOriginStates @TaxAuthorityCode = @TaxAuthorityCode, @ValidOriginStates = @ValidOriginStates')



	DECLARE @RCDSQuery NVARCHAR(MAX)
		, @RCDSQueryALL NVARCHAR(MAX)
		, @RCDSResults NVARCHAR(MAX)

	SET @RCDSQueryALL = '
	/* Generate script for Valid Destination States. Specify Tax Authority Id to filter out specific Valid Destination States only.' + CHAR(10)

	SET @RCDSQuery = 'select strQuery = ''UNION ALL SELECT intValidDestinationStateId = '' + CAST(intReportingComponentDestinationStateId AS NVARCHAR(10))
		+ CASE WHEN RC.strFormCode IS NULL THEN '', strFormCode = NULL'' ELSE '', strFormCode = '''''' + RC.strFormCode + ''''''''  END
		+ CASE WHEN RC.strScheduleCode IS NULL THEN '', strScheduleCode = NULL'' ELSE '', strScheduleCode = '''''' + RC.strScheduleCode + ''''''''  END
		+ CASE WHEN RC.strType IS NULL THEN '', strType = NULL'' ELSE '', strType = '''''' + RC.strType + '''''''' END
		+ CASE WHEN ODS.strOriginDestinationState COLLATE Latin1_General_CI_AS IS NULL THEN '', strState = NULL'' ELSE '', strState = '''''' + ODS.strOriginDestinationState COLLATE Latin1_General_CI_AS + ''''''''  END
		+ CASE WHEN RCDS.strType IS NULL THEN '', strStatus = NULL'' ELSE '', strStatus = '''''' + RCDS.strType + ''''''''  END
		+ '', intMasterId = '' + CASE WHEN RCDS.intMasterId IS NULL THEN CAST(' + CAST(@TaxAuthorityId AS NVARCHAR(10)) + ' AS NVARCHAR(20)) + CAST(intReportingComponentDestinationStateId AS NVARCHAR(20)) ELSE CAST(RCDS.intMasterId AS NVARCHAR(20)) END
	from tblTFReportingComponentDestinationState RCDS
	left join tblTFOriginDestinationState ODS ON ODS.intOriginDestinationStateId= RCDS.intOriginDestinationStateId
	left join tblTFReportingComponent RC ON RC.intReportingComponentId = RCDS.intReportingComponentId
	where RC.intTaxAuthorityId = ' + CAST(@TaxAuthorityId AS NVARCHAR(10)) + ''

	SET @RCDSQueryALL += @RCDSQuery + CHAR(10) +  '*/

	DECLARE @ValidDestinationStates AS TFValidDestinationStates

	INSERT INTO @ValidDestinationStates(
		intValidDestinationStateId
		, strFormCode
		, strScheduleCode
		, strType
		, strState
		, strStatus
		, intMasterId
	)
	
	-- Insert generated script here. Remove first instance of "UNION ALL "'

	PRINT @RCDSQueryALL

	EXEC PrintSQLResults @RCDSQuery, @RCDSResults OUTPUT

	PRINT @RCDSResults

	PRINT (CHAR(10) + 'EXEC uspTFUpgradeValidDestinationStates @TaxAuthorityCode = @TaxAuthorityCode, @ValidDestinationStates = @ValidDestinationStates')
	


	DECLARE @RCConfigQuery NVARCHAR(MAX)
		, @RCConfigQueryALL NVARCHAR(MAX)
		, @RCConfigResults NVARCHAR(MAX)

	SET @RCConfigQueryALL = '
	-- Reporting Component - Configuration
	/* Generate script for Reporting Component - Configurations. Specify Tax Authority Id to filter out specific Reporting Component - Configurations only.' + CHAR(10)

	SET @RCConfigQuery = 'select strQuery = ''UNION ALL SELECT intReportTemplateId = '' + CAST(intReportingComponentConfigurationId AS NVARCHAR(10))
		+ CASE WHEN RC.strFormCode IS NULL THEN '', strFormCode = NULL'' ELSE '', strFormCode = '''''' + RC.strFormCode + ''''''''  END
		+ CASE WHEN RC.strScheduleCode IS NULL THEN '', strScheduleCode = NULL'' ELSE '', strScheduleCode = '''''' + RC.strScheduleCode + ''''''''  END
		+ CASE WHEN RC.strType IS NULL THEN '', strType = NULL'' ELSE '', strType = '''''' + RC.strType + '''''''' END
		+ CASE WHEN strTemplateItemId IS NULL THEN '', strTemplateItemId = NULL'' ELSE '', strTemplateItemId = '''''' + strTemplateItemId + ''''''''  END
		+ CASE WHEN strReportSection IS NULL THEN '', strReportSection = NULL'' ELSE '', strReportSection = '''''' + strReportSection + ''''''''  END
		+ CASE WHEN intReportItemSequence IS NULL THEN '', intReportItemSequence = NULL'' ELSE '', intReportItemSequence = '''''' + CAST(intReportItemSequence AS NVARCHAR(10)) + ''''''''  END
		+ CASE WHEN intTemplateItemNumber IS NULL THEN '', intTemplateItemNumber = NULL'' ELSE '', intTemplateItemNumber = '''''' + CAST(intTemplateItemNumber AS NVARCHAR(10)) + ''''''''  END
		+ CASE WHEN strDescription IS NULL THEN '', strDescription = NULL'' ELSE '', strDescription = '''''' + REPLACE(strDescription, '''''''', '''''''''''') + ''''''''  END
		+ CASE WHEN Config.strScheduleCode IS NULL THEN '', strScheduleList = NULL'' ELSE '', strScheduleList = '''''' + Config.strScheduleCode + ''''''''  END
		+ CASE WHEN strConfiguration IS NULL THEN '', strConfiguration = NULL'' ELSE '', strConfiguration = '''''' + strConfiguration + ''''''''  END
		+ CASE WHEN ysnConfiguration IS NULL THEN '', ysnConfiguration = NULL'' ELSE '', ysnConfiguration = '''''' + CAST(ysnConfiguration AS NVARCHAR(5)) + ''''''''  END
		+ CASE WHEN ysnUserDefinedValue IS NULL THEN '', ysnUserDefinedValue = NULL'' ELSE '', ysnUserDefinedValue = '''''' + CAST(ysnUserDefinedValue AS NVARCHAR(5)) + ''''''''  END
		+ CASE WHEN strLastIndexOf IS NULL THEN '', strLastIndexOf = NULL'' ELSE '', strLastIndexOf = '''''' + strLastIndexOf + ''''''''  END
		+ CASE WHEN strSegment IS NULL THEN '', strSegment = NULL'' ELSE '', strSegment = '''''' + strSegment + ''''''''  END
		+ CASE WHEN intConfigurationSequence IS NULL THEN '', intConfigurationSequence = NULL'' ELSE '', intConfigurationSequence = '''''' + CAST(intConfigurationSequence AS NVARCHAR(10)) + ''''''''  END
		+ '', intMasterId = '' + CASE WHEN Config.intMasterId IS NULL THEN CAST(' + CAST(@TaxAuthorityId AS NVARCHAR(10)) + ' AS NVARCHAR(20)) + CAST(intReportingComponentConfigurationId AS NVARCHAR(20)) ELSE CAST(Config.intMasterId AS NVARCHAR(20)) END
	from tblTFReportingComponentConfiguration Config
	left join tblTFReportingComponent RC ON RC.intReportingComponentId = Config.intReportingComponentId
	WHERE RC.intTaxAuthorityId = ' + CAST(@TaxAuthorityId AS NVARCHAR(10)) + ''

	SET @RCConfigQueryALL += @RCConfigQuery + CHAR(10) +  '*/

	DECLARE @ReportingComponentConfigurations AS TFReportingComponentConfigurations

	INSERT INTO @ReportingComponentConfigurations(
		intReportTemplateId
		, strFormCode
		, strScheduleCode
		, strType
		, strTemplateItemId
		, strReportSection
		, intReportItemSequence
		, intTemplateItemNumber
		, strDescription
		, strScheduleList
		, strConfiguration
		, ysnConfiguration
		, ysnUserDefinedValue
		, strLastIndexOf
		, strSegment
		, intSort
		, intMasterId
	)
	-- Insert generated script here. Remove first instance of "UNION ALL "'

	PRINT @RCConfigQueryALL

	EXEC PrintSQLResults @RCConfigQuery, @RCConfigResults OUTPUT

	PRINT @RCConfigResults

	PRINT (CHAR(10) + 'EXEC uspTFUpgradeReportingComponentConfigurations @TaxAuthorityCode = @TaxAuthorityCode, @ReportingComponentConfigurations = @ReportingComponentConfigurations')
	


	DECLARE @RCODQuery NVARCHAR(MAX)
		, @RCODQueryALL NVARCHAR(MAX)
		, @RCODResults NVARCHAR(MAX)

	SET @RCODQueryALL = '
	-- Reporting Component - Output Designer
	/* Generate script for Reporting Component - Output Designer. Specify Tax Authority Id to filter out specific Reporting Component - Output Designer only.' + CHAR(10)

	SET @RCODQuery = 'select strQuery = ''UNION ALL SELECT intScheduleColumnId = '' + CAST(intReportingComponentFieldId AS NVARCHAR(10))
		+ CASE WHEN strFormCode IS NULL THEN '', strFormCode = NULL'' ELSE '', strFormCode = '''''' + strFormCode + ''''''''  END
		+ CASE WHEN strScheduleCode IS NULL THEN '', strScheduleCode = NULL'' ELSE '', strScheduleCode = '''''' + strScheduleCode + ''''''''  END
		+ CASE WHEN strType IS NULL THEN '', strType = NULL'' ELSE '', strType = '''''' + strType + '''''''' END
		+ CASE WHEN strColumn IS NULL THEN '', strColumn = NULL'' ELSE '', strColumn = '''''' + strColumn + '''''''' END
		+ CASE WHEN strCaption IS NULL THEN '', strCaption = NULL'' ELSE '', strCaption = '''''' + strCaption + '''''''' END
		+ CASE WHEN strFormat IS NULL THEN '', strFormat = NULL'' ELSE '', strFormat = '''''' + strFormat + '''''''' END
		+ CASE WHEN strFooter IS NULL THEN '', strFooter = NULL'' ELSE '', strFooter = '''''' + strFooter + '''''''' END
		+ CASE WHEN intWidth IS NULL THEN '', intWidth = NULL'' ELSE '', intWidth = '' + CAST(intWidth AS NVARCHAR(10)) END
		+ '', intMasterId = '' + CASE WHEN RCF.intMasterId IS NULL THEN CAST(' + CAST(@TaxAuthorityId AS NVARCHAR(10)) + ' AS NVARCHAR(20)) + CAST(intReportingComponentFieldId AS NVARCHAR(20)) ELSE CAST(RCF.intMasterId AS NVARCHAR(20)) END
	from tblTFReportingComponentField RCF
	left join tblTFReportingComponent RC on RC.intReportingComponentId = RCF.intReportingComponentId
	where RC.intTaxAuthorityId = ' + CAST(@TaxAuthorityId AS NVARCHAR(10)) + ''

	SET @RCODQueryALL += @RCODQuery + CHAR(10) +  '*/

	DECLARE @ReportingComponentOutputDesigners AS TFReportingComponentOutputDesigners

	INSERT INTO @ReportingComponentOutputDesigners(
		intScheduleColumnId
		, strFormCode
		, strScheduleCode
		, strType
		, strColumn
		, strCaption
		, strFormat
		, strFooter
		, intWidth
		, intMasterId
	)
	-- Insert generated script here. Remove first instance of "UNION ALL "'

	PRINT @RCODQueryALL

	EXEC PrintSQLResults @RCODQuery, @RCODResults OUTPUT

	PRINT @RCODResults

	PRINT (CHAR(10) + 'EXEC uspTFUpgradeReportingComponentOutputDesigners @TaxAuthorityCode = @TaxAuthorityCode, @ReportingComponentOutputDesigners = @ReportingComponentOutputDesigners')



	DECLARE @FPQuery NVARCHAR(MAX)
		, @FPQueryALL NVARCHAR(MAX)
		, @FPResults NVARCHAR(MAX)

	SET @FPQueryALL = '
	-- Filing Packet
	/* Generate script for Filing Packets. Specify Tax Authority Id to filter out specific Filing Packets only.' + CHAR(10)

	SET @FPQuery = 'select strQuery = ''UNION ALL SELECT intFilingPacketId = '' + CAST(intFilingPacketId AS NVARCHAR(10))
		+ CASE WHEN strFormCode IS NULL THEN '', strFormCode = NULL'' ELSE '', strFormCode = '''''' + strFormCode + ''''''''  END
		+ CASE WHEN strScheduleCode IS NULL THEN '', strScheduleCode = NULL'' ELSE '', strScheduleCode = '''''' + strScheduleCode + ''''''''  END
		+ CASE WHEN strType IS NULL THEN '', strType = NULL'' ELSE '', strType = '''''' + strType + '''''''' END
		+ CASE WHEN ysnStatus IS NULL THEN '', ysnStatus = NULL'' ELSE '', ysnStatus = '' + CAST(ysnStatus AS NVARCHAR) END
		+ CASE WHEN intFrequency IS NULL THEN '', intFrequency = NULL'' ELSE '', intFrequency = '' + CAST(intFrequency AS NVARCHAR(10)) END
		+ '', intMasterId = '' + CASE WHEN FP.intMasterId IS NULL THEN CAST(' + CAST(@TaxAuthorityId AS NVARCHAR(10)) + ' AS NVARCHAR(20)) + CAST(intFilingPacketId AS NVARCHAR(20)) ELSE CAST(FP.intMasterId AS NVARCHAR(20)) END
	from tblTFFilingPacket FP
	left join tblTFReportingComponent RC on RC.intReportingComponentId = FP.intReportingComponentId
	where FP.intTaxAuthorityId = ' + CAST(@TaxAuthorityId AS NVARCHAR(10)) + ''

	SET @FPQueryALL += @FPQuery + CHAR(10) +  '*/

	DECLARE @FilingPackets AS TFFilingPackets

	INSERT INTO @FilingPackets(
		intFilingPacketId
		, strFormCode
		, strScheduleCode
		, strType
		, ysnStatus
		, intFrequency
		, intMasterId
	)
	-- Insert generated script here. Remove first instance of "UNION ALL "'

	PRINT @FPQueryALL

	EXEC PrintSQLResults @FPQuery, @FPResults OUTPUT

	PRINT @FPResults

	PRINT (CHAR(10) + 'EXEC uspTFUpgradeFilingPackets @TaxAuthorityCode = @TaxAuthorityCode, @FilingPackets = @FilingPackets')

	PRINT (CHAR(10) + 'GO')
	

END TRY
BEGIN CATCH
	SELECT 
		@ErrorMessage = ERROR_MESSAGE(),
		@ErrorSeverity = ERROR_SEVERITY(),
		@ErrorState = ERROR_STATE();

	-- Use RAISERROR inside the CATCH block to return error
	-- information about the original error that caused
	-- execution to jump to the CATCH block.
	RAISERROR (
		@ErrorMessage, -- Message text.
		@ErrorSeverity, -- Severity.
		@ErrorState -- State.
	);
END CATCH