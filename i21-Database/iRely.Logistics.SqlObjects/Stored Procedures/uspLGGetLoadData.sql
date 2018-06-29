CREATE PROCEDURE uspLGGetLoadData 
	 @strLoadId NVARCHAR(MAX)
	,@strLoadNumber NVARCHAR(MAX) = NULL
	,@intStart INT
AS
BEGIN
	DECLARE @intLoadIdCount INT

	SET @strLoadId = REPLACE(@strLoadId, '|^|', ',')

	IF (ISNULL(@strLoadNumber, '') = '')
	BEGIN
		SELECT @intLoadIdCount = COUNT(*)
		FROM tblLGLoad L
		WHERE L.intLoadId IN (SELECT *
							  FROM dbo.fnSplitString(@strLoadId, ','))

		SELECT * FROM (
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
				,FT.strFreightTerm
				,FT.strFobPoint
				,CU.strCurrency
				,CONT.strContainerType
				,ShippingLine.strName AS strShippingLine			
				,Terminal.strName AS strTerminal
				,ForwardingAgent.strName AS strForwardingAgent
				,Insurer.strName AS strInsurer
				,Currency.strCurrency AS strInsuranceCurrency
				,BLDraftToBeSent.strName AS strBLDraftToBeSent
				,NP.strName AS strDocPresentationVal 
				,ETAPODRC.strReasonCodeDescription AS strETAPODReasonCode
				,ETAPOLRC.strReasonCodeDescription AS strETAPOLReasonCode
				,ETSPOLRC.strReasonCodeDescription AS strETSPOLReasonCode
				,DemurrageCurrency.strCurrency AS strDemurrageCurrency
				,DespatchCurrency.strCurrency AS strDespatchCurrency
				,LoadingUnit.strUnitMeasure AS strLoadingUnitMeasure
				,DischargeUnit.strUnitMeasure AS strDischargeUnitMeasure
				,Driver.strName AS strDriver
				,DENSE_RANK() OVER (
					ORDER BY L.intLoadId DESC
					) intRankNo
				,BO.strBook
				,SB.strSubBook
				,INC.intInsuranceCalculatorId
			FROM tblLGLoad L
			LEFT JOIN tblLGGenerateLoad GL ON GL.intGenerateLoadId = L.intGenerateLoadId
			LEFT JOIN tblEMEntity Hauler ON Hauler.intEntityId = L.intHaulerEntityId
			LEFT JOIN tblEMEntity Driver ON Driver.intEntityId = L.intDriverEntityId
			LEFT JOIN tblEMEntity ShippingLine ON ShippingLine.intEntityId = L.intShippingLineEntityId
			LEFT JOIN tblEMEntity Terminal ON Terminal.intEntityId = L.intTerminalEntityId
			LEFT JOIN tblEMEntity ForwardingAgent ON ForwardingAgent.intEntityId = L.intForwardingAgentEntityId
			LEFT JOIN tblEMEntity Insurer ON Insurer.intEntityId = L.intInsurerEntityId
			LEFT JOIN tblEMEntity BLDraftToBeSent ON BLDraftToBeSent.intEntityId = L.intBLDraftToBeSentId
			LEFT JOIN tblCTPosition P ON L.intPositionId = P.intPositionId
			LEFT JOIN tblICUnitMeasure UM ON UM.intUnitMeasureId = L.intWeightUnitMeasureId
			LEFT JOIN tblLGEquipmentType EQ ON EQ.intEquipmentTypeId = L.intEquipmentTypeId
			LEFT JOIN tblSCTicket ST ON ST.intTicketId = L.intTicketId
			LEFT JOIN tblTRLoadHeader TR ON TR.intLoadHeaderId = L.intLoadHeaderId
			LEFT JOIN tblLGLoad LSI ON LSI.intLoadId = L.intLoadShippingInstructionId
			LEFT JOIN tblSMUserSecurity SE ON SE.intEntityId = L.intDispatcherId
			LEFT JOIN tblLGLoad SI ON SI.intLoadId = L.intLoadShippingInstructionId
			LEFT JOIN tblSMFreightTerms FT ON FT.intFreightTermId = L.intFreightTermId
			LEFT JOIN tblSMCurrency CU ON CU.intCurrencyID = L.intCurrencyId
			LEFT JOIN tblSMCurrency Currency ON Currency.intCurrencyID = L.intInsuranceCurrencyId
			LEFT JOIN tblLGContainerType CONT ON CONT.intContainerTypeId = L.intContainerTypeId
			LEFT JOIN vyuLGNotifyParties NP ON NP.intEntityId = L.intDocPresentationId AND NP.strEntity = L.strDocPresentationType
			LEFT JOIN tblLGReasonCode ETAPODRC ON ETAPODRC.intReasonCodeId = L.intETAPODReasonCodeId
			LEFT JOIN tblLGReasonCode ETAPOLRC ON ETAPOLRC.intReasonCodeId = L.intETAPOLReasonCodeId
			LEFT JOIN tblLGReasonCode ETSPOLRC ON ETSPOLRC.intReasonCodeId = L.intETSPOLReasonCodeId
			LEFT JOIN tblSMCurrency DemurrageCurrency ON DemurrageCurrency.intCurrencyID = L.intDemurrageCurrencyId
			LEFT JOIN tblSMCurrency DespatchCurrency ON DespatchCurrency.intCurrencyID = L.intDespatchCurrencyId
			LEFT JOIN tblICUnitMeasure LoadingUnit ON LoadingUnit.intUnitMeasureId = L.intLoadingUnitMeasureId
			LEFT JOIN tblICUnitMeasure DischargeUnit ON DischargeUnit.intUnitMeasureId = L.intDischargeUnitMeasureId
			LEFT JOIN tblCTBook BO ON BO.intBookId = L.intBookId
			LEFT JOIN tblCTSubBook SB ON SB.intSubBookId = L.intSubBookId
			LEFT JOIN tblLGInsuranceCalculator INC ON INC.intLoadId = L.intLoadId
			WHERE L.intLoadId IN (
					SELECT *
					FROM dbo.fnSplitString(@strLoadId, ',')
					)
			) t
		WHERE intRankNo = ISNULL(@intStart, 0) + 1
		ORDER BY intLoadId DESC
	END
	ELSE
	BEGIN
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
			,FT.strFreightTerm
			,FT.strFobPoint
			,CU.strCurrency
			,CONT.strContainerType
			,ShippingLine.strName AS strShippingLine			
			,Terminal.strName AS strTerminal
			,ForwardingAgent.strName AS strForwardingAgent
			,Insurer.strName AS strInsurer
			,Currency.strCurrency AS strInsuranceCurrency
			,BLDraftToBeSent.strName AS strBLDraftToBeSent
			,NP.strName AS strDocPresentationVal  
			,ETAPODRC.strReasonCodeDescription AS strETAPODReasonCode
			,ETAPOLRC.strReasonCodeDescription AS strETAPOLReasonCode
			,ETSPOLRC.strReasonCodeDescription AS strETSPOLReasonCode
			,DemurrageCurrency.strCurrency AS strDemurrageCurrency
			,DespatchCurrency.strCurrency AS strDespatchCurrency
			,LoadingUnit.strUnitMeasure AS strLoadingUnitMeasure
			,DischargeUnit.strUnitMeasure AS strDischargeUnitMeasure
			,Driver.strName AS strDriver
			,BO.strBook
			,SB.strSubBook
			,INC.intInsuranceCalculatorId
		FROM tblLGLoad L
		LEFT JOIN tblLGGenerateLoad GL ON GL.intGenerateLoadId = L.intGenerateLoadId
		LEFT JOIN tblEMEntity Hauler ON Hauler.intEntityId = L.intHaulerEntityId
		LEFT JOIN tblEMEntity Driver ON Driver.intEntityId = L.intDriverEntityId
		LEFT JOIN tblEMEntity ShippingLine ON ShippingLine.intEntityId = L.intShippingLineEntityId
		LEFT JOIN tblEMEntity Terminal ON Terminal.intEntityId = L.intTerminalEntityId
		LEFT JOIN tblEMEntity ForwardingAgent ON ForwardingAgent.intEntityId = L.intForwardingAgentEntityId
		LEFT JOIN tblEMEntity Insurer ON Insurer.intEntityId = L.intInsurerEntityId
		LEFT JOIN tblEMEntity BLDraftToBeSent ON BLDraftToBeSent.intEntityId = L.intBLDraftToBeSentId
		LEFT JOIN tblCTPosition P ON L.intPositionId = P.intPositionId
		LEFT JOIN tblICUnitMeasure UM ON UM.intUnitMeasureId = L.intWeightUnitMeasureId
		LEFT JOIN tblLGEquipmentType EQ ON EQ.intEquipmentTypeId = L.intEquipmentTypeId
		LEFT JOIN tblSCTicket ST ON ST.intTicketId = L.intTicketId
		LEFT JOIN tblTRLoadHeader TR ON TR.intLoadHeaderId = L.intLoadHeaderId
		LEFT JOIN tblLGLoad LSI ON LSI.intLoadId = L.intLoadShippingInstructionId
		LEFT JOIN tblSMUserSecurity SE ON SE.intEntityId = L.intDispatcherId
		LEFT JOIN tblLGLoad SI ON SI.intLoadId = L.intLoadShippingInstructionId
		LEFT JOIN tblSMFreightTerms FT ON FT.intFreightTermId = L.intFreightTermId
		LEFT JOIN tblSMCurrency CU ON CU.intCurrencyID = L.intCurrencyId
		LEFT JOIN tblSMCurrency Currency ON Currency.intCurrencyID = L.intInsuranceCurrencyId
		LEFT JOIN tblLGContainerType CONT ON CONT.intContainerTypeId = L.intContainerTypeId
		LEFT JOIN vyuLGNotifyParties NP ON NP.intEntityId = L.intDocPresentationId AND NP.strEntity = L.strDocPresentationType
		LEFT JOIN tblLGReasonCode ETAPODRC ON ETAPODRC.intReasonCodeId = L.intETAPODReasonCodeId
		LEFT JOIN tblLGReasonCode ETAPOLRC ON ETAPOLRC.intReasonCodeId = L.intETAPOLReasonCodeId
		LEFT JOIN tblLGReasonCode ETSPOLRC ON ETSPOLRC.intReasonCodeId = L.intETSPOLReasonCodeId
		LEFT JOIN tblSMCurrency DemurrageCurrency ON DemurrageCurrency.intCurrencyID = L.intDemurrageCurrencyId
		LEFT JOIN tblSMCurrency DespatchCurrency ON DespatchCurrency.intCurrencyID = L.intDespatchCurrencyId
		LEFT JOIN tblICUnitMeasure LoadingUnit ON LoadingUnit.intUnitMeasureId = L.intLoadingUnitMeasureId
		LEFT JOIN tblICUnitMeasure DischargeUnit ON DischargeUnit.intUnitMeasureId = L.intDischargeUnitMeasureId
		LEFT JOIN tblCTBook BO ON BO.intBookId = L.intBookId
		LEFT JOIN tblCTSubBook SB ON SB.intSubBookId = L.intSubBookId
		LEFT JOIN tblLGInsuranceCalculator INC ON INC.intLoadId = L.intLoadId
		WHERE L.strLoadNumber COLLATE Latin1_General_CI_AS IN (
				SELECT *
				FROM dbo.fnSplitString(@strLoadNumber, ',')
				)
		ORDER BY L.intLoadId DESC
	END
END