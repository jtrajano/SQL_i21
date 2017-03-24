CREATE PROCEDURE [dbo].[uspGRReportStorageStatementDetail]
	@intEntityId INT,
	@intItemId   INT,
	@intStorageTypeId INT,
	@intStorageScheduleId INT,
	@strFormNumber NVarchar(30)
AS

BEGIN TRY
	
	DECLARE @ErrMsg NVARCHAR(MAX)
	DECLARE @strStorageType NVARCHAR(100)
	DECLARE @dblThereAfterCharge NUMERIC(18,10)
	DECLARE @dtmTerminationOfReceipt DATETIME
	DECLARE @strItemNo				NVARCHAR(100)
	DECLARE @strLicenseNumber		NVARCHAR(100)
	DECLARE @strPrefix              Nvarchar(100)
	DECLARE @intNumber				INT

	SELECT @strStorageType=strStorageTypeDescription FROM tblGRStorageType WHERE intStorageScheduleTypeId=@intStorageTypeId	
	SELECT @dblThereAfterCharge=ISNULL(dblStorageRate,0) FROM tblGRStorageSchedulePeriod WHERE intStorageScheduleRule=@intStorageScheduleId AND strPeriodType='Thereafter'
	SELECT TOP 1 @dtmTerminationOfReceipt=ISNULL(dtmEndingDate,0) FROM tblGRStorageSchedulePeriod WHERE intStorageScheduleRule=@intStorageScheduleId AND strPeriodType='Date Range'
	SELECT @strItemNo=strItemNo FROM tblICItem WHERE intItemId=@intItemId
	SELECT @strLicenseNumber=[strLicenseNumber] FROM [tblGRCompanyPreference]
	SELECT @strPrefix=[strPrefix],@intNumber=intNumber FROM tblSMStartingNumber WHERE [strTransactionType]	= N'Storage Statement FormNo'

	IF ISNULL(@strFormNumber,'')=''
	BEGIN
		SELECT	CS.intCustomerStorageId,
			CS.strStorageTicketNumber,
			CONVERT(Nvarchar,CS.dtmDeliveryDate,101) AS dtmReceiptDate,
			CASE 
				WHEN COM.strDescription LIKE '%Corn%' THEN 2
				WHEN COM.strDescription LIKE '%Wheat%' OR COM.strDescription LIKE '%bean%'  THEN 1
				ELSE NULL
			END
			AS strGrade,
			DItem.strItemNo AS strDryingItem,
			dbo.fnRemoveTrailingZeroes(QM.dblGradeReading) AS dblDryingReading,
			dbo.fnRemoveTrailingZeroes(ROUND(dbo.fnCTConvertQuantityToTargetItemUOM(CS.intItemId,CS.intUnitMeasureId,UOM.intUnitMeasureId, SC.dblNetUnits),3)) AS dblDryTonnes,
			@strStorageType AS strStorageType,
			dbo.fnRemoveTrailingZeroes(@dblThereAfterCharge) AS dblCharges,
			CONVERT(NVARCHAR,@dtmTerminationOfReceipt,101) AS dtmTerminationOfReceipt						 			
	FROM	tblGRCustomerStorage CS
	JOIN    tblICCommodity COM ON COM.intCommodityId=CS.intCommodityId
	JOIN    tblQMTicketDiscount QM ON QM.intTicketFileId=CS.intCustomerStorageId AND QM.strSourceType = 'Storage'
	JOIN tblGRDiscountScheduleCode Dcode ON Dcode.intDiscountScheduleCodeId = QM.intDiscountScheduleCodeId AND Dcode.ysnDryingDiscount=1 
	JOIN tblICItem DItem ON DItem.intItemId = Dcode.intItemId
	JOIN tblSCTicket SC ON SC.intTicketId=CS.intTicketId
	JOIN tblICItemUOM IU ON IU.intItemId = CS.intItemId
	JOIN tblICUnitMeasure UOM ON UOM.intUnitMeasureId=IU.intUnitMeasureId AND UOM.strUnitMeasure='Ton'
	WHERE CS.intEntityId=@intEntityId AND CS.intItemId=@intItemId 
	AND   CS.intStorageTypeId=@intStorageTypeId AND CS.intStorageScheduleId=@intStorageScheduleId 
	AND   CS.ysnPrinted=0 AND CS.intCustomerStorageId NOT IN(SELECT intCustomerStorageId FROM tblGRStorageStatement)
	ORDER BY CS.intCustomerStorageId
	
	INSERT INTO [dbo].[tblGRStorageStatement]
	(	
		[strFormNumber],
		[dtmIssueDate],
		[strLicenceNumber],
		[strItemNo],
		[intCustomerStorageId],
		[dtmDeliveryDate],
		[strGrade],
		[strDryingItem],
		[dblGradeReading],
		[dblDryTonnes],
		[strStorageType],
		[dblCharges],
		[dtmTerminationOfReceipt]
	)
	SELECT	
	NULL,
	GetDATE(),
	@strLicenseNumber,
	@strItemNo,	
	CS.intCustomerStorageId,
	CS.dtmDeliveryDate,
	CASE 
		WHEN COM.strDescription LIKE '%Corn%' THEN 2
		WHEN COM.strDescription LIKE '%Wheat%' OR COM.strDescription LIKE '%bean%'  THEN 1
		ELSE NULL
	END
	AS strGrade,
	DItem.strItemNo,	
	QM.dblGradeReading,
	ROUND(dbo.fnCTConvertQuantityToTargetItemUOM(CS.intItemId,CS.intUnitMeasureId,UOM.intUnitMeasureId, SC.dblNetUnits),3),
	@strStorageType AS strStorageType,
	@dblThereAfterCharge,
	@dtmTerminationOfReceipt
	FROM	tblGRCustomerStorage CS
	JOIN    tblICCommodity COM ON COM.intCommodityId=CS.intCommodityId
	JOIN    tblQMTicketDiscount QM ON QM.intTicketFileId=CS.intCustomerStorageId AND QM.strSourceType = 'Storage'
	JOIN tblGRDiscountScheduleCode Dcode ON Dcode.intDiscountScheduleCodeId = QM.intDiscountScheduleCodeId AND Dcode.ysnDryingDiscount=1 
	JOIN tblICItem DItem ON DItem.intItemId = Dcode.intItemId
	JOIN tblSCTicket SC ON SC.intTicketId=CS.intTicketId
	JOIN tblICItemUOM IU ON IU.intItemId = CS.intItemId
	JOIN tblICUnitMeasure UOM ON UOM.intUnitMeasureId=IU.intUnitMeasureId AND UOM.strUnitMeasure='Ton'
	WHERE CS.intEntityId=@intEntityId AND CS.intItemId=@intItemId 
	AND   CS.intStorageTypeId=@intStorageTypeId AND CS.intStorageScheduleId=@intStorageScheduleId
	AND   CS.ysnPrinted=0 AND CS.intCustomerStorageId NOT IN(SELECT intCustomerStorageId FROM tblGRStorageStatement)
	ORDER BY CS.intCustomerStorageId

	;WITH CTE as
	(
		SELECT tblGRStorageStatement.intStorageStatementId, ROW_NUMBER() OVER (ORDER BY intStorageStatementId) AS rowNum
		FROM tblGRStorageStatement WHERE strFormNumber IS NULL 
	)
	
	UPDATE SST
	SET strFormNumber=@strPrefix+LTRIM(@intNumber+CAST(rowNum / 15 AS INT)+ CASE WHEN rowNum % 15=0 THEN 0 ELSE 1 END)
	FROM tblGRStorageStatement SST
	JOIN CTE C ON C.intStorageStatementId=SST.intStorageStatementId

	UPDATE tblSMStartingNumber 
	SET intNumber=(SELECT MAX(CAST(REPLACE(strFormNumber,@strPrefix,'')AS INT)) FROM tblGRStorageStatement)
	FROM tblSMStartingNumber SN	
	WHERE SN.[strTransactionType]	= N'Storage Statement FormNo'
	
	END
	ELSE
	BEGIN
		SELECT
		intStorageStatementId,	
		ST.intCustomerStorageId,
		CS.strStorageTicketNumber,
		CONVERT(Nvarchar,CS.dtmDeliveryDate,101) AS dtmReceiptDate,
		ST.strGrade,
		ST.strDryingItem,
		dbo.fnRemoveTrailingZeroes(ST.dblGradeReading) AS dblDryingReading,
		dbo.fnRemoveTrailingZeroes(ST.dblDryTonnes) AS dblDryTonnes,
		ST.strStorageType AS strStorageType,
		dbo.fnRemoveTrailingZeroes(dblCharges) AS dblCharges,
		CONVERT(NVARCHAR,dtmTerminationOfReceipt,101) AS dtmTerminationOfReceipt						 			
		FROM tblGRStorageStatement ST
		JOIN tblGRCustomerStorage CS ON CS.intCustomerStorageId=ST.intCustomerStorageId 
		WHERE ST.strFormNumber=@strFormNumber
		ORDER BY intStorageStatementId
	END

END TRY

BEGIN CATCH

	SET @ErrMsg = ERROR_MESSAGE()  
	RAISERROR (@ErrMsg,18,1,'WITH NOWAIT')  
	
END CATCH
