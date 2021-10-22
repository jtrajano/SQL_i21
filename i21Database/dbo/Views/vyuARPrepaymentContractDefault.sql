CREATE VIEW [dbo].[vyuARPrepaymentContractDefault]
AS
SELECT CONTRACTS.*
	 , intPrepayContractId		= CAST(ROW_NUMBER() OVER (ORDER BY CONTRACTS.strContractNumber) AS INT)
	 , strCustomerName			= ARC.strName
	 , intBillToId				= ARC.intBillToId
	 , intShipToId				= ARC.intShipToId
	 , intEntityContactId		= ARC.intEntityContactId
	 , strShipToLocationName	= ARC.strShipToLocationName
	 , strShipToAddress 		= ARC.strShipToAddress
	 , strShipToCity			= ARC.strShipToCity
	 , strShipToState			= ARC.strShipToState
	 , strShipToZipCode			= ARC.strShipToZipCode
	 , strShipToCountry			= ARC.strShipToCountry
	 , strBillToLocationName	= ARC.strBillToLocationName
	 , strBillToAddress			= ARC.strBillToAddress
	 , strBillToCity			= ARC.strBillToCity
	 , strBillToState			= ARC.strBillToState
	 , strBillToZipCode			= ARC.strBillToZipCode
	 , strBillToCountry			= ARC.strBillToCountry 
	 , strTerm					= SMT.strTerm
	 , strCompanyLocationName	= LOC.strLocationName
	 , strSalespersonName		= SP.strName
	 , strFreightTerm			= FT.strFreightTerm
