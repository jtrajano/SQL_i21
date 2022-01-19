CREATE VIEW vyuLGGenerateLoad
AS
SELECT GL.intGenerateLoadId
	  ,ISNULL(PCH.intEntityId, VLE.intEntityId)	AS intVendorEntityId
	  ,ISNULL(EV.strName, VLE.strName) 			AS strVendorName
	  ,EVL.intEntityLocationId					AS intVEntityLocationId
	  ,EVL.strLocationName						AS strVendorLocation
	  ,PCH.intContractHeaderId					AS intPContractHeaderId
	  ,PCD.intContractDetailId					AS intPContractDetailId
	  ,PCD.intContractSeq						AS intPContractSeq
	  ,PCH.strContractNumber					AS strPContractNo
	  ,PIM.intItemId							AS intPItemId --obsolete
	  ,PIM.strItemNo							AS strPItemNo --obsolete
	  ,PIM.strDescription						AS strPItemDescription --obsolete
	  ,PCL.strLocationName						AS strPCompanyLocation
	  ,GL.strPVendorContract
	  ,GL.dtmPArrivalDate --obsolete
	  ,ETP.intEquipmentTypeId					AS intPEquipmentType --obsolete
	  ,ETP.strEquipmentType						AS strPEquipmentType --obsolete
	  ,EPH.intEntityId							AS intPHaulerEntityId --obsolete
	  ,EPH.strName								AS strPHaulerName --obsolete

	  ,ISNULL(SCH.intEntityId, CLE.intEntityId) AS intCustomerEntityId
	  ,ISNULL(EC.strName, CLE.strName)			AS strCustomerName
	  ,ECL.intEntityLocationId					AS intCEntityLocationId
	  ,ECL.strLocationName						AS strCustomerLocation
	  ,SCH.intContractHeaderId					AS intSContractHeaderId
	  ,SCD.intContractDetailId					AS intSContractDetailId
	  ,SCD.intContractSeq						AS intSContractSeq
	  ,SCH.strContractNumber					AS strSContractNo
	  ,SIM.intItemId							AS intSItemId --obsolete
	  ,SIM.strItemNo							AS strSItemNo --obsolete
	  ,SIM.strDescription						AS strSItemDescription --obsolete
	  ,SCL.strLocationName						AS strSCompanyLocation
	  ,GL.strSCustomerContract
	  ,GL.dtmSShipToDate --obsolete
	  ,ETS.intEquipmentTypeId					AS intSEquipmentType --obsolete
	  ,ETS.strEquipmentType						AS strSEquipmentType --obsolete
	  ,ESH.intEntityId							AS intSHaulerEntityId --obsolete
	  ,ESH.strName								AS strSHaulerName --obsolete

	  ,GL.dtmShipDate
	  ,GL.dtmEndDate
	  ,GL.intItemId
	  ,I.strItemNo								AS strItemNo
	  ,I.strDescription							AS strItemDescription
	  ,UM.intItemUOMId							AS intItemUOMId
	  ,UM.intUnitMeasureId						AS intUnitMeasureId
	  ,UM.strUnitMeasure						AS strUnitMeasure
	  ,WUOM.intItemUOMId						AS intWeightUOMId
	  ,WUM.intUnitMeasureId						AS intWeightUnitMeasureId
	  ,WUM.strUnitMeasure						AS strWeightUnitMeasure
	  ,ET.intEquipmentTypeId					AS intEquipmentTypeId
	  ,ET.strEquipmentType						AS strEquipmentType
	  ,EH.intEntityId							AS intHaulerEntityId
	  ,EH.strName								AS strHaulerName
	  ,DV.intEntityId							AS intDriverEntityId
	  ,DV.strName								AS strDriverName
	  ,GL.dblFreightRate
	  ,GL.intFreightCurrencyId
	  ,CUR.strCurrency							AS strFreightCurrency
	  ,GL.intFreightUOMId
	  ,FUM.strUnitMeasure						AS strFreightUnitMeasure
	  ,GL.dblSurchargeRate
	  ,GL.intType			
	  ,CASE GL.intType
		WHEN 1
			THEN 'Inbound'	
		WHEN 2
			THEN 'Outbound'
		WHEN 3
			THEN 'Drop Ship'
		END COLLATE Latin1_General_CI_AS AS strType
	  ,GL.intSourceType
	  ,CASE GL.intSourceType
		WHEN 1
			THEN 'Manual'
		WHEN 2
			THEN 'Allocation'
		END COLLATE Latin1_General_CI_AS AS strSourceType
	  ,GL.intTransUsedBy
	  ,CASE GL.intTransUsedBy
		WHEN 1
			THEN 'None'	
		WHEN 2
			THEN 'Scale Ticket'
		WHEN 3
			THEN 'Transport Load'
		END COLLATE Latin1_General_CI_AS AS strTransUsedBy	
	  ,GL.intTransportationMode 
	  ,CASE GL.intTransportationMode
		WHEN 1
			THEN 'Truck'	
		WHEN 2
			THEN 'Ocean Vessel'
		WHEN 3
			THEN 'Rail'
		END COLLATE Latin1_General_CI_AS AS strTransportationMode	 
	  ,GL.intAllocationDetailId
	  ,AH.strAllocationNumber
	  ,CP.intDefaultFreightItemId
	  ,CP.intDefaultSurchargeItemId
	  ,FT.intFreightTermId
	  ,FT.strFreightTerm
	  ,intPositionId = CASE WHEN GL.intType = 2 THEN SCH.intPositionId ELSE PCH.intPositionId END
	  ,strPositionType = CASE WHEN GL.intType = 2 THEN SPT.strPositionType ELSE PPT.strPositionType END

