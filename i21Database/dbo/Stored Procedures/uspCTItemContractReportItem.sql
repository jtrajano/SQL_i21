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
		,dblLineItemQytShipped				NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL
		,strLineUnitMeasure					NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL
		,strLineSymbol						NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL
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
		,dblLineItemQytShipped
		,strLineUnitMeasure			
		,strLineSymbol							
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
			CONVERT(VARCHAR(10), E.dtmLastDeliveryDate, 101) as dtmLineLastDeliveryDate,
			CONVERT(VARCHAR(10), E.dtmDeliveryDate, 101) as dtmLineDeliveryDate,
			UPPER(E.strItemNo) as strLineItemNo,
			UPPER(E.strItemDescription) as strLineItemDescription,
			E.dblContracted as dblLineItemQytShipped,
			UPPER(E.strUnitMeasure) as strLineUnitMeasure,
			UPPER(F.strSymbol) as strLineSymbol,
			E.dblPrice as dblLinePrice,
			CAST(ROUND(E.dblTotal,2) as NUMERIC(36,2)) as dblLineTotal,
			UPPER(E.strContractNumber) as strContractNumber,
			E.intItemContractHeaderId,
			E.intItemContractDetailId

			FROM vyuCTItemContractHeader A 
					LEFT JOIN tblEMEntity B ON A.intEntityId = B.intEntityId
					LEFT JOIN tblEMEntityLocation C ON A.intEntityId = C.intEntityId
					LEFT JOIN tblARCustomer D ON A.intEntityId = D.intEntityId
					LEFT JOIN vyuCTItemContractDetail E ON A.intItemContractHeaderId = E.intItemContractHeaderId
					LEFT JOIN tblICUnitMeasure F ON E.intItemUOMId = F.intUnitMeasureId
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
			AND A.strContractCategoryId = 'Item'
			AND A.intItemContractHeaderId = @intItemContractHeaderId

	INSERT INTO @ItemContractItems
	(
		strLineItemNo				
		,strLineItemDescription		
		,dblLineItemQytShipped
		,strLineUnitMeasure			
		,strLineSymbol					
		,dblLinePrice				
		,dblLineTotal
		,strContractNumber
		,intItemContractHeaderId
		,intItemContractDetailId
	)
	SELECT	UPPER(E.strItemNo) as strLineItemNo,
			UPPER(I.strTaxCode) as strLineItemDescription,
			E.dblContracted as dblLineItemQytShipped,
			UPPER(E.strUnitMeasure) as strLineUnitMeasure,
			UPPER(F.strSymbol) as strLineSymbol,
			UPPER(J.dblRate) as dblLinePrice,
			CAST(ROUND(ISNULL(J.dblRate,0) * ISNULL(E.dblContracted,0),2) as NUMERIC(36,2))  as dblLineTotal,
			UPPER(E.strContractNumber) as strContractNumber,
			E.intItemContractHeaderId,
			E.intItemContractDetailId

			FROM vyuCTItemContractDetail E 
					LEFT JOIN tblICUnitMeasure F ON E.intItemUOMId = F.intUnitMeasureId
					LEFT JOIN tblSMTaxGroupCode G ON E.intTaxGroupId = G.intTaxGroupId
					LEFT JOIN tblSMTaxCode I ON G.intTaxCodeId = I.intTaxCodeId
					LEFT JOIN tblSMTaxCodeRate J ON I.intTaxCodeId = J.intTaxCodeId
		WHERE E.intItemContractHeaderId = @intItemContractHeaderId

	SELECT * FROM @ItemContractItems ORDER BY intItemContractKey

END TRY

BEGIN CATCH

	SET @ErrMsg = 'uspCTItemContractReportItem - ' + ERROR_MESSAGE()  
	RAISERROR (@ErrMsg,18,1,'WITH NOWAIT')  
	
END CATCH
GO
