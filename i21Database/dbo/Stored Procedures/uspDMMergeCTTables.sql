CREATE PROCEDURE [dbo].[uspDMMergeCTTables]
    @remoteDB NVARCHAR(MAX)
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON

DECLARE @SQLString NVARCHAR(MAX) = '';

BEGIN

     -- tblCTContractHeader
    SET @SQLString = N'MERGE tblCTContractHeader AS Target
        USING (SELECT * FROM REMOTEDBSERVER.[repDB].[dbo].[tblCTContractHeader]) AS Source
        ON (Target.intContractHeaderId = Source.intContractHeaderId)
        WHEN MATCHED THEN
            UPDATE SET Target.intConcurrencyId = Source.intConcurrencyId, Target.intContractTypeId = Source.intContractTypeId, Target.intEntityId = Source.intEntityId, Target.intEntityContactId = Source.intEntityContactId, Target.intContractPlanId = Source.intContractPlanId, Target.intCommodityId = Source.intCommodityId, Target.dblQuantity = Source.dblQuantity, Target.intCommodityUOMId = Source.intCommodityUOMId, Target.strContractNumber = Source.strContractNumber, Target.dtmContractDate = Source.dtmContractDate, Target.strCustomerContract = Source.strCustomerContract, Target.dtmDeferPayDate = Source.dtmDeferPayDate, Target.dblDeferPayRate = Source.dblDeferPayRate, Target.intContractTextId = Source.intContractTextId, Target.ysnSigned = Source.ysnSigned, Target.dtmSigned = Source.dtmSigned, Target.ysnPrinted = Source.ysnPrinted, Target.intSalespersonId = Source.intSalespersonId, Target.intGradeId = Source.intGradeId, Target.intWeightId = Source.intWeightId, Target.intCropYearId = Source.intCropYearId, Target.strInternalComment = Source.strInternalComment, Target.strPrintableRemarks = Source.strPrintableRemarks, Target.intAssociationId = Source.intAssociationId, Target.intTermId = Source.intTermId, Target.intPricingTypeId = Source.intPricingTypeId, Target.intApprovalBasisId = Source.intApprovalBasisId, Target.intContractBasisId = Source.intContractBasisId, Target.intPositionId = Source.intPositionId, Target.intInsuranceById = Source.intInsuranceById, Target.intInvoiceTypeId = Source.intInvoiceTypeId, Target.dblTolerancePct = Source.dblTolerancePct, Target.dblProvisionalInvoicePct = Source.dblProvisionalInvoicePct, Target.ysnSubstituteItem = Source.ysnSubstituteItem, Target.ysnUnlimitedQuantity = Source.ysnUnlimitedQuantity, Target.ysnMaxPrice = Source.ysnMaxPrice, Target.intINCOLocationTypeId = Source.intINCOLocationTypeId, Target.intCountryId = Source.intCountryId, Target.intCompanyLocationPricingLevelId = Source.intCompanyLocationPricingLevelId, Target.ysnProvisional = Source.ysnProvisional, Target.ysnLoad = Source.ysnLoad, Target.intNoOfLoad = Source.intNoOfLoad, Target.dblQuantityPerLoad = Source.dblQuantityPerLoad, Target.intLoadUOMId = Source.intLoadUOMId, Target.ysnCategory = Source.ysnCategory, Target.ysnMultiplePriceFixation = Source.ysnMultiplePriceFixation, Target.intCategoryUnitMeasureId = Source.intCategoryUnitMeasureId, Target.intLoadCategoryUnitMeasureId = Source.intLoadCategoryUnitMeasureId, Target.intArbitrationId = Source.intArbitrationId, Target.intProducerId = Source.intProducerId, Target.ysnExported = Source.ysnExported, Target.dtmExported = Source.dtmExported, Target.intCreatedById = Source.intCreatedById, Target.dtmCreated = Source.dtmCreated, Target.intLastModifiedById = Source.intLastModifiedById, Target.dtmLastModified = Source.dtmLastModified
        WHEN NOT MATCHED BY SOURCE THEN
             DELETE;';

    SET @SQLString = 'Exec('' '  + Replace(@SQLString, 'repDB', @remoteDB) + ' '')'

    SET IDENTITY_INSERT tblCTContractHeader ON
    EXECUTE sp_executesql @SQLString;
    SET IDENTITY_INSERT tblCTContractHeader OFF

    -- tblCTContractDetail
    SET @SQLString = N'MERGE tblCTContractDetail AS Target
        USING (SELECT * FROM REMOTEDBSERVER.[repDB].[dbo].[tblCTContractDetail]) AS Source
        ON (Target.intContractDetailId = Source.intContractDetailId)
        WHEN MATCHED THEN
            UPDATE SET Target.intConcurrencyId = Source.intConcurrencyId, Target.intContractHeaderId = Source.intContractHeaderId, Target.intContractStatusId = Source.intContractStatusId, Target.intContractSeq = Source.intContractSeq, Target.intCompanyLocationId = Source.intCompanyLocationId, Target.dtmStartDate = Source.dtmStartDate, Target.dtmEndDate = Source.dtmEndDate, Target.intFreightTermId = Source.intFreightTermId, Target.intShipViaId = Source.intShipViaId, Target.intItemContractId = Source.intItemContractId, Target.intItemId = Source.intItemId, Target.intCategoryId = Source.intCategoryId, Target.dblQuantity = Source.dblQuantity, Target.intItemUOMId = Source.intItemUOMId, Target.dblOriginalQty = Source.dblOriginalQty, Target.dblBalance = Source.dblBalance, Target.dblIntransitQty = Source.dblIntransitQty, Target.dblScheduleQty = Source.dblScheduleQty, Target.dblNetWeight = Source.dblNetWeight, Target.intNetWeightUOMId = Source.intNetWeightUOMId, Target.intUnitMeasureId = Source.intUnitMeasureId, Target.intCategoryUOMId = Source.intCategoryUOMId, Target.intNoOfLoad = Source.intNoOfLoad, Target.dblQuantityPerLoad = Source.dblQuantityPerLoad, Target.intIndexId = Source.intIndexId, Target.dblAdjustment = Source.dblAdjustment, Target.intAdjItemUOMId = Source.intAdjItemUOMId, Target.intPricingTypeId = Source.intPricingTypeId, Target.intFutureMarketId = Source.intFutureMarketId, Target.intFutureMonthId = Source.intFutureMonthId, Target.dblFutures = Source.dblFutures, Target.dblBasis = Source.dblBasis, Target.dblOriginalBasis = Source.dblOriginalBasis, Target.dblCashPrice = Source.dblCashPrice, Target.dblTotalCost = Source.dblTotalCost, Target.intCurrencyId = Source.intCurrencyId, Target.intPriceItemUOMId = Source.intPriceItemUOMId, Target.dblNoOfLots = Source.dblNoOfLots, Target.intMarketZoneId = Source.intMarketZoneId, Target.intDiscountTypeId = Source.intDiscountTypeId, Target.intDiscountId = Source.intDiscountId, Target.intDiscountScheduleId = Source.intDiscountScheduleId, Target.intDiscountScheduleCodeId = Source.intDiscountScheduleCodeId, Target.intStorageScheduleRuleId = Source.intStorageScheduleRuleId, Target.intContractOptHeaderId = Source.intContractOptHeaderId, Target.strBuyerSeller = Source.strBuyerSeller, Target.intBillTo = Source.intBillTo, Target.intFreightRateId = Source.intFreightRateId, Target.strFobBasis = Source.strFobBasis, Target.intRailGradeId = Source.intRailGradeId, Target.strRailRemark = Source.strRailRemark, Target.strLoadingPointType = Source.strLoadingPointType, Target.intLoadingPortId = Source.intLoadingPortId, Target.strDestinationPointType = Source.strDestinationPointType, Target.intDestinationPortId = Source.intDestinationPortId, Target.strShippingTerm = Source.strShippingTerm, Target.intShippingLineId = Source.intShippingLineId, Target.strVessel = Source.strVessel, Target.intDestinationCityId = Source.intDestinationCityId, Target.intShipperId = Source.intShipperId, Target.strRemark = Source.strRemark, Target.intFarmFieldId = Source.intFarmFieldId, Target.strGrade = Source.strGrade, Target.strVendorLotID = Source.strVendorLotID, Target.strInvoiceNo = Source.strInvoiceNo, Target.strReference = Source.strReference, Target.intUnitsPerLayer = Source.intUnitsPerLayer, Target.intLayersPerPallet = Source.intLayersPerPallet, Target.dtmEventStartDate = Source.dtmEventStartDate, Target.dtmPlannedAvailabilityDate = Source.dtmPlannedAvailabilityDate, Target.dtmUpdatedAvailabilityDate = Source.dtmUpdatedAvailabilityDate, Target.intBookId = Source.intBookId, Target.intSubBookId = Source.intSubBookId, Target.intContainerTypeId = Source.intContainerTypeId, Target.intNumberOfContainers = Source.intNumberOfContainers, Target.intInvoiceCurrencyId = Source.intInvoiceCurrencyId, Target.dtmFXValidFrom = Source.dtmFXValidFrom, Target.dtmFXValidTo = Source.dtmFXValidTo, Target.dblRate = Source.dblRate, Target.intFXPriceUOMId = Source.intFXPriceUOMId, Target.strFXRemarks = Source.strFXRemarks, Target.dblAssumedFX = Source.dblAssumedFX, Target.strFixationBy = Source.strFixationBy, Target.strPackingDescription = Source.strPackingDescription, Target.intCurrencyExchangeRateId = Source.intCurrencyExchangeRateId, Target.intCreatedById = Source.intCreatedById, Target.dtmCreated = Source.dtmCreated, Target.intLastModifiedById = Source.intLastModifiedById, Target.dtmLastModified = Source.dtmLastModified
        WHEN NOT MATCHED BY SOURCE THEN
            DELETE;';

    SET @SQLString = 'Exec('' ' + Replace(@SQLString, 'repDB', @remoteDB) + ' '')'
    SET IDENTITY_INSERT tblCTContractDetail ON
    EXECUTE sp_executesql @SQLString;

    SET IDENTITY_INSERT tblCTContractDetail OFF

    -- tblCTContractCost
    SET @SQLString = N'MERGE tblCTContractCost AS Target
        USING (SELECT * FROM REMOTEDBSERVER.[repDB].[dbo].[tblCTContractCost]) AS Source
        ON (Target.intContractCostId = Source.intContractCostId)
        WHEN MATCHED THEN
            UPDATE SET Target.intConcurrencyId = Source.intConcurrencyId, Target.intContractDetailId = Source.intContractDetailId, Target.intItemId = Source.intItemId, Target.intVendorId = Source.intVendorId, Target.strCostMethod = Source.strCostMethod, Target.intCurrencyId = Source.intCurrencyId, Target.dblRate = Source.dblRate, Target.intItemUOMId = Source.intItemUOMId, Target.dblFX = Source.dblFX, Target.ysnAccrue = Source.ysnAccrue, Target.ysnMTM = Source.ysnMTM, Target.ysnPrice = Source.ysnPrice
        WHEN NOT MATCHED BY SOURCE THEN
            DELETE;';

    SET @SQLString = 'Exec('' ' + Replace(@SQLString, 'repDB', @remoteDB) + ' '')'
    SET IDENTITY_INSERT tblCTContractCost ON
    EXECUTE sp_executesql @SQLString;
    SET IDENTITY_INSERT tblCTContractCost OFF

END