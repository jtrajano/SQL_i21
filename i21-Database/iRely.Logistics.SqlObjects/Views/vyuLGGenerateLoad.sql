CREATE VIEW vyuLGGenerateLoad
AS
SELECT GL.intGenerateLoadId
	  ,PCH.intEntityId			AS intVendorEntityId
	  ,EV.strName				AS strVendorName
	  ,EVL.intEntityLocationId	AS intVEntityLocationId
	  ,EVL.strLocationName		AS strVendorLocation
	  ,PCH.intContractHeaderId	AS intPContractHeaderId
	  ,PCD.intContractDetailId	AS intPContractDetailId
	  ,PCH.strContractNumber	AS strPContractNo
	  ,PIM.intItemId			AS intPItemId
	  ,PIM.strItemNo			AS strPItemNo
	  ,PIM.strDescription		AS strPItemDescription
	  ,PCL.strLocationName		AS strPCompanyLocation
	  ,GL.strPVendorContract
	  ,GL.dtmPArrivalDate
	  ,ETP.intEquipmentTypeId	AS intPEquipmentType
	  ,ETP.strEquipmentType		AS strPEquipmentType
	  ,EPH.intEntityId			AS intPHaulerEntityId
	  ,EPH.strName				AS strPHaulerName

	  ,SCH.intEntityId			AS intCustomerEntityId
	  ,EC.strName				AS strCustomerName
	  ,ECL.intEntityLocationId	AS intCEntityLocationId
	  ,ECL.strLocationName		AS strCustomerLocation
	  ,SCH.intContractHeaderId	AS intSContractHeaderId
	  ,SCH.strContractNumber	AS strSContractNo
	  ,SIM.intItemId			AS intSItemId	
	  ,SIM.strItemNo			AS strSItemNo
	  ,SIM.strDescription		AS strSItemDescription
	  ,SCL.strLocationName		AS strSCompanyLocation
	  ,GL.strSCustomerContract
	  ,GL.dtmSShipToDate
	  ,ETS.intEquipmentTypeId	AS intSEquipmentType
	  ,ETS.strEquipmentType		AS strSEquipmentType
	  ,ESH.intEntityId			AS intSHaulerEntityId
	  ,ESH.strName				AS strSHaulerName
	  ,GL.intType			
	  ,CASE GL.intType
		WHEN 1
			THEN 'Inbound'	
		WHEN 2
			THEN 'Outbound'
		WHEN 3
			THEN 'Drop Ship'
		END AS strType
	  ,GL.intSourceType
	  ,CASE GL.intSourceType
		WHEN 1
			THEN 'Manual'
		WHEN 2
			THEN 'Allocation'
		END AS strSourceType
	  ,GL.intTransUsedBy
	  ,CASE GL.intTransUsedBy
		WHEN 1
			THEN 'None'	
		WHEN 2
			THEN 'Scale Ticket'
		WHEN 3
			THEN 'Transport Load'
		END AS strTransUsedBy	  
	  ,GL.intAllocationDetailId
	  ,AH.strAllocationNumber

FROM tblLGGenerateLoad			GL

LEFT JOIN tblCTContractDetail	PCD		ON		PCD.intContractDetailId		=	GL.intPContractDetailId
LEFT JOIN tblCTContractHeader	PCH		ON		PCH.intContractHeaderId		=	PCD.intContractHeaderId
LEFT JOIN tblEMEntity			EV		ON		EV.intEntityId				=	PCH.intEntityId
LEFT JOIN tblEMEntityLocation	EVL		ON		EVL.intEntityLocationId		=	GL.intPEntityLocationId
LEFT JOIN tblICItem				PIM		ON		PIM.intItemId				=	PCD.intItemId
LEFT JOIN tblSMCompanyLocation	PCL		ON		PCL.intCompanyLocationId	=	GL.intPCompanyLocationId
LEFT JOIN tblLGEquipmentType	ETP		ON		ETP.intEquipmentTypeId		=	GL.intPEquipmentTypeId
LEFT JOIN tblEMEntity			EPH		ON		EPH.intEntityId				=	GL.intPHaulerEntityId

LEFT JOIN tblCTContractDetail	SCD		ON		SCD.intContractDetailId		=	GL.intSContractDetailId
LEFT JOIN tblCTContractHeader	SCH		ON		SCH.intContractHeaderId		=	SCD.intContractHeaderId
LEFT JOIN tblEMEntity			EC		ON		EC.intEntityId				=	SCH.intEntityId
LEFT JOIN tblEMEntityLocation	ECL		ON		ECL.intEntityLocationId		=	GL.intSEntityLocationId
LEFT JOIN tblICItem				SIM		ON		SIM.intItemId				=	SCD.intItemId
LEFT JOIN tblSMCompanyLocation	SCL		ON		SCL.intCompanyLocationId	=	GL.intSCompanyLocationId
LEFT JOIN tblLGEquipmentType	ETS		ON		ETS.intEquipmentTypeId		=	GL.intSEquipmentTypeId
LEFT JOIN tblEMEntity			ESH		ON		ESH.intEntityId				=	GL.intSHaulerEntityId
LEFT JOIN tblLGAllocationDetail	AD		ON		AD.intAllocationDetailId	=	GL.intAllocationDetailId
LEFT JOIN tblLGAllocationHeader	AH		ON		AH.intAllocationHeaderId	=	AD.intAllocationHeaderId 