FROM (
	SELECT intContractHeaderId		= CC.intContractHeaderId
		 , intContractDetailId		= CC.intContractDetailId
		 , intItemContractHeaderId	= NULL
		 , intItemContractDetailId	= NULL
		 , intItemCategoryId		= NULL
		 , strContractNumber		= CC.strContractNumber
		 , intContractSeq			= CC.intContractSeq
		 , strContractType			= CC.strContractType
		 , strContractCategoryId	= NULL
		 , dtmStartDate				= CC.dtmStartDate
		 , dtmEndDate				= CC.dtmEndDate
		 , dtmDueDate				= dbo.fnGetDueDateBasedOnTerm(CAST(CC.dtmStartDate AS DATE), CC.intTermId)
		 , strContractStatus		= CC.strContractStatus
		 , intEntityCustomerId		= CC.intEntityCustomerId		 
		 , intCurrencyId			= CC.intCurrencyId
		 , strCurrency				= CC.strSubCurrency
		 , intCompanyLocationId		= CC.intCompanyLocationId		 
		 , intItemId				= CC.intItemId
		 , strItemNo				= CC.strItemNo
		 , strItemDescription		= CC.strItemDescription
		 , intOrderUOMId			= CC.intOrderUOMId
		 , strOrderUnitMeasure		= CC.strOrderUnitMeasure
		 , intItemUOMId				= CC.intItemUOMId
		 , strUnitMeasure			= CC.strUnitMeasure
		 , intPricingTypeId			= CC.intPricingTypeId
		 , strPricingType			= CC.strPricingType
		 , dblOrderPrice			= CC.dblOrderPrice
		 , dblCashPrice				= CC.dblCashPrice
		 , intSubCurrencyId			= CC.intSubCurrencyId
		 , dblSubCurrencyRate		= CC.dblSubCurrencyRate
		 , strSubCurrency			= CC.strSubCurrency
		 , intPriceItemUOMId		= CC.intPriceItemUOMId
		 , dblBalance				= CC.dblBalance
		 , dblScheduleQty			= ISNULL(CC.dblScheduleQty, 0.000000)
		 , dblAvailableQty			= CC.dblAvailableQty
		 , dblDetailQuantity		= CC.dblDetailQuantity
		 , dblOrderQuantity			= CC.dblOrderQuantity
		 , dblShipQuantity			= CC.dblShipQuantity
		 , ysnUnlimitedQuantity		= CC.ysnUnlimitedQuantity
		 , ysnLoad					= CC.ysnLoad
		 , ysnAllowedToShow			= CC.ysnAllowedToShow
		 , intTermId				= CC.intTermId		 
		 , intShipViaId				= CC.intShipViaId		 
		 , intDestinationGradeId	= CC.intDestinationGradeId
		 , strDestinationGrade		= CC.strDestinationGrade
		 , intDestinationWeightId	= CC.intDestinationWeightId
		 , strDestinationWeight		= CC.strDestinationWeight
		 , intCategoryId			= NULL
		 , strCategoryCode			= NULL
		 , strCategoryDescription	= NULL
		 , intEntitySalespersonId	= NULL
		 , intFreightTermId			= CC.intFreightTermId
	FROM vyuCTCustomerContract CC
	WHERE CC.intCurrencyId = (
		SELECT TOP 1 intCurrencyID = ISNULL(SMC.intMainCurrencyId, SMC.intCurrencyID)
		FROM tblCTContractDetail CTD 
		INNER JOIN tblSMCurrency SMC ON CTD.intCurrencyId IN (SMC.intCurrencyID, SMC.intMainCurrencyId)
		WHERE CC.intContractHeaderId = CTD.intContractHeaderId
		ORDER BY intContractSeq ASC
	) 
	AND CC.strContractStatus NOT IN ('Complete','Cancelled')

	UNION ALL

	SELECT intContractHeaderId		= NULL
		 , intContractDetailId		= NULL
		 , intItemContractHeaderId	= ICC.intItemContractHeaderId
		 , intItemContractDetailId	= ICD.intItemContractDetailId
		 , intItemCategoryId		= NULL
		 , strContractNumber		= ICC.strContractNumber
		 , intContractSeq			= ICD.intLineNo
		 , strContractType			= 'Sale'
		 , strContractCategoryId	= ICC.strContractCategoryId
		 , dtmStartDate				= ICC.dtmContractDate
		 , dtmEndDate				= ICC.dtmExpirationDate
		 , dtmDueDate				= dbo.fnGetDueDateBasedOnTerm(CAST(ICC.dtmContractDate AS DATE), ICC.intTermId)
		 , strContractStatus		= CASE WHEN ICD.intContractStatusId = 1 THEN 'Open' ELSE 'Closed' END
		 , intEntityCustomerId		= ICC.intEntityId		 
		 , intCurrencyId			= ICC.intCurrencyId
		 , strCurrency				= NULL
		 , intCompanyLocationId		= ICC.intCompanyLocationId		 
		 , intItemId				= ICD.intItemId
		 , strItemNo				= ITEM.strItemNo
		 , strItemDescription		= ICD.strItemDescription
		 , intOrderUOMId			= ICD.intItemUOMId
		 , strOrderUnitMeasure		= UOM.strUnitMeasure
		 , intItemUOMId				= ICD.intItemUOMId
		 , strUnitMeasure			= UOM.strUnitMeasure
		 , intPricingTypeId			= NULL
		 , strPricingType			= 'Item Contract'
		 , dblOrderPrice			= ICD.dblPrice
		 , dblCashPrice				= ICD.dblPrice
		 , intSubCurrencyId			= NULL
		 , dblSubCurrencyRate		= NULL
		 , strSubCurrency			= NULL
		 , intPriceItemUOMId		= ICD.intItemUOMId
		 , dblBalance				= ICD.dblBalance
		 , dblScheduleQty			= ISNULL(ICD.dblScheduled, 0.000000)
		 , dblAvailableQty			= ICD.dblAvailable
		 , dblDetailQuantity		= ICD.dblContracted
		 , dblOrderQuantity			= ICD.dblContracted
		 , dblShipQuantity			= ICD.dblAvailable
		 , ysnUnlimitedQuantity		= CAST(0 AS BIT)
		 , ysnLoad					= CAST(0 AS BIT)
		 , ysnAllowedToShow			= CAST(1 AS BIT)
		 , intTermId				= ICC.intTermId		 
		 , intShipViaId				= NULL
		 , intDestinationGradeId	= NULL
		 , strDestinationGrade		= NULL
		 , intDestinationWeightId	= NULL
		 , strDestinationWeight		= NULL
		 , intCategoryId			= NULL
		 , strCategoryCode			= NULL
		 , strCategoryDescription	= NULL
		 , intEntitySalespersonId	= ICC.intSalespersonId
		 , intFreightTermId			= ICC.intFreightTermId
	FROM tblCTItemContractHeader ICC
	INNER JOIN tblCTItemContractDetail ICD ON ICC.intItemContractHeaderId = ICD.intItemContractHeaderId
	INNER JOIN tblICItem ITEM ON ICD.intItemId = ITEM.intItemId
	LEFT JOIN vyuARItemUOM UOM ON ICD.intItemUOMId = UOM.intItemUOMId
	WHERE ICD.intContractStatusId = 1
	  AND ICC.strContractCategoryId <> 'Dollar'

	UNION ALL

	SELECT intContractHeaderId		= NULL
		 , intContractDetailId		= NULL
		 , intItemContractHeaderId	= ICC.intItemContractHeaderId
		 , intItemContractDetailId	= NULL
		 , intItemCategoryId		= ICHC.intItemCategoryId
		 , strContractNumber		= ICC.strContractNumber
		 , intContractSeq			= NULL
		 , strContractType			= 'Sale'
		 , strContractCategoryId	= ICC.strContractCategoryId
		 , dtmStartDate				= ICC.dtmContractDate
		 , dtmEndDate				= ICC.dtmExpirationDate
		 , dtmDueDate				= dbo.fnGetDueDateBasedOnTerm(CAST(ICC.dtmContractDate AS DATE), ICC.intTermId)
		 , strContractStatus		= 'Open'
		 , intEntityCustomerId		= ICC.intEntityId		 
		 , intCurrencyId			= ICC.intCurrencyId
		 , strCurrency				= NULL
		 , intCompanyLocationId		= ICC.intCompanyLocationId		 
		 , intItemId				= NULL
		 , strItemNo				= NULL
		 , strItemDescription		= 'Prepay for Item Category ' + ISNULL(IC.strDescription, IC.strCategoryCode)
		 , intOrderUOMId			= NULL
		 , strOrderUnitMeasure		= NULL
		 , intItemUOMId				= NULL
		 , strUnitMeasure			= NULL
		 , intPricingTypeId			= NULL
		 , strPricingType			= 'Item Contract'
		 , dblOrderPrice			= CAST(0 AS NUMERIC(18, 6))
		 , dblCashPrice				= CAST(ICC.dblDollarValue AS NUMERIC(18, 6))
		 , intSubCurrencyId			= NULL
		 , dblSubCurrencyRate		= NULL
		 , strSubCurrency			= NULL
		 , intPriceItemUOMId		= NULL
		 , dblBalance				= CAST(1 AS NUMERIC(18, 6))
		 , dblScheduleQty			= CAST(1 AS NUMERIC(18, 6))
		 , dblAvailableQty			= CAST(1 AS NUMERIC(18, 6))
		 , dblDetailQuantity		= CAST(1 AS NUMERIC(18, 6))
		 , dblOrderQuantity			= CAST(1 AS NUMERIC(18, 6))
		 , dblShipQuantity			= CAST(1 AS NUMERIC(18, 6))
		 , ysnUnlimitedQuantity		= CAST(0 AS BIT)
		 , ysnLoad					= CAST(0 AS BIT)
		 , ysnAllowedToShow			= CAST(1 AS BIT)
		 , intTermId				= ICC.intTermId		 
		 , intShipViaId				= NULL
		 , intDestinationGradeId	= NULL
		 , strDestinationGrade		= NULL
		 , intDestinationWeightId	= NULL
		 , strDestinationWeight		= NULL
		 , intCategoryId			= ICHC.intCategoryId
		 , strCategoryCode			= IC.strCategoryCode
		 , strCategoryDescription	= IC.strDescription
		 , intEntitySalespersonId	= ICC.intSalespersonId
		 , intFreightTermId			= ICC.intFreightTermId
	FROM tblCTItemContractHeader ICC
	INNER JOIN tblCTItemContractHeaderCategory ICHC ON ICC.intItemContractHeaderId = ICHC.intItemContractHeaderId
	INNER JOIN tblICCategory IC ON IC.intCategoryId = ICHC.intCategoryId
	WHERE ICC.strContractCategoryId = 'Dollar'
) CONTRACTS
INNER JOIN vyuARCustomerSearch ARC ON CONTRACTS.intEntityCustomerId = ARC.intEntityId
LEFT OUTER JOIN tblSMTerm SMT ON CONTRACTS.intTermId = SMT.intTermID
LEFT OUTER JOIN tblSMCompanyLocation LOC ON CONTRACTS.intCompanyLocationId = LOC.intCompanyLocationId
LEFT OUTER JOIN tblSMFreightTerms FT ON CONTRACTS.intFreightTermId = FT.intFreightTermId
LEFT OUTER JOIN tblEMEntity SP ON CONTRACTS.intEntitySalespersonId = SP.intEntityId