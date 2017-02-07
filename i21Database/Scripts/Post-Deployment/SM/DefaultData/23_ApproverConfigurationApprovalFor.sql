GO
	PRINT N'INSERT APPROVER CONFFIGURATION APPROVAL FOR DEFAULT RECORDS'

	DECLARE @PurchaseOrderId INT
	SELECT @PurchaseOrderId = intScreenId FROM tblSMScreen WHERE strNamespace = 'AccountsPayable.view.PurchaseOrder'

	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMApproverConfigurationApprovalFor WHERE intScreenId = @PurchaseOrderId AND strType = 'Vendor')
	BEGIN
		INSERT INTO tblSMApproverConfigurationApprovalFor(intScreenId, strNamespace, strType, strApprovalFor, strDisplayField, strValueField)
		VALUES(@PurchaseOrderId, 'EntityManagement.common.combo.Vendor', 'Combobox', 'Vendor', 'strName', 'intEntityId')
	END

	DECLARE @VoucherId INT
	SELECT @VoucherId = intScreenId FROM tblSMScreen WHERE strNamespace = 'AccountsPayable.view.Voucher'

	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMApproverConfigurationApprovalFor WHERE intScreenId = @VoucherId AND strType = 'Vendor')
	BEGIN
		INSERT INTO tblSMApproverConfigurationApprovalFor(intScreenId, strNamespace, strType, strApprovalFor, strDisplayField, strValueField)
		VALUES(@VoucherId, 'EntityManagement.common.combo.Vendor', 'Combobox', 'Vendor', 'strName', 'intEntityId')
	END

	DECLARE @ContractId INT
	SELECT @ContractId = intScreenId FROM tblSMScreen WHERE strNamespace = 'ContractManagement.view.Contract'

	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMApproverConfigurationApprovalFor WHERE intScreenId = @ContractId AND strType = 'Contract Type')
	BEGIN
		INSERT INTO tblSMApproverConfigurationApprovalFor(intScreenId, strNamespace, strType, strApprovalFor, strDisplayField, strValueField)
		VALUES(@ContractId, 'i21.component.combobox.ContractType', 'Combobox', 'Contract Type', 'strContractType', 'intContractTypeId')
	END

	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMApproverConfigurationApprovalFor WHERE intScreenId = @ContractId AND strType = 'Product Type')
	BEGIN
		INSERT INTO tblSMApproverConfigurationApprovalFor(intScreenId, strNamespace, strType, strApprovalFor, strDisplayField, strValueField)
		VALUES(@ContractId, 'i21.component.combobox.ProductType', 'Combobox', 'Product Type', 'strDescription', 'intCommodityAttributeId')
	END

	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMApproverConfigurationApprovalFor WHERE intScreenId = @ContractId AND strType = 'Origin')
	BEGIN
		INSERT INTO tblSMApproverConfigurationApprovalFor(intScreenId, strNamespace, strType, strApprovalFor, strDisplayField, strValueField)
		VALUES(@ContractId, '', 'Textfield', 'Origin', NULL, NULL)
	END

GO