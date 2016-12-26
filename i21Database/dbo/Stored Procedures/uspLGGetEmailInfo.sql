﻿CREATE PROCEDURE uspLGGetEmailInfo 
	 @intTransactionId INT
	,@strReportName NVARCHAR(100)
	,@strHyperLink NVARCHAR(MAX)
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

	IF (@strReportName = 'ShippingInstruction')
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
					SELECT DISTINCT ', ' + LTRIM(intEntityContactId)
					FROM vyuCTEntityToContact
					WHERE intEntityId = @intEntityId
					FOR XML PATH('')
					), 1, 2, '')
		FROM vyuCTEntityToContact CH
		WHERE intEntityId = @intEntityId

		SET @Subject = 'Load/Shipment Schedule - Shipping Instruction - ' + @strLoadNumber
		SET @body += '<!DOCTYPE html>'
		SET @body += '<html>'
		SET @body += '<body>Dear <strong>' + @strEntityName + '</strong>, <br><br>'
		SET @body += 'Please see your ' + LOWER(@strReportName) + ' in the attachments tab. <br><br>'
		SET @body += 'Thank you for your business. <br><br>'
		SET @body += 'Sincerely, <br><br>'
		SET @body += '</html>'
		SET @Filter = '[{"column":"intEntityId","value":"' + @strIds + '","condition":"eq","conjunction":"and"}]'

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
					SELECT DISTINCT ', ' + LTRIM(intEntityContactId)
					FROM vyuCTEntityToContact
					WHERE intEntityId = @intEntityId
					FOR XML PATH('')
					), 1, 2, '')
		FROM vyuCTEntityToContact CH
		WHERE intEntityId = @intEntityId

		SET @Subject = 'Load/Shipment Schedule - Insurance Letter - ' + @strLoadNumber
		SET @body += '<!DOCTYPE html>'
		SET @body += '<html>'
		SET @body += '<body>Dear <strong>' + @strEntityName + '</strong>, <br><br>'
		SET @body += 'Please see your ' + LOWER(@strReportName) + ' in the attachments tab. <br><br>'
		SET @body += 'Thank you for your business. <br><br>'
		SET @body += 'Sincerely, <br><br>'
		SET @body += '</html>'
		SET @Filter = '[{"column":"intEntityId","value":"' + @strIds + '","condition":"eq","conjunction":"and"}]'

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
					SELECT DISTINCT ', ' + LTRIM(intEntityContactId)
					FROM vyuCTEntityToContact
					WHERE intEntityId = @intEntityId
					FOR XML PATH('')
					), 1, 2, '')
		FROM vyuCTEntityToContact CH
		WHERE intEntityId = @intEntityId

		SET @Subject = 'Load/Shipment Schedule - Deliver Order - ' + @strLoadNumber
		SET @body += '<!DOCTYPE html>'
		SET @body += '<html>'
		SET @body += '<body>Dear <strong>' + @strEntityName + '</strong>, <br><br>'
		SET @body += 'Please see your ' + LOWER(@strReportName) + ' in the attachments tab. <br><br>'
		SET @body += 'Thank you for your business. <br><br>'
		SET @body += 'Sincerely, <br><br>'
		SET @body += '</html>'
		SET @Filter = '[{"column":"intEntityId","value":"' + @strIds + '","condition":"eq","conjunction":"and"}]'

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
					SELECT DISTINCT ', ' + LTRIM(intEntityContactId)
					FROM vyuCTEntityToContact
					WHERE intEntityId = @intEntityId
					FOR XML PATH('')
					), 1, 2, '')
		FROM vyuCTEntityToContact CH
		WHERE intEntityId = @intEntityId

		SET @Subject = 'Load/Shipment Schedule - Shipping Advice - ' + @strLoadNumber
		SET @body += '<!DOCTYPE html>'
		SET @body += '<html>'
		SET @body += '<body>Dear <strong>' + @strEntityName + '</strong>, <br><br>'
		SET @body += 'Please see your shipping advice in the attachments tab. <br><br>'
		SET @body += 'Thank you for your business. <br><br>'
		SET @body += 'Sincerely, <br><br>'
		SET @body += '</html>'
		SET @Filter = '[{"column":"intEntityId","value":"' + @strIds + '","condition":"eq","conjunction":"and"}]'

		SELECT @Subject AS strSubject
			,@Filter AS strFilters
			,@body AS strMessage
	END
	ELSE IF (@strReportName = 'In_store')
	BEGIN
		SELECT @strLoadNumber = strLoadNumber,
			   @intPurchaseSaleId = intPurchaseSale
		FROM tblLGLoad L
		JOIN tblLGLoadWarehouse LW ON LW.intLoadId = L.intLoadId
		WHERE LW.intLoadWarehouseId = @intTransactionId

		SELECT @intEntityId = (SELECT EM.intEntityId FROM tblLGLoadWarehouse LW
							   JOIN tblSMCompanyLocationSubLocation CLSL ON LW.intSubLocationId = CLSL.intCompanyLocationSubLocationId
							   JOIN tblEMEntity EM ON EM.intEntityId = CLSL.intVendorId
							   WHERE LW.intLoadWarehouseId = @intTransactionId)



		SELECT @strEntityName = strName
		FROM tblEMEntity
		WHERE intEntityId = @intEntityId

		SELECT @strIds = STUFF((
					SELECT DISTINCT ', ' + LTRIM(intEntityContactId)
					FROM vyuCTEntityToContact
					WHERE intEntityId = @intEntityId
					FOR XML PATH('')
					), 1, 2, '')
		FROM vyuCTEntityToContact CH
		WHERE intEntityId = @intEntityId

		SET @Subject = 'Load/Shipment Schedule - In Store Letter - ' + @strLoadNumber
		SET @body += '<!DOCTYPE html>'
		SET @body += '<html>'
		SET @body += '<body>Dear <strong>' + @strEntityName + '</strong>, <br><br>'
		SET @body += 'Please see your "in store letter"  in the attachments tab. <br><br>'
		SET @body += 'Thank you for your business. <br><br>'
		SET @body += 'Sincerely, <br><br>'
		SET @body += '</html>'
		SET @Filter = '[{"column":"intEntityId","value":"' + @strIds + '","condition":"eq","conjunction":"and"}]'

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
					SELECT DISTINCT ', ' + LTRIM(intEntityContactId)
					FROM vyuCTEntityToContact
					WHERE intEntityId = @intEntityId
					FOR XML PATH('')
					), 1, 2, '')
		FROM vyuCTEntityToContact CH
		WHERE intEntityId = @intEntityId

		SET @Subject = 'Load/Shipment Schedule - Carrier Shipment Order - ' + @strLoadNumber
		SET @body += '<!DOCTYPE html>'
		SET @body += '<html>'
		SET @body += '<body>Dear <strong>' + @strEntityName + '</strong>, <br><br>'
		SET @body += 'Please see your carrier shipment order in the attachments tab. <br><br>'
		SET @body += 'Thank you for your business. <br><br>'
		SET @body += 'Sincerely, <br><br>'
		SET @body += '</html>'
		SET @Filter = '[{"column":"intEntityId","value":"' + @strIds + '","condition":"eq","conjunction":"and"}]'

		SELECT @Subject AS strSubject
			,@Filter AS strFilters
			,@body AS strMessage
	END

END