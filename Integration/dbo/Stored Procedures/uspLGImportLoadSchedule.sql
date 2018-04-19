IF EXISTS(SELECT TOP 1 1 FROM sys.procedures WHERE name = 'uspLGImportLoadSchedule')
	DROP PROCEDURE uspLGImportLoadSchedule
GO
CREATE PROCEDURE uspLGImportLoadSchedule
	@Checking BIT = 0,
	@UserId	  INT = 0,
	@Total	  INT = 0 OUTPUT

	AS

BEGIN
	--================================================
	--     IMPORT Logistics  Load Schedule
	--================================================


	DECLARE	@MaxLoadId as INT

	SELECT @MaxLoadId = MAX(intLoadId) FROM tblLGLoad 
	SET @MaxLoadId = ISNULL(@MaxLoadId, 0)

	IF (@Checking = 1)
	BEGIN
			 SELECT @Total = COUNT (*) 	FROM galdsmst LL 
					JOIN	tblSMCompanyLocation	CL	ON	LTRIM(RTRIM(CL.strLocationNumber)) collate SQL_Latin1_General_CP1_CS_AS  = LTRIM(RTRIM(LL.galds_loc_no)) collate SQL_Latin1_General_CP1_CS_AS
					JOIN	gacntmst				CT	ON	gacnt_cnt_no = galds_cnt_no AND gacnt_cus_no = galds_cus_no AND
					 gacnt_seq_no = galds_cnt_seq_no AND gacnt_sub_seq_no = galds_cnt_sub_no AND gacnt_loc_no = galds_loc_no AND gacnt_pur_sls_ind = galds_pur_sls_ind
					JOIN    tblCTContractHeader		CH  ON  LTRIM(RTRIM(CH.strContractNumber)) collate SQL_Latin1_General_CP1_CS_AS  = LTRIM(RtRIM(CT.gacnt_cnt_no))+'_'+LTRIM(RtRIM(CT.gacnt_cus_no))
															+'_'+LTRIM(RtRIM(CAST(CT.gacnt_seq_no AS CHAR(3))))+'_'+LTRIM(RtRIM(CAST(CT.gacnt_sub_seq_no AS CHAR(3))))+'_'+CAST(CT.A4GLIdentity AS CHAR(6)) collate SQL_Latin1_General_CP1_CS_AS
					JOIN    tblCTContractDetail		CD  ON  CD.intContractSeq												 = LL.galds_cnt_seq_no 
														AND CD.intContractHeaderId = CH.intContractHeaderId
					LEFT	JOIN	tblICCommodity			CO	ON	LTRIM(RTRIM(CO.strCommodityCode))  collate SQL_Latin1_General_CP1_CS_AS = LTRIM(RTRIM(LL.galds_com_cd)) collate SQL_Latin1_General_CP1_CS_AS
					LEFT	JOIN	tblICItem				IM	ON	LTRIM(RTRIM(IM.strItemNo))										= LTRIM(RTRIM(LL.galds_com_cd)) collate SQL_Latin1_General_CP1_CS_AS
					LEFT	JOIN	tblICItemUOM			IU	ON	IU.intItemId	=	IM.intItemId  AND IU.ysnStockUnit =1	
					JOIN			[tblLGEquipmentType]    EquipmentType ON						EquipmentType.intEquipmentTypeId = LL.galds_equip_type
					LEFT	JOIN	tblARCustomer			CS	ON	LTRIM(RTRIM(CS.strCustomerNumber)) collate SQL_Latin1_General_CP1_CS_AS	= LTRIM(RTRIM(LL.galds_cus_no)) collate SQL_Latin1_General_CP1_CS_AS
					JOIN			tblEMEntity				EM  ON	EM.intEntityId = CS.intEntityId
					LEFT	JOIN	tblEMEntityLocation		EL	ON	EL.intEntityId	=	CS.intEntityId and EL.strLocationName = EM.strName
					LEFT	JOIN	tblSCTicket			    SC	ON	LTRIM(RTRIM(SC.strTicketNumber)) collate SQL_Latin1_General_CP1_CS_AS	= LTRIM(RTRIM(LL.galds_tic_no))+'_'+ LTRIM(RTRIM(LL.galds_cus_no))
														--AND SC.intContractId 
					LEFT	JOIN	tblARCustomer			Hauler	ON	LTRIM(RTRIM(Hauler.strCustomerNumber)) collate SQL_Latin1_General_CP1_CS_AS	= LTRIM(RTRIM(LL.galds_frt_cus_no))	
					LEFT    JOIN	tblLGLoad				LG	ON LG.[strLoadNumber] collate SQL_Latin1_General_CP1_CS_AS = LTRIM(RTRIM(LL.galds_load_no))+'_'+LTRIM(RTRIM(LL.galds_cus_no))+'_'+LTRIM(RTRIM(LL.galds_loc_no)) collate SQL_Latin1_General_CP1_CS_AS 
					WHERE LG.intLoadId IS NULL
			 
			 RETURN @Total
	END

	--For Purchase Loads,adding the GA customers as Vendor type	
	DECLARE @CustomerId AS Id
	INSERT INTO @CustomerId SELECT DISTINCT CUS.intEntityId FROM galdsmst 
	JOIN tblARCustomer CUS ON CUS.strCustomerNumber COLLATE SQL_Latin1_General_CP1_CS_AS = galds_cus_no COLLATE SQL_Latin1_General_CP1_CS_AS
	WHERE galds_pur_sls_ind = 'P' AND NOT EXISTS (SELECT * FROM tblAPVendor WHERE strVendorId = CUS .strCustomerNumber)

	EXEC uspEMConvertCustomerToVendor @CustomerId, @UserId	

	--IMPORT LOAD HEADER

	INSERT INTO [dbo].[tblLGLoad]
	(
		 [intConcurrencyId]
		,[strLoadNumber]
		,[intCompanyLocationId]
		,[intPurchaseSale]
		,[intItemId]
		,[dblQuantity]
		,[intUnitMeasureId]
		,[dtmScheduledDate]
		,[strCustomerReference]
		,[strBookingReference]
		,[intEquipmentTypeId]
		,[intEntityId]
		,[intEntityLocationId]
		,[intContractDetailId]
		,[strComments]
		,[intHaulerEntityId]
		,[intTicketId]
		,[ysnInProgress]
		,[dblDeliveredQuantity]
		,[dtmDeliveredDate]
		,[intGenerateLoadId]
		,[intGenerateSequence]
		,[strTruckNo]
		,[strTrailerNo1]
		,[strTrailerNo2]
		,[strTrailerNo3]
		,[intUserSecurityId]
		,[strExternalLoadNumber]
		,[intTransportLoadId]
		,[intDriverEntityId]
		,[ysnDispatched]
		,[dtmDispatchedDate]
		,[intDispatcherId]
		,[ysnDispatchMailSent]
		,[dtmDispatchMailSent]
		,[dtmCancelDispatchMailSent]
		,[intLoadHeaderId]
		,[intSourceType]
		,[intPositionId]
		,[intWeightUnitMeasureId]
		,[strBLNumber]
		,[dtmBLDate]
		,[strOriginPort]
		,[strDestinationPort]
		,[strDestinationCity]
		,[intTerminalEntityId]
		,[intShippingLineEntityId]
		,[strServiceContractNumber]
		,[strPackingDescription]
		,[strMVessel]
		,[strMVoyageNumber]
		,[strFVessel]
		,[strFVoyageNumber]
		,[intForwardingAgentEntityId]
		,[strForwardingAgentRef]
		,[intInsurerEntityId]
		,[dblInsuranceValue]
		,[intInsuranceCurrencyId]
		,[dtmDocsToBroker]
		,[strMarks]
		,[strMarkingInstructions]
		,[strShippingMode]
		,[intNumberOfContainers]
		,[intContainerTypeId]
		,[intBLDraftToBeSentId]
		,[strBLDraftToBeSentType]
		,[strDocPresentationType]
		,[intDocPresentationId]
		,[dtmDocsReceivedDate]
		,[dtmETAPOL]
		,[dtmETSPOL]
		,[dtmETAPOD]
		,[dtmDeadlineCargo]
		,[dtmDeadlineBL]
		,[dtmISFReceivedDate]
		,[dtmISFFiledDate]
		,[dtmStuffingDate]
		,[dtmStartDate]
		,[dtmEndDate]
		,[dtmPlannedAvailabilityDate]
		,[dblDemurrage]
		,[intDemurrageCurrencyId]
		,[dblDespatch]
		,[intDespatchCurrencyId]
		,[dblLoadingRate]
		,[intLoadingUnitMeasureId]
		,[strLoadingPerUnit]
		,[dblDischargeRate]
		,[intDischargeUnitMeasureId]
		,[strDischargePerUnit]
		,[intTransportationMode]
		,[intShipmentStatus]
		,[ysnPosted]
		,[dtmPostedDate]
		,[intTransUsedBy]
		,[intShipmentType]
		,[intLoadShippingInstructionId]
		,[strExternalShipmentNumber]
		,[ysn4cRegistration]
		,[ysnInvoice]
		,[ysnProvisionalInvoice]
		,[ysnQuantityFinal]
		,[ysnCancelled]
		,[intShippingModeId]
		,[intETAPOLReasonCodeId]
		,[intETSPOLReasonCodeId]
		,[intETAPODReasonCodeId]
	)