FROM tblLGGenerateLoad			GL

LEFT JOIN tblCTContractDetail	PCD		ON		PCD.intContractDetailId		=	GL.intPContractDetailId
LEFT JOIN tblCTContractHeader	PCH		ON		PCH.intContractHeaderId		=	PCD.intContractHeaderId
LEFT JOIN tblCTPosition			PPT		ON		PPT.intPositionId			=	PCH.intPositionId
LEFT JOIN tblEMEntity			EV		ON		EV.intEntityId				=	PCH.intEntityId
LEFT JOIN tblEMEntityLocation	EVL		ON		EVL.intEntityLocationId		=	GL.intPEntityLocationId
LEFT JOIN tblEMEntity			VLE		ON		VLE.intEntityId				=	EVL.intEntityId
LEFT JOIN tblICItem				PIM		ON		PIM.intItemId				=	PCD.intItemId --obsolete
LEFT JOIN tblSMCompanyLocation	PCL		ON		PCL.intCompanyLocationId	=	GL.intPCompanyLocationId
LEFT JOIN tblLGEquipmentType	ETP		ON		ETP.intEquipmentTypeId		=	GL.intPEquipmentTypeId --obsolete
LEFT JOIN tblEMEntity			EPH		ON		EPH.intEntityId				=	GL.intPHaulerEntityId --obsolete

LEFT JOIN tblCTContractDetail	SCD		ON		SCD.intContractDetailId		=	GL.intSContractDetailId
LEFT JOIN tblCTContractHeader	SCH		ON		SCH.intContractHeaderId		=	SCD.intContractHeaderId
LEFT JOIN tblCTPosition			SPT		ON		SPT.intPositionId			=	SCH.intPositionId
LEFT JOIN tblEMEntity			EC		ON		EC.intEntityId				=	SCH.intEntityId
LEFT JOIN tblEMEntityLocation	ECL		ON		ECL.intEntityLocationId		=	GL.intSEntityLocationId
LEFT JOIN tblEMEntity			CLE		ON		CLE.intEntityId				=	ECL.intEntityId
LEFT JOIN tblICItem				SIM		ON		SIM.intItemId				=	SCD.intItemId --obsolete
LEFT JOIN tblSMCompanyLocation	SCL		ON		SCL.intCompanyLocationId	=	GL.intSCompanyLocationId
LEFT JOIN tblLGEquipmentType	ETS		ON		ETS.intEquipmentTypeId		=	GL.intSEquipmentTypeId --obsolete
LEFT JOIN tblEMEntity			ESH		ON		ESH.intEntityId				=	GL.intSHaulerEntityId --obsolete
LEFT JOIN tblLGAllocationDetail	AD		ON		AD.intAllocationDetailId	=	GL.intAllocationDetailId
LEFT JOIN tblLGAllocationHeader	AH		ON		AH.intAllocationHeaderId	=	AD.intAllocationHeaderId

LEFT JOIN tblICItem				I		ON		GL.intItemId				=	I.intItemId
LEFT JOIN tblLGEquipmentType	ET		ON		ET.intEquipmentTypeId		=	GL.intEquipmentTypeId
LEFT JOIN tblEMEntity			EH		ON		EH.intEntityId				=	GL.intHaulerEntityId
LEFT JOIN tblEMEntity			DV		ON		DV.intEntityId				=	GL.intDriverEntityId
LEFT JOIN tblSMCurrency			CUR		ON		CUR.intCurrencyID			=	GL.intFreightCurrencyId 
LEFT JOIN tblICItemUOM			FUOM	ON		FUOM.intItemUOMId			=	GL.intFreightUOMId
LEFT JOIN tblICUnitMeasure		FUM		ON		FUOM.intUnitMeasureId		=	FUM.intUnitMeasureId
OUTER APPLY (SELECT TOP 1 IUOM.intItemUOMId, IUOM.intUnitMeasureId, UM.strUnitMeasure 
				FROM tblICItemUOM IUOM INNER JOIN tblICUnitMeasure UM ON IUOM.intUnitMeasureId = UM.intUnitMeasureId
				WHERE IUOM.intItemId = GL.intItemId AND UM.intUnitMeasureId = GL.intUnitMeasureId) UM
OUTER APPLY tblLGCompanyPreference CP
LEFT JOIN tblICItemUOM			WUOM	ON		WUOM.intItemUOMId = COALESCE(PCD.intNetWeightUOMId, SCD.intNetWeightUOMId, CP.intWeightUOMId)
LEFT JOIN tblICUnitMeasure		WUM		ON		WUOM.intUnitMeasureId = WUM.intUnitMeasureId
LEFT JOIN tblSMFreightTerms		FT		ON		FT.intFreightTermId = COALESCE(PCH.intFreightTermId, SCH.intFreightTermId, CP.intDefaultFreightTermId)