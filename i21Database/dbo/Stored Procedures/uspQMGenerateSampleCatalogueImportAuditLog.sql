CREATE PROCEDURE uspQMGenerateSampleCatalogueImportAuditLog
    @intUserEntityId INT
    ,@strRemarks NVARCHAR(100) = NULL
    ,@ysnCreate BIT = 0
    ,@ysnBeforeUpdate BIT = 1
    ,@intSampleId INT = NULL
AS

BEGIN TRY
	-- BEGIN TRANSACTION
        DECLARE
            @tblLog SingleAuditLogParam
            -- ,@tblHeaderLog SingleAuditLogParam
            -- ,@tblLogTestResult SingleAuditLogParam
            ,@intKey INT = 0
            ,@intTestResultKey INT = 0

        -- If the sample is just being created, add created audit log
        IF @ysnCreate = 1
        BEGIN
            SET @intKey = 1

            INSERT INTO @tblLog (
                [Id]
                ,[Action]
                ,[Change]
                ,[From]
                ,[To]
                ,[ParentId]
            )
            SELECT
                [Id]            = @intKey   
                ,[Action]       = 'Created'
                ,[Change]       = NULL--'Created - Record' + CASE WHEN ISNULL(@strRemarks, '') <> '' THEN ' (' + @strRemarks + ')' ELSE '' END + ': ' + @strSampleNumber
                ,[From]         = NULL
                ,[To]           = NULL
                ,[ParentId]     = NULL
            
            EXEC uspSMSingleAuditLog
                @screenName     = 'Quality.view.QualitySample',
                @recordId       = @intSampleId,
                @entityId       = @intUserEntityId,
                @AuditLogParam  = @tblLog
            
            RETURN
        END

        -- Store the original values in a temp table before the sample is updated
        IF @ysnBeforeUpdate = 1
        BEGIN
            IF OBJECT_ID('tempdb..##tmpQMSample') IS NULL
            BEGIN
                SELECT * INTO ##tmpQMSample FROM tblQMSample WHERE 1 = 0
            END

            IF OBJECT_ID('tempdb..##tmpQMTestResult') IS NULL
            BEGIN
                SELECT * INTO ##tmpQMTestResult FROM tblQMTestResult WHERE 1 = 0
            END

            SET IDENTITY_INSERT ##tmpQMSample ON
            INSERT INTO ##tmpQMSample (
                [intSampleId],
                [intConcurrencyId],
                [intCompanyId],
                [intSampleTypeId],
                [strSampleNumber],
                [intCompanyLocationId],
                [intParentSampleId],
                [strSampleRefNo],
                [intProductTypeId],
                [intProductValueId],
                [intSampleStatusId],
                [intPreviousSampleStatusId],
                [intItemId],
                [intItemContractId],
                [intContractHeaderId],
                [intContractDetailId],
                [intShipmentBLContainerId],
                [intShipmentBLContainerContractId],
                [intShipmentId],
                [intShipmentContractQtyId],
                [intCountryID],
                [ysnIsContractCompleted],
                [intLotStatusId],
                [intEntityId],
                [intShipperEntityId],
                [strShipmentNumber],
                [strLotNumber],
                [strSampleNote],
                [dtmSampleReceivedDate],
                [dtmTestedOn],
                [intTestedById],
                [dblSampleQty],
                [intSampleUOMId],
                [dblRepresentingQty],
                [intRepresentingUOMId],
                [strRefNo],
                [dtmTestingStartDate],
                [dtmTestingEndDate],
                [dtmSamplingEndDate],
                [strSamplingMethod],
                [strContainerNumber],
                [strMarks],
                [intCompanyLocationSubLocationId],
                [strCountry],
                [intItemBundleId],
                [intLoadContainerId],
                [intLoadDetailContainerLinkId],
                [intLoadId],
                [intLoadDetailId],
                [dtmBusinessDate],
                [intShiftId],
                [intLocationId],
                [intInventoryReceiptId],
                [intInventoryShipmentId],
                [intWorkOrderId],
                [strComment],
                [ysnAdjustInventoryQtyBySampleQty],
                [intStorageLocationId],
                [intBookId],
                [intSubBookId],
                [strChildLotNumber],
                [strCourier],
                [strCourierRef],
                [intForwardingAgentId],
                [strForwardingAgentRef],
                [strSentBy],
                [intSentById],
                [intSampleRefId],
                [ysnParent],
                [ysnIgnoreContract],
                [ysnImpactPricing],
                [dtmRequestedDate],
                [dtmSampleSentDate],
                [intSamplingCriteriaId],
                [strSendSampleTo],
                [strRepresentLotNumber],
                [intRelatedSampleId],
                [intTypeId],
                [intCuppingSessionDetailId],
                [intCreatedUserId],
                [dtmCreated],
                [intLastModifiedUserId],
                [dtmLastModified],
                [intSaleYearId],
                [strSaleNumber],
                [dtmSaleDate],
                [intCatalogueTypeId],
                [dtmPromptDate],
                [strChopNumber],
                [intBrokerId],
                [intGradeId],
                [intLeafCategoryId],
                [intManufacturingLeafTypeId],
                [intSeasonId],
                [intGardenMarkId],
                [dtmManufacturingDate],
                [intTotalNumberOfPackageBreakups],
                [intNetWtPerPackagesUOMId],
                [intNoOfPackages],
                [intNetWtSecondPackageBreakUOMId],
                [intNoOfPackagesSecondPackageBreak],
                [intNetWtThirdPackageBreakUOMId],
                [intNoOfPackagesThirdPackageBreak],
                [intProductLineId],
                [ysnOrganic],
                [dblSupplierValuationPrice],
                [intProducerId],
                [intPurchaseGroupId],
                [strERPRefNo],
                [dblGrossWeight],
                [dblTareWeight],
                [dblNetWeight],
                [strBatchNo],
                [str3PLStatus],
                [strAdditionalSupplierReference],
                [intAWBSampleReceived],
                [strAWBSampleReference],
                [dblBasePrice],
                [ysnBoughtAsReserve],
                [intCurrencyId],
                [ysnEuropeanCompliantFlag],
                [intEvaluatorsCodeAtTBOId],
                [intFromLocationCodeId],
                [strSampleBoxNumber],
                [intBrandId],
                [intValuationGroupId],
                [strMusterLot],
                [strMissingLot],
                [intMarketZoneId],
                [intDestinationStorageLocationId],
                [strComments2],
                [strComments3],
                [strBuyingOrderNo],
                [intTINClearanceId],
                [intBuyer1Id],
                [dblB1QtyBought],
                [intB1QtyUOMId],
                [dblB1Price],
                [intB1PriceUOMId],
                [intBuyer2Id],
                [dblB2QtyBought],
                [intB2QtyUOMId],
                [dblB2Price],
                [intB2PriceUOMId],
                [intBuyer3Id],
                [dblB3QtyBought],
                [intB3QtyUOMId],
                [dblB3Price],
                [intB3PriceUOMId],
                [intBuyer4Id],
                [dblB4QtyBought],
                [intB4QtyUOMId],
                [dblB4Price],
                [intB4PriceUOMId],
                [intBuyer5Id],
                [dblB5QtyBought],
                [intB5QtyUOMId],
                [dblB5Price],
                [intB5PriceUOMId],
                [strB5PriceUOM],
                [ysnBought],
				intPackageTypeId
            )
            SELECT
                [intSampleId],
                [intConcurrencyId],
                [intCompanyId],
                [intSampleTypeId],
                [strSampleNumber],
                [intCompanyLocationId],
                [intParentSampleId],
                [strSampleRefNo],
                [intProductTypeId],
                [intProductValueId],
                [intSampleStatusId],
                [intPreviousSampleStatusId],
                [intItemId],
                [intItemContractId],
                [intContractHeaderId],
                [intContractDetailId],
                [intShipmentBLContainerId],
                [intShipmentBLContainerContractId],
                [intShipmentId],
                [intShipmentContractQtyId],
                [intCountryID],
                [ysnIsContractCompleted],
                [intLotStatusId],
                [intEntityId],
                [intShipperEntityId],
                [strShipmentNumber],
                [strLotNumber],
                [strSampleNote],
                [dtmSampleReceivedDate],
                [dtmTestedOn],
                [intTestedById],
                [dblSampleQty],
                [intSampleUOMId],
                [dblRepresentingQty],
                [intRepresentingUOMId],
                [strRefNo],
                [dtmTestingStartDate],
                [dtmTestingEndDate],
                [dtmSamplingEndDate],
                [strSamplingMethod],
                [strContainerNumber],
                [strMarks],
                [intCompanyLocationSubLocationId],
                [strCountry],
                [intItemBundleId],
                [intLoadContainerId],
                [intLoadDetailContainerLinkId],
                [intLoadId],
                [intLoadDetailId],
                [dtmBusinessDate],
                [intShiftId],
                [intLocationId],
                [intInventoryReceiptId],
                [intInventoryShipmentId],
                [intWorkOrderId],
                [strComment],
                [ysnAdjustInventoryQtyBySampleQty],
                [intStorageLocationId],
                [intBookId],
                [intSubBookId],
                [strChildLotNumber],
                [strCourier],
                [strCourierRef],
                [intForwardingAgentId],
                [strForwardingAgentRef],
                [strSentBy],
                [intSentById],
                [intSampleRefId],
                [ysnParent],
                [ysnIgnoreContract],
                [ysnImpactPricing],
                [dtmRequestedDate],
                [dtmSampleSentDate],
                [intSamplingCriteriaId],
                [strSendSampleTo],
                [strRepresentLotNumber],
                [intRelatedSampleId],
                [intTypeId],
                [intCuppingSessionDetailId],
                [intCreatedUserId],
                [dtmCreated],
                [intLastModifiedUserId],
                [dtmLastModified],
                [intSaleYearId],
                [strSaleNumber],
                [dtmSaleDate],
                [intCatalogueTypeId],
                [dtmPromptDate],
                [strChopNumber],
                [intBrokerId],
                [intGradeId],
                [intLeafCategoryId],
                [intManufacturingLeafTypeId],
                [intSeasonId],
                [intGardenMarkId],
                [dtmManufacturingDate],
                [intTotalNumberOfPackageBreakups],
                [intNetWtPerPackagesUOMId],
                [intNoOfPackages],
                [intNetWtSecondPackageBreakUOMId],
                [intNoOfPackagesSecondPackageBreak],
                [intNetWtThirdPackageBreakUOMId],
                [intNoOfPackagesThirdPackageBreak],
                [intProductLineId],
                [ysnOrganic],
                [dblSupplierValuationPrice],
                [intProducerId],
                [intPurchaseGroupId],
                [strERPRefNo],
                [dblGrossWeight],
                [dblTareWeight],
                [dblNetWeight],
                [strBatchNo],
                [str3PLStatus],
                [strAdditionalSupplierReference],
                [intAWBSampleReceived],
                [strAWBSampleReference],
                [dblBasePrice],
                [ysnBoughtAsReserve],
                [intCurrencyId],
                [ysnEuropeanCompliantFlag],
                [intEvaluatorsCodeAtTBOId],
                [intFromLocationCodeId],
                [strSampleBoxNumber],
                [intBrandId],
                [intValuationGroupId],
                [strMusterLot],
                [strMissingLot],
                [intMarketZoneId],
                [intDestinationStorageLocationId],
                [strComments2],
                [strComments3],
                [strBuyingOrderNo],
                [intTINClearanceId],
                [intBuyer1Id],
                [dblB1QtyBought],
                [intB1QtyUOMId],
                [dblB1Price],
                [intB1PriceUOMId],
                [intBuyer2Id],
                [dblB2QtyBought],
                [intB2QtyUOMId],
                [dblB2Price],
                [intB2PriceUOMId],
                [intBuyer3Id],
                [dblB3QtyBought],
                [intB3QtyUOMId],
                [dblB3Price],
                [intB3PriceUOMId],
                [intBuyer4Id],
                [dblB4QtyBought],
                [intB4QtyUOMId],
                [dblB4Price],
                [intB4PriceUOMId],
                [intBuyer5Id],
                [dblB5QtyBought],
                [intB5QtyUOMId],
                [dblB5Price],
                [intB5PriceUOMId],
                [strB5PriceUOM],
                [ysnBought],
				intPackageTypeId
            FROM tblQMSample WHERE intSampleId = @intSampleId
            SET IDENTITY_INSERT ##tmpQMSample OFF

            SET IDENTITY_INSERT ##tmpQMTestResult ON
            INSERT INTO ##tmpQMTestResult (
                [intTestResultId],
                [intConcurrencyId],
                [intSampleId],
                [intProductId],
                [intProductTypeId],
                [intProductValueId],
                [intTestId],
                [intPropertyId],
                [strPanelList],
                [strPropertyValue],
                [dtmCreateDate],
                [strResult],
                [ysnFinal],
                [strComment],
                [intSequenceNo],
                [dtmValidFrom],
                [dtmValidTo],
                [strPropertyRangeText],
                [dblMinValue],
                [dblPinpointValue],
                [dblMaxValue],
                [dblLowValue],
                [dblHighValue],
                [intUnitMeasureId],
                [strFormulaParser],
                [dblCrdrPrice],
                [dblCrdrQty],
                [intProductPropertyValidityPeriodId],
                [intPropertyValidityPeriodId],
                [intControlPointId],
                [intParentPropertyId],
                [intRepNo],
                [strFormula],
                [intListItemId],
                [strIsMandatory],
                [intPropertyItemId],
                [dtmPropertyValueCreated],
                [intTestResultRefId],
                [intCreatedUserId],
                [dtmCreated],
                [intLastModifiedUserId],
                [dtmLastModified]
            )
            SELECT
                [intTestResultId],
                [intConcurrencyId],
                [intSampleId],
                [intProductId],
                [intProductTypeId],
                [intProductValueId],
                [intTestId],
                [intPropertyId],
                [strPanelList],
                [strPropertyValue],
                [dtmCreateDate],
                [strResult],
                [ysnFinal],
                [strComment],
                [intSequenceNo],
                [dtmValidFrom],
                [dtmValidTo],
                [strPropertyRangeText],
                [dblMinValue],
                [dblPinpointValue],
                [dblMaxValue],
                [dblLowValue],
                [dblHighValue],
                [intUnitMeasureId],
                [strFormulaParser],
                [dblCrdrPrice],
                [dblCrdrQty],
                [intProductPropertyValidityPeriodId],
                [intPropertyValidityPeriodId],
                [intControlPointId],
                [intParentPropertyId],
                [intRepNo],
                [strFormula],
                [intListItemId],
                [strIsMandatory],
                [intPropertyItemId],
                [dtmPropertyValueCreated],
                [intTestResultRefId],
                [intCreatedUserId],
                [dtmCreated],
                [intLastModifiedUserId],
                [dtmLastModified]
            FROM tblQMTestResult WHERE intSampleId = @intSampleId
            SET IDENTITY_INSERT ##tmpQMTestResult OFF

        END
        -- Compare the updated sample with the original values to determine which field needs audit logs
        ELSE
        BEGIN
            -- Generate audit logs for sample header
            SET @intKey = 1

            IF OBJECT_ID('tempdb..##tmpHeaderLogs') IS NOT NULL
                DROP TABLE ##tmpHeaderLogs

            IF OBJECT_ID('tempdb..##tmpLogs') IS NOT NULL
                DROP TABLE ##tmpLogs

            CREATE TABLE ##tmpLogs (
                [Id]		    INT, 
                [KeyValue]	    INT,
                [Action]	    NVARCHAR(MAX),
                [Change]	    NVARCHAR(MAX),
                [From]		    NVARCHAR(MAX),
                [To]		    NVARCHAR(MAX),
                [Alias]		    NVARCHAR(MAX),
                [intSampleId]	INT,
            )

            CREATE INDEX [IX_tmpLogs_intSampleId] ON ##tmpLogs(intSampleId)

            -- SET STATISTICS XML ON
            SELECT
                -- [Id]        = @intKey + ROW_NUMBER() OVER(ORDER BY (SELECT 1))
                -- ,[Action]   = NULL
                [Change]   = C.strFieldName
                ,[From]     = C.strOldValue
                ,[To]       = C.strNewValue
                ,[intSampleId] = SN.intSampleId
            INTO ##tmpHeaderLogs
            FROM ##tmpQMSample SO
            INNER JOIN tblQMSample SN ON SO.intSampleId = SN.intSampleId
            -- Contract Detail
            LEFT JOIN tblCTContractDetail CDN ON CDN.intContractDetailId = SN.intContractDetailId
            LEFT JOIN tblCTContractDetail CDO ON CDO.intContractDetailId = SO.intContractDetailId
            -- Contract Header
            LEFT JOIN tblCTContractHeader CHN ON CHN.intContractHeaderId = CDN.intContractHeaderId
            LEFT JOIN tblCTContractHeader CHO ON CHO.intContractHeaderId = CDO.intContractHeaderId
            -- Channel
            LEFT JOIN tblARMarketZone MZN ON MZN.intMarketZoneId = SN.intMarketZoneId
            LEFT JOIN tblARMarketZone MZO ON MZO.intMarketZoneId = SO.intMarketZoneId
            -- Sample Status
            LEFT JOIN tblQMSampleStatus SSN ON SSN.intSampleStatusId = SN.intSampleStatusId
            LEFT JOIN tblQMSampleStatus SSO ON SSO.intSampleStatusId = SO.intSampleStatusId
            -- Mixing Unit
            LEFT JOIN tblCTBook CTBN ON CTBN.intBookId = SN.intBookId
            LEFT JOIN tblCTBook CTBO ON CTBO.intBookId = SO.intBookId
            -- Grade
            LEFT JOIN tblICCommodityAttribute GRDN ON GRDN.intCommodityAttributeId = SN.intGradeId
            LEFT JOIN tblICCommodityAttribute GRDO ON GRDO.intCommodityAttributeId = SO.intGradeId
            -- Manufacturing Leaf Type
            LEFT JOIN tblICCommodityAttribute LEAFN ON LEAFN.intCommodityAttributeId = SN.intManufacturingLeafTypeId
            LEFT JOIN tblICCommodityAttribute LEAFO ON LEAFO.intCommodityAttributeId = SO.intManufacturingLeafTypeId
            -- Season
            LEFT JOIN tblICCommodityAttribute SEASN ON SEASN.intCommodityAttributeId = SN.intSeasonId
            LEFT JOIN tblICCommodityAttribute SEASO ON SEASO.intCommodityAttributeId = SO.intSeasonId
            -- Garden Mark
            LEFT JOIN tblQMGardenMark GMN ON GMN.intGardenMarkId = SN.intGardenMarkId
            LEFT JOIN tblQMGardenMark GMO ON GMO.intGardenMarkId = SO.intGardenMarkId
            -- Origin
            LEFT JOIN tblICCommodityAttribute ORIN ON ORIN.intCommodityAttributeId = SN.intCountryID
            LEFT JOIN tblICCommodityAttribute ORIO ON ORIO.intCommodityAttributeId = SO.intCountryID
            -- Warehouse
            LEFT JOIN tblSMCompanyLocationSubLocation WHN ON WHN.intCompanyLocationSubLocationId = SN.intCompanyLocationSubLocationId
            LEFT JOIN tblSMCompanyLocationSubLocation WHO ON WHO.intCompanyLocationSubLocationId = SO.intCompanyLocationSubLocationId
            -- UOM 1st Package-Break
            LEFT JOIN tblICUnitMeasure PBUOM1N ON PBUOM1N.intUnitMeasureId = SN.intNetWtPerPackagesUOMId
            LEFT JOIN tblICUnitMeasure PBUOM1O ON PBUOM1O.intUnitMeasureId = SO.intNetWtPerPackagesUOMId
            -- UOM 2nd Package-Break
            LEFT JOIN tblICUnitMeasure PBUOM2N ON PBUOM2N.intUnitMeasureId = SN.intNetWtSecondPackageBreakUOMId
            LEFT JOIN tblICUnitMeasure PBUOM2O ON PBUOM2O.intUnitMeasureId = SO.intNetWtSecondPackageBreakUOMId
            -- UOM 3rd Package-Break
            LEFT JOIN tblICUnitMeasure PBUOM3N ON PBUOM3N.intUnitMeasureId = SN.intNetWtThirdPackageBreakUOMId
            LEFT JOIN tblICUnitMeasure PBUOM3O ON PBUOM3O.intUnitMeasureId = SO.intNetWtThirdPackageBreakUOMId
            -- Sustainability
            LEFT JOIN tblICCommodityProductLine SUSN ON SUSN.intCommodityProductLineId = SN.intProductLineId
            LEFT JOIN tblICCommodityProductLine SUSO ON SUSO.intCommodityProductLineId = SO.intProductLineId
            -- Colour
            LEFT JOIN tblICCommodityAttribute COLN ON COLN.intCommodityAttributeId = SN.intSeasonId
            LEFT JOIN tblICCommodityAttribute COLO ON COLO.intCommodityAttributeId = SO.intSeasonId
            -- Size
            LEFT JOIN tblICBrand SIZEN ON SIZEN.intBrandId = SN.intBrandId
            LEFT JOIN tblICBrand SIZEO ON SIZEO.intBrandId = SO.intBrandId
            -- Size
            LEFT JOIN tblCTValuationGroup STYLN ON STYLN.intValuationGroupId = SN.intValuationGroupId
            LEFT JOIN tblCTValuationGroup STYLO ON STYLO.intValuationGroupId = SO.intValuationGroupId
            -- Tealingo Item
            LEFT JOIN tblICItem ITMN ON ITMN.intItemId = SN.intItemId
            LEFT JOIN tblICItem ITMO ON ITMO.intItemId = SO.intItemId
            -- Buyer 1 Qty Bought UOM
            LEFT JOIN tblICUnitMeasure B1QUOMN ON B1QUOMN.intUnitMeasureId = SN.intB1QtyUOMId
            LEFT JOIN tblICUnitMeasure B1QUOMO ON B1QUOMO.intUnitMeasureId = SO.intB1QtyUOMId
            -- Buyer 2 Qty Bought UOM
            LEFT JOIN tblICUnitMeasure B2QUOMN ON B2QUOMN.intUnitMeasureId = SN.intB2QtyUOMId
            LEFT JOIN tblICUnitMeasure B2QUOMO ON B2QUOMO.intUnitMeasureId = SO.intB2QtyUOMId
            -- Buyer 3 Qty Bought UOM
            LEFT JOIN tblICUnitMeasure B3QUOMN ON B3QUOMN.intUnitMeasureId = SN.intB3QtyUOMId
            LEFT JOIN tblICUnitMeasure B3QUOMO ON B3QUOMO.intUnitMeasureId = SO.intB3QtyUOMId
            -- Buyer 4 Qty Bought UOM
            LEFT JOIN tblICUnitMeasure B4QUOMN ON B4QUOMN.intUnitMeasureId = SN.intB4QtyUOMId
            LEFT JOIN tblICUnitMeasure B4QUOMO ON B4QUOMO.intUnitMeasureId = SO.intB4QtyUOMId
            -- Buyer 5 Qty Bought UOM
            LEFT JOIN tblICUnitMeasure B5QUOMN ON B5QUOMN.intUnitMeasureId = SN.intB5QtyUOMId
            LEFT JOIN tblICUnitMeasure B5QUOMO ON B5QUOMO.intUnitMeasureId = SO.intB5QtyUOMId
            -- Buyer 1 Price UOM
            LEFT JOIN tblICUnitMeasure B1PUOMN ON B1PUOMN.intUnitMeasureId = SN.intB1PriceUOMId
            LEFT JOIN tblICUnitMeasure B1PUOMO ON B1PUOMO.intUnitMeasureId = SO.intB1PriceUOMId
            -- Buyer 2 Price UOM
            LEFT JOIN tblICUnitMeasure B2PUOMN ON B2PUOMN.intUnitMeasureId = SN.intB2PriceUOMId
            LEFT JOIN tblICUnitMeasure B2PUOMO ON B2PUOMO.intUnitMeasureId = SO.intB2PriceUOMId
            -- Buyer 3 Price UOM
            LEFT JOIN tblICUnitMeasure B3PUOMN ON B3PUOMN.intUnitMeasureId = SN.intB3PriceUOMId
            LEFT JOIN tblICUnitMeasure B3PUOMO ON B3PUOMO.intUnitMeasureId = SO.intB3PriceUOMId
            -- Buyer 4 Price UOM
            LEFT JOIN tblICUnitMeasure B4PUOMN ON B4PUOMN.intUnitMeasureId = SN.intB4PriceUOMId
            LEFT JOIN tblICUnitMeasure B4PUOMO ON B4PUOMO.intUnitMeasureId = SO.intB4PriceUOMId
            -- Buyer 5 Price UOM
            LEFT JOIN tblICUnitMeasure B5PUOMN ON B5PUOMN.intUnitMeasureId = SN.intB5PriceUOMId
            LEFT JOIN tblICUnitMeasure B5PUOMO ON B5PUOMO.intUnitMeasureId = SO.intB5PriceUOMId
            -- Buyer 1 Code
            LEFT JOIN vyuEMSearchEntityBuyer B1N ON B1N.intEntityId = SN.intBuyer1Id
            LEFT JOIN vyuEMSearchEntityBuyer B1O ON B1O.intEntityId = SO.intBuyer1Id
            -- Buyer 2 Code
            LEFT JOIN vyuEMSearchEntityBuyer B2N ON B2N.intEntityId = SN.intBuyer2Id
            LEFT JOIN vyuEMSearchEntityBuyer B2O ON B2O.intEntityId = SO.intBuyer2Id
            -- Buyer 3 Code
            LEFT JOIN vyuEMSearchEntityBuyer B3N ON B3N.intEntityId = SN.intBuyer3Id
            LEFT JOIN vyuEMSearchEntityBuyer B3O ON B3O.intEntityId = SO.intBuyer3Id
            -- Buyer 4 Code
            LEFT JOIN vyuEMSearchEntityBuyer B4N ON B4N.intEntityId = SN.intBuyer4Id
            LEFT JOIN vyuEMSearchEntityBuyer B4O ON B4O.intEntityId = SO.intBuyer4Id
            -- Buyer 5 Code
            LEFT JOIN vyuEMSearchEntityBuyer B5N ON B5N.intEntityId = SN.intBuyer5Id
            LEFT JOIN vyuEMSearchEntityBuyer B5O ON B5O.intEntityId = SO.intBuyer5Id
            -- From Location Code
            LEFT JOIN tblSMCity FLCN ON FLCN.intCityId = SN.intFromLocationCodeId
            LEFT JOIN tblSMCity FLCO ON FLCO.intCityId = SO.intFromLocationCodeId
            -- Sample Type
            LEFT JOIN tblQMSampleType STN ON STN.intSampleTypeId = SN.intSampleTypeId
            LEFT JOIN tblQMSampleType STO ON STO.intSampleTypeId = SO.intSampleTypeId
            -- Broker
            LEFT JOIN vyuEMSearchEntityBroker BRN ON BRN.intEntityId = SN.intBrokerId
            LEFT JOIN vyuEMSearchEntityBroker BRO ON BRO.intEntityId = SO.intBrokerId
            -- TIN
            LEFT JOIN tblQMTINClearance TINN ON TINN.intTINClearanceId = SN.intTINClearanceId
            LEFT JOIN tblQMTINClearance TINO ON TINO.intTINClearanceId = SO.intTINClearanceId
            -- Strategy
            LEFT JOIN tblCTSubBook SUBN ON SUBN.intSubBookId = SN.intSubBookId
            LEFT JOIN tblCTSubBook SUBO ON SUBO.intSubBookId = SO.intSubBookId
            -- Receiving Storage Location
            LEFT JOIN tblSMCompanyLocationSubLocation RSLN ON RSLN.intCompanyLocationSubLocationId = SN.intDestinationStorageLocationId
            LEFT JOIN tblSMCompanyLocationSubLocation RSLO ON RSLO.intCompanyLocationSubLocationId = SO.intDestinationStorageLocationId
            -- Currency
            LEFT JOIN tblSMCurrency CURN ON CURN.intCurrencyID = SN.intCurrencyId
            LEFT JOIN tblSMCurrency CURO ON CURO.intCurrencyID = SO.intCurrencyId
            -- Evaluator's Code at TBO
            LEFT JOIN tblEMEntity ECTN ON ECTN.intEntityId = SN.intEvaluatorsCodeAtTBOId
            LEFT JOIN tblEMEntity ECTO ON ECTO.intEntityId = SO.intEvaluatorsCodeAtTBOId
            -- Unpivot columns to rows
            CROSS APPLY (
                SELECT 'Contract', CAST(CHO.strContractNumber AS NVARCHAR(MAX)) + ' - ' + ISNULL(CAST(CDO.intContractSeq AS NVARCHAR(5)), ''), CAST(CHN.strContractNumber AS NVARCHAR(MAX)) + ' - ' + ISNULL(CAST(CDN.intContractSeq AS NVARCHAR(5)), '')
                UNION ALL
                SELECT 'Sample Status', CAST(SO.intSampleStatusId AS NVARCHAR), CAST(SN.intSampleStatusId AS NVARCHAR)
                UNION ALL
                SELECT 'Channel', MZO.strMarketZoneCode, MZN.strMarketZoneCode
                UNION ALL
                SELECT 'Sample Status', SSO.strStatus, SSN.strStatus
                UNION ALL
                SELECT 'Mixing Unit', CTBO.strBook, CTBN.strBook
                UNION ALL
                SELECT 'Supplier Valuation', CAST(SO.dblSupplierValuationPrice AS NVARCHAR), CAST(SN.dblSupplierValuationPrice AS NVARCHAR)
                UNION ALL
                SELECT 'Chop No.', SO.strChopNumber, SN.strChopNumber
                UNION ALL
                SELECT 'Grade', GRDO.strDescription, GRDN.strDescription
                UNION ALL
                SELECT 'Manufacturing Leaf Type', LEAFO.strDescription, LEAFN.strDescription
                UNION ALL
                SELECT 'Season', SEASO.strDescription, SEASN.strDescription
                UNION ALL
                SELECT 'Gross Weight', CAST(SO.dblGrossWeight AS NVARCHAR), CAST(SN.dblGrossWeight AS NVARCHAR)
                UNION ALL
                SELECT 'Garden Mark', GMO.strGardenMark, GMN.strGardenMark
                UNION ALL
                SELECT 'Origin', ORIO.strDescription, ORIN.strDescription
                UNION ALL
                SELECT 'Warehouse', WHO.strSubLocationName, WHN.strSubLocationName
                UNION ALL
                SELECT 'Manufacturing Date', dbo.fnRKFormatDate(SO.dtmManufacturingDate, 'MM/dd/yyy'), dbo.fnRKFormatDate(SN.dtmManufacturingDate, 'MM/dd/yyy')
                UNION ALL
                SELECT 'Quantity', CAST(SO.dblRepresentingQty AS NVARCHAR), CAST(SN.dblRepresentingQty AS NVARCHAR)
                UNION ALL
                SELECT 'Total No. of Package Breakups', CAST(SO.intTotalNumberOfPackageBreakups AS NVARCHAR), CAST(SN.intTotalNumberOfPackageBreakups AS NVARCHAR)
                
                UNION ALL
                SELECT 'No. of Packages', CAST(SO.intNoOfPackages AS NVARCHAR), CAST(SN.intNoOfPackages AS NVARCHAR)
                UNION ALL
                SELECT 'No. of Packages UOM', PBUOM1O.strSymbol, PBUOM1N.strSymbol
                
                UNION ALL
                SELECT 'No. of Packages (2nd Package-Break)', CAST(SO.intNoOfPackagesSecondPackageBreak AS NVARCHAR), CAST(SN.intNoOfPackagesSecondPackageBreak AS NVARCHAR)
                UNION ALL
                SELECT 'No. of Packages UOM (2nd Package-Break)', PBUOM2O.strSymbol, PBUOM2N.strSymbol
                
                UNION ALL
                SELECT 'No. of Packages (3rd Package-Break)', CAST(SO.intNoOfPackagesThirdPackageBreak AS NVARCHAR), CAST(SN.intNoOfPackagesThirdPackageBreak AS NVARCHAR)
                UNION ALL
                SELECT 'No. of Packages UOM (3rd Package-Break)', PBUOM3O.strSymbol, PBUOM3N.strSymbol
                
                UNION ALL
                SELECT 'Sustainability', SUSO.strDescription, SUSN.strDescription
                UNION ALL
                SELECT 'Organic', CASE WHEN SO.ysnOrganic = 1 THEN 'True' ELSE 'False' END, CASE WHEN SN.ysnOrganic = 1 THEN 'True' ELSE 'False' END
                UNION ALL
                SELECT 'Sale Date', dbo.fnRKFormatDate(SO.dtmSaleDate, 'MM/dd/yyy'), dbo.fnRKFormatDate(SN.dtmSaleDate, 'MM/dd/yyy')
                UNION ALL
                SELECT 'Prompt Date', dbo.fnRKFormatDate(SO.dtmPromptDate, 'MM/dd/yyy'), dbo.fnRKFormatDate(SN.dtmPromptDate, 'MM/dd/yyy')
                UNION ALL
                SELECT 'Remarks', SO.strComment, SN.strComment
                UNION ALL
                SELECT 'Colour', COLO.strDescription, COLN.strDescription
                UNION ALL
                SELECT 'Size', SIZEO.strBrandCode, SIZEN.strBrandCode
                UNION ALL
                SELECT 'Style', STYLO.strName, STYLN.strName
                UNION ALL
                SELECT 'Muster Lot', SO.strMusterLot, SN.strMusterLot
                UNION ALL
                SELECT 'Missing Lot', SO.strMissingLot, SN.strMissingLot
                UNION ALL
                SELECT 'Comments2', SO.strComments2, SN.strComments2
                UNION ALL
                SELECT 'Tealingo Item', ITMO.strItemNo, ITMN.strItemNo
                UNION ALL
                SELECT 'Bought', CASE WHEN SO.ysnBought = 1 THEN 'True' ELSE 'False' END, CASE WHEN SN.ysnBought = 1 THEN 'True' ELSE 'False' END
                
                UNION ALL
                SELECT 'Buyer1 Code', B1O.strName, B1N.strName
                UNION ALL
                SELECT 'Buyer1 Quantity Bought', CAST(SO.dblB1QtyBought AS NVARCHAR), CAST(SN.dblB1QtyBought AS NVARCHAR)
                UNION ALL
                SELECT 'Buyer1 Quantity Bought UOM', B1QUOMO.strSymbol, B1QUOMN.strSymbol
                UNION ALL
                SELECT 'Buyer1 Price', CAST(SO.dblB1Price AS NVARCHAR), CAST(SN.dblB1Price AS NVARCHAR)
                UNION ALL
                SELECT 'Buyer1 Price UOM', B1PUOMO.strSymbol, B1PUOMN.strSymbol
                
                UNION ALL
                SELECT 'Buyer2 Code', B2O.strName, B2N.strName
                UNION ALL
                SELECT 'Buyer2 Quantity Bought', CAST(SO.dblB2QtyBought AS NVARCHAR), CAST(SN.dblB2QtyBought AS NVARCHAR)
                UNION ALL
                SELECT 'Buyer2 Quantity Bought UOM', B2QUOMO.strSymbol, B2QUOMN.strSymbol
                UNION ALL
                SELECT 'Buyer2 Price', CAST(SO.dblB2Price AS NVARCHAR), CAST(SN.dblB2Price AS NVARCHAR)
                UNION ALL
                SELECT 'Buyer2 Price UOM', B2PUOMO.strSymbol, B2PUOMN.strSymbol

                UNION ALL
                SELECT 'Buyer3 Code', B3O.strName, B3N.strName
                UNION ALL
                SELECT 'Buyer3 Quantity Bought', CAST(SO.dblB3QtyBought AS NVARCHAR), CAST(SN.dblB3QtyBought AS NVARCHAR)
                UNION ALL
                SELECT 'Buyer3 Quantity Bought UOM', B3QUOMO.strSymbol, B3QUOMN.strSymbol
                UNION ALL
                SELECT 'Buyer3 Price', CAST(SO.dblB3Price AS NVARCHAR), CAST(SN.dblB3Price AS NVARCHAR)
                UNION ALL
                SELECT 'Buyer3 Price UOM', B3PUOMO.strSymbol, B3PUOMN.strSymbol

                UNION ALL
                SELECT 'Buyer4 Code', B4O.strName, B4N.strName
                UNION ALL
                SELECT 'Buyer4 Quantity Bought', CAST(SO.dblB4QtyBought AS NVARCHAR), CAST(SN.dblB4QtyBought AS NVARCHAR)
                UNION ALL
                SELECT 'Buyer4 Quantity Bought UOM', B4QUOMO.strSymbol, B4QUOMN.strSymbol
                UNION ALL
                SELECT 'Buyer4 Price', CAST(SO.dblB4Price AS NVARCHAR), CAST(SN.dblB4Price AS NVARCHAR)
                UNION ALL
                SELECT 'Buyer4 Price UOM', B4PUOMO.strSymbol, B4PUOMN.strSymbol

                UNION ALL
                SELECT 'Buyer5 Code', B5O.strName, B5N.strName
                UNION ALL
                SELECT 'Buyer5 Quantity Bought', CAST(SO.dblB5QtyBought AS NVARCHAR), CAST(SN.dblB5QtyBought AS NVARCHAR)
                UNION ALL
                SELECT 'Buyer5 Quantity Bought UOM', B5QUOMO.strSymbol, B5QUOMN.strSymbol
                UNION ALL
                SELECT 'Buyer5 Price', CAST(SO.dblB5Price AS NVARCHAR), CAST(SN.dblB5Price AS NVARCHAR)
                UNION ALL
                SELECT 'Buyer5 Price UOM', B5PUOMO.strSymbol, B5PUOMN.strSymbol

                UNION ALL
                SELECT 'Buying Order Number', SO.strBuyingOrderNo, SN.strBuyingOrderNo
                UNION ALL
                SELECT '3PL Status', SO.str3PLStatus, SN.str3PLStatus
                UNION ALL
                SELECT 'Additional Supplier Reference', SO.strAdditionalSupplierReference, SN.strAdditionalSupplierReference
                UNION ALL
                SELECT 'AWB Sample Reference', SO.strAWBSampleReference, SN.strAWBSampleReference
                UNION ALL
                SELECT 'AWB Sample Received', CAST(SO.intAWBSampleReceived AS NVARCHAR), CAST(SN.intAWBSampleReceived AS NVARCHAR)
                UNION ALL
                SELECT 'Base Price', CAST(SO.dblBasePrice AS NVARCHAR), CAST(SN.dblBasePrice AS NVARCHAR)
                UNION ALL
                SELECT 'Bought as Reserve', CASE WHEN SO.ysnBoughtAsReserve = 1 THEN 'True' ELSE 'False' END, CASE WHEN SN.ysnBoughtAsReserve = 1 THEN 'True' ELSE 'False' END
                UNION ALL
                SELECT 'Currency', CURO.strCurrency, CURN.strCurrency
                UNION ALL
                SELECT 'European Compliant Flag', CASE WHEN SO.ysnEuropeanCompliantFlag = 1 THEN 'True' ELSE 'False' END, CASE WHEN SN.ysnEuropeanCompliantFlag = 1 THEN 'True' ELSE 'False' END
                UNION ALL
                SELECT 'Evaluator''s Code at TBO', ECTO.strName, ECTN.strName
                UNION ALL
                SELECT 'Comments3', SO.strComments3, SN.strComments3
                UNION ALL
                SELECT 'From Location Code', FLCO.strCity, FLCN.strCity
                UNION ALL
                SELECT 'Sample Box No.(TBO)', SO.strSampleBoxNumber, SN.strSampleBoxNumber
                UNION ALL
                SELECT 'Batch No.', SO.strBatchNo, SN.strBatchNo
                UNION ALL
                SELECT 'Sample Type', STO.strSampleTypeName, STN.strSampleTypeName
                UNION ALL
                SELECT 'Broker', BRO.strName, BRN.strName
                UNION ALL
                SELECT 'TIN Number', TINO.strTINNumber, TINN.strTINNumber
                UNION ALL
                SELECT 'Strategy', SUBO.strSubBook, SUBN.strSubBook
                UNION ALL
                SELECT 'Receiving Storage Location', RSLO.strSubLocationName, RSLN.strSubLocationName
            ) C (strFieldName, strOldValue, strNewValue)
            -- Filter
            WHERE SN.intSampleId = SO.intSampleId
            AND ISNULL(C.strOldValue, '') <> ISNULL(C.strNewValue, '')

            INSERT INTO ##tmpLogs (
                [Id]
                ,[Action]
                ,[Change]
                ,[From]
                ,[To]
                ,[intSampleId]
            )
            SELECT
                [Id]            = @intKey + ROW_NUMBER() OVER(ORDER BY (SELECT 1))
                ,[Action]       = 'UPdated'
                ,[Change]       = T.[Change]
                ,[From]         = T.[From]
                ,[To]           = T.[To]
                ,[intSampleId]  = T.intSampleId
            FROM ##tmpHeaderLogs T

            SELECT @intKey = MAX(Id) FROM ##tmpLogs

            INSERT INTO ##tmpLogs (
                [Id]
                ,[Action]
                ,[Change]
                ,[From]
                ,[To]
                ,[intSampleId]
            )
            SELECT
                [Id]            = @intKey + ROW_NUMBER() OVER(ORDER BY (SELECT 1))
                ,[Action]       = 'Updated'
                ,[Change]       = C.strFieldName
                ,[From]         = C.strOldValue
                ,[To]           = C.strNewValue
                ,[intSampleId]  = TRN.intSampleId
            FROM tblQMTestResult TRN
            INNER JOIN ##tmpQMTestResult TRO ON TRO.intPropertyId = TRN.intPropertyId AND TRO.intSampleId = TRN.intSampleId
            -- Unpivot columns to rows
            CROSS APPLY (
                SELECT 'Actual Value', TRO.strPropertyValue, TRN.strPropertyValue
                UNION ALL
                SELECT 'Result', TRO.strResult, TRN.strResult
                UNION ALL
                SELECT 'Comment', TRO.strComment, TRN.strComment
            ) C (strFieldName, strOldValue, strNewValue)
            WHERE TRN.intSampleId = @intSampleId
            AND ISNULL(C.strOldValue, '') <> ISNULL(C.strNewValue, '')

            -- POST:
            IF @intKey > 1
            BEGIN
                DECLARE @auditLog AS BatchAuditLogParam

                INSERT INTO @auditLog (
                    [Id]
                    , [Namespace]
                    , [Action]
                    , [Description]
                    , [From]
                    , [To]
                    , [EntityId]
                )
                SELECT
                    [Id]				= L.intSampleId
                    , [Namespace]		= 'Quality.view.QualitySample'
                    , [Action]			= 'Updated'
                    , [Change]		    = L.Change
                    , [From]			= L.[From]
                    , [To]				= L.[To]
                    , [EntityId]		= @intUserEntityId
                FROM ##tmpLogs L

                IF EXISTS (SELECT TOP 1 NULL FROM @auditLog)
                    EXEC dbo.uspSMBatchAuditLog
                        @AuditLogParam 	= @auditLog
                        ,@EntityId		= @intUserEntityId
            END

        END
        
END TRY
BEGIN CATCH
	DECLARE @strErrorMsg NVARCHAR(MAX) = NULL
	SET @strErrorMsg = ERROR_MESSAGE()
	RAISERROR(@strErrorMsg, 11, 1) 
END CATCH