SELECT
     [intConcurrencyId]				= 1
	,[strLoadNumber]				= LTRIM(RTRIM(LL.galds_load_no))+'_'+LTRIM(RTRIM(LL.galds_cus_no))+'_'+LTRIM(RTRIM(LL.galds_loc_no))
	,[intCompanyLocationId]			= CL.intCompanyLocationId
	,[intPurchaseSale]				= CASE 
										 WHEN LL.galds_pur_sls_ind='P' THEN 1
										 WHEN LL.galds_pur_sls_ind='S' THEN 2
									  END 
	,[intItemId]					= IM.intItemId
	,[dblQuantity]					= LL.galds_sched_un
	,[intUnitMeasureId]				= IU.intUnitMeasureId
	,[dtmScheduledDate]				= dbo.fnCTConvertToDateTime(LL.galds_sched_rev_dt,null)
	,[strCustomerReference]			= LL.galds_cus_ref_no
	,[strBookingReference]			= LL.galds_booking_no
	,[intEquipmentTypeId]			= EquipmentType.intEquipmentTypeId
	,[intEntityId]					= CS.intEntityId
	,[intEntityLocationId]			= EL.intEntityLocationId
	,[intContractDetailId]			= CD.intContractDetailId
	,[strComments]					= ''--
	,[intHaulerEntityId]			= Hauler.intEntityId
	,[intTicketId]					= SC.intTicketId
	,[ysnInProgress]				= 0--
	,[dblDeliveredQuantity]			= LL.galds_dlvd_un+LL.galds_dlvd_un_prc
	,[dtmDeliveredDate]				= dbo.fnCTConvertToDateTime(LL.galds_dlvd_rev_dt,null)
	,[intGenerateLoadId]			= NULL
	,[intGenerateSequence]			= NULL
	,[strTruckNo]					= NULL
	,[strTrailerNo1]				= NULL
	,[strTrailerNo2]				= NULL
	,[strTrailerNo3]				= NULL
	,[intUserSecurityId]			= @UserId
	,[strExternalLoadNumber]		= NULL
	,[intTransportLoadId]			= NULL
	,[intDriverEntityId]			= Hauler.intEntityId
	,[ysnDispatched]				= CASE 
										 WHEN LL.galds_tic_no <> '' THEN 1
										 ELSE 0
									  END
	,[dtmDispatchedDate]			= dbo.fnCTConvertToDateTime(LL.galds_user_rev_dt,null)
	,[intDispatcherId]				= @UserId
	,[ysnDispatchMailSent]			= NULL
	,[dtmDispatchMailSent]		    = NULL
	,[dtmCancelDispatchMailSent]	= NULL
	,[intLoadHeaderId]				= NULL
	,[intSourceType]				= 2
	,[intPositionId]				= NULL
	,[intWeightUnitMeasureId]		= NULL
	,[strBLNumber]					= NULL
	,[dtmBLDate]					= NULL
	,[strOriginPort]				= NULL
	,[strDestinationPort]			= NULL
	,[strDestinationCity]			= NULL
	,[intTerminalEntityId]			= NULL
	,[intShippingLineEntityId]		= NULL
	,[strServiceContractNumber]		= NULL
	,[strPackingDescription]		= NULL
	,[strMVessel]					= NULL
	,[strMVoyageNumber]				= NULL
	,[strFVessel]					= NULL
	,[strFVoyageNumber]				= NULL
	,[intForwardingAgentEntityId]   = NULL
	,[strForwardingAgentRef]		= NULL
	,[intInsurerEntityId]			= NULL
	,[dblInsuranceValue]			= NULL
	,[intInsuranceCurrencyId]		= NULL
	,[dtmDocsToBroker]				= NULL
	,[strMarks]						= NULL
	,[strMarkingInstructions]		= NULL
	,[strShippingMode]				= NULL
	,[intNumberOfContainers]		= NULL
	,[intContainerTypeId]			= NULL
	,[intBLDraftToBeSentId]			= NULL
	,[strBLDraftToBeSentType]		= NULL
	,[strDocPresentationType]		= NULL
	,[intDocPresentationId]			= NULL
	,[dtmDocsReceivedDate]			= NULL
	,[dtmETAPOL]					= NULL
	,[dtmETSPOL]					= NULL
	,[dtmETAPOD]					= NULL
	,[dtmDeadlineCargo]				= NULL
	,[dtmDeadlineBL]				= NULL
	,[dtmISFReceivedDate]			= NULL
	,[dtmISFFiledDate]				= NULL
	,[dtmStuffingDate]				= NULL
	,[dtmStartDate]				    = NULL
	,[dtmEndDate]					= NULL
	,[dtmPlannedAvailabilityDate]   = NULL
	,[dblDemurrage]					= NULL
	,[intDemurrageCurrencyId]		= NULL
	,[dblDespatch]					= NULL
	,[intDespatchCurrencyId]		= NULL
	,[dblLoadingRate]				= NULL
	,[intLoadingUnitMeasureId]		= NULL
	,[strLoadingPerUnit]			= NULL
	,[dblDischargeRate]				= NULL
	,[intDischargeUnitMeasureId]	= NULL
	,[strDischargePerUnit]			= NULL
	,[intTransportationMode]		= 1
	,[intShipmentStatus]			= CASE 
										 WHEN LL.galds_tic_no <> '' THEN 2
										 ELSE 1
									  END
	,[ysnPosted]					= NULL
	,[dtmPostedDate]				= NULL
	,[intTransUsedBy]			    = 2
	,[intShipmentType]				= 1
	,[intLoadShippingInstructionId] = NULL
	,[strExternalShipmentNumber]	= NULL
	,[ysn4cRegistration]			= NULL
	,[ysnInvoice]					= NULL
	,[ysnProvisionalInvoice]		= NULL
	,[ysnQuantityFinal]				= NULL
	,[ysnCancelled]					= NULL
	,[intShippingModeId]			= NULL
	,[intETAPOLReasonCodeId]		= NULL
	,[intETSPOLReasonCodeId]		= NULL
	,[intETAPODReasonCodeId]		= NULL
	FROM galdsmst LL 
	JOIN	tblSMCompanyLocation	CL	ON	LTRIM(RTRIM(CL.strLocationNumber)) collate SQL_Latin1_General_CP1_CS_AS  = LTRIM(RTRIM(LL.galds_loc_no)) collate SQL_Latin1_General_CP1_CS_AS
	JOIN	gacntmst				CT	ON	gacnt_cnt_no = galds_cnt_no AND gacnt_cus_no = galds_cus_no AND
	 gacnt_seq_no = galds_cnt_seq_no AND gacnt_sub_seq_no = galds_cnt_sub_no AND gacnt_loc_no = galds_loc_no AND gacnt_pur_sls_ind = galds_pur_sls_ind
	JOIN    tblCTContractHeader		CH  ON  LTRIM(RTRIM(CH.strContractNumber)) collate SQL_Latin1_General_CP1_CS_AS  = LTRIM(RtRIM(CT.gacnt_cnt_no))+'_'+LTRIM(RtRIM(CT.gacnt_cus_no))
											+'_'+LTRIM(RtRIM(CAST(CT.gacnt_seq_no AS CHAR(3))))+'_'+LTRIM(RtRIM(CAST(CT.gacnt_sub_seq_no AS CHAR(3))))+'_'+CAST(CT.A4GLIdentity AS CHAR(6)) collate SQL_Latin1_General_CP1_CS_AS
	JOIN    tblCTContractDetail		CD  ON  CD.intContractSeq												 = LL.galds_cnt_seq_no 
										AND CD.intContractHeaderId = CH.intContractHeaderId
	LEFT	JOIN	tblICCommodity			CO	ON	LTRIM(RTRIM(CO.strCommodityCode))  collate SQL_Latin1_General_CP1_CS_AS = LTRIM(RTRIM(LL.galds_com_cd)) collate SQL_Latin1_General_CP1_CS_AS
	LEFT	JOIN	tblICItem				IM	ON	LTRIM(RTRIM(IM.strItemNo))										= LTRIM(RTRIM(LL.galds_com_cd)) collate SQL_Latin1_General_CP1_CS_AS
	LEFT	JOIN	tblICItemUOM			IU	ON	IU.intItemId	=	IM.intItemId  AND IU.ysnStockUnit =1	
	JOIN			[tblLGEquipmentType]    EquipmentType ON						EquipmentType.intEquipmentTypeId = LL.galds_equip_type
	LEFT	JOIN	tblARCustomer			CS	ON	LTRIM(RTRIM(CS.strCustomerNumber)) collate SQL_Latin1_General_CP1_CS_AS	= LTRIM(RTRIM(LL.galds_cus_no)) collate SQL_Latin1_General_CP1_CS_AS
	JOIN			tblEMEntity				EM  ON	EM.intEntityId = CS.intEntityId
	LEFT	JOIN	tblEMEntityLocation		EL	ON	EL.intEntityId	=	CS.intEntityId and EL.strLocationName = EM.strName
	LEFT	JOIN	tblSCTicket			    SC	ON	LTRIM(RTRIM(SC.strTicketNumber)) collate SQL_Latin1_General_CP1_CS_AS	= LTRIM(RTRIM(LL.galds_tic_no))+'_'+ LTRIM(RTRIM(LL.galds_cus_no))
										--AND SC.intContractId 
	LEFT	JOIN	tblARCustomer			Hauler	ON	LTRIM(RTRIM(Hauler.strCustomerNumber)) collate SQL_Latin1_General_CP1_CS_AS	= LTRIM(RTRIM(LL.galds_frt_cus_no))	
	LEFT    JOIN	tblLGLoad				LG	ON LG.[strLoadNumber] collate SQL_Latin1_General_CP1_CS_AS = LTRIM(RTRIM(LL.galds_load_no))+'_'+LTRIM(RTRIM(LL.galds_cus_no))+'_'+LTRIM(RTRIM(LL.galds_loc_no)) collate SQL_Latin1_General_CP1_CS_AS 
	WHERE LG.intLoadId IS NULL

	INSERT INTO [dbo].[tblLGLoadDetail]
    (		
			[intConcurrencyId]
           ,[intLoadId]
           ,[intVendorEntityId]
           ,[intVendorEntityLocationId]
           ,[intCustomerEntityId]
           ,[intCustomerEntityLocationId]
           ,[intItemId]
           ,[intPContractDetailId]
           ,[intSContractDetailId]
           ,[intPCompanyLocationId]
           ,[intSCompanyLocationId]
           ,[dblQuantity]
           ,[intItemUOMId]
           ,[dblGross]
           ,[dblTare]
           ,[dblNet]
           ,[intWeightItemUOMId]
           ,[dblDeliveredQuantity]
           ,[dblDeliveredGross]
           ,[dblDeliveredTare]
           ,[dblDeliveredNet]
           ,[strLotAlias]
           ,[strSupplierLotNumber]
           ,[dtmProductionDate]
           ,[strScheduleInfoMsg]
           ,[ysnUpdateScheduleInfo]
           ,[ysnPrintScheduleInfo]
           ,[strLoadDirectionMsg]
           ,[ysnUpdateLoadDirections]
           ,[ysnPrintLoadDirections]
           ,[strVendorReference]
           ,[strCustomerReference]
           ,[intAllocationDetailId]
           ,[intPickLotDetailId]
           ,[intPSubLocationId]
           ,[intSSubLocationId]
           ,[intNumberOfContainers]
           ,[strExternalShipmentItemNumber]
           ,[strExternalBatchNo]
           ,[ysnNoClaim]
	)
			
    SELECT			
			[intConcurrencyId]				= 1
           ,[intLoadId]						= LG.intLoadId
           ,[intVendorEntityId]				= CASE WHEN LL.galds_pur_sls_ind='P' 
												  THEN CS.intEntityId 
												  ELSE NULL END
           ,[intVendorEntityLocationId]		= CASE WHEN LL.galds_pur_sls_ind='P' 
												  THEN EL.intEntityLocationId 
												  ELSE NULL END
           ,[intCustomerEntityId]			= CASE WHEN LL.galds_pur_sls_ind='S' 
												  THEN CS.intEntityId 
												  ELSE NULL END
           ,[intCustomerEntityLocationId]	= CASE WHEN LL.galds_pur_sls_ind='S' 
												  THEN EL.intEntityLocationId 
												  ELSE NULL END
           ,[intItemId]						= IM.intItemId
           ,[intPContractDetailId]			= CASE 
												 WHEN LL.galds_pur_sls_ind='P' AND CH.intContractTypeId=1 THEN CD.intContractDetailId
												 ELSE NULL
											  END

           ,[intSContractDetailId]			= CASE 
												 WHEN LL.galds_pur_sls_ind='S' AND CH.intContractTypeId=2 THEN CD.intContractDetailId
												 ELSE NULL
											  END

           ,[intPCompanyLocationId]			= CASE 
												 WHEN LL.galds_pur_sls_ind='P' THEN CL.intCompanyLocationId
												 ELSE NULL
											  END

           ,[intSCompanyLocationId]			= CASE 
												 WHEN LL.galds_pur_sls_ind='S' THEN CL.intCompanyLocationId
												 ELSE NULL
											  END

           ,[dblQuantity]					= LL.galds_sched_un
           ,[intItemUOMId]					= IU.intItemUOMId
           ,[dblGross]						= LL.galds_sched_un
           ,[dblTare]						= 0
           ,[dblNet]						= LL.galds_sched_un
           ,[intWeightItemUOMId]			= IU.intItemUOMId
           ,[dblDeliveredQuantity]			= LL.galds_sched_un
           ,[dblDeliveredGross]				= LL.galds_sched_un
           ,[dblDeliveredTare]				= 0
           ,[dblDeliveredNet]				= LL.galds_sched_un
           ,[strLotAlias]					= NULL
           ,[strSupplierLotNumber]			= NULL
           ,[dtmProductionDate]				= NULL
           ,[strScheduleInfoMsg]			= NULL
           ,[ysnUpdateScheduleInfo]			= NULL
           ,[ysnPrintScheduleInfo]			= 1
           ,[strLoadDirectionMsg]			= NULL
           ,[ysnUpdateLoadDirections]		= NULL
           ,[ysnPrintLoadDirections]		= 1
           ,[strVendorReference]			= NULL
           ,[strCustomerReference]			= NULL
           ,[intAllocationDetailId]			= NULL
           ,[intPickLotDetailId]			= NULL
           ,[intPSubLocationId]				= NULL
           ,[intSSubLocationId]				= NULL
           ,[intNumberOfContainers]			= NULL		
           ,[strExternalShipmentItemNumber]	= NULL
           ,[strExternalBatchNo]			= NULL
           ,[ysnNoClaim]					= NULL
		   FROM galdsmst LL
		   JOIN tblLGLoad				LG	ON LG.[strLoadNumber] collate SQL_Latin1_General_CP1_CS_AS = LTRIM(RTRIM(LL.galds_load_no))+'_'+LTRIM(RTRIM(LL.galds_cus_no))+'_'+LTRIM(RTRIM(LL.galds_loc_no)) collate SQL_Latin1_General_CP1_CS_AS 
		   JOIN	tblSMCompanyLocation	CL	ON	LTRIM(RTRIM(CL.strLocationNumber)) collate SQL_Latin1_General_CP1_CS_AS  = LTRIM(RTRIM(LL.galds_loc_no)) collate SQL_Latin1_General_CP1_CS_AS
		   JOIN	gacntmst				CT	ON	gacnt_cnt_no = galds_cnt_no AND gacnt_cus_no = galds_cus_no AND
												gacnt_seq_no = galds_cnt_seq_no AND gacnt_sub_seq_no = galds_cnt_sub_no
			JOIN    tblCTContractHeader		CH  ON  LTRIM(RTRIM(CH.strContractNumber)) collate SQL_Latin1_General_CP1_CS_AS  = LTRIM(RtRIM(CT.gacnt_cnt_no))+'_'+LTRIM(RtRIM(CT.gacnt_cus_no))
											+'_'+LTRIM(RtRIM(CAST(CT.gacnt_seq_no AS CHAR(3))))+'_'+LTRIM(RtRIM(CAST(CT.gacnt_sub_seq_no AS CHAR(3))))+'_'+CAST(CT.A4GLIdentity AS CHAR(6)) collate SQL_Latin1_General_CP1_CS_AS
		   JOIN    tblCTContractDetail		CD  ON  CD.intContractSeq		= LL.galds_cnt_seq_no AND CD.intContractHeaderId	= CH.intContractHeaderId
		   LEFT	JOIN	tblARCustomer			CS	ON	LTRIM(RTRIM(CS.strCustomerNumber)) collate SQL_Latin1_General_CP1_CS_AS	= LTRIM(RTRIM(LL.galds_cus_no)) collate SQL_Latin1_General_CP1_CS_AS
	            JOIN	tblEMEntity				EM  ON	EM.intEntityId = CS.intEntityId
		   LEFT	JOIN	tblEMEntityLocation		EL	ON	EL.intEntityId	=	CS.intEntityId and EL.strLocationName = EM.strName
		   LEFT	JOIN	tblICCommodity			CO	ON	LTRIM(RTRIM(CO.strCommodityCode))  collate SQL_Latin1_General_CP1_CS_AS = LTRIM(RTRIM(LL.galds_com_cd)) collate SQL_Latin1_General_CP1_CS_AS 
		   LEFT	JOIN	tblICItem				IM	ON	LTRIM(RTRIM(IM.strItemNo))										= LTRIM(RTRIM(LL.galds_com_cd)) collate SQL_Latin1_General_CP1_CS_AS
		   LEFT	JOIN	tblICItemUOM			IU	ON	IU.intItemId	=	IM.intItemId AND IU.ysnStockUnit =1
		   WHERE LG.intLoadId > @MaxLoadId 
END	

GO

