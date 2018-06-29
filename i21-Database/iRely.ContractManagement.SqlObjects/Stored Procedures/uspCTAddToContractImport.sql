CREATE PROCEDURE [dbo].[uspCTAddToContractImport]
	
	@strXML NVARCHAR(MAX)

AS

BEGIN TRY
	DECLARE @ErrMsg NVARCHAR(MAX)
	INSERT INTO tblCTContractImport
	(
			strContractType,
			strEntityName,
			strCommodity,
			strContractNumber,
			dtmContractDate,
			strSalesperson,
			strCropYear,
			strPosition,

			strLocationName,
			dtmStartDate,
			dtmEndDate,
			strItem,
			dblQuantity,
			strQuantityUOM,
			strPricingType,
			strFutMarketName,
			intMonth,
			intYear,
			dblFutures,
			dblBasis,
			dblCashPrice,
			strCurrency,
			strPriceUOM,
			strRemark,
			xmlInput
	)

	SELECT	buysell AS strContractType,
			customernumber AS strEntityName,
			commodity AS strCommodity,
			contractnumber AS strContractNumber,
			deliverystart AS dtmContractDate,
			originator AS strSalesperson,
			cropyear AS strCropYear,
			position AS strPosition,

			baselocation AS strCompanyLocation,
			deliverystart AS dtmStartDate,
			deliveryend AS dtmEndDate,
			item AS strItem,
			quantity AS dblQuantity,
			uom AS strQuantityUOM,
			contracttype AS strPricingType,
			market AS strFutMarketName,
			futuremonth AS intMonth,
			futureyear AS intYear,
			future AS dblFutures,
			basis AS dblBasis,
			cash AS dblCashPrice,
			currency AS strCurrency,
			uom AS strPriceUOM,
			comments AS strRemark,
			CAST(@strXML AS XML)

	FROM #tmpXMLTable

END TRY
BEGIN CATCH
	SET @ErrMsg = ERROR_MESSAGE()  
	RAISERROR (@ErrMsg,18,1,'WITH NOWAIT')
END CATCH