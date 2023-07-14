CREATE PROCEDURE [dbo].[uspGLConsolidate]  
 @dtmDate DATETIME,  
 @intEntityId INT  
AS  
DECLARE @intFiscalPeriodId  INT  
DECLARE @ysnOpen BIT  
DECLARE @strPeriod NVARCHAR(40)  
DECLARE @dtmCurrentDate DATETIME =GETDATE()  


SELECT TOP 1 @intFiscalPeriodId=intGLFiscalYearPeriodId, @ysnOpen=ysnOpen, @strPeriod=strPeriod  
FROM tblGLFiscalYearPeriod WHERE @dtmDate BETWEEN dtmStartDate AND dtmEndDate  

IF @ysnOpen = 0   
	RAISERROR('Selected Fiscal Period is closed', 16, 1);  
ELSE
BEGIN
	DECLARE @parentDbName NVARCHAR(50)  
	SELECT @parentDbName= DB_NAME()  
	DECLARE @dbTable TABLE ( intSubsidiaryCompanyId int, strDatabase NVARCHAR(50), strCompany NVARCHAR(50) )  
	DECLARE @intSubsidiaryCompanyId INT  
	DECLARE @strDatabase NVARCHAR(50)  
	DECLARE @strCompany NVARCHAR(50)  
	DECLARE @intConsolidateLogId INT  

	INSERT INTO @dbTable (intSubsidiaryCompanyId, strDatabase, strCompany)  
	SELECT intSubsidiaryCompanyId, strDatabase, strCompany FROM tblGLSubsidiaryCompany  
	WHERE strDatabase <> DB_NAME() 
		
	WHILE EXISTS(SELECT TOP 1 1 FROM @dbTable)  
	BEGIN  
		SELECT TOP 1   
		@intSubsidiaryCompanyId= intSubsidiaryCompanyId,   
		@strDatabase =strDatabase,   
		@strCompany = strCompany  
		FROM @dbTable  
		
		DELETE FROM @dbTable WHERE intSubsidiaryCompanyId = @intSubsidiaryCompanyId  
		
		INSERT INTO tblGLConsolidateLog  
		(  
			ysnSuccess,  
			dtmDateEntered ,  
			dtmDate,  
			intFiscalPeriodId ,  
			intConcurrencyId ,  
			intSubsidiaryCompanyId ,  
			intEntityId,  
			strPeriod  
		)  
		SELECT   
		0,  
		@dtmCurrentDate,  
		@dtmDate,  
		@intFiscalPeriodId ,  
		1 ,  
		@intSubsidiaryCompanyId,  
		@intEntityId,  
		@strPeriod  
		
		SELECT @intConsolidateLogId = SCOPE_IDENTITY()  
		
		BEGIN TRY  
			EXEC dbo.uspGLConsolidateSubsidiary   
			@intSubsidiaryCompanyId,  
			@dtmDate,  
			@parentDbName,  
			@strDatabase,  
			@intConsolidateLogId  
		END TRY  
		BEGIN CATCH  
				UPDATE tblGLConsolidateLog  
				SET strComment= ERROR_MESSAGE(),  
				intConcurrencyId = intConcurrencyId + 1  
				WHERE intConsolidateLogId = @intConsolidateLogId  
		END CATCH  
	END
END  
