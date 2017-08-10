CREATE PROCEDURE uspLGGetLoadData
	@strLoadId NVARCHAR(MAX)
AS
BEGIN
	SET @strLoadId = REPLACE(@strLoadId,'|^|','^')

	SELECT L.*
		,strType = CASE L.intPurchaseSale
			WHEN 1
				THEN 'Inbound'
			WHEN 2
				THEN 'Outbound'
			WHEN 3
				THEN 'Drop Ship'
			END
		,strEquipmentType = EQ.strEquipmentType
		,strPosition = P.strPosition
		,strPositionType = P.strPositionType
		,strHauler = Hauler.strName
		,strWeightUnitMeasure = UM.strUnitMeasure
		,strScaleTicketNo = CASE 
			WHEN IsNull(L.intTicketId, 0) <> 0
				THEN CAST(ST.strTicketNumber AS VARCHAR(100))
			ELSE CASE 
					WHEN IsNull(L.intLoadHeaderId, 0) <> 0
						THEN TR.strTransaction
					ELSE NULL
					END
			END
		,intGenerateReferenceNumber = GL.intReferenceNumber
		,intNumberOfLoads = GL.intNumberOfLoads
		,strDispatcher = SE.strUserName
		,strShippingInstructionNo = SI.strLoadNumber
	FROM tblLGLoad L
	LEFT JOIN tblLGGenerateLoad GL ON GL.intGenerateLoadId = L.intGenerateLoadId 
	LEFT JOIN tblEMEntity Hauler ON Hauler.intEntityId = L.intHaulerEntityId
	LEFT JOIN tblEMEntity Driver ON Driver.intEntityId = L.intDriverEntityId
	LEFT JOIN tblCTPosition P ON L.intPositionId = P.intPositionId
	LEFT JOIN tblICUnitMeasure UM ON UM.intUnitMeasureId = L.intWeightUnitMeasureId
	LEFT JOIN tblLGEquipmentType EQ ON EQ.intEquipmentTypeId = L.intEquipmentTypeId
	LEFT JOIN tblSCTicket ST ON ST.intTicketId = L.intTicketId
	LEFT JOIN tblTRLoadHeader TR ON TR.intLoadHeaderId = L.intLoadHeaderId
	LEFT JOIN tblLGLoad LSI ON LSI.intLoadId = L.intLoadShippingInstructionId
	LEFT JOIN tblSMUserSecurity SE ON SE.intEntityId = L.intDispatcherId
	LEFT JOIN tblLGLoad SI ON SI.intLoadId = L.intLoadShippingInstructionId
	WHERE L.intLoadId IN (
				SELECT *
				FROM dbo.fnSplitString(@strLoadId, '^')
				)
END
