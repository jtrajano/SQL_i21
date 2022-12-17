﻿CREATE VIEW [dbo].[vyuCTFWCOverview]

AS

		SELECT	
				CH.intContractHeaderId,
				CTD.intContractDetailId,
				strPONumber = LGL.strCustomerReference,	
				dtmOriginalETD = LGL.dtmETAPOD,
				dtmCurrentETD = CTD.dtmEtaPod,
				dtmOriginalStockDate = LGL.dtmBLDate, --TBD 
				dtmRevisedStockDate = LGL.dtmPlannedAvailabilityDate, 
				strContractNumber = CH.strContractNumber,
				strItemNo = CAST (CTD.intContractSeq AS VARCHAR(MAX)),
				strContractStatus = CTS.strContractStatus,
				strS4ContractNo = CH.strCustomerContract,
				dtmCreationDate = CH.dtmCreated,
				dblTargetValue = CH.dblValue, --Contract value
				dblReleaseValue = 0.00, --Release value
				dtmStartValidityDate = CTD.dtmStartDate,
				dtmEndValidityDate = CTD.dtmEndDate,
				strBuyingOrder = MFB.strBuyingOrderNumber, --TBD Part of Batch Characteristics
				strBuyingCenter = CL.strLocationName,
				strSAPSupplierNo = APV.strVendorAccountNum,
				strSAPSupplierDescription = EV.strName,
				strPricingMechanism = CP.strPricingType,
				strContractOwner = EC.strName,
				strPaymentTerm = CT.strTermCode,
				strPaymentTermDesc = CT.strTerm,
				strPurchaseGroup = '', --TBD Purchase Group from Contract
				strPurchaseIncoTerm = IT.strFreightTerm,
				strPurchaseIncoTermLocation = SC.strCity,
				strFCItem = ICI.strItemNo,
				strTargetNetUOM = ICM.strUnitMeasure,
				dblTargetNetWeight = CTD.dblNetWeight,
				strTargetQtyUOM = ICQM.strUnitMeasure,
				dblTargetQty = CTD.dblQuantity,
				dblAllocatedQty = LGAS.dblAllocatedQuantity,
				dblBalanceToAllocatedQty = CTD.dblQuantity - LGAS.dblAllocatedQuantity,
				strFCOrigin = MFB.strTeaOrigin,
				strFCGardenMark = GM.strGardenMark,
				strFCGradeCode = MFB.strLeafGrade,
				strFCDestination = SL.strName,
				strFCMixingUnit = CTB.strBook,
				dblFCBasePrice = CTD.dblCashPrice,
				dblPurchasePrice = CTD.dblCashPrice,
				dblSalesPrice = MFB.dblSellingPrice,
				strPortOfShipment = LP.strCity,
				strPortOfArrival = DP.strCity,
				dtmETA = CTD.dtmEtaPod,
				dtmMTA = CTD.dtmEtaPod + MFL.dblMUToAvailableForBlending,
				dtmDaysLate = MFB.dtmProductionBatch,
				dtmReportRunOn = getdate(),
				strFCPackageType = ICQM.strUnitMeasure,
				strLineItemStatus = CTS.strContractStatus,
				strSalesYear = SY.strSaleYear,
				strFCBuyingCenter = CLD.strLocationName,
				intSalesNo = MFB.intSales,
				strCatalogueType = MFB.strTeaType,
				strSAPSupplierCode = APV.strVendorAccountNum,
				strSampleType = MFB.strSampleBoxNumber,
				strLotNo = '', --TBA
				strTimeStamp =  CONVERT(VARCHAR(20),getdate(), 100),
				dtmManufacturingDate = MFB.dtmProductionBatch,
				dblNetWeight = CTD.dblNetWeight 
			FROM	tblCTContractHeader	CH	
			INNER JOIN tblCTContractDetail		CTD  WITH (NOLOCK) ON CTD.intContractHeaderId = CH.intContractHeaderId
			LEFT JOIN tblLGLoadDetail			LGD  WITH (NOLOCK) ON CTD.intContractDetailId = LGD.intPContractDetailId
			LEFT JOIN tblLGLoad					LGL  WITH (NOLOCK) ON LGL.intContractDetailId = CTD.intContractDetailId
			LEFT JOIN tblCTContractStatus		CTS  WITH (NOLOCK) ON CTS.intContractStatusId = CTD.intContractStatusId
			LEFT JOIN tblSMCompanyLocation		CL   WITH (NOLOCK) ON CL.intCompanyLocationId = CH.intCompanyLocationId
			LEFT JOIN tblSMCompanyLocation		CLD  WITH (NOLOCK) ON CLD.intCompanyLocationId = CTD.intCompanyLocationId
			LEFT JOIN tblAPVendor				APV  WITH (NOLOCK) ON APV.intEntityId		  = CH.intEntityId
			LEFT JOIN tblEMEntity				EV	 WITH (NOLOCK) ON EV.intEntityId		  = APV.intEntityId
			LEFT JOIN tblCTPricingType			CP	 WITH (NOLOCK) ON CTD.intPricingTypeId	  = CP.intPricingTypeId
			LEFT JOIN tblEMEntity				EC	 WITH (NOLOCK) ON EC.intEntityId		  = CH.intCreatedById
			LEFT JOIN tblSMTerm					CT	 WITH (NOLOCK) ON CT.intTermID			  = CH.intTermId
			LEFT JOIN tblMFBatch				MFB  WITH (NOLOCK) ON CTD.intContractDetailId = MFB.intContractDetailId 
			LEFT JOIN tblQMGardenMark			GM   WITH (NOLOCK) ON GM.intGardenMarkId	  = MFB.intGardenMarkId
			LEFT JOIN tblSMFreightTerms			IT	 WITH (NOLOCK) ON IT.intFreightTermId	  =	CH.intFreightTermId
			LEFT JOIN tblSMCity					SC	 WITH (NOLOCK) ON SC.intCityId			  =	CH.intINCOLocationTypeId
			LEFT JOIN tblICItem					ICI  WITH (NOLOCK) ON ICI.intItemId			  =	CTD.intItemId
			LEFT JOIN tblICItemUOM				ICN  WITH (NOLOCK) ON ICN.intItemUOMId		  =	CTD.intNetWeightUOMId
			LEFT JOIN tblICUnitMeasure			ICM  WITH (NOLOCK) ON ICM.intUnitMeasureId	  = ICN.intUnitMeasureId
			LEFT JOIN tblICItemUOM				ICQ  WITH (NOLOCK) ON ICQ.intItemUOMId		  =	CTD.intItemUOMId
			LEFT JOIN tblICUnitMeasure			ICQM WITH (NOLOCK) ON ICQM.intUnitMeasureId	  = ICQ.intUnitMeasureId
			LEFT JOIN vyuLGAllocationStatus     LGAS WITH (NOLOCK) ON LGAS.strPurchaseContractNumber = CH.strContractNumber  AND LGAS.intContractDetailId = CTD.intContractDetailId
			LEFT JOIN tblICStorageLocation		SL	 WITH (NOLOCK) ON SL.intStorageLocationId = CTD.intStorageLocationId
			LEFT JOIN tblCTBook					CTB	 WITH (NOLOCK) ON CTB.intBookId			  = CH.intBookId
			LEFT JOIN tblSMCity					LP	 WITH (NOLOCK) ON LP.intCityId			  =	CTD.intLoadingPortId
			LEFT JOIN tblSMCity					DP	 WITH (NOLOCK) ON DP.intCityId			  =	CTD.intDestinationPortId
			LEFT JOIN tblMFLocationLeadTime		MFL	 WITH (NOLOCK) ON CTD.intLoadingPortId    = MFL.intPortOfDispatchId AND  CTD.intDestinationPortId = MFL.intPortOfArrivalId
			LEFT JOIN tblQMSaleYear				SY	 WITH (NOLOCK) ON SY.intSaleYearId		  = MFB.intSalesYear
			WHERE CTD.intContractStatusId IN ( 1,2,4) --Open, Unconfirmed,Re-Open

			
