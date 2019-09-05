CREATE PROCEDURE uspCTItemContractReportItem

	@intItemContractHeaderId	INT
	
AS
 
BEGIN TRY
	
	DECLARE @ErrMsg						NVARCHAR(MAX),
			@intItemContractDetailId	INT
    
	DECLARE @ItemContractItems AS TABLE 
	(
		 intItemContractKey					INT IDENTITY(1, 1)
		,strCompanyName						NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL		
		,strCompanyAddress					NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL
		,strCompanyStateAddress				NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL
		,strCompanyCity						NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL
		,strCompanyState					NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL
		,strCompanyZip						NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL
		,strCustomerName					NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL
		,strCustomerAddress					NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL
		,strCustomerStateAddress			NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL
		,strCustomerCity					NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL
		,strCustomerState					NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL
		,strCustomerZipCode					NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL
		,strLocationName					NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL
		,strEntityNo						NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL
		,dtmContractDate					NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL
		,dtmLineLastDeliveryDate			NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL
		,dtmLineDeliveryDate				NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL
		,strLineItemNo						NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL
		,strLineItemDescription				NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL
		,dblLineItemQytSold					NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL
		,dblLineItemQytShipped				NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL
		,strLineUnitMeasure					NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL
		,strLineSymbolSold					NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL
		,strLineSymbolShipped				NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL
		,dblLinePrice						NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL
		,dblLineTotal						NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL		
		,strContractNumber					NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL		
		,intItemContractHeaderId			INT NULL
		,intItemContractDetailId			INT NULL
	)

	INSERT INTO @ItemContractItems
	(
		 strCompanyName				
		,strCompanyAddress			
		,strCompanyStateAddress		
		,strCompanyCity				
		,strCompanyState			
		,strCompanyZip				
		,strCustomerName			
		,strCustomerAddress
		,strCustomerStateAddress	
		,strCustomerCity			
		,strCustomerState			
		,strCustomerZipCode			
		,strLocationName			
		,strEntityNo				
		,dtmContractDate			
		,dtmLineLastDeliveryDate	
		,dtmLineDeliveryDate		
		,strLineItemNo				
		,strLineItemDescription		
		,dblLineItemQytSold
		,dblLineItemQytShipped
		,strLineUnitMeasure			
		,strLineSymbolSold
		,strLineSymbolShipped							
		,dblLinePrice				
		,dblLineTotal
		,strContractNumber
		,intItemContractHeaderId
		,intItemContractDetailId
	)
	SELECT	UPPER(tblSMCompanySetup.strCompanyName) as strCompanyName,
			UPPER(tblSMCompanySetup.strCompanyAddress) as strCompanyAddress,
			UPPER(tblSMCompanySetup.strCompanyStateAddress) as strCompanyStateAddress,
			UPPER(tblSMCompanySetup.strCompanyCity) as strCompanyCity,
			UPPER(tblSMCompanySetup.strCompanyState) as strCompanyState,
			UPPER(tblSMCompanySetup.strCompanyZip) as strCompanyZip,
			UPPER(B.strName) as strCustomerName,
			UPPER(C.strAddress) as strCustomerAddress,
			UPPER(C.strCity + ' ' + C.strState + ' ' +C.strZipCode) as strCustomerStateAddress,
			UPPER(C.strCity) as strCustomerCity,
			UPPER(C.strState) as strCustomerState,
			UPPER(C.strZipCode) as strCustomerZipCode,
			UPPER(A.strLocationName) as strLocationName,			
			UPPER(B.strEntityNo) as strEntityNo,
			CONVERT(VARCHAR(10), A.dtmContractDate, 101) as dtmContractDate,
			CONVERT(VARCHAR(10), F.dtmLastDeliveryDate, 101) as dtmLineLastDeliveryDate,
			CONVERT(VARCHAR(10), F.dtmDeliveryDate, 101) as dtmLineDeliveryDate,
			UPPER(F.strItemNo) as strLineItemNo,
			UPPER(F.strItemDescription) as strLineItemDescription,
			F.dblContracted as dblLineItemQytSold,
			CAST(E.dblQtyShipped as NUMERIC(36,6)) as dblLineItemQytShipped,
			UPPER(F.strUnitMeasure) as strLineUnitMeasure,
			UPPER(GA.strSymbol) as strLineSymbolSold,
			UPPER(G.strSymbol) as strLineSymbolShipped,
			E.dblPrice as dblLinePrice,
			CAST(ROUND(E.dblTotal,2) as NUMERIC(36,2)) as dblLineTotal,
			UPPER(F.strContractNumber) as strContractNumber,
			F.intItemContractHeaderId,
			F.intItemContractDetailId

			FROM vyuCTItemContractHeader A 
					LEFT JOIN tblEMEntity B ON A.intEntityId = B.intEntityId
					LEFT JOIN tblEMEntityLocation C ON A.intEntityId = C.intEntityId
					LEFT JOIN tblARCustomer D ON A.intEntityId = D.intEntityId
					LEFT JOIN tblARInvoiceDetail E ON A.intItemContractHeaderId = E.intItemContractHeaderId
					LEFT JOIN vyuCTItemContractDetail F ON E.intItemContractDetailId = F.intItemContractDetailId
					LEFT JOIN tblICItemUOM IU ON IU.intItemUOMId = E.intItemUOMId
					LEFT JOIN tblICUnitMeasure G ON IU.intUnitMeasureId = G.intUnitMeasureId
					LEFT JOIN tblICItemUOM IUA ON IUA.intItemUOMId = F.intItemUOMId
					LEFT JOIN tblICUnitMeasure GA ON IUA.intUnitMeasureId = GA.intUnitMeasureId
			,(SELECT TOP 1
					strCompanyName
					,strAddress AS strCompanyAddress
					,strCity + ' ' + strState + ' ' + strZip AS strCompanyStateAddress
					,strCity AS strCompanyCity
					,strState AS strCompanyState
					,strZip AS strCompanyZip
				FROM tblSMCompanySetup
			) tblSMCompanySetup
		WHERE C.intEntityLocationId = CASE
										WHEN D.intShipToId IS NOT NULL
											THEN D.intShipToId
										WHEN C.ysnDefaultLocation = 1
											THEN C.intEntityLocationId
										ELSE 0
									END
			AND A.intItemContractHeaderId = @intItemContractHeaderId

	INSERT INTO @ItemContractItems
	(
		strLineItemNo				
		,strLineItemDescription		
		,dblLineItemQytSold
		,dblLineItemQytShipped
		,strLineUnitMeasure			
		,strLineSymbolSold					
		,strLineSymbolShipped
		,dblLinePrice				
		,dblLineTotal
		,strContractNumber
		,intItemContractHeaderId
		,intItemContractDetailId
	)
	SELECT	UPPER(G.strItemNo) as strLineItemNo,
			UPPER(E.strTaxCode) as strLineItemDescription,
			G.dblContracted as dblLineItemQytSold,			
			CAST(A.dblQtyShipped as NUMERIC(36,6)) as dblLineItemQytShipped,
			UPPER(C.strUnitMeasure) as strLineUnitMeasure,
			CASE WHEN B.strCalculationMethod = 'Percentage' THEN NULL ELSE UPPER(UM.strSymbol) END as strLineSymbolSold,
			CASE WHEN B.strCalculationMethod = 'Percentage' THEN NULL ELSE UPPER(C.strSymbol) END as strLineSymbolShipped,
			UPPER(B.dblRate) as dblLinePrice,
			CAST(ROUND(ISNULL(B.dblAdjustedTax,0),2) as NUMERIC(36,2))  as dblLineTotal,
			UPPER(G.strContractNumber) as strContractNumber,
			A.intItemContractHeaderId,
			A.intItemContractDetailId

			FROM tblARInvoiceDetail A 
					LEFT JOIN tblARInvoiceDetailTax B ON A.intInvoiceDetailId = B.intInvoiceDetailId
					LEFT JOIN tblICUnitMeasure C ON B.intUnitMeasureId = C.intUnitMeasureId
					LEFT JOIN tblSMTaxCode E ON B.intTaxCodeId = E.intTaxCodeId
					LEFT JOIN vyuCTItemContractDetail G ON A.intItemContractDetailId = G.intItemContractDetailId
					LEFT JOIN tblICItemUOM IU ON IU.intItemUOMId = G.intItemUOMId
					LEFT JOIN tblICUnitMeasure UM ON IU.intUnitMeasureId = UM.intUnitMeasureId

		WHERE A.intItemContractHeaderId = @intItemContractHeaderId		


	SELECT * FROM @ItemContractItems ORDER BY intItemContractDetailId, intItemContractKey

END TRY

BEGIN CATCH

	SET @ErrMsg = 'uspCTItemContractReportItem - ' + ERROR_MESSAGE()  
	RAISERROR (@ErrMsg,18,1,'WITH NOWAIT')  
	
END CATCH
GO
