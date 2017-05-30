CREATE PROCEDURE uspLGGetEmailInfo 
	 @intTransactionId INT
	,@strReportName NVARCHAR(100)
	,@strHyperLink NVARCHAR(MAX)
	,@strInstoreTo NVARCHAR(MAX) = NULL
AS
BEGIN
	DECLARE @strLoadNumber NVARCHAR(100)
	DECLARE @intEntityId INT
	DECLARE @strEntityName NVARCHAR(200)
	DECLARE @body NVARCHAR(MAX) = ''
	DECLARE @Subject NVARCHAR(MAX) = ''
	DECLARE @Filter NVARCHAR(MAX) = ''
	DECLARE @strIds AS NVARCHAR(MAX)
	DECLARE @intPurchaseSaleId INT 
	DECLARE @intInsurerEntityId INT
	DECLARE @ysnClaimsToProducer BIT
	DECLARE @intProducerEntityId INT
	DECLARE @strInstoreLetterName NVARCHAR(MAX)

	IF (@strReportName = 'ShippingInstruction' or @strReportName = 'ShippingInstruction2')
	BEGIN
		SELECT @strLoadNumber = strLoadNumber,
				@intPurchaseSaleId = intPurchaseSale
		FROM tblLGLoad
		WHERE intLoadId = @intTransactionId

		SELECT TOP 1 @ysnClaimsToProducer = ISNULL(CH.ysnClaimsToProducer, 0),
					 @intProducerEntityId = CD.intProducerId
		FROM tblLGLoad L
		JOIN tblLGLoadDetail LD ON L.intLoadId = LD.intLoadId
		JOIN tblCTContractDetail CD ON CD.intContractDetailId = CASE 
				WHEN L.intPurchaseSale = 1
					THEN LD.intPContractDetailId
				ELSE LD.intSContractDetailId
				END
		JOIN tblCTContractHeader CH ON CH.intContractHeaderId = CD.intContractHeaderId
		WHERE L.intLoadId = @intTransactionId


		IF (@ysnClaimsToProducer = 1)
		BEGIN
			SELECT @intEntityId = @intProducerEntityId
		END
		ELSE
		BEGIN
			SELECT @intEntityId = (
					SELECT TOP 1 CASE @intPurchaseSaleId
								 WHEN 1
									 THEN intVendorEntityId
								 WHEN 2
									 THEN intCustomerEntityId
								 WHEN 3
									 THEN intVendorEntityId
								 END
					FROM tblLGLoadDetail
					WHERE intLoadId = @intTransactionId
					)
		END

		SELECT @strEntityName = strName
		FROM tblEMEntity
		WHERE intEntityId = @intEntityId

		SELECT @strIds = STUFF((
					SELECT DISTINCT '|^|' + LTRIM(intEntityContactId)
					FROM vyuCTEntityToContact
					WHERE intEntityId = @intEntityId
					AND           ISNULL(strEmail,'') <> ''
					FOR XML PATH('')
					), 1, 3, '')
		FROM vyuCTEntityToContact CH
		WHERE intEntityId = @intEntityId

		SET @Subject = 'Load/Shipment Schedule - Shipping Instruction - ' + @strLoadNumber
		SET @body += '<!DOCTYPE html>'
		SET @body += '<html>'
		SET @body += '<body>Dear <strong>' + @strEntityName + '</strong>, <br><br>'
		SET @body += 'Please see your shipping instruction in the attachments tab. <br><br>'
		SET @body += 'Thank you for your business. <br><br>'
		SET @body += 'Sincerely, <br><br>'
		SET @body += '#SIGNATURE#'
		SET @body += '</html>'
		SET @Filter = '[{"column":"intEntityContactId","value":"' + @strIds + '","condition":"eq","conjunction":"and"}]'

		SELECT @Subject AS strSubject
			,@Filter AS strFilters
			,@body AS strMessage
	END
	ELSE IF (@strReportName = 'InsuranceLetter')
	BEGIN
		SELECT @strLoadNumber = strLoadNumber,
			   @intPurchaseSaleId = intPurchaseSale,
			   @intInsurerEntityId = intInsurerEntityId
		FROM tblLGLoad
		WHERE intLoadId = @intTransactionId

		SELECT @intEntityId = @intInsurerEntityId

		SELECT @strEntityName = strName
		FROM tblEMEntity
		WHERE intEntityId = @intEntityId

		SELECT @strIds = STUFF((
					SELECT DISTINCT '|^|' + LTRIM(intEntityContactId)
					FROM vyuCTEntityToContact
					WHERE intEntityId = @intEntityId
					AND           ISNULL(strEmail,'') <> ''
					FOR XML PATH('')
					), 1, 3, '')
		FROM vyuCTEntityToContact CH
		WHERE intEntityId = @intEntityId

		SET @Subject = 'Load/Shipment Schedule - Insurance Letter - ' + @strLoadNumber
		SET @body += '<!DOCTYPE html>'
		SET @body += '<html>'
		SET @body += '<body>Dear <strong>' + @strEntityName + '</strong>, <br><br>'
		SET @body += 'Please see your insurance letter in the attachments tab. <br><br>'
		SET @body += 'Thank you for your business. <br><br>'
		SET @body += 'Sincerely, <br><br>'
		SET @body += '#SIGNATURE#'
		SET @body += '</html>'
		SET @Filter = '[{"column":"intEntityContactId","value":"' + @strIds + '","condition":"eq","conjunction":"and"}]'

		SELECT @Subject AS strSubject
			,@Filter AS strFilters
			,@body AS strMessage
	END
	ELSE IF (@strReportName = 'DeliveryOrder')
	BEGIN
		SELECT @strLoadNumber = strLoadNumber,
			   @intPurchaseSaleId = intPurchaseSale
		FROM tblLGLoad
		WHERE intLoadId = @intTransactionId

		SELECT @intEntityId = (SELECT TOP 1 CASE @intPurchaseSaleId 
												WHEN 1 THEN intVendorEntityId 
												WHEN 2 THEN intCustomerEntityId 
												WHEN 3 THEN intCustomerEntityId END FROM tblLGLoadDetail WHERE intLoadId = @intTransactionId)

		SELECT @strEntityName = strName
		FROM tblEMEntity
		WHERE intEntityId = @intEntityId

		SELECT @strIds = STUFF((
					SELECT DISTINCT '|^|' + LTRIM(intEntityContactId)
					FROM vyuCTEntityToContact
					WHERE intEntityId = @intEntityId
					AND           ISNULL(strEmail,'') <> ''
					FOR XML PATH('')
					), 1, 3, '')
		FROM vyuCTEntityToContact CH
		WHERE intEntityId = @intEntityId

		SET @Subject = 'Load/Shipment Schedule - Deliver Order - ' + @strLoadNumber
		SET @body += '<!DOCTYPE html>'
		SET @body += '<html>'
		SET @body += '<body>Dear <strong>' + @strEntityName + '</strong>, <br><br>'
		SET @body += 'Please see your delivery order in the attachments tab. <br><br>'
		SET @body += 'Thank you for your business. <br><br>'
		SET @body += 'Sincerely, <br><br>'
		SET @body += '#SIGNATURE#'
		SET @body += '</html>'
		SET @Filter = '[{"column":"intEntityContactId","value":"' + @strIds + '","condition":"eq","conjunction":"and"}]'

		SELECT @Subject AS strSubject
			,@Filter AS strFilters
			,@body AS strMessage
	END
	ELSE IF (@strReportName = 'ShippingAdvice')
	BEGIN
		SELECT @strLoadNumber = strLoadNumber,
				@intPurchaseSaleId = intPurchaseSale
		FROM tblLGLoad
		WHERE intLoadId = @intTransactionId

		SELECT @intEntityId = (SELECT TOP 1 CASE @intPurchaseSaleId 
												WHEN 1 THEN intVendorEntityId 
												WHEN 2 THEN intCustomerEntityId 
												WHEN 3 THEN intCustomerEntityId END FROM tblLGLoadDetail WHERE intLoadId = @intTransactionId)

		SELECT @strEntityName = strName
		FROM tblEMEntity
		WHERE intEntityId = @intEntityId

		SELECT @strIds = STUFF((
					SELECT DISTINCT '|^|' + LTRIM(intEntityContactId)
					FROM vyuCTEntityToContact
					WHERE intEntityId = @intEntityId
					AND           ISNULL(strEmail,'') <> ''
					FOR XML PATH('')
					), 1, 3, '')
		FROM vyuCTEntityToContact CH
		WHERE intEntityId = @intEntityId

		SET @Subject = 'Load/Shipment Schedule - Shipping Advice - ' + @strLoadNumber
		SET @body += '<!DOCTYPE html>'
		SET @body += '<html>'
		SET @body += '<body>Dear <strong>' + @strEntityName + '</strong>, <br><br>'
		SET @body += 'Please see your shipping advice in the attachments tab. <br><br>'
		SET @body += 'Thank you for your business. <br><br>'
		SET @body += 'Sincerely, <br><br>'
		SET @body += '#SIGNATURE#'
		SET @body += '</html>'
		SET @Filter = '[{"column":"intEntityContactId","value":"' + @strIds + '","condition":"eq","conjunction":"and"}]'

		SELECT @Subject AS strSubject
			,@Filter AS strFilters
			,@body AS strMessage
	END
	ELSE IF (@strReportName = 'In_store' Or @strReportName = 'In_store2')
	BEGIN
		SELECT @strLoadNumber = strLoadNumber,
			   @intPurchaseSaleId = intPurchaseSale
		FROM tblLGLoad L
		JOIN tblLGLoadWarehouse LW ON LW.intLoadId = L.intLoadId
		WHERE LW.intLoadWarehouseId = @intTransactionId

		IF(@strInstoreTo = 'Warehouse')
		BEGIN
				SELECT @intEntityId = (SELECT EM.intEntityId FROM tblLGLoadWarehouse LW
							   JOIN tblSMCompanyLocationSubLocation CLSL ON LW.intSubLocationId = CLSL.intCompanyLocationSubLocationId
							   JOIN tblEMEntity EM ON EM.intEntityId = CLSL.intVendorId
							   WHERE LW.intLoadWarehouseId = @intTransactionId)

				SELECT @strInstoreLetterName = 'in store letter'				
		END
		ELSE 
		BEGIN
				SELECT @intEntityId = (SELECT EM.intEntityId FROM tblLGLoad L
								JOIN tblLGLoadWarehouse LW ON L.intLoadId = LW.intLoadId
								JOIN tblEMEntity EM ON EM.intEntityId = L.intShippingLineEntityId
								WHERE intLoadWarehouseId = @intTransactionId)

				SELECT @strInstoreLetterName = 'release order'
		END

		SELECT @strEntityName = strName
		FROM tblEMEntity
		WHERE intEntityId = @intEntityId

		SELECT @strIds = STUFF((
					SELECT DISTINCT '|^|' + LTRIM(intEntityContactId)
					FROM vyuCTEntityToContact
					WHERE intEntityId = @intEntityId
					AND           ISNULL(strEmail,'') <> ''
					FOR XML PATH('')
					), 1, 3, '')
		FROM vyuCTEntityToContact CH
		WHERE intEntityId = @intEntityId

        SET @Subject = 'Load/Shipment Schedule - ' + CASE WHEN @strInstoreTo = 'Warehouse' THEN 'In Store Letter' ELSE 'Release Order' END + ' - ' + @strLoadNumber
        SET @body += '<!DOCTYPE html>'
        SET @body += '<html>'
        SET @body += '<body>Dear <strong>' + @strEntityName + '</strong>, <br><br>'
        SET @body += 'Please see your "' + @strInstoreLetterName + '"  in the attachments tab. <br><br>'
        SET @body += 'Thank you for your business. <br><br>'
        SET @body += 'Sincerely, <br><br>'
		SET @body += '#SIGNATURE#'
        SET @body += '</html>'
        SET @Filter = '[{"column":"intEntityContactId","value":"' + @strIds + '","condition":"eq","conjunction":"and"}]'

		SELECT @Subject AS strSubject
			,@Filter AS strFilters
			,@body AS strMessage
	END
	ELSE IF (@strReportName = 'CarrierShipmentOrder')
	BEGIN
		SELECT @strLoadNumber = strLoadNumber,
				@intPurchaseSaleId = intPurchaseSale
		FROM tblLGLoad
		WHERE intLoadId = @intTransactionId

		SELECT @intEntityId = (SELECT TOP 1 CASE @intPurchaseSaleId 
												WHEN 1 THEN intVendorEntityId 
												WHEN 2 THEN intCustomerEntityId 
												WHEN 3 THEN intCustomerEntityId END FROM tblLGLoadDetail WHERE intLoadId = @intTransactionId)

		SELECT @strEntityName = strName
		FROM tblEMEntity
		WHERE intEntityId = @intEntityId

		SELECT @strIds = STUFF((
					SELECT DISTINCT '|^|' + LTRIM(intEntityContactId)
					FROM vyuCTEntityToContact
					WHERE intEntityId = @intEntityId
					AND           ISNULL(strEmail,'') <> ''
					FOR XML PATH('')
					), 1, 3, '')
		FROM vyuCTEntityToContact CH
		WHERE intEntityId = @intEntityId

		SET @Subject = 'Load/Shipment Schedule - Carrier Shipment Order - ' + @strLoadNumber
		SET @body += '<!DOCTYPE html>'
		SET @body += '<html>'
		SET @body += '<body>Dear <strong>' + @strEntityName + '</strong>, <br><br>'
		SET @body += 'Please see your carrier shipment order in the attachments tab. <br><br>'
		SET @body += 'Thank you for your business. <br><br>'
		SET @body += 'Sincerely, <br><br>'
		SET @body += '#SIGNATURE#'
		SET @body += '</html>'
		SET @Filter = '[{"column":"intEntityContactId","value":"' + @strIds + '","condition":"eq","conjunction":"and"}]'

		SELECT @Subject AS strSubject
			,@Filter AS strFilters
			,@body AS strMessage
	END